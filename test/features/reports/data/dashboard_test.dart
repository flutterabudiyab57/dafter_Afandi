import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/reports/data/reports_repository_impl.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/reports/domain/report_types.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import '../../purchases/data/purchases_env.dart';
import '../../sales/data/sales_env.dart' show one;

void main() {
  late PurchasesEnv env;
  late String pen;

  // Records are made from 2026-10-20 09:00 UTC (StepClock); "today" is
  // that day in any time zone from UTC-9 to UTC+14.
  final today = FixedClock(DateTime.utc(2026, 10, 20, 10));
  final tomorrow = FixedClock(DateTime.utc(2026, 10, 21, 10));

  ReportsRepositoryImpl reports([Clock? clock]) =>
      ReportsRepositoryImpl(env.products.db.reportsDao, clock ?? today);

  Future<DashboardSnapshot> dashboard([Clock? clock]) =>
      reports(clock).watchDashboard().first;

  setUp(() async {
    env = PurchasesEnv();
    // 50.00 each.
    pen = await env.products.addProduct(
      'قلم',
      price: '50',
      openingQty: '100',
      openingCost: '30',
    );
  });
  tearDown(() => env.dispose());

  Future<String> sell(
    int units, {
    PaymentMethod method = PaymentMethod.cash,
    SaleCustomer? customer,
    int? paid,
  }) async {
    final d = (await env.sales.draftFor({
      pen: units * one,
    }, customer: customer)).withMethod(method).withPaid(paid);
    return okValue<SaleSaved, SaleSaveError>(await env.sales.sales.create(d))
        .id;
  }

  PaymentRequest request(String amount, PaymentMethod method) =>
      okValue<PaymentRequest, List<CustomerFieldError>>(
        PaymentRequest.create(amountText: amount, method: method),
      );

  test('today: three sales of 450.00; a voided one does not count', () async {
    for (var i = 0; i < 3; i++) {
      await sell(3);
    }
    final voided = await sell(2);
    await env.sales.sales.voidSale(voided, 'خطأ');

    final d = await dashboard();
    expect(d.todaySalesPiasters, 45000);
    expect(d.todaySalesCount, 3);
    expect(d.todayCollected.totalPiasters, 45000);
  });

  test('collected: a cash sale and a customer payment, by method', () async {
    await sell(4); // 200.00 cash
    final mona = await env.sales.addCustomer('منى', opening: '500');
    await env.sales.customers.receivePayment(
      mona,
      request('300', PaymentMethod.wallet),
    );
    await sell(1, method: PaymentMethod.instapay);

    final c = (await dashboard()).todayCollected;
    expect(c.of(PaymentMethod.cash), 20000);
    expect(c.of(PaymentMethod.wallet), 30000);
    expect(c.of(PaymentMethod.instapay), 5000);
    expect(c.totalPiasters, 55000);
  });

  test('a credit sale collects only what was paid; a cancelled receipt '
      'collects nothing', () async {
    final mona = await env.sales.addCustomer('منى');
    await sell(
      4,
      customer: SaleCustomer(id: mona, name: 'منى'),
      paid: 5000,
    );
    await env.sales.customers.receivePayment(
      mona,
      request('70', PaymentMethod.cash),
    );
    final receipt = (await env.sales.statement(mona)).firstWhere(
      (e) => e.type == LedgerEntryType.payment && e.receiptNumber != null,
    );
    await env.sales.customers.cancelPayment(receipt.id, 'خطأ');

    final d = await dashboard();
    expect(d.todaySalesPiasters, 20000);
    expect(d.todayCollected.totalPiasters, 5000);
  });

  test('top debtors: the three who owe most, largest first', () async {
    for (final (name, owes) in [
      ('أ', '100'),
      ('ب', '500'),
      ('ج', '300'),
      ('د', '50'),
      ('ه', '400'),
    ]) {
      await env.sales.addCustomer(name, opening: owes);
    }
    await env.sales.addCustomer('دائن', opening: '900', inFavour: true);

    final top = (await dashboard()).topDebtors;
    expect(top.map((r) => (r.name, r.balancePiasters)), [
      ('ب', 50000),
      ('ه', 40000),
      ('ج', 30000),
    ]);
    final all = await reports().watchCustomersOwing().first;
    expect(all, hasLength(5));
  });

  test('a new shop shows zeros', () async {
    final d = await dashboard();
    expect(d.todaySalesPiasters, 0);
    expect(d.todaySalesCount, 0);
    expect(d.todayCollected, CollectedSummary.empty);
    expect(d.topDebtors, isEmpty);
  });

  test("yesterday's sales are not today's", () async {
    await sell(2);
    final d = await dashboard(tomorrow);
    expect(d.todaySalesCount, 0);
    expect(d.todayCollected.totalPiasters, 0);
    final yesterday = await reports(tomorrow)
        .watchCollected(ReportPeriod.of(ReportPeriodKind.yesterday, tomorrow))
        .first;
    expect(yesterday.totalPiasters, 10000);
  });

  test('the dashboard updates when a sale is saved', () async {
    final seen = <int>[];
    final sub = reports().watchDashboard().listen(
      (d) => seen.add(d.todaySalesCount),
    );
    await pumpEventQueue();
    await sell(1);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.first, 0);
    expect(seen.last, 1);
  });
}
