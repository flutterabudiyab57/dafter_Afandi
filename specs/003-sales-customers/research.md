# Research: Sales and Customers

Phase 0 for [plan.md](plan.md). Each entry has the decision, why, and what else was considered.
Binding inputs: the constitution, report §3 and §4.1 as amended by M0-DECISIONS, and the code of
001 and 002 (schema v1, `core/utils`, the products feature as the pattern).

## R1. Schema: no change, stay on v1

**Decision**: `schemaVersion` stays 1; make-migrations does not run.

**Rationale**: v1 already has every column and rule needed:
- `sales_invoices` (number UNIQUE, customerId NULL, subtotal/discount/total/paidAtSale with CHECKs
  including "paid = total OR customer set", paymentMethod, note, voidedAt/voidReason/updatedAt and
  the void-only update trigger);
- `sale_items` (snapshots of name, unit and unit cost; lineTotal, invoiceDiscountShare, lineCost;
  UNIQUE(invoice, lineNo));
- `customers` (name, searchKey, phone, address, note, archivedAt);
- `customer_ledger` (OPENING_BALANCE, SALE, PAYMENT_RECEIVED, SALE_VOID, REVERSAL; receiptNumber
  UNIQUE; paymentMethod required exactly on payment and refund rows; reversesEntryId);
- `stock_movements` (SALE needs saleItemId; SALE_VOID needs saleItemId and reversesMovementId);
- `counters` seeded with SALE and CUSTOMER_RECEIPT.

Limits (names, notes, reasons) are domain rules, as in 002.

**Alternatives**: a `cancelledAt` column on ledger rows (rejected: ledgers are append-only; a
reversal row pointing at the payment says the same thing).

## R2. Packages: none new

**Decision**: no pubspec change. "Scan a barcode" means a hardware (keyboard-wedge) scanner or
typing into the search field, then Enter. Camera scanning needs a package and stays out of scope.
The lock audit runs again before the first commit.

## R3. Feature folders and dependencies

**Decision**: two features:
- `lib/features/customers/{domain,data,presentation}`: customers, their account, payments.
- `lib/features/sales/{domain,data,presentation}`: sale draft, invoices, voids.

Sales presentation reads products and customers through their **domain** interfaces only
(`ProductRepository`, `CustomerRepository`). The sales repository impl uses DAOs from
`core/database/daos` directly inside its transaction (the products, stock and ledger DAOs). This
keeps every write of one sale inside one transaction without a repository calling another
repository.

## R4. Document numbers

**Decision**: `CountersDao.take(DocType)` runs
`UPDATE counters SET next_value = next_value + 1, updated_at = ? WHERE doc_type = ? RETURNING next_value - 1`
inside the caller's transaction. A rollback undoes the increment, so no number is burned (SC-005).
The UI shows `S-000012` and `RC-000001` through `formatDocNumber(prefix, n)` in `core/utils`
(six digits, then as many as needed, in the active digit style).

## R5. Sale amounts in the domain

**Decision**: `SaleDraft` (pure Dart) holds lines and computes everything with the existing
helpers:
- `gross = lineTotalPiasters(qtyMilli, unitPricePiasters)` (half up);
- `lineTotal = gross − lineDiscount`, with `0 ≤ lineDiscount ≤ gross`;
- `subtotal = Σ lineTotal`, `total = subtotal − invoiceDiscount`, `0 ≤ invoiceDiscount ≤ subtotal`;
- `shares = allocateLargestRemainder(invoiceDiscount, lineTotals)` so Σ shares = invoiceDiscount;
- at save time `unitCost = product.avgCostPiasters` and
  `lineCost = lineTotalPiasters(qtyMilli, unitCost)`.

The repository re-reads products and recomputes inside the transaction (report §4 pre-step), so a
price shown on screen and the saved values cannot drift.

## R6. One line per product

**Decision**: adding a product already on the draft raises that line's quantity by one unit
(1 piece, 1 kg…). The draft rejects a second line for the same product, so stock checks and voids
work per line without merging.

## R7. Stock shortage (policy warn)

**Decision**: `SalesRepository.create(draft, {acknowledgeShortage})` computes, inside the
transaction, each product's need against `SUM(stock_movements)`. If any need exceeds stock and
`acknowledgeShortage` is false it returns `Err(StockShortage([...]))` with name, unit and stock, and
writes nothing. The cubit shows the warning and resubmits with `acknowledgeShortage: true`. The
`block` policy is not offered (spec Assumptions); the setting stays `warn`.

## R8. Customer balance and lists

**Decision**: balance = `COALESCE((SELECT SUM(amount_piasters) FROM customer_ledger l WHERE
l.customer_id = c.id), 0)` as a correlated subquery, like stock in 002. The list orders by
`(unicode(search_key) < 1536) ASC, search_key, name, id` (002 R5). Search is `instr` on
search_key and on the phone. "Owes money" filter: `balance > 0 ORDER BY balance DESC, …`.
Watch queries use `customSelect(...).watch()` with `readsFrom: {customers, customerLedger}`.

