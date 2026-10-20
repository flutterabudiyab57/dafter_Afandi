---

description: "Task list for 001-foundation"
---

# Tasks: Foundation

**Input**: Design documents from `specs/001-foundation/`. These are plan.md, spec.md,
research.md, data-model.md, contracts/ and quickstart.md.

**Prerequisites**: approvals A1–A5 are granted (plan.md, 2026-10-19).

**Tests**: Included. The constitution requires them: every money/quantity utility and every
financial flow has unit tests, Cubits use bloc_test + mocktail, schema changes have migration tests,
and import_rules_test must pass.

**Organization**: The tasks follow the **9 implementation phases in plan.md**. Each phase is ONE
`/speckit-implement` run. It ends with `flutter analyze` clean and `flutter test` green, then STOPS
for human review.
- Phases 1–6 are setup and foundational work, with no story label.
- Phase 7 delivers US1 and US2, Phase 8 delivers US3 and US4, and Phase 9 delivers US5 plus
  platform polish.

**Standing rules for every task**:
- Never commit, stage, push or merge.
- Never add a package that isn't in plan.md.
- Import `package:material_ui/material_ui.dart`, never `flutter/material.dart` or `cupertino.dart`.
- No `double` in money or quantity paths.
- No user-visible literal strings; they come from the ARB files.
- No `Color(`, `TextStyle(` or `EdgeInsets.only/fromLTRB` outside `lib/core/theme`.
- If anything is ambiguous, stop and ask.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US5 from spec.md (used only in Phases 7–9)

---

## Phase 1: Repo and dependencies (Setup)

**Purpose**: a clean, pinned, rule-enforcing project that launches a blank material_ui screen.

- [X] T001 [P] Create `.gitattributes` at the repo root with these rules (research R13):
  - `* text=auto eol=lf`
  - `*.bat text eol=crlf` and `*.cmd text eol=crlf`
  - `binary` for `*.png *.jpg *.jpeg *.ttf *.otf *.jks *.keystore *.sqlite`
- [X] T002 Rewrite `pubspec.yaml`:
  - `description: "دفتر أفندي — Daftar Afandi: offline shop accounting"` and `version: 1.0.0+1`;
  - `environment: sdk: ^3.13.5`, `flutter: ">=3.47.7 <3.48.0"`;
  - **exact** pins (no `^`):
    - dependencies: material_ui 1.5.0, flutter_bloc 9.1.1, go_router 18.0.2, drift 2.35.1,
      drift_flutter 0.3.1, get_it 9.3.0, uuid 4.6.0, flutter_screenutil 5.9.3, intl 0.20.3,
      flutter_localizations (sdk), path_provider 2.1.6, package_info_plus 10.2.2, equatable 3.0.0;
    - dev_dependencies: flutter_test (sdk), build_runner 2.16.1, drift_dev 2.35.1, bloc_test 10.0.0,
      mocktail 1.0.5, flutter_lints 6.0.0;
  - `dependency_overrides`: `sqlite3: 3.7.0  # remove after 2026-10-27` and
    `cupertino_ui: 1.1.1  # remove after 2026-10-28`;
  - **remove** `cupertino_icons` (A3);
  - `flutter: generate: true` and `uses-material-design: true`. No assets or fonts yet (they come in Phase 5).
- [X] T003 Run `flutter pub get`. Then audit every package in `pubspec.lock`:
  - use a throwaway script in the scratchpad (not in the repo) that queries `https://pub.dev/api/packages/<name>`;
  - any version published after **2026-10-05** gets a `dependency_overrides` entry at the newest
    version published on or before 2026-10-05, with `# remove after <date it turns 14 days old>` (A2);
  - re-run until clean, and report the final table (package, version, publish date).
- [X] T004 [P] Create `l10n.yaml` with:
  - `arb-dir: lib/core/l10n/arb`, `template-arb-file: app_ar.arb`, `output-dir: lib/core/l10n/generated`;
  - `output-localization-file: app_localizations.dart`, `nullable-getter: false`.
- [X] T005 [P] Create `lib/core/l10n/arb/app_ar.arb` (`"@@locale": "ar"`, `"appName": "دفتر أفندي"`) and
  `lib/core/l10n/arb/app_en.arb` (`"@@locale": "en"`, `"appName": "Daftar Afandi"`).
- [X] T006 [P] Create `build.yaml`, exactly as in report §3.4:
  - `databases: app_database: lib/core/database/app_database.dart`;
  - `schema_dir: drift_schemas/`, `test_dir: test/drift/`;
  - `sql: dialect: sqlite, options: version: "3.45"`.
- [X] T007 [P] Update `analysis_options.yaml`:
  - keep `include: package:flutter_lints/flutter.yaml`;
  - add `analyzer: language: strict-casts, strict-raw-types, strict-inference: true`;
  - exclude `**/*.g.dart` and `lib/core/l10n/generated/**`;
  - enable `prefer_const_constructors`, `prefer_final_locals`, `always_declare_return_types`,
    `avoid_print`, `directives_ordering`, `unawaited_futures`.
- [X] T008 [P] Raise iOS to 15.0:
  - every `IPHONEOS_DEPLOYMENT_TARGET` in `ios/Runner.xcodeproj/project.pbxproj`;
  - `platform :ios, '15.0'` in `ios/Podfile`, if that file exists;
  - `MinimumOSVersion` in `ios/Flutter/AppFrameworkInfo.plist`, if present.
- [X] T009 Replace `lib/main.dart` with a minimal app that imports only `package:material_ui/material_ui.dart`
  and shows an empty `Scaffold`. This is temporary; Phase 4 replaces it.
- [X] T010 Delete `test/widget_test.dart` and create `test/app_smoke_test.dart`, which pumps the T009 app and
  finds a `Scaffold`.
- [X] T011 Create `test/architecture/import_rules_test.dart`. It is plain Dart that scans `lib/` and skips
  `*.g.dart` and `lib/core/l10n/generated/`. It fails on any of the research R14 rules:
  - `package:flutter/material.dart` or `package:flutter/cupertino.dart`;
  - a `presentation/` or `domain/` file importing `package:drift`, `core/database/` or another feature's `data/`;
  - `package:flutter/` imported in `domain/`;
  - `AppLocalizations.localizationsDelegates`;
  - `flutter_localizations` imported in a file that also imports material_ui;
  - the word `double` in `lib/features/*/domain/**` or `lib/core/utils/money.dart` / `quantity.dart`;
  - `package:http`, `package:dio`, `HttpClient`, `Socket` or `WebSocket`;
  - `.sp`;
  - outside `lib/core/theme/`: `Color(`, `TextStyle(`, `EdgeInsets.only(`, `EdgeInsets.fromLTRB(`,
    `Alignment.centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight`, `TextAlign.left|right`;
  - `Text('` or `Text("` followed by a non-empty literal in `presentation/`.

  Each rule has a positive and a negative case, run against in-memory sample sources.
