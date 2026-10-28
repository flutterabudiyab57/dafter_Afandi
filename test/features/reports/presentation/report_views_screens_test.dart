import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/reports/domain/report_types.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_reports.dart';
import '../../../helpers/pump_app.dart';

const _pen = TopSeller(
  productId: 'p1',
  name: 'قلم',
  unit: UnitType.piece,
  qtyMilli: 2000,
  netSalesPiasters: 10000,
);
const _rice = TopSeller(
  productId: 'p2',
  name: 'أرز',
  unit: UnitType.kg,
  qtyMilli: 12500,
  netSalesPiasters: 5000,
);

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;
    String digits(String latin) => ar
        ? latin
              .replaceAllMapped(
                RegExp('[0-9]'),
                (m) => String.fromCharCode(0x0660 + int.parse(m[0]!)),
              )
              .replaceAll('.', '٫')
              .replaceAll(',', '٬')
        : latin;

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeReportsStore reports;

        setUp(() => reports = FakeReportsStore());

        Future<void> open(WidgetTester tester, String path) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            textScale: textScale,
            reports: FakeReportsCubits(reports),
          );
          await goTo(tester, RoutePaths.reports);
          final link = find.text(switch (path) {
            RoutePaths.reportCollected => l10n.reportCollectedTitle,
            RoutePaths.reportTopSellers => l10n.reportTopSellersTitle,
            _ => l10n.reportBalancesTitle,
          });
          await tester.ensureVisible(link);
          await tester.tap(link);
          await tester.pumpAndSettle();
          expect(currentPath(tester), path);
          expect(tester.takeException(), isNull);
        }

        Finder amount(String latin) => find.textContaining(digits(latin));

        testWidgets('collected: a row per method and the total (US5-1, 5)', (
          tester,
        ) async {
          reports.collected = const CollectedSummary({
            PaymentMethod.cash: 30000,
            PaymentMethod.wallet: 20000,
          });
          await open(tester, RoutePaths.reportCollected);
          expect(find.text(l10n.methodCash), findsOneWidget);
          expect(amount('300.00'), findsOneWidget);
          expect(find.text(l10n.methodWallet), findsOneWidget);
          expect(amount('200.00'), findsOneWidget);
          expect(find.text(l10n.methodInstapay), findsNothing);
          expect(amount('500.00'), findsOneWidget);
          // The period bar is there.
          expect(find.text(l10n.reportPeriodToday), findsOneWidget);
        });

        testWidgets('collected: nothing in the period', (tester) async {
          reports.collected = CollectedSummary.empty;
          await open(tester, RoutePaths.reportCollected);
          expect(find.text(l10n.reportCollectedEmpty), findsOneWidget);
        });

        testWidgets('top sellers: by value, switch to quantity (US5-2)', (
          tester,
        ) async {
          reports.topSellers = {
            TopSellerOrder.value: [_pen, _rice],
            TopSellerOrder.quantity: [_rice, _pen],
          };
          await open(tester, RoutePaths.reportTopSellers);
          double y(String name) => tester.getTopLeft(find.text(name)).dy;
          expect(y('قلم'), lessThan(y('أرز')));
          expect(amount('100.00'), findsOneWidget);
          expect(
            find.text(
              l10n.reportTopSold(
                ar ? '١٢٫٥ ${l10n.unitKgShort}' : '12.5 ${l10n.unitKgShort}',
              ),
            ),
            findsOneWidget,
          );

          final byQty = find.text(l10n.reportTopByQuantity);
          await tester.ensureVisible(byQty);
          await tester.tap(byQty);
          await tester.pumpAndSettle();
          expect(y('أرز'), lessThan(y('قلم')));

          await tester.ensureVisible(find.text('قلم'));
          await tester.tap(find.text('قلم'));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.productDetails('p1'));
        });

        testWidgets('top sellers: nothing sold', (tester) async {
          await open(tester, RoutePaths.reportTopSellers);
          expect(find.text(l10n.reportTopEmpty), findsOneWidget);
        });

        testWidgets('balances: customers and suppliers with totals; rows '
            'open the party (US5-3, 4)', (tester) async {
          reports
            ..customersOwing = const [
              BalanceRow(partyId: 'c1', name: 'منى', balancePiasters: 50000),
              BalanceRow(partyId: 'c2', name: 'سعيد', balancePiasters: 20000),
            ]
            ..suppliersOwed = const [
              BalanceRow(partyId: 's1', name: 'النور', balancePiasters: 70000),
            ];
          await open(tester, RoutePaths.reportBalances);
          expect(
            find.text(
              l10n.reportBalancesCustomersTotal(
                ar ? '٧٠٠٫٠٠ ج.م' : 'EGP 700.00',
              ),
            ),
            findsOneWidget,
          );
          expect(find.text('منى'), findsOneWidget);

          await tester.tap(find.text(l10n.reportBalancesSuppliersTab));
          await tester.pumpAndSettle();
          expect(
            find.text(
              l10n.reportBalancesSuppliersTotal(
                ar ? '٧٠٠٫٠٠ ج.م' : 'EGP 700.00',
              ),
            ),
            findsOneWidget,
          );
          await tester.tap(find.text('النور'));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.supplierDetails('s1'));
        });

        testWidgets('balances: nobody owes', (tester) async {
          await open(tester, RoutePaths.reportBalances);
          expect(find.text(l10n.reportBalancesCustomersNone), findsOneWidget);
          await tester.tap(find.text(l10n.reportBalancesSuppliersTab));
          await tester.pumpAndSettle();
          expect(find.text(l10n.reportBalancesSuppliersNone), findsOneWidget);
        });
      });
    }
  }
}
