# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# دفتر أفندي — Daftar Afandi

An offline, single-device accounting app for small Egyptian shops. It is Arabic-first (RTL) with English, EGP only, and has no tax.
The on-device SQLite database is the only source of truth. There is NO network code (no dio, http or Firebase).

`.specify/memory/constitution.md` is binding and wins over this file. `docs/research/M0-DECISIONS.md` overrides `docs/research/M0-PHASE1-REPORT.md` where they differ.

## Commands

```bash
flutter analyze                                   # must be clean
flutter test                                      # full suite (~1.5 min)
flutter test test/features/products/presentation/product_form_screen_test.dart
flutter test test/path/to_test.dart --plain-name "part of the test name"
dart run build_runner build                       # drift *.g.dart (committed)
flutter gen-l10n                                  # ARB → lib/core/l10n/generated (also runs on pub get)
dart run drift_dev make-migrations                # any schema change (see below)
flutter build apk --debug
```

A phase is not done until `flutter analyze` is clean and `flutter test` passes.

## Workflow (human-in-the-loop, Spec Kit)

- Features live in `specs/NNN-name/` (spec, plan, research, data-model, contracts, tasks). Skills in `.claude/skills/speckit-*` drive specify → clarify → plan → tasks → implement.
- `/speckit-implement` runs ONE phase of `tasks.md`, marks its tasks `[X]`, then stops for review.
- **Commits:** the constitution says the agent never commits. Decision B1 in `specs/002-products-stock/plan.md` lets the agent commit once at each phase gate, for that feature only. **Never push or merge;** the owner does that.
- **Packages:** never add, remove or upgrade one without approval. Direct dependencies are pinned exactly. Never pick a version under 14 days old.
- **Overrides:** every `dependency_overrides` entry carries a "remove after <date>" comment. Re-audit `pubspec.lock` dates before each feature's first commit.
- When something is ambiguous, stop and ask.
- **Logo:** `assets/images/afandi.jpg` (the photo of the afandi writing in his ledger) is the only correct one; the old drawing `logo.png` is kept but no longer shown. Never read or use files from other projects, e.g. `E:\projects\Cardeil`.
- **Signing and devices:** never create keystores, handle passwords, unlock a device or enter a PIN.

## Hard code rules (most are enforced by `test/architecture/import_rules_test.dart`)

- **Imports:** use `package:material_ui/material_ui.dart`, NEVER `package:flutter/material.dart` or `cupertino.dart`.
- **Localization delegates:** `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]` (from material_ui). Never `AppLocalizations.localizationsDelegates`. Never import `flutter_localizations` in a file that imports material_ui.
- **Stack:** state is flutter_bloc Cubits only, DI is get_it, routing is go_router (StatefulShellRoute), the database is drift. Forbidden: dio, Firebase, Hive, Isar, Riverpod, GetX, MobX, Provider-as-state.
- **Money:** `int` piasters (1 EGP = 100), names end in `Piasters`.
- **Quantity:** `int` milli-units (1 unit = 1000), names end in `Milli`.
- **No `double`** anywhere in money or quantity paths. Parse, round and format only through `lib/core/utils` (money.dart, quantity.dart, decimal_text.dart, digits.dart). Arabic and Latin digits must both be accepted.
- **Strings:** every user-visible string goes in BOTH `lib/core/l10n/arb/app_ar.arb` (the template) and `app_en.arb`. Presentation code may not contain `Text('literal')`. App Arabic is MSA, not Egyptian dialect.
- **Visuals:** `Color(`, `TextStyle(`, `EdgeInsets.only/fromLTRB` and left/right alignment are allowed only in `lib/core/theme/`.
  - Elsewhere, use `context.tokens` (app_tokens.dart), `EdgeInsetsDirectional` and start/end.
  - flutter_screenutil is for sizes only: no `.sp`, and system text scaling is never clamped.
- **No hard deletes and no updates to `stock_movements`:** DB triggers refuse them and the import rules ban them. Archive instead (`archivedAt`).
  - The one exception (constitution 1.2.0): a customer or supplier with no history is removed for good 7 days after it was archived (`purgeArchived` at startup). Only their DAOs may delete.
