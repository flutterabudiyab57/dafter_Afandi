import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/features/reports/domain/profit_summary.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/reports/domain/reports_repository.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/profit_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/report_period_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final class _Reports extends Mock implements ReportsRepository {}

final _clock = FixedClock(DateTime(2026, 10, 26, 12).toUtc());
final _month = ReportPeriod.of(ReportPeriodKind.thisMonth, _clock);
final _today = ReportPeriod.of(ReportPeriodKind.today, _clock);
const _sales = ProfitSummary(
  salesPiasters: 1000,
  returnsPiasters: 0,
  saleCostPiasters: 700,
  returnedCostPiasters: 0,
  inventoryLossesByReason: {},
  expensesPiasters: 0,
  salesCount: 1,
  linesWithoutCost: 0,
);

void main() {
  setUpAll(() => registerFallbackValue(_month));

  group('ReportPeriodCubit', () {
    test('starts on this month', () {
      expect(ReportPeriodCubit(_clock).state, _month);
    });

    blocTest<ReportPeriodCubit, ReportPeriod>(
      'chooses a fixed period and a valid range',
      build: () => ReportPeriodCubit(_clock),
      act: (c) {
        c.choose(ReportPeriodKind.today);
        expect(
          c.chooseRange(DateTime(2026, 10, 1), DateTime(2026, 10, 5)),
          isNull,
        );
      },
      expect: () => [
        _today,
        isA<ReportPeriod>()
            .having((p) => p.kind, 'kind', ReportPeriodKind.custom)
            .having((p) => p.to, 'to', DateTime(2026, 10, 5)),
      ],
    );

    blocTest<ReportPeriodCubit, ReportPeriod>(
      'refuses a range ending before it starts or in the future',
      build: () => ReportPeriodCubit(_clock),
      act: (c) {
        expect(
          c.chooseRange(DateTime(2026, 10, 5), DateTime(2026, 10, 1)),
          PeriodInvalid.endBeforeStart,
        );
        expect(
          c.chooseRange(DateTime(2026, 10, 1), DateTime(2026, 10, 30)),
          PeriodInvalid.inFuture,
        );
      },
      expect: () => const <ReportPeriod>[],
    );
  });

  group('ProfitCubit', () {
    late _Reports reports;

    setUp(() {
      reports = _Reports();
      when(() => reports.watchProfit(any()))
          .thenAnswer((_) => Stream.value(_sales));
    });

    blocTest<ProfitCubit, ProfitState>(
      'loads the period and follows a new one',
      build: () => ProfitCubit(reports, ReportPeriodCubit(_clock)),
      act: (_) => Future<void>.delayed(Duration.zero),
      expect: () => [ProfitState(period: _month, summary: _sales)],
    );

    test('a new period reloads', () async {
      final periods = ReportPeriodCubit(_clock);
      final cubit = ProfitCubit(reports, periods);
      await Future<void>.delayed(Duration.zero);
      periods.choose(ReportPeriodKind.today);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, ProfitState(period: _today, summary: _sales));
      verify(() => reports.watchProfit(_month)).called(1);
      verify(() => reports.watchProfit(_today)).called(1);
      await cubit.close();
      await periods.close();
    });

    test('a failed load offers retry', () async {
      var calls = 0;
      when(() => reports.watchProfit(any())).thenAnswer(
        (_) => calls++ == 0
            ? Stream.error(StateError('db'))
            : Stream.value(_sales),
      );
      final periods = ReportPeriodCubit(_clock);
      final cubit = ProfitCubit(reports, periods);
      cubit.stream.handleError((_) {}).listen((_) {});
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.loadFailed, isTrue);
      cubit.retry();
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, ProfitState(period: _month, summary: _sales));
      await cubit.close();
      await periods.close();
    });
  });
}
