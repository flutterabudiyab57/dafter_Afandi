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

        testWidgets('shows every detail of the product', (tester) async {
          final store = FakeProductsStore();
          final drinks = store.seedCategory('مشروبات');
          final id = store.seedProduct(
            'شاي العروسة',
            pricePiasters: 1250,
            stockMilli: 3000,
            costPiasters: 900,
            lowStockMilli: 5000,
            barcode: '1234',
            sku: 'T-1',
            categoryId: drinks,
          );
          await open(tester, store, RoutePaths.productDetails(id));
          expect(find.text('شاي العروسة'), findsOneWidget);
          expect(find.text('مشروبات'), findsOneWidget);
          expect(find.text(ar ? '١٢٫٥٠ ج.م' : 'EGP 12.50'), findsOneWidget);
          expect(find.text(ar ? '٩٫٠٠ ج.م' : 'EGP 9.00'), findsOneWidget);
          expect(
            find.text(ar ? '٣ ${l10n.unitPieceShort}' : '3 pc'),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
          expect(find.textContaining('1234'), findsOneWidget);
          expect(find.text('T-1'), findsOneWidget);
        });

        testWidgets('edit the price: saved and shown on return', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('شاي', pricePiasters: 1000);
          await open(tester, store, RoutePaths.productDetails(id));
          await tapVisible(tester, find.text(l10n.productEditAction));
          expect(currentPath(tester), RoutePaths.productEdit(id));
          final price = find.widgetWithText(TextField, l10n.productPriceLabel);
          await tester.enterText(price, '12.75');
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(currentPath(tester), RoutePaths.productDetails(id));
          expect(find.text(ar ? '١٢٫٧٥ ج.م' : 'EGP 12.75'), findsOneWidget);
        });

        testWidgets('after history the unit is locked with a note', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('أرز', stockMilli: 1000);
          await open(tester, store, RoutePaths.productEdit(id));
          expect(find.text(l10n.productUnitLockedNote), findsOneWidget);
          await tester.tap(find.text(l10n.unitKg));
          await tester.pump();
          final kg = tester.widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, l10n.unitKg),
          );
          expect(kg.selected, isFalse);
          expect(kg.onSelected, isNull);
          // Opening stock is offered only without history.
          await goTo(tester, RoutePaths.productDetails(id));
          expect(find.text(l10n.productSetOpeningAction), findsNothing);
        });

        testWidgets('archive asks first, then hides it; restore brings it '
            'back', (tester) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('أرز', stockMilli: 9000);
          await open(tester, store, RoutePaths.productDetails(id));
          expect(find.text(l10n.productSetOpeningAction), findsNothing);

          await tapVisible(tester, find.text(l10n.productArchiveAction));
          expect(find.text(l10n.productArchiveConfirm), findsOneWidget);
          await tester.tap(find.text(l10n.cancelAction));
          await tester.pumpAndSettle();
          expect(store.writes, isEmpty);

          await tapVisible(tester, find.text(l10n.productArchiveAction));
          await tester.tap(find.text(l10n.productArchiveAction).last);
          await tester.pumpAndSettle();
          expect(find.text(l10n.productArchivedBadge), findsOneWidget);
          expect(store.summaries(const ProductQuery()), isEmpty);

          await tapVisible(tester, find.text(l10n.productRestoreAction));
          expect(find.text(l10n.productRestored), findsOneWidget);
          expect(store.summaries(const ProductQuery()).single.stockMilli, 9000);
        });

        testWidgets('restore is blocked when the barcode is taken', (
          tester,
        ) async {
          final store = FakeProductsStore();
          final id = store.seedProduct('قديم', barcode: '1', archived: true);
          store.seedProduct('جديد', barcode: '1');
          await open(tester, store, RoutePaths.productDetails(id));
          await tapVisible(tester, find.text(l10n.productRestoreAction));
          expect(
            find.text(l10n.errorRestoreBarcodeTaken('جديد')),
            findsOneWidget,
          );
          expect(store.summary(id)!.product.archived, isTrue);
        });

        testWidgets('the archived list restores, and no delete exists', (
          tester,
        ) async {
          final store = FakeProductsStore();
          store
            ..seedProduct('قديم', archived: true, unit: UnitType.kg)
            ..seedProduct('نشط');
          await open(tester, store, RoutePaths.productsArchived);
          expect(find.text('قديم'), findsOneWidget);
          expect(find.text('نشط'), findsNothing);
          await tester.tap(find.text(l10n.productRestoreAction));
          await tester.pumpAndSettle();
          expect(find.text(l10n.productsArchivedEmpty), findsOneWidget);
          expect(find.byIcon(Icons.delete), findsNothing);
          expect(find.byIcon(Icons.delete_outline), findsNothing);
        });

        testWidgets('a missing product says so', (tester) async {
          await open(
            tester,
            FakeProductsStore(),
            RoutePaths.productDetails('nope'),
          );
          expect(find.text(l10n.productNotFound), findsOneWidget);
        });
      });
    }
  }
}