- **Secrets:** they never go in the database. The PIN hash and salt live in flutter_secure_storage.

## Architecture

Feature-first: `lib/core/{database,di,router,theme,l10n,utils,widgets}` and `lib/features/<name>/{data,domain,presentation}`.

Strict layer direction: **Screen → Cubit → Repository interface (`domain/`) → Repository impl (`data/`) → DAO → Drift.**
- `domain/` is pure Dart: entities, sealed error classes, and repository interfaces returning `Result<T, E>` (core/utils/result.dart). No Flutter, no Drift rows.
- `data/` maps Drift rows to entities (`mappers.dart`). Every multi-table write runs in ONE transaction via `TransactionRunner` (core/database/transaction_runner.dart).
- Screens and cubits never import `core/database`, DAOs or another feature's `data/`.
- **IDs and time:** primary keys are UUID v7 text from `IdGenerator` (core/utils/id.dart). Time is UTC epoch ms through `Clock` and `UtcMillisConverter`. Inject both so tests are deterministic.

**Database** (`lib/core/database/`): `app_database.dart` holds the `@DriftDatabase` with tables/, daos/ and converters/.
- The raw schema SQL, triggers and the startup guard are in schema_sql.dart and schema_guard.dart.
- Stock is derived: `stock = SUM(stock_movements)`, computed with correlated subqueries in the DAOs. The only cached value is `products.avgCostPiasters` (weighted average cost), written only by inbound-movement paths in the same transaction.
- Search folds text with `arabicNormalize` (core/utils/arabic_normalize.dart) into a `search_key` column.
- **Schema changes:** bump `schemaVersion`, run `dart run drift_dev make-migrations`, write a step-by-step migration, and keep the exported JSON in `drift_schemas/` with passing tests in `test/drift/`. The schema is at v3: feature 006 added `payment_parts` in v2 (a payment split into up to three methods, with the owner's account number) and, in v3, the delete permission for purging unused customers and suppliers.

**App wiring:**
- `main.dart` calls `bootstrap.dart` (DB open, schema guard, get_it in `core/di/service_locator.dart`), which builds `app.dart` (MaterialApp.router).
- Cubits for a feature are created through a factory bundle (e.g. `ProductsCubits` / `AppProductsCubits` in `features/products/presentation/cubits/products_cubits.dart`). The bundle is passed App → `createAppRouter`, so tests can swap in fakes.
- Payments (006): every form that takes money uses `PaymentSplitField` (features/payments/presentation). Its cubit comes from the `PaymentsCubits` bundle that `App` provides once; parts are written only through `PaymentPartsWriter`, inside the caller's transaction.
- Routes and paths are in `core/router/route_names.dart`. `AppShellScaffold` is the bottom-nav shell and hides its AppBar below section roots (`RoutePaths.isSectionRoot`).

## Testing conventions

- **Repositories:** test on a real in-memory Drift database (`NativeDatabase.memory()`, helpers in `test/core/database/test_database.dart`, feature envs like `test/features/products/data/products_env.dart`).
- **Cubits:** bloc_test + mocktail.
- **Widget tests:**
  - Use `pumpApp(tester, settingsRepo, products: FakeProductsCubits(store), textScale: …)` and `goTo(tester, path)` from `test/helpers/pump_app.dart`. In-memory fakes are in `test/helpers/fake_products.dart`.
  - Screen tests loop over both locales (ar and en) and text scales 1.0 and 2.0.
  - Use `tester.ensureVisible` before tapping offscreen widgets.
  - For short pages, prefer `SingleChildScrollView(Column)` over lazy lists so every row is built at 200%.
  - In fakes, don't return a broadcast stream's cancel future from `onCancel` (it hangs under fake async).
- **Every-screen coverage:** `test/helpers/screens.dart` (`visitEveryScreen`, `kOnboardedPaths`) drives the semantics and layout-stress tests in `test/app/`. Add new screens there.
- **Real app flow:** `test/app/real_app_flow_test.dart` boots the real app (bootstrap, DI, every real repository) on a SQLite file and drives a whole day through the screens. Extend it when a feature adds a main flow.
- **ARB keys:** `test/l10n/arb_test.dart` checks that ar and en have the same keys.
