# Research: Products and Stock

Phase 0 for [plan.md](plan.md). Each entry has the decision, why, and what else was considered.
The binding inputs are the constitution, report §3 as amended by M0-DECISIONS, and the code that
001-foundation shipped (schema v1, `core/utils`, the settings feature as the pattern).

## R1. Schema: no change, stay on v1

**Decision**: use schema v1 as it is. `schemaVersion` stays 1 and make-migrations does not run.

**Rationale**: every field the spec needs already exists:
- `products`: name, searchKey, barcode, sku, unitType, salePricePiasters, avgCostPiasters,
  lowStockThresholdMilli, categoryId, archivedAt;
- `categories`: name, searchKey, sortOrder, archivedAt;
- `stock_movements`: OPENING and ADJUSTMENT with `adjustmentReason` (damage, count, other) and
  `note`.

The indexes already present are enough: barcode unique among active products, category searchKey
unique among active categories, `(productId, qtyDeltaMilli)` covering the stock sum, and
`(productId, createdAt)` for the history. Triggers already forbid deletes on every table and any
update on `stock_movements`.

Length limits (name 1–100, barcode and code ≤ 64, note ≤ 200, category ≤ 40) live in the domain,
as in 001 for most fields. No DB CHECK is added, since that would need v2 for little gain.

**Alternatives**: v2 with an `OPENING_CORRECTION` reason (rejected by clarification Q1); a
`product_stock` cache (report §3 keeps it for later, if profiling shows a need).

## R2. Packages: none new

**Decision**: no package is added, removed or upgraded. The 14-day audit of `pubspec.lock` runs
again before the first commit of this feature (Q3), and "remove after" overrides that have expired
by then are reported to the owner.

**Rationale**:
- Camera scanning would need a scanner package; it is out of scope (spec Assumptions).
- Everything else uses the 001 stack: material_ui, flutter_bloc, go_router, drift, get_it,
  equatable.

## R3. Stock on hand in queries

**Decision**: compute stock with a correlated subquery,
`COALESCE((SELECT SUM(qty_delta_milli) FROM stock_movements m WHERE m.product_id = p.id), 0)`.
List, details and the Home card use Drift `customSelect(...).watch()` with
`readsFrom: {products, stockMovements, categories}`, so every screen updates after a write.

**Rationale**:
- Constitution III: stock is never stored.
- The covering index answers each sum without touching the table rows.
- A watch query keeps the list, details and Home card in step with no manual refresh.

**Check**: a repository test seeds 2,000 products and 100,000 movements in memory, and asserts
that one list query plus one search query finish in under 300 ms on the dev machine. That leaves
room inside SC-002's one second on a low-end phone. The phone itself is checked in quickstart.

**Alternatives**: a `GROUP BY` join (same cost, harder to combine with filters); a trigger-kept
cache table (needs v2).

## R4. Search

**Decision**:
- The query is `q = arabicNormalize(input)`. An empty `q` means no search.
- A product matches when any of these holds:
  - `instr(search_key, q) > 0`;
  - `instr(lower(sku), q) > 0`;
  - `instr(barcode, q) > 0`.
- Results are ordered `barcode = q DESC`, then the list order (R5).
- The search cubit waits 200 ms after the last keystroke before it queries.

**Rationale**:
- `instr` needs no escaping of `%` and `_`, unlike `LIKE`.
- The normalized query folds the same variants as the stored `searchKey` (FR-009).
- `barcode` and `sku` are stored normalized (R9), so Arabic digits typed in the box match.
- With 2,000 rows a scan is cheap (R3 measures it).

**Alternatives**: FTS5 (needs a v2 virtual table, and its tokenizer does not know the Arabic
folding); prefix-only search (fails "ارز" inside "أرز مصري").

## R5. List order (clarification Q3)

**Decision**: `ORDER BY (unicode(search_key) < 1536) ASC, search_key ASC, name ASC, id ASC`.
1536 is U+0600, the start of the Arabic block.

