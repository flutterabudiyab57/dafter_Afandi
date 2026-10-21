# Research: Purchases and Suppliers

Phase 0 for [plan.md](plan.md). Each entry has the decision, why, and what else was considered.
Binding inputs: the constitution, report §3.2, §3.3 and §4.2 as amended by M0-DECISIONS (Q12, Q15,
Q17, Q18, Q23, Q24), and the code of 001–003 (schema v1, `core/utils`, the customers and sales
features as the pattern).

## R1. Schema: no change, stay on v1

**Decision**: `schemaVersion` stays 1; make-migrations does not run.

**Rationale**: v1 already has every column and rule needed:
- `purchase_invoices` (number UNIQUE, supplierId NULL, supplierRef, invoiceDate, subtotal /
  discount / total / paid with CHECKs including "paid = total OR supplier set", paymentMethod, note,
  updatedAt, voidedAt / voidReason and the void-only update trigger);
- `purchase_items` (product name snapshot, qty, unitCost, discount, lineTotal,
  invoiceDiscountShare, netLineCost, avgCostBefore / avgCostAfter; UNIQUE(invoice, lineNo));
- `suppliers` (name, searchKey, phone, address, note, archivedAt) with search and phone indexes;
- `supplier_ledger` (OPENING_BALANCE, PURCHASE, PAYMENT_MADE, PURCHASE_VOID, ADJUSTMENT, REVERSAL;
  paymentNumber UNIQUE when set; paymentMethod required exactly on PAYMENT_MADE; reversesEntryId);
- `stock_movements` (PURCHASE needs purchaseItemId; PURCHASE_VOID needs purchaseItemId and
  reversesMovementId, qty < 0);
- `counters` seeded with every DocType, including PURCHASE and SUPPLIER_PAYMENT.

The supplier's invoice number limit (50) and the "not in the future" date rule are domain rules.
`purchase_items` has no unit snapshot column; the line shows the product's current unit, which
cannot change once the product has movements (002).

**Alternatives**: a unit snapshot column (rejected: needs a migration for no visible gain).

## R2. Packages: none new; lock audit

**Decision**: no pubspec change. Barcode input works as in 003 (keyboard-wedge scanner or typing,
then Enter). The date is picked with material_ui's `showDatePicker`.

The 8 `dependency_overrides` expire between 2026-10-27 and 2026-10-30. Phase 1 re-runs the 14-day
lock audit; any override past its date before 004's first commit is reported to the owner, who
approves its removal (no package change without approval).

## R3. Feature folders and dependencies

**Decision**: two new features, mirroring 003:
- `lib/features/suppliers/{domain,data,presentation}`: suppliers, their account, payments made.
- `lib/features/purchases/{domain,data,presentation}`: purchase draft, purchases, voids.

Purchases presentation reads products and suppliers through their **domain** interfaces only. The
purchase repository impl uses DAOs from `core/database/daos` inside its transaction (products,
stock movements, counters, purchases, supplier ledger), like `SalesRepositoryImpl`.

Shared pieces move instead of being copied:
- `reason_dialog.dart` moves from `customers/presentation/widgets` to `core/widgets` (sales,
  customers, purchases and suppliers use it);
- the product picker page and its cubit move from `sales/presentation` to
  `products/presentation`, gaining an optional quick-add action (R13).

**Alternatives**: a generic "party" feature for customers and suppliers (rejected: it would
rewrite tested 003 code; the two ledgers have different types and signs).

## R4. Document numbers

**Decision**: reuse `CountersDao.take(DocType)` inside the transaction: `PURCHASE` for purchases,
`SUPPLIER_PAYMENT` for standalone payments. Display through `formatDocNumber` with `P-` and `PY-`
(six digits). A rollback undoes the increment (SC-006).

## R5. Purchase amounts in the domain

**Decision**: `PurchaseDraft` (pure Dart), like `SaleDraft`:
- `gross = lineTotalPiasters(qtyMilli, unitCostPiasters)` (half up);
- `lineTotal = gross − lineDiscount`, `0 ≤ lineDiscount ≤ gross`;
- `subtotal = Σ lineTotal`, `total = subtotal − invoiceDiscount`, `0 ≤ invoiceDiscount ≤ subtotal`;
- `shares = allocateLargestRemainder(invoiceDiscount, lineTotals)`;
- `netLineCost = lineTotal − share` (≥ 0), the amount that enters the average.

