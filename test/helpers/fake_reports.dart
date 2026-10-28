import 'dart:async';

import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/features/home/presentation/cubits/dashboard_cubit.dart';
import 'package:daftar_afandi/features/reports/domain/profit_summary.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/reports/domain/report_types.dart';
import 'package:daftar_afandi/features/reports/domain/reports_repository.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/balances_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/collected_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/profit_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/report_period_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/reports_cubits.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/top_sellers_cubit.dart';

const DashboardSnapshot kEmptyDashboard = DashboardSnapshot(
  todaySalesPiasters: 0,
  todaySalesCount: 0,
  todayCollected: CollectedSummary.empty,
  topDebtors: [],
);

/// An in-memory [ReportsRepository]: tests set the numbers, and every
/// subscriber sees each change.
final class FakeReportsStore implements ReportsRepository {
  FakeReportsStore([this._dashboard = kEmptyDashboard]);

  DashboardSnapshot _dashboard;
  final StreamController<void> _changes = StreamController.broadcast();

  /// When set, the next subscription fails with it.
  Object? failNextWatch;

  ProfitSummary _profit = ProfitSummary.empty;

  /// The periods the profit report asked for, in order.
  final List<ReportPeriod> profitPeriods = [];

  ProfitSummary get profit => _profit;

  set profit(ProfitSummary value) {
    _profit = value;
    _changes.add(null);
  }

  CollectedSummary? _collected;

  /// What money collected shows; today's on the dashboard when unset.
  set collected(CollectedSummary value) {
    _collected = value;
    _changes.add(null);
  }

  List<BalanceRow>? _customersOwing;

  /// Every customer who owes; the dashboard's top debtors when unset.
  set customersOwing(List<BalanceRow> value) {
    _customersOwing = value;
    _changes.add(null);
  }

  List<BalanceRow> _suppliersOwed = const [];

  set suppliersOwed(List<BalanceRow> value) {
    _suppliersOwed = value;
    _changes.add(null);
  }

  Map<TopSellerOrder, List<TopSeller>> _topSellers = const {};

  /// The top sellers for each order.
  set topSellers(Map<TopSellerOrder, List<TopSeller>> value) {
    _topSellers = value;
    _changes.add(null);
  }

  DashboardSnapshot get dashboard => _dashboard;

  set dashboard(DashboardSnapshot value) {
    _dashboard = value;
    _changes.add(null);
  }

  Stream<T> _watch<T>(T Function() read) async* {
    if (failNextWatch case final error?) {
      failNextWatch = null;
      throw error;
    }
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  @override
  Stream<DashboardSnapshot> watchDashboard() => _watch(() => _dashboard);

  @override
  Stream<ProfitSummary> watchProfit(ReportPeriod period) {
    profitPeriods.add(period);
    return _watch(() => _profit);
  }

  @override
  Stream<CollectedSummary> watchCollected(ReportPeriod period) =>
      _watch(() => _collected ?? _dashboard.todayCollected);

  @override
  Stream<List<BalanceRow>> watchCustomersOwing({int? limit}) =>
      _watch(() => _customersOwing ?? _dashboard.topDebtors);

  @override
  Stream<List<TopSeller>> watchTopSellers(
    ReportPeriod period,
    TopSellerOrder order,
  ) => _watch(() => _topSellers[order] ?? const []);

  @override
  Stream<List<BalanceRow>> watchSuppliersOwed() => _watch(() => _suppliersOwed);
}

final class FakeReportsCubits implements ReportsCubits {
  FakeReportsCubits([FakeReportsStore? store, Clock? clock])
    : store = store ?? FakeReportsStore(),
      clock = clock ?? FixedClock(DateTime.utc(2026, 10, 26, 10));

  final FakeReportsStore store;
  final Clock clock;

  @override
  DashboardCubit dashboard() => DashboardCubit(store, clock);

  @override
  ReportPeriodCubit reportPeriod() => ReportPeriodCubit(clock);

  @override
  ProfitCubit profit(ReportPeriodCubit periods) => ProfitCubit(store, periods);

  @override
  CollectedCubit collected(ReportPeriodCubit periods) =>
      CollectedCubit(store, periods);

  @override
  TopSellersCubit topSellers(ReportPeriodCubit periods) =>
      TopSellersCubit(store, periods);

  @override
  BalancesCubit balances() => BalancesCubit(store);
}
