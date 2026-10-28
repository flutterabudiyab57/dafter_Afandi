# Research: Reports, Home Dashboard and Expenses

Decisions for 006. Each entry gives the decision, why, and what else was considered. "Owner" items
need the owner's yes before the phase that uses them.

## R1. Schema v2: one new table, no new columns

**Decision**: Add one table, `payment_parts`, and one index on `stock_movements`. No column is
added to an existing table. Expenses take their payment method from their parts, not from a new
column. The schema version goes from 1 to 2 with `make-migrations` and one step `from1To2`.

**Rationale**: The five voidable or immutable headers already have void-only and immutable
triggers, and `kVoidableFrozenColumns` lists their frozen columns. A new column on any of them
means re-creating triggers and the table (SQLite cannot add a CHECK to an existing table). A side
table leaves every v1 table, trigger and check as it is, so the upgrade is small and safe.

**Alternatives**: A `payment_method` column on `expenses` (needs a table rebuild for the CHECK
and a trigger change, and still no split). Splitting by writing several ledger rows per payment
(the statement would show one payment as two rows, and sales and purchases headers hold one
method). One table per document type (five near-identical tables).

## R2. How parts attach to documents

**Decision**: `payment_parts` has five nullable foreign keys: `sales_invoice_id`,
`purchase_invoice_id`, `customer_ledger_id`, `supplier_ledger_id`, `expense_id`. A CHECK requires
exactly one of them. Parts attach to:

| Money | Parts belong to |
|---|---|
| Paid at sale time | the sale invoice |
| Customer receipt (RC-) | its `PAYMENT_RECEIVED` ledger row (the one with a receipt number) |
| Paid at purchase time | the purchase invoice |
| Supplier payment (PY-) | its `PAYMENT_MADE` ledger row (the one with a payment number) |
| Expense | the expense |

The `PAYMENT_RECEIVED` and `PAYMENT_MADE` rows that a sale or purchase writes for a named party get
no parts of their own; their parts are the invoice's. So no payment is ever counted twice.

**Rationale**: Real foreign keys keep referential integrity and the `RESTRICT` rules; one table
gives one query for money collected and one for account suggestions.

**Alternatives**: A polymorphic `(doc_type, doc_id)` pair (no foreign key). Parts on every ledger
row (would double-count sales with a named customer).

## R3. The header and ledger `payment_method` columns stay

**Decision**: Every existing `payment_method` column keeps being written: with the method of part
number 1. Readers that need the split read the parts. The constitution rule "paymentMethod on
sales, purchases, sale returns and payment ledger rows" stays true.

**Rationale**: No v1 column changes meaning; older code paths and the statement keep working.

**Alternatives**: Writing a new `mixed` value (needs a CHECK change on five tables).

## R4. Upgrading existing data (FR-041)

**Decision**: `from1To2` creates the table, its indexes and triggers, then backfills one part per
existing payment, in the same migration transaction:
- each sale with `paid_at_sale_piasters > 0`: part 1 = (header method, paid at sale);
- each purchase with `paid_piasters > 0`: part 1 = (header method, paid);
- each customer ledger `PAYMENT_RECEIVED` row with a receipt number: part 1 = (row method, −amount);
- each supplier ledger `PAYMENT_MADE` row with a payment number: part 1 = (row method, −amount);
- each expense (none exist yet; the table has had no screen): part 1 = (cash, amount).

Backfilled parts take the parent's `created_at`, a new UUID v7 and no account number. Voided and
reversed parents are backfilled too, so history stays complete.

**Rationale**: After the upgrade every reader can rely on parts, with no "old row" branch.
A generated migration test checks the v1 → v2 data and every balance before and after (SC-009).

## R5. Parts are immutable and add up

**Decision**: `payment_parts` joins `kImmutableTables` (no update, no delete). Its own CHECKs:
`amount_piasters > 0`, `part_no BETWEEN 1 AND 3`, `method IN ('cash','wallet','instapay','card')`
(the stored domain, so a backfill can never fail; the app never offers or writes card), cash and
card have no account number, an account
number is 1–40 characters. Unique indexes stop the same method twice and the same part number
twice per parent. "Parts add up to the amount paid" is checked by the repository inside the
transaction (one place: `PaymentPartsWriter`) and by property tests; SQLite cannot check a sum
across rows without a trigger per parent table.

**Alternatives**: An `AFTER INSERT` trigger summing parts (the parent row is written before its
parts, so the trigger would have to be deferred, which SQLite does not support).

## R6. Account number (FR-034, FR-035)

**Decision**: The owner's own wallet number or InstaPay address. Normalised by
`normalizeAccountRef` in `core/utils`: Arabic and Persian digits to Latin (existing `digits.dart`),
trim, empty → null. Allowed: `[0-9A-Za-z@._-]`, 1–40 characters; anything else is a field error.
Suggestions: the distinct account numbers used with the chosen method, most recent first, at most
5, from one DAO query on `payment_parts`.

## R7. Shared payment code lives in a new `payments` feature

**Decision**: `lib/features/payments/`:
- `domain/`: `PaymentMethod` and `offeredPaymentMethods` move here from `customers/domain/payment.dart`
  (re-exported from the old path so existing imports keep working), plus `PaymentPart`,
  `PaymentSplit` and its errors;
