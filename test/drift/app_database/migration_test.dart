// Schema checks and the v1 → v2 upgrade (006 research R4, SC-009, FR-041).
import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;

const _t = 1761400000000; // a fixed v1 time, UTC ms

/// A v1 shop: every kind of payment v1 could hold.
Future<void> _fillV1(DatabaseConnectionUser db) async {
  Future<void> run(String sql, [List<Object?> args = const []]) =>
      db.customStatement(sql, args);

  await run(
    'INSERT INTO customers (id, name, search_key, created_at, updated_at) '
    "VALUES ('c1', 'منى', 'منى', $_t, $_t)",
  );
  await run(
    'INSERT INTO suppliers (id, name, search_key, created_at, updated_at) '
    "VALUES ('s1', 'النور', 'النور', $_t, $_t)",
  );
  await run(
    'INSERT INTO products (id, name, search_key, unit_type, '
    'sale_price_piasters, avg_cost_piasters, created_at, updated_at) '
    "VALUES ('p1', 'شاي', 'شاي', 'piece', 1250, 900, $_t, $_t)",
  );
  await run(
    'INSERT INTO stock_movements (id, product_id, movement_type, '
    'qty_delta_milli, unit_cost_piasters, created_at) VALUES '
    "('m1', 'p1', 'OPENING', 10000, 900, $_t)",
  );
  await run(
    'INSERT INTO stock_movements (id, product_id, movement_type, '
    'qty_delta_milli, unit_cost_piasters, adjustment_reason, created_at) '
    "VALUES ('m2', 'p1', 'ADJUSTMENT', -1000, 900, 'damage', $_t)",
  );

  Future<void> sale(
    String id,
    int n,
    int total,
    int paid,
    String method, {
    String? customer,
    bool voided = false,
  }) => run(
    'INSERT INTO sales_invoices (id, number, customer_id, subtotal_piasters, '
    'total_piasters, paid_at_sale_piasters, payment_method, created_at, '
    'updated_at, voided_at, void_reason) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [
      id,
      n,
      customer,
      total,
      total,
      paid,
      method,
      _t + n,
      _t + n,
      voided ? _t + 99 : null,
      voided ? 'خطأ' : null,
    ],
  );

  await sale('sa1', 1, 5000, 5000, 'cash');
  await sale('sa2', 2, 8000, 0, 'cash', customer: 'c1'); // credit
  await sale('sa3', 3, 9000, 4000, 'wallet', customer: 'c1'); // partial
  await sale('sa4', 4, 3000, 3000, 'instapay', voided: true);

  Future<void> cl(
    String id,
    String type,
    int amount, {
    String? sale,
    int? receipt,
    String? method,
    String? reverses,
  }) => run(
    'INSERT INTO customer_ledger (id, customer_id, entry_type, amount_piasters, '
    'sales_invoice_id, receipt_number, payment_method, reverses_entry_id, '
    "created_at) VALUES (?, 'c1', ?, ?, ?, ?, ?, ?, $_t)",
    [id, type, amount, sale, receipt, method, reverses],
  );

  await cl('l1', 'OPENING_BALANCE', 1000);
  await cl('l2', 'SALE', 8000, sale: 'sa2');
  await cl('l3', 'SALE', 9000, sale: 'sa3');
  await cl('l4', 'PAYMENT_RECEIVED', -4000, sale: 'sa3', method: 'wallet');
  await cl('l5', 'PAYMENT_RECEIVED', -2500, receipt: 1, method: 'instapay');
  await cl('l6', 'PAYMENT_RECEIVED', -700, receipt: 2, method: 'cash');
  await cl('l7', 'REVERSAL', 700, reverses: 'l6');

  Future<void> purchase(String id, int n, int total, int paid, String method) =>
      run(
        'INSERT INTO purchase_invoices (id, number, supplier_id, invoice_date, '
        'subtotal_piasters, total_piasters, paid_piasters, payment_method, '
        "created_at, updated_at) VALUES (?, ?, 's1', $_t, ?, ?, ?, ?, ?, ?)",
        [id, n, total, total, paid, method, _t + n, _t + n],
      );
  await purchase('pu1', 1, 20000, 5000, 'cash');
  await purchase('pu2', 2, 6000, 0, 'cash');

  Future<void> sl(
    String id,
    String type,
    int amount, {
    String? purchase,
    int? payment,
    String? method,
  }) => run(
    'INSERT INTO supplier_ledger (id, supplier_id, entry_type, amount_piasters, '
    'purchase_invoice_id, payment_number, payment_method, created_at) '
    "VALUES (?, 's1', ?, ?, ?, ?, ?, $_t)",
    [id, type, amount, purchase, payment, method],
  );
  await sl('k1', 'PURCHASE', 20000, purchase: 'pu1');
  await sl('k2', 'PAYMENT_MADE', -5000, purchase: 'pu1', method: 'cash');
  await sl('k3', 'PURCHASE', 6000, purchase: 'pu2');
  await sl('k4', 'PAYMENT_MADE', -3000, payment: 1, method: 'wallet');

  await run(
    'INSERT INTO expense_categories (id, name, search_key, created_at, '
    "updated_at) VALUES ('ec1', 'إيجار', 'ايجار', $_t, $_t)",
  );
  await run(
    'INSERT INTO expenses (id, number, expense_category_id, amount_piasters, '
    "spent_at, created_at, updated_at) VALUES ('e1', 1, 'ec1', 150000, $_t, "
    '$_t, $_t)',
  );
}

