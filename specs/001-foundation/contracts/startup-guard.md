# Contract: Startup and the schema guard (FR-018)

File: `lib/core/database/schema_guard.dart` (pure `dart:io`; it imports no package).
Constants: `lib/core/database/schema_constants.dart`.

```dart
const int kSchemaVersion = 1;                 // AppDatabase.schemaVersion returns this
const int kAppApplicationId = 0x44414641;     // "DAFA"
const String kDatabaseFileName = 'daftar_afandi.sqlite';

sealed class SchemaInspection {}
final class SchemaFresh extends SchemaInspection {}                       // no file or 0 bytes
final class SchemaOk extends SchemaInspection { final int userVersion; }  // 0..kSchemaVersion
final class SchemaTooNew extends SchemaInspection { final int userVersion; }
final class SchemaUnrecognized extends SchemaInspection { final String reason; }

abstract interface class SchemaGuard {
  /// Reads at most the first 100 bytes via a read-only handle. Never writes, never creates files.
  Future<SchemaInspection> inspect(String databasePath);
}
```

## Decision table

| File state | Result |
|---|---|
| absent, or length 0 | `SchemaFresh` |
| < 100 bytes, or magic ≠ `SQLite format 3\0` | `SchemaUnrecognized('header')` |
| appId ∉ {0, kAppApplicationId} | `SchemaUnrecognized('applicationId')` |
| appId = 0 and userVersion ≠ 0 | `SchemaUnrecognized('applicationId')` |
| userVersion > kSchemaVersion | `SchemaTooNew` |
| otherwise | `SchemaOk` |

## Bootstrap order (`lib/main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()`; portrait lock; register the font license.
2. `dir = await getApplicationSupportDirectory()`; `path = join(dir, kDatabaseFileName)`.
3. `inspection = await SchemaGuard().inspect(path)`. **No DI registration and no database object
   exists before this line.**
4. `SchemaTooNew` → `runApp(const UpdateRequiredApp(kind: tooNew))`. Then stop.
   `SchemaUnrecognized` → `runApp(const UpdateRequiredApp(kind: unrecognized))` (A4, approved). Then stop.
5. Otherwise: `configureDependencies(databaseDirectory: dir)` → `AppDatabase` (drift_flutter) →
   load settings (this opens the DB and runs onCreate/onUpgrade) → `PackageInfo` → `runApp(App)`.
6. If opening or migrating throws: `runApp(StartupErrorApp)` (Arabic, file untouched, no retry loop
   that writes). `SchemaTooNewException` thrown from `onUpgrade` (`from > to`) maps to step 4.

## UpdateRequiredApp

- A minimal `MaterialApp` (material_ui), Arabic locale and RTL only, theme tokens, logo, one message,
  and no other route. Nothing can navigate away from it (FR-018). It has no buttons that touch data.
- Strings come from `AppLocalizations` (ar), keys `updateRequiredTitle`, `updateRequiredBody`,
  `dataUnrecognizedBody`.

## Tests (required)

- Guard unit tests on files built byte-by-byte in a temp dir (no SQLite needed): fresh, empty file,
  short file, bad magic, foreign appId, appId 0 + version 3, version 0, 1 (ok), 2 (too new).
  - Each test asserts that the file's bytes, length and last-modified time are unchanged afterwards,
    and that no sibling file (`-journal`, `-wal`, `-shm`) was created.
- Integration test: create a real v1 DB with `AppDatabase` on a temp file, close it, inspect →
  `SchemaOk(1)` and appId matches.
- Integration test: patch `user_version` to 99 on that file (raw bytes), run the bootstrap with a fake
  `runApp` sink → `UpdateRequiredApp` is chosen, `AppDatabase` is never constructed, and the SHA-256 of
  the file is unchanged.
