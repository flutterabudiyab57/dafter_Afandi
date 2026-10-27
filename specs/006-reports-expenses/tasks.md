# Tasks: Reports, Home Dashboard and Expenses

**Input**: design documents in `specs/006-reports-expenses/` (spec, plan, research, data-model,
contracts, quickstart) and `.specify/memory/constitution.md` 1.1.0.

**Tests**: required (constitution quality gates; SC-004, SC-005, SC-009).

**Organization**: Setup and Foundational first. The foundation includes schema v2 and the existing
flows writing one payment part, so no payment saved after the upgrade lacks parts. Then one phase
per user story in priority order: US1, US2 and US3 (P1), then US4, US5 and US6 (P2). US3 uses plain
method chips; US6 replaces them with the split field in all five forms.

**Standing rules**:
- **Commits:** commit once at each gate (B1 for 006, approved 2026-10-26). Never push or merge.
- **Packages:** none added, removed or upgraded.
- **Code rules:**
  - material_ui only;
  - every string in both ARB files, in MSA;
  - no `Color(`, `TextStyle(` or `EdgeInsets.only` outside `core/theme`;
  - start/end only; no text-scale clamp;
  - no `double` in any money or quantity path;
  - money only through `core/utils/money.dart`, digits through `core/utils/digits.dart`.
- **Writes:** every multi-table write in one `TransactionRunner` transaction; no hard delete; no
  update of an immutable row.
- **Ambiguity:** stop and ask.

**Screen tests**: every new or changed screen state is tested in ar and en at text scale 1.0 and
2.0 (`pumpApp`, `goTo` from `test/helpers/pump_app.dart`). Every new screen is added to
`test/helpers/screens.dart` (`visitEveryScreen`, `kOnboardedPaths`).

## Phase 1: Setup

- [X] T001 Ask the owner to create or switch to branch `006-reports-expenses` (the checkout is on
  `001-foundation`). Do not create or switch branches yourself. Wait for the answer.
- [X] T002 Run the 14-day lock audit on `pubspec.lock`. Report every `dependency_overrides` entry
  in `pubspec.yaml` past its "remove after" date. Change nothing without the owner's approval.
- [X] T003 [P] Create the empty feature folders with a `.gitkeep` only where a folder would
  otherwise be empty: `lib/features/payments/{domain,data,presentation}`,
  `lib/features/expenses/{domain,data,presentation}`, `lib/features/reports/{domain,data}`
  (`reports/presentation` exists).

## Phase 2: Foundational (blocks every story)

**Goal**: shared domain types, schema v2 with the backfill, and existing flows writing one part per
payment. After this phase the app behaves exactly as before for the user.

### Shared domain

- [X] T004 [P] Move `PaymentMethod` and `offeredPaymentMethods` from
  `lib/features/customers/domain/payment.dart` to `lib/features/payments/domain/payment_method.dart`.
  Re-export them from the old file (`export '../../payments/domain/payment_method.dart';`) so no
  other import changes. Keep the doc comments (research R7).
- [X] T005 [P] `lib/core/utils/account_ref.dart`: `String? normalizeAccountRef(String input)` and
  `AccountRefProblem? checkAccountRef(String normalized)` (research R6):
  - Arabic and Persian digits → Latin through `digits.dart`; trim; empty → null;
  - allowed characters exactly `[0-9A-Za-z@._-]`; length 1–40 characters;
  - problems: `invalidCharacters`, `tooLong`.
  Tests in `test/core/utils/account_ref_test.dart`: Arabic digits, an InstaPay address
  `shop@instapay`, spaces at the ends, 40 and 41 characters, an Arabic letter, empty.