- [X] T012 Phase gate: run `flutter analyze` and `flutter test`, both green. Report and STOP.

**Checkpoint**: the project builds with pinned packages and the rules are enforced.

---

## Phase 2: core/utils (Foundational)

**Purpose**: pure-Dart utilities from contracts/core-utils.md, fully tested. Every file is
independent, so all tasks are [P].

- [X] T013 [P] `lib/core/utils/result.dart`: `sealed class Result<T, E>` with `Ok<T, E>(value)` and
  `Err<T, E>(error)`, plus `fold`. Test in `test/core/utils/result_test.dart`.
- [X] T014 [P] `lib/core/utils/app_locale_code.dart`: `enum AppLocaleCode { ar, en }`.
- [X] T015 [P] `lib/core/utils/digits.dart`:
  - `enum DigitStyle { arabicIndic, latin }`;
  - `normalizeDigits(String)`: U+0660–0669 and U+06F0–06F9 become `0-9`;
  - `applyDigitStyle(String latin, DigitStyle)`: `0-9 → ٠-٩`, `. → ٫`, `, → ٬` when Arabic-Indic, otherwise unchanged;
  - `ltrIsolate(String)`: wraps in U+2066 … U+2069.

  Tests in `test/core/utils/digits_test.dart`.
- [X] T016 [P] `lib/core/utils/money.dart`:
  - `piastersPerPound = 100`;
  - `roundHalfUpDiv` (half away from zero; asserts denominator > 0);
  - `lineTotalPiasters(qtyMilli, unitPricePiasters) = roundHalfUpDiv(qty*price, 1000)`;
  - `allocateLargestRemainder(total, weights)`: Σ = total, ties go to the lower index;
  - `weightedAverageCost`: if `stockMilli <= 0` the result is `roundHalfUp(inTotalCost*1000, inQty)`,
    otherwise `roundHalfUp(S*A + C*1000, S + q)`;
  - `tryParsePiasters`: accepts ٠-٩ ۰-۹ 0-9, "٫"/"." decimal, "٬"/"," grouping, at most 2 decimals;
  - `formatPiasters`: "١٬٢٣٤٫٥٠ ج.م" for ar + Arabic-Indic, "EGP 1,234.50" for en + Latin; digits
    applied via `applyDigitStyle`.

  Tests in `test/core/utils/money_test.dart` cover every case listed in contracts/core-utils.md,
  including a seeded-Random property test for allocation.
- [X] T017 [P] `lib/core/utils/quantity.dart`:
  - `milliPerUnit = 1000`;
  - `enum UnitType { piece, kg, liter, meter }` with `allowsFraction` and `maxDecimals` (piece 0, others 3);
  - `tryParseQuantityMilli` rejects fractions for piece;
  - `formatQuantityMilli`.

  Tests in `test/core/utils/quantity_test.dart` include parse/format round-trips.
- [X] T018 [P] `lib/core/utils/phone.dart`:
  - `sealed class PhoneParse` with `PhoneOk(normalized)`, `PhoneEmpty`, `PhoneInvalidChars`,
    `PhoneTooShort` and `PhoneTooLong`;
  - `parseShopPhone(raw)` strips spaces and `-`, then `normalizeDigits`; allows an optional single
    leading `+`; requires "7–15 digits"; returns Latin output, e.g. `+201001234567`.

  Tests in `test/core/utils/phone_test.dart`: the boundaries 6/7/15/16, Arabic digits, `+` in the
  middle rejected, empty → `PhoneEmpty`.
- [X] T019 [P] `lib/core/utils/arabic_normalize.dart`: `arabicNormalize(String)` does the following:
  - removes tashkeel (U+064B–U+0652, U+0670) and tatweel (U+0640);
  - folds أإآ→ا, ة→ه, ى→ي;
  - converts digits to Latin and lowercases Latin;
  - collapses whitespace and trims.

  Tests in `test/core/utils/arabic_normalize_test.dart` cover each rule and idempotence.
- [X] T020 [P] `lib/core/utils/id.dart`: `IdGenerator` interface and `UuidV7Generator` (lowercase canonical
  UUID v7 via uuid 4.6.0). Tests in `test/core/utils/id_test.dart`: regex, lowercase, ordering across 1,000 ids.
- [X] T021 [P] `lib/core/utils/clock.dart`: `Clock` with `nowUtc()`, `SystemClock`, and `FixedClock(DateTime utc)`,
  which asserts the time is UTC. Tests in `test/core/utils/clock_test.dart`.
- [X] T022 [P] `lib/core/utils/text_length.dart`: `codePointLength(String) = s.runes.length` (matches
  SQLite `length()`). Tests in `test/core/utils/text_length_test.dart` include emoji and Arabic.
- [X] T023 Phase gate: `flutter analyze` and `flutter test` green. Report and STOP.

**Checkpoint**: utilities are ready and the no-double rule passes.

---

## Phase 3: Schema v1 (Foundational)

**Purpose**: all 17 tables from data-model.md, plus triggers, seeds and migrations from v1.

- [X] T024 [P] `lib/core/database/schema_constants.dart`: `const int kSchemaVersion = 1;`,
  `const int kAppApplicationId = 0x44414641;`, `const String kDatabaseFileName = 'daftar_afandi.sqlite';`.
- [X] T025 [P] `lib/core/database/converters/utc_millis_converter.dart`: a `TypeConverter<DateTime, int>`
  that stores UTC epoch milliseconds and rejects non-UTC input.
- [X] T026 [P] `lib/core/database/tables/enums.dart`: Dart enums for `textEnum`, with these exact values:
  - LocaleCode `ar`, `en`;
  - DigitStylePreference `follow`, `arabic`, `latin`;
  - NegativeStockPolicy `warn`, `block`;
  - UnitType `piece`, `kg`, `liter`, `meter`;
  - PaymentMethod `cash`, `wallet`, `instapay`, `card`;
  - DocType `SALE`, `SALE_RETURN`, `PURCHASE`, `EXPENSE`, `CUSTOMER_RECEIPT`, `SUPPLIER_PAYMENT`;
  - MovementType `OPENING`, `PURCHASE`, `PURCHASE_VOID`, `SALE`, `SALE_RETURN`, `SALE_VOID`, `ADJUSTMENT`;
  - AdjustmentReason `damage`, `count`, `other`;
  - CustomerEntryType `OPENING_BALANCE`, `SALE`, `PAYMENT_RECEIVED`, `SALE_RETURN`, `REFUND_PAID`,
    `SALE_VOID`, `ADJUSTMENT`, `REVERSAL`;
  - SupplierEntryType `OPENING_BALANCE`, `PURCHASE`, `PAYMENT_MADE`, `PURCHASE_VOID`, `ADJUSTMENT`, `REVERSAL`.
