# Quickstart: validating Foundation (001)

## Prerequisites

- Flutter 3.47.7 / Dart 3.13.5 (`flutter --version`).
- An Android emulator (API 34+) with a Google account; ideally also an API 36 tablet emulator.
  For iOS: a Mac with Xcode and an iOS 15+ simulator (iOS can't be verified on this Windows machine).
- Fonts and logo assets placed as in [research.md](research.md) R6 and R11.

## Build and automated checks (the gate after every phase)

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter analyze
```

```bash
flutter test
```

Expected: analyze reports no issues, and every test passes. This includes
`test/architecture/import_rules_test.dart`, `test/drift/` (migration tests), `test/core/utils/`,
the guard tests ([contracts/startup-guard.md](contracts/startup-guard.md)), and the cubit and widget tests.

Once, after the schema is written (Phase 3):

```bash
dart run drift_dev make-migrations
```

Expected: `drift_schemas/app_database/drift_schema_v1.json` and the generated migration test appear.

Lock-file audit (Phase 1): every entry in `pubspec.lock` was published on or before the cutoff,
or is listed in `dependency_overrides` with a "remove after" date.

## Manual scenarios (map to the spec)

| # | Scenario | Expected | Spec |
|---|---|---|---|
| 1 | Fresh install with the phone language set to English, launch | Arabic RTL welcome, logo, app name "دفتر أفندي" | US1-1, FR-001 |
| 2 | Tap English on the welcome, kill the app, relaunch | Welcome again, in English | US1-2, US1-6, FR-002 |
| 3 | Shop step: empty name, then spaces only, then 61 chars | Continue blocked; the message is in the active language; input stops at 60 | US1-3, FR-006 |
| 4 | Phone `٠١٠ ١٢٣٤-٥٦٧٨` | Accepted; stored as `01012345678` | Edge cases, R10 |
| 5 | Finish first run with a stopwatch, three new people | Each under 60 s | SC-001 |
| 6 | Relaunch 10 times, then reboot | Opens on Home; shop details unchanged | US1-5, SC-003 |
| 7 | Visit all 5 sections in ar and en | Correct order, placeholder text, no sample data | US3, FR-008/009 |
| 8 | Settings: switch the language, then the digit style | Updates within 1 s, no restart; the shop name is unchanged; the version stays `1.0.0 (1)` | US4, SC-004, FR-011 |
| 9 | System text 200% plus dark mode, every screen, both languages | Nothing cut off or overlapping; everything reachable | SC-002, FR-016/021 |
| 10 | TalkBack on: focus every control and the logo | Each has a label in the active language | FR-020, SC-008 |
| 11 | Airplane mode, run 1–8 | All work; no network permission is requested | SC-006, FR-015 |
| 12 | Rotate the phone | Stays portrait | FR-019 |
| 13 | API 36 tablet emulator, rotate | Stays portrait (opt-out active), or, if ignored, a centered capped layout that still works | FR-019, K1 |

### Android backup and restore (US5, SC-005)

```bash
adb shell bmgr enable true
```

```bash
adb shell bmgr backupnow com.ahmedmaher.daftarafandi
```

```bash
adb uninstall com.ahmedmaher.daftarafandi
```

Then reinstall the same build (`flutter install`) and launch. Expected: Home opens with the same shop
details, and first run is skipped. For US5-3 (older data), install a build with schema v1, back up,
then install a build with a higher schema version (available from the first migration onwards) and
check that the data is upgraded and nothing is asked.

### Newer-data block (FR-018)

1. Copy a v1 database out with `adb exec-out run-as com.ahmedmaher.daftarafandi cat files/daftar_afandi.sqlite > v1.sqlite`.
2. Patch bytes 60–63 to `00 00 00 63` (user_version 99) on the PC with a hex editor.
3. Push it back, using `run-as` with `cp` from `/data/local/tmp`, and note its SHA-256.
4. Launch. Expected: only the Arabic "please update the app" screen appears, with no way past it.
   After closing the app, the file's SHA-256 is unchanged.

## Not verifiable on this machine

iOS behavior (portrait plist, the data-safety iPhone text, VoiceOver) needs a Mac. Release signing
needs the human-created upload keystore.
