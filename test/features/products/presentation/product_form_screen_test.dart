import 'dart:async';

import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        Future<FakeProductsStore> open(
          WidgetTester tester, {
          void Function(FakeProductsStore s)? seed,
          String path = RoutePaths.productNew,
        }) async {
          final store = FakeProductsStore();
          seed?.call(store);
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            products: FakeProductsCubits(store),
            textScale: textScale,
          );
          await goTo(tester, path);
          return store;
        }

        Finder field(String label) => find.widgetWithText(TextField, label);

        Future<void> type(
          WidgetTester tester,
          String label,
          String text,
        ) async {
          await tester.ensureVisible(field(label));
          await tester.enterText(field(label), text);
          await tester.pump();
        }

        // The focused field may still be scrolling its caret into view, and
        // a scrolling list ignores taps, so settle before tapping the chip.
        Future<void> pickUnit(WidgetTester tester, String unit) async {
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text(unit));
          await tester.tap(find.text(unit));
          await tester.pump();
        }

        Future<void> save(WidgetTester tester) async {
          final button = find.widgetWithText(FilledButton, l10n.saveAction);
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
        }

        testWidgets('required fields show their messages; nothing is saved', (
          tester,
        ) async {
          final store = await open(tester);
          await type(tester, l10n.productNameLabel, '   ');
          await save(tester);
          expect(tester.takeException(), isNull);
          expect(find.text(l10n.errorNameRequired), findsOneWidget);
          expect(find.text(l10n.errorPriceRequired), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('name, unit and price only: saved, opens details with '
            'stock 0', (tester) async {
          final store = await open(tester);
          await type(tester, l10n.productNameLabel, 'أرز مصري');
          await pickUnit(tester, l10n.unitKg);
          await type(tester, l10n.productPriceLabel, '25');
          await save(tester);
          expect(store.writes, ['create أرز مصري']);
          final id = store.summaries(const ProductQuery()).single.product.id;
          expect(currentPath(tester), RoutePaths.productDetails(id));
          expect(store.summary(id)!.product.unit, UnitType.kg);
          expect(find.text(ar ? '٠ كجم' : '0 kg'), findsOneWidget);
        });

        testWidgets('opening 12 at 7.50: confirmation, Back keeps the form, '
            'Confirm saves', (tester) async {
          final store = await open(tester);
          await type(tester, l10n.productNameLabel, 'شاي');
          await type(tester, l10n.productPriceLabel, '10');
          await type(tester, l10n.productOpeningQtyLabel, '12');
          await type(tester, l10n.productOpeningCostLabel, '7.50');
          await save(tester);

          final body = ar
              ? l10n.openingConfirmBody('١٢ قطعة', '٧٫٥٠ ج.م', '٩٠٫٠٠ ج.م')
              : l10n.openingConfirmBody('12 pc', 'EGP 7.50', 'EGP 90.00');
          expect(find.text(l10n.openingConfirmTitle), findsOneWidget);
          expect(find.text(body), findsOneWidget);

          await tester.tap(find.text(l10n.backAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);
          expect(currentPath(tester), RoutePaths.productNew);
          expect(find.text('7.50'), findsOneWidget);

          await save(tester);
          await tester.tap(find.text(l10n.confirmAction));
          await tester.pumpAndSettle();
          final id = store.summaries(const ProductQuery()).single.product.id;
          expect(store.stockOf(id), 12000);
          expect(currentPath(tester), RoutePaths.productDetails(id));
        });

        testWidgets('a fraction of a piece is rejected with a message', (
          tester,
        ) async {
          await open(tester);
          await type(tester, l10n.productNameLabel, 'شاي');
          await type(tester, l10n.productPriceLabel, '10');
          await type(tester, l10n.productOpeningQtyLabel, '1.5');
          await type(tester, l10n.productOpeningCostLabel, '1');
          await save(tester);
          expect(find.text(l10n.errorQuantityNotWhole), findsOneWidget);
          expect(find.text(l10n.openingConfirmTitle), findsNothing);
        });

        testWidgets('kg takes 2.375; a 4th decimal cannot be typed', (
          tester,
        ) async {
          final store = await open(tester);
          await type(tester, l10n.productNameLabel, 'دقيق');
          await pickUnit(tester, l10n.unitKg);
          await type(tester, l10n.productPriceLabel, '20');
          await type(tester, l10n.productOpeningQtyLabel, '2.375');
          await tester.enterText(field(l10n.productOpeningQtyLabel), '2.3755');
          await tester.pump();
          expect(find.text('2.375'), findsOneWidget);
          await type(tester, l10n.productOpeningCostLabel, '40');
          await save(tester);
          await tester.tap(find.text(l10n.confirmAction));
          await tester.pumpAndSettle();
          final id = store.summaries(const ProductQuery()).single.product.id;
          expect(store.stockOf(id), 2375);
        });

        testWidgets('opening without a cost asks for the cost', (tester) async {
          await open(tester);
          await type(tester, l10n.productNameLabel, 'شاي');
          await type(tester, l10n.productPriceLabel, '10');
          await type(tester, l10n.productOpeningQtyLabel, '3');
          await save(tester);
          expect(find.text(l10n.errorOpeningCostRequired), findsOneWidget);
        });

        testWidgets('a taken barcode names the other product', (tester) async {
          final store = await open(
            tester,
            seed: (s) => s.seedProduct('أرز مصري', barcode: '6221234567890'),
          );
          await type(tester, l10n.productNameLabel, 'شاي');
          await type(tester, l10n.productPriceLabel, '10');
          await type(tester, l10n.productBarcodeLabel, '٦٢٢١٢٣٤٥٦٧٨٩٠');
          await save(tester);
          expect(find.text(l10n.errorBarcodeTaken('أرز مصري')), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('Arabic digits are accepted in prices and quantities', (
          tester,
        ) async {
          final store = await open(tester);
          await type(tester, l10n.productNameLabel, 'سكر');
          await type(tester, l10n.productPriceLabel, '٢٥٫٥٠');
          await type(tester, l10n.productLowStockLabel, '٥');
          await save(tester);
          final p = store.summaries(const ProductQuery()).single.product;
          expect(p.salePricePiasters, 2550);
          expect(p.lowStockThresholdMilli, 5000);
        });

        testWidgets('the empty-search action fills in the name', (
          tester,
        ) async {
          await open(tester, path: RoutePaths.products);
          unawaited(routerOf(tester).push(RoutePaths.productNew, extra: 'زيت'));
          await tester.pumpAndSettle();
          expect(find.text('زيت'), findsOneWidget);
        });
      });
    }
  }
}
