import 'report_period.dart';
import 'report_types.dart';

/// Derived numbers for the dashboard and the reports (contracts). Every
/// stream emits again when the records behind it change (FR-021). Later
/// stories add the profit, top sellers and supplier balances.
abstract interface class ReportsRepository {
  /// Today, by the phone's local calendar when subscribed.
  Stream<DashboardSnapshot> watchDashboard();

  Stream<CollectedSummary> watchCollected(ReportPeriod period);

  /// Customers who owe the shop, largest first; all of them when [limit]
  /// is null.
  Stream<List<BalanceRow>> watchCustomersOwing({int? limit});
}
