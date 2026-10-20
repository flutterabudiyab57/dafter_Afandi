---

description: "Task list for 002-products-stock"
---

# Tasks: Products and Stock

**Input**: Design documents from `specs/002-products-stock/`. These are plan.md, spec.md,
research.md, data-model.md, contracts/ and quickstart.md.

**Prerequisites**:
- 001-foundation is complete.
- Decisions B1–B3 are approved (plan.md, 2026-10-20).

**Tests**: Included. The constitution requires them: every financial flow has unit tests, Cubits
use bloc_test + mocktail, repositories run on in-memory Drift, and import_rules_test must pass.

**Organization**: The tasks follow the **8 implementation phases in plan.md**. Each phase is ONE
`/speckit-implement` run. It ends with `flutter analyze` clean and the full `flutter test` green,
then a commit (B1), then it STOPS for review.
- Phases 1–3 are foundational, with no story label.
- Phase 4 delivers US2, Phase 5 delivers US1 and US3, Phase 6 delivers US4, and Phase 7 delivers
  US5.
- Phase 8 is polish and the device check.

**Standing rules for every task**:
- Commit once at the end of each phase, after its gate passes (B1). Never push or merge.
- No package changes.
- No schema change: `schemaVersion` stays 1, and `drift_schemas/` must not change.
- Import `package:material_ui/material_ui.dart`, never `flutter/material.dart` or `cupertino.dart`.
- No `double` in money or quantity paths.
- No user-visible literal strings; every string is in both ARB files.
- No `Color(`, `TextStyle(` or `EdgeInsets.only/fromLTRB` outside `lib/core/theme`. Use
  `EdgeInsetsDirectional` and start/end.
- No `delete(`/`DELETE`, and no update of `stock_movements`.
- If anything is ambiguous, stop and ask.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US5 from spec.md (used only in Phases 4–7)

---

## Phase 1: Pre-flight and domain (Foundational)

**Purpose**: pure-Dart product, category and stock types with all validation, plus the repository
interfaces.

- [X] T001 Re-run the 14-day audit of `pubspec.lock` (cutoff = today − 14 days) with the
  scratchpad audit script. Report each override whose "remove after" date has passed. Change
  nothing (removal needs owner approval).
- [X] T002 [P] Create `lib/features/products/domain/product.dart` with three types:
  - `Product`: fields per data-model.md (id, name, unit `UnitType`, salePricePiasters,
    avgCostPiasters, categoryId?, categoryName?, barcode?, sku?, lowStockThresholdMilli?,
    archived);
  - `ProductSummary`: Product plus stockMilli, isLow, isBelowZero, hasHistory;
  - `LowStockSnapshot`: items and totalCount.

  All use Equatable.
- [X] T003 [P] Create `lib/features/products/domain/product_errors.dart` with these sealed classes:
  - `ProductFieldError`: nameRequired, nameTooLong(max), priceRequired, priceInvalid,
    priceTooLarge(max), quantityInvalid, quantityNotWhole, quantityTooLarge(max),
    openingCostRequired, barcodeTooLong(max), skuTooLong(max);
  - `ProductSaveError`: barcodeTaken(otherProductName), unitLocked, openingNotAllowed, notFound;
  - `RestoreError`: barcodeTaken(otherProductName);
  - `CategoryError`: nameRequired, nameTooLong(max), duplicate;
  - `AdjustmentError`: quantityRequired, quantityInvalid, quantityNotWhole, quantityTooLarge,
    noteRequired, noteTooLong(max), exceedsStock(onHandMilli), alreadyMatches.
- [X] T004 Create `lib/features/products/domain/product_draft.dart`.
  - `OpeningStock` has `qtyMilli > 0`, `unitCostPiasters`, and `totalPiasters` =
    `lineTotalPiasters(qtyMilli, unitCostPiasters)`.
  - `ProductDraft.create({name, unit, priceText, categoryId, barcode, sku, lowStockText,
    openingQtyText, openingCostText})` returns `Result<ProductDraft, List<ProductFieldError>>`
    and collects every error. The rules:
    - "name trimmed, 1–100 code points";
    - "0 ≤ price ≤ 1,000,000,000 piasters, at most 2 decimals" (via `tryParsePiasters`);
    - "0 ≤ q ≤ 1,000,000,000 milli; piece: multiple of 1000" (via `tryParseQuantityMilli`), for the
      low-stock level and the opening quantity;
    - "barcode, code trimmed, ≤ 64 code points, digits folded to Latin; empty means none";
    - "opening cost required when the opening quantity is above zero; same range as price";
    - an opening quantity of 0 or empty gives `opening == null`.