- [X] T006 `lib/features/payments/domain/payment_split.dart` (data-model "Payments domain"):
  - `PaymentPart{method, amountPiasters, accountRef}`, `PaymentPartInput{method, amountText,
    accountText}`, `AccountSuggestion{method, accountRef, lastUsedAt}`;
  - `PaymentSplit` with 1–3 parts: `PaymentSplit.single(method, amount, {accountRef})`,
    `PaymentSplit.create({required int totalPiasters, required List<PaymentPartInput> inputs})` →
    `Result<PaymentSplit, List<PaymentSplitError>>`, collecting every error;
  - getters: `total`, `first`;
  - rules: each part `> 0`; offered methods only; "no method MUST appear twice"; at most 3 parts;
    account only on wallet or InstaPay, through T005; parts add up exactly to the total, else
    `SumMismatch(differencePiasters)`.
  - `sealed class PaymentSplitError` with the part index: PartAmountInvalid, PartAmountZero,
    MethodRepeated, TooManyParts, AccountInvalid, AccountTooLong, AccountNotAllowed, SumMismatch.
  Amounts are parsed through `core/utils/money.dart` (`≤ 2 decimals`, `≤ 1,000,000,000` piasters).
- [X] T007 [P] `test/features/payments/domain/payment_split_test.dart`: single part; 300 + 200 of
  500; over and under by one piaster; a zero part; the same method twice; four parts; an account
  on cash; Arabic digits in an amount and an account; all errors collected at once.
- [X] T008 [P] `lib/features/reports/domain/report_period.dart` (research R10):
  `enum ReportPeriodKind { today, yesterday, thisWeek, thisMonth, lastMonth, custom }`,
  `ReportPeriod{kind, from, to}` (local dates), `ReportPeriod.of(kind, Clock)`,
  `ReportPeriod.custom(from, to, Clock)` → `Result<ReportPeriod, PeriodInvalid>`
  (`EndBeforeStart`, `InFuture`), `({DateTime startUtc, DateTime endUtc}) range()` =
  `[start of first local day, start of the day after the last)`. "The week starts on Saturday."
  Tests in `test/features/reports/domain/report_period_test.dart`: each kind on a Saturday, a
  Friday and the 1st of a month; 23:59 and 00:00; last month across a year end; custom refusals.

### Schema v2

- [X] T009 `lib/core/database/tables/payment_parts_table.dart` exactly as data-model.md
  "New table payment_parts": columns, the five nullable foreign keys with `onDelete:
  KeyAction.restrict`, and the CHECKs ("exactly one parent column is set", `amount_piasters > 0`,
  `part_no BETWEEN 1 AND 3`, `method IN ('cash','wallet','instapay','card')`,
  `account_ref IS NULL OR (method IN ('wallet','instapay') AND length(account_ref) BETWEEN 1 AND
  40)`). `@DataClassName('PaymentPartRow')`. Register it in `lib/core/database/app_database.dart`.
- [X] T010 `lib/core/database/schema_sql.dart`: add `payment_parts` to `kAllTables` and
  `kImmutableTables`; add the 10 partial unique indexes, `ix_payment_parts_created_at`,
  `ix_payment_parts_method_account (method, account_ref, created_at) WHERE account_ref IS NOT
  NULL` and `ix_stock_movements_type_created ON stock_movements (movement_type, created_at)`.
  Update the "Every table in schema v1" comment.
- [X] T011 Bump `kSchemaVersion` to 2 in `lib/core/database/schema_constants.dart`. Run
  `dart run build_runner build` and `dart run drift_dev make-migrations`. Keep
  `drift_schemas/app_database/drift_schema_v2.json` and the generated files under
  `test/drift/app_database/generated/`.
- [X] T012 `lib/core/database/app_database.dart` `onUpgrade`: replace the `StateError` with the
  generated `stepByStep(from1To2: ...)` (research R4), in one transaction:
  1. create `payment_parts`, its indexes and triggers, and the new stock movements index, from the
     same `schema_sql.dart` source;
  2. backfill part 1 with `INSERT … SELECT`, a new UUID v7 per row from `IdGenerator`, the parent's
     `created_at`, `account_ref` NULL: sales with `paid_at_sale_piasters > 0`; purchases with
     `paid_piasters > 0`; `customer_ledger` `PAYMENT_RECEIVED` rows with a receipt number
     (amount = −`amount_piasters`); `supplier_ledger` `PAYMENT_MADE` rows with a payment number
     (amount = −`amount_piasters`); every expense as cash. Voided and reversed parents too.
  Keep `SchemaTooNewException` for `from > to`.
