import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/reports/data/reports_repository_impl.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/database/test_database.dart';
import '../../products/data/products_env.dart';

/// SC-005: a year of a busy shop, about 20,000 sales and 2,000 expenses;
/// each report shows within 2 s. The budget here is the dev machine's.
void main() {
  test('profit and money collected for a year of records', () async {
    final env = ProductsEnv();
    addTearDown(env.dispose);
    final db = env.db;
    final start = DateTime.utc(2026).millisecondsSinceEpoch;
    const day = 24 * 60 * 60 * 1000;

    await db.transaction(() async {
      await db.exec(
        'INSERT INTO products (id, name, search_key, unit_type, '
        "sale_price_piasters, created_at, updated_at) VALUES ('p', 'صنف', "
        "'صنف', 'piece', 1000, 1, 1)",
      );
      await db.exec(
        'INSERT INTO expense_categories (id, name, search_key, created_at, '
        "updated_at) VALUES ('c', 'إيجار', 'ايجار', 1, 1)",
      );
      for (var s = 0; s < 20000; s++) {
        final at = start + (s * 365 ~/ 20000) * day + s;
        await db.exec(
          'INSERT INTO sales_invoices (id, number, subtotal_piasters, '
          'total_piasters, paid_at_sale_piasters, payment_method, created_at, '
          "updated_at) VALUES ('s$s', $s, 3000, 3000, 3000, 'cash', $at, $at)",
        );
        for (var l = 0; l < 2; l++) {
          await db.exec(
            'INSERT INTO sale_items (id, sales_invoice_id, line_no, '
            'product_id, product_name_snapshot, unit_type_snapshot, qty_milli, '
            'unit_price_piasters, discount_piasters, line_total_piasters, '
            'invoice_discount_share_piasters, unit_cost_piasters, '
            "line_cost_piasters) VALUES ('i$s-$l', 's$s', ${l + 1}, 'p', "
            "'صنف', 'piece', 1000, 1500, 0, 1500, 0, 700, 700)",
          );
        }
        await db.exec(
          'INSERT INTO payment_parts (id, sales_invoice_id, part_no, method, '
          "amount_piasters, created_at) VALUES ('pp$s', 's$s', 1, "
          "'${s.isEven ? 'cash' : 'wallet'}', 3000, $at)",
        );
      }
      for (var e = 0; e < 2000; e++) {
        final at = start + (e * 365 ~/ 2000) * day;
        await db.exec(
          'INSERT INTO expenses (id, number, expense_category_id, '
          'amount_piasters, spent_at, created_at, updated_at) VALUES '
          "('e$e', $e, 'c', 500, $at, $at, $at)",
        );
      }
    });

    final clock = FixedClock(DateTime.utc(2027, 1, 15));
    final reports = ReportsRepositoryImpl(db.reportsDao, clock);
    final year = switch (ReportPeriod.custom(
      DateTime(2026),
      DateTime(2026, 12, 31),
      clock,
    )) {
      Ok(:final value) => value,
      Err() => fail('period'),
    };

    final watch = Stopwatch()..start();
    final profit = await reports.watchProfit(year).first;
    final profitMs = watch.elapsedMilliseconds;
    final collected = await reports.watchCollected(year).first;
    watch.stop();
    final collectedMs = watch.elapsedMilliseconds - profitMs;

    expect(profit.salesCount, 20000);
    expect(profit.costOfGoodsPiasters, 20000 * 1400);
    expect(profit.expensesPiasters, 2000 * 500);
    expect(collected.totalPiasters, 20000 * 3000);
    // ignore: avoid_print
    print('profit: $profitMs ms, collected: $collectedMs ms');
    expect(profitMs, lessThan(2000));
    expect(collectedMs, lessThan(2000));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