- [X] T005 [P] Create `lib/features/products/domain/category.dart`:
  - `Category` (id, name, sortOrder, productCount);
  - `validateCategoryName(String)` with the rule "trimmed, 1–40 code points";
  - `MoveDirection { up, down }`.
- [X] T006 [P] Create `lib/features/products/domain/stock_entry.dart`:
  - `StockEntryType` (opening, purchase, purchaseVoid, sale, saleReturn, saleVoid, adjustment);
  - `AdjustmentKind` (damage, count, other);
  - `StockEntry` (id, type, qtyDeltaMilli, unitCostPiasters, reason?, note?, at);
  - `StockEntryCursor` (at, rowOrder).
- [X] T007 [P] Create `lib/features/products/domain/adjustment.dart`:
  - `AdjustmentRequest.damage(qtyText, unit, note?)`, `.count(countedText, unit, note?)` and
    `.other(qtyText, unit, add: bool, note)`, each returning
    `Result<AdjustmentRequest, List<AdjustmentError>>`;
  - the rules: "qtyMilli > 0" for damage and other, "countedMilli ≥ 0" for count, piece quantities
    whole, ≤ 1,000,000,000 milli, and the note "trimmed, 1–200 code points; required for other";
  - `AdjustmentResult` (deltaMilli, newStockMilli).
- [X] T008 [P] Create `lib/features/products/domain/product_query.dart` with `ProductQuery`
  (text, categoryFilter `CategoryFilter.all | none | category(id)`, lowOnly) and a `normalizedText`
  getter that returns `arabicNormalize(text)`.
- [X] T009 Create the three repository interfaces exactly as in
  contracts/repositories-and-domain.md:
  - `lib/features/products/domain/product_repository.dart` (with `ProductSaved`);
  - `lib/features/products/domain/inventory_repository.dart`;
  - `lib/features/products/domain/category_repository.dart`.
- [X] T010 [P] Test `ProductDraft.create` at every limit in
  `test/features/products/domain/product_draft_test.dart`:
  - empty, 1, 100 and 101 code-point names, including emoji and Arabic;
  - price 0, 10,000,000.00 and 10,000,000.01, 3 decimals, Arabic digits, grouping;
  - piece 1.5 rejected, kg 2.375 accepted, a 4th decimal rejected;
  - opening quantity without a cost;
  - barcode 64 and 65, and spaces trimmed;
  - all errors collected at once.
- [X] T011 [P] Test the adjustment requests and category names in
  `test/features/products/domain/adjustment_test.dart` and
  `test/features/products/domain/category_test.dart`: every rule in T005 and T007 at its limits.
- [X] T012 Gate: `flutter analyze` clean, `flutter test` green, and import_rules_test passes (domain
  has no Flutter or Drift import). Commit `feat(002): phase 1 domain`.

---

## Phase 2: DAOs and repositories (Foundational)

**Purpose**: every stored rule from contracts/repositories-and-domain.md, on schema v1.

- [X] T013 Create `lib/core/database/daos/products_dao.dart`.
  - One shared SQL base: products, the stock subquery
    `COALESCE((SELECT SUM(qty_delta_milli) FROM stock_movements m WHERE m.product_id = p.id), 0)`,
    a LEFT JOIN of active categories (an archived category reads as NULL, R17), and
    `has_history = EXISTS(...)`.
  - One shared low-stock fragment:
    `(low_stock_threshold_milli IS NOT NULL AND stock <= low_stock_threshold_milli) OR stock < 0`.
  - Methods:
    - `watchSummaries(query)`: search via `instr` on search_key, lower(sku) and barcode (R4);
      category and low filters; `ORDER BY (barcode = :q) DESC, (unicode(search_key) < 1536) ASC,
      search_key, name, id` (R5);
    - `watchLowStock(limit)`: `ORDER BY stock ASC`, then the list order, with `COUNT(*) OVER ()`;
    - `watchSummary(id)`;
    - `watchArchived()`;
    - `activeWithBarcode(barcode, exceptId)` and `activeNameExists(searchKey, exceptId)`;
    - `insertProduct`, `updateProduct`, `setAvgCost`, `setArchivedAt`.

  The watch queries use `customSelect(...).watch()` with
  `readsFrom: {products, stockMovements, categories}`.