- [X] T013 `test/drift/app_database/migration_test.dart`: the generated v1 → v2 schema test, plus an
  upgrade data test. Fill a v1 database with cash, credit, partial and voided sales (with and
  without a customer), purchases (paid, partial, voided), a receipt, a reversed receipt, supplier
  payments and adjustments. Upgrade, then check:
  - every customer and supplier balance, every stock and every statement total is unchanged;
  - each parent has exactly one part, equal to what it paid, with its old method;
  - no part for credit sales or for the ledger payment rows that a sale or purchase wrote
    (SC-009, FR-041).
- [X] T014 Update `test/core/database/` trigger coverage and constraints tests for the new table:
  update and delete on `payment_parts` are refused; each CHECK refuses a bad row.
- [X] T015 Gate: `flutter analyze` clean and `flutter test` green. Commit
  `feat(006): schema v2 payment parts`.

### Payment parts in existing flows (unsplit)

- [X] T016 `lib/core/database/daos/payment_parts_dao.dart` (register in `AppDatabase`):
  `insertPart`, `partsOfSale`, `partsOfPurchase`, `partsOfLedgerEntry` (customer),
  `partsOfSupplierEntry`, `partsOfExpense`, and `suggestions(method, {limit = 5})`: distinct
  `account_ref` for the method, most recent first.
- [X] T017 `lib/features/payments/data/payment_parts_writer.dart` (contracts "Payments"):
  `sealed class PaymentParent` (Sale, Purchase, Receipt, SupplierPayment, Expense) and
  `write(parent, split, {required int paidPiasters, required DateTime at})`. It throws
  `PaymentPartsMismatch` unless `split.total == paidPiasters`, so the caller's transaction rolls
  back. It writes `part_no` 1..n in order. Also `partsOf(parent)`, mapping rows to `PaymentPart`.
  Register it in `lib/core/di/service_locator.dart`.
- [X] T018 Change `SaleDraft` (`lib/features/sales/domain/`) from `method` to
  `split: PaymentSplit`, over `paid`. When `paid == 0` the split is empty and no parts are asked
  for. `SalesRepositoryImpl.create` writes `payment_method` = `split.first.method` on the header and
  the `PAYMENT_RECEIVED` row, then W7 parts on the invoice through `PaymentPartsWriter`. Update the
  doc comment's write list. `SaleCubit` keeps one method: `methodChanged(m)` builds
  `PaymentSplit.single(m, paid)`.
- [X] T019 Same for the customer receipt: `PaymentRequest.split`;
  `CustomerRepositoryImpl.receivePayment` writes parts on the new ledger row; `PaymentCubit`
  builds a single split.
- [X] T020 Same for purchases: `PurchaseDraft.split` over `paid`; `PurchaseRepositoryImpl.create`
  writes parts on the invoice; `PurchaseCubit` builds a single split.
- [X] T021 Same for supplier payments: `SupplierPaymentRequest.split`;
  `SupplierRepositoryImpl.pay` writes parts on the new ledger row; `SupplierPaymentCubit` builds
  a single split.
- [X] T022 Repository tests for T018–T021 on `NativeDatabase.memory()`: one part per paid save;
  none for credit; a forced mismatch rolls back every write, including the counter; the header and
  ledger method equal part 1's. Property test in `test/features/payments/data/parts_sum_test.dart`:
  random sales, receipts, purchases and supplier payments → Σ parts = paid for every parent.
- [X] T023 Update the fakes (`test/helpers/fake_sales.dart`, `fake_purchases.dart`) and existing
  cubit and screen tests for the `split` change. No behaviour visible to the user changes.
> **As built (T018–T023):** the drafts and `PaymentRequest` keep `method` and gain a derived
> `split` getter (`PaymentSplit.single(method, paid)`), so the split can never disagree with the
> amount paid. Cubits, fakes and screens needed no change. Customer and supplier payments share
> `PaymentRequest`. US6 (T073) replaces the getter with typed parts. `PaymentPartsWriter` is a
> plain `class` so a test can subclass it to force a mismatch.

