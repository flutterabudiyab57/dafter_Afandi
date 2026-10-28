import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/reports/domain/report_types.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';
import '../../../helpers/fake_purchases.dart';
import '../../../helpers/fake_reports.dart';
import '../../../helpers/fake_sales.dart';
import '../../../helpers/pump_app.dart';

const _busy = DashboardSnapshot(
  todaySalesPiasters: 45000,
  todaySalesCount: 3,
  todayCollected: CollectedSummary({
    PaymentMethod.cash: 20000,
    PaymentMethod.wallet: 30000,
  }),
  topDebtors: [
    BalanceRow(partyId: 'c2', name: 'بسمة', balancePiasters: 52000),
    BalanceRow(partyId: 'c5', name: 'هالة', balancePiasters: 40000),
    BalanceRow(partyId: 'c3', name: 'جمال', balancePiasters: 30000),
  ],
);

/// US1: today at a glance (spec scenarios 1–6).
void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    String digits(String latin) => locale == AppLocale.ar
        ? latin
              .replaceAllMapped(
                RegExp('[0-9]'),
                (m) => String.fromCharCode(0x0660 + int.parse(m[0]!)),
              )
              .replaceAll('.', '٫')
        : latin;

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeReportsStore reports;
        late FakeProductsStore products;
        late FakeSalesStore sales;

        setUp(() {
          reports = FakeReportsStore();
          products = FakeProductsStore();
          sales = FakeSalesStore(products);
        });

        Future<void> open(WidgetTester tester) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (locale == AppLocale.en) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            textScale: textScale,
            products: FakeProductsCubits(products),
            customers: FakeCustomersCubits(sales),
            sales: FakeSalesCubits(sales),
            purchases: FakePurchasesCubits(FakePurchasesStore(products)),
            reports: FakeReportsCubits(reports),
          );
          expect(tester.takeException(), isNull);
        }

        Finder text(String s) => find.textContaining(s);

        testWidgets('sales, count, collected by method and top debtors', (
          tester,
        ) async {
          reports.dashboard = _busy;
          await open(tester);
          expect(find.text(l10n.dashboardSalesTitle), findsOneWidget);
          expect(text(digits('450.00')), findsOneWidget);
          expect(
            find.text(l10n.dashboardSalesCount(3, digits('3'))),
            findsOneWidget,
          );
          expect(text(digits('500.00')), findsOneWidget);
          expect(find.text(l10n.methodCash), findsOneWidget);
          expect(find.text(l10n.methodWallet), findsOneWidget);
          expect(find.text(l10n.methodInstapay), findsNothing);
          for (final name in ['بسمة', 'هالة', 'جمال']) {
            expect(find.text(name), findsOneWidget);
          }
          // Largest first.
          expect(
            tester.getTopLeft(find.text('بسمة')).dy,
            lessThan(tester.getTopLeft(find.text('جمال')).dy),
          );
        });

        testWidgets('a new shop shows zeros and an empty debtors card', (
          tester,
        ) async {
          await open(tester);
          expect(
            find.text(l10n.dashboardSalesCount(0, digits('0'))),
            findsOneWidget,
          );
          await tester.ensureVisible(find.text(l10n.dashboardDebtorsNone));
          expect(find.text(l10n.dashboardDebtorsNone), findsOneWidget);
          expect(find.text(l10n.dashboardSeeAll), findsNothing);
        });

        testWidgets('the sales card opens the sales list', (tester) async {
          reports.dashboard = _busy;
          await open(tester);
          await tester.tap(find.text(l10n.dashboardSalesTitle));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.sales);
        });

        testWidgets('a debtor opens the customer; See all opens the list', (
          tester,
        ) async {
          final id = sales.seedCustomer('بسمة', openingPiasters: 50000);
          reports.dashboard = DashboardSnapshot(
            todaySalesPiasters: 0,
            todaySalesCount: 0,
            todayCollected: CollectedSummary.empty,
            topDebtors: [
              BalanceRow(partyId: id, name: 'بسمة', balancePiasters: 50000),
            ],
          );
          await open(tester);
          await tester.ensureVisible(find.text('بسمة'));
          await tester.tap(find.text('بسمة'));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.customerDetails(id));

          await goTo(tester, RoutePaths.home);
          await tester.ensureVisible(find.text(l10n.dashboardSeeAll));
          await tester.tap(find.text(l10n.dashboardSeeAll));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.parties);
        });

        testWidgets('new numbers show without a restart', (tester) async {
          await open(tester);
          reports.dashboard = _busy;
          await tester.pumpAndSettle();
          expect(
            find.text(l10n.dashboardSalesCount(3, digits('3'))),
            findsOneWidget,
          );
        });

        testWidgets('a failed load offers Retry, which loads', (tester) async {
          reports
            ..dashboard = _busy
            ..failNextWatch = StateError('db');
          await open(tester);
          expect(find.text(l10n.dashboardSalesTitle), findsNothing);
          await tester.ensureVisible(find.text(l10n.retryAction).first);
          await tester.tap(find.text(l10n.retryAction).first);
          await tester.pumpAndSettle();
          expect(find.text(l10n.dashboardSalesTitle), findsOneWidget);
        });
      });
    }
  }
}
