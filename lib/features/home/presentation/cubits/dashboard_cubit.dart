import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/clock.dart';
import '../../../reports/domain/report_period.dart';
import '../../../reports/domain/report_types.dart';
import '../../../reports/domain/reports_repository.dart';

final class DashboardState extends Equatable {
  const DashboardState({this.snapshot, this.loadFailed = false});

  /// Null while loading.
  final DashboardSnapshot? snapshot;

  /// The stream failed; [DashboardCubit.retry] tries again.
  final bool loadFailed;

  @override
  List<Object?> get props => [snapshot, loadFailed];
}

/// Today on the home screen (US1). Follows the records live (FR-021) and
/// starts a new day when the app comes back after midnight (research R11).
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository, this._clock)
    : super(const DashboardState()) {
    _lifecycle = AppLifecycleListener(onResume: onResume);
    _subscribe();
  }

  final ReportsRepository _repository;
  final Clock _clock;
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<DashboardSnapshot>? _subscription;
  late DateTime _day;

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  /// Called when the app returns to the foreground.
  @visibleForTesting
  void onResume() {
    if (_today() != _day) _subscribe();
  }

  DateTime _today() => ReportPeriod.of(ReportPeriodKind.today, _clock).from;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _day = _today();
    if (state.loadFailed) emit(DashboardState(snapshot: state.snapshot));
    _subscription = _repository.watchDashboard().listen(
      (snapshot) => emit(DashboardState(snapshot: snapshot)),
      onError: (Object error, StackTrace stack) {
        emit(DashboardState(snapshot: state.snapshot, loadFailed: true));
        addError(error, stack);
      },
    );
  }

  @override
  Future<void> close() async {
    _lifecycle.dispose();
    await _subscription?.cancel();
    return super.close();
  }
}
