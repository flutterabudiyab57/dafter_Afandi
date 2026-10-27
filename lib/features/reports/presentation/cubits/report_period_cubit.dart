import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/clock.dart';
import '../../../../core/utils/result.dart';
import '../../domain/report_period.dart';

/// The period the report screens show (FR-001). This month to start.
class ReportPeriodCubit extends Cubit<ReportPeriod> {
  ReportPeriodCubit(this._clock)
    : super(ReportPeriod.of(ReportPeriodKind.thisMonth, _clock));

  final Clock _clock;

  /// A fixed period: anything but [ReportPeriodKind.custom].
  void choose(ReportPeriodKind kind) => emit(ReportPeriod.of(kind, _clock));

  /// Two picked dates. Returns why they are refused, or null.
  PeriodInvalid? chooseRange(DateTime from, DateTime to) {
    switch (ReportPeriod.custom(from, to, _clock)) {
      case Ok(:final value):
        emit(value);
        return null;
      case Err(:final error):
        return error;
    }
  }
}
