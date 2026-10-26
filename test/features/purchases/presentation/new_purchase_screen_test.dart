import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:daftar_afandi/features/products/presentation/widgets/unit_label.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';
import '../../../helpers/fake_purchases.dart';
import '../../../helpers/fake_sales.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;
    String egp(String latin, String arabic) =>
        ar ? '$arabic\u00A0ج.م' : 'EGP\u00A0$latin';
    String doc(String latin) =>
        ltrIsolate(ar ? applyDigitStyle(latin, DigitStyle.arabicIndic) : latin);

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakePurchasesStore store;
        late String tea;

        setUp(() {
          store = FakePurchasesStore();
          tea = store.products.seedProduct(
            'شاي',
            pricePiasters: 1250,
            stockMilli: 10000,
            costPiasters: 900,
            barcode: '6221',
          );
        });

        Future<void> open(WidgetTester tester) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            products: FakeProductsCubits(store.products),
            sales: FakeSalesCubits(FakeSalesStore(store.products)),
            suppliers: FakeSuppliersCubits(store),
            purchases: FakePurchasesCubits(store),
            textScale: textScale,
          );
          await goTo(tester, RoutePaths.purchases);
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.purchasesNew);
          expect(tester.takeException(), isNull);
        }

        Future<void> tapVisible(WidgetTester tester, Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Finder field(String label) => find.widgetWithText(TextField, label);

        Future<void> typeIn(WidgetTester tester, Finder f, String text) async {
          await tester.ensureVisible(f);
          await tester.enterText(f, text);
          await tester.pump();
        }

        Future<void> scan(WidgetTester tester, String code) async {
          await typeIn(tester, field(l10n.saleBarcodeLabel), code);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        Future<void> pick(WidgetTester tester, String name) async {
          await tapVisible(tester, find.text(l10n.saleAddProductAction));
          await tester.tap(find.text(name));
          await tester.pumpAndSettle();
        }

        Future<void> pickSupplier(WidgetTester tester, String name) async {
          await tapVisible(tester, find.text(l10n.purchaseSupplierPick));
          await tester.tap(find.text(name));
          await tester.pumpAndSettle();
        }

        Future<void> save(WidgetTester tester) => tapVisible(
          tester,
          find.widgetWithText(FilledButton, l10n.purchaseSaveAction),
        );

        testWidgets('US1-1: 10 × شاي at 11.00 for cash: P-000001, stock 20, '
            'screen empty again', (tester) async {
          await open(tester);
          await pick(tester, 'شاي');
          // No earlier purchase: the cost starts at the average cost.
          expect(
            tester
                .widget<TextField>(field(l10n.purchaseCostLabel))
                .controller!
                .text,
            '9',
          );
          await typeIn(tester, field(l10n.saleQtyLabel), '10');
          await typeIn(tester, field(l10n.purchaseCostLabel), '١١');
          expect(find.text(egp('110.00', '١١٠٫٠٠')), findsWidgets);
          await save(tester);
          expect(
            find.text(l10n.purchaseSaved(doc('P-000001'))),
            findsOneWidget,
          );
          expect(store.products.stockOf(tea), 20000);
          final saved = store.purchaseList(const PurchaseQuery()).single;
          expect(saved.totalPiasters, 11000);
          expect(saved.kind, PurchaseKind.cash);
          expect(find.text(l10n.saleEmpty), findsOneWidget);
          expect(currentPath(tester), RoutePaths.purchasesNew);
        });

        testWidgets('US1-2: the same barcode twice raises one line to 2', (
          tester,
        ) async {
          await open(tester);
          await scan(tester, '٦٢٢١');
          await scan(tester, '6221');
          expect(find.text('شاي'), findsOneWidget);
          expect(
            tester.widget<TextField>(field(l10n.saleQtyLabel)).controller!.text,
            '2',
          );
          await scan(tester, '999');
          expect(find.text(l10n.saleBarcodeNotFound), findsOneWidget);
        });

        testWidgets('US1-3: 100.00 + 300.00 − 40.00 invoice discount = '
            '360.00', (tester) async {
          store.products.seedProduct('سكر', pricePiasters: 20000);
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, field(l10n.purchaseCostLabel), '100');
          await pick(tester, 'سكر');
          await typeIn(tester, field(l10n.saleQtyLabel).last, '3');
          await typeIn(tester, field(l10n.purchaseCostLabel).last, '100');
          await typeIn(tester, field(l10n.saleInvoiceDiscountLabel), '40');
          expect(find.text(egp('360.00', '٣٦٠٫٠٠')), findsOneWidget);
          await save(tester);
          final p = store.purchaseList(const PurchaseQuery()).single;
          final full = store.purchase(p.id)!;
          expect(full.invoiceDiscountPiasters, 4000);
          expect(p.totalPiasters, 36000);
        });

        testWidgets('US1-3: a line discount above the line amount is '
            'blocked', (tester) async {
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, field(l10n.purchaseCostLabel), '10');
          await typeIn(tester, field(l10n.saleLineDiscountLabel), '11');
          await save(tester);
          expect(find.text(l10n.errorLineDiscountTooLarge), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('US1-4: 2.500 kg at 30.00 = 75.00; a piece fraction is '
            'rejected', (tester) async {
          store.products.seedProduct('دقيق', unit: UnitType.kg);
          await open(tester);
          await pick(tester, 'دقيق');
          await typeIn(tester, field(l10n.saleQtyLabel), '2.500');
          await typeIn(tester, field(l10n.purchaseCostLabel), '30');
          expect(
            find.text(l10n.saleLineTotal(egp('75.00', '٧٥٫٠٠'))),
            findsOneWidget,
          );
          await pick(tester, 'شاي');
          await typeIn(tester, field(l10n.saleQtyLabel).last, '1.5');
          expect(find.text(l10n.errorQuantityNotWhole), findsOneWidget);
        });

        testWidgets('US1-6: no lines: saving is blocked', (tester) async {
          await open(tester);
          await save(tester);
          expect(find.text(l10n.errorSaleNoLines), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('US1-7: leaving with lines asks first', (tester) async {
          await open(tester);
          await pick(tester, 'شاي');
          await tapBack(tester);
          expect(find.text(l10n.purchaseDiscardTitle), findsOneWidget);
          await tester.tap(find.text(l10n.purchaseKeepAction));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.purchasesNew);
          await tapBack(tester);
          await tester.tap(find.text(l10n.saleDiscardAction));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.purchases);
          expect(store.writes, isEmpty);
        });

        testWidgets('US1-8: the date defaults to today and the picker ends '
            'today', (tester) async {
          await open(tester);
          final today = find.text(doc('2026/10/20'));
          await tapVisible(tester, today);
          final picker = tester.widget<DatePickerDialog>(
            find.byType(DatePickerDialog),
          );
          expect(picker.lastDate, DateTime(2026, 10, 20));
          expect(picker.initialDate, DateTime(2026, 10, 20));
        });

        testWidgets('US1-9: quick add «بن يمني» by kg at 400.00; it stays '
            'after the purchase is discarded', (tester) async {
          await open(tester);
          await tapVisible(tester, find.text(l10n.saleAddProductAction));
          await tester.enterText(field(l10n.productsSearchHint), 'بن يمني');
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.purchaseAddProductNamed('بن يمني')));
          await tester.pumpAndSettle();
          expect(find.text(l10n.purchaseQuickAddTitle), findsOneWidget);
          await tapVisible(tester, find.text(unitFull(l10n, UnitType.kg)));
          await typeIn(tester, field(l10n.productPriceLabel), '400');
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(currentPath(tester), RoutePaths.purchasesNew);
          expect(find.text('بن يمني'), findsOneWidget);
          expect(find.text(unitFull(l10n, UnitType.kg)), findsOneWidget);

          final added = store.products
              .summaries(const ProductQuery(text: 'بن يمني'))
              .single;
          expect(added.product.unit, UnitType.kg);
          expect(added.product.salePricePiasters, 40000);
          expect(store.products.stockOf(added.product.id), 0);

          await tapBack(tester);
          await tester.tap(find.text(l10n.saleDiscardAction));
          await tester.pumpAndSettle();
          expect(
            store.products.summaries(const ProductQuery(text: 'بن')),
            hasLength(1),
          );
          expect(store.writes, isEmpty);
        });

        testWidgets('US1-10: the cost starts at the last purchase; at or '
            'above the selling price shows a notice and still saves', (
          tester,
        ) async {
          store.seedPurchase(
            const PurchaseDraft().add(
              productId: tea,
              name: 'شاي',
              unit: UnitType.piece,
              salePricePiasters: 1250,
              unitCostPiasters: 1100,
            ),
          );
          await open(tester);
          await pick(tester, 'شاي');
          expect(
            tester
                .widget<TextField>(field(l10n.purchaseCostLabel))
                .controller!
                .text,
            '11',
          );
          expect(find.text(l10n.purchaseCostNotice), findsNothing);
          await typeIn(tester, field(l10n.purchaseCostLabel), '12.50');
          expect(find.text(l10n.purchaseCostNotice), findsOneWidget);
          await typeIn(tester, field(l10n.purchaseCostLabel), '13');
          expect(find.text(l10n.purchaseCostNotice), findsOneWidget);
          await save(tester);
          expect(
            find.text(l10n.purchaseSaved(doc('P-000002'))),
            findsOneWidget,
          );
        });

        testWidgets('US2-1: 500.00 from شركة النور, 200.00 paid now: the '
            'shop owes 300.00', (tester) async {
          final v = store.seedSupplier('شركة النور');
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, field(l10n.purchaseCostLabel), '500');
          await pickSupplier(tester, 'شركة النور');
          expect(find.text('شركة النور'), findsOneWidget);
          await typeIn(tester, field(l10n.salePaidLabel), '200');
          expect(find.text(egp('300.00', '٣٠٠٫٠٠')), findsOneWidget);
          await tapVisible(tester, find.text(l10n.methodWallet));
          await typeIn(tester, field(l10n.purchaseSupplierRefLabel), 'F-77');
          await save(tester);
          expect(store.balanceOf(v), 30000);
          final p = store.purchaseList(const PurchaseQuery()).single;
          expect(p.kind, PurchaseKind.partial);
          expect(p.supplierRef, 'F-77');
          expect(store.purchase(p.id)!.method, PaymentMethod.wallet);
        });

        testWidgets('US2-2: credit with no supplier is blocked', (
          tester,
        ) async {
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, field(l10n.salePaidLabel), '0');
          await save(tester);
          expect(find.text(l10n.errorCreditNeedsSupplier), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('US2-3: paid in full with a supplier keeps the balance', (
          tester,
        ) async {
          final v = store.seedSupplier('شركة النور', openingPiasters: 1000);
          await open(tester);
          await pick(tester, 'شاي');
          await pickSupplier(tester, 'شركة النور');
          await save(tester);
          expect(store.balanceOf(v), 1000);
          expect(store.statementOf(v), hasLength(3));
        });

        testWidgets('US2-4: a new supplier is added from the picker', (
          tester,
        ) async {
          await open(tester);
          await pick(tester, 'شاي');
          await tapVisible(tester, find.text(l10n.purchaseSupplierPick));
          await tester.enterText(field(l10n.suppliersSearchHint), 'أحمد');
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.supplierAddNamed('أحمد')));
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.purchasesNew);
          expect(find.text('أحمد'), findsOneWidget);
          expect(store.activeSuppliers().single.supplier.name, 'أحمد');
          // Clearing the supplier goes back to no supplier.
          await tapVisible(tester, find.text(l10n.purchaseNoSupplier));
          expect(find.text('أحمد'), findsNothing);
        });

        testWidgets('US2-5: paid more than the total is rejected', (
          tester,
        ) async {
          await open(tester);
          await pick(tester, 'شاي');
          await typeIn(tester, field(l10n.salePaidLabel), '10');
          await save(tester);
          expect(find.text(l10n.errorPaidTooLarge), findsOneWidget);
          expect(store.writes, isEmpty);
        });
      });
    }
  }
}
