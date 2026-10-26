/// Constants the startup guard reads without constructing `AppDatabase`
/// (research R3). Plain `const`s, no imports.
library;

/// Stored in SQLite `user_version`; `AppDatabase.schemaVersion` returns it.
const int kSchemaVersion = 2;

/// Stored in SQLite `application_id`: "DAFA" in ASCII.
const int kAppApplicationId = 0x44414641;

/// The database file name inside the application support directory.
const String kDatabaseFileName = 'daftar_afandi.sqlite';
