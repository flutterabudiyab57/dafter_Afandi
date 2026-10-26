import 'dart:io';

import 'package:daftar_afandi/core/database/schema_constants.dart';
import 'package:daftar_afandi/core/database/schema_sql.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

void main() {
  late TempDatabase t;

  setUp(() async => t = await TempDatabase.open());
  tearDown(() => t.dispose());

  test('all 18 tables exist, and no others', () async {
    final rows = await t.db.rows(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    final names = rows.map((r) => r['name']).toSet();
    expect(kAllTables, hasLength(18));
    expect(names, kAllTables.toSet());
  });

  test('header pragmas', () async {
    expect(await t.db.scalar('PRAGMA application_id'), 0x44414641);
    expect(kAppApplicationId, 0x44414641);
    expect(await t.db.scalar('PRAGMA user_version'), 2);
    expect(kSchemaVersion, 2);
    expect(t.db.schemaVersion, kSchemaVersion);
  });

  test('rollback journal and foreign keys on', () async {
    expect(await t.db.scalar('PRAGMA journal_mode'), 'delete');
    expect(await t.db.scalar('PRAGMA foreign_keys'), 1);
  });

  test('no REAL column anywhere', () async {
    for (final table in kAllTables) {
      final columns = await t.db.rows('PRAGMA table_info($table)');
      for (final c in columns) {
        expect(c['type'], isNot('REAL'), reason: '$table.${c['name']}');
      }
    }
  });

  test('reopening an existing file does not run onCreate again', () async {
    await t.db.close();
    final again = TempDatabase.openAt(t.file);
    expect(await again.scalar('SELECT COUNT(*) FROM counters'), 6);
    expect(await again.scalar('SELECT COUNT(*) FROM app_settings'), 1);
    expect(await again.scalar('PRAGMA foreign_keys'), 1);
    await again.close();
    await t.dir.delete(recursive: true);
    t = await TempDatabase.open(); // a fresh one for tearDown
  });

  test('a failure during onCreate leaves no half-built schema (K4)', () async {
    final file = File('${t.dir.path}${Platform.pathSeparator}k4.sqlite');

    // The 5th id is a counters row: tables, triggers and 3 counters exist by then.
    final broken = TempDatabase.openAt(file, ids: _FailingIds(failOnCall: 5));
    await expectLater(broken.customSelect('SELECT 1').get(), throwsStateError);
    await broken.close();

    // Everything was rolled back, so a normal open builds it from scratch
    // (createAll would fail on existing tables otherwise).
    final ok = TempDatabase.openAt(file);
    expect(await ok.scalar('SELECT COUNT(*) FROM counters'), 6);
    expect(await ok.scalar('SELECT COUNT(*) FROM app_settings'), 1);
    expect(await ok.scalar('PRAGMA user_version'), kSchemaVersion);
    expect(await ok.scalar('PRAGMA application_id'), kAppApplicationId);
    await ok.close();
  });
}

final class _FailingIds implements IdGenerator {
  _FailingIds({required this.failOnCall});

  final int failOnCall;
  final IdGenerator _real = const UuidV7Generator();
  int _calls = 0;

  @override
  String newId() {
    _calls += 1;
    if (_calls == failOnCall) throw StateError('simulated crash in onCreate');
    return _real.newId();
  }
}
