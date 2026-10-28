import 'dart:io';

import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

final DateTime testNow = DateTime.utc(2026, 10, 20, 9);

/// A fresh database in a new temp file (a real file, so `journal_mode` is the
/// on-disk default). The directory is deleted when the test ends.
final class TempDatabase {
  TempDatabase._(this.dir, this.file, this.db);

  final Directory dir;
  final File file;
  final AppDatabase db;

  static Future<TempDatabase> open({IdGenerator? ids}) async {
    final dir = await Directory.systemTemp.createTemp('daftar_db_test_');
    final file = File('${dir.path}${Platform.pathSeparator}test.sqlite');
    final db = openAt(file, ids: ids);
    await db.customSelect('SELECT 1').get(); // runs onCreate
    return TempDatabase._(dir, file, db);
  }

  static AppDatabase openAt(File file, {IdGenerator? ids}) => AppDatabase(
    NativeDatabase(file),
    ids ?? const UuidV7Generator(),
    FixedClock(testNow),
  );

  Future<void> dispose() async {
    await db.close();
    await dir.delete(recursive: true);
  }
}

extension RawSql on AppDatabase {
  Future<Object?> scalar(String sql, [List<Object?> args = const []]) async {
    final row = await customSelect(
      sql,
      variables: [for (final a in args) Variable(a)],
    ).getSingle();
    return row.data.values.first;
  }

  Future<List<Map<String, Object?>>> rows(String sql) async =>
      (await customSelect(sql).get()).map((r) => r.data).toList();

  Future<void> exec(String sql, [List<Object?> args = const []]) =>
      customStatement(sql, args);
}

/// One valid row in every table that has no seed, with fixed ids. Sold 2.000
/// pieces on `sit1`, of which 1.000 is already returned on `sri1`.
Future<void> insertFixtures(AppDatabase db) async {
  const statements = [
    "INSERT INTO categories (id, name, search_key, created_at, updated_at) VALUES ('c1', 'Food', 'food', 1, 1)",
    "INSERT INTO products (id, category_id, name, search_key, unit_type, sale_price_piasters, created_at, updated_at) VALUES ('p1', 'c1', 'Rice', 'rice', 'piece', 1000, 1, 1)",
    "INSERT INTO customers (id, name, search_key, created_at, updated_at) VALUES ('cu1', 'Ali', 'ali', 1, 1)",
    "INSERT INTO suppliers (id, name, search_key, created_at, updated_at) VALUES ('su1', 'Nile', 'nile', 1, 1)",
    "INSERT INTO expense_categories (id, name, search_key, created_at, updated_at) VALUES ('ec1', 'Rent', 'rent', 1, 1)",
    "INSERT INTO sales_invoices (id, number, customer_id, subtotal_piasters, discount_piasters, total_piasters, paid_at_sale_piasters, created_at, updated_at) VALUES ('si1', 1, 'cu1', 2000, 0, 2000, 2000, 1, 1)",
    "INSERT INTO sale_items (id, sales_invoice_id, line_no, product_id, product_name_snapshot, unit_type_snapshot, qty_milli, unit_price_piasters, discount_piasters, line_total_piasters, invoice_discount_share_piasters, unit_cost_piasters, line_cost_piasters) VALUES ('sit1', 'si1', 1, 'p1', 'Rice', 'piece', 2000, 1000, 0, 2000, 0, 500, 1000)",
    "INSERT INTO sale_returns (id, number, sales_invoice_id, customer_id, total_refund_piasters, total_cost_piasters, refund_paid_piasters, created_at) VALUES ('sr1', 1, 'si1', 'cu1', 1000, 500, 1000, 1)",
    "INSERT INTO sale_return_items (id, sale_return_id, sale_item_id, product_id, qty_milli, unit_price_piasters, unit_cost_piasters, refund_piasters, cost_piasters, created_at) VALUES ('sri1', 'sr1', 'sit1', 'p1', 1000, 1000, 500, 1000, 500, 1)",
    "INSERT INTO purchase_invoices (id, number, supplier_id, invoice_date, subtotal_piasters, discount_piasters, total_piasters, paid_piasters, created_at, updated_at) VALUES ('pi1', 1, 'su1', 1, 5000, 0, 5000, 5000, 1, 1)",
    "INSERT INTO purchase_items (id, purchase_invoice_id, line_no, product_id, product_name_snapshot, qty_milli, unit_cost_piasters, line_total_piasters, invoice_discount_share_piasters, net_line_cost_piasters, avg_cost_before_piasters, avg_cost_after_piasters, created_at) VALUES ('pit1', 'pi1', 1, 'p1', 'Rice', 10000, 500, 5000, 0, 5000, 0, 500, 1)",
    "INSERT INTO stock_movements (id, product_id, movement_type, qty_delta_milli, unit_cost_piasters, purchase_item_id, created_at) VALUES ('sm1', 'p1', 'PURCHASE', 10000, 500, 'pit1', 1)",
    "INSERT INTO customer_ledger (id, customer_id, entry_type, amount_piasters, sales_invoice_id, created_at) VALUES ('cl1', 'cu1', 'SALE', 2000, 'si1', 1)",
    "INSERT INTO customer_ledger (id, customer_id, entry_type, amount_piasters, receipt_number, payment_method, created_at) VALUES ('cl2', 'cu1', 'PAYMENT_RECEIVED', -2000, 1, 'cash', 1)",
    "INSERT INTO supplier_ledger (id, supplier_id, entry_type, amount_piasters, purchase_invoice_id, created_at) VALUES ('sl1', 'su1', 'PURCHASE', 5000, 'pi1', 1)",
    "INSERT INTO expenses (id, number, expense_category_id, amount_piasters, spent_at, created_at, updated_at) VALUES ('e1', 1, 'ec1', 100, 1, 1, 1)",
    "INSERT INTO payment_parts (id, sales_invoice_id, part_no, method, amount_piasters, created_at) VALUES ('pp1', 'si1', 1, 'cash', 2000, 1)",
  ];
  for (final sql in statements) {
    await db.exec(sql);
  }
}
