# Research: Foundation (001)

Date: 2026-10-19. 14-day cutoff: a pub version must be published on or before **2026-10-05**.
Baseline: `docs/research/M0-PHASE1-REPORT.md` §1–7, overridden by `docs/research/M0-DECISIONS.md`.
Everything below was checked today (pub.dev API, Flutter SDK source at `C:\src\flutter`,
Google Fonts metadata, Android developer docs). Items marked **APPROVAL** need a human decision
before implementation; everything else follows the binding inputs.

---

## R1. Toolchain

- **Decision**: Flutter 3.47.7 / Dart 3.13.5 (verified with `flutter --version`, revision abaf9c5237).
  `environment: sdk: ^3.13.5`, `flutter: ">=3.47.7 <3.48.0"`.
- **Rationale**: Decision Q1 (official stable SDK is exempt from the 14-day rule). material_ui 1.5.0
  needs `flutter >=3.47.0, sdk ^3.13.0`.
- **SDK facts used by the plan** (from the 3.47.7 source): `flutter.minSdkVersion = 24`,
  `targetSdkVersion = 36`, `compileSdkVersion = 36`; `flutter_localizations` requires `intl ^0.20.3`;
  `package:flutter/material.dart` still ships (needed by flutter_screenutil only).
- iOS scaffold currently has `IPHONEOS_DEPLOYMENT_TARGET = 13.0` → raised to **15.0** (Q5).

## R2. Packages (exact pins)

### Direct dependencies used by this feature

| Package | Pin | Published | Latest today | Note |
|---|---|---|---|---|
| material_ui | 1.5.0 | 2026-09-28 | 1.7.0 (10-14) | 1.6.0 (10-06) too new; 1.3.0 retracted |
| flutter_bloc | 9.1.1 | 2025-05-02 | same | brings bloc 9.2.1 + provider 6.1.5+1 |
| go_router | 18.0.2 | 2026-09-28 | 18.1.0 (10-14) | depends on material_ui ^1.0.0, cupertino_ui ^1.0.0 |
| drift | 2.35.1 | 2026-09-30 | 2.35.2 (10-07) | |
| drift_flutter | 0.3.1 | 2026-07-11 | same | |
| get_it | 9.3.0 | 2026-09-19 | same | |
| uuid | 4.6.0 | 2026-07-15 | same | `Uuid().v7()` |
| flutter_screenutil | 5.9.3 | 2024-05-31 | same | required pin; unmaintained (report R6) |
| intl | 0.20.3 | 2026-06-25 | same | matches flutter_localizations |
| flutter_localizations | sdk | — | — | |
| path_provider | 2.1.6 | 2026-06-15 | same | `getApplicationSupportDirectory()` (Q20) before the DB opens |
| package_info_plus | 10.2.2 | 2026-10-01 | same | FR-010 version display (approved for this feature) |
| equatable | 3.0.0 | 2026-09-15 | same | Cubit states / value objects (Q4) |

### Dev dependencies

| Package | Pin | Published | Latest today | Note |
|---|---|---|---|---|
| flutter_test | sdk | — | — | |
| build_runner | 2.16.1 | 2026-09-02 | 2.17.1 (10-14) | 2.16.2 (10-07) too new, 2.17.0 retracted |
| drift_dev | 2.35.1 | 2026-09-30 | same | `drift >=2.30.0 <2.36.0` ✓ |
| bloc_test | 10.0.0 | 2025-01-12 | same | |
| mocktail | 1.0.5 | 2026-04-10 | same | |
| flutter_lints | 6.0.0 | 2025-05-27 | same | |

### dependency_overrides (approved by Q3)

| Package | Pin | Published | Would resolve to | Comment to write |
|---|---|---|---|---|
| sqlite3 | 3.7.0 | 2026-09-30 | 3.7.1 (10-13) | `# remove after 2026-10-27` |
| cupertino_ui | 1.1.1 | 2026-09-21 | 1.1.3 (10-14) | `# remove after 2026-10-28` |

### Likely extra overrides — **A2 approved 2026-10-19**

These are dev-only transitives (via drift_dev / build_runner). Their constraints allow a version that
is newer than the cutoff today:

