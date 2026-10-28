import 'package:equatable/equatable.dart';

import '../../../core/utils/clock.dart';
import '../../../core/utils/result.dart';

enum ReportPeriodKind {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  lastMonth,
  custom,
}

/// Why a custom range is refused.
enum PeriodInvalid { endBeforeStart, inFuture }

/// A report period: whole local days from [from] to [to], both included
/// (FR-001, FR-002, research R10). The week starts on Saturday.
final class ReportPeriod extends Equatable {
  const ReportPeriod._(this.kind, this.from, this.to);

  /// A fixed period, by the phone's local calendar today.
  factory ReportPeriod.of(ReportPeriodKind kind, Clock clock) {
    final today = _today(clock);
    DateTime day(int offset) =>
        DateTime(today.year, today.month, today.day + offset);
    return switch (kind) {
      ReportPeriodKind.today => ReportPeriod._(kind, today, today),
      ReportPeriodKind.yesterday => ReportPeriod._(kind, day(-1), day(-1)),
      ReportPeriodKind.thisWeek => ReportPeriod._(
        kind,
        day(-((today.weekday - DateTime.saturday) % 7)),
        today,
      ),
      ReportPeriodKind.thisMonth => ReportPeriod._(
        kind,
        DateTime(today.year, today.month),
        today,
      ),
      ReportPeriodKind.lastMonth => ReportPeriod._(
        kind,
        DateTime(today.year, today.month - 1),
        DateTime(today.year, today.month, 0),
      ),
      ReportPeriodKind.custom => throw ArgumentError.value(
        kind,
        'kind',
        'use ReportPeriod.custom',
      ),
    };
  }

  /// Two dates the owner picked; their times are ignored.
  static Result<ReportPeriod, PeriodInvalid> custom(
    DateTime from,
    DateTime to,
    Clock clock,
  ) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (end.isBefore(start)) return const Err(PeriodInvalid.endBeforeStart);
    if (end.isAfter(_today(clock))) return const Err(PeriodInvalid.inFuture);
    return Ok(ReportPeriod._(ReportPeriodKind.custom, start, end));
  }

  final ReportPeriodKind kind;

  /// Local midnight of the first day.
  final DateTime from;

  /// Local midnight of the last day.
  final DateTime to;

  /// `[start of the first day, start of the day after the last)`, in UTC.
  ({DateTime startUtc, DateTime endUtc}) range() => (
    startUtc: from.toUtc(),
    endUtc: DateTime(to.year, to.month, to.day + 1).toUtc(),
  );

  static DateTime _today(Clock clock) {
    final now = clock.nowUtc().toLocal();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  List<Object?> get props => [kind, from, to];
}
