import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/reports/domain/report_types.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/balances_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/collected_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/report_period_cubit.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/top_sellers_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_reports.dart';

final _clock = FixedClock(DateTime(2026, 10, 26, 12).toUtc());
final _month = ReportPeriod.of(ReportPeriodKind.thisMonth, _clock);
final _today = ReportPeriod.of(ReportPeriodKind.today, _clock);

const _cash = CollectedSummary({PaymentMethod.cash: 30000});
const _pen = TopSeller(
  productId: 'p1',
  name: 'قلم',
  unit: UnitType.piece,
  qtyMilli: 2000,
  netSalesPiasters: 10000,
);
const _paper = TopSeller(
  productId: 'p2',
  name: 'ورق',
  unit: UnitType.piece,
  qtyMilli: 10000,
  netSalesPiasters: 5000,
);
const _mona = BalanceRow(partyId: 'c1', name: 'منى', balancePiasters: 500);
const _ali = BalanceRow(partyId: 's1', name: 'علي', balancePiasters: 700);

void main() {
  late FakeReportsStore store;
  late ReportPeriodCubit periods;

  setUp(() {
    store = FakeReportsStore();
    periods = ReportPeriodCubit(_clock);
  });
  tearDown(() => periods.close());

  group('CollectedCubit', () {
    blocTest<CollectedCubit, CollectedState>(
      'loads, follows the period and the records',
      setUp: () => store.collected = _cash,
      build: () => CollectedCubit(store, periods),
      act: (c) async {
        await Future<void>.delayed(Duration.zero);
        periods.choose(ReportPeriodKind.today);
        await Future<void>.delayed(Duration.zero);
        store.collected = CollectedSummary.empty;
      },
      expect: () => [
        CollectedState(period: _month, summary: _cash),
        CollectedState(period: _today),
        CollectedState(period: _today, summary: _cash),
        CollectedState(period: _today, summary: CollectedSummary.empty),
      ],
    );

    blocTest<CollectedCubit, CollectedState>(
      'a failure shows retry; retry loads',
      setUp: () => store.failNextWatch = StateError('db'),
      build: () => CollectedCubit(store, periods),
      act: (c) async {
        await Future<void>.delayed(Duration.zero);
        c.retry();
      },
      errors: () => [isA<StateError>()],
      expect: () => [
        CollectedState(period: _month, loadFailed: true),
        CollectedState(period: _month),
        CollectedState(period: _month, summary: CollectedSummary.empty),
      ],
    );
  });

  group('TopSellersCubit', () {
    blocTest<TopSellersCubit, TopSellersState>(
      'by value first, then by quantity',
      setUp: () => store.topSellers = {
        TopSellerOrder.value: [_pen, _paper],
        TopSellerOrder.quantity: [_paper, _pen],
      },
      build: () => TopSellersCubit(store, periods),
      act: (c) async {
        await Future<void>.delayed(Duration.zero);
        c
          ..orderBy(TopSellerOrder.value)
          ..orderBy(TopSellerOrder.quantity);
      },
      expect: () => [
        TopSellersState(period: _month, rows: const [_pen, _paper]),
        TopSellersState(period: _month, order: TopSellerOrder.quantity),
        TopSellersState(
          period: _month,
          order: TopSellerOrder.quantity,
          rows: const [_paper, _pen],
        ),
      ],
    );

    blocTest<TopSellersCubit, TopSellersState>(
      'a new period keeps the order',
      build: () => TopSellersCubit(store, periods),
      act: (c) async {
        c.orderBy(TopSellerOrder.quantity);
        await Future<void>.delayed(Duration.zero);
        periods.choose(ReportPeriodKind.today);
        await Future<void>.delayed(Duration.zero);
      },
      skip: 2,
      expect: () => [
        TopSellersState(period: _today, order: TopSellerOrder.quantity),
        TopSellersState(
          period: _today,
          order: TopSellerOrder.quantity,
          rows: const [],
        ),
      ],
    );
  });

  group('BalancesCubit', () {
    blocTest<BalancesCubit, BalancesState>(
      'customers and suppliers, live, with totals',
      setUp: () {
        store
          ..customersOwing = [_mona]
          ..suppliersOwed = [_ali];
      },
      build: () => BalancesCubit(store),
      act: (c) async {
        await Future<void>.delayed(Duration.zero);
        store.suppliersOwed = const [];
      },
      expect: () => [
        const BalancesState(customers: [_mona]),
        const BalancesState(customers: [_mona], suppliers: [_ali]),
        const BalancesState(customers: [_mona], suppliers: []),
      ],
      verify: (c) {
        expect(BalancesState.total(const [_mona, _ali]), 1200);
      },
    );
  });
}