- [X] T027 [P] Tables `lib/core/database/tables/app_settings_table.dart` and `counters_table.dart`, exactly per
  data-model.md:
  - app_settings:
    - `singleton INTEGER DEFAULT 1 UNIQUE CHECK (singleton = 1)`;
    - `shopName` nullable; `shopPhone` nullable with `CHECK (shopPhone IS NULL OR shopPhone GLOB '[+0-9]*')`;
    - `shopAddress` and `invoiceFooter` nullable;
    - `localeCode DEFAULT 'ar'`, `digitStyle DEFAULT 'follow'`, `negativeStockPolicy DEFAULT 'warn'`;
    - `appLockEnabled` and `biometricEnabled` `DEFAULT 0`;
    - `deviceId`, `onboardingCompletedAt` nullable, `createdAt`, `updatedAt`;
    - table CHECK `onboardingCompletedAt IS NULL OR (shopName IS NOT NULL AND length(trim(shopName)) BETWEEN 1 AND 60)`;
    - no `pinHash` or `pinSalt`.
  - counters: `docType` UNIQUE, `nextValue INTEGER CHECK (nextValue >= 1)`, `createdAt`, `updatedAt`.
- [X] T028 [P] Master tables in `lib/core/database/tables/`: `categories_table.dart`, `products_table.dart`,
  `customers_table.dart`, `suppliers_table.dart`, `expense_categories_table.dart`. Columns and CHECKs per
  data-model.md:
  - products:
    - `salePricePiasters CHECK >= 0`; `avgCostPiasters DEFAULT 0 CHECK >= 0`;
    - `barcode` nullable; `categoryId` FK → categories, nullable;
    - `unitType` UnitType; `lowStockThresholdMilli` nullable;
  - customers and suppliers: `name`, `searchKey`, `phone`, `address` and `note` nullable; **no** `creditLimitPiasters`;
  - every master table has `createdAt`, `updatedAt` and `archivedAt` (nullable);
  - every FK is `ON DELETE RESTRICT`.
- [X] T029 [P] Sales tables in `lib/core/database/tables/`:
  - `sales_invoices_table.dart`:
    - `number` UNIQUE; `customerId` FK nullable;
    - `discountPiasters DEFAULT 0`; `paymentMethod NOT NULL DEFAULT 'cash'`;
    - `createdAt`, `updatedAt`, `voidedAt`, `voidReason`;
    - CHECKs: `0 <= discount <= subtotal`, `total = subtotal - discount`, `0 <= paid <= total`,
      `paid = total OR customerId IS NOT NULL`, `(voidedAt IS NULL) = (voidReason IS NULL)`;
  - `sale_items_table.dart`:
    - `UNIQUE(salesInvoiceId, lineNo)`; `productNameSnapshot`, `unitTypeSnapshot`;
    - `qtyMilli > 0`, `unitPricePiasters >= 0`, `discountPiasters` 0..gross;
    - `lineTotalPiasters`, `invoiceDiscountSharePiasters`, `unitCostPiasters`, `lineCostPiasters`;
  - `sale_returns_table.dart`:
    - `number` UNIQUE;
    - `refundPaidPiasters` 0..total, and `= total OR customerId IS NOT NULL`;
    - `paymentMethod NOT NULL DEFAULT 'cash'`; no voidedAt;
  - `sale_return_items_table.dart`: `qtyMilli > 0`.
- [X] T030 [P] Purchase tables: `lib/core/database/tables/purchase_invoices_table.dart` and `purchase_items_table.dart`.
  - purchase_invoices: `paymentMethod NOT NULL DEFAULT 'cash'`, `updatedAt`, `voidedAt`, `voidReason`;
    CHECKs mirror sales, including `paid = total OR supplierId IS NOT NULL`;
  - purchase_items: `productNameSnapshot`, `UNIQUE(purchaseInvoiceId, lineNo)`, `qtyMilli > 0`,
    `netLineCostPiasters`, `avgCostBeforePiasters`, `avgCostAfterPiasters`.
- [X] T031 [P] `lib/core/database/tables/stock_movements_table.dart`:
  - `qtyDeltaMilli CHECK != 0`;
  - the per-type CHECK table from data-model.md, exactly (OPENING +, no source; PURCHASE purchaseItemId +;
    PURCHASE_VOID purchaseItemId + reversesMovementId −; SALE saleItemId −; SALE_RETURN saleReturnItemId +;
    SALE_VOID saleItemId + reversesMovementId +; ADJUSTMENT adjustmentReason ±);
  - `adjustmentReason IS NOT NULL` only when the type is ADJUSTMENT;
  - `reversesMovementId` is a self-FK.
- [X] T032 [P] Ledger tables: `lib/core/database/tables/customer_ledger_table.dart` and `supplier_ledger_table.dart`.
  - `amountPiasters CHECK != 0`; `receiptNumber` / `paymentNumber` nullable, partial UNIQUE;
    `reversesEntryId` self-FK;
  - **nullable** `paymentMethod`;
  - customer CHECK `(entryType IN ('PAYMENT_RECEIVED','REFUND_PAID')) = (paymentMethod IS NOT NULL)`;
  - supplier CHECK `(entryType = 'PAYMENT_MADE') = (paymentMethod IS NOT NULL)` (deviation D2).
- [X] T033 [P] `lib/core/database/tables/expenses_table.dart`: `number` UNIQUE, `expenseCategoryId` FK NOT NULL,
  `amountPiasters CHECK > 0`, `spentAt`, `note`, `createdAt`, `updatedAt`, `voidedAt`, `voidReason`.
  No paymentMethod.
- [X] T034 `lib/core/database/schema_sql.dart`: one ordered list of SQL strings. It contains:
  - all indexes from data-model.md, including the partial UNIQUEs on searchKey, barcode,
    receiptNumber and paymentNumber;
  - `trg_<table>_no_delete` on all 17 tables;
  - `trg_<table>_immutable` on sale_items, sale_returns, sale_return_items, purchase_items,
    stock_movements, customer_ledger and supplier_ledger;
  - `trg_<table>_void_only` on sales_invoices, purchase_invoices and expenses. It aborts when
    `OLD.voidedAt IS NOT NULL OR NEW.voidedAt IS NULL OR NEW.voidReason IS NULL`, or when any other
    column changes (`NEW.x IS NOT OLD.x`);
  - `trg_sale_return_items_qty_ceiling`.
