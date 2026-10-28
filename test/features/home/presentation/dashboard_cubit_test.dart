import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/features/home/presentation/cubits/dashboard_cubit.dart';
import 'package:daftar_afandi/features/reports/domain/report_types.dart';
import 'package:daftar_afandi/features/reports/domain/reports_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final class _Reports extends Mock implements ReportsRepository {}

final class _MovableClock implements Clock {
  _MovableClock(this.now);

  DateTime now;

  @override
  DateTime nowUtc() => now;
}

const _one = DashboardSnapshot(
  todaySalesPiasters: 45000,
  todaySalesCount: 3,
  todayCollected: CollectedSummary.empty,
  topDebtors: [],
);
const _two = DashboardSnapshot(
  todaySalesPiasters: 0,
  todaySalesCount: 0,
  todayCollected: CollectedSummary.empty,
  topDebtors: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Reports reports;
  late _MovableClock clock;

  setUp(() {
    reports = _Reports();
    clock = _MovableClock(DateTime.utc(2026, 10, 26, 10));
  });

  blocTest<DashboardCubit, DashboardState>(
    'loads today and follows changes',
    setUp: () =>
        when(() => reports.watchDashboard())
            .thenAnswer((_) => Stream.fromIterable([_one, _two])),
    build: () => DashboardCubit(reports, clock),
    expect: () => const [
      DashboardState(snapshot: _one),
      DashboardState(snapshot: _two),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'a failed load offers retry, which loads',
    setUp: () {
      var calls = 0;
      when(() => reports.watchDashboard()).thenAnswer(
        (_) =>
            calls++ == 0 ? Stream.error(StateError('db')) : Stream.value(_one),
      );
    },
    build: () => DashboardCubit(reports, clock),
    act: (c) async {
      await Future<void>.delayed(Duration.zero);
      c.retry();
    },
    errors: () => [isA<StateError>()],
    expect: () => const [
      DashboardState(loadFailed: true),
      DashboardState(),
      DashboardState(snapshot: _one),
    ],
  );

  blocTest<DashboardCubit, DashboardState>(
    'coming back on a new day reads the new day; the same day does not',
    setUp: () =>
        when(() => reports.watchDashboard())
            .thenAnswer((_) => Stream.value(_one)),
    build: () => DashboardCubit(reports, clock),
    act: (c) async {
      await Future<void>.delayed(Duration.zero);
      c.onResume();
      clock.now = clock.now.add(const Duration(days: 1));
      c.onResume();
    },
    verify: (_) => verify(() => reports.watchDashboard()).called(2),
  );
}