- [X] T014 [P] Create `lib/core/database/daos/stock_movements_dao.dart` with these methods:
  - `stockOf(productId)`;
  - `hasAny(productId)`;
  - `insertOpening(...)` and `insertAdjustment(...)`;
  - `page(productId, before, limit)`, ordered `created_at DESC, rowid DESC`;
  - `replayRows(productId)`, ordered `created_at, rowid`.

  It never updates and never deletes.
- [X] T015 [P] Create `lib/core/database/daos/categories_dao.dart` with these methods:
  - `watchActive()`, which includes the active product count and orders by
    `sort_order, search_key`;
  - `activeBySearchKey`, `maxSortOrder`, `insert`, `rename`, `setArchivedAt`, `setSortOrders`.
- [X] T016 Register the three DAOs in `@DriftDatabase(daos: [...])` in
  `lib/core/database/app_database.dart`. Run `dart run build_runner build`, then confirm that
  `drift_schemas/` is unchanged and `schemaVersion` is still 1.
- [X] T017 Create `lib/features/products/data/mappers.dart`: row ↔ domain mapping for products,
  categories and movements (`adjustment_reason` ↔ `AdjustmentKind`, MovementType ↔
  StockEntryType). It is the only place that names Drift types.
- [X] T018 Create `lib/features/products/data/product_repository_impl.dart`. Each write is one
  `TransactionRunner.run`, with writes exactly as listed in data-model.md "Writes":
  - **create**: W1 insert the product; then, if an opening is given, W2 insert OPENING and W3 set
    `avgCost = weightedAverageCost(stockMilli: 0, …)` (R7);
  - **update**: a barcode conflict gives `barcodeTaken(name)`; a unit change with history gives
    `unitLocked`; it never writes avgCost;
  - **archive** and **restore**: restore checks the barcode conflict;
  - `searchKey = arabicNormalize(name)`; barcode and sku go through `normalizeDigits` and trim,
    and empty becomes NULL (R9);
  - a `SqliteException` UNIQUE failure on barcode maps to `barcodeTaken`;
  - `ProductSaved.nameExistsElsewhere` comes from `activeNameExists`.
- [X] T019 [P] Create `lib/features/products/data/inventory_repository_impl.dart`:
  - `setOpening`: `hasAny` must be false, else `openingNotAllowed`; then insert OPENING and set
    avgCost.
  - `adjust`, in one transaction:
    1. read stock and avgCost;
    2. damage or other-remove above stock gives `exceedsStock(onHand)`;
    3. a count sets `delta = counted − stock`, and a zero delta gives `alreadyMatches` with no write;
    4. insert ADJUSTMENT with `unitCostPiasters = avgCost`, never changing avgCost.
  - `history` reads pages.
  - `rebuildAverageCost` replays (R7): OPENING, PURCHASE, SALE_RETURN and SALE_VOID apply WAC,
    and the other types change stock only. It writes the result and returns it.
- [X] T020 [P] Create `lib/features/products/data/category_repository_impl.dart`:
  - create and rename check for a duplicate by searchKey among active categories;
  - create uses `sortOrder = max + 1`;
  - `move` swaps with the neighbour and rewrites `sort_order` 0..n-1 for all active categories in
    one transaction;
  - archive sets `archived_at`.
- [X] T021 Register the DAOs and the three repositories in `lib/core/di/service_locator.dart`, and
  extend `resetDependencies`.
