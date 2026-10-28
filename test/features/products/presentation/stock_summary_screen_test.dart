import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;
    String egp(String latin, String arabic) =>
        ar ? '$arabic ج.م' : 'EGP $latin';

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        Future<void> open(WidgetTester tester, String path) async {
          final store = FakeProductsStore();
          final cheese = store.seedCategory('جبن');
          final halawa = store.seedCategory('حلاوة');
          store
            ..seedProduct(
              'رومي',
              categoryId: cheese,
              stockMilli: 60000,
              costPiasters: 1000,
              pricePiasters: 1200,
            )
            ..seedProduct(
              'فيتا',
              categoryId: cheese,
              unit: UnitType.kg,
              stockMilli: 2500,
              costPiasters: 8000,
              pricePiasters: 9000,
            )
            ..seedProduct(
              'حلاوة سادة',
              categoryId: halawa,
              stockMilli: 30000,
              costPiasters: 500,
              pricePiasters: 700,
            );
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            products: FakeProductsCubits(store),
            textScale: textScale,
          );
          await goTo(tester, path);
          expect(tester.takeException(), isNull);
        }

        // 60 × 10 + 2.5 × 80 + 30 × 5 = 950.
        final atCost = egp('950.00', '٩٥٠٫٠٠');

        testWidgets('the product list shows the value and opens the '
            'summary', (tester) async {
          await open(tester, RoutePaths.products);
          final line = find.text(l10n.stockValueAtCost(atCost));
          expect(line, findsOneWidget);
          await tester.tap(line);
          await tester.pumpAndSettle();
          expect(currentPath(tester), RoutePaths.productsStock);
        });

        testWidgets('the summary: both values and each category', (
          tester,
        ) async {
          await open(tester, RoutePaths.productsStock);
          expect(find.text(l10n.stockValueAtCost(atCost)), findsOneWidget);
          // 60 × 12 + 2.5 × 90 + 30 × 7 = 1,155.
          expect(
            find.text(l10n.stockValueAtSale(egp('1,155.00', '١٬١٥٥٫٠٠'))),
            findsOneWidget,
          );
          expect(find.text('جبن'), findsOneWidget);
          expect(
            find.text(ar ? '٦٠ قطعة · ٢٫٥ كجم' : '60 pc · 2.5 kg'),
            findsOneWidget,
          );
          expect(find.text(ar ? '٣٠ قطعة' : '30 pc'), findsOneWidget);
          expect(
            find.text(l10n.stockGroupValue(egp('800.00', '٨٠٠٫٠٠'))),
            findsOneWidget,
          );
        });
      });
    }
  }
}
