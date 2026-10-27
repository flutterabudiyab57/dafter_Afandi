import '../../../core/database/daos/reports_dao.dart';
import '../../../core/utils/clock.dart';
import '../../payments/data/payment_parts_writer.dart';
import '../../payments/domain/payment_method.dart';
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
  Stream<List<BalanceRow>> watchCustomersOwing({int? limit}) =>
      _dao.watchChanges().asyncMap((_) => _owing(limit));

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