- [X] T024 Gate: `flutter analyze` clean and `flutter test` green. Commit
  `feat(006): existing payments write parts`.

## Phase 3: User Story 1 - Today at a glance (P1) 🎯 MVP

**Goal**: the home dashboard. **Independent test**: seed sales, receipts and low-stock products;
open Home; check each card and where it leads (spec US1 scenarios 1–6).

- [X] T025 [P] [US1] `lib/features/reports/domain/report_types.dart`: `CollectedSummary`
  (`Map<PaymentMethod, int>` for cash, wallet, InstaPay and `totalPiasters`), `BalanceRow{partyId,
  name, balancePiasters, archived}`, `DashboardSnapshot{todaySalesPiasters, todaySalesCount,
  todayCollected, runningLowCount, topDebtors}`. Equatable.
- [X] T026 [US1] `lib/features/reports/domain/reports_repository.dart`: the
  `ReportsRepository` interface from contracts (all six methods; later stories implement theirs).
- [X] T027 [US1] `lib/core/database/daos/reports_dao.dart` (register in `AppDatabase`), watched
  `customSelect` queries with full `readsFrom` (research R8, R11):
  - `salesTotals(startUtc, endUtc)`: Σ total and count of non-voided sales;
  - `collected(startUtc, endUtc)`: Σ parts by method for non-voided sales and unreversed receipts
    (no `REVERSAL` row points to the receipt row), minus `sale_returns.refund_paid_piasters` by
    `sale_returns.payment_method`, all by `created_at` in `[start, end)`;
  - `runningLowCount()`: active products matching `ProductsDao.lowStockSql`;
  - `customersOwing({limit})`: active and archived customers with balance > 0, largest first.
- [X] T028 [US1] `lib/features/reports/data/reports_repository_impl.dart`: `watchDashboard()` for
  today by the injected `Clock`, combining T027; `watchCollected`; `watchCustomersOwing`. Register
  in DI.
- [X] T029 [US1] `test/features/reports/data/dashboard_test.dart`: spec US1 scenarios 1–3 and 5
  exactly; a split sale counts per method; a reversed receipt and a voided sale count nowhere; a
  sale at 23:58 yesterday is not today; the stream emits again after a sale is saved.
- [X] T030 [US1] `lib/features/home/presentation/cubits/dashboard_cubit.dart`: loading / loaded /
  failed with retry; re-subscribes when the app resumes on a new local day (research R11).
  `ReportsCubits` / `AppReportsCubits` bundle in
  `lib/features/reports/presentation/cubits/reports_cubits.dart`, passed App → `createAppRouter`
  and through `pumpApp` (`reports:` parameter). Fake in `test/helpers/fake_reports.dart`. Bloc
  tests.
- [X] T031 [US1] ARB keys in `app_ar.arb` and `app_en.arb` for the dashboard: card titles (today's
  sales, collected today, running low, who owes most), "N sales", "see all", the empty texts, and
  the "record expense" shortcut. MSA.
- [X] T032 [US1] Rebuild `lib/features/home/presentation/home_screen.dart` as the dashboard:
  - cards: today's sales + count → `RoutePaths.sales`; collected → `/reports/collected`;
  - running low → `RoutePaths.productsLow`;
  - top 3 who owe, each → `customerDetails`, "see all" → `/reports/balances`.
  Keep the existing shortcuts and `LowStockCard`; add "record expense" → `/reports/expenses/new`
  (a placeholder route until US3). Use `SingleChildScrollView(Column)`, the 005 loading and
  failed states, and tokens only.
- [X] T033 [US1] `test/features/home/presentation/home_screen_test.dart`: every card's number and
  destination, the empty shop, a failed load with retry, live update after a save; ar/en ×
  1.0/2.0.
> **As built (T025–T033):**
> - **Running low:** the count is the existing low-stock warning banner and card (005), not a
>   new query or card; `DashboardSnapshot` has no `runningLowCount`.
> - **Repository:** `ReportsRepository` has only the dashboard, collected and customers-owing
>   streams so far; US2 and US5 add theirs. Each stream reloads on any change to the tables
>   reports read (`ReportsDao.watchChanges`).
> - **Links until their routes exist:** the collected card does not open anything until US5
>   adds `/reports/collected`, and the debtors card's "See all" opens Parties until US5 adds
>   `/reports/balances`. The "record expense" shortcut comes with US3 (T053), so no placeholder
>   route was added.
> - **Test fake:** `FakeReportsStore` holds a settable snapshot.

