/// Meta-test (research R14): a column added later must not slip past the
/// update-blocking triggers.
library;

import 'package:daftar_afandi/core/database/schema_sql.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

void main() {
  late TempDatabase t;

  setUp(() async => t = await TempDatabase.open());
  tearDown(() => t.dispose());

  Future<String> triggerSql(String name) async {
    final sql = await t.db.scalar(
      "SELECT sql FROM sqlite_master WHERE type = 'trigger' AND name = ?",
      [name],
    );
    expect(sql, isA<String>(), reason: 'trigger $name is missing');
    return sql! as String;
  }

  Future<List<String>> columnsOf(String table) async =>
      (await t.db.rows('PRAGMA table_info($table)'))
          .map((c) => c['name']! as String)
          .toList();

  test('every table has a no-delete trigger', () async {
    for (final table in kAllTables) {
      final sql = await triggerSql('trg_${table}_no_delete');
      expect(sql, contains('BEFORE DELETE ON $table'));
    }
  });

  test(
    'immutable triggers block every column (no column list, no WHEN)',
    () async {
      for (final table in kImmutableTables) {
        final sql = await triggerSql('trg_${table}_immutable');
        expect(sql, contains('BEFORE UPDATE ON $table'), reason: table);
        expect(sql, isNot(contains(' OF ')), reason: table);
        expect(sql, isNot(contains('WHEN')), reason: table);
      }
    },
  );

  test('void-only triggers name every non-void column', () async {
    expect(kVoidableFrozenColumns.keys.toSet(), {
      'sales_invoices',
      'purchase_invoices',
      'expenses',
    });
    for (final MapEntry(key: table, value: frozen)
        in kVoidableFrozenColumns.entries) {
      final columns = await columnsOf(table);
      expect(columns, containsAll(kVoidColumns), reason: table);

      final nonVoid = columns.where((c) => !kVoidColumns.contains(c)).toSet();
      expect(
        frozen.toSet(),
        nonVoid,
        reason: '$table: update kVoidableFrozenColumns',
      );

      final sql = await triggerSql('trg_${table}_void_only');
      for (final c in nonVoid) {
        expect(sql, contains('NEW.$c IS NOT OLD.$c'), reason: '$table.$c');
      }
    }
  });
}