The repository re-reads products and recomputes inside the transaction. One line per product, as
003 R6.

## R6. Invoice date

**Decision**: the draft holds a local calendar date (default today). It is stored as the UTC
epoch ms of local midnight of that date. Validation: date ≤ today (local). The list orders by
`invoice_date DESC, number DESC`. Average cost never uses the invoice date; it follows the save
order `(created_at, rowid)` (spec Assumptions, report R7).

## R7. Saving a purchase (one transaction)

Reads first: each product is active (else `ProductUnavailable(name)`); the supplier, when set, is
active (else `SupplierUnavailable`); `paid < total` needs a supplier (`CreditNeedsSupplier`).

Writes, in order (report §4.2):
- W1 take the PURCHASE number;
- W2 insert `purchase_invoices` (`updatedAt = createdAt`);
- per line in lineNo order (W3–W5 interleaved, so a later line sees the earlier one):
  - `S = SUM(stock_movements)` for the product, `A = products.avgCostPiasters`;
  - `A' = weightedAverageCost(stockMilli: S, avgCostPiasters: A, inQtyMilli: qty,
    inTotalCostPiasters: netLineCost)` (S ≤ 0 → the line's own cost);
  - W3 insert `purchase_items` (avgCostBefore = A, avgCostAfter = A');
  - W4 insert `stock_movements` PURCHASE (+qty, unitCost = roundHalfUpDiv(netLineCost × 1000, qty),
    purchaseItemId);
  - W5 `products.setAvgCost(A')`;
- W6 with a supplier: `supplier_ledger` PURCHASE (+total, purchaseInvoiceId);
- W7 with a supplier and paid > 0: PAYMENT_MADE (−paid, method, purchaseInvoiceId, no payment
  number; the number is for standalone payments, as RC- in 003).

No selling price is written (clarification Q3).

## R8. Average cost replay

**Problem**: 002's `rebuildAverageCost` replays every movement and treats PURCHASE_VOID as a plain
stock decrease, so a voided purchase's cost would stay blended in. It also rebuilds a purchase's
cost from its rounded per-unit cost, which can differ from `netLineCost` by a few piasters and
break "stored = replay" (SC-004).

**Decision**:
- `StockMovementsDao.replayRows` skips every PURCHASE movement that a PURCHASE_VOID reverses, and
  the PURCHASE_VOID rows themselves ("as if never recorded", FR-009a);
- for PURCHASE rows it reads `purchase_items.net_line_cost_piasters` (LEFT JOIN on purchaseItemId)
  as the inbound total cost; other inbound rows keep `lineTotalPiasters(qty, unitCost)`.
- the replay loop moves to one pure function `replayAverageCost(rows)` in
  `features/products/domain/average_cost_replay.dart`; `InventoryRepositoryImpl.rebuildAverageCost`
  and the purchase void both call it with the DAO's rows.

Existing data has no purchases, so 002 and 003 results do not change; their property tests stay
as they are and gain purchase steps.

**Alternatives**: undo the voided line's contribution arithmetically (rejected: wrong when later
purchases blended in after it, which is why Q18 chose replay).

## R9. Voiding a purchase (one transaction)

Reads: the purchase exists and is not voided (else `AlreadyVoided`); the reason is 1–200 code
points after trimming (else `VoidReasonInvalid`); its items and their PURCHASE movements; each
product's current stock. If any product's stock minus its voided quantity would be below zero and
`acknowledgeShortage` is false, return `Err(VoidStockShortage([...]))` with name, unit and the
resulting stock, and write nothing (clarification Q2).

Writes:
- V1 update `purchase_invoices` set voidedAt, voidReason, updatedAt (void-only trigger allows it);
- V2 per item: PURCHASE_VOID (−qty, unitCost = the PURCHASE movement's unitCost, purchaseItemId,
  reversesMovementId);
- V3 per distinct product: `setAvgCost(replayAverageCost(replayRows(product)))` (R8);
- V4 with a supplier: PURCHASE_VOID (−total, purchaseInvoiceId, reversesEntryId = PURCHASE row);
- V5 with a supplier and paid > 0: REVERSAL (+paid, reversesEntryId = PAYMENT_MADE row, note =
  reason).

Archived products and suppliers do not block a void.

## R10. Supplier balance, lists and statement

**Decision**: as 003 R8 and R9, on `suppliers` and `supplier_ledger`: balance by correlated
`SUM`, Arabic-first name order, `instr` search on search_key and phone, "shop owes" filter =
balance > 0, highest first; the statement uses the running-balance window over
`(created_at, rowid)`, newest first, paged by 50 with a cursor, each row carrying type, amount,
running balance, purchase id and number, payment number, method, note and whether it was
reversed. `watchStatementChanges` (row count) reloads the statement as in the 003 review fix.

## R11. Supplier payments and cancelling them

**Decision**:
- pay: one transaction, take the SUPPLIER_PAYMENT number, insert PAYMENT_MADE (−amount, method,
  paymentNumber, note);
- cancel: one transaction, check the reason, check the row is a PAYMENT_MADE with a payment number
  and no reversal, then insert REVERSAL (+amount, reversesEntryId, note = trimmed reason).

The "supplier will owe the shop" notice is computed by the cubit from the balance before saving.

## R12. Supplier form, opening balance, archive

**Decision**: the 003 rules (R13, R14) on the supplier tables: name 1–100, phone via
`parseShopPhone`, address and note ≤ 200; opening balance only when adding, amount plus direction
(owed by the shop = +, in the shop's favour = −) as an OPENING_BALANCE row in the same transaction;
a same-name notice; archive / restore with a balance confirmation.

## R13. Quick add of a product (clarification Q1)

**Decision**: the product picker shows "Add «text» as a new product" when a search finds nothing
(and always as a last row). It opens a short form: name (prefilled from the search text), unit,
selling price, optional barcode. Saving calls the existing `ProductRepository.create(ProductDraft)`
with no opening stock, so 002's validation and barcode uniqueness apply unchanged. The new product
is returned to the purchase as a line. It is its own transaction, before and apart from the
purchase; discarding the purchase keeps the product (spec US1 scenario 9). The sale screen does
not offer quick add.

## R14. Prefilled cost and the cost notice (clarify session)

**Decision**:
- `PurchaseRepository.lastUnitCost(productId)`: `unit_cost_piasters` of the newest
  `purchase_items` row (by `created_at`, `rowid`) whose invoice is not voided; null when none. The
  cubit falls back to the product's `avgCostPiasters`. Uses `ix_purchase_items_product_id`.
- The notice shows when `lineTotal ≥ lineTotalPiasters(qtyMilli, salePricePiasters)`: integer
  comparison of the line after its line discount with the same quantity at the selling price, so
  no per-unit rounding. The invoice discount does not affect the notice. Nothing blocks saving.

## R15. Routes and the Parties switch

**Decision**, as children of the section branches so the bottom bar stays:
- Purchases branch: `/purchases` (list, New purchase button), `/purchases/new`, `/purchases/:id`.
- Parties branch: `/parties` (customers, as in 003) and `/parties/suppliers` (suppliers),
  `/parties/suppliers/new`, `/parties/suppliers/archived`, `/parties/suppliers/:id`,
  `/parties/suppliers/:id/edit`, `/parties/suppliers/:id/payment`.

Both list screens start with the same two-segment control (Customers | Suppliers) that switches
with `go`, so each list keeps its own route and the existing customer tests keep their paths. Void
and cancel are dialogs; the product and supplier pickers are pushed full-screen pages.

## R16. Purchase list

**Decision**: watch the newest 50 matching purchases, "Show more" grows the limit. All-digit text
(any digit set, `P-` prefix allowed) matches the number exactly or as a prefix; other text matches
the supplier's search_key or the supplier's invoice number (`instr` on the folded value). Filter:
all / not fully paid (not voided). The row shows the supplier name, or "no supplier".

## R17. Cubit factories and leaving an unsaved purchase

**Decision**: `SuppliersCubits` and `PurchasesCubits` bundles like `CustomersCubits` and
`SalesCubits`, passed App → `createAppRouter`; tests pass bundles on in-memory fakes. The purchase
screen uses `PopScope(canPop: draft.isEmpty)` with the Discard / Keep dialog, as 003 R18.