- [X] T022 [P] Test `test/features/products/data/product_repository_impl_test.dart` on in-memory
  Drift (`NativeDatabase.memory()`, `FixedClock`). Cover every row of the contract table that
  concerns products:
  - rollback: a fake runner or DAO that throws after W2 leaves no product and no movement;
  - barcode conflicts on create, update and restore (an archived holder does not block);
  - unit lock;
  - archived products hidden from summaries, search and low stock;
  - an archived category matches the `none` filter;
  - the duplicate-name flag;
  - avgCost after an opening of 12 at 7.50 is 750.
- [X] T023 [P] Test `test/features/products/data/search_and_order_test.dart`:
  - "ارز" finds "أرز مصري";
  - an Arabic-digit barcode query finds the Latin barcode;
  - an exact barcode match is first;
  - a code (SKU) substring matches;
  - the order is أرز, باذنجان, تفاح, Zeta, and a name starting with ء sorts first (documents K2);
  - the low rule includes threshold-equal and below-zero rows, and excludes rows with no threshold
    and stock ≥ 0;
  - the Home query returns the 5 lowest and a total of 7.
- [X] T024 [P] Test `test/features/products/data/inventory_repository_impl_test.dart`:
  - opening once;
  - damage at the limit and at limit + 1 milli;
  - count equal (no row written), count up and count down;
  - other with add and remove;
  - avgCost unchanged after every adjustment;
  - the history page order and the cursor;
  - a property test: 200 random sequences of opening and adjustments with a seeded Random, after
    which the stock equals the sum of movements and `rebuildAverageCost` equals the stored value.
- [X] T025 [P] Test `test/features/products/data/category_repository_impl_test.dart`:
  - duplicates, including folded variants;
  - rename shows on products;
  - move up and down, at the first and last positions;
  - archive keeps the products.
- [X] T026 [P] Test `test/features/products/data/performance_test.dart`: seed 2,000 products and
  100,000 movements in a batch, then assert that the first emission of `watchSummaries(all)` plus
  one search query complete in under 300 ms (R3). Tag it `performance`, and print the timing.
- [X] T027 [P] Add a test in `test/architecture/import_rules_test.dart` (or a new
  `test/architecture/no_delete_test.dart`) that fails when any file under `lib/` contains
  `delete(` or a `DELETE` statement, or updates `stock_movements`.
- [X] T028 Gate: analyze clean and all tests green; the `drift_schemas/` diff is empty. Commit
  `feat(002): phase 2 DAOs and repositories`.

---

## Phase 3: Cubits (Foundational)

**Purpose**: all presentation state for the products feature, tested with fakes.

- [X] T029 Create `lib/features/products/presentation/products_cubits.dart` (R11):
  - `abstract class ProductsCubits` with one factory method per cubit: lowStock, productList
    (initial query), productForm (mode, productId?, initialName?), productDetails(id),
    stockHistory(id), openingStock(id), stockAdjustment(id), categories, archivedProducts;
  - `AppProductsCubits implements ProductsCubits`, which builds them from get_it.

  Register `ProductsCubits` in `service_locator.dart`.
- [X] T030 [P] Create `lib/features/products/presentation/cubits/low_stock_cubit.dart`: it watches
  `watchLowStock(5)`. The state is loading or ready(snapshot, hasAnyProduct).
- [X] T031 [P] Create `lib/features/products/presentation/cubits/product_list_cubit.dart`:
  - `search(text)` waits 200 ms after the last call (use an injectable `Duration` for tests);
  - `setCategory(filter)` and `toggleLow()`;
  - each change cancels the old subscription and subscribes to `watchSummaries` again;
  - the state is query, items and status.
- [X] T032 [P] Create `lib/features/products/presentation/cubits/product_form_cubit.dart`:
  - field setters; it loads categories and, in edit mode, the product (`unitLocked =
    hasHistory`);
  - `submit()` runs `ProductDraft.create`. Field errors go to `errors`. With an opening, the
    status becomes `confirmOpening(qty, cost, total)`; otherwise it saves.
  - `confirm()` saves; `cancelConfirm()` returns to `editing` with the fields kept;
  - `saved(id, nameExistsElsewhere)`;
  - repository errors map to field errors (barcodeTaken on the barcode field, unitLocked), and any
    other exception becomes `failed`.
