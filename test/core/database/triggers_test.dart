import 'package:daftar_afandi/core/database/schema_sql.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

Matcher _aborts(String message) => throwsA(
  isA<SqliteException>().having((e) => e.message, 'message', contains(message)),
);

/// The id of one fixture row in each voidable header.
const Map<String, String> _voidableRow = {
  'sales_invoices': 'si1',
  'purchase_invoices': 'pi1',
  'expenses': 'e1',
};

void main() {
  late TempDatabase t;

  setUp(() async {
    t = await TempDatabase.open();
    await insertFixtures(t.db);
  });
  tearDown(() => t.dispose());

  test('DELETE aborts on every table', () async {
    for (final table in kAllTables) {
      final before = await t.db.scalar('SELECT COUNT(*) FROM $table');
      expect(before, greaterThan(0), reason: 'fixture row missing in $table');
      await expectLater(
        t.db.exec('DELETE FROM $table'),
        _aborts('no hard delete: $table'),
        reason: table,
      );
      expect(await t.db.scalar('SELECT COUNT(*) FROM $table'), before);
    }
  });

  test('a party with no history may go once archived, and only then', () async {
    for (final (table, id) in [('customers', 'cu9'), ('suppliers', 'su9')]) {
      await t.db.exec(
        "INSERT INTO $table (id, name, search_key, created_at, updated_at) "
        "VALUES ('$id', 'x', 'x', 1, 1)",
      );
      await expectLater(
        t.db.exec("DELETE FROM $table WHERE id = '$id'"),
        _aborts('no hard delete: $table'),
        reason: '$table: not archived',
      );
      await t.db.exec("UPDATE $table SET archived_at = 2 WHERE id = '$id'");
      await t.db.exec("DELETE FROM $table WHERE id = '$id'");
      expect(
        await t.db.scalar("SELECT COUNT(*) FROM $table WHERE id = '$id'"),
        0,
      );
    }
    // The fixture parties have ledger rows: archived, they still stay.
    for (final (table, id) in [('customers', 'cu1'), ('suppliers', 'su1')]) {
      await t.db.exec("UPDATE $table SET archived_at = 2 WHERE id = '$id'");
      await expectLater(
        t.db.exec("DELETE FROM $table WHERE id = '$id'"),
        _aborts('no hard delete: $table'),
        reason: '$table: with history',
      );
    }
  });

  test('UPDATE aborts on every immutable table, even a no-op', () async {
    for (final table in kImmutableTables) {
      await expectLater(
        t.db.exec('UPDATE $table SET id = id'),
        _aborts('immutable: $table'),
        reason: table,
      );
    }
  });

  for (final MapEntry(key: table, value: id) in _voidableRow.entries) {
    group('$table void-only', () {
      Future<void> update(String set) =>
          t.db.exec("UPDATE $table SET $set WHERE id = '$id'");

      test('accepts exactly one void, with updated_at', () async {
        await update(
          "voided_at = 2000, void_reason = 'mistake', updated_at = 2000",
        );
        final row = (await t.db.rows(
          "SELECT voided_at, void_reason, updated_at FROM $table WHERE id = '$id'",
        )).single;
        expect(row, {
          'voided_at': 2000,
          'void_reason': 'mistake',
          'updated_at': 2000,
        });
      });

      test('rejects a void without a reason', () async {
        await expectLater(
          update('voided_at = 2000'),
          throwsA(isA<SqliteException>()),
        );
      });

      test('rejects any other column change, voiding or not', () async {
        await expectLater(
          update("note = 'edited'"),
          _aborts('void only: $table'),
        );
        await expectLater(
          update("voided_at = 2000, void_reason = 'x', note = 'edited'"),
          _aborts('void only: $table'),
        );
        await expectLater(
          update("voided_at = 2000, void_reason = 'x', number = 99"),
          _aborts('void only: $table'),
        );
      });

      test('rejects re-void and un-void', () async {
        await update("voided_at = 2000, void_reason = 'mistake'");
        await expectLater(
          update("voided_at = 3000, void_reason = 'again'"),
          _aborts('void only: $table'),
        );
        await expectLater(
          update('voided_at = NULL, void_reason = NULL'),
          _aborts('void only: $table'),
        );
        await expectLater(
          update('updated_at = 9'),
          _aborts('void only: $table'),
        );
      });
    });
  }

  group('sale return qty ceiling', () {
    Future<void> returnQty(String id, int qtyMilli) => t.db.exec(
      'INSERT INTO sale_return_items (id, sale_return_id, sale_item_id, product_id, '
      'qty_milli, unit_price_piasters, unit_cost_piasters, refund_piasters, '
      "cost_piasters, created_at) VALUES (?, 'sr1', 'sit1', 'p1', ?, 1000, 500, 0, 0, 1)",
      [id, qtyMilli],
    );

    test('aborts an over-return', () async {
      // Sold 2000, already returned 1000.
      await expectLater(
        returnQty('sri2', 1001),
        _aborts('return exceeds sold qty'),
      );
    });

    test('allows up to the sold qty, then nothing more', () async {
      await returnQty('sri2', 1000);
      await expectLater(
        returnQty('sri3', 1),
        _aborts('return exceeds sold qty'),
      );
      expect(
        await t.db.scalar(
          "SELECT SUM(qty_milli) FROM sale_return_items WHERE sale_item_id = 'sit1'",
        ),
        2000,
      );
    });
  });
}
