import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';
import '../../../helpers/fake_sales.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;
    String egp(String latin, String arabic) =>
        ar ? '$arabic\u00A0ج.م' : 'EGP\u00A0$latin';

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        Future<void> open(
          WidgetTester tester,
          FakeSalesStore store,
          String path,
        ) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            products: FakeProductsCubits(store.products),
            customers: FakeCustomersCubits(store),
            sales: FakeSalesCubits(store),
            textScale: textScale,
          );
          await goTo(tester, path);
          expect(tester.takeException(), isNull);
        }

        Future<void> tapVisible(WidgetTester tester, Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Future<void> type(
          WidgetTester tester,
          String label,
          String text,
        ) async {
          final f = find.widgetWithText(TextField, label);
          await tester.ensureVisible(f);
          await tester.enterText(f, text);
          await tester.pump();
        }

        Future<void> save(WidgetTester tester) => tapVisible(
          tester,
          find.widgetWithText(FilledButton, l10n.saveAction),
        );

        testWidgets('add with phone: listed with no balance', (tester) async {
          final store = FakeSalesStore();
          await open(tester, store, RoutePaths.parties);
          expect(find.text(l10n.customersEmptyTitle), findsOneWidget);
          await tapVisible(tester, find.text(l10n.customerAddTitle));
          expect(currentPath(tester), RoutePaths.customerNew);
          await type(tester, l10n.customerNameLabel, 'محمد');
          await type(tester, l10n.customerPhoneLabel, '٠١٠١٢٣٤٥٦٧٨');
          await save(tester);
          // Back to the list, where they are.
          final id = store.activeCustomers().single.customer.id;
          expect(currentPath(tester), RoutePaths.parties);
          expect(store.customer(id)!.customer.phone, '01012345678');
          expect(find.text('محمد'), findsOneWidget);
          expect(find.text(l10n.balanceZero), findsOneWidget);
        });

        testWidgets('opening balance owed, or in their favour', (tester) async {
          final store = FakeSalesStore();
          await open(tester, store, RoutePaths.customerNew);
          await type(tester, l10n.customerNameLabel, 'أحمد');
          await type(tester, l10n.customerOpeningAmount, '50');
          await save(tester);
          final id = store.activeCustomers().single.customer.id;
          await goTo(tester, RoutePaths.customerDetails(id));
          expect(
            find.text(l10n.balanceOwes(egp('50.00', '٥٠٫٠٠'))),
            findsOneWidget,
          );
          await tester.ensureVisible(find.text(l10n.ledgerOpening));
          expect(find.text(l10n.ledgerOpening), findsOneWidget);

          await goTo(tester, RoutePaths.customerNew);
          await type(tester, l10n.customerNameLabel, 'بسمة');
          await type(tester, l10n.customerOpeningAmount, '20');
          await tapVisible(tester, find.text(l10n.customerOpeningInFavour));
          await save(tester);
          await goTo(tester, RoutePaths.parties);
          expect(
            find.text(l10n.balanceInFavour(egp('20.00', '٢٠٫٠٠'))),
            findsOneWidget,
          );
        });

        testWidgets('required name and a bad phone show messages', (
          tester,
        ) async {
          final store = FakeSalesStore();
          await open(tester, store, RoutePaths.customerNew);
          await type(tester, l10n.customerPhoneLabel, '12');
          await save(tester);
          expect(find.text(l10n.errorCustomerNameRequired), findsOneWidget);
          expect(
            find.text(l10n.errorPhoneTooShort(ar ? '٧' : '7')),
            findsOneWidget,
          );
          expect(store.writes, isEmpty);
        });

        testWidgets('search by name and phone; owes filter', (tester) async {
          final store = FakeSalesStore()
            ..seedCustomer('أحمد', phone: '0101', openingPiasters: 100)
            ..seedCustomer('محمد', openingPiasters: 900)
            ..seedCustomer('علي');
          await open(tester, store, RoutePaths.parties);
          final total = find.text(
            l10n.customersTotalOwing(egp('10.00', '١٠٫٠٠')),
          );
          expect(total, findsOneWidget);
          await tester.enterText(
            find.widgetWithText(TextField, l10n.customersSearchHint),
            'احمد',
          );
          await tester.pumpAndSettle();
          expect(find.text('أحمد'), findsOneWidget);
          expect(find.text('محمد'), findsNothing);
          // The total is everyone's, whatever the search.
          expect(total, findsOneWidget);
          await tester.enterText(
            find.widgetWithText(TextField, l10n.customersSearchHint),
            '',
          );
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text(l10n.customersFilterOwes));
          expect(find.text('علي'), findsNothing);
          expect(
            tester.getTopLeft(find.text('محمد')).dy,
            lessThan(tester.getTopLeft(find.text('أحمد')).dy),
          );
        });

        testWidgets('statement newest first; a sale row opens the invoice', (
          tester,
        ) async {
          final store = FakeSalesStore();
          final tea = store.products.seedProduct('شاي', stockMilli: 9000);
          final k = store.seedCustomer('أحمد', openingPiasters: 5000);
          final sale = store.seedSale(
            const SaleDraft()
                .add(
                  productId: tea,
                  name: 'شاي',
                  unit: UnitType.piece,
                  unitPricePiasters: 3000,
                )
                .withCustomer(SaleCustomer(id: k, name: 'أحمد'))
                .withPaid(0),
          );
          await open(tester, store, RoutePaths.customerDetails(k));
          expect(
            find.text(l10n.balanceOwes(egp('80.00', '٨٠٫٠٠'))),
            findsWidgets,
          );
          final saleRow = find.text(
            l10n.ledgerSale(ltrIsolate(ar ? 'S-٠٠٠٠٠١' : 'S-000001')),
          );
          await tester.ensureVisible(find.text(l10n.ledgerOpening));
          expect(
            tester.getTopLeft(saleRow).dy,
            lessThan(tester.getTopLeft(find.text(l10n.ledgerOpening)).dy),
          );
          await tapVisible(tester, saleRow);
          expect(currentPath(tester), RoutePaths.saleInvoice(sale));
        });

        testWidgets('edit keeps the balance and statement', (tester) async {
          final store = FakeSalesStore();
          final k = store.seedCustomer('أحمد', openingPiasters: 700);
          await open(tester, store, RoutePaths.customerDetails(k));
          await tapVisible(tester, find.text(l10n.productEditAction));
          await type(tester, l10n.customerNameLabel, 'أحمد سعيد');
          await save(tester);
          expect(currentPath(tester), RoutePaths.customerDetails(k));
          expect(find.text('أحمد سعيد'), findsOneWidget);
          expect(store.balanceOf(k), 700);
        });

        testWidgets('archive with a balance asks with the balance; restore', (
          tester,
        ) async {
          final store = FakeSalesStore();
          final k = store.seedCustomer('أحمد', openingPiasters: 6000);
          await open(tester, store, RoutePaths.customerDetails(k));
          await tapVisible(tester, find.text(l10n.customerArchiveAction));
          expect(
            find.text(
              l10n.customerArchiveConfirmBalance(
                l10n.balanceOwes(egp('60.00', '٦٠٫٠٠')),
              ),
            ),
            findsOneWidget,
          );
          await tester.tap(find.text(l10n.customerArchiveAction).last);
          await tester.pumpAndSettle();
          expect(find.text(l10n.customerArchivedBadge), findsOneWidget);
          expect(store.activeCustomers(), isEmpty);
          expect(find.text(l10n.customerReceivePayment), findsNothing);

          await goTo(tester, RoutePaths.customersArchived);
          await tapVisible(tester, find.text(l10n.customerRestoreAction));
          expect(store.activeCustomers(), hasLength(1));
          expect(store.balanceOf(k), 6000);
        });

        testWidgets('archive with no history warns of the deletion; the '
            'archive shows its day', (tester) async {
          final store = FakeSalesStore();
          final k = store.seedCustomer('سعيد');
          await open(tester, store, RoutePaths.customerDetails(k));
          await tapVisible(tester, find.text(l10n.customerArchiveAction));
          expect(
            find.text(l10n.customerArchiveConfirmPurge(ar ? '٧' : '7')),
            findsOneWidget,
          );
          await tester.tap(find.text(l10n.customerArchiveAction).last);
          await tester.pumpAndSettle();

          await goTo(tester, RoutePaths.customersArchived);
          expect(
            find.textContaining(ar ? '٢٠٢٦/١٠/٢٧' : '2026/10/27'),
            findsOneWidget,
          );
        });

        testWidgets('a cancelled payment shows a reversal and its mark', (
          tester,
        ) async {
          final store = FakeSalesStore();
          final k = store.seedCustomer('أحمد', openingPiasters: 6000);
          await store.customers.receivePayment(
            k,
            const PaymentRequest(
              amountPiasters: 2500,
              method: PaymentMethod.wallet,
            ),
          );
          await open(tester, store, RoutePaths.customerDetails(k));
          await tapVisible(tester, find.text(l10n.paymentCancelAction));
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.paymentCancelAction),
          );
          await tester.pumpAndSettle();
          expect(find.text(l10n.errorReasonRequired), findsOneWidget);
          await tester.enterText(
            find.widgetWithText(TextField, l10n.reasonLabel),
            'دفعة مكررة',
          );
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.paymentCancelAction),
          );
          await tester.pumpAndSettle();
          expect(store.balanceOf(k), 6000);
          await tester.ensureVisible(find.text(l10n.ledgerReversal));
          expect(find.text(l10n.ledgerReversal), findsOneWidget);
          expect(find.text(l10n.ledgerCancelled), findsOneWidget);
          expect(find.text(l10n.paymentCancelAction), findsNothing);
        });

        testWidgets('a missing customer says so', (tester) async {
          await open(
            tester,
            FakeSalesStore(),
            RoutePaths.customerDetails('nope'),
          );
          expect(find.text(l10n.customerNotFound), findsOneWidget);
        });
      });
    }
  }
}