- [X] T033 [P] Create `lib/features/products/presentation/cubits/product_details_cubit.dart`: it
  watches `watchSummary(id)`. `archive()` and `restore()` expose a RestoreError as a one-shot
  message.
- [X] T034 [P] Create `lib/features/products/presentation/cubits/stock_history_cubit.dart`:
  `load()`, `loadMore()` (50 per page, cursor), `hasMore`, and `refresh()`, which the details
  screen calls when the stock changes.
- [X] T035 [P] Create `lib/features/products/presentation/cubits/opening_stock_cubit.dart`: the
  quantity and cost fields, the same validation as ProductDraft's opening part, the same
  confirm/cancel flow, then `InventoryRepository.setOpening`.
- [X] T036 [P] Create `lib/features/products/presentation/cubits/stock_adjustment_cubit.dart`:
  - kind, direction (other only), quantity or counted text, note;
  - `onHandMilli` from the product;
  - `submit()` builds the AdjustmentRequest, calls adjust, and maps the errors;
  - `alreadyMatches` becomes an info status, not an error; success becomes `saved(newStockMilli)`.
- [X] T037 [P] Create `lib/features/products/presentation/cubits/categories_cubit.dart` (create,
  rename, archive, moveUp, moveDown, errors) and
  `lib/features/products/presentation/cubits/archived_products_cubit.dart` (watch, restore with a
  one-shot error).
- [X] T038 [P] Create `test/helpers/fake_products.dart`:
  - fakes of the three repositories, built on StreamControllers and recording their writes;
  - `FakeProductsCubits`, which builds real cubits on the fakes.
- [X] T039 [P] bloc_test every cubit, with one file each under
  `test/features/products/presentation/cubits/`. Cover:
  - every input and every error path;
  - the debounce: three quick searches cause one subscription;
  - the confirm flow: submit, confirmOpening, cancel keeps the fields, confirm saves;
  - `alreadyMatches`;
  - the restore error.

  Don't await `cubit.close` in tearDown inside fake async (see 001).
- [X] T040 Gate: analyze clean and all tests green. Commit `feat(002): phase 3 cubits`.

---

## Phase 4: Strings, routes, list and Home — User Story 2 (P1)

**Goal**: the owner opens Products from Home, finds products, and sees the low-stock card.

**Independent test**: with seeded products (repository fakes), search by folded name, barcode and
code, filter by category and low, and confirm the Home card states.

- [ ] T041 [US2] Add every ARB key from contracts/screens-and-state.md to
  `lib/core/l10n/arb/app_ar.arb` (the template) and `app_en.arb`. Use placeholders as listed;
  `lowStockCount` and `categoryProductCount` are ICU plurals.
  - Units: Arabic قطعة / كجم / لتر / م and English pc / kg / L / m for the short labels (B3), plus
    the full names.
  - Run `flutter gen-l10n`.
- [ ] T042 [P] [US2] Create `lib/features/products/presentation/widgets/unit_label.dart`
  (UnitType → short or full ARB label) and `stock_marks.dart`. The marks are icons for low and
  below zero, with spoken labels `markLowStock` and `markBelowZero`. Quantities are formatted via
  `formatQuantityMilli` and `context.digits`, then followed by the short unit label.
- [ ] T043 [US2] Extend `lib/core/router/route_names.dart` with the R10 paths and builders
  (`productDetails(id)`, `productEdit(id)`, `productOpening(id)`, `productAdjust(id)`). Add the
  children under the Home branch in `lib/core/router/app_router.dart`, with `new` and `archived`
  declared before `:id`.
  - `createAppRouter` takes `required ProductsCubits products`.
  - The routes this phase doesn't build yet point to a temporary `SectionPlaceholder`, replaced in
    Phases 5–7.
- [ ] T044 [US2] Pass `ProductsCubits` through `lib/app.dart` (a `products` parameter) and
  `lib/bootstrap.dart` (`sl<ProductsCubits>()`). Update `test/helpers/pump_app.dart` so `pumpApp`
  takes an optional `ProductsCubits`, defaulting to `FakeProductsCubits`.
- [ ] T045 [P] [US2] Create `lib/features/products/presentation/widgets/product_row.dart`: the
  name (wraps), price via `formatPiasters`, stock with the unit, and the marks. Tapping opens
  details. Its semantics label combines name, price and stock.
