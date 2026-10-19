# Implementation Plan: Foundation

**Branch**: `001-foundation` | **Date**: 2026-10-19 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-foundation/spec.md`

## Summary

This is the first runnable Daftar Afandi. It has:
- an Arabic-first RTL app shell on material_ui and go_router: first run (welcome with a language switch,
  then shop details, then data-and-backup), five placeholder sections, and settings (shop details,
  language, digit style, about your data, app version);
- the **full v1 Drift schema** for the whole MVP (17 tables, triggers, indexes, seeds) with
  make-migrations from v1;
- a pure-`dart:io` **schema guard** that reads the SQLite header before Drift opens the file and blocks
  newer or foreign data (FR-018);
- `core/utils` for money, quantity, digits, ids, clock and Arabic search normalization, with full tests;
- Android Auto Backup rules, a portrait lock, release-signing wiring, `.gitattributes`, and an
  import-rules test that enforces the constitution.

Technical choices and evidence are in [research.md](research.md). The schema is in
[data-model.md](data-model.md), and interfaces are in [contracts/](contracts/).

## Technical Context

**Language/Version**: Dart 3.13.5 on Flutter 3.47.7 stable

**Primary Dependencies**:
- runtime: material_ui 1.5.0, flutter_bloc 9.1.1, go_router 18.0.2, drift 2.35.1, drift_flutter 0.3.1,
  get_it 9.3.0, uuid 4.6.0, flutter_screenutil 5.9.3, intl 0.20.3, flutter_localizations (sdk),
  path_provider 2.1.6, package_info_plus 10.2.2, equatable 3.0.0;
- dev: build_runner 2.16.1, drift_dev 2.35.1, bloc_test 10.0.0, mocktail 1.0.5, flutter_lints 6.0.0;
- overrides: sqlite3 3.7.0, cupertino_ui 1.1.1, plus the audit results (approval A2).

The full table with publish dates is in research R2.

**Storage**: SQLite via Drift, `<ApplicationSupport>/daftar_afandi.sqlite`, rollback journal (A1),
`application_id` 0x44414641, `user_version` = schema version 1.

**Testing**: flutter_test, bloc_test + mocktail, Drift on `NativeDatabase.memory()` and temp files,
drift_dev generated migration tests, and a plain-Dart architecture test.

**Target Platform**: Android minSdk 24 / targetSdk 36; iOS 15+. Phones, portrait.

**Project Type**: mobile app (single Flutter project).

**Performance Goals**: cold start to first frame < 2 s on a mid-range phone; a language or digit change
re-renders in < 1 s (SC-004); first run < 60 s for a new user (SC-001).

**Constraints**:
- fully offline, with no network code (FR-015);
- the system text scale is never overridden (FR-016);
- the DB file is never written when it is newer or foreign (FR-018);
- integer-only money and quantities.

**Scale/Scope**: 11 screens (3 onboarding, 5 sections, 3 settings) plus 2 blocking apps; one settings
row in use; 17 tables prepared.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design (below).*

| Principle / rule | Status | Evidence / note |
|---|---|---|
| I. Local-first; no network code | PASS | No network package is used; the import test bans `http`, `dio`, `HttpClient`, `Socket` and `WebSocket`. Note: package_info_plus carries `http` transitively for its **web** impl only (R2). DB is in Application Support (Q20). |
| I. Sync-ready schema | PASS | UUID v7, UTC ms, archivedAt, append-only ledgers, `updatedAt` on voidable headers (Q16), `deviceId`. |
| II. Arabic-first; all strings in ARB | PASS | ar template, en second; a test checks key parity and literal `Text('…')`. The blocking screen is Arabic-only because the language preference is unreadable (FR-018). |
| II. Never "tax receipt" | PASS | An ARB grep test (contracts/routes-and-screens.md). |
| III. Integer money/qty, no double | PASS | INTEGER columns only; utils use `int`; a grep test. |
| III. UUID PK + separate sequential number | PASS | `counters` seeded, `UNIQUE(number)`, display-only prefixes. |
| III. Stock/balances derived; WAC cached only in products | PASS | data-model.md. |
| III. Immutability, no hard delete | PASS | Triggers on every table, plus a meta-test that the triggers cover all columns. |
| III. One transaction per financial op | PASS | `TransactionRunner`; the only multi-write here is `completeOnboarding`. |
| III. Sale line cost + name snapshot, WAC | PASS | Columns in v1 (flows come in later features). |
| III. Secrets not in DB | PASS | pinHash/pinSalt removed (Q8). |
| IV. Feature-first, strict layers | PASS | Structure below; enforced by import_rules_test. The guard lives in core/database and is called only from `main.dart`. |
| V. material_ui only; delegate rule | PASS | Import test plus a delegates test. flutter_screenutil imports legacy material internally (known, report §1.3; extensions only). |
| V. Approved packages only, exact pins, 14-day rule | **PASS with approvals** | A2: extra dev-only overrides; A3: remove `cupertino_icons` (not on the list). package_info_plus is approved for this feature by the user. |
| Technical rules (UTC ms, columns, paymentMethod) | PASS with **D2** | paymentMethod on ledger tables is nullable but required exactly on payment rows (data-model.md). |
| Schema via make-migrations + tests | PASS | Phase 3. |
| Quality gates (tests, analyze, test) | PASS | Every phase below ends green. |
| Workflow (one phase per implement, no commits, ask when unclear) | PASS | Approvals A1–A5 are listed rather than guessed. |

**Deviations from the report baseline** (not constitution violations, but they need sign-off):
- **D1 = A1**: rollback journal instead of WAL (R3).
- **D2**: nullable paymentMethod on ledgers.
- **D3**: `app_settings` reshaped: shopName nullable, `onboardingCompletedAt` added, `follow` digit style.
- **D4**: release builds fail without `key.properties` (as the report says), which replaces the scaffold's debug-signing TODO.

### Approvals needed before `/speckit-implement`

| Id | Question | Recommendation |
|---|---|---|
| A1 | Rollback journal instead of WAL, so the header check is exact? | Yes. Alternative: keep WAL and approve `sqlite3` as a direct dependency. |
| A2 | Add dependency_overrides for dev-only transitives that the lock audit finds too new (analyzer, source_gen, dart_style, build_daemon today), each with a "remove after" date? | Yes (or implement after 2026-10-29, when none is needed). |
| A3 | Remove `cupertino_icons` from pubspec? | Yes. |
| A4 | Data with a foreign application id or a corrupt header: the same blocking screen with a "can't open this data" message, file untouched? | Yes. |
| A5 | Is `E:\projects\Cardeil\assets\images\logo.png` the right logo? | Confirm. |

**Approved 2026-10-19 by the project owner: A1–A5 all as recommended.** Rollback journal (no WAL,
no direct sqlite3); dev-only overrides from the lock audit allowed, with "remove after" comments;
`cupertino_icons` removed; an unrecognized file gets the blocking screen with the "can't open this
data" message; the Cardeil logo is the correct one.

## Project Structure

### Documentation (this feature)

```text
specs/001-foundation/
├── plan.md              # this file
├── research.md          # Phase 0
├── data-model.md        # Phase 1: full schema v1
├── quickstart.md        # Phase 1: validation guide
├── contracts/
│   ├── startup-guard.md
│   ├── routes-and-screens.md
│   ├── settings-and-state.md
│   └── core-utils.md
├── checklists/requirements.md
└── tasks.md             # /speckit-tasks (not created here)
```

### Source Code (repository root)

```text
lib/
  main.dart                         # bootstrap: portrait, license, guard → UpdateRequiredApp | App
  app.dart                          # MaterialApp.router, delegates, ThemeMode.system, ScreenUtilInit
  core/
    database/
      app_database.dart             # @DriftDatabase(all tables, daos), migration, onCreate seeds
      schema_constants.dart         # kSchemaVersion, kAppApplicationId, kDatabaseFileName
      schema_guard.dart             # FR-018 header check (dart:io only)
      schema_sql.dart               # triggers + partial indexes (single source)
      tables/                       # one file per table (17)
      daos/settings_dao.dart        # only DAO needed now
      converters/utc_millis_converter.dart
      transaction_runner.dart
    di/service_locator.dart
    router/{app_router.dart, route_names.dart}
    theme/{app_colors.dart, app_typography.dart, app_spacing.dart, app_radii.dart, app_tokens.dart, app_theme.dart}
    l10n/{arb/app_ar.arb, arb/app_en.arb, generated/}
    utils/{money, quantity, digits, phone, arabic_normalize, id, clock, text_length, result}.dart
    widgets/{section_placeholder, app_shell_scaffold, digit_style_scope, code_point_length_formatter, update_required_app, startup_error_app}.dart
  features/
    onboarding/presentation/        # welcome_screen, shop_details_step_screen
    settings/{domain,data,presentation}/   # AppSettings, ShopProfile, repo, cubits, settings + shop edit + data-safety screens
    home/presentation/home_screen.dart
    sales/presentation/sales_screen.dart
    customers/presentation/parties_screen.dart
    purchases/presentation/purchases_screen.dart
    reports/presentation/reports_screen.dart
