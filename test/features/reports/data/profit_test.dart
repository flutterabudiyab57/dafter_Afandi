import 'dart:math';

import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/adjustment.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/reports/data/reports_repository_impl.dart';
import 'package:daftar_afandi/features/reports/domain/profit_summary.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import '../../sales/data/sales_env.dart';

/// Records are made from 2026-10-20 09:00 UTC (StepClock), inside October
/// in any time zone from UTC-9 to UTC+14.
final _later = FixedClock(DateTime.utc(2026, 11, 15, 10));

ReportPeriod _range(DateTime from, DateTime to) =>
    okValue<ReportPeriod, PeriodInvalid>(ReportPeriod.custom(from, to, _later));

final _october = _range(DateTime(2026, 10), DateTime(2026, 10, 31));
final _september = _range(DateTime(2026, 9), DateTime(2026, 9, 30));

void main() {
  late SalesEnv env;
  late String item;
  late ReportsRepositoryImpl reports;
  var expenseNo = 0;

  setUp(() async {
    env = SalesEnv();
    reports = ReportsRepositoryImpl(env.products.db.reportsDao, _later);
    // Sells at 100.00; 1,000 in stock at 70.00.
    item = await env.products.addProduct(
      'صنف',
      price: '100',
      openingQty: '1000',
      openingCost: '70',
    );
    await env.products.db.customStatement(
      'INSERT INTO expense_categories (id, name, search_key, created_at, '
      "updated_at) VALUES ('rent', 'إيجار', 'ايجار', 1, 1)",
    );
    expenseNo = 0;
  });
  tearDown(() => env.dispose());

  Future<ProfitSummary> profit([ReportPeriod? period]) =>
      reports.watchProfit(period ?? _october).first;

  Future<String> sell(int units, {int? pricePiasters}) async {
    var d = await env.draftFor({item: units * one});
    if (pricePiasters != null) {
      d = d.updateLine(item, unitPricePiasters: pricePiasters);
    }
    return okValue<SaleSaved, SaleSaveError>(
      await env.sales.create(d, acknowledgeShortage: true),
    ).id;
  }

  Future<void> expense(
    int piasters, {
    DateTime? spentAt,
    bool voided = false,
  }) => env.products.db.customStatement(
    'INSERT INTO expenses (id, number, expense_category_id, '
    'amount_piasters, spent_at, created_at, updated_at, voided_at, '
    "void_reason) VALUES (?, ?, 'rent', ?, ?, 1, 1, ?, ?)",
    [
      'e${++expenseNo}',
      expenseNo,
      piasters,
      (spentAt ?? DateTime.utc(2026, 10, 20, 9)).millisecondsSinceEpoch,
      voided ? 2 : null,
      voided ? 'خطأ' : null,
    ],
  );

  Future<void> adjust(AdjustmentRequest Function() request) async {
    final r = await env.products.inventory.adjust(item, request());
    expect(r, isA<Ok<Object?, Object?>>());
  }

  AdjustmentRequest damage(String qty) =>
      okValue<AdjustmentRequest, List<AdjustmentError>>(
        AdjustmentRequest.damage(qtyText: qty, unit: UnitType.piece),
      );

  AdjustmentRequest counted(String qty) =>
      okValue<AdjustmentRequest, List<AdjustmentError>>(
        AdjustmentRequest.count(countedText: qty, unit: UnitType.piece),
      );

  test(
    'sales of 10,000 at a cost of 7,000: gross profit 3,000 (US2-1)',
    () async {
      await sell(60);
      await sell(40);
      final p = await profit();
      expect(p.netSalesPiasters, 1000000);
      expect(p.costOfGoodsPiasters, 700000);
      expect(p.grossProfitPiasters, 300000);
      expect(p.salesCount, 2);
    },
  );

  test(
    'damage of 200 and expenses of 1,500: net profit 1,300 (US2-2)',
    () async {
      await sell(100);
      await adjust(() => damage('2')); // 2 × 70.00 = 140.00
      await adjust(() => damage('1')); // 70.00 → 210.00 in all
      await expense(150000);
      await expense(99900, voided: true);
      final p = await profit();
      expect(p.inventoryLossesByReason, {AdjustmentKind.damage: 21000});
      expect(p.expensesPiasters, 150000);
      expect(p.netProfitPiasters, 300000 - 21000 - 150000);
    },
  );

  test('a voided sale counts in no period (US2-3)', () async {
    final id = await sell(10);
    await env.sales.voidSale(id, 'خطأ');
    expect((await profit()).netSalesPiasters, 0);
    expect((await profit(_september)).netSalesPiasters, 0);
  });

  test('a return counts in the month it is made (US2-4)', () async {
    final sale = await sell(10);
    // No screen makes returns yet; the reports count any that exist.
    await env.products.db.customStatement(
      'INSERT INTO sale_returns (id, number, sales_invoice_id, '
      'total_refund_piasters, total_cost_piasters, refund_paid_piasters, '
      "created_at) VALUES ('r1', 1, ?, 30000, 21000, 30000, ?)",
      [sale, DateTime.utc(2026, 10, 25, 9).millisecondsSinceEpoch],
    );
    final p = await profit();
    expect(p.netSalesPiasters, 100000 - 30000);
    expect(p.costOfGoodsPiasters, 70000 - 21000);
    final sept = await profit(_september);
    expect(sept.isEmpty, isTrue);
  });

  test('an empty period shows zeros (US2-5)', () async {
    await sell(1);
    final p = await profit(_september);
    expect(p, ProfitSummary.empty);
    expect(p.isEmpty, isTrue);
  });

  test('costs above sales are a loss (US2-6)', () async {
    await sell(1); // profit 30.00
    await expense(5000);
    final p = await profit();
    expect(p.netProfitPiasters, -2000);
    expect(p.isLoss, isTrue);
  });

  test('stock found by a count lowers losses; a net gain raises profit '
      '(FR-012)', () async {
    await adjust(() => damage('1')); // loss 70.00, stock 999
    await adjust(() => counted('1002')); // gain 3 × 70.00 = 210.00
    final p = await profit();
    expect(p.inventoryLossesByReason, {
      AdjustmentKind.damage: 7000,
      AdjustmentKind.count: -21000,
    });
    expect(p.inventoryLossesPiasters, -14000);
    expect(p.netProfitPiasters, 14000);
  });

  test('a sale below cost lowers gross profit; a line with no cost is '
      'flagged', () async {
    await sell(1, pricePiasters: 5000); // cost 70.00
    final free = await env.products.addProduct('هدية', price: '10');
    await env.sales.create(
      await env.draftFor({free: one}),
      acknowledgeShortage: true,
    );
    final p = await profit();
    expect(p.grossProfitPiasters, 5000 - 7000 + 1000);
    expect(p.linesWithoutCost, 1);
  });

  test(
    'property: every line equals a hand sum to the piaster (SC-004)',
    () async {
      final rnd = Random(2);
      var sales = 0, cost = 0, losses = 0, expenses = 0, count = 0;
      for (var i = 0; i < 40; i++) {
        switch (rnd.nextInt(4)) {
          case 0:
            final units = 1 + rnd.nextInt(5);
            final price = 5000 + rnd.nextInt(10000);
            final id = await sell(units, pricePiasters: price);
            if (rnd.nextInt(5) == 0) {
              await env.sales.voidSale(id, 'خطأ');
            } else {
              sales += units * price;
              cost += units * 7000;
              count++;
            }
          case 1:
            final units = 1 + rnd.nextInt(3);
            await adjust(() => damage('$units'));
            losses += units * 7000;
          case 2:
            final amount = 1 + rnd.nextInt(100000);
            final voided = rnd.nextBool();
            await expense(amount, voided: voided);
            if (!voided) expenses += amount;
          case 3:
            await expense(
              1 + rnd.nextInt(1000),
              spentAt: DateTime.utc(2026, 9, 15, 9),
            );
        }
      }
      final p = await profit();
      expect(p.netSalesPiasters, sales);
      expect(p.costOfGoodsPiasters, cost);
      expect(p.inventoryLossesPiasters, losses);
      expect(p.expensesPiasters, expenses);
      expect(p.salesCount, count);
      expect(p.netProfitPiasters, sales - cost - losses - expenses);
    },
  );
}