- [X] T035 [P] `lib/core/database/transaction_runner.dart`: an interface `TransactionRunner { Future<T> run<T>(Future<T> Function() action); }`
  and a `DriftTransactionRunner(AppDatabase)`.
- [X] T036 [P] `lib/core/database/daos/settings_dao.dart`: `getSingleton()`, `watchSingleton()`, and
  `updateSingleton(companion)`, which asserts that exactly 1 row is affected. It has no insert and no delete.
- [X] T037 `lib/core/database/app_database.dart`:
  - `@DriftDatabase` with all 17 tables and `SettingsDao`; `schemaVersion => kSchemaVersion`;
  - the constructor takes `(QueryExecutor, IdGenerator, Clock)`;
  - `onCreate`, in order: `PRAGMA application_id = kAppApplicationId`, `createAll()`, the `schema_sql.dart`
    statements, the 6 counters rows (`nextValue = 1`), and one app_settings row (new id, new `deviceId`,
    defaults, `shopName` NULL);
  - `onUpgrade` throws `SchemaTooNewException(from, to)` when `from > to`; otherwise it uses `stepByStep`
    (no steps yet);
  - `beforeOpen` runs `PRAGMA foreign_keys = ON`;
  - no `journal_mode` pragma (rollback journal, A1);
  - verify whether Drift 2.35.1 runs `onCreate` in a transaction, and wrap it explicitly if not (risk K4).

  Also `lib/core/database/schema_errors.dart` with `SchemaTooNewException`.
- [X] T038 [P] `lib/core/database/connection.dart`: `QueryExecutor openAppDatabaseExecutor()` =
  `driftDatabase(name: 'daftar_afandi', native: DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory))`.
- [X] T039 Run `dart run build_runner build --delete-conflicting-outputs`, then `dart run drift_dev make-migrations`.
  Confirm that `drift_schemas/app_database/drift_schema_v1.json` and the files under `test/drift/` were created,
  and report the generated file names.
- [X] T040 [P] `test/core/database/schema_test.dart` (temp-file DB) checks:
  - all 17 tables exist;
  - `PRAGMA application_id` = 0x44414641; `user_version` = 1;
  - `journal_mode` = `delete`; `foreign_keys` = 1.
- [X] T041 [P] `test/core/database/seeds_test.dart` checks:
  - 6 counters rows with `nextValue` 1;
  - exactly one app_settings row: `localeCode` `ar`, `digitStyle` `follow`, NULL `shopName` and
    `onboardingCompletedAt`, a UUID v7 `deviceId`;
  - a second app_settings insert fails.
- [X] T042 [P] `test/core/database/triggers_test.dart` checks:
  - DELETE aborts on every table;
  - UPDATE aborts on every immutable table;
  - a voidable header accepts exactly one void (NULL → set, together with `updatedAt`) and rejects
    re-void, un-void and any other column change;
  - the sale-return qty ceiling aborts over-returns.
- [X] T043 [P] `test/core/database/trigger_coverage_test.dart`: for each immutable and voidable table, read
  `PRAGMA table_info` and assert that every non-void column name appears in its trigger SQL (meta-test, research R14).
- [X] T044 [P] `test/core/database/constraints_test.dart` covers each CHECK in data-model.md:
  - app_settings onboarded without a name is rejected, and a 61-code-point name is rejected;
  - a phone with letters is rejected;
  - each stock_movements per-type rule;
  - ledger paymentMethod required exactly on payment rows;
  - sales/purchase header money CHECKs;
  - expenses `amountPiasters > 0`.
- [X] T045 [P] `test/core/database/counters_test.dart`: `UPDATE counters SET nextValue = nextValue + 1 … RETURNING nextValue - 1`
  returns 1, 2, 3 in a transaction; a rolled-back transaction doesn't consume a number.
- [X] T046 Phase gate: `flutter analyze` and `flutter test` green, including the generated `test/drift/` tests.
  Report and STOP.

**Checkpoint**: the whole MVP schema exists and is protected by triggers.

---

## Phase 4: Startup guard and bootstrap (Foundational, FR-018)

**Purpose**: the database is never opened when the file is newer or foreign (contracts/startup-guard.md).

- [X] T047 `lib/core/database/schema_guard.dart`, pure `dart:io` with no package imports:
  - the sealed `SchemaInspection` (`SchemaFresh`, `SchemaOk`, `SchemaTooNew`, `SchemaUnrecognized(reason)`);
  - `FileSchemaGuard.inspect(path)` opens with `FileMode.read`, reads at most the first 100 bytes, and
    implements the decision table in the contract exactly (magic `SQLite format 3\0`, user_version as
    big-endian int32 at offset 60, application_id at offset 68).
- [X] T048 [P] `test/core/database/schema_guard_test.dart` builds byte-level fixtures in a temp dir:
  - cases: absent, 0 bytes, 50 bytes, bad magic, appId 0x12345678, appId 0 with version 3,
    versions 0/1 → Ok, version 2 → TooNew;
  - each case asserts that the file's bytes, length and modified time are unchanged afterwards, and that
    no `-journal`, `-wal` or `-shm` sibling was created.
- [X] T049 Add ARB keys to `lib/core/l10n/arb/app_ar.arb` and `app_en.arb`: `updateRequiredTitle`,
  `updateRequiredBody`, `dataUnrecognizedBody` and `startupErrorBody`, in Arabic and English. The Arabic body
  says that the data was made by a newer version and asks the owner to update the app.
- [X] T050 [P] `lib/core/widgets/update_required_app.dart`:
  - `UpdateRequiredApp({required UpdateRequiredKind kind})` (`tooNew` / `unrecognized`);
  - a material_ui `MaterialApp` with Arabic locale only and RTL, and the delegates
    `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]`;
  - one screen with a title and the kind's body; no navigation, no buttons, no data access.
- [X] T051 [P] `lib/core/widgets/startup_error_app.dart`: the same shell, showing `startupErrorBody`.
- [X] T052 `lib/core/di/service_locator.dart`: `Future<void> configureDependencies({required QueryExecutor executor})`.
  It registers `Clock` (`SystemClock`), `IdGenerator` (`UuidV7Generator`), `AppDatabase`, `TransactionRunner`
  and `SettingsDao` with get_it. Nothing is registered before the guard runs.
