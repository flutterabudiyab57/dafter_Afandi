import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/widgets/status_banner.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
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
        ar ? '$arabic ج.م' : 'EGP $latin';
    String saleNo(String latin, String arabic) =>
        ltrIsolate(ar ? 'S-$arabic' : 'S-$latin');

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeSalesStore store;
        late String tea;
        late String ahmad;

        setUp(() {
          store = FakeSalesStore();
          tea = store.products.seedProduct(
            'شاي',
            pricePiasters: 1000,
            stockMilli: 10000,
          );
          ahmad = store.seedCustomer('أحمد');
        });

        SaleDraft teaSale(int qty, {bool credit = false, int? paid}) {
          var d = const SaleDraft()
              .add(
                productId: tea,
                name: 'شاي',
                unit: UnitType.piece,
                unitPricePiasters: 1000,
              )
              .updateLine(tea, qtyMilli: qty * 1000);
          if (credit) {
            d = d
                .withCustomer(SaleCustomer(id: ahmad, name: 'أحمد'))
                .withPaid(paid ?? 0);
          }
          return d;
        }

        Future<void> open(WidgetTester tester, String path) async {
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

        Future<void> giveReason(
          WidgetTester tester,
          String action,
          String reason,
        ) async {
          await tester.enterText(
            find.widgetWithText(TextField, l10n.reasonLabel),
            reason,
          );
          await tester.tap(find.widgetWithText(FilledButton, action));
          await tester.pumpAndSettle();
        }

        testWidgets('the list: newest first, marks, search, unpaid filter', (
          tester,
        ) async {
          store
            ..seedSale(teaSale(1))
            ..seedSale(teaSale(2, credit: true))
            ..seedSale(teaSale(3, credit: true, paid: 1000));
          await open(tester, RoutePaths.sales);
          final rows = [
            '${saleNo('000003', '٠٠٠٠٠٣')} · أحمد',
            '${saleNo('000002', '٠٠٠٠٠٢')} · أحمد',
            '${saleNo('000001', '٠٠٠٠٠١')} · ${l10n.walkInCustomer}',
          ];
          // Newest first: the top row is the last sale.
          expect(find.text(rows[0]), findsOneWidget);
          for (final r in rows.skip(1)) {
            await tester.scrollUntilVisible(
              find.text(r),
              200,
              scrollable: find.byType(Scrollable).last,
            );
            expect(find.text(r), findsOneWidget);
          }
          await tester.drag(
            find.byType(Scrollable).last,
            const Offset(0, 3000),
          );
          await tester.pumpAndSettle();
          if (textScale == 1) {
            expect(find.text(l10n.saleKindPartial), findsOneWidget);
            expect(find.text(l10n.saleKindCredit), findsOneWidget);
          }

          await tester.enterText(
            find.widgetWithText(TextField, l10n.salesSearchHint),
            '1',
          );
          await tester.pumpAndSettle();
          expect(find.text(rows[2]), findsOneWidget);
          expect(find.text(rows[0]), findsNothing);
          await tester.enterText(
            find.widgetWithText(TextField, l10n.salesSearchHint),
            '',
          );
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text(l10n.salesFilterUnpaid));
          expect(find.text(rows[2]), findsNothing);
          expect(find.text(rows[1]), findsOneWidget);
        }, skip: textScale != 1); // TODO(003): scroll-based check at 200%.

        testWidgets('the invoice shows every field; never a tax title', (
          tester,
        ) async {
          final id = store.seedSale(
            teaSale(3, credit: true, paid: 1000)
                .updateLine(tea, lineDiscountPiasters: 200)
                .withInvoiceDiscount(300)
                .withMethod(PaymentMethod.wallet),
          );
          await open(tester, RoutePaths.saleInvoice(id));
          expect(
            find.text(l10n.invoiceTitle(saleNo('000001', '٠٠٠٠٠١'))),
            findsOneWidget,
          );
          expect(find.textContaining('ضريب'), findsNothing);
          expect(find.textContaining('Tax'), findsNothing);
          expect(find.text('أحمد'), findsOneWidget);
          expect(
            find.text(
              l10n.invoiceLineDetail(
                ar ? '٣ قطعة' : '3 pc',
                egp('10.00', '١٠٫٠٠'),
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.text(l10n.invoiceLineDiscount(egp('2.00', '٢٫٠٠'))),
            findsOneWidget,
          );
          for (final v in [
            egp('28.00', '٢٨٫٠٠'),
            egp('3.00', '٣٫٠٠'),
            egp('25.00', '٢٥٫٠٠'),
            egp('15.00', '١٥٫٠٠'),
          ]) {
            await tester.ensureVisible(find.text(v).first);
            expect(find.text(v), findsWidgets, reason: v);
          }
          expect(find.text(l10n.methodWallet), findsOneWidget);
        });

        testWidgets('void asks for a reason; stock and balance come back', (
          tester,
        ) async {
          final id = store.seedSale(teaSale(3, credit: true, paid: 1000));
          expect(store.balanceOf(ahmad), 2000);
          await open(tester, RoutePaths.saleInvoice(id));
          await tapVisible(tester, find.text(l10n.invoiceVoidAction));
          // The destructive choice is last (US1-5).
          final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
          expect(
            (dialog.actions!.last as FilledButton).child,
            isA<Text>().having((t) => t.data, 'data', l10n.invoiceVoidAction),
          );
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.invoiceVoidAction),
          );
          await tester.pumpAndSettle();
          expect(find.text(l10n.errorReasonRequired), findsOneWidget);
          await giveReason(tester, l10n.invoiceVoidAction, 'خطأ في العميل');
          expect(store.products.stockOf(tea), 10000);
          expect(store.balanceOf(ahmad), 0);
          expect(find.textContaining('خطأ في العميل'), findsOneWidget);
          expect(find.text(l10n.invoiceVoidAction), findsNothing);
          expect(find.byType(VoidedBanner), findsOneWidget);
          final types = store.statementOf(ahmad).map((e) => e.type).toList();
          expect(types, contains(LedgerEntryType.saleVoid));
          expect(types, contains(LedgerEntryType.reversal));

          await goTo(tester, RoutePaths.sales);
          expect(find.text(l10n.saleVoidedBadge), findsOneWidget);
          await tapVisible(tester, find.text(l10n.salesFilterUnpaid));
          expect(find.text(l10n.salesNoMatch), findsOneWidget);
        });

        testWidgets('voiding a cash sale from the customer page refreshes '
            'the statement', (tester) async {
          final id = store.seedSale(
            teaSale(2).withCustomer(SaleCustomer(id: ahmad, name: 'أحمد')),
          );
          await open(tester, RoutePaths.customerDetails(ahmad));
          expect(find.text(l10n.ledgerReversal), findsNothing);
          expect(find.text(l10n.ledgerCancelled), findsNothing);

          // The payment row belongs to the sale and opens its invoice.
          await tapVisible(tester, find.text(l10n.ledgerPayment));
          expect(currentPath(tester), RoutePaths.saleInvoice(id));
          await tapVisible(tester, find.text(l10n.invoiceVoidAction));
          await giveReason(tester, l10n.invoiceVoidAction, 'خطأ');
          expect(find.text(l10n.invoiceVoided), findsOneWidget);

          await tapBack(tester);
          expect(currentPath(tester), RoutePaths.customerDetails(ahmad));
          // The balance did not move (−20 and +20), yet the statement shows
          // the two reversing rows and marks both originals.
          expect(store.balanceOf(ahmad), 0);
          expect(find.text(l10n.ledgerReversal), findsOneWidget);
          final paymentRow = find.ancestor(
            of: find.text(l10n.ledgerPayment),
            matching: find.byType(ListTile),
          );
          expect(
            find.descendant(
              of: paymentRow,
              matching: find.text(l10n.ledgerCancelled),
            ),
            findsOneWidget,
          );
        });

        testWidgets('a full-credit invoice shows no payment method', (
          tester,
        ) async {
          final id = store.seedSale(teaSale(2, credit: true));
          await open(tester, RoutePaths.saleInvoice(id));
          expect(find.text(l10n.saleMethodLabel), findsNothing);
          expect(find.text(l10n.methodCash), findsNothing);
        });

        testWidgets('a missing invoice says so', (tester) async {
          await open(tester, RoutePaths.saleInvoice('nope'));
          expect(find.text(l10n.invoiceNotFound), findsOneWidget);
        });

        testWidgets('payment: 25 by wallet gives RC-000001 and lowers the '
            'balance', (tester) async {
          final k = store.seedCustomer('محمد', openingPiasters: 6000);
          await open(tester, RoutePaths.customerDetails(k));
          await tapVisible(tester, find.text(l10n.customerReceivePayment));
          expect(currentPath(tester), RoutePaths.customerPayment(k));
          await tester.enterText(
            find.widgetWithText(TextField, l10n.paymentAmountLabel),
            '٢٥',
          );
          await tapVisible(tester, find.text(l10n.methodWallet));
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(currentPath(tester), RoutePaths.customerDetails(k));
          expect(
            find.text(
              l10n.paymentSaved(ltrIsolate(ar ? 'RC-٠٠٠٠٠١' : 'RC-000001')),
            ),
            findsOneWidget,
          );
          expect(store.balanceOf(k), 3500);
          expect(
            find.text(l10n.balanceOwes(egp('35.00', '٣٥٫٠٠'))),
            findsWidgets,
          );
        });

        testWidgets('payment: empty or bad amounts are blocked; more than '
            'the balance asks first', (tester) async {
          final k = store.seedCustomer('محمد', openingPiasters: 6000);
          await open(tester, RoutePaths.customerPayment(k));
          final save = find.widgetWithText(FilledButton, l10n.saveAction);
          await tapVisible(tester, save);
          expect(find.text(l10n.errorAmountRequired), findsOneWidget);
          await tester.enterText(
            find.widgetWithText(TextField, l10n.paymentAmountLabel),
            '80',
          );
          await tapVisible(tester, save);
          expect(
            find.text(l10n.paymentCreditBody(egp('20.00', '٢٠٫٠٠'))),
            findsOneWidget,
          );
          await tester.tap(find.text(l10n.backAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);
          await tapVisible(tester, save);
          await tester.tap(find.text(l10n.confirmAction));
          await tester.pumpAndSettle();
          expect(store.balanceOf(k), -2000);
        });

        testWidgets('a payment made with a sale cannot be cancelled alone', (
          tester,
        ) async {
          store.seedSale(teaSale(3, credit: true, paid: 1000));
          await open(tester, RoutePaths.customerDetails(ahmad));
          expect(find.text(l10n.ledgerPayment), findsOneWidget);
          expect(find.text(l10n.paymentCancelAction), findsNothing);
        });
      });
    }
  }
}
