import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/widgets/status_banner.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
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
    String number(String latin, String arabic) =>
        ltrIsolate(ar ? 'S-$arabic' : 'S-$latin');

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeSalesStore store;
        late String tea;
        late String flour;

        Future<void> open(WidgetTester tester) async {
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
          await goTo(tester, RoutePaths.sales);
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.salesNew);
          expect(tester.takeException(), isNull);
        }

        setUp(() {
          store = FakeSalesStore();
          tea = store.products.seedProduct(
            'شاي',
            pricePiasters: 1250,
            stockMilli: 10000,
            barcode: '6221',
          );
          flour = store.products.seedProduct(
            'دقيق',
            unit: UnitType.kg,
            pricePiasters: 4000,
            stockMilli: 5000,
          );
        });

        Future<void> tapVisible(WidgetTester tester, Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Future<void> scan(WidgetTester tester, String code) async {
          final f = find.widgetWithText(TextField, l10n.saleBarcodeLabel);
          await tester.ensureVisible(f);
          await tester.enterText(f, code);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        Future<void> pick(WidgetTester tester, String name) async {
          await tapVisible(tester, find.text(l10n.saleAddProductAction));
          await tester.tap(find.text(name));
          await tester.pumpAndSettle();
        }

        Future<void> typeIn(
          WidgetTester tester,
          Finder field,
          String text,
        ) async {
          await tester.ensureVisible(field);
          await tester.enterText(field, text);
          await tester.pump();
        }

        Finder lineField(String label) => find.widgetWithText(TextField, label);

        Future<void> save(WidgetTester tester) => tapVisible(
          tester,
          find.widgetWithText(FilledButton, l10n.saleSaveAction),
        );

        testWidgets('2 × شاي by barcode: cash sale 1, stock down, back on '
            'the list', (tester) async {
          await open(tester);
          expect(find.text(l10n.saleEmpty), findsOneWidget);
          await scan(tester, '٦٢٢١');
          await scan(tester, '6221');
          expect(find.text('2'), findsOneWidget);
          expect(
            find.text(l10n.saleLineTotal(egp('25.00', '٢٥٫٠٠'))),
            findsOneWidget,
          );
          await save(tester);
          expect(
            find.text(l10n.saleSaved(number('000001', '٠٠٠٠٠١'))),
            findsOneWidget,
          );
          expect(store.products.stockOf(tea), 8000);
          expect(store.salesList(const SaleQuery()).single.kind, SaleKind.cash);
          // Back where the sale was started, the message still showing.
          expect(currentPath(tester), RoutePaths.sales);
        });

        testWidgets('an unknown barcode says so', (tester) async {
          await open(tester);
          await scan(tester, '999');
          expect(find.text(l10n.saleBarcodeNotFound), findsOneWidget);
          expect(find.text(l10n.saleEmpty), findsOneWidget);
        });

        testWidgets('discounts: 3 × 10.00 − 2.00 − 3.00 = 25.00; too large '
            'is blocked', (tester) async {
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, lineField(l10n.saleQtyLabel).first, '3');
          await typeIn(tester, lineField(l10n.salePriceLabel), '10');
          await typeIn(tester, lineField(l10n.saleLineDiscountLabel), '2');
          await typeIn(tester, lineField(l10n.saleInvoiceDiscountLabel), '3');
          expect(find.text(egp('25.00', '٢٥٫٠٠')), findsOneWidget);

          await typeIn(tester, lineField(l10n.saleLineDiscountLabel), '31');
          await save(tester);
          expect(find.text(l10n.errorLineDiscountTooLarge), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('kg takes 0.750; a piece fraction is rejected', (
          tester,
        ) async {
          await open(tester);
          await pick(tester, 'دقيق');
          await typeIn(tester, lineField(l10n.saleQtyLabel), '0.750');
          expect(
            find.text(l10n.saleLineTotal(egp('30.00', '٣٠٫٠٠'))),
            findsOneWidget,
          );
          await pick(tester, 'شاي');
          await typeIn(tester, lineField(l10n.saleQtyLabel).last, '1.5');
          expect(find.text(l10n.errorQuantityNotWhole), findsOneWidget);
        });

        testWidgets('a shortage warns; Back saves nothing; confirm saves', (
          tester,
        ) async {
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, lineField(l10n.saleQtyLabel), '12');
          await save(tester);
          expect(find.text(l10n.shortageTitle), findsOneWidget);
          // The lines are part of the dialog's message.
          expect(
            find.textContaining(
              l10n.shortageLine(
                'شاي',
                ar ? '١٠ قطعة' : '10 pc',
                ar ? '١٢ قطعة' : '12 pc',
              ),
            ),
            findsOneWidget,
          );
          await tester.tap(find.text(l10n.backAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);
          await save(tester);
          await tester.tap(find.text(l10n.shortageConfirm));
          await tester.pumpAndSettle();
          expect(store.products.stockOf(tea), -2000);
        });

        testWidgets('no lines: saving is blocked', (tester) async {
          await open(tester);
          await save(tester);
          expect(find.text(l10n.errorSaleNoLines), findsOneWidget);
        });

        testWidgets('leaving with lines asks first', (tester) async {
          await open(tester);
          await pick(tester, 'شاي');
          await tapBack(tester);
          expect(find.text(l10n.saleDiscardTitle), findsOneWidget);
          await tester.tap(find.text(l10n.saleKeepAction));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.salesNew);
          await tapBack(tester);
          await tester.tap(find.text(l10n.saleDiscardAction));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.sales);
          expect(store.writes, isEmpty);
        });

        testWidgets('credit needs a customer; quick add, then 40 of 100 '
            'paid by wallet', (tester) async {
          store.products.seedProduct(
            'زيت',
            pricePiasters: 10000,
            stockMilli: 5000,
          );
          await open(tester);
          await pick(tester, 'زيت');
          await typeIn(tester, lineField(l10n.salePaidLabel), '40');
          await save(tester);
          // A warning banner at the top whose "Choose" opens the picker
          // (US3-3).
          expect(find.text(l10n.creditNeedsCustomerTitle), findsOneWidget);
          expect(find.text(l10n.errorCreditNeedsCustomer), findsOneWidget);
          final banner = tester.widget<StatusBanner>(
            find.ancestor(
              of: find.text(l10n.creditNeedsCustomerTitle),
              matching: find.byType(StatusBanner),
            ),
          );
          expect(banner.tone, StatusTone.warning);

          await tapVisible(tester, find.text(l10n.chooseAction));
          await tester.enterText(
            find.widgetWithText(TextField, l10n.customersSearchHint),
            'أحمد',
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.customerAddNamed('أحمد')));
          await tester.pumpAndSettle();
          expect(find.text('أحمد'), findsOneWidget);
          expect(find.text(egp('60.00', '٦٠٫٠٠')), findsOneWidget);
          await tapVisible(tester, find.text(l10n.methodWallet));
          await save(tester);
          final k = store.activeCustomers().single.customer.id;
          expect(store.balanceOf(k), 6000);
          expect(store.statementOf(k).first.method, PaymentMethod.wallet);
        });

        testWidgets('the picker opens the full form, its name from the '
            'search; the saved customer is chosen and the lines kept', (
          tester,
        ) async {
          await open(tester);
          await pick(tester, 'شاي');
          await tapVisible(tester, find.text(l10n.saleCustomerPick));
          await tester.enterText(
            find.widgetWithText(TextField, l10n.customersSearchHint),
            'سامي',
          );
          await tester.pumpAndSettle();
          await tapVisible(tester, find.text(l10n.customerNewAction));
          expect(find.text(l10n.customerAddTitle), findsOneWidget);
          expect(find.text('سامي'), findsOneWidget);
          await tester.enterText(
            find.widgetWithText(TextField, l10n.customerPhoneLabel),
            '01001234567',
          );
          await tapVisible(tester, find.text(l10n.saveAction));

          final added = store.activeCustomers().single.customer;
          expect(added.name, 'سامي');
          expect(added.phone, '01001234567');
          expect(find.text('سامي'), findsOneWidget);
          expect(find.textContaining('شاي'), findsWidgets);
        });

        testWidgets('paid more than the total is rejected', (tester) async {
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, lineField(l10n.salePaidLabel), '13');
          await save(tester);
          expect(find.text(l10n.errorPaidTooLarge), findsOneWidget);
        });

        testWidgets('an existing customer is picked; cash keeps the balance', (
          tester,
        ) async {
          final k = store.seedCustomer('محمد', openingPiasters: 500);
          await open(tester);
          await pick(tester, 'شاي');
          await tapVisible(tester, find.text(l10n.saleCustomerPick));
          await tester.tap(find.text('محمد'));
          await tester.pumpAndSettle();
          await save(tester);
          expect(store.balanceOf(k), 500);
          expect(store.statementOf(k), hasLength(3));
          expect(flour, isNotEmpty);
        });
      });
    }
  }
}
