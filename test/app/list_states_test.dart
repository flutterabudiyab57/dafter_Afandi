import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/widgets/app_illustration.dart';
import 'package:daftar_afandi/core/widgets/load_failed_view.dart';
import 'package:daftar_afandi/core/widgets/status_badge.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_products.dart';
import '../helpers/fake_purchases.dart';
import '../helpers/fake_sales.dart';
import '../helpers/pump_app.dart';

/// Phase 4 of 005: every list's empty, no-results, load-failed and marked
/// states, and archive undo (US1, US2, US3).
void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeProductsStore products;
        late FakeSalesStore sales;
        late FakePurchasesStore purchases;

        Future<void> open(WidgetTester tester, String path) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (locale == AppLocale.en) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            textScale: textScale,
            products: FakeProductsCubits(products),
            customers: FakeCustomersCubits(sales),
            sales: FakeSalesCubits(sales),
            suppliers: FakeSuppliersCubits(purchases),
            purchases: FakePurchasesCubits(purchases),
          );
          await goTo(tester, path);
        }

        setUp(() {
          products = FakeProductsStore();
          sales = FakeSalesStore(products);
          purchases = FakePurchasesStore(products);
        });

        AppIllustration shown(WidgetTester tester) =>
            tester.widget<Illustration>(find.byType(Illustration)).kind;

        testWidgets('each empty list shows its own illustration (US2-3)', (
          tester,
        ) async {
          for (final (path, kind) in [
            (RoutePaths.products, AppIllustration.emptyProducts),
            (RoutePaths.sales, AppIllustration.emptySales),
            (RoutePaths.parties, AppIllustration.emptyCustomers),
            (RoutePaths.suppliers, AppIllustration.emptySuppliers),
            (RoutePaths.purchases, AppIllustration.emptyPurchases),
            (RoutePaths.productsArchived, AppIllustration.emptyArchive),
          ]) {
            await open(tester, path);
            expect(shown(tester), kind, reason: path);
          }
        });

        testWidgets('no results, then Clear shows the list again (US2-2)', (
          tester,
        ) async {
          products.seedProduct('شاي');
          await open(tester, RoutePaths.products);
          await tester.enterText(find.byType(TextField), 'zzz');
          await tester.pump(const Duration(milliseconds: 250));
          await tester.pumpAndSettle();
          expect(shown(tester), AppIllustration.emptySearch);
          expect(find.text(l10n.searchEmptyTitle), findsOneWidget);

          await tester.ensureVisible(find.text(l10n.searchClearAction));
          await tester.tap(find.text(l10n.searchClearAction));
          await tester.pumpAndSettle();
          expect(find.text('شاي'), findsOneWidget);
          expect(find.byType(Illustration), findsNothing);
        });

        testWidgets('a failed load offers Retry, which loads the list', (
          tester,
        ) async {
          sales.seedCustomer('منى');
          sales.failNextWatch = StateError('db');
          await open(tester, RoutePaths.parties);
          expect(find.byType(LoadFailedView), findsOneWidget);
          expect(find.text(l10n.loadFailedTitle), findsOneWidget);

          await tester.ensureVisible(find.text(l10n.retryAction));
          await tester.tap(find.text(l10n.retryAction));
          await tester.pumpAndSettle();
          expect(find.byType(LoadFailedView), findsNothing);
          expect(find.text('منى'), findsOneWidget);
        });

        testWidgets('a details page that fails to load offers Retry, not an '
            'endless spinner', (tester) async {
          final product = products.seedProduct('شاي');
          final customer = sales.seedCustomer('منى');
          final supplier = purchases.seedSupplier('مورد');
          // Armed once the section's list is showing, so only the details
          // page's own stream fails.
          for (final (list, path, fail, name) in [
            (
              RoutePaths.products,
              RoutePaths.productDetails(product),
              () => products.failNextWatch = StateError('db'),
              'شاي',
            ),
            (
              RoutePaths.parties,
              RoutePaths.customerDetails(customer),
              () => sales.failNextWatch = StateError('db'),
              'منى',
            ),
            (
              RoutePaths.suppliers,
              RoutePaths.supplierDetails(supplier),
              () => purchases.failNextWatch = StateError('db'),
              'مورد',
            ),
          ]) {
            await open(tester, list);
            fail();
            await goTo(tester, path);
            expect(find.byType(LoadFailedView), findsOneWidget, reason: path);
            expect(find.text(name), findsNothing, reason: path);

            await tester.ensureVisible(find.text(l10n.retryAction));
            await tester.tap(find.text(l10n.retryAction));
            await tester.pumpAndSettle();
            expect(find.byType(LoadFailedView), findsNothing, reason: path);
            expect(find.text(name), findsWidgets, reason: path);
          }
        });

        testWidgets('Undo after leaving the product says why a restore was '
            'refused', (tester) async {
          final id = products.seedProduct('شاي', barcode: '123');
          await open(tester, RoutePaths.productDetails(id));
          await tester.ensureVisible(find.text(l10n.productArchiveAction));
          await tester.tap(find.text(l10n.productArchiveAction));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.productArchiveAction).last);
          await tester.pumpAndSettle();
          await goTo(tester, RoutePaths.products);
          products.seedProduct('قهوة', barcode: '123');
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.undoAction));
          await tester.pumpAndSettle();
          expect(products.summary(id)!.product.archived, isTrue);
          expect(find.text(l10n.errorRestoreBarcodeTaken('قهوة')), findsOne);
        });

        testWidgets('low stock and below zero are two different badges', (
          tester,
        ) async {
          products
            ..seedProduct('أرز', stockMilli: 1000, lowStockMilli: 5000)
            ..seedProduct('سكر', stockMilli: -1000);
          await open(tester, RoutePaths.products);
          final low = tester.widget<StatusBadge>(
            find.ancestor(
              of: find.text(l10n.markLowStock),
              matching: find.byType(StatusBadge),
            ),
          );
          final below = tester.widget<StatusBadge>(
            find.ancestor(
              of: find.text(l10n.markBelowZero),
              matching: find.byType(StatusBadge),
            ),
          );
          expect(low.tone, BadgeTone.owes);
          expect(below.tone, BadgeTone.error);
        });

        testWidgets('archive offers Undo, which brings the product back '
            '(US1-1); the last one archived empties the list', (tester) async {
          final id = products.seedProduct('شاي');
          await open(tester, RoutePaths.productDetails(id));
          await tester.ensureVisible(find.text(l10n.productArchiveAction));
          await tester.tap(find.text(l10n.productArchiveAction));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.productArchiveAction).last);
          await tester.pumpAndSettle();
          expect(find.text(l10n.productArchivedMessage), findsOneWidget);
          expect(products.summary(id)!.product.archived, isTrue);

          await tester.tap(find.text(l10n.undoAction));
          await tester.pumpAndSettle();
          expect(products.summary(id)!.product.archived, isFalse);

          await tester.ensureVisible(find.text(l10n.productArchiveAction));
          await tester.tap(find.text(l10n.productArchiveAction));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l10n.productArchiveAction).last);
          await tester.pumpAndSettle();
          await goTo(tester, RoutePaths.products);
          expect(shown(tester), AppIllustration.emptyProducts);
        });
      });
    }
  }
}
