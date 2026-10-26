import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
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

        Future<void> save(WidgetTester tester) => tapVisible(
          tester,
          find.widgetWithText(FilledButton, l10n.saveAction),
        );

        /// Opens details, then the adjust screen from its button, so Save
        /// returns to details.
        Future<void> openAdjust(
          WidgetTester tester,
          FakeProductsStore store,
          String id,
        ) async {
          await open(tester, store, RoutePaths.productDetails(id));
          await tapVisible(tester, find.text(l10n.productAdjustAction));
          expect(currentPath(tester), RoutePaths.productAdjust(id));
        }

        String qty(int n) => ar
            ? '${'٠١٢٣٤٥٦٧٨٩'[n]} ${l10n.unitPieceShort}'
            : '$n ${l10n.unitPieceShort}';

        testWidgets('10 on hand: count 8 then damage 1 gives 7, history '
            'shows all three, avg cost unchanged', (tester) async {
          final store = FakeProductsStore();
          final id = store.seedProduct(
            'شاي',
            stockMilli: 10000,
            costPiasters: 500,
          );
          await openAdjust(tester, store, id);
          expect(
            find.text(l10n.adjustOnHand(ar ? '١٠ قطعة' : '10 pc')),
            findsOneWidget,
          );

          await type(tester, l10n.adjustCountedLabel, '8');
          await save(tester);
          expect(currentPath(tester), RoutePaths.productDetails(id));
          expect(find.text(l10n.adjustSaved(qty(8))), findsOneWidget);
          expect(store.stockOf(id), 8000);
          // The SnackBar covers the lower buttons at 200%.
          tester
              .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
              .removeCurrentSnackBar();
          await tester.pumpAndSettle();

          await tapVisible(tester, find.text(l10n.productAdjustAction));
          await tapVisible(tester, find.text(l10n.reasonDamage));
          await type(tester, l10n.adjustRemoveLabel, '1');
          await save(tester);
          expect(store.stockOf(id), 7000);
          expect(store.summary(id)!.product.avgCostPiasters, 500);

          // History, newest first: damage, count, opening.
          final damage = '${l10n.stockAdjustment} · ${l10n.reasonDamage}';
          final count = '${l10n.stockAdjustment} · ${l10n.reasonCount}';
          await tester.ensureVisible(find.text(l10n.stockOpening));
          expect(find.text(damage), findsOneWidget);
          expect(find.text(count), findsOneWidget);
          expect(find.text(l10n.stockOpening), findsOneWidget);
          expect(
            tester.getTopLeft(find.text(damage)).dy,
            lessThan(tester.getTopLeft(find.text(count)).dy),
          );
          expect(
            tester.getTopLeft(find.text(count)).dy,
            lessThan(tester.getTopLeft(find.text(l10n.stockOpening)).dy),
          );
          // History rows have no edit or delete.
          expect(find.byIcon(Icons.delete), findsNothing);
          expect(find.byIcon(Icons.delete_outline), findsNothing);
        });

        testWidgets('a count equal to the stock records nothing', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي', stockMilli: 5000);
          await openAdjust(tester, store, id);
          await type(tester, l10n.adjustCountedLabel, '5');
          await save(tester);
          expect(find.text(l10n.adjustAlreadyMatches), findsOneWidget);
          expect(store.writes, isEmpty);
          expect(currentPath(tester), RoutePaths.productAdjust(id));
        });

        testWidgets('damage above the stock is blocked', (tester) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي', stockMilli: 3000);
          await openAdjust(tester, store, id);
          await tapVisible(tester, find.text(l10n.reasonDamage));
          await type(tester, l10n.adjustRemoveLabel, '4');
          await save(tester);
          expect(find.text(l10n.adjustExceedsStock(qty(3))), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('other needs a note; with one it adds stock', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي', stockMilli: 2000);
          await openAdjust(tester, store, id);
          await tapVisible(tester, find.text(l10n.reasonOther));
          await tapVisible(tester, find.text(l10n.adjustAdd));
          await type(tester, l10n.adjustQtyLabel, '3');
          await save(tester);
          // The helper and the error both say a note is needed.
          expect(find.text(l10n.adjustNoteRequired), findsWidgets);
          expect(store.writes, isEmpty);

          await type(tester, l10n.adjustNoteLabel, 'هدية من المورد');
          await save(tester);
          expect(store.stockOf(id), 5000);
          await tester.ensureVisible(find.text('هدية من المورد'));
          expect(find.text('هدية من المورد'), findsOneWidget);
        });

        testWidgets('a fraction of a piece is rejected', (tester) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي', stockMilli: 2000);
          await openAdjust(tester, store, id);
          await type(tester, l10n.adjustCountedLabel, '1.5');
          await save(tester);
          expect(find.text(l10n.errorQuantityNotWhole), findsOneWidget);
          expect(store.writes, isEmpty);
        });

        testWidgets('kg counts take three decimals', (tester) async {
          final store = FakeProductsStore();
          final id = store.seedProduct(
            'دقيق',
            unit: UnitType.kg,
            stockMilli: 5000,
          );
          await openAdjust(tester, store, id);
          await type(tester, l10n.adjustCountedLabel, '4.250');
          await save(tester);
          expect(store.stockOf(id), 4250);
        });

        testWidgets('history shows every type and pages with Show more', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي', stockMilli: 1000);
          for (final type in StockEntryType.values) {
            if (type == StockEntryType.opening) continue;
            store.seedEntry(
              id,
              type,
              1000,
              reason: type == StockEntryType.adjustment
                  ? AdjustmentKind.other
                  : null,
            );
          }
          // 50 more rows push the oldest off the first page.
          for (var i = 0; i < 50; i++) {
            store.seedEntry(id, StockEntryType.sale, -1);
          }
          await open(tester, store, RoutePaths.productDetails(id));
          expect(find.text(l10n.stockOpening), findsNothing);
          await tapVisible(tester, find.text(l10n.historyShowMore));
          await tester.ensureVisible(find.text(l10n.stockOpening));
          for (final label in [
            l10n.stockOpening,
            l10n.stockPurchase,
            l10n.stockPurchaseVoid,
            l10n.stockSaleReturn,
            l10n.stockSaleVoid,
            '${l10n.stockAdjustment} · ${l10n.reasonOther}',
          ]) {
            expect(find.text(label), findsOneWidget, reason: label);
          }
          expect(find.text(l10n.historyShowMore), findsNothing);
        });
      });
    }
  }
}