- [ ] T046 [US2] Create `lib/features/products/presentation/screens/product_list_screen.dart`:
  - a search field in the app bar;
  - filter chips (All / each active category in order / No category, and a Low stock toggle); the
    `?filter=low` query param starts with low on;
  - an overflow action to Archived products, and a FAB to add a product;
  - empty states: no products (`productsEmpty` with an add button), and no match
    (`productsNoMatch` with an "Add ‘…’" button that opens `/home/products/new` with the name
    filled in).
- [ ] T047 [P] [US2] Create `lib/features/products/presentation/widgets/low_stock_card.dart` with
  three states:
  - none low: `lowStockNone`;
  - no products: `lowStockNoProducts`;
  - some low: up to 5 rows, `lowStockCount`, and a tap that opens `/home/products?filter=low`.

  Tapping a row opens details.
- [ ] T048 [US2] Replace the placeholder in `lib/features/home/presentation/home_screen.dart` with
  the Products button, a Categories entry and the LowStockCard, providing `LowStockCubit` from
  `ProductsCubits`. The screen scrolls and has a capped width.
- [ ] T049 [P] [US2] Widget tests in
  `test/features/products/presentation/product_list_screen_test.dart` for US2 scenarios 1–6 in ar
  and en: folded search, barcode first, category filter, low mark plus filter, both empty states
  (the "Add ‘…’" button carries the name), and RTL order.
- [ ] T050 [P] [US2] Widget tests in `test/features/home/home_screen_test.dart` for US2 scenarios
  7–9: Products opens the list, the card shows 5 of 7 and its tap opens the list with the low
  filter on, the card says stock is fine, and the no-products state. Run them at 100% and 200%
  text.
- [ ] T051 [US2] Update `test/core/router/router_redirect_test.dart` with the new paths (blocked
  before onboarding and allowed after), and `test/helpers/screens.dart` (`kOnboardedPaths` gains
  the list).
- [ ] T052 [US2] Gate: analyze clean, all tests green, ARB tests green. Commit
  `feat(002): phase 4 product list and Home`.

---

## Phase 5: Product form and details — User Story 1 (P1) 🎯 MVP and User Story 3 (P2)

**Goal**: add products with opening stock; view, edit, archive and restore them.

**Independent test**: add a piece product and a kg product with opening stock, close and reopen,
and both are there; change a price; archive and restore.

- [ ] T053 [P] [US1] Create `lib/core/widgets/money_field.dart` and
  `lib/core/widgets/quantity_field.dart`:
  - `TextFormField`s with `TextInputType.numberWithOptions(decimal: true)`;
  - a formatter that accepts both digit sets and caps the decimals: 2 for money, and
    `unit.maxDecimals` for quantity (0 for piece, 3 otherwise), so a 4th decimal cannot be typed;
  - an LTR-isolated input. Test them in `test/core/widgets/number_fields_test.dart`.
- [ ] T054 [P] [US1] Create `lib/features/products/presentation/widgets/product_error_text.dart`:
  `ProductFieldError`, `ProductSaveError` and `RestoreError` mapped to ARB messages, with numeric
  limits formatted in the active digit style.
- [ ] T055 [P] [US1] Create
  `lib/features/products/presentation/widgets/opening_confirm_dialog.dart`. It shows
  `openingConfirmBody(qty with unit, cost, total)` with Confirm and Back, and returns a bool.
- [ ] T056 [US1] Create `lib/features/products/presentation/screens/product_form_screen.dart`
  (create and edit):
  - fields: name; unit as a SegmentedButton of 4, disabled with `productUnitLockedNote` when
    locked; price; a category picker with "No category"; barcode; code; low-stock level;
  - an "Opening stock" section (quantity and cost) in create mode only;
  - an optional initial name from the route's extra or query;
  - errors under the fields;
  - on `confirmOpening` it shows the dialog;
  - on `saved` it pops to details, and shows the `productNameExistsNotice` SnackBar when flagged.
  - Wire `/home/products/new` and `/home/products/:id/edit`.
