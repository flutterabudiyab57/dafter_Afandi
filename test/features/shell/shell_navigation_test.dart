import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final labels = [
      l10n.navHome,
      l10n.navSales,
      l10n.navParties,
      l10n.navPurchases,
      l10n.navReports,
    ];
    final sections = [
      (RoutePaths.home, l10n.placeholderHomeTitle, l10n.placeholderHomeBody),
      (RoutePaths.sales, l10n.placeholderSalesTitle, l10n.placeholderSalesBody),
      (
        RoutePaths.parties,
        l10n.placeholderPartiesTitle,
        l10n.placeholderPartiesBody,
      ),
      (
        RoutePaths.purchases,
        l10n.placeholderPurchasesTitle,
        l10n.placeholderPurchasesBody,
      ),
      (
        RoutePaths.reports,
        l10n.placeholderReportsTitle,
        l10n.placeholderReportsBody,
      ),
    ];

    Future<void> open(WidgetTester tester) async {
      final repo = FakeSettingsRepository(kOnboardedSettings);
      if (locale == AppLocale.en) await repo.setLocale(AppLocale.en);
      await pumpApp(tester, repo);
    }

    testWidgets(
      '${locale.name}: five destinations in order, Home at the start',
      (tester) async {
        await open(tester);
        final destinations = tester
            .widgetList<NavigationDestination>(
              find.byType(NavigationDestination),
            )
            .map((d) => d.label)
            .toList();
        expect(destinations, labels);

        final homeX = tester.getCenter(find.text(l10n.navHome).last).dx;
        final reportsX = tester.getCenter(find.text(l10n.navReports).last).dx;
        if (locale == AppLocale.ar) {
          expect(
            homeX,
            greaterThan(reportsX),
            reason: 'RTL: Home on the right',
          );
        } else {
          expect(homeX, lessThan(reportsX), reason: 'LTR: Home on the left');
        }
      },
    );

    testWidgets(
      '${locale.name}: Home, Sales, Parties and Purchases show content; the others a placeholder',
      (tester) async {
        await open(tester);
        for (final (index, (path, title, body)) in sections.indexed) {
          await tester.tap(find.text(labels[index]).last);
          await tester.pumpAndSettle();

          expect(currentPath(tester), path);
          final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
          expect(bar.selectedIndex, index);
          if (path == RoutePaths.home) {
            // Home has real content since 002: Products, Categories and the
            // low-stock card.
            expect(find.text(l10n.homeProductsAction), findsOneWidget);
            expect(find.text(l10n.homeCategoriesAction), findsOneWidget);
            expect(find.text(l10n.lowStockCardTitle), findsOneWidget);
            continue;
          }
          if (path == RoutePaths.sales) {
            // The invoice list since 003.
            expect(find.text(l10n.salesNewAction), findsOneWidget);
            expect(find.text(l10n.salesListEmpty), findsOneWidget);
            continue;
          }
          if (path == RoutePaths.purchases) {
            // The purchase list since 004.
            expect(find.text(l10n.purchasesNewAction), findsOneWidget);
            expect(find.text(l10n.purchasesListEmpty), findsOneWidget);
            continue;
          }
          if (path == RoutePaths.parties) {
            // The customer list since 003.
            expect(find.text(l10n.customersTitle), findsOneWidget);
            expect(find.text(l10n.customersEmpty), findsOneWidget);
            continue;
          }
          expect(find.text(body), findsOneWidget);
          expect(find.text(title), findsWidgets);
          // A placeholder, not a list of sample data.
          expect(find.byType(ListTile), findsNothing);
          expect(find.byType(ListView), findsNothing);
        }
      },
    );
  }

  testWidgets('the settings button opens settings above the shell', (
    tester,
  ) async {
    await pumpApp(tester, FakeSettingsRepository(kOnboardedSettings));
    await tester.tap(find.byTooltip('فتح الإعدادات'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), RoutePaths.settings);
    expect(find.byType(NavigationBar), findsNothing);

    await tapBack(tester);
    expect(currentPath(tester), RoutePaths.home);
  });
}
