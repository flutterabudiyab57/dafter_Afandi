import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/settings/domain/app_settings.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_products.dart';
import '../helpers/fake_purchases.dart';
import '../helpers/fake_sales.dart';
import '../helpers/pump_app.dart';
import 'capture.dart';

/// The pictures of the user guide (docs/user-guide), from a shop with
/// believable data. Off by default:
///
///     flutter test test/screenshots/guide_test.dart --dart-define=SCREENSHOTS=true
///
/// Writes `build/guide/NN-<name>.png`.
const bool _enabled = bool.fromEnvironment('SCREENSHOTS');

void main() {
  setUpAll(loadAppFonts);

  testWidgets('user guide pictures', skip: !_enabled, (tester) async {
    debugDisableShadows = false;
    final l10n = lookupAppLocalizations(const Locale('ar'));
    var n = 0;
    Future<void> shot(String name) async {
      // No caret or selection handle in the pictures.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await settleImages(tester);
      final image = await captureScreen(tester);
      n++;
      await writePng(
        tester,
        image,
        'build/guide/${n.toString().padLeft(2, '0')}-$name.png',
      );
    }

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    Future<void> type(String label, String text, {bool last = false}) async {
      var f = find.widgetWithText(TextField, label);
      if (last) f = f.last;
      await tester.ensureVisible(f);
      await tester.enterText(f, text);
      await tester.pumpAndSettle();
    }

    // A small grocery with a few days of work.
    final store = FakeProductsStore();
    final drinks = store.seedCategory('مشروبات');
    final grocery = store.seedCategory('بقالة');
    final cleaning = store.seedCategory('منظفات');
    final tea = store.seedProduct(
      'شاي العروسة ٢٥٠ جرام',
      pricePiasters: 1250,
      stockMilli: 4000,
      costPiasters: 900,
      lowStockMilli: 5000,
      barcode: '6221234567890',
      categoryId: drinks,
    );
    final sugar = store.seedProduct(
      'سكر',
      unit: UnitType.kg,
      pricePiasters: 3000,
      stockMilli: 12500,
      costPiasters: 2500,
      lowStockMilli: 5000,
      categoryId: grocery,
    );
    store
      ..seedProduct(
        'أرز مصري',
        unit: UnitType.kg,
        pricePiasters: 2800,
        stockMilli: 20000,
        costPiasters: 2300,
        categoryId: grocery,
      )
      ..seedProduct(
        'زيت عافية ١ لتر',
        pricePiasters: 8500,
        stockMilli: 15000,
        costPiasters: 7600,
        categoryId: grocery,
      )
      ..seedProduct(
        'بيبسي ١ لتر',
        pricePiasters: 2000,
        stockMilli: 24000,
        costPiasters: 1600,
        categoryId: drinks,
      )
      ..seedProduct(
        'مسحوق غسيل ١ كجم',
        pricePiasters: 4500,
        stockMilli: 2000,
        costPiasters: 3800,
        lowStockMilli: 3000,
        categoryId: cleaning,
      );

    final sales = FakeSalesStore(store);
    final ahmad = sales.seedCustomer(
      'أحمد محمود',
      phone: '01012345678',
      openingPiasters: 15000,
    );
    sales
      ..seedCustomer('منى علي', phone: '01122334455')
      ..seedCustomer('مقهى النخيل', phone: '0225556677');
    SaleDraft sale(List<(String, String, int, int)> lines) {
      var d = const SaleDraft();
      for (final (id, name, price, qty) in lines) {
        d = d
            .add(
              productId: id,
              name: name,
              unit: id == sugar ? UnitType.kg : UnitType.piece,
              unitPricePiasters: price,
            )
            .updateLine(id, qtyMilli: qty);
      }
      return d;
    }

    sales.seedSale(sale([(tea, 'شاي العروسة ٢٥٠ جرام', 1250, 2000)]));
    final credit = sales.seedSale(
      sale([
            (tea, 'شاي العروسة ٢٥٠ جرام', 1250, 2000),
            (sugar, 'سكر', 3000, 1500),
          ])
          .withCustomer(SaleCustomer(id: ahmad, name: 'أحمد محمود'))
          .withPaid(3000),
    );
    sales.seedSale(sale([(sugar, 'سكر', 3000, 2000)]));
    await sales.customers.receivePayment(
      ahmad,
      const PaymentRequest(amountPiasters: 5000, method: PaymentMethod.cash),
    );

    final buying = FakePurchasesStore(store);
    final nour = buying.seedSupplier(
      'شركة النور للتوريدات',
      phone: '0223456789',
    );
    buying.seedSupplier('مخازن الحرمين', phone: '0233445566');
    final purchase = buying.seedPurchase(
      const PurchaseDraft()
          .add(
            productId: tea,
            name: 'شاي العروسة ٢٥٠ جرام',
            unit: UnitType.piece,
            salePricePiasters: 1250,
            unitCostPiasters: 900,
          )
          .updateLine(tea, qtyMilli: 20000)
          .withSupplier(
            PurchaseSupplier(id: nour, name: 'شركة النور للتوريدات'),
          )
          .withSupplierRef('F-2041')
          .withPaid(10000),
    );
    // The purchase above restocked the tea; sales brought it low again.
    store.seedEntry(tea, StockEntryType.sale, -19000);

    Future<void> pump(AppSettings settings) => pumpApp(
      tester,
      FakeSettingsRepository(settings),
      products: FakeProductsCubits(store),
      customers: FakeCustomersCubits(sales),
      sales: FakeSalesCubits(sales),
      suppliers: FakeSuppliersCubits(buying),
      purchases: FakePurchasesCubits(buying),
      size: kPhone,
      devicePixelRatio: kRatio,
    );

    // First run.
    await pump(kFreshSettings);
    await shot('welcome');
    await tap(find.text(l10n.continueAction));
    await type(l10n.shopNameLabel, 'بقالة الأمانة');
    await type(l10n.shopPhoneLabel, '01012345678');
    await shot('shop-details');
    await tap(find.text(l10n.continueAction));
    await shot('data-safety');

    // The shop at work.
    await pump(
      const AppSettings(
        locale: AppLocale.ar,
        digitStyle: DigitStylePreference.followLanguage,
        onboardingCompleted: true,
        shop: ShopProfile(name: 'بقالة الأمانة', phone: '01012345678'),
      ),
    );
    await shot('home');
    await goTo(tester, RoutePaths.products);
    await shot('products');

    await goTo(tester, RoutePaths.productNew);
    await type(l10n.productNameLabel, 'عصير مانجو ١ لتر');
    await type(l10n.productPriceLabel, '35');
    await type(l10n.productOpeningQtyLabel, '12');
    await type(l10n.productOpeningCostLabel, '28');
    await tester.ensureVisible(find.text(l10n.productNameLabel));
    await tester.pumpAndSettle();
    await shot('product-new');
    await tap(find.widgetWithText(FilledButton, l10n.saveAction));
    await shot('product-opening-confirm');
    await tap(find.text(l10n.backAction));
    await tapBack(tester);
    await tap(find.text(l10n.discardAction));

    await goTo(tester, RoutePaths.productDetails(tea));
    await shot('product-details');
    await goTo(tester, RoutePaths.productAdjust(tea));
    await shot('product-adjust');
    await goTo(tester, RoutePaths.categories);
    await shot('categories');

    // Selling.
    await goTo(tester, RoutePaths.sales);
    await shot('sales');
    await goTo(tester, RoutePaths.salesNew);
    await tap(find.text(l10n.saleAddProductAction));
    await shot('sale-product-picker');
    await tap(find.text('شاي العروسة ٢٥٠ جرام'));
    await type(l10n.saleQtyLabel, '3');
    await tap(find.text(l10n.saleAddProductAction));
    await tap(find.text('أرز مصري'));
    await type(l10n.saleQtyLabel, '2', last: true);
    await tester.ensureVisible(find.text(l10n.saleBarcodeLabel));
    await tester.pumpAndSettle();
    await shot('sale-lines');
    await tap(find.text(l10n.saleCustomerPick));
    await tap(find.text('منى علي'));
    await type(l10n.salePaidLabel, '50');
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, l10n.saleSaveAction),
    );
    await tester.pumpAndSettle();
    await shot('sale-payment');
    await tapBack(tester);
    await tap(find.text(l10n.saleDiscardAction));

    await goTo(tester, RoutePaths.saleInvoice(credit));
    await shot('invoice');
    await tap(find.text(l10n.invoiceVoidAction));
    await shot('invoice-void');
    await tap(find.text(l10n.backAction));

    // Customers.
    await goTo(tester, RoutePaths.parties);
    await shot('customers');
    await goTo(tester, RoutePaths.customerDetails(ahmad));
    await shot('customer-details');
    await goTo(tester, RoutePaths.customerPayment(ahmad));
    await type(l10n.paymentAmountLabel, '100');
    await tap(find.text(l10n.methodWallet));
    await shot('customer-payment');
    await tapBack(tester);
    await tap(find.text(l10n.discardAction));

    // Suppliers and purchases.
    await goTo(tester, RoutePaths.suppliers);
    await shot('suppliers');
    await goTo(tester, RoutePaths.supplierDetails(nour));
    await shot('supplier-details');
    await goTo(tester, RoutePaths.purchases);
    await shot('purchases');
    await goTo(tester, RoutePaths.purchasesNew);
    await tap(find.text(l10n.saleAddProductAction));
    await tap(find.text('زيت عافية ١ لتر'));
    await type(l10n.saleQtyLabel, '12');
    await tap(find.text(l10n.purchaseSupplierPick));
    await tap(find.text('مخازن الحرمين'));
    await type(l10n.purchaseSupplierRefLabel, '7781');
    await tester.ensureVisible(find.text(l10n.saleBarcodeLabel));
    await tester.pumpAndSettle();
    await shot('purchase-new');
    await tapBack(tester);
    await tap(find.text(l10n.saleDiscardAction));
    await goTo(tester, RoutePaths.purchase(purchase));
    await shot('purchase');

    // Settings, and Undo after archiving.
    await goTo(tester, RoutePaths.settings);
    await shot('settings');
    await goTo(tester, RoutePaths.productDetails(sugar));
    await tap(find.text(l10n.productArchiveAction));
    await shot('product-archive-confirm');
    await tap(find.text(l10n.productArchiveAction).last);
    await shot('product-archived-undo');

    debugDisableShadows = true;
  });
}
