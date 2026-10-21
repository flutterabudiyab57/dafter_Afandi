import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/widgets/startup_error_app.dart';
import 'package:daftar_afandi/core/widgets/update_required_app.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_products.dart';
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

  Future<void> pump(bool onboarded) async => pumpApp(
    tester,
    await repo(onboarded),
    products: FakeProductsCubits(store),
    customers: FakeCustomersCubits(sales),
    sales: FakeSalesCubits(sales),
    size: size,
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
  ]) {
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
  for (final app in kBlockingApps) {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await check(app.toString());
  }
}
