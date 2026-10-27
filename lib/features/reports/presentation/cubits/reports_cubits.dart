import 'package:get_it/get_it.dart';

import '../../../../core/utils/clock.dart';
import '../../../home/presentation/cubits/dashboard_cubit.dart';
import '../../domain/reports_repository.dart';
import 'profit_cubit.dart';
import 'report_period_cubit.dart';

/// Builds the dashboard and report cubits (006). The app uses
/// [AppReportsCubits]; widget tests pass a bundle built on fakes.
abstract class ReportsCubits {
  DashboardCubit dashboard();

  /// The period shared by the report screens.
  ReportPeriodCubit reportPeriod();

  ProfitCubit profit(ReportPeriodCubit periods);
}

/// Cubits built on the repositories in [locator].
final class AppReportsCubits implements ReportsCubits {
  const AppReportsCubits(this.locator);

  final GetIt locator;

  @override
  DashboardCubit dashboard() =>
      DashboardCubit(locator<ReportsRepository>(), locator<Clock>());

  @override
  ReportPeriodCubit reportPeriod() => ReportPeriodCubit(locator<Clock>());

  @override
  ProfitCubit profit(ReportPeriodCubit periods) =>
      ProfitCubit(locator<ReportsRepository>(), periods);
}