Future<Map<String, Object?>> _totals(DatabaseConnectionUser db) async {
  Future<Object?> one(String sql) async =>
      (await db.customSelect(sql).getSingle()).data.values.single;
  return {
    'customer': await one(
      "SELECT SUM(amount_piasters) FROM customer_ledger WHERE customer_id = 'c1'",
    ),
    'supplier': await one(
      "SELECT SUM(amount_piasters) FROM supplier_ledger WHERE supplier_id = 's1'",
    ),
    'stock': await one(
      "SELECT SUM(qty_delta_milli) FROM stock_movements WHERE product_id = 'p1'",
    ),
    'sales': await one('SELECT SUM(total_piasters) FROM sales_invoices'),
    'rows': await one(
      'SELECT (SELECT COUNT(*) FROM customer_ledger) + '
      '(SELECT COUNT(*) FROM supplier_ledger) + '
      '(SELECT COUNT(*) FROM sales_invoices)',
    ),
  };
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  final clock = FixedClock(DateTime.utc(2026, 10, 26));

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  AppDatabase open(QueryExecutor e) =>
      AppDatabase(e, const UuidV7Generator(), clock);

  test('v1 upgrades to a v2 schema that matches the code', () async {
    final schema = await verifier.schemaAt(1);
    final db = open(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('v2 upgrades to v3 with the party triggers a new file gets', () async {
    // The verifier's v2 has tables only; the party triggers are compared.
    Future<Map<String, String>> triggers(AppDatabase db) async => {
      for (final r
          in await db
              .customSelect(
                "SELECT name, sql FROM sqlite_master WHERE type = 'trigger' "
                "AND name IN ('trg_customers_no_delete', "
                "'trg_suppliers_no_delete')",
              )
              .get())
        r.read<String>('name'): r.read<String>('sql'),
    };

    final schema = await verifier.schemaAt(2);
    final db = open(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    final fresh = open(NativeDatabase.memory());
    expect(await triggers(db), hasLength(2));
    expect(await triggers(db), await triggers(fresh));
    expect(
      (await triggers(db))['trg_customers_no_delete'],
      contains('OLD.archived_at IS NULL'),
    );
    await db.close();
    await fresh.close();
  });

  test('a database built by onCreate matches the schema in code', () async {
    final db = open(NativeDatabase.memory());
    await db.validateDatabaseSchema();
    await db.close();
  });

  test(
    'upgrading keeps every balance and gives each payment one part',
    () async {
      final schema = await verifier.schemaAt(1);
      final old = v1.DatabaseAtV1(schema.newConnection());
      await _fillV1(old);
      final filled = await _totals(old);
      await old.close();

      final db = open(schema.newConnection());
      await verifier.migrateAndValidate(db, 2);

      expect(await _totals(db), filled);
      final parts = await db
          .customSelect(
            'SELECT COALESCE(sales_invoice_id, purchase_invoice_id, '
            'customer_ledger_id, supplier_ledger_id, expense_id) AS parent, '
            'part_no, method, amount_piasters, account_ref FROM payment_parts '
            'ORDER BY parent',
          )
          .get();
      expect(
        [
          for (final p in parts)
            (
              p.read<String>('parent'),
              p.read<int>('part_no'),
              p.read<String>('method'),
              p.read<int>('amount_piasters'),
              p.readNullable<String>('account_ref'),
            ),
        ],
        [
          ('e1', 1, 'cash', 150000, null),
          ('k4', 1, 'wallet', 3000, null),
          ('l5', 1, 'instapay', 2500, null),
          ('l6', 1, 'cash', 700, null), // reversed, kept for history
          ('pu1', 1, 'cash', 5000, null),
          ('sa1', 1, 'cash', 5000, null),
          ('sa3', 1, 'wallet', 4000, null),
          ('sa4', 1, 'instapay', 3000, null), // voided, kept for history
        ],
      );
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 2);
      await db.close();
    },
  );
}
