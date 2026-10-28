import '../../../core/database/daos/reports_dao.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/money.dart';
import '../../payments/data/payment_parts_writer.dart';
import '../../payments/domain/payment_method.dart';
import '../../products/data/mappers.dart';
import '../../products/domain/stock_entry.dart';
import '../domain/profit_summary.dart';
import '../domain/report_period.dart';
import '../domain/report_types.dart';
import '../domain/reports_repository.dart';

/// Reports on the live database (006 research R8, R11): each stream reloads
/// its numbers whenever a table it reads changes.
final class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._dao, this._clock);

  final ReportsDao _dao;
  final Clock _clock;

  @override
  Stream<DashboardSnapshot> watchDashboard() {
    final today = ReportPeriod.of(ReportPeriodKind.today, _clock).range();
    return _dao.watchChanges().asyncMap((_) async {
      final sales = await _dao.salesTotals(today.startUtc, today.endUtc);
      return DashboardSnapshot(
        todaySalesPiasters: sales.netPiasters,
        todaySalesCount: sales.count,
        todayCollected: await _collected(today.startUtc, today.endUtc),
        topDebtors: await _owing(3),
      );
    });
  }

  @override
  Stream<CollectedSummary> watchCollected(ReportPeriod period) {
    final r = period.range();
    return _dao.watchChanges().asyncMap(
      (_) => _collected(r.startUtc, r.endUtc),
    );
  }

  @override
  Stream<ProfitSummary> watchProfit(ReportPeriod period) {
    final r = period.range();
    return _dao.watchChanges().asyncMap((_) async {
      final t = await _dao.profitTotals(r.startUtc, r.endUtc);
      final adjustments = await _dao.adjustments(r.startUtc, r.endUtc);
      final losses = <AdjustmentKind, int>{};
      for (final a in adjustments) {
        final kind = ProductMappers.adjustmentKind(a.reason);
        // Removed stock is a loss (positive); stock found is a gain.
        final value = roundHalfUpDiv(
          -a.qtyDeltaMilli * a.unitCostPiasters,
          1000,
        );
        losses[kind] = (losses[kind] ?? 0) + value;
      }
      return ProfitSummary(
        salesPiasters: t.salesPiasters,
        returnsPiasters: t.returnsPiasters,
        saleCostPiasters: t.saleCostPiasters,
        returnedCostPiasters: t.returnedCostPiasters,
        inventoryLossesByReason: losses,
        expensesPiasters: t.expensesPiasters,
        salesCount: t.salesCount,
        linesWithoutCost: t.linesWithoutCost,
        hasAdjustments: adjustments.isNotEmpty,
        hasReturns: t.returnCount > 0,
      );
    });
  }

  @override
  Stream<List<BalanceRow>> watchCustomersOwing({int? limit}) =>
      _dao.watchChanges().asyncMap((_) => _owing(limit));

  @override
  Stream<List<TopSeller>> watchTopSellers(
    ReportPeriod period,
    TopSellerOrder order,
  ) {
    final r = period.range();
    return _dao.watchChanges().asyncMap(
      (_) async => [
        for (final t in await _dao.topSellers(
          r.startUtc,
          r.endUtc,
          byQuantity: order == TopSellerOrder.quantity,
        ))
          TopSeller(
            productId: t.productId,
            name: t.name,
            unit: t.unit,
            qtyMilli: t.qtyMilli,
            netSalesPiasters: t.netPiasters,
          ),
      ],
    );
  }

  @override
  Stream<List<BalanceRow>> watchSuppliersOwed() => _dao.watchChanges().asyncMap(
    (_) async => [
      for (final r in await _dao.suppliersOwed())
        BalanceRow(
          partyId: r.id,
          name: r.name,
          balancePiasters: r.balancePiasters,
          archived: r.archived,
        ),
    ],
  );

  Future<CollectedSummary> _collected(DateTime start, DateTime end) async {
    final rows = await _dao.collected(start, end);
    return CollectedSummary(<PaymentMethod, int>{
      for (final MapEntry(key: m, value: amount) in rows.entries)
        if (amount != 0) PaymentMappers.method(m): amount,
    });
  }

  Future<List<BalanceRow>> _owing(int? limit) async => [
    for (final r in await _dao.customersOwing(limit: limit))
      BalanceRow(
        partyId: r.id,
        name: r.name,
        balancePiasters: r.balancePiasters,
        archived: r.archived,
      ),
  ];
}
