import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/profit_summary.dart';
import '../../domain/report_period.dart';
import '../../domain/reports_repository.dart';
import 'report_period_cubit.dart';

final class ProfitState extends Equatable {
  const ProfitState({
    required this.period,
    this.summary,
    this.loadFailed = false,
  });

  final ReportPeriod period;

  /// Null while loading.
  final ProfitSummary? summary;

  /// The stream failed; [ProfitCubit.retry] tries again.
  final bool loadFailed;

  @override
  List<Object?> get props => [period, summary, loadFailed];
}

/// The profit report for the chosen period (US2). Follows the period and
/// the records live.
class ProfitCubit extends Cubit<ProfitState> {
  ProfitCubit(this._repository, ReportPeriodCubit periods)
    : super(ProfitState(period: periods.state)) {
    _periods = periods.stream.listen(_show);
    _subscribe();
  }

  final ReportsRepository _repository;
  late final StreamSubscription<ReportPeriod> _periods;
  StreamSubscription<ProfitSummary>? _subscription;

  void retry() => _subscribe();

  void _show(ReportPeriod period) {
    emit(ProfitState(period: period));
    _subscribe();
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    final period = state.period;
    if (state.loadFailed) emit(ProfitState(period: period));
    _subscription = _repository
        .watchProfit(period)
        .listen(
          (summary) => emit(ProfitState(period: period, summary: summary)),
          onError: (Object error, StackTrace stack) {
            emit(
              ProfitState(
                period: period,
                summary: state.summary,
                loadFailed: true,
              ),
            );
            addError(error, stack);
          },
        );
  }

  @override
  Future<void> close() async {
    await _periods.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