- [X] T053 `lib/bootstrap.dart`: `Future<void> bootstrap({required void Function(Widget) runAppFn, SchemaGuard? guard,
  Future<Directory> Function()? supportDir, QueryExecutor Function(Directory)? executorFactory})`. Steps:
  1. portrait lock via `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`;
  2. resolve the path;
  3. run the guard;
  4. `tooNew`/`unrecognized` → `runAppFn(UpdateRequiredApp)` and return;
  5. otherwise configure DI and read the settings singleton once (this opens and migrates the DB);
  6. any error → `StartupErrorApp`, and `SchemaTooNewException` → `UpdateRequiredApp(tooNew)`;
  7. on success, `runAppFn` a temporary placeholder app. Phase 5 replaces it with `App`.

  `lib/main.dart` calls `bootstrap(runAppFn: runApp)`.
- [X] T054 `test/bootstrap_test.dart` with a temp dir and a fake `runAppFn`:
  - fresh → app path chosen and the DB created at `<dir>/daftar_afandi.sqlite`;
  - a real v1 file → app path;
  - the same file with bytes 60–63 patched to `00 00 00 63` → `UpdateRequiredApp` chosen, `executorFactory`
    never called, and the SHA-256 of the file unchanged;
  - a foreign appId → `UpdateRequiredApp(unrecognized)`.
- [X] T055 Phase gate: `flutter analyze` and `flutter test` green. Report and STOP.

**Checkpoint**: FR-018 is enforced before any database object exists.

---

## Phase 5: Theme, fonts, l10n shell (Foundational)

**Purpose**: every visual token in `lib/core/theme`, the bundled font, full ARB files, and the app root.

- [X] T056 ASK the human before downloading. Then download from
  `https://raw.githubusercontent.com/google/fonts/main/ofl/ibmplexsansarabic/`:
  - `IBMPlexSansArabic-Regular.ttf` (235,924 B), `-Medium.ttf` (242,100 B), `-SemiBold.ttf` (244,616 B),
    `-Bold.ttf` (246,992 B) and `OFL.txt` (4,456 B), into `assets/fonts/`;
  - verify each byte size, and report SHA-256 values.
- [X] T057 [P] Verify `assets/images/logo.png` exists (placed by the owner, A5) and record its dimensions
  (expected 799×1024 RGBA, 897,908 B). Copy nothing; never read any file from another project.
- [X] T058 Add to the `pubspec.yaml` `flutter:` section:
  - `assets: [assets/images/logo.png, assets/fonts/OFL.txt]`;
  - `fonts: - family: IBMPlexSansArabic` with weights 400/500/600/700 mapped to the four files.

  Run `flutter pub get`.
- [X] T059 Verify glyph coverage with a throwaway scratchpad script (fontTools, if it's installed; otherwise
  report that it was skipped): `0-9`, `٠-٩`, `A-Z`, `a-z`, `+`, `٫` (U+066B), `٬` (U+066C), `ج`, `.`, `م`
  in all four files. Report the results.
- [X] T060 [P] `lib/core/theme/app_colors.dart`: `lightScheme` and `darkScheme` =
  `ColorScheme.fromSeed(seedColor: Color(0xFF326CE9), brightness: …)`, plus a `ThemeExtension` for any
  extra semantic colors (none required yet).
- [X] T061 [P] `lib/core/theme/app_typography.dart`: a `TextTheme` built with `fontFamily: 'IBMPlexSansArabic'`,
  sizes in logical px, weights limited to 400/500/600/700. Never `.sp`.
- [X] T062 [P] `lib/core/theme/app_spacing.dart` and `app_radii.dart`:
  - design-px values (xs 4, sm 8, md 16, lg 24, xl 32; radii sm 8, md 12, lg 16);
  - a scale helper = `ScreenUtil().scaleWidth.clamp(0.85, 1.20)`;
  - `maxContentWidth = 600`.
- [X] T063 `lib/core/theme/app_tokens.dart`: `AppTokens extends ThemeExtension<AppTokens>` (spacing, radii,
  maxContentWidth) with `copyWith`/`lerp`, plus a `BuildContext.tokens` extension.
  Also `lib/core/theme/app_theme.dart`: `ThemeData appLightTheme()` / `appDarkTheme()` using the colors,
  typography and tokens.
- [X] T064 [P] `lib/core/theme/font_license.dart`: `registerFontLicenses()` adds
  `LicenseEntryWithLineBreaks(['IBM Plex Sans Arabic'], await rootBundle.loadString('assets/fonts/OFL.txt'))`
  to `LicenseRegistry`. Call it from `bootstrap()` step 1.
- [X] T065 Fill `lib/core/l10n/arb/app_ar.arb` (template, with `@key` descriptions) and `app_en.arb` with **every**
  key listed in contracts/routes-and-screens.md. The Arabic text is natural Egyptian-friendly MSA. No
  string mentions a tax receipt or tax invoice (FR-017). Run `flutter gen-l10n`.
- [X] T066 `lib/app.dart`: `App` is a material_ui `MaterialApp.router` with:
  - `localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]`;
  - `supportedLocales: [Locale('ar'), Locale('en')]`, `locale` from a parameter for now;
  - `theme`/`darkTheme` from `app_theme.dart` and `themeMode: ThemeMode.system`;
  - wrapped in `ScreenUtilInit(designSize: Size(420, 812))`;
  - `routerConfig` = a temporary single-route `GoRouter` in `lib/core/router/app_router.dart`.

  Also switch the T053 success path to `App`, and update `UpdateRequiredApp` and `StartupErrorApp` to use the
  theme and tokens.
- [X] T067 [P] `test/app/delegates_test.dart`: with locale `ar`, `MaterialLocalizations.of(context)` (material_ui)
  returns Arabic strings (e.g. `okButtonLabel`), and the widget tree uses material_ui's type.
- [X] T068 [P] `test/app/text_scale_test.dart`: pump `App` inside `MediaQuery(textScaler: TextScaler.linear(2.0))`
  and assert that `MediaQuery.textScalerOf` under the router is still 2.0 (FR-016).
- [X] T069 [P] `test/l10n/arb_test.dart`: the two ARB files have identical key sets and no empty values; neither
  contains "tax receipt", "tax invoice", "فاتورة ضريبية" or "إيصال ضريبي".
- [X] T070 [P] `test/core/theme/theme_test.dart`: light and dark schemes derive from 0xFF326CE9; `AppTokens` is
  present in both themes; the font family is `IBMPlexSansArabic`.
- [X] T071 Phase gate: `flutter analyze` and `flutter test` green. Report and STOP.

**Checkpoint**: the app root is ready; screens can now be built using only tokens and ARB strings.

---

## Phase 6: Settings domain and data (Foundational for US1 and US4)

**Purpose**: contracts/settings-and-state.md: entities, repository and Cubits.

- [X] T072 [P] `lib/features/settings/domain/app_locale.dart`: `enum AppLocale { ar, en }` and
  `enum DigitStylePreference { followLanguage, arabicIndic, latin }`.
