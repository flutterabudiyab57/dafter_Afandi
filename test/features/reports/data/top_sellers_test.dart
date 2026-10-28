import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/reports/data/reports_repository_impl.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/reports/domain/report_types.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import '../../purchases/data/purchases_env.dart';
import '../../sales/data/sales_env.dart' show one;

void main() {
  late PurchasesEnv env;
  late String pen;
  late String rice;
  late String paper;

  // Records are made from 2026-10-20 09:00 UTC (StepClock).
  final clock = FixedClock(DateTime.utc(2026, 10, 20, 10));
  late ReportsRepositoryImpl reports;

  Future<List<TopSeller>> top(TopSellerOrder order) => reports
      .watchTopSellers(
        ReportPeriod.of(ReportPeriodKind.thisMonth, clock),
        order,
      )
      .first;

  setUp(() async {
    env = PurchasesEnv();
    reports = ReportsRepositoryImpl(env.products.db.reportsDao, clock);
    // 50.00 a piece.
    pen = await env.products.addProduct(
      'قلم',
      price: '50',
      openingQty: '100',
      openingCost: '30',
    );
    // 40.00 a kg.
    rice = await env.products.addProduct(
      'أرز',
      unit: UnitType.kg,
      price: '40',
      openingQty: '100',
      openingCost: '30',
    );
    // 5.00 a piece.
    paper = await env.products.addProduct(
      'ورق',
      price: '5',
      openingQty: '100',
      openingCost: '3',
    );
  });
  tearDown(() => env.dispose());

  Future<String> sell(Map<String, int> qty) async {
    final d = await env.sales.draftFor(qty);
    return okValue<SaleSaved, SaleSaveError>(await env.sales.sales.create(d))
        .id;
  }

  /// Returns [qtyMilli] of the sale's line for [productId], refunding
  /// [refundPiasters] in cash.
  Future<void> returnLine(
    String saleId,
    String productId,
    int qtyMilli,
    int refundPiasters,
  ) async {
    final db = env.products.db;
    final item =
        await (db.select(db.saleItems)..where(
              (i) =>
                  i.salesInvoiceId.equals(saleId) &
                  i.productId.equals(productId),
            ))
            .getSingle();
    final at = DateTime.utc(2026, 10, 20, 12);
    final id = 'r-$saleId-$productId';
    await db
        .into(db.saleReturns)
        .insert(
          SaleReturnsCompanion.insert(
            id: id,
            number: 1,
            salesInvoiceId: saleId,
            totalRefundPiasters: refundPiasters,
            totalCostPiasters: 0,
            refundPaidPiasters: refundPiasters,
            createdAt: at,
          ),
        );
    await db
        .into(db.saleReturnItems)
        .insert(
          SaleReturnItemsCompanion.insert(
            id: '$id-1',
            saleReturnId: id,
            saleItemId: item.id,
            productId: productId,
            qtyMilli: qtyMilli,
            unitPricePiasters: item.unitPricePiasters,
            unitCostPiasters: item.unitCostPiasters,
            refundPiasters: refundPiasters,
            costPiasters: 0,
            createdAt: at,
          ),
        );
  }

  test('by value and by quantity, largest first', () async {
    await sell({pen: 2 * one, rice: 1500, paper: 10 * one});
    // pen 100.00 / 2, rice 60.00 / 1.5 kg, paper 50.00 / 10.
    final byValue = await top(TopSellerOrder.value);
    expect(byValue.map((t) => t.name), ['قلم', 'أرز', 'ورق']);
    expect(byValue.first.netSalesPiasters, 10000);
    expect(byValue[1].unit, UnitType.kg);
    expect(byValue[1].qtyMilli, 1500);

    final byQty = await top(TopSellerOrder.quantity);
    expect(byQty.map((t) => t.name), ['ورق', 'قلم', 'أرز']);
  });

  test('returns are subtracted; voided sales do not count', () async {
    final s = await sell({pen: 3 * one});
    await returnLine(s, pen, one, 5000);
    final voided = await sell({paper: 10 * one});
    await env.sales.sales.voidSale(voided, 'خطأ');

    final rows = await top(TopSellerOrder.value);
    expect(rows.single.name, 'قلم');
    expect(rows.single.qtyMilli, 2000);
    expect(rows.single.netSalesPiasters, 10000);
  });

  test('a product fully returned is not listed', () async {
    final s = await sell({pen: one, paper: one});
    await returnLine(s, pen, one, 5000);
    expect((await top(TopSellerOrder.value)).map((t) => t.name), ['ورق']);
  });

  test('archived products are still listed; at most ten', () async {
    await sell({pen: one});
    await env.products.productRepo.archive(pen);
    expect((await top(TopSellerOrder.value)).single.productId, pen);

    for (var i = 0; i < 11; i++) {
      final p = await env.products.addProduct(
        'صنف $i',
        price: '1',
        openingQty: '5',
        openingCost: '1',
      );
      await sell({p: one});
    }
    expect(await top(TopSellerOrder.value), hasLength(10));
  });

  test(
    'suppliers owed: largest first; settled and in-favour left out',
    () async {
      final a = await env.addSupplier('مورد أ', opening: '300');
      await env.addSupplier('مورد ب', opening: '700');
      await env.addSupplier('مورد ج');
      await env.addSupplier('مورد د', opening: '100', inShopFavour: true);
      await env.suppliers.archive(a);

      final rows = await reports.watchSuppliersOwed().first;
      expect(rows.map((r) => r.name), ['مورد ب', 'مورد أ']);
      expect(rows.map((r) => r.balancePiasters), [70000, 30000]);
      expect(rows.last.archived, isTrue);
    },
  );
}