| Package | Safe pin (date) | Too new | Passes the rule on |
|---|---|---|---|
| analyzer | 14.4.0 (09-11) | 14.5.0 (10-06) | 2026-10-20 |
| source_gen | 4.3.0 (08-19) | 4.3.1 (10-14) | 2026-10-28 |
| dart_style | 3.1.13 (08-26) | 3.1.14 (10-15) | 2026-10-29 |
| build_daemon | 4.1.6 (09-02) | 4.1.7 (10-14) | 2026-10-28 |

Excluded by constraints (no action): build 5.0.0 (drift_dev needs `<5.0.0`), build_config 1.4.0
(build_runner needs `<1.4.0`). The authoritative list comes from the lock-file audit in
implementation Phase 1 (every `pubspec.lock` entry checked against the cutoff). If the
implementation runs on or after 2026-10-29, none of the four is needed.

### Approved but not used in this feature (not added now)

share_plus, local_auth, file_picker, flutter_secure_storage, crypto, flutter_launcher_icons,
flutter_native_splash. `pdf` remains unapproved.

### Removed from the scaffold — **A3 approved 2026-10-19**

`cupertino_icons ^1.0.8` (added by `flutter create`, not on the approved list, not needed:
icons come from material_ui's `Icons`). `uses-material-design: true` stays (Material Icons font).

### Transitive network package (noted, not a violation)

`package_info_plus 10.2.2` depends on `http ^1.6.0` for its **web** implementation only (registered
through the web plugin registrant, not compiled into Android/iOS builds). Our code never imports
it; `import_rules_test` forbids `package:http`, `package:dio`, `HttpClient`, `Socket`, and `WebSocket`
in `lib/`. Alternative considered: a build-time `--dart-define` for the version (no package);
rejected because the user approved package_info_plus and it reads the real installed build number.

## R3. Journal mode and the FR-018 newer-data check — **A1 approved 2026-10-19**

**Problem**: FR-018 requires detecting a newer schema *before* Drift opens the file, so the file is
never written. Drift's `setup`/migration code runs only after it has opened the file read-write.
`package:drift/native.dart` re-exports only `SqliteException` from sqlite3, so a read-only SQLite
connection would need `sqlite3` as a **direct** dependency.

**Decision (recommended)**: use SQLite's default **rollback journal (`journal_mode = DELETE`)**,
not WAL, and read the version straight from the file header with `dart:io`.

How the check works (`lib/core/database/schema_guard.dart`, pure `dart:io`, no package):

1. Resolve `<getApplicationSupportDirectory()>/daftar_afandi.sqlite` (the same path the database will use).
2. Missing file or 0 bytes → `fresh` (first install). Continue.
3. Open with `File.open(mode: FileMode.read)` (OS read-only handle; it cannot write), read the first
   100 bytes, close.
4. Less than 100 bytes, or bytes 0–15 ≠ `"SQLite format 3\0"` → `unrecognized`.
5. `applicationId` = big-endian int32 at offset 68; `userVersion` = big-endian int32 at offset 60.
   (SQLite file-format spec; Drift stores `schemaVersion` in `user_version`.)
6. `applicationId` ≠ 0 and ≠ `kAppApplicationId` → `unrecognized`.
   `applicationId` = 0 and `userVersion` ≠ 0 → `unrecognized` (not ours).
7. `userVersion` > `kSchemaVersion` → `tooNew`.
8. Otherwise → `ok` (0 = never migrated, < current = older, migrated by Drift `onUpgrade`).

`main()` runs the guard before get_it registers anything. For `tooNew` / `unrecognized` it calls
`runApp(UpdateRequiredApp(...))`, a minimal app that has **no** database object at all, so
nothing can write the file. `kSchemaVersion` and `kAppApplicationId` are plain `const int`s in
`lib/core/database/schema_constants.dart`, so the guard never constructs `AppDatabase`.

**Why the rollback journal**: with WAL, committed pages (including page 1 with `user_version`
after a migration) can sit in `daftar_afandi.sqlite-wal` until a checkpoint. The main file header
would then be stale, and the only correct readers are SQLite itself (needs the direct sqlite3
dependency) or a hand-written WAL parser. In rollback-journal mode, the main file always holds the
last committed state, so the 100-byte header is authoritative. It also simplifies Android backup to
**one** file (removes report risk R3: main + `-wal` snapshot mismatch, and the
checkpoint-on-pause workaround).

**Cost**: WAL's benefit is concurrent readers during a write. drift_flutter uses a single
background-isolate connection, so there is no concurrency to lose for a single-user app. Writes are
short user-initiated transactions.

**Defence in depth**: `MigrationStrategy.onUpgrade` throws `SchemaTooNewException` if `from > to`
before any statement runs, and the bootstrap maps it to the same blocking screen.

**Alternatives considered**:
- Keep WAL + add `sqlite3` as a direct dependency (already in the graph, pinned by override) and open
  it with `OpenMode.readOnly`. Correct, but needs a package approval, and a read-only open of a WAL
  database may create `-shm` side files. Acceptable fallback if A1 is rejected.
- Keep WAL + parse WAL frames for page 1 in Dart. Rejected: checksum/salt validation is complex and
  error-prone.
- Header-only check while keeping WAL. Rejected: wrong after a migration until the next checkpoint.

**Language on the blocking screen**: the language preference lives in the blocked database, so
it is unknown; FR-018 says Arabic then. The screen is Arabic-only (respects FR-003).

**`unrecognized` handling — A4 approved 2026-10-19**: the spec covers only "newer". Proposed: the same
blocking screen with a different Arabic message ("can't open this data"), file untouched.

## R4. Database location and Android Auto Backup

- **Decision**: `driftDatabase(name: 'daftar_afandi', native: DriftNativeOptions(databaseDirectory:
  getApplicationSupportDirectory))` (Q20). Android: `files/daftar_afandi.sqlite` → backup domain `file`.
- `res/xml/data_extraction_rules.xml` (API 31+) and `res/xml/full_backup_content.xml` (API 24–30):
  include only `daftar_afandi.sqlite` in both `cloud-backup` and `device-transfer`. With A1, no
  `-wal` entry; the transient `-journal` is excluded (only listed paths are backed up).
- Manifest: `android:allowBackup="true"`, `android:fullBackupContent`, `android:dataExtractionRules`.
- Restored data goes through the same guard on first launch (R3), which answers report R3's
  "restored DB is not version-checked" concern, and the older-data path migrates (FR-018).
- Android doesn't back up an app while it is in the foreground; writes happen only in the
  foreground on user action, so a snapshot of a half-written transaction is very unlikely.
- iOS finding: Application Support **is** included in iCloud/Finder device backups by default. The
  spec's iPhone message ("export manually") stays correct as advice: the app can't rely on or verify
  a device backup. No spec change proposed.

## R5. Schema v1 and make-migrations

- **Decision**: the whole MVP schema from report §3, amended by the decisions, is created in v1 (see
  `data-model.md`). `schemaVersion = 1`. `build.yaml` per report §3.4 (`schema_dir:
  drift_schemas/`, `test_dir: test/drift/`, sqlite dialect version `"3.45"`).
- After the first `build_runner build`: `dart run drift_dev make-migrations` exports
  `drift_schemas/app_database/drift_schema_v1.json` and scaffolds the migration test. Both are
  committed by the human, along with `*.g.dart` (Q21).
- Triggers and partial indexes are created by `customStatement` in `onCreate` from one list in
  `lib/core/database/schema_sql.dart`, so a later migration can re-create them from the same source.
- `application_id` is set by `PRAGMA application_id = kAppApplicationId` as the first statement in
  `onCreate`. `foreign_keys = ON` in `beforeOpen` on every connection.
- Seeds in `onCreate`: the 6 `counters` rows, and the single `app_settings` row (defaults:
  `ar`, `follow`, no shop name, onboarding not completed). Seeding the settings row at create time lets
  the welcome-screen language choice persist before the shop name exists (FR-002).

## R6. Font: IBM Plex Sans Arabic

- **Coverage verified** (Google Fonts `ofl/ibmplexsansarabic/METADATA.pb`): subsets `arabic`, `latin`,
  `latin-ext`, `cyrillic-ext`. Latin is included, so **no fallback font is needed**. Arabic-Indic digits
  (U+0660–0669) and the Arabic decimal and thousands separators are part of the `arabic` subset.
  Phase 5 includes a `fontTools` cmap check of the bundled files for `0-9`, `٠-٩`, `A-Z`, `a-z`, `+`,
  `٫`, `٬`, `ج.م` as a verification step.
- **Files** (from `github.com/google/fonts/tree/main/ofl/ibmplexsansarabic`, which builds from
  `googlefonts/plex`): Regular 400 (235,924 B), Medium 500 (242,100 B), SemiBold 600 (244,616 B),
  Bold 700 (246,992 B), `OFL.txt` (4,456 B). About 0.97 MB total. Thin/ExtraLight/Light are not bundled.
  No italic exists, and none is needed.
- Placed at `assets/fonts/`. `OFL.txt` is declared as an asset and registered in `main()`:
  `LicenseRegistry.addLicense(() async* { yield LicenseEntryWithLineBreaks(['IBM Plex Sans Arabic'],
  await rootBundle.loadString('assets/fonts/OFL.txt')); })`.
- Downloading the five files is an implementation step; the agent asks before downloading.

## R7. Theme tokens and sizing

- **Decision**: everything visual comes from `lib/core/theme/`:
  - `ColorScheme.fromSeed(seedColor: Color(0xFF326CE9), brightness: light/dark)`;
  - `AppTypography` (IBM Plex Sans Arabic, sizes in logical px);
  - `AppSpacing` and `AppRadii`, exposed as a `ThemeExtension<AppTokens>` (`context.tokens`).
  - `ThemeMode.system` (FR-021).
- Screens never create `Color`, `TextStyle`, `EdgeInsets` literals, or `BorderRadius` values; the
  import-rules test enforces it heuristically outside `lib/core/theme`.
- **flutter_screenutil** (design 420×812) is used for sizes only, inside the tokens. Spacing token
  = design value × `ScreenUtil().scaleWidth` clamped to `[0.85, 1.20]`. The clamp keeps tablets (which
  show the phone layout, FR-019) from getting doubled spacing. Fonts **never** use `.sp`; system
  text scaling applies once (FR-016, report R6). A widget test asserts the app does not change
  `MediaQuery.textScalerOf` (200% in, 200% seen).
- Content width is capped (e.g. 600 logical px, centered) so tablets and forced landscape (R8) stay usable.

## R8. Portrait lock (FR-019)

- **Decision**: three layers:
  - `SystemChrome.setPreferredOrientations([portraitUp])` in `main()`;
  - `android:screenOrientation="portrait"` on the activity;
  - iOS `UISupportedInterfaceOrientations` = portrait only, the same for `~ipad`, plus
    `UIRequiresFullScreen = true` (an iPad app that does not support all orientations must opt out of
    multitasking).
- **Finding (verified in the Android 16 behavior-changes doc)**: for apps targeting API 36 (Flutter's
  default), `screenOrientation` and `setRequestedOrientation()` are **ignored on displays with
  smallest width ≥ 600dp** (tablets, foldables unfolded). A temporary opt-out
  (`android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY`) restores the old behavior, but it
  goes away with a later target SDK. Plan: add the opt-out property now, keep the capped-width layout so
  landscape never breaks, and verify on a tablet emulator. Recorded as risk K1. Apple has likewise
  deprecated `UIRequiresFullScreen` in iPadOS 26, so the same mitigation applies to iPad.

## R9. Localization and digits

- `l10n.yaml`: `arb-dir: lib/core/l10n/arb`, `template-arb-file: app_ar.arb`, output to
  `lib/core/l10n/generated/`, `nullable-getter: false`. Generated files are committed (same reasoning as Q21).
- Delegates: `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]` from
  material_ui (report §1.4). Never `AppLocalizations.localizationsDelegates` (test-enforced).
- **Digits are applied by our own code, not by intl's locale data.** Numbers are formatted with Latin
  digits first, then `applyDigitStyle()` maps `0-9 → ٠-٩`, `. → ٫` and `, → ٬` when Arabic-Indic is active.
  This gives deterministic output whatever CLDR's numbering system for `ar` is. Dates use
  `DateFormat(locale)` for month names, then the same mapping.
- `DigitStylePreference { followLanguage, arabicIndic, latin }` resolves to an effective style:
  `followLanguage` → `ar` gives Arabic-Indic, `en` gives Latin.
- Exceptions (FR-011): the shop name is shown as typed; the app version is always Latin (`1.0.0 (1)`).
- Bidi: the phone and the version are wrapped in LTR isolates (U+2066…U+2069), so `+` and dots keep
  their order in RTL.
- Input: every numeric field and the phone field accept `0-9`, `٠-٩` (U+0660–0669) and `۰-۹`
  (U+06F0–06F9); `normalizeDigits()` maps them to Latin before validation and storage.

## R10. Shop details validation

- Name: trimmed, 1–60 **Unicode code points**. This matches SQLite `length()`, so the DB CHECK and the
  domain agree. The text field uses a custom code-point length formatter (Flutter's built-in one counts
  grapheme clusters).
- Phone: optional; strip spaces and `-`; optional single leading `+`; normalize digits; 7–15 digits;
  stored as Latin (`+201001234567`). Anything else is rejected with a localized message.

## R11. Logo, launcher icon, splash

- **Logo source (A5, corrected 2026-10-19):** `assets/images/logo.png`, already in this repo, placed by
  the owner. 799×1024 px, 8-bit RGBA PNG, 897,908 B. It is used in place on the welcome and
  data-and-backup screens with a spoken label (FR-020). `E:\projects\Cardeil\assets\images\logo.png`
  belongs to a different product and must never be read or used; nothing is copied from another
  project. Only `logo.png` is registered as an asset; the other files in `assets/images/` are not.
- **Dark appearance (FR-021):** the logo has no transparency. Every pixel is opaque, on an off-white
  canvas (about `#FBFAF9`). On the dark theme the illustration stays visible and legible, but it
  shows as a bright rectangle with hard edges instead of blending into the screen.
  **Design follow-up (not done now; the image is not edited):** a transparent-background or
  dark-theme variant of the logo, supplied in the designs phase. Until then both themes show the
  same image.
- **Recommendation: defer the launcher icon and splash to the designs phase.** The logo isn't square
  (799×1024), and an Android adaptive icon needs a foreground drawn inside a 66% safe zone on its own
  background, so generating icons now would mean redoing them. Until then the scaffold's default icons
  and Flutter's plain launch screen stay, and flutter_launcher_icons / flutter_native_splash are not
  added.

## R12. Release signing

- **Decision** (report §7.2): `android/app/build.gradle.kts` loads `android/key.properties` if present
  and defines `signingConfigs.release`. A release build **fails** if the file is missing; it never falls
  back to debug keys. Commit `android/key.properties.example` with placeholders (`.gitignore` already
  covers `key.properties`, `*.jks` and `*.keystore`).
- The human creates the upload keystore (outside the repo) and enters its passwords; the agent never
  handles them. Play App Signing is enabled at first upload.

## R13. Line endings

- **Decision**: `.gitattributes` with `* text=auto eol=lf`; `*.bat`/`*.cmd` `eol=crlf`; binary for `*.png`,
  `*.jpg`, `*.ttf`, `*.otf`, `*.jks`, `*.keystore` and `*.sqlite`. Existing CRLF files (e.g. `.gitignore`) are
  normalized when the human first runs `git add`. There are no commits yet, so nothing needs rewriting.

## R14. Architecture enforcement

- `test/architecture/import_rules_test.dart` (plain Dart, scans `lib/`) fails on:
  - `package:flutter/material.dart` or `cupertino.dart`;
  - a presentation or domain file importing `drift`, `core/database/` or another feature's `data/`;
  - `package:flutter/` imported in `domain/`;
  - use of `AppLocalizations.localizationsDelegates`;
  - `flutter_localizations` imported in a file that imports material_ui;
  - `double` in `features/*/domain` or in `core/utils/money.dart` / `quantity.dart`;
  - `package:http`, `package:dio`, `HttpClient`, `Socket` or `WebSocket` anywhere in `lib/`;
  - `.sp` usage;
  - outside `lib/core/theme`: `Color(`, `TextStyle(`, `EdgeInsets.only(`, `EdgeInsets.fromLTRB(`,
    `Alignment.*Left/Right`, `TextAlign.left/right`;
  - `Text('…')` or `Text("…")` with a non-empty literal in `presentation/`.
- Trigger meta-test: for each immutable or voidable table, list its columns with `PRAGMA table_info`
  and assert that the update-blocking trigger covers every column (so a future column can't bypass
  immutability).
