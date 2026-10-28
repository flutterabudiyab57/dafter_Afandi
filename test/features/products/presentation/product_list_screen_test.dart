import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));

    Future<FakeProductsStore> open(
      WidgetTester tester, {
      void Function(FakeProductsStore store)? seed,
      String path = RoutePaths.products,
      double textScale = 1,
    }) async {
      final store = FakeProductsStore();
      seed?.call(store);
      final repo = FakeSettingsRepository(kOnboardedSettings);
      if (locale == AppLocale.en) await repo.setLocale(AppLocale.en);
      await pumpApp(
        tester,
        repo,
        products: FakeProductsCubits(store),
        textScale: textScale,
      );
      await goTo(tester, path);
      return store;
    }

    Future<void> search(WidgetTester tester, String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
    }

    void seedShop(FakeProductsStore s) {
      final drinks = s.seedCategory('Drinks');
      s
        ..seedProduct(
          'أرز مصري',
          pricePiasters: 2500,
          stockMilli: 3000,
          lowStockMilli: 5000,
          barcode: '6221234567890',
          sku: 'R-01',
        )
        ..seedProduct('شاي العروسة', stockMilli: 12000, barcode: '1234')
        ..seedProduct('Cola', categoryId: drinks, stockMilli: 6000)
        ..seedProduct('مكرونة', sku: 'PAS-9');
    }

    group(locale.name, () {
      testWidgets('lists products in order with price, stock and marks', (
        tester,
      ) async {
        await open(tester, seed: seedShop);
        expect(find.text(l10n.productsTitle), findsOneWidget);
        // The shell's own app bar is hidden below Home.
        expect(find.text(l10n.appName), findsNothing);

        final names = ['أرز مصري', 'شاي العروسة', 'مكرونة', 'Cola'];
        final ys = [for (final n in names) tester.getTopLeft(find.text(n)).dy];
        expect(ys, orderedEquals([...ys]..sort()), reason: 'list order');
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
        final unit = l10n.unitPieceShort;
        expect(find.textContaining(unit), findsNWidgets(4));
        if (locale == AppLocale.ar) {
          expect(find.text('٢٥٫٠٠\u00A0ج.م'), findsOneWidget);
          expect(find.text('٣ $unit'), findsOneWidget);
          // RTL: the name starts at the right edge.
          expect(
            tester.getTopRight(find.text('Cola')).dx,
            greaterThan(tester.getSize(find.byType(Scaffold).last).width / 2),
          );
        } else {
          expect(find.text('EGP\u00A025.00'), findsOneWidget);
          expect(find.text('3 $unit'), findsOneWidget);
        }
      });

      testWidgets('search folds Arabic spelling and finds barcodes first', (
        tester,
      ) async {
        await open(tester, seed: seedShop);
        await search(tester, 'ارز');
        expect(find.text('أرز مصري'), findsOneWidget);
        expect(find.text('شاي العروسة'), findsNothing);

        await search(tester, '1234');
        final barcodeFirst = tester.getTopLeft(find.text('شاي العروسة')).dy;
        expect(
          barcodeFirst,
          lessThan(tester.getTopLeft(find.text('أرز مصري')).dy),
        );

        await search(tester, 'pas');
        expect(find.text('مكرونة'), findsOneWidget);
        expect(find.text('أرز مصري'), findsNothing);
      });

      testWidgets('category and low-stock filters', (tester) async {
        await open(tester, seed: seedShop);
        await tester.tap(find.text('Drinks'));
        await tester.pumpAndSettle();
        expect(find.text('Cola'), findsOneWidget);
        expect(find.text('أرز مصري'), findsNothing);

        await tester.ensureVisible(find.text(l10n.productsFilterNoCategory));
        await tester.tap(find.text(l10n.productsFilterNoCategory));
        await tester.pumpAndSettle();
        expect(find.text('Cola'), findsNothing);
        expect(find.text('مكرونة'), findsOneWidget);

        await tester.ensureVisible(find.text(l10n.productsFilterAll));
        await tester.tap(find.text(l10n.productsFilterAll));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text(l10n.productsFilterLow).first);
        await tester.tap(find.text(l10n.productsFilterLow).first);
        await tester.pumpAndSettle();
        expect(find.text('أرز مصري'), findsOneWidget);
        expect(find.text('Cola'), findsNothing);
      });

      testWidgets('?filter=low starts with the low-stock filter on', (
        tester,
      ) async {
        await open(tester, seed: seedShop, path: RoutePaths.productsLow);
        expect(find.text('أرز مصري'), findsOneWidget);
        expect(find.text('شاي العروسة'), findsNothing);
      });

      testWidgets('no products: explains how to add the first one', (
        tester,
      ) async {
        await open(tester);
        expect(find.text(l10n.productsEmpty), findsOneWidget);
        await tester.tap(
          find.widgetWithText(FilledButton, l10n.productsEmptyAction),
        );
        await tester.pumpAndSettle();
        expect(currentPath(tester), RoutePaths.productNew);
      });

      testWidgets('no match: offers to add the typed name', (tester) async {
        await open(tester, seed: seedShop);
        await search(tester, 'زيت');
        expect(find.text(l10n.productsNoMatch('زيت')), findsOneWidget);
        await tester.tap(find.text(l10n.productsAddNamed('زيت')));
        await tester.pumpAndSettle();
        expect(currentPath(tester), RoutePaths.productNew);
        expect(routerOf(tester).state.extra, 'زيت');
      });

      testWidgets('a filter with no match says so', (tester) async {
        await open(tester, seed: (s) => s.seedProduct('شاي', stockMilli: 9000));
        await tester.tap(find.text(l10n.productsFilterLow).first);
        await tester.pumpAndSettle();
        expect(find.text(l10n.productsFilterEmpty), findsOneWidget);
      });

      testWidgets('a row opens details; the add button opens the form', (
        tester,
      ) async {
        late String id;
        await open(tester, seed: (s) => id = s.seedProduct('شاي'));
        await tester.tap(find.text('شاي'));
        await tester.pumpAndSettle();
        expect(currentPath(tester), RoutePaths.productDetails(id));
        await tapBack(tester);
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        expect(currentPath(tester), RoutePaths.productNew);
      });

      testWidgets('usable at 200% text', (tester) async {
        await open(tester, seed: seedShop, textScale: 2);
        expect(tester.takeException(), isNull);
        expect(find.text('أرز مصري'), findsOneWidget);
      });
    });
  }
}
