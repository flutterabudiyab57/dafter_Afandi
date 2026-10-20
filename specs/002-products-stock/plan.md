# Implementation Plan: Products and Stock

**Branch**: `002-products-stock` | **Date**: 2026-10-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/002-products-stock/spec.md`

## Summary

This feature adds the product catalog and stock on hand on top of 001-foundation:
- add, edit, archive and restore products, with an optional opening stock that is confirmed
  before saving;
- search with Arabic folding, an alphabetical list, filters by category and low stock;
- stock adjustments (damaged, stock count, other) and a per-product stock history;
- categories (add, rename, reorder, archive);
- a Products button and a low-stock card on Home.

Stored data stays on **schema v1** (no migration) and **no package is added**. Stock is always the
sum of stock movements. Average cost changes only on opening stock. Every multi-write is one
transaction.

Decisions and evidence are in [research.md](research.md), domain types and writes in
[data-model.md](data-model.md), and interfaces in [contracts/](contracts/).

## Technical Context

**Language/Version**: Dart 3.13.5 on Flutter 3.47.7 stable

**Primary Dependencies**: unchanged from 001: material_ui 1.5.0, flutter_bloc 9.1.1, go_router
18.0.2, drift 2.35.1, drift_flutter 0.3.1, get_it 9.3.0, equatable 3.0.0, intl 0.20.3; dev:
bloc_test, mocktail, drift_dev, build_runner.

**Storage**: SQLite via Drift, schema v1. It uses `products`, `categories` and `stock_movements`.
No new table, column, index or trigger.

**Testing**:
- flutter_test, bloc_test with mocktail;
- repositories on `NativeDatabase.memory()`, with a property test (stock = sum, WAC = replay) and
  a performance test;
- widget tests at 100% and 200% text in ar and en;
- the existing import-rules and ARB tests.

**Target Platform**: Android minSdk 24 / targetSdk 36; iOS 15+. Phones, portrait.

**Project Type**: mobile app (single Flutter project).

**Performance Goals**:
- search updates within 1 s with 2,000 products on a 2 GB Android phone (SC-002); the query
  budget is under 300 ms on the dev machine (R3);
- add a product in under 30 s (SC-001) and record a stock count in under 20 s (SC-004).

**Constraints**:
- offline;
- integer money and quantities only;
- no deletes and no movement updates (triggers);
- unit locked after the first movement;
- opening stock once, with no correction (clarification Q1).

**Scale/Scope**:
- 9 new screens (list, form, details with history, opening, adjustment, archived, categories,
  plus the Home card and the confirmation dialog);
- 3 repositories, 3 DAOs, 9 cubits;
- about 110 ARB keys.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design (below).*

| Principle / rule | Status | Evidence / note |
|---|---|---|
| I. Local-first; no network code | PASS | No network use; the import test is unchanged. |
| I. Sync-ready schema | PASS | Existing v1: UUID v7, UTC ms, archivedAt, append-only movements. |
| II. Arabic-first; all strings in ARB | PASS | All new keys in ar and en (contracts/screens-and-state.md); parity and literal-text tests. |
| II. Never "tax receipt" | PASS | No document is produced here; the ARB grep test still runs. |
| III. Integer money/qty, no double | PASS | `int` piasters and milli everywhere; existing parse and format utils; the grep test. |
| III. UUID PK; document numbers separate | PASS | `IdGenerator` for products, categories and movements. No document numbers here. |
| III. Stock derived; only avgCost cached | PASS | Stock is a SUM subquery (R3). avgCost is written only by the opening path, in the same transaction as its movement (R7), and rebuilt by replay in tests. |
| III. Immutability, no hard delete | PASS | Movements are insert-only; archive instead of delete; a grep test asserts the repositories issue no `delete(`/`DELETE`; the v1 triggers back this up. |
| III. One transaction per financial op | PASS | Write lists in data-model.md; a rollback test for each multi-write. |
| III. Sale cost/name snapshot; WAC on purchases; returns at snapshot | N/A | Later features. The replay already treats those types as inbound (R7). |
| III. Secrets not in DB | N/A | No secrets. |
| IV. Feature-first, strict layers | PASS | `features/products/{domain,data,presentation}`. DAOs live in `core/database/daos`. Home presentation imports only products `domain` and `presentation`. import_rules_test is extended to cover the new feature. |
| V. material_ui only; delegate rule | PASS | Same as 001. |
| V. No new package; exact pins; 14-day rule | PASS | No pubspec change. The lock audit is re-run before the first commit (Q3). |
| Technical rules (UTC ms, RTL-safe, text scale) | PASS | `Clock`; `EdgeInsetsDirectional`; no text-scale override; 200% tests. |
| Schema change via make-migrations | N/A | No schema change (R1). |
| Quality gates | PASS | Each phase below ends with analyze clean and the full test suite green. |
| Workflow | PASS, **note W1** | One phase per `/speckit-implement`, then stop. W1: the constitution says the agent never commits. During 001 the owner asked for a commit per phase. The plan assumes the same for 002 only if the owner confirms it again. |

**Post-design re-check (after Phase 1)**: unchanged. All rows PASS or N/A, and no deviation needs
justification.

### Decisions for the owner before `/speckit-implement`

| Id | Question | Recommendation |
|---|---|---|
| B1 | Commit after each phase, as in 001 (constitution says the agent never commits)? | Yes, a commit per phase, never a push. |
| B2 | Scenario 19 needs about 2,000 products on the phone. Add a debug-only "seed demo products" path (`kDebugMode`, never in release)? | Yes, in a debug menu on the archived-products screen's overflow, compiled out in release. |
| B3 | Should unit labels be short with no plurals (قطعة / كجم / لتر / م; pc / kg / L / m), research R18? | Yes. |

**Approved 2026-10-20 by the project owner: B1–B3 all as recommended.** A commit per phase, never
a push; a debug-only demo seed (compiled out in release); short unit labels with no plurals.

## Project Structure

### Documentation (this feature)

```text
specs/002-products-stock/
├── plan.md              # this file
├── research.md          # Phase 0
├── data-model.md        # Phase 1: domain types, queries, writes
├── quickstart.md        # Phase 1: validation guide
├── contracts/
│   ├── repositories-and-domain.md
│   └── screens-and-state.md
├── checklists/requirements.md
└── tasks.md             # /speckit-tasks (not created here)
```

### Source Code (repository root)

```text
lib/
  core/
    database/
      app_database.dart                 # daos: + ProductsDao, CategoriesDao, StockMovementsDao
      daos/{products_dao, categories_dao, stock_movements_dao}.dart
    di/service_locator.dart             # + DAOs, repositories, AppProductsCubits
    router/{app_router, route_names}.dart   # Home-branch child routes (R10)
    l10n/arb/app_{ar,en}.arb            # new keys
    widgets/{money_field, quantity_field}.dart   # decimal fields with per-unit caps (R12)
  features/
    products/
      domain/   product.dart, product_draft.dart, product_errors.dart, category.dart,
                stock_entry.dart, adjustment.dart, product_query.dart,
                product_repository.dart, inventory_repository.dart, category_repository.dart
      data/     product_repository_impl.dart, inventory_repository_impl.dart,
                category_repository_impl.dart, mappers.dart
      presentation/
        products_cubits.dart            # ProductsCubits bundle + AppProductsCubits (R11)
        cubits/ low_stock, product_list, product_form, product_details, stock_history,
                opening_stock, stock_adjustment, categories, archived_products
        screens/ product_list, product_form, product_details, opening_stock,
                 stock_adjustment, archived_products, categories
        widgets/ product_row, stock_marks, low_stock_card, opening_confirm_dialog,
                 unit_label, product_error_text
    home/presentation/home_screen.dart  # placeholder replaced: Products, Categories, LowStockCard
  app.dart                              # + products: ProductsCubits
  bootstrap.dart                        # passes sl<ProductsCubits>()
test/
  features/products/{domain,data,presentation}/…
  helpers/{pump_app.dart, screens.dart, fake_products.dart}
  architecture/import_rules_test.dart   # covers the new feature
```

**Structure Decision**: same single Flutter app with feature-first folders as 001. DAOs stay in
`core/database` so one transaction can span features later (sales will write movements). The Home
feature shows products through the products presentation layer only.

## Implementation phases (for tasks.md)

Each phase is one `/speckit-implement` run. It ends with `flutter analyze` clean and the full
`flutter test` green, then stops for review.

| Phase | Content | Done when |
|---|---|---|
| **1. Pre-flight and domain** | Lock-file 14-day audit (report only); domain types, `ProductDraft.create`, adjustment requests, category name validation, sealed errors; repository interfaces | Domain tests at every limit; no Flutter or Drift import in domain |
| **2. DAOs and repositories** | `ProductsDao`, `CategoriesDao`, `StockMovementsDao` (queries R3–R6), registered on `AppDatabase` (no schema change, so the drift schema JSON is unchanged); the three repository impls with transactions (R7, R9); DI registration | Every rule in contracts/repositories-and-domain.md has a test: rollback, property (stock and WAC replay), barcode, unit lock, opening once, archived, search folding, order, performance |
| **3. Cubits** | The nine cubits and the `ProductsCubits` bundle | bloc_test for each input and error path, incl. the debounce and the confirm flow |
| **4. Strings, routes, list and Home** | ARB keys; `RoutePaths`; Home-branch routes; `App` and `createAppRouter` take `ProductsCubits`; `ProductListScreen` (search, filters, marks, empty states); Home with the Products button, Categories entry and `LowStockCard` | Widget tests: Home → list, `?filter=low`, card states (none / no products / 7 low → 5 shown), RTL order, 200%; redirect matrix still green |
| **5. Product form and details** | Money and quantity fields; `ProductFormScreen` (create and edit, unit lock, category picker, opening section); opening confirmation dialog; `ProductDetailsScreen` header and actions; archive with confirm; restore; `ArchivedProductsScreen`; duplicate-name notice | Widget tests for US1 and US3 scenarios in ar and en at 100% and 200% |
| **6. Stock: opening later, adjustments, history** | `OpeningStockScreen`; `StockAdjustmentScreen` (three reasons, add/remove toggle, note rule, already-matches info); history list with Show more | Widget tests for US4 scenarios; history labels for every movement type |
| **7. Categories** | `CategoriesScreen`: add, rename, move up/down, archive with confirm; filter and picker use the order | Widget tests for US5 scenarios |
| **8. Polish and device check** | Extend `visitEveryScreen` (semantics labels and layout stress) to the new screens; debug seed (if B2 is approved); `flutter build apk --debug`; quickstart scenarios on the phone, results reported | All automated checks green; manual scenarios reported (the owner runs any that need the phone unlocked) |

## Risks

| Id | Risk | Mitigation |
|---|---|---|
| K1 | The stock subquery on every list row slows down with many movements once sales arrive | Performance test now with 100k movements; a trigger-kept cache by migration later if needed (report §3) |
| K2 | Code-point order is not perfect Arabic collation (ء ؤ ئ before ا) | Documented and tested (R5); ICU would need a package |
| K3 | Watch queries re-run on every write to the three tables | Fine at this scale; the performance test covers one re-run |
| K4 | A wrong opening cost cannot be fixed until purchases exist (clarification Q1) | The confirmation dialog shows the total; documented in the spec |
| K5 | Overrides from 001 expire between 2026-10-27 and 2026-10-30, during this feature | The phase 1 audit and the pre-commit audit report which can be removed; removal needs owner approval |
| K6 | iOS not checkable on Windows | Listed in quickstart |

## Complexity Tracking

No constitution violations to justify. Note W1 (commits) and decisions B1–B3 are listed above.