- [ ] T057 [US3] Create `lib/features/products/presentation/screens/product_details_screen.dart`:
  - a header with name, unit, price, average cost, stock (with marks), category or "No category",
    barcode, code and low-stock level;
  - actions: Edit, Adjust stock (a route placeholder until Phase 6), Set opening stock (only when
    `!hasHistory`), and Archive with a confirm dialog;
  - an archived product shows Restore, with the error as a SnackBar;
  - a history section reserved for Phase 6 (an empty-state text for now).
  - Wire `/home/products/:id`.
- [ ] T058 [P] [US3] Create
  `lib/features/products/presentation/screens/archived_products_screen.dart`: a list with a
  Restore action per row and a restore error SnackBar. Wire `/home/products/archived`.
- [ ] T059 [P] [US1] Widget tests in
  `test/features/products/presentation/product_form_screen_test.dart` for US1 scenarios 1–8:
  - required fields;
  - the confirmation shows 12 × 7.50 = 90.00, and Back keeps the form and saves nothing;
  - piece fractions rejected;
  - kg 2.375, with a 4th decimal not accepted;
  - opening without cost;
  - a barcode conflict naming the other product;
  - Arabic and Latin digits.

  Run in ar and en, at 100% and 200%.
- [ ] T060 [P] [US3] Widget tests in
  `test/features/products/presentation/product_details_screen_test.dart` and
  `archived_products_screen_test.dart` for US3 scenarios 1–6:
  - edit the price;
  - the unit is locked after history;
  - archive hides the product, and restore brings it back;
  - a restore barcode conflict;
  - no delete action exists anywhere.
- [ ] T061 [US1] Add an integration test on a real temp database
  (`test/features/products/products_flow_test.dart`, using `tester.runAsync`): add a product with
  opening stock, dispose the database and reopen it, then confirm the product and stock are still
  there (SC-006).
- [ ] T062 Gate: analyze clean and all tests green. Commit `feat(002): phase 5 product form and
  details`.

---

## Phase 6: Stock — User Story 4 (P2)

**Goal**: opening later, adjustments with reasons, and a permanent history.

**Independent test**: 10 on hand → count 8 → damage 1 gives stock 7, with history showing opening,
count and damage.

- [ ] T063 [US4] Create `lib/features/products/presentation/screens/opening_stock_screen.dart`:
  quantity and cost fields, the confirm dialog, and save. It redirects to details when the product
  already has history. Wire `/home/products/:id/opening`.
- [ ] T064 [US4] Create `lib/features/products/presentation/screens/stock_adjustment_screen.dart`:
  - a reason picker (Damaged / Stock count / Other);
  - Count shows `adjustOnHand` and the counted field; Damaged shows the remove quantity; Other
    shows an Add/Remove toggle, the quantity and a required note;
  - an optional note for the other reasons;
  - `alreadyMatches` shows an info message; success pops with the `adjustSaved(newStock)`
    SnackBar.
  - Wire `/home/products/:id/adjust`.
- [ ] T065 [US4] Fill the history section of `product_details_screen.dart` from
  `StockHistoryCubit`:
  - each row shows the local date and time, the type label (all 7 types), the reason, the signed
    quantity with its unit, and the note;
  - "Show more" loads the next page;
  - the list refreshes when the summary's stock changes.
- [ ] T066 [P] [US4] Widget tests in
  `test/features/products/presentation/stock_adjustment_screen_test.dart` and
  `opening_stock_screen_test.dart` for US4 scenarios 1–7: count down, count equal, damage above
  stock blocked, other without a note blocked, no edit or delete on history rows, avg cost
  unchanged, and opening once. Run in ar and en, at 100% and 200%.
- [ ] T067 [P] [US4] Test that every `StockEntryType` and `AdjustmentKind` has a label in both
  languages, in `test/features/products/presentation/history_labels_test.dart`.
- [ ] T068 Gate: analyze clean and all tests green. Commit `feat(002): phase 6 stock adjustments
  and history`.

---

## Phase 7: Categories — User Story 5 (P3)

**Goal**: create, rename, reorder and archive categories.

**Independent test**: two categories, reorder and rename them, archive one; its products appear
under "No category".