- [X] T034 [US1] Gate: analyze clean, all tests green. Commit `feat(006): home dashboard`.

## Phase 4: User Story 2 - Real profit for a period (P1)

**Goal**: Reports shows the profit summary for a period. **Independent test**: seeded sales,
costs, a voided sale, adjustments and expenses across two months; every line checked (spec US2).

- [X] T035 [P] [US2] `lib/features/reports/domain/profit_summary.dart`: `ProfitSummary` exactly as
  data-model.md, including `inventoryLossesByReason` ("each the net (gains negative)"),
  `netProfitPiasters` = gross − inventoryLosses − expenses, `isLoss`, `isEmpty`,
  `linesWithoutCost`. Unit tests for the sums and signs.
- [X] T036 [US2] `reports_dao.dart`: `profitRows(startUtc, endUtc)`, watched:
  - non-voided sales: Σ total, Σ `sale_items.line_cost_piasters`, count, count of lines with
    `unit_cost_piasters = 0`;
  - sale returns: Σ `total_refund_piasters`, Σ `total_cost_piasters`;
  - `ADJUSTMENT` movements as rows (`qty_delta_milli`, `unit_cost_piasters`, `adjustment_reason`);
  - Σ non-voided `expenses.amount_piasters` with `spent_at` in period.
- [X] T037 [US2] `ReportsRepositoryImpl.watchProfit(period)`: value each adjustment with
  `roundHalfUpDiv(-qtyDeltaMilli * unitCostPiasters, 1000)` from `core/utils/money.dart`, sum per
  reason, and build `ProfitSummary` (research R9).
- [X] T038 [US2] `test/features/reports/data/profit_test.dart`: spec US2 scenarios 1–6 exactly; a
  count adjustment that adds stock lowers losses, and a net gain raises profit (FR-012); a sale
  below cost; a zero-cost line is counted. Property test: random records → every line equals a
  hand sum to the piaster (SC-004).
- [X] T039 [US2] `test/features/reports/data/performance_test.dart`: 20,000 sales and 2,000
  expenses across a year; profit, collected and top sellers each emit within 2 s (SC-005). Tag it
  so it can be skipped in quick runs, as earlier performance tests are.
- [X] T040 [US2] `ReportPeriodCubit` (the chosen period, shared) and `ProfitCubit` in
  `lib/features/reports/presentation/cubits/`; add them to the bundle and fake. Bloc tests.
- [X] T041 [US2] ARB keys: period names, "custom range", the refusal texts, every profit line,
  "loss", "net gain", "nothing in this period", "some products had no cost when sold", the
  inventory reasons (reuse the existing damage, count and other keys if present).
- [X] T042 [US2] `lib/features/reports/presentation/widgets/period_bar.dart`: chips for the five
  fixed periods and "custom" (built-in date range picker, refusing per T008), showing the chosen
  dates.
- [X] T043 [US2] Replace `lib/features/reports/presentation/reports_screen.dart`: the period bar,
  then the profit summary (net sales, cost of goods, gross profit, inventory losses with its reason
  breakdown, expenses, net profit marked as a loss when negative), then links to collected, top
  sellers, balances and expenses (routes added in their stories; until then the links are hidden).
- [X] T044 [US2] `test/features/reports/presentation/reports_screen_test.dart`: lines and signs,
  empty period, loss marking, custom-range refusal, period change; ar/en × 1.0/2.0.
> **As built (T035–T044):**
> - **Reason labels:** `ProfitSummary` uses the products domain's `AdjustmentKind` and reuses
>   the existing reason labels.
> - **Expenses in tests:** they are inserted as rows until US3 adds the repository.
> - **Speed:** the performance test runs a year of data in about 65 ms for profit and 25 ms for
>   money collected. It is not tagged, like the earlier performance tests.
> - **Leftover placeholder:** the Reports placeholder strings and illustration are no longer
>   shown. They stay until the polish phase decides whether to remove them.

