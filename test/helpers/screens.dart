import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/widgets/starting_app.dart';
import 'package:daftar_afandi/core/widgets/startup_error_app.dart';
import 'package:daftar_afandi/core/widgets/update_required_app.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_products.dart';
import 'fake_purchases.dart';
import 'fake_sales.dart';
import 'pump_app.dart';

const List<String> kFirstRunPaths = [
  RoutePaths.welcome,
  RoutePaths.onboardingShop,
  RoutePaths.onboardingData,
];

const List<String> kOnboardedPaths = [
  RoutePaths.home,
  RoutePaths.sales,
  RoutePaths.parties,
  RoutePaths.purchases,
  RoutePaths.reports,
  RoutePaths.settings,
  RoutePaths.settingsShop,
  RoutePaths.settingsData,
  RoutePaths.products,
];

const List<Widget> kBlockingApps = [
  StartingApp(),
  UpdateRequiredApp(kind: UpdateRequiredKind.tooNew),
  UpdateRequiredApp(kind: UpdateRequiredKind.unrecognized),
  StartupErrorApp(),
];

/// Visits every screen of the app in [locale] and calls [check] on each,
/// with a name for failure messages. The view settings from [pumpApp]
/// stay in force for the blocking apps.
Future<void> visitEveryScreen(
  WidgetTester tester, {
  required AppLocale locale,
  required Future<void> Function(String screen) check,
  Size size = const Size(420, 812),
  double devicePixelRatio = 1,
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) async {
  Future<FakeSettingsRepository> repo(bool onboarded) async {
    final r = FakeSettingsRepository(
      onboarded ? kOnboardedSettings : kFreshSettings,
    );
    if (locale != AppLocale.ar) await r.setLocale(locale);
    return r;
  }

  // Products with every kind of row, so the product screens are not empty.
  final store = FakeProductsStore();
  final drinks = store.seedCategory('مشروبات');
  final tea = store.seedProduct(
    'شاي العروسة ٢٥٠ جرام',
    stockMilli: 3000,
    costPiasters: 900,
    lowStockMilli: 5000,
    barcode: '6221234567890',
    sku: 'T-250',
    categoryId: drinks,
  );
  store.seedEntry(
    tea,
    StockEntryType.adjustment,
    -1000,
    reason: AdjustmentKind.other,
    note: 'عبوة مفتوحة',
  );
  final sugar = store.seedProduct('سكر');
  store.seedProduct('قديم', archived: true);

  // Customers and sales of every kind: cash, part paid, voided, and a
  // payment that can be cancelled.
  final sales = FakeSalesStore(store);
  final ahmad = sales.seedCustomer(
    'أحمد',
    phone: '01012345678',
    openingPiasters: 5000,
  );
  sales.seedCustomer('قديم', archived: true);
  SaleDraft teaSale({SaleCustomer? customer, int? paid}) {
    var d = const SaleDraft()
        .add(
          productId: tea,
          name: 'شاي العروسة ٢٥٠ جرام',
          unit: UnitType.piece,
          unitPricePiasters: 1000,
        )
        .updateLine(tea, qtyMilli: 1000);
    if (customer != null) d = d.withCustomer(customer).withPaid(paid);
    return d;
  }

  sales.seedSale(teaSale());
  final partPaid = sales.seedSale(
    teaSale(
      customer: SaleCustomer(id: ahmad, name: 'أحمد'),
      paid: 400,
    ),
  );
  final voided = sales.seedSale(teaSale());
  await sales.sales.voidSale(voided, 'خطأ في الكمية');
  await sales.customers.receivePayment(
    ahmad,
    const PaymentRequest(amountPiasters: 1000, method: PaymentMethod.wallet),
  );

  // Suppliers and purchases of every kind: credit, voided, and a
  // standalone payment that can be cancelled.
  final buying = FakePurchasesStore(store);
  final nour = buying.seedSupplier(
    'شركة النور للتوريدات',
    phone: '0223456789',
    openingPiasters: 30000,
  );
  buying.seedSupplier('قديم', archived: true);
  PurchaseDraft teaPurchase({int? paid}) => const PurchaseDraft()
      .add(
        productId: tea,
        name: 'شاي العروسة ٢٥٠ جرام',
        unit: UnitType.piece,
        salePricePiasters: 1000,
        unitCostPiasters: 900,
      )
      .updateLine(tea, qtyMilli: 10000)
      .withSupplier(PurchaseSupplier(id: nour, name: 'شركة النور للتوريدات'))
      .withSupplierRef('F-2041')
      .withPaid(paid);
  final onCredit = buying.seedPurchase(teaPurchase(paid: 2000));
  final voidedPurchase = buying.seedPurchase(teaPurchase());
  await buying.purchases.voidPurchase(voidedPurchase, 'مورد خطأ');
  await buying.suppliers.pay(
    nour,
    const PaymentRequest(amountPiasters: 5000, method: PaymentMethod.instapay),
  );

  Future<void> pump(bool onboarded) async => pumpApp(
    tester,
    await repo(onboarded),
    products: FakeProductsCubits(store),
    customers: FakeCustomersCubits(sales),
    sales: FakeSalesCubits(sales),
    suppliers: FakeSuppliersCubits(buying),
    purchases: FakePurchasesCubits(buying),
    size: size,
    devicePixelRatio: devicePixelRatio,
    textScale: textScale,
    brightness: brightness,
  );

  await pump(false);
  for (final path in kFirstRunPaths) {
    await goTo(tester, path);
    await check(path);
  }
  await pump(true);
  for (final path in [
    ...kOnboardedPaths,
    RoutePaths.productsLow,
    RoutePaths.productNew,
    RoutePaths.productsArchived,
    RoutePaths.categories,
    RoutePaths.productDetails(tea),
    RoutePaths.productEdit(tea),
    RoutePaths.productAdjust(tea),
    RoutePaths.productOpening(sugar),
    RoutePaths.salesNew,
    RoutePaths.saleInvoice(partPaid),
    RoutePaths.saleInvoice(voided),
    RoutePaths.customerNew,
    RoutePaths.customersArchived,
    RoutePaths.customerDetails(ahmad),
    RoutePaths.customerEdit(ahmad),
    RoutePaths.customerPayment(ahmad),
    RoutePaths.suppliers,
    RoutePaths.supplierNew,
    RoutePaths.suppliersArchived,
    RoutePaths.supplierDetails(nour),
    RoutePaths.supplierEdit(nour),
    RoutePaths.purchasesNew,
    RoutePaths.purchase(onCredit),
    RoutePaths.purchase(voidedPurchase),
    RoutePaths.supplierPayment(nour),
  ]) {
    // The list page is already open, so a new query alone would keep its
    // cubit; start it again from Home.
    if (path == RoutePaths.productsLow) await goTo(tester, RoutePaths.home);
    await goTo(tester, path);
    await check(path);
  }
  final l10n = lookupAppLocalizations(Locale(locale.name));
  Future<void> tap(Finder f) async {
    await tester.ensureVisible(f);
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  // Overpaying asks to confirm the credit, still on the payment page.
  await goTo(tester, RoutePaths.customerPayment(ahmad));
  await tester.enterText(
    find.widgetWithText(TextField, l10n.paymentAmountLabel),
    '1000',
  );
  await tap(find.widgetWithText(FilledButton, l10n.saveAction));
  await check('payment credit dialog');
  await tap(find.text(l10n.backAction));

  // The archive confirmation and the cancel-payment reason.
  await goTo(tester, RoutePaths.customerDetails(ahmad));
  await tap(find.text(l10n.customerArchiveAction));
  await check('archive customer dialog');
  await tap(find.text(l10n.cancelAction));
  await tap(find.text(l10n.paymentCancelAction));
  await check('cancel payment dialog');
  await tap(find.text(l10n.backAction));

  // The void reason.
  await goTo(tester, RoutePaths.saleInvoice(partPaid));
  await tap(find.text(l10n.invoiceVoidAction));
  await check('void dialog');
  await tap(find.text(l10n.backAction));

  // The new sale's pickers, shortage warning and discard question.
  await goTo(tester, RoutePaths.salesNew);
  await tap(find.text(l10n.saleCustomerPick));
  await check('customer picker');
  await tapBack(tester);
  await tap(find.text(l10n.saleAddProductAction));
  await check('product picker');
  await tap(find.text('شاي العروسة ٢٥٠ جرام'));
  final qty = find.widgetWithText(TextField, l10n.saleQtyLabel);
  await tester.ensureVisible(qty);
  await tester.enterText(qty, '99');
  await tester.pump();
  await tap(find.widgetWithText(FilledButton, l10n.saleSaveAction));
  await check('shortage dialog');
  await tap(find.text(l10n.backAction));
  await tapBack(tester);
  await check('discard sale dialog');
  await tap(find.text(l10n.saleDiscardAction));

  // Paying a supplier more than the shop owes asks first, still on the
  // payment page.
  await goTo(tester, RoutePaths.supplierPayment(nour));
  await tester.enterText(
    find.widgetWithText(TextField, l10n.paymentAmountLabel),
    '10000',
  );
  await tap(find.widgetWithText(FilledButton, l10n.saveAction));
  await check('supplier overpay dialog');
  await tap(find.text(l10n.backAction));

  // The supplier's archive confirmation and cancel-payment reason.
  await goTo(tester, RoutePaths.supplierDetails(nour));
  await tap(find.text(l10n.supplierArchiveAction));
  await check('archive supplier dialog');
  await tap(find.text(l10n.cancelAction));
  await tap(find.text(l10n.paymentCancelAction));
  await check('cancel supplier payment dialog');
  await tap(find.text(l10n.backAction));

  // The purchase void reason, then the shortage warning: a sale took the
  // purchased stock.
  store.seedEntry(tea, StockEntryType.sale, -30000);
  await goTo(tester, RoutePaths.purchase(onCredit));
  await tap(find.text(l10n.purchaseVoidAction));
  await check('purchase void dialog');
  await tester.enterText(
    find.widgetWithText(TextField, l10n.reasonLabel),
    'خطأ',
  );
  await tap(find.widgetWithText(FilledButton, l10n.purchaseVoidAction));
  await check('purchase void shortage dialog');
  await tap(find.text(l10n.backAction));

  // The new purchase's pickers, quick add, date and discard question.
  await goTo(tester, RoutePaths.purchasesNew);
  await tap(find.text(l10n.purchaseSupplierPick));
  await check('supplier picker');
  await tapBack(tester);
  await tap(find.text(l10n.saleAddProductAction));
  await tester.enterText(
    find.widgetWithText(TextField, l10n.productsSearchHint),
    'بن يمني',
  );
  await tester.pumpAndSettle();
  await check('purchase product picker');
  await tap(find.text(l10n.purchaseAddProductNamed('بن يمني')));
  await check('quick add product');
  await tapBack(tester);
  await tester.enterText(
    find.widgetWithText(TextField, l10n.productsSearchHint),
    '',
  );
  await tester.pumpAndSettle();
  await tap(find.text('شاي العروسة ٢٥٠ جرام'));
  await tap(find.byIcon(Icons.calendar_today));
  await check('purchase date picker');
  // Material's own Cancel, the first of the dialog's two actions.
  await tap(
    find
        .descendant(
          of: find.byType(DatePickerDialog),
          matching: find.byType(TextButton),
        )
        .first,
  );
  await tapBack(tester);
  await check('discard purchase dialog');
  await tap(find.text(l10n.saleDiscardAction));

  // The opening-stock confirmation, on the opening page.
  await goTo(tester, RoutePaths.productOpening(sugar));
  for (final (label, value) in [
    (l10n.productOpeningQtyLabel, '12'),
    (l10n.productOpeningCostLabel, '7.50'),
  ]) {
    final field = find.widgetWithText(TextField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
  }
  final save = find.widgetWithText(FilledButton, l10n.saveAction);
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
  await check('opening dialog');
  await tester.tap(find.text(l10n.backAction));
  await tester.pumpAndSettle();

  // 005 states: no results, a failed load, a failed save and the
  // unsaved-changes question.
  await goTo(tester, RoutePaths.products);
  await tester.enterText(
    find.widgetWithText(TextField, l10n.productsSearchHint),
    'zzz',
  );
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pumpAndSettle();
  expect(find.text(l10n.searchEmptyTitle), findsOneWidget);
  await check('no results');
  sales.failNextWatch = StateError('db');
  await goTo(tester, RoutePaths.parties);
  expect(find.text(l10n.loadFailedTitle), findsOneWidget);
  await check('load failed');
  await goTo(tester, RoutePaths.productNew);
  for (final (label, value) in [
    (l10n.productNameLabel, 'بن'),
    (l10n.productPriceLabel, '5'),
  ]) {
    final field = find.widgetWithText(TextField, label);
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
  }
  // Let the focused field finish scrolling into view: a scrolling page
  // ignores taps.
  await tester.pumpAndSettle();
  store.failNextWrite = StateError('disk full');
  await tap(find.widgetWithText(FilledButton, l10n.saveAction));
  expect(find.text(l10n.errorSaveFailed), findsOneWidget);
  await check('save failed banner');
  await tapBack(tester);
  expect(find.text(l10n.discardChangesTitle), findsOneWidget);
  await check('unsaved changes dialog');
  await tester.tap(find.text(l10n.discardAction));
  await tester.pumpAndSettle();

  for (final app in kBlockingApps) {
    await tester.pumpWidget(app);
    // The starting app's progress bar never settles.
    if (app is StartingApp) {
      await tester.pump(const Duration(milliseconds: 100));
    } else {
      await tester.pumpAndSettle();
    }
    await check(app.toString());
  }
}
