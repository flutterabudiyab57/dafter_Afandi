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
          FakeProductsStore store,
          String path,
        ) async {
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

        Future<void> type(
          WidgetTester tester,
          String label,
          String text,
        ) async {
          final f = find.widgetWithText(TextField, label);
          await tester.ensureVisible(f);
          await tester.enterText(f, text);
          await tester.pump();
        }

        testWidgets('set once from details: confirm, saved, then the action '
            'is gone', (tester) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي');
          await open(tester, store, RoutePaths.productDetails(id));
          await tapVisible(tester, find.text(l10n.productSetOpeningAction));
          expect(currentPath(tester), RoutePaths.productOpening(id));

          await type(tester, l10n.productOpeningQtyLabel, '12');
          await type(tester, l10n.productOpeningCostLabel, '7.50');
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(find.text(l10n.openingConfirmTitle), findsOneWidget);
          await tester.tap(find.text(l10n.confirmAction));
          await tester.pumpAndSettle();

          expect(currentPath(tester), RoutePaths.productDetails(id));
          expect(store.stockOf(id), 12000);
          expect(store.summary(id)!.product.avgCostPiasters, 750);
          expect(find.text(l10n.productSetOpeningAction), findsNothing);
          await tester.ensureVisible(find.text(l10n.stockOpening));
          expect(find.text(l10n.stockOpening), findsOneWidget);
        });

        testWidgets('Back in the dialog keeps the values; nothing saved', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي');
          await open(tester, store, RoutePaths.productOpening(id));
          await type(tester, l10n.productOpeningQtyLabel, '3');
          await type(tester, l10n.productOpeningCostLabel, '2');
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          await tester.tap(find.text(l10n.backAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);
          expect(find.text('3'), findsOneWidget);
        });

        testWidgets('a quantity and a cost are required', (tester) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي');
          await open(tester, store, RoutePaths.productOpening(id));
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(find.text(l10n.errorQuantityInvalid), findsOneWidget);
          await type(tester, l10n.productOpeningQtyLabel, '3');
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(find.text(l10n.errorOpeningCostRequired), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('a product with history goes back to its details', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي', stockMilli: 1000);
          await open(tester, store, RoutePaths.productOpening(id));
          expect(currentPath(tester), RoutePaths.productDetails(id));
          expect(store.writes, isEmpty);
        });
      });
    }
  }
}
