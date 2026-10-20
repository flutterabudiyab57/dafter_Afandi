# Data Model: Sales and Customers

Stored tables are schema v1 as shipped (research R1). This file lists the **domain** types, their
rules, and every write. Money is `int` piasters, quantity `int` milli. Time is UTC `DateTime`.

## Customers domain (`lib/features/customers/domain/`)

### Customer
| Field | Type | Rule |
|---|---|---|
| id | String | UUID v7 |
| name | String | trimmed, 1–100 code points |
| phone | String? | `parseShopPhone` → normalized, or null |
| address | String? | trimmed, ≤ 200 code points, empty → null |
| note | String? | same |
| archived | bool | |

### CustomerSummary
Customer + `balancePiasters` (Σ ledger; positive = owes the shop).

### CustomerDraft.create({name, phone, address, note, openingText, openingInFavour})
Returns `Result<CustomerDraft, List<CustomerFieldError>>`, collecting all errors. Opening:
empty or 0 → none; else 0 < amount ≤ 1,000,000,000 piasters, ≤ 2 decimals; sign = + (owes) or −
(in their favour).

### CustomerFieldError (sealed, each with `field`)
NameRequired, NameTooLong(max), PhoneInvalid, PhoneTooShort, PhoneTooLong, TextTooLong(max),
AmountInvalid, AmountTooLarge(max).

### LedgerEntry (statement row)
id, type (`LedgerEntryType`: openingBalance, sale, payment, saleVoid, reversal), amountPiasters
(signed), runningBalancePiasters, at, rowOrder, invoiceId?, invoiceNumber?, receiptNumber?,
method (`PaymentMethod`?), note?, reversed (bool), cancellable (bool = payment with receipt and
not reversed).

### PaymentMethod
cash, wallet, instapay (card exists in storage, not offered).

### PaymentRequest.create({amountText, method, note})
0 < amount ≤ 1e9 piasters, ≤ 2 decimals; note ≤ 200 code points.

### Reason rule (shared, `validateReason`)
trimmed, 1–200 code points. Errors: ReasonRequired, ReasonTooLong(max).

### Errors
- `CustomerSaveError`: CustomerNotFound.
- `PaymentError`: CustomerNotFound, PaymentNotCancellable, AlreadyCancelled.

## Sales domain (`lib/features/sales/domain/`)

### SaleLine
productId, name, unit, qtyMilli, unitPricePiasters, lineDiscountPiasters; getters `gross`,
`lineTotal`.

### SaleDraft (immutable, value methods)
lines, invoiceDiscountPiasters, paidPiasters? (null = full), method, customer (id + name)?, note?.
Methods: `add(product)` (new line qty 1 unit, or +1 unit), `setQty`, `setPrice`, `setLineDiscount`,
`remove`, `setInvoiceDiscount`, `setPaid`, `setCustomer`. Getters: `subtotal`, `total`, `paid`
(paidPiasters ?? total), `remaining`, `shares` (largest remainder), `isEmpty`.
`validate()` → `List<SaleError>`: NoLines, LineQuantity(productId, kind), LinePrice(productId,
kind), LineDiscountTooLarge(productId), InvoiceDiscountTooLarge, PaidTooLarge,
CreditNeedsCustomer.

Number text is parsed by the screen fields through `readQuantity` / `readMoney` (002) into the
draft; the draft only stores integers.

### SaleSaveError (sealed)
StockShortage(List<Shortage{productId, name, unit, stockMilli, needMilli}>), ProductUnavailable(name),
CustomerUnavailable, plus the validation errors above re-checked in the transaction.

### SaleSummary (list row)
id, number, at, customerName?, totalPiasters, paidPiasters, voided.
Getter `kind`: cash (paid = total), partial, credit (paid = 0).

### SaleInvoice (view)
SaleSummary fields + customerId?, subtotal, invoiceDiscount, method, note, voidedAt?,
voidReason?, items: List<SaleItem{lineNo, name, unit, qtyMilli, unitPrice, lineDiscount,
lineTotal}>.

### VoidError
InvoiceNotFound, AlreadyVoided.

## Writes (each is ONE transaction)

| Operation | Reads | Writes |
|---|---|---|
| Create customer | — | customers insert; OPENING_BALANCE (±) when opening ≠ 0 |
| Edit customer | exists | customers update (name, searchKey, phone, address, note, updatedAt) |
| Archive / restore customer | exists | customers.archivedAt |
| Receive payment | customer active | counters CUSTOMER_RECEIPT; ledger PAYMENT_RECEIVED (−amount, method, receiptNumber, note) |
| Cancel payment | row is a receipt payment, not reversed | ledger REVERSAL (+amount, reversesEntryId, note = reason) |
| Save sale | products active, stock, customer active | W1–W6 (research R10) |
| Void sale | invoice not voided, items, SALE movements, stock, avgCost | V1–V5 (research R11) |

## Invariants checked by tests

- Customer balance = Σ ledger rows (SC-003), after random sales, payments, cancels and voids.
- Stock = Σ movements and avgCost = replay, after random sales and voids (SC-004).
- Invoice: total = Σ lineTotal − invoiceDiscount; Σ shares = invoiceDiscount.
- Numbers SALE and CUSTOMER_RECEIPT are 1..n without gaps, also after a failed transaction.