- `data/`: `PaymentPartsWriter` (writes and checks parts, used by the five repository impls) and the
  `AccountSuggestionsRepository` impl;
- `presentation/`: `PaymentSplitField` (method chips, amount per part, account field with
  suggestions, "split" toggle) and its cubit.

Sale, purchase, receipt, supplier payment and expense forms replace their method chips with
`PaymentSplitField`. Unsplit, it looks and behaves as today: one method, cash selected, the amount
already filled (FR-038, SC-008).

**Rationale**: One widget and one writer give the same rules everywhere (FR-033). Repository
impls may use another feature's `data/`; only screens and cubits may not (import rules).

## R8. Money collected (FR-013)

**Decision**: One watched SQL query over `payment_parts` joined to its parent, in the period by
the part's `created_at`:
- sale parts where the sale is not voided;
- receipt parts where the ledger row has not been reversed (no `REVERSAL` row points to it);
- minus refunds: `sale_returns.refund_paid_piasters` by `sale_returns.payment_method` (returns keep
  one method and have no parts; no screen writes them yet).

Grouped by method, cash / wallet / InstaPay, plus a total. A reversed receipt or voided sale counts
in no period, matching "a voided sale never counts" (FR-009).

## R9. Profit (FR-003 to FR-012)

**Decision**: One repository call per period, reading:
- net sales: Σ `sales_invoices.total_piasters` (not voided, created in period) − Σ
  `sale_returns.total_refund_piasters` (created in period);
- cost of goods: Σ `sale_items.line_cost_piasters` of those sales − Σ
  `sale_returns.total_cost_piasters` (created in period);
- inventory losses: `ADJUSTMENT` movements created in period, each valued
  `roundHalfUpDiv(-qtyDeltaMilli * unitCostPiasters, 1000)` in Dart through `core/utils/money.dart`
  (adjustments are few, so they are read as rows), summed per reason; gains are negative losses,
  so the line is the net (FR-012);
- expenses: Σ `expenses.amount_piasters`, not voided, `spent_at` in period;
- a count of sale lines with `unit_cost_piasters = 0` in period, for the "some products had no cost"
  note.

Net profit and gross profit are computed in the domain (`ProfitSummary`), never stored.
New index: `ix_stock_movements_type_created ON stock_movements (movement_type, created_at)`.

## R10. Periods (FR-001, FR-002)

**Decision**: A pure-Dart `ReportPeriod` (kind + from/to local dates) turns into
`[startUtc, endUtc)` with the phone's current time zone: start of the first local day to start of
the day after the last. "This week" starts on Saturday. Custom ranges refuse end < start and any
day after today. `Clock` is injected so tests are fixed.

## R11. Live numbers (FR-021)

**Decision**: Every report and dashboard query is a Drift `watch` (`customSelect(...).watch()` with
`readsFrom` listing every table read), so saving a sale or expense updates open screens. "Today"
rolls over when the app returns to the foreground on a new day: the dashboard cubit re-reads the
period on `AppLifecycleState.resumed`.

## R12. Low-stock alert (FR-028, FR-029)

**Decision**: `SalesRepository.create` returns `SaleSaved` with a new `lowStock` list (product id,
name, unit, stock left), read inside the same transaction after the sale's movements, using the
existing `ProductsDao.lowStockSql` rule, for the products on the sale only. The new-sale screen's
saved message names up to two and "and N more", with an action to `RoutePaths.productsLow`.

## R13. Expenses and their categories (FR-022 to FR-027, FR-032)

**Decision**: New `features/expenses` (domain, data, presentation). Numbers from the existing
`EXPENSE` counter (already seeded). Void once with a reason (existing void-only trigger).
Categories: add, rename, archive, restore; uniqueness by `search_key` among active ones (existing
partial unique index). The four defaults are inserted the first time the expense form or category
list opens and the `expense_categories` table has no rows at all, in the shop's language at that
moment, in one transaction. Archived categories count as rows, so the defaults never come back
after the owner archives them.

**Alternatives**: Seeding in the migration (the language may not be chosen yet on a new install).

## R14. Screens and routes

**Decision**: Under the Reports branch:
- `/reports`: the period bar, the profit summary and links;
- `/reports/collected`, `/reports/top`, `/reports/balances`: the US5 views;
- `/reports/expenses`: list with period and category filters;
- `/reports/expenses/new` and `/reports/expenses/:id`;
- `/reports/expense-categories`.

Home is rebuilt as the dashboard (US1), keeping its shortcuts and the low-stock list card, and adds
"record expense". Simple totals only, no charts. The custom range uses the toolkit's built-in date
range picker. No new package.

## R15. Owner approvals

Items 1 and 2 were approved by the owner on 2026-10-26; the constitution is now 1.1.0.

1. **Constitution amendment 1.1.0** (MINOR): in Technical Rules, after the `paymentMethod` rule,
   add: "A payment may be split into up to three parts, one per method, in `payment_parts`, each
   with an optional owner's account number; the header `paymentMethod` holds part 1's method.
   Expenses record their method only through their parts." Also amends decision Q23. Needed before
   phase 2.
2. **Commits (B1 for 006)**: the agent commits once at each phase gate, for this feature only;
   never pushes or merges.
3. **Branch**: work is planned for `006-reports-expenses`; the checkout is on `001-foundation`. The
   owner creates or switches the branch.
