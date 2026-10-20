import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/widgets/startup_error_app.dart';
import 'package:daftar_afandi/core/widgets/update_required_app.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_products.dart';
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

  Future<void> pump(bool onboarded) async => pumpApp(
    tester,
    await repo(onboarded),
    products: FakeProductsCubits(store),
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
  ]) {
    await goTo(tester, path);
    await check(path);
  }
  // The opening-stock confirmation, still on the opening page.
  final l10n = lookupAppLocalizations(Locale(locale.name));
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
