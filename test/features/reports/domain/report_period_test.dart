import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

/// A clock at a local wall time, so the tests hold in any time zone.
Clock _at(int y, int m, int d, [int h = 12, int min = 0]) =>
    FixedClock(DateTime(y, m, d, h, min).toUtc());

ReportPeriod _of(ReportPeriodKind kind, Clock clock) =>
    ReportPeriod.of(kind, clock);

void main() {
  // 2026-10-24 is a Saturday, 2026-10-30 a Friday.
  test('today and yesterday', () {
    final clock = _at(2026, 10, 26);
    expect(_of(ReportPeriodKind.today, clock).from, DateTime(2026, 10, 26));
    expect(_of(ReportPeriodKind.today, clock).to, DateTime(2026, 10, 26));
    expect(_of(ReportPeriodKind.yesterday, clock).from, DateTime(2026, 10, 25));
    expect(
      _of(ReportPeriodKind.yesterday, _at(2026, 11, 1)).to,
      DateTime(2026, 10, 31),
    );
  });

  test('the week starts on Saturday', () {
    for (final (day, start) in [
      (24, 24), // Saturday
      (26, 24), // Monday
      (30, 24), // Friday
      (31, 31), // the next Saturday
    ]) {
      final week = _of(ReportPeriodKind.thisWeek, _at(2026, 10, day));
      expect(week.from, DateTime(2026, 10, start), reason: 'day $day');
      expect(week.to, DateTime(2026, 10, day));
    }
  });

  test('this month and last month, on the 1st and across a year end', () {
    final first = _at(2026, 11, 1);
    expect(_of(ReportPeriodKind.thisMonth, first).from, DateTime(2026, 11));
    expect(_of(ReportPeriodKind.thisMonth, first).to, DateTime(2026, 11));
    final last = _of(ReportPeriodKind.lastMonth, _at(2027, 1, 15));
    expect(last.from, DateTime(2026, 12));
    expect(last.to, DateTime(2026, 12, 31));
    final feb = _of(ReportPeriodKind.lastMonth, _at(2028, 3, 31));
    expect(feb.to, DateTime(2028, 2, 29));
  });

  test('range covers whole local days; 23:59 and 00:00 fall apart', () {
    final today = _of(ReportPeriodKind.today, _at(2026, 10, 26, 0, 0));
    final r = today.range();
    expect(r.startUtc, DateTime(2026, 10, 26).toUtc());
    expect(r.endUtc, DateTime(2026, 10, 27).toUtc());
    final lateYesterday = DateTime(2026, 10, 25, 23, 59).toUtc();
    expect(lateYesterday.isBefore(r.startUtc), isTrue);
    final lateToday = DateTime(2026, 10, 26, 23, 59).toUtc();
    expect(lateToday.isBefore(r.endUtc), isTrue);
  });

  test('a custom range refuses an end before the start and the future', () {
    final clock = _at(2026, 10, 26);
    expect(
      ReportPeriod.custom(DateTime(2026, 10, 5), DateTime(2026, 10, 1), clock),
      const Err<ReportPeriod, PeriodInvalid>(PeriodInvalid.endBeforeStart),
    );
    expect(
      ReportPeriod.custom(DateTime(2026, 10, 1), DateTime(2026, 10, 27), clock),
      const Err<ReportPeriod, PeriodInvalid>(PeriodInvalid.inFuture),
    );
    final ok = ReportPeriod.custom(
      DateTime(2026, 10, 1, 15),
      DateTime(2026, 10, 26, 9),
      clock,
    );
    expect(
      switch (ok) {
        Ok(:final value) => (value.from, value.to),
        Err() => null,
      },
      (DateTime(2026, 10, 1), DateTime(2026, 10, 26)),
    );
  });

  test('custom is not a fixed kind', () {
    expect(
      () => _of(ReportPeriodKind.custom, _at(2026, 10, 26)),
      throwsArgumentError,
    );
  });
}