- [X] T073 [P] `lib/features/settings/domain/shop_profile.dart`:
  - `ShopProfile` (Equatable) {name, phone?};
  - `static Result<ShopProfile, ShopProfileError> create(String rawName, String rawPhone)`;
  - name: trim; "1–60 code points" (`codePointLength`);
  - phone: delegates to `parseShopPhone` (empty → null);
  - `enum ShopProfileError { nameRequired, nameTooLong, phoneInvalidCharacters, phoneTooShort, phoneTooLong }`.
- [X] T074 [P] `lib/features/settings/domain/app_settings.dart`: `AppSettings` (Equatable) {locale, digitStyle,
  shop?, onboardingCompleted} with `effectiveDigitStyle` (`followLanguage`: ar → arabicIndic, en → latin).
- [X] T075 [P] `lib/features/settings/domain/app_version.dart`: `AppVersion {name, build}`, with
  `display => '$name ($build)'` (always Latin), and `abstract interface class AppVersionSource { Future<AppVersion> read(); }`.
- [X] T076 [P] `lib/features/settings/domain/settings_repository.dart`: the interface from the contract
  (`load`, `watch`, `setLocale`, `setDigitStyle`, `saveShopProfile`, `completeOnboarding`) and
  `SettingsWriteFailure`.
- [X] T077 `lib/features/settings/data/settings_repository_impl.dart`:
  - `SettingsRepositoryImpl(SettingsDao, TransactionRunner, Clock)` with row ↔ entity mapping;
  - `completeOnboarding` = ONE `TransactionRunner.run` that updates `shopName`, `shopPhone`,
    `onboardingCompletedAt` and `updatedAt`;
  - storage errors are wrapped in `SettingsWriteFailure`.
- [X] T078 [P] `lib/features/settings/data/package_info_app_version_source.dart`: implements `AppVersionSource`
  via `PackageInfo.fromPlatform()`.
- [X] T079 `lib/features/settings/presentation/cubits/app_preferences_cubit.dart`:
  - state = `AppSettings`;
  - subscribes to `repository.watch()`;
  - `changeLocale` and `changeDigitStyle` write through the repository.
- [X] T080 `lib/features/settings/presentation/cubits/shop_profile_form_cubit.dart` and `shop_profile_form_state.dart`:
  - `ShopProfileFormMode { onboarding, settings }`;
  - state {nameInput, phoneInput, nameError?, phoneError?, status: idle/saving/saved/failed};
  - `nameChanged`, `phoneChanged`, `validate()` (no write), and `submit()`, which calls
    `completeOnboarding` (onboarding) or `saveShopProfile` (settings);
  - a failure keeps the inputs.
- [X] T081 Register `SettingsRepository`, `AppVersionSource` and the Cubit factories in
  `lib/core/di/service_locator.dart`. Load `AppVersion` once in `bootstrap()` and pass it down.
- [X] T082 [P] `test/features/settings/domain/shop_profile_test.dart`: every error, the 60/61 code-point boundary,
  trim, an Arabic-digit phone normalized.
- [X] T083 [P] `test/features/settings/data/settings_repository_impl_test.dart` on `NativeDatabase.memory()`
  and a temp file:
  - load defaults; set locale and digit style;
  - `completeOnboarding` atomic: a forced DAO failure leaves `onboardingCompletedAt` NULL;
  - values persist after close and reopen of the temp file (SC-003).
- [X] T084 [P] `test/features/settings/presentation/app_preferences_cubit_test.dart` (bloc_test + mocktail): the stream
  updates the state; `changeLocale` calls the repository.
- [X] T085 [P] `test/features/settings/presentation/shop_profile_form_cubit_test.dart`: validation errors, submit success
  in both modes, a failure keeping inputs.
- [X] T086 Phase gate: `flutter analyze` and `flutter test` green. Report and STOP.

**Checkpoint**: settings state is persisted and reactive.

---

## Phase 7: First run and router — User Story 1 (P1) 🎯 MVP and User Story 2 (P1)

**Goal US1**: a new owner completes welcome → shop details → data screen → Home, and the result persists.
**Goal US2**: the data-and-backup explanation shows the right platform text.

**Independent Test**: install fresh, complete first run, kill and relaunch: Home opens and settings
show the same shop data. On Android and iOS (target-platform override in tests) the data screen
shows the matching text.

- [X] T087 [P] [US1] `lib/core/router/route_names.dart`: path constants `/welcome`, `/onboarding/shop`,
  `/onboarding/data`, `/home`, `/sales`, `/parties`, `/purchases`, `/reports`, `/settings`, `/settings/shop`,
  `/settings/data`. Also `lib/core/router/stream_listenable.dart` (adapts a `Stream` to a `Listenable`).
- [X] T088 [US1] `lib/core/router/app_router.dart`: `GoRouter createAppRouter(AppPreferencesCubit prefs)`:
  - `initialLocation: '/welcome'`;
  - a single `redirect` that implements the contract's matrix (not onboarded → only `/welcome` and
    `/onboarding/*`; onboarded → never those, go to `/home`), with `refreshListenable` driven by the cubit stream;
  - the onboarding routes are under a `ShellRoute` that provides one `ShopProfileFormCubit(mode: onboarding)`
    for both steps;
  - a `/home` route to a temporary `HomeScreen` (completed in Phase 8).
- [X] T089 [P] [US1] `lib/core/widgets/digit_style_scope.dart`: an `InheritedWidget` holding the effective
  `DigitStyle`, with `context.digits(String latin)` → `applyDigitStyle`.
  Also `lib/core/widgets/code_point_length_formatter.dart`, a `TextInputFormatter` that limits to N code points.
- [X] T090 [US1] Update `lib/app.dart`:
  - a `BlocProvider<AppPreferencesCubit>` above `MaterialApp.router`;
  - `locale` from the cubit state; `DigitStyleScope` from `effectiveDigitStyle`;
  - the router from `createAppRouter`;
  - content wrapped in a centered `ConstrainedBox(maxWidth: context.tokens.maxContentWidth)` builder.
- [X] T091 [US1] `lib/features/onboarding/presentation/welcome_screen.dart`:
  - the logo (`Image.asset('assets/images/logo.png')`) inside `Semantics(label: l10n.logoSemantics)`;
  - `appName`, `welcomeTitle` and `welcomeBody`;
  - a visible Arabic / English `SegmentedButton` that calls `AppPreferencesCubit.changeLocale` immediately;
  - Continue → `/onboarding/shop`;
  - scrollable at 200% text; tokens only.