assets/
  fonts/IBMPlexSansArabic-{Regular,Medium,SemiBold,Bold}.ttf, OFL.txt
  images/logo.png
drift_schemas/app_database/drift_schema_v1.json
test/
  architecture/import_rules_test.dart
  core/utils/*_test.dart
  core/database/{schema_test, triggers_test, seeds_test, schema_guard_test}.dart
  drift/app_database/                # make-migrations output
  features/settings/{domain,data,presentation}/…
  features/onboarding/presentation/…
  app/{delegates_test, text_scale_test, router_redirect_test}.dart
android/app/src/main/res/xml/{data_extraction_rules.xml, full_backup_content.xml}
android/key.properties.example
.gitattributes  build.yaml  l10n.yaml
```

**Structure Decision**: a single Flutter app with feature-first folders (report §2). Tables and DAOs
live in `core/database`, so one database and one transaction can span features. Section features get
only `presentation/` placeholders now; their `domain` and `data` folders arrive with their features.

## Implementation phases (for tasks.md)

Each phase is one `/speckit-implement` run. It ends with `flutter analyze` clean and `flutter test`
green, then stops for human review. The agent never commits.

| Phase | Content | Done when |
|---|---|---|
| **1. Repo and dependencies** | `.gitattributes`; pubspec (exact pins, SDK constraints, overrides incl. A2, remove cupertino_icons, `generate: true`, assets and fonts entries); `l10n.yaml`; `build.yaml`; stricter `analysis_options.yaml`; iOS deployment target 15; replace the demo `main.dart` and `widget_test.dart` with a minimal material_ui app; first `import_rules_test`; lock-file date audit | the app launches to a blank material_ui screen; audit is clean |
| **2. core/utils** | money, quantity, digits, phone, arabic_normalize, id, clock, text_length, result, with the full tests from contracts/core-utils.md | utils coverage complete; no `double` |
| **3. Schema v1** | 17 tables, converters, `schema_sql.dart` triggers and partial indexes, seeds, `AppDatabase`, `TransactionRunner`, `SettingsDao`, build_runner, make-migrations v1 | schema, trigger (incl. meta), CHECK, seed and migration tests pass |
| **4. Startup guard and bootstrap** | `schema_constants`, `SchemaGuard`, DB location (Application Support), `main.dart` order, `UpdateRequiredApp`, `StartupErrorApp`, `onUpgrade` from > to guard, DI setup | guard tests incl. bytes-unchanged; the bootstrap selects the right app |
| **5. Theme, fonts, l10n shell** | download the fonts (asks first) and copy the logo; cmap check; tokens (`AppTokens` extension, light/dark from seed, typography, clamped spacing); LicenseRegistry; ARB ar/en with all keys; `app.dart` (delegates, ThemeMode.system, ScreenUtilInit) | delegates test, text-scale-untouched test, ARB parity and "no tax wording" tests |
| **6. Settings domain and data** | `AppSettings`, `ShopProfile`, `SettingsRepository` and impl, `AppPreferencesCubit`, `ShopProfileFormCubit` | bloc_test and repository tests (atomic onboarding, persistence across reopen) |
| **7. First run and router** | go_router with redirects, welcome (language switch), shop step, data-safety screen (platform text), completion → Home | widget tests: ar/en, 200% text, dark, interrupted-restart, redirect matrix |
| **8. Shell, placeholders, settings UI** | `StatefulShellRoute` with 5 destinations, `SectionPlaceholder`, settings screen, shop edit, version row (Latin), digit-style rendering via `DigitStyleScope` | widget tests: order and RTL, shop name as typed, version Latin, semantics labels on all controls |
| **9. Platform** | backup XMLs and manifest attributes, portrait lock (manifest, SystemChrome, iOS plist with `UIRequiresFullScreen`, Android 16 opt-out property), release signing in `build.gradle.kts` and `key.properties.example` | `flutter build apk --debug` succeeds; quickstart manual scenarios run on the emulator, with results reported |

## Risks

| Id | Risk | Mitigation |
|---|---|---|
| K1 | Android 16+ (API 36) ignores portrait on large screens; the opt-out is temporary. iPadOS 26 deprecates `UIRequiresFullScreen` | Opt-out now; a capped-width layout that works in landscape; tablet emulator check |
| K2 | flutter_screenutil is unmaintained and reads the deprecated `textScaleFactor` | Extensions used only inside tokens; vendor ~60 lines if it breaks |
| K3 | Transitive versions move daily | The lock audit in Phase 1 and before each commit; "remove after" comments |
| K4 | A crash between `onCreate` statements could leave a half-built file | Phase 3 verifies whether Drift 2.35.1 wraps `onCreate` in a transaction and wraps it explicitly if not; a `StartupErrorApp` fallback with no deletes |
| K5 | iOS can't be verified on Windows | Listed in quickstart; a Mac run is needed before release |

## Complexity Tracking

No constitution violations to justify. Deviations D1–D4 from the report baseline and approvals
A1–A5 are listed in the Constitution Check above.
