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
    final ar = locale == AppLocale.ar;

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        Future<void> open(
          WidgetTester tester,
          FakeProductsStore store, [
          String path = RoutePaths.categories,
        ]) async {
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

        Future<void> tapVisible(WidgetTester tester, Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Finder addField() =>
            find.widgetWithText(TextField, l10n.categoryAddHint);

        Future<void> add(WidgetTester tester, String name) async {
          await tester.enterText(addField(), name);
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.categoryAddAction),
          );
        }

        testWidgets('add, then a folded duplicate is blocked', (tester) async {
          final store = FakeProductsStore();
          await open(tester, store);
          expect(find.text(l10n.categoriesEmpty), findsOneWidget);
          await add(tester, 'أدوات');
          expect(find.text('أدوات'), findsOneWidget);
          expect(find.text(l10n.categoryProductCount(0, '0')), findsOneWidget);

          await add(tester, 'ادوات');
          expect(find.text(l10n.errorCategoryDuplicate), findsOneWidget);
          expect(store.writes, ['category أدوات']);

          await add(tester, '   ');
          expect(find.text(l10n.errorCategoryNameRequired), findsOneWidget);
        });

        testWidgets('a rename shows on its products', (tester) async {
          final store = FakeProductsStore();
          final c = store.seedCategory('مشروبات');
          final p = store.seedProduct('شاي', categoryId: c);
          await open(tester, store);
          await tapVisible(tester, find.byTooltip(l10n.categoryRename));
          await tester.enterText(
            find.widgetWithText(TextField, l10n.categoryNameLabel),
            'مشروبات ساخنة',
          );
          await tester.tap(find.widgetWithText(FilledButton, l10n.saveAction));
          await tester.pumpAndSettle();
          expect(find.text('مشروبات ساخنة'), findsOneWidget);

          await goTo(tester, RoutePaths.productDetails(p));
          expect(find.text('مشروبات ساخنة'), findsOneWidget);
        });

        testWidgets('archive asks first; its products show under No category', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final c = store.seedCategory('مشروبات');
          store
            ..seedCategory('منظفات')
            ..seedProduct('شاي', categoryId: c);
          await open(tester, store);

          await tapVisible(tester, find.byTooltip(l10n.categoryArchive).first);
          await tester.tap(find.text(l10n.cancelAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);

          await tapVisible(tester, find.byTooltip(l10n.categoryArchive).first);
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.categoryArchive),
          );
          await tester.pumpAndSettle();
          expect(find.text('مشروبات'), findsNothing);

          await goTo(tester, RoutePaths.products);
          expect(find.widgetWithText(ChoiceChip, 'مشروبات'), findsNothing);
          await tapVisible(
            tester,
            find.widgetWithText(ChoiceChip, l10n.productsFilterNoCategory),
          );
          expect(find.text('شاي'), findsOneWidget);
        });

        testWidgets('move down reorders the filter chips; the ends are '
            'disabled', (tester) async {
          final store = FakeProductsStore();
          store
            ..seedCategory('أول')
            ..seedCategory('ثاني');
          await open(tester, store);

          IconButton button(String tooltip, int i) => tester.widget<IconButton>(
            find
                .widgetWithIcon(IconButton, switch (tooltip) {
                  'up' => Icons.arrow_upward,
                  _ => Icons.arrow_downward,
                })
                .at(i),
          );
          expect(button('up', 0).onPressed, isNull);
          expect(button('down', 1).onPressed, isNull);

          await tapVisible(tester, find.byTooltip(l10n.categoryMoveDown).first);
          expect(
            tester.getTopLeft(find.text('ثاني')).dy,
            lessThan(tester.getTopLeft(find.text('أول')).dy),
          );

          await goTo(tester, RoutePaths.products);
          final chips = tester
              .widgetList<ChoiceChip>(find.byType(ChoiceChip))
              .map((c) => ((c.label as Text).data))
              .toList();
          expect(chips.indexOf('ثاني'), lessThan(chips.indexOf('أول')));
        });
      });
    }
  }
}
