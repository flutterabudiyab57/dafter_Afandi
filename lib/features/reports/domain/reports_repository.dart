import 'profit_summary.dart';
import 'report_period.dart';
import 'report_types.dart';

/// Derived numbers for the dashboard and the reports (contracts). Every
/// stream emits again when the records behind it change (FR-021).
abstract interface class ReportsRepository {
  /// Today, by the phone's local calendar when subscribed.
  Stream<DashboardSnapshot> watchDashboard();

  Stream<ProfitSummary> watchProfit(ReportPeriod period);

  Stream<CollectedSummary> watchCollected(ReportPeriod period);

  /// Customers who owe the shop, largest first; all of them when [limit]
  /// is null.
  Stream<List<BalanceRow>> watchCustomersOwing({int? limit});

  /// Up to ten products sold in [period], in [order], largest first.
  Stream<List<TopSeller>> watchTopSellers(
    ReportPeriod period,
    TopSellerOrder order,
  );

  /// Suppliers the shop owes, largest first.
  Stream<List<BalanceRow>> watchSuppliersOwed();
}