- [ ] T069 [US5] Create `lib/features/products/presentation/screens/categories_screen.dart`:
  - an add field at the top;
  - each row shows the name and `categoryProductCount`, with Rename (a dialog), Move up and Move
    down (spoken labels, disabled at the ends), and Archive (with `categoryArchiveConfirm`);
  - errors (duplicate, too long) appear inline.
  - Wire `/home/categories`.
- [ ] T070 [P] [US5] Widget tests in
  `test/features/products/presentation/categories_screen_test.dart` for US5 scenarios 1–4:
  - a folded duplicate is blocked;
  - a rename shows on products;
  - archiving moves its products to "No category" in the list filter;
  - the order is used by the filter chips and the form picker.

  Run in ar and en, at 100% and 200%.
- [ ] T071 Gate: analyze clean and all tests green. Commit `feat(002): phase 7 categories`.

---

## Phase 8: Polish and device check

**Purpose**: cross-screen accessibility and layout, the debug seed, and the quickstart on the
phone.

- [ ] T072 Extend `test/helpers/screens.dart` so `visitEveryScreen` visits every new screen and the
  opening dialog with seeded fakes. Then confirm that `test/app/semantics_labels_test.dart` and
  `test/app/layout_stress_test.dart` pass for all of them: every control has a spoken label, and
  nothing overflows at 200% in ar and en, light and dark.
- [ ] T073 [P] Add the debug-only demo seed (B2). An overflow item "Seed demo products" on
  `archived_products_screen.dart` appears only when `kDebugMode`. It calls
  `lib/features/products/data/demo_seed.dart`, which inserts 2,000 products with opening stock
  through `ProductRepository.create`. Test that the item is absent when the debug flag is false
  (inject the flag).
- [ ] T074 Run the full gate (analyze clean, all tests green) and `flutter build apk --debug`. Then
  install on the connected phone and run the quickstart scenarios that work with the screen
  locked. List the rest for the owner. Never unlock the phone or enter a PIN.
- [ ] T075 Re-run the T001 lock audit and report it. Mark all tasks [X] in this file. Commit
  `feat(002): phase 8 polish and device check`. Do not push.

---

## Dependencies & Execution Order

### Phase dependencies

- Phase 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8, strictly sequential, with review between.
  - Phase 2 needs the Phase 1 types and interfaces.
  - Phase 3 needs the Phase 1 interfaces (it uses fakes, not Phase 2 impls, but runs after for DI).
  - Phase 4 needs the Phase 3 cubits and bundle.
  - Phases 5–7 need the Phase 4 routes and strings.
  - Phase 8 needs everything.

### User story dependencies

- **US2** (Phase 4): needs Phases 1–3. Testable with fake data before US1 exists.
- **US1** (Phase 5): needs Phase 4 routes. Together with US2 this is the MVP.
- **US3** (Phase 5): shares the form and details screens with US1.
- **US4** (Phase 6): needs the details screen from US3.
- **US5** (Phase 7): needs the list filters (US2) and the form picker (US1). Otherwise
  independent.

### Within each phase

- Tasks without [P] run in ID order.
- [P] tasks touch different files and can run in any order.
- The gate task always runs last.

## Parallel examples

```text
Phase 1: T002, T003, T005–T008 together; then T004, T009; then T010, T011 together.
Phase 2: T014, T015 together after T013; T019, T020 together after T018; T022–T027 together.
Phase 3: T030–T037 together after T029; T038 then T039.
Phase 4: T042, T045, T047 together after T041; T049, T050 together.
Phase 5: T053–T055 together; T058 with T057; T059, T060 together.
```

## Implementation Strategy

### MVP first

1. Phases 1–3: foundation (no user-visible change, everything tested).
2. Phase 4 (US2) and Phase 5 (US1, US3). **STOP and validate**: an owner adds products with
   opening stock in under 30 s, finds them, and they persist.

### Incremental delivery

3. Phase 6: US4 (adjustments and history).
4. Phase 7: US5 (categories).
5. Phase 8: polish, then the quickstart on the phone.

## Notes

- [P] = different files, no dependency on incomplete tasks; [USn] = traceability to spec.md.
- Commit at each gate (B1); the owner pushes.
- No schema change in this feature: if a task seems to need one, stop and ask.