- [X] T092 [US1] `lib/features/onboarding/presentation/shop_details_step_screen.dart`:
  - name field with `CodePointLengthFormatter(60)`;
  - phone field: optional, `TextInputType.phone`, accepts Arabic and Latin digits;
  - errors from `ShopProfileFormCubit` mapped to the ARB keys `errorShopNameRequired`, `errorShopNameTooLong`,
    `errorPhoneInvalid`, `errorPhoneTooShort` and `errorPhoneTooLong`;
  - Continue calls `validate()` and navigates to `/onboarding/data` only when valid.
- [X] T093 [US2] `lib/features/settings/presentation/data_safety_screen.dart`:
  - `DataSafetyScreen({required DataSafetyMode mode})` (`onboarding` / `settings`);
  - body `dataSafetyLocalOnly`, plus `dataSafetyAndroidBackup` when `defaultTargetPlatform == TargetPlatform.android`,
    or `dataSafetyIosManual` when `iOS`;
  - in onboarding mode: Finish → `ShopProfileFormCubit.submit()`. On success the redirect goes to `/home`;
    on failure it shows `errorSaveFailed` and keeps the inputs;
  - in settings mode: a back button only.
- [X] T094 [P] [US1] `test/core/router/router_redirect_test.dart`: the redirect matrix for every route in both states,
  and a restart while not onboarded lands on `/welcome`.
- [X] T095 [P] [US1] `test/features/onboarding/welcome_screen_test.dart`:
  - the default is Arabic and RTL even with the platform locale `en`;
  - tapping English switches immediately and persists (repository mock verify);
  - the logo semantics label is present in both languages.
- [X] T096 [P] [US1] `test/features/onboarding/shop_details_step_screen_test.dart`:
  - empty and spaces-only names block Continue, with the message in the active language;
  - a 61st code point can't be typed;
  - an empty phone is allowed; `٠١٠ ١٢٣٤-٥٦٧٨` is accepted.
- [X] T097 [P] [US2] `test/features/settings/data_safety_screen_test.dart`: `debugDefaultTargetPlatformOverride` android
  → Android text, iOS → iOS text, in ar and en; settings mode has no Finish.
- [X] T098 [US1] `test/features/onboarding/onboarding_flow_test.dart` (in-memory DB, real repository):
  - the full flow ends on Home with `onboardingCompletedAt` set;
  - an interrupted flow, after re-pump, restarts at `/welcome` in the language chosen before;
  - every onboarding screen at `TextScaler.linear(2.0)` in light and dark, ar and en, shows no
    overflow (no `FlutterError` overflow reported).
- [X] T099 Phase gate: `flutter analyze` and `flutter test` green; run the app on the Android emulator and
  report the first-run time. Report and STOP.

**Checkpoint**: MVP: first run works end to end and persists (US1 and US2).

---

## Phase 8: Shell, placeholders, settings UI — User Story 3 (P2) and User Story 4 (P2)

**Goal US3**: five sections in the order Home, Sales, Customers & Suppliers, Purchases, Reports, each with an explanatory placeholder.
**Goal US4**: settings for shop details, language, digit style, about your data, and the app version.

**Independent Test**: tap all five sections in ar and en; change every setting, relaunch, and confirm
each setting is kept and applied (shop name as typed, version in Latin digits).

- [ ] T100 [P] [US3] `lib/core/widgets/section_placeholder.dart`: `SectionPlaceholder({required IconData icon, required String title, required String body})`.
  Tokens only, scrollable, no sample data.
- [ ] T101 [US3] `lib/core/widgets/app_shell_scaffold.dart`:
  - takes a `StatefulNavigationShell` and shows a `NavigationBar` with 5 destinations (labels `navHome`,
    `navSales`, `navParties`, `navPurchases`, `navReports`, in that order);
  - an app bar with a settings `IconButton` (`tooltip`/semantics `openSettingsSemantics`) that pushes `/settings`.
- [ ] T102 [P] [US3] Placeholder screens, each a `SectionPlaceholder` with its own `placeholder…Title/Body` keys:
  - `lib/features/home/presentation/home_screen.dart` (replaces the temporary one);
  - `lib/features/sales/presentation/sales_screen.dart`;
  - `lib/features/customers/presentation/parties_screen.dart`;
  - `lib/features/purchases/presentation/purchases_screen.dart`;
  - `lib/features/reports/presentation/reports_screen.dart`.
- [ ] T103 [US3] In `lib/core/router/app_router.dart`, add a `StatefulShellRoute.indexedStack` with 5 branches
  (`/home`, `/sales`, `/parties`, `/purchases`, `/reports`) using `AppShellScaffold`, keeping the redirects.
- [ ] T104 [US4] `lib/features/settings/presentation/settings_screen.dart`, with only these rows:
  - Shop details: name exactly as typed, phone via `ltrIsolate(context.digits(phone))`; opens `/settings/shop`;
  - Language: ar/en, via `changeLocale`;
  - Digit style: `digitStyleFollowLanguage` / `digitStyleArabic` (٠١٢٣) / `digitStyleLatin` (0123), via
    `changeDigitStyle`;
  - About your data: opens `/settings/data`;
  - App version: read-only `ltrIsolate(appVersion.display)`, **never** passed through `context.digits`.
- [ ] T105 [US4] `lib/features/settings/presentation/shop_profile_edit_screen.dart`:
  - uses `ShopProfileFormCubit(mode: settings)`, pre-filled from the settings;
  - the same fields and formatters as T092;
  - Save is blocked on an invalid name, and the stored name is kept;
  - on success it pops.
- [ ] T106 [US4] Add the `/settings`, `/settings/shop` and `/settings/data` routes (`DataSafetyScreen(mode: settings)`) in
  `lib/core/router/app_router.dart`, pushed above the shell.
- [ ] T107 [P] [US3] `test/features/shell/shell_navigation_test.dart`:
  - destinations are in the exact order; Home sits at the right edge in RTL and the left in LTR;
  - the selected destination is marked;
  - each section shows its own placeholder text and no list or sample data.
- [ ] T108 [P] [US4] `test/features/settings/settings_screen_test.dart`:
  - a language switch rebuilds to English LTR with no restart;
  - follow-language digits are Arabic-Indic in ar and Latin in en;
  - an explicit digit style survives a language switch, and choosing follow restores the default;
  - shop name `محل 23` renders exactly as typed under both digit styles while the phone follows the style;
  - the version renders `1.0.0 (1)` in Latin under Arabic-Indic.
- [ ] T109 [P] [US4] `test/features/settings/shop_profile_edit_screen_test.dart`: clearing the name blocks Save and keeps
  the old name; a valid edit persists through a temp-file DB reopen.
- [ ] T110 [P] [US4] `test/app/semantics_labels_test.dart`: for every screen in ar and en, every tappable widget and the
  logo has a non-empty semantics label (`SemanticsTester` / `tester.getSemantics`), per FR-020 and SC-008.
