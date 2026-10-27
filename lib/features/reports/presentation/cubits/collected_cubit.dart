import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/report_period.dart';
import '../../domain/report_types.dart';
import '../../domain/reports_repository.dart';
import 'report_period_cubit.dart';

final class CollectedState extends Equatable {
  const CollectedState({
    required this.period,
    this.summary,
    this.loadFailed = false,
  });

  final ReportPeriod period;

  /// Null while loading.
  final CollectedSummary? summary;

  /// The stream failed; [CollectedCubit.retry] tries again.
  final bool loadFailed;

  @override
  List<Object?> get props => [period, summary, loadFailed];
}

/// Money collected in the chosen period, by method (US5, FR-013). Follows
/// the period and the records live.
class CollectedCubit extends Cubit<CollectedState> {
  CollectedCubit(this._repository, ReportPeriodCubit periods)
    : super(CollectedState(period: periods.state)) {
    _periods = periods.stream.listen(_show);
    _subscribe();
  }

  final ReportsRepository _repository;
  late final StreamSubscription<ReportPeriod> _periods;
  StreamSubscription<CollectedSummary>? _subscription;

  void retry() => _subscribe();

  void _show(ReportPeriod period) {
    emit(CollectedState(period: period));
    _subscribe();
  }

  void _subscribe() {
    unawaited(_subscription?.cancel());
    final period = state.period;
    if (state.loadFailed) emit(CollectedState(period: period));
    _subscription = _repository
        .watchCollected(period)
        .listen(
          (summary) => emit(CollectedState(period: period, summary: summary)),
          onError: (Object error, StackTrace stack) {
            emit(
              CollectedState(
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