- [X] T045 [US2] Gate: analyze clean, all tests green. Commit `feat(006): profit report`.

## Phase 5: User Story 3 - Shop expenses (P1)

**Goal**: record, list, filter and void expenses; manage categories. **Independent test**: spec US3
scenarios 1–7, and the profit report changes by the expense.

- [X] T046 [P] [US3] `lib/features/expenses/domain/`: `ExpenseCategory`, `ExpenseDraft.create`,
  `Expense`, `ExpenseQuery`, the errors and the two repository interfaces, exactly as data-model.md
  "Expenses domain" and contracts:
  - name "trimmed, 1–50 code points";
  - amount "0 < amount ≤ 1,000,000,000 piasters, ≤ 2 decimals";
  - "spentOn: ≤ today (local)";
  - note "≤ 200 code points, empty → null".
  Unit tests at every limit.
- [X] T047 [US3] `lib/core/database/daos/expenses_dao.dart` and `expense_categories_dao.dart`
  (register both): list by period and category, newest first; the non-voided total; one with its
  category; insert; void fields only; categories active and archived; `activeNameExists`;
  `countAll`.
- [X] T048 [US3] `lib/features/expenses/data/expense_repository_impl.dart`: `create` in one
  transaction: W1 `EXPENSE` number, W2 `expenses` row (`spent_at` = local day start in UTC), W3
  parts through `PaymentPartsWriter`. `voidExpense` once with `validateReason`. Register in DI.
- [X] T049 [US3] `lib/features/expenses/data/expense_category_repository_impl.dart`: create,
  rename, archive, restore with the `search_key` rule (`NameTaken`); `ensureDefaults(names)`
  inserts the four names in one transaction only when `countAll() == 0` (research R13).
- [X] T050 [US3] Repository tests: numbers E-1, E-2 in order and gap-free on rollback; void once;
  voided excluded from the total and from `watchProfit`; a future date refused; defaults inserted
  once and never again after all are archived; a duplicate name refused ignoring case, Arabic
  letter forms and extra spaces; an archived category keeps its name on old expenses.
- [X] T051 [US3] Cubits `ExpensesListCubit`, `ExpenseFormCubit`, `ExpenseCubit`,
  `ExpenseCategoriesCubit` and the `ExpensesCubits` / `AppExpensesCubits` bundle (App →
  `createAppRouter`, `pumpApp` `expenses:`), fake in `test/helpers/fake_expenses.dart`. The form
  uses `PaymentSplit.single`, cash by default. Bloc tests.
- [X] T052 [US3] ARB keys: expenses title, "E-{number}", form labels, the four default category
  names, filters, total, void dialog, voided mark, category screen texts and errors.
- [X] T053 [US3] Routes in `lib/core/router/route_names.dart` and the router: `/reports/expenses`,
  `/reports/expenses/new`, `/reports/expenses/:id`, `/reports/expense-categories`. Replace the
  placeholder from T032.
- [X] T054 [US3] Screens in `lib/features/expenses/presentation/screens/`:
  - expenses list: period bar, category filter, newest first, total of non-voided, voided marked,
    005 empty state;
  - expense form: category, amount, method chips (cash, wallet, InstaPay), date (today, no future),
    note, unsaved-changes guard;
  - expense details: number, category, amount, method, date, note; void with a required reason,
    hidden once voided;
  - categories: add, rename, archive, restore, archived section.
  Show the Reports link to expenses (T043).
- [X] T055 [US3] Widget tests for the four screens: spec US3 scenarios 1–7; ar/en × 1.0/2.0. Add
  the screens to `test/helpers/screens.dart`.