- [ ] T111 [P] [US3] `test/app/layout_stress_test.dart`: every screen (onboarding, the 5 sections, settings, shop edit,
  data, blocking apps) at 375×812 and 800×1280, `TextScaler.linear(2.0)`, light and dark, ar and en, with
  no overflow errors (SC-002).
- [ ] T112 Phase gate: `flutter analyze` and `flutter test` green; spot-check on the emulator. Report and STOP.

**Checkpoint**: all in-app stories (US1–US4) work.

---

## Phase 9: Platform — User Story 5 (P3), portrait, signing, validation

**Goal US5**: Android Auto Backup restores the data after a reinstall; older data is upgraded automatically.

**Independent Test**: quickstart.md "Android backup and restore": `bmgr backupnow`, uninstall,
reinstall: Home appears with the same shop details.

- [ ] T113 [P] [US5] Create `android/app/src/main/res/xml/data_extraction_rules.xml` with
  `<cloud-backup disableIfNoEncryptionCapabilities="false">` and `<device-transfer>`, each containing only
  `<include domain="file" path="daftar_afandi.sqlite" />`. There is no `-wal` entry (A1).
- [ ] T114 [P] [US5] Create `android/app/src/main/res/xml/full_backup_content.xml` with only
  `<include domain="file" path="daftar_afandi.sqlite" />`.
- [ ] T115 [US5] In `android/app/src/main/AndroidManifest.xml`, add to `<application>`:
  `android:allowBackup="true"`, `android:fullBackupContent="@xml/full_backup_content"` and
  `android:dataExtractionRules="@xml/data_extraction_rules"`.
- [ ] T116 [P] [US5] `test/platform/android_backup_rules_test.dart`: parse both XML files and the manifest as text, and
  assert that the only included path is `daftar_afandi.sqlite` in domain `file` and that all three manifest
  attributes are present.
- [ ] T117 [P] [US5] `test/core/database/older_schema_test.dart`: `SchemaOk(0..kSchemaVersion)` proceeds to open, and the
  generated `test/drift/` migration test from T039 runs. Add a TODO comment: from v2 on, the generated stepByStep
  tests cover US5-3.
- [ ] T118 Portrait lock (FR-019):
  - in `android/app/src/main/AndroidManifest.xml`, add `android:screenOrientation="portrait"` on `MainActivity`,
    and inside `<application>` add
    `<property android:name="android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY" android:value="true" />`
    (temporary Android 16 opt-out, risk K1);
  - in `ios/Runner/Info.plist`, set `UISupportedInterfaceOrientations` and `UISupportedInterfaceOrientations~ipad`
    to `UIInterfaceOrientationPortrait` only, and add `UIRequiresFullScreen` = true.
- [ ] T119 [P] Release signing:
  - `android/app/build.gradle.kts` loads `android/key.properties` with `java.util.Properties`, if it exists, and defines
    `signingConfigs.create("release")` (storeFile, storePassword, keyAlias, keyPassword);
  - `buildTypes.release` uses it;
  - a release task **fails** with a clear message when the file is missing; never fall back to debug;
  - remove the scaffold TODO and debug-signing lines;
  - create `android/key.properties.example` with placeholder values (`storePassword=CHANGE_ME`,
    `keyPassword=CHANGE_ME`, `keyAlias=upload`, `storeFile=C:\\Users\\<you>\\.keystores\\daftar-afandi-upload.jks`);
  - the agent does NOT create a keystore or handle passwords.
- [ ] T120 Run `flutter build apk --debug` and report the result. Confirm that a release build without
  `key.properties` fails as designed (`flutter build apk --release`); report the error text.
- [ ] T121 Re-run the lock-file audit from T003 and report any override whose "remove after" date has passed.
- [ ] T122 Run quickstart.md on the Android emulator: manual scenarios 1–13, "Android backup and restore",
  and "Newer-data block". Report each result as pass or fail with notes. List the iOS items and release
  signing as not verified on this machine.
- [ ] T123 Final gate: `flutter analyze` clean, `flutter test` green, `import_rules_test` passing. Report and STOP.
  The human commits.

**Checkpoint**: feature 001 is complete and validated.

---

## Dependencies & Execution Order

### Phase dependencies

- Phase 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9, strictly sequential: one `/speckit-implement` per phase, with human review between.
  - Phase 3 needs the Phase 2 id and clock (seeds).
  - Phase 4 needs the Phase 3 constants and AppDatabase.
  - Phase 5 needs the Phase 4 bootstrap.
  - Phase 6 needs the Phase 3 DAO and the Phase 2 utils.
  - Phase 7 needs Phases 5 and 6.
  - Phase 8 needs the Phase 7 router.
  - Phase 9 needs the complete app for validation.

### User story dependencies

- **US1** (Phase 7): needs Phases 1–6. MVP.
- **US2** (Phase 7): the data screen is part of the first-run flow, so it ships with US1. Its settings entry point arrives with US4.
- **US3** (Phase 8): needs the US1 router; independent of US4.
- **US4** (Phase 8): needs Phase 6 cubits and the US1 router; independent of US3 except for the settings icon in the shell.
- **US5** (Phase 9): needs the schema (Phase 3), the guard (Phase 4) and a working app.

### Within each phase

- Tasks without [P] run in ID order.
- [P] tasks touch different files and can run in any order or concurrently.
- The gate task always runs last.

## Parallel examples

```text
Phase 2: T013–T022 are all [P] (one util + its test per task).
Phase 3: T027–T033 (table files) together, then T034–T038, then T039, then T040–T045 together.
Phase 5: T060, T061, T062, T064 together after T058.
Phase 6: T072–T076 together, then T077–T081, then T082–T085 together.
Phase 7 (US1/US2): T094–T097 together after T093.
Phase 8 (US3/US4): T107–T111 together after T106.
Phase 9 (US5): T113, T114, T116, T117, T119 together.
```

## Implementation Strategy

### MVP first

1. Phases 1–6: foundation (no user-visible feature, everything tested).
2. Phase 7: US1 and US2. **STOP and validate**: a new owner completes first run in under 60 s, and it persists.

### Incremental delivery

3. Phase 8: US3 and US4 (navigation and settings).
4. Phase 9: US5 and platform hardening, then the full quickstart run.

Each phase is reviewed by the human before the next `/speckit-implement`.

## Notes

- [P] = different files, no dependency on incomplete tasks; [USn] = traceability to spec.md.
- Never commit; the human commits after reviewing each phase.
- Downloads (T056) and anything not covered here need explicit approval first.
- Avoid vague edits, same-file conflicts within a phase, and any package not listed in plan.md.