**Rationale**:
- SQLite's default BINARY collation compares UTF-8 bytes, which is code-point order.
- After `arabicNormalize`, code-point order of the Arabic letters is the standard alphabetical
  order (ا ب ت ث … ن ه و ي), and folded variants sort together because they are the same letter.
- The first term puts names that start with Latin letters or digits after Arabic names, as asked.
- Known limit: names starting with ء, ؤ or ئ (U+0621–U+0626) sort before ا. This is acceptable
  and is documented in a test.

**Alternatives**: ICU collation (not in the bundled sqlite3, and it would need a package); sorting
in Dart (it breaks paging and watch queries).

## R6. Low stock

**Decision**: a product is low when
`(low_stock_threshold_milli IS NOT NULL AND stock <= low_stock_threshold_milli) OR stock < 0`
(FR-008). The list filter and the Home card share one SQL fragment, defined in the DAO.
- The Home card orders by `stock ASC`, then the list order, takes 5, and counts the total in the
  same query (`COUNT(*) OVER ()`).
- Below zero is flagged separately (`stock < 0`), so a row can show both marks.

**Rationale**: one definition gives one count everywhere (spec scenario US2-8).

## R7. Average cost and transactions

**Decision**:
- **Opening stock**, at create time or later while the product has no movements. In one
  `TransactionRunner.run`:
  1. W1: insert the product (or confirm it has no movements);
  2. W2: insert the OPENING movement (`+qty`, `unitCostPiasters = cost`);
  3. W3: update `products.avgCostPiasters` via
     `weightedAverageCost(stockMilli: 0, avgCostPiasters: 0, inQtyMilli: qty, inTotalCostPiasters: lineTotalPiasters(qty, cost))`.
- **Adjustment**. In one transaction:
  1. R1: read stock;
  2. validate: a decrease must not exceed stock; a count is converted to `delta = counted − stock`,
     and a zero delta writes nothing;
  3. W1: insert the ADJUSTMENT movement with `unitCostPiasters = current avgCostPiasters`.

  `avgCostPiasters` is not changed (FR-007).
- **Replay**: `InventoryRepository.rebuildAverageCost(productId)` walks the movements ordered by
  `createdAt, rowid`:
  - stock is the sum of all deltas;
  - cost-bearing inbound types (OPENING, PURCHASE, SALE_RETURN, SALE_VOID) apply WAC;
  - ADJUSTMENT and outbound types change stock only.

  It exists for tests and maintenance. A property test checks that replay equals the stored value
  after random sequences of opening and adjustments. The purchase and sale features extend the
  same test.

**Rationale**:
- Constitution III: one transaction per financial operation, and WAC changes only on inbound,
  cost-bearing paths.
- Reading stock inside the transaction stops two quick saves from both passing the "not more than
  on hand" check.

## R8. Domain validation and errors

**Decision**: pure-Dart value types validate input and return `Result<T, E>` from `core/utils`
(contracts/repositories-and-domain.md). Each error is a sealed class that the UI maps to an ARB
message, as `ShopProfileError` does in 001.

| Field | Rule |
|---|---|
| name | trimmed, 1–100 code points |
| unit | required |
| sale price | 0 ≤ p ≤ 1,000,000,000 piasters, at most 2 decimals |
| quantity | 0 ≤ q ≤ 1,000,000,000 milli; piece: multiple of 1000 |
| low-stock level | as quantity, optional |
| barcode, code | trimmed, ≤ 64 code points, digits folded to Latin; empty means none |
| opening cost | required when the opening quantity is above zero; same range as price |
| adjustment note | trimmed, 1–200 code points; required for `other` |
| category name | trimmed, 1–40 code points; unique among active categories by searchKey |

## R9. Barcode and code normalization

**Decision**: on write, `barcode` and `sku` are trimmed and their digits mapped to Latin
(`normalizeDigits`). An empty string is stored as NULL. Inner spaces are kept, since some shops
type codes like "A 12".
- Uniqueness of barcodes among active products is checked inside the save or restore transaction
  so the error can name the other product.