> **As built (T046–T055):**
> - **Shared period:** `ReportPeriodCubit` is provided once by the shell, so Reports and the
>   expenses list share it, and the chosen period stays while the owner visits other sections.
> - **Numbers:** shown as `E-000001`, like every other document number (decision Q22).
> - **Defaults:** the expense form and the categories screen each call `ensureDefaults` with the
>   four names in the current language when they open; the repository inserts them only into an
>   empty table.
> - **Form:** the method chips only (cash, wallet, InstaPay). The account number field and split
>   payments come with US6 (T072, T073); the draft already takes `PaymentPartInput`s.
> - **Layout at 200%:** the list row shows the amount in its subtitle instead of as the trailing,
>   and the category buttons sit under each name, so nothing overflows at large text.
> - **Home shortcut:** "Record expense" opens the form in the Reports section, so Back returns to
>   the expenses list.
> - **Empty list:** uses the old Reports placeholder illustration (`emptyReports`).
> - **Test fake:** `FakeExpensesStore` (expenses) with `FakeExpenseCategories` (categories) on the
>   same data, as the two interfaces both have a `create`.

- [X] T056 [US3] Gate: analyze clean, all tests green. Commit `feat(006): expenses`.

## Phase 6: User Story 4 - Low-stock message after a sale (P2)

**Goal**: the saved message names products that ran low. **Independent test**: spec US4
scenarios 1–4.

- [X] T057 [US4] `lib/features/sales/domain/`: `LowStockItem{productId, name, unit, stockMilli,
  thresholdMilli}` and `SaleSaved.lowStock`. `SalesRepositoryImpl.create` reads, after W4, the
  sale's products that match `ProductsDao.lowStockSql`, in line order (research R12).
- [X] T058 [US4] Repository tests: crossing the level; already low; three products; a product
  with no level that stays ≥ 0 is not listed; below zero is listed.
- [X] T059 [US4] ARB keys: "{name} is running low ({qty} left)", "{first} and {second} are running
  low", "and {count} more", "Show". `SaleCubit` exposes the list; `new_sale_screen.dart` shows it
  in the saved snack bar (up to two names, "and N more", action → `RoutePaths.productsLow`).
  Quantities through `core/utils/quantity.dart`.
- [X] T060 [US4] Widget tests for the message and its action; ar/en × 1.0/2.0.
- [X] T061 [US4] Gate: analyze clean, all tests green. Commit `feat(006): low-stock message`.

## Phase 7: User Story 5 - Collected, top sellers and balances (P2)

**Goal**: three report views. **Independent test**: spec US5 scenarios 1–5.

- [ ] T062 [P] [US5] `lib/features/reports/domain/report_types.dart`: `TopSeller{productId, name,
  unit, qtyMilli, netSalesPiasters}` and `enum TopSellerOrder { value, quantity }`.
- [ ] T063 [US5] `reports_dao.dart`: `topSellers(startUtc, endUtc, order, limit 10)` (sold minus
  returned, non-voided sales, latest name snapshot) and `suppliersOwed()`;
  `ReportsRepositoryImpl.watchTopSellers` and `watchSuppliersOwed`.
- [ ] T064 [US5] Repository tests: order by value and by quantity, returns subtracted, voided
  excluded, archived products still listed; suppliers owed largest first with the total.
- [ ] T065 [US5] `CollectedCubit`, `TopSellersCubit`, `BalancesCubit`; bundle and fake. Bloc tests.
- [ ] T066 [US5] ARB keys for the three views. Routes `/reports/collected`, `/reports/top`,
  `/reports/balances`. Screens in `lib/features/reports/presentation/screens/`:
  - collected: one row per method and the total, with the period bar;
  - top sellers: value / quantity switch, quantities in each product's unit;
  - balances: two tabs, customers owing and suppliers owed, each with its total; rows open the
    party.
  Show their links on the Reports screen.
- [ ] T067 [US5] Widget tests for the three screens; ar/en × 1.0/2.0. Add them to
  `test/helpers/screens.dart`.
- [ ] T068 [US5] Gate: analyze clean, all tests green. Commit `feat(006): collected, top sellers
  and balances`.

## Phase 8: User Story 6 - Account number and split payment (P2)

**Goal**: split payments and the owner's account number in all five forms, shown everywhere a
payment is shown. **Independent test**: spec US6 scenarios 1–8.

