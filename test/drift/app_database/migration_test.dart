// Schema v1 check. make-migrations scaffolds the step-by-step migration tests
// once a second schema version exists; until then this file checks that the
// exported drift_schema_v1.json matches the code.
import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  final clock = FixedClock(DateTime.utc(2026, 10, 20));

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('the exported v1 schema matches the tables in code', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(
      schema.newConnection(),
      const UuidV7Generator(),
      clock,
    );
    await verifier.migrateAndValidate(db, 1);
    await db.close();
  });

  test('a database built by onCreate matches the schema in code', () async {
    final db = AppDatabase(
      NativeDatabase.memory(),
      const UuidV7Generator(),
      clock,
    );
    await db.validateDatabaseSchema();
    await db.close();
  });
}