## R9. Statement with a running balance

**Decision**: one query per page using a window function:
`SUM(amount_piasters) OVER (ORDER BY created_at, rowid ROWS UNBOUNDED PRECEDING)` computed over
the customer's rows, then ordered newest first and paged (50) with a `(createdAt, rowid)` cursor,
as the 002 history. Each row carries its type, amount, running balance, invoice id and number,
receipt number, payment method, note, and whether it was reversed.

## R10. Saving a sale (one transaction)

Writes, in order (report §4.1):
- W1 take the SALE number;
- W2 insert `sales_invoices` (`updatedAt = createdAt`);
- W3 insert `sale_items` × n with lineNo 1..n;
- W4 insert `stock_movements` SALE × n (−qty, unitCost snapshot, saleItemId);
- W5 with a customer: `customer_ledger` SALE (+total, salesInvoiceId);
- W6 with a customer and paid > 0: PAYMENT_RECEIVED (−paid, method, salesInvoiceId).

Reads first: each product is active (else `ProductUnavailable(name)`); the customer, when set, is
active (else `CustomerUnavailable`); `paid < total` needs a customer (`CreditNeedsCustomer`).

## R11. Voiding a sale (one transaction, clarification Q1)

Reads: the invoice exists and is not voided (else `AlreadyVoided`); its items and their SALE
movements; current stock and average cost of each product.
Writes:
- V1 update `sales_invoices` set voidedAt, voidReason, updatedAt (allowed by the void-only trigger);
- V2 per item: insert SALE_VOID (+qty, unitCost = item.unitCostPiasters, saleItemId,
  reversesMovementId = the SALE movement);
- V3 per item: `avgCost = weightedAverageCost(stock before V2, avgCost, qty, lineCost)` (Q9);
- V4 with a customer: SALE_VOID (−total, reversesEntryId = the SALE row);
- V5 with a customer and paid > 0: REVERSAL (+paid, reversesEntryId = the PAYMENT row, note =
  reason).

Archived products and customers do not block a void. The 002 replay (`rebuildAverageCost`)
already treats SALE_VOID as inbound at its unit cost, so the property test still holds.

## R12. Payments and cancelling them

**Decision**:
- receive: in one transaction, take the CUSTOMER_RECEIPT number, insert PAYMENT_RECEIVED
  (−amount, method, receiptNumber, note);
- cancel: in one transaction, check the row is a PAYMENT_RECEIVED with a receipt number (not a
  payment at sale) and has no reversal yet, then insert REVERSAL (+amount, reversesEntryId, note =
  reason). A payment is "cancelled" when a reversal points to it.

The "credit after payment" notice is computed by the cubit from the current balance before saving.

## R13. Customer form and opening balance

**Decision**: name 1–100 code points after trimming; phone via the existing `parseShopPhone`
(7–15 digits); address and note ≤ 200 code points. The opening balance is offered only when adding:
an amount plus a direction (owed by the customer / in their favour). Create inserts the customer
and, when the amount is above 0, an OPENING_BALANCE row (±) in one transaction. A same-name notice
follows 002 R14.

## R14. Archiving a customer

**Decision**: archive sets archivedAt; restore clears it. No uniqueness conflict exists on
restore (names may repeat). The confirmation shows the balance when it is not zero.

## R15. Routes

**Decision**, as children of the section branches so the bottom bar stays:
- Sales branch: `/sales` (invoice list, New sale button), `/sales/new`, `/sales/:id`.
- Parties branch: `/parties` (customers list), `/parties/customers/new`,
  `/parties/customers/archived`, `/parties/customers/:id`, `/parties/customers/:id/edit`,
  `/parties/customers/:id/payment`.

Void and cancel are dialogs on the invoice and customer pages. The product and customer pickers
are full-screen pages pushed with `Navigator` and return their pick.

## R16. Invoice list

**Decision**: watch the newest 50 matching invoices, with "Show more" growing the limit. Search
text that is all digits (any digit set, `S-` prefix allowed) matches the number exactly or as a
prefix; other text matches the customer's search_key. Filters: all / not fully paid (credit or
partial, not voided). The row shows customer name, or "walk-in customer".

## R17. Cubit factories

**Decision**: `SalesCubits` and `CustomersCubits` bundles like `ProductsCubits` (002 R11), passed
App → `createAppRouter`; tests pass bundles built on in-memory fakes in `test/helpers/`.

## R18. Leaving an unsaved sale

**Decision**: `PopScope(canPop: draft.isEmpty)`; on a blocked pop a dialog asks Discard / Keep.
Switching sections keeps the branch stack (the draft survives), which is the expected behaviour of
the indexed shell.