- The partial unique index is the backstop: a `SqliteException` with a UNIQUE constraint failure
  is mapped to the same error.

## R10. Navigation (clarification on FR-001)

**Decision**: product routes sit under the Home branch of the existing `StatefulShellRoute`, so
the bottom bar stays visible and Back returns to Home:

| Path | Screen |
|---|---|
| `/home/products` | product list; `?filter=low` opens with the low-stock filter |
| `/home/products/new` | add product |
| `/home/products/archived` | archived products |
| `/home/products/:id` | product details and its stock history |
| `/home/products/:id/edit` | edit product |
| `/home/products/:id/opening` | set opening stock (only while it has no history) |
| `/home/products/:id/adjust` | stock adjustment |
| `/home/categories` | categories |

Home itself replaces its placeholder with a Products button, a Categories entry, and the
low-stock card.

**Alternatives**: top-level routes above the shell (they lose the bottom bar and the Home stack).

## R11. Building cubits: one factory bundle

**Decision**: add `ProductsCubits`, one abstract class whose methods create each product cubit.
`AppProductsCubits` builds them from get_it. It is passed to `App` and `createAppRouter` as one
argument, next to `shopProfileForm`. Tests pass a fake bundle.

**Rationale**: 001 passes each factory explicitly so widget tests can inject fakes. Doing that
for seven new cubits would bloat both signatures. One bundle per feature keeps the pattern and
the testability.

**Alternatives**: calling `sl<…>()` inside route builders (hides the dependency and breaks
`pumpApp` fakes); seven separate typedef parameters.

## R12. Number input

**Decision**:
- Price, cost and quantity fields use `TextInputType.numberWithOptions(decimal: true)`.
- A formatter caps fraction digits by unit (0 for piece, 3 otherwise, 2 for money), so "a fourth
  decimal cannot be entered" (US1-5).
- Parsing goes through the existing `tryParsePiasters` and `tryParseQuantityMilli`, which accept
  Arabic and Latin digits.
- Displayed numbers follow `context.digits` (DigitStyleScope).

## R13. Opening-stock confirmation (clarification Q1)

**Decision**: when the opening quantity is above zero, saving opens a dialog with the quantity
and unit, the cost per unit, and the total `lineTotalPiasters(qty, cost)` (round half up).
Confirm saves; Back or Cancel returns to the form unchanged. A zero quantity skips the dialog.

## R14. Duplicate product name

**Decision**: after a successful save, if another active product has the same `searchKey`, a
SnackBar says a product with this name already exists. The save is never blocked (spec Edge
Cases).

## R15. Stock history

**Decision**: shown on the product details screen, ordered `createdAt DESC, rowid DESC`, in pages
of 50 with a "show more" button.
- Each row shows the date and time in local time, the type label (ARB), the signed quantity with
  its unit, the reason and the note.
- Types that later features will write (sale, purchase, return, void) already have labels, so
  nothing changes when they arrive.

## R16. Category order

**Decision**: each category row has Move up and Move down buttons with spoken labels, instead of
drag only. A move rewrites `sortOrder` as 0..n-1 for all active categories in one transaction.

**Rationale**: buttons work with screen readers and at 200% text; drag alone does not.

## R17. Archived categories

**Decision**: archiving a category does not touch its products' `categoryId`. Queries treat a
product whose category is archived as having no category, for the "no category" filter, the
details screen and the form. Saving the form writes the category the owner picked, which is "no
category" unless they choose another.

**Rationale**: no extra writes, and history is kept.

## R18. Unit labels

**Decision**: short, fixed unit labels from ARB, with no plural forms:
- Arabic: قطعة, كجم, لتر, م;
- English: pc, kg, L, m.

They are shown after the formatted number, e.g. "١٢ قطعة" or "2.375 kg".

**Rationale**: Arabic plurals for units on every row add noise, and short shop labels are common.
