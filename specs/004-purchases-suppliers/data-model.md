# Data Model: Purchases and Suppliers

Stored tables are schema v1 as shipped (research R1). This file lists the **domain** types, their
rules, and every write. Money is `int` piasters, quantity `int` milli. Time is UTC `DateTime`.
`PaymentMethod`, `validateReason` and the reason errors are reused from
`features/customers/domain/payment.dart` (003).

## Suppliers domain (`lib/features/suppliers/domain/`)

### Supplier
| Field | Type | Rule |
|---|---|---|
| id | String | UUID v7 |
| name | String | trimmed, 1–100 code points |
| phone | String? | `parseShopPhone` → normalized, or null |
| address | String? | trimmed, ≤ 200 code points, empty → null |
| note | String? | same |
| archived | bool | |

### SupplierSummary
Supplier + `balancePiasters` (Σ supplier ledger; positive = the shop owes the supplier).

### SupplierDraft.create({name, phone, address, note, openingText, openingInShopFavour})
Returns `Result<SupplierDraft, List<SupplierFieldError>>`, collecting all errors. Opening: empty or
0 → none; else 0 < amount ≤ 1,000,000,000 piasters, ≤ 2 decimals; sign = + (owed by the shop) or
− (in the shop's favour).

### SupplierFieldError (sealed, each with `field`)
NameRequired, NameTooLong(max), PhoneInvalid, PhoneTooShort, PhoneTooLong, TextTooLong(max),
AmountInvalid, AmountTooLarge(max).

### SupplierEntry (statement row)
id, type (`SupplierEntryType`: openingBalance, purchase, payment, purchaseVoid, reversal),
amountPiasters (signed), runningBalancePiasters, at, rowOrder, purchaseId?, purchaseNumber?,
paymentNumber?, method (`PaymentMethod`?), note?, reversed (bool), cancellable (bool = payment
with a payment number and not reversed).

### SupplierPaymentRequest.create({amountText, method, note})
0 < amount ≤ 1e9 piasters, ≤ 2 decimals; note ≤ 200 code points.

### Errors
- `SupplierSaveError`: SupplierNotFound.
- `SupplierPaymentError`: SupplierNotFound, SupplierArchived, PaymentNotCancellable,
  PaymentAlreadyCancelled, PaymentReasonInvalid.

## Purchases domain (`lib/features/purchases/domain/`)

### PurchaseLine (draft)
| Field | Type | Rule |
|---|---|---|
| productId | String | one line per product |
| name | String | shown; the saved snapshot is re-read in the transaction |
| unit | UnitType | piece → whole quantities only |
| salePricePiasters | int | for the cost notice only |
| qtyMilli | int | 0 < qty ≤ 1,000,000,000 |
| unitCostPiasters | int | 0 ≤ cost ≤ 1,000,000,000; prefilled per research R14 |
| discountPiasters | int | 0 ≤ discount ≤ gross |

Derived: `gross`, `lineTotal`, `costNotice` (`lineTotal ≥ lineTotalPiasters(qty, salePrice)`).

### PurchaseDraft
lines, invoiceDiscountPiasters (0 ≤ d ≤ subtotal), supplier (`PurchaseSupplier{id, name}`?),
supplierRef (trimmed, ≤ 50 code points, empty → null), invoiceDate (local date ≤ today), paid
(`int?`, null = pay all), method (default cash), note (≤ 200).
Derived: subtotal, total, shares (largest remainder), netLineCost per line, paid, remaining.
`add` raises the quantity of an existing line by one unit.

### Purchase (saved)
summary (id, number, invoiceDate, createdAt, supplier name?, supplierRef?, total, paid,
remaining, voided, kind: cash / partial / credit), supplierId?, lines (name snapshot, unit,
qty, unitCost, discount, lineTotal, share), subtotal, invoiceDiscount, method, note, voidedAt?,
voidReason?.

### PurchaseQuery
text, unpaidOnly, supplierId?.

### Errors
- `PurchaseInputError` (draft, before saving): NoLines, QuantityInvalid, QuantityNotWhole,
  CostInvalid, DiscountTooLarge, InvoiceDiscountTooLarge, PaidTooLarge, CreditNeedsSupplier,
  DateInFuture, RefTooLong, NoteTooLong, DuplicateLine.
- `PurchaseSaveError`: ProductUnavailable(name), SupplierUnavailable, CreditNeedsSupplier.
- `PurchaseVoidError`: PurchaseNotFound, AlreadyVoided, VoidReasonInvalid,
  VoidStockShortage(List<VoidShortage{name, unit, stockAfterMilli}>).

## Shared (`lib/features/products/domain/average_cost_replay.dart`)

`int replayAverageCost(Iterable<ReplayMovement> rows)`, where `ReplayMovement{qtyDeltaMilli,
inboundCostPiasters?}` (null for movements that do not change the average). Pure; used by
`InventoryRepositoryImpl.rebuildAverageCost` and the purchase void (research R8).

## Writes (each list is ONE transaction)

### Save purchase (research R7)
| # | Write |
|---|---|
| W1 | `counters` PURCHASE +1 → number |
| W2 | insert `purchase_invoices` |
| W3 | per line: insert `purchase_items` (avgCostBefore, avgCostAfter) |
| W4 | per line: insert `stock_movements` PURCHASE (+qty, unitCost, purchaseItemId) |
| W5 | per line: update `products.avg_cost_piasters`, `updated_at` |
| W6 | with supplier: insert `supplier_ledger` PURCHASE (+total) |
| W7 | with supplier, paid > 0: insert `supplier_ledger` PAYMENT_MADE (−paid, method) |

### Void purchase (research R9)
| # | Write |
|---|---|
| V1 | update `purchase_invoices` voided_at, void_reason, updated_at |
| V2 | per item: insert `stock_movements` PURCHASE_VOID (−qty, reversesMovementId) |
| V3 | per product: update `products.avg_cost_piasters` from the replay |
| V4 | with supplier: insert `supplier_ledger` PURCHASE_VOID (−total, reversesEntryId) |
| V5 | with supplier, paid > 0: insert `supplier_ledger` REVERSAL (+paid, reversesEntryId, note) |

### Create supplier (research R12)
| # | Write |
|---|---|
| C1 | insert `suppliers` |
| C2 | opening ≠ 0: insert `supplier_ledger` OPENING_BALANCE (±amount) |

### Pay supplier / cancel payment (research R11)
| # | Write |
|---|---|
| P1 | `counters` SUPPLIER_PAYMENT +1 → number |
| P2 | insert `supplier_ledger` PAYMENT_MADE (−amount, method, paymentNumber, note) |
| X1 | cancel: insert `supplier_ledger` REVERSAL (+amount, reversesEntryId, note = reason) |

Update supplier, archive and restore are single-row updates of `suppliers`. Quick add of a product
is 002's product create (research R13), not part of these transactions.
