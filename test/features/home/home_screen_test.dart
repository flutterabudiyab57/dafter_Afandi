import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/fake_products.dart';
import '../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));

    Future<void> open(
      WidgetTester tester,
      FakeProductsStore store, {
      double textScale = 1,
    }) async {
      final repo = FakeSettingsRepository(kOnboardedSettings);
      if (locale == AppLocale.en) await repo.setLocale(AppLocale.en);
      await pumpApp(
        tester,
        repo,
        products: FakeProductsCubits(store),
        textScale: textScale,
      );
    }

    group(locale.name, () {
      testWidgets('Products and Categories open their screens', (tester) async {
        await open(tester, FakeProductsStore());
        await tester.tap(find.text(l10n.homeProductsAction));
        await tester.pumpAndSettle();
        expect(currentPath(tester), RoutePaths.products);
        // The bottom bar stays below Home's screens.
        expect(find.byType(NavigationBar), findsOneWidget);

        await tapBack(tester);
        expect(currentPath(tester), RoutePaths.home);
        await tester.tap(find.text(l10n.homeCategoriesAction));
        await tester.pumpAndSettle();
        expect(currentPath(tester), RoutePaths.categories);
      });

      testWidgets('no products: the card asks to add products', (tester) async {
        await open(tester, FakeProductsStore());
        expect(find.text(l10n.lowStockNoProducts), findsOneWidget);
      });

      testWidgets('nothing low: the card says stock is fine', (tester) async {
        final store = FakeProductsStore()
          ..seedProduct('شاي', stockMilli: 9000, lowStockMilli: 1000);
        await open(tester, store);
        expect(find.text(l10n.lowStockNone), findsOneWidget);
      });

      for (final textScale in [1.0, 2.0]) {
        testWidgets('7 low: 5 lowest shown, 7 counted, opens the low list '
            '(text ×$textScale)', (tester) async {
          final store = FakeProductsStore();
          for (var i = 1; i <= 7; i++) {
            store.seedProduct(
              'منتج $i',
              stockMilli: i * 1000,
              lowStockMilli: 10000,
            );
          }
          store.seedProduct('كثير', stockMilli: 50000, lowStockMilli: 1000);
          await open(tester, store, textScale: textScale);
          expect(tester.takeException(), isNull);

          for (var i = 1; i <= 5; i++) {
            expect(find.text('منتج $i'), findsOneWidget);
          }
          expect(find.text('منتج 6'), findsNothing);
          expect(find.text('كثير'), findsNothing);
          final countText = locale == AppLocale.ar ? '٧' : '7';
          final count = find.text(l10n.lowStockCount(7, countText));
          expect(count, findsOneWidget);

          await tester.ensureVisible(count);
          await tester.tap(count);
          await tester.pumpAndSettle();
          expect(routerOf(tester).state.uri.toString(), RoutePaths.productsLow);
          // The list is filtered to low stock.
          expect(find.text('منتج 1'), findsOneWidget);
          expect(find.text('كثير'), findsNothing);
        });
      }

      testWidgets('a card row opens the product', (tester) async {
        final store = FakeProductsStore();
        final id = store.seedProduct(
          'شاي',
          stockMilli: 1000,
          lowStockMilli: 2000,
        );
        await open(tester, store);
        await tester.tap(find.text('شاي'));
        await tester.pumpAndSettle();
        expect(currentPath(tester), RoutePaths.productDetails(id));
      });
    });
  }
}