- [ ] T069 [US6] `lib/features/payments/domain/account_suggestions_repository.dart` and
  `lib/features/payments/data/account_suggestions_repository_impl.dart` (T016 `suggestions`).
  Register in DI. Repository test: most recent first, at most 5, per method, no cash.
- [ ] T070 [US6] `lib/features/payments/presentation/cubits/payment_split_cubit.dart`: parts,
  errors, suggestions per method; `split()`, `removePart(i)` (its amount goes back to part 1),
  `methodChanged`, `amountChanged`, `accountChanged`, `totalChanged`. Bloc tests, including
  "remaining" and "over by".
- [ ] T071 [US6] ARB keys: "Split payment", "Part {n}", "Your account number (optional)",
  "Remaining {amount}", "Over by {amount}", every `PaymentSplitError` message.
- [ ] T072 [US6] `lib/features/payments/presentation/widgets/payment_split_field.dart` (contracts
  "PaymentSplitField"): unsplit looks as today (chips, cash selected, no extra field for cash);
  wallet or InstaPay shows the optional account field with suggestion chips; "Split payment" adds
  up to three parts; errors per part and the sum error below. No more taps than today when not
  split (SC-008).
- [ ] T073 [US6] Use `PaymentSplitField` in new sale (over "paid now"), customer payment, new
  purchase (over "paid now"), supplier payment and the expense form. The cubits from T018–T021 and
  T051 take a full `PaymentSplit`.
- [ ] T074 [US6] Show the parts: `SaleInvoice.parts` and `Purchase.parts` from
  `PaymentPartsWriter.partsOf`; `LedgerEntry.parts` and `SupplierEntry.parts` (the invoice's for
  sale and purchase payments, their own for receipts and payments). Invoice, purchase, expense
  details and both statements list each part with its method and account number.
- [ ] T075 [US6] Tests: repository tests for a 3-part sale, receipt, purchase, supplier payment and
  expense; widget tests for spec US6 scenarios 1–8 in each form; ar/en × 1.0/2.0. Money collected
  shows a split sale per method (spec US5 scenario 5).
- [ ] T076 [US6] Gate: analyze clean, all tests green. Commit `feat(006): split payments and
  account numbers`.

## Phase 9: Polish

- [ ] T077 Run every-screen semantics and layout-stress walks (`test/app/`) with all new screens;
  fix any clipping at 200% and any missing spoken label.
- [ ] T078 [P] ARB review: every new key in both files, MSA in Arabic, no "tax" wording on any
  document; `test/l10n/arb_test.dart` green.
- [ ] T079 [P] Screenshot tests: add Home, Reports, expenses list and form, and a split sale to
  `test/screenshots/screenshots_test.dart`; run with `--dart-define=SCREENSHOTS=true` and review.
- [ ] T080 `flutter build apk --debug`. Run [quickstart.md](quickstart.md) on a phone over a 005
  install, or list its steps for the owner if no device is available. Do not unlock a device or
  enter a PIN.
- [ ] T081 Lock audit again; update `CLAUDE.md` only where 006 changed a fact it states (schema
  version, the payments feature).
- [ ] T082 Gate: analyze clean, all tests green. Commit `chore(006): polish`.

## Dependencies

- Phase 1 → Phase 2 → every story.
- US1, US2 and US3 depend only on Phase 2. US2's expenses line reads the expenses table, so its
  tests seed rows directly; US3 then adds the screens.
- US4 depends only on Phase 2.
- US5 depends on US1 (reports DAO and repository, collected query) and US2 (period bar).
- US6 depends on US3 (the expense form) and Phase 2.
- Polish depends on every story.

## Parallel opportunities

- Phase 2: T004, T005 and T008 in parallel; T007 alongside T006 once T006's types exist.
- US1: T025 with T027; US2: T035 with T036; US3: T046 with T047; US5: T062 with T063.
- After Phase 2, US1, US2, US3 and US4 touch different files and can be built in any order.

## Implementation strategy

- **MVP**: Phases 1–3 (foundation and the dashboard). Then US2 and US3 to make profit honest.
- One phase per `/speckit-implement` run, then stop for review at its gate.
- Phases 2 and 8 change how money is stored and entered; their gates include the upgrade test and
  the parts property test.
