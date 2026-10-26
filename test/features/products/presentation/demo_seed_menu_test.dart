import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/archived_products_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/screens/archived_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_products.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  Future<FakeProductsStore> pump(
    WidgetTester tester, {
    required bool debugTools,
  }) async {
    final store = FakeProductsStore();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: BlocProvider(
          create: (_) => ArchivedProductsCubit(store.products),
          child: ArchivedProductsScreen(debugTools: debugTools),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets('no demo-seed menu without the debug flag (release)', (
    tester,
  ) async {
    await pump(tester, debugTools: false);
    expect(find.byTooltip(l10n.demoSeedMenu), findsNothing);
    expect(find.text(l10n.demoSeedAction), findsNothing);
  });

  testWidgets('with the flag the menu seeds 2,000 products', (tester) async {
    final store = await pump(tester, debugTools: true);
    await tester.tap(find.byTooltip(l10n.demoSeedMenu));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.demoSeedAction));
    await tester.pumpAndSettle();
    expect(store.summaries(const ProductQuery()), hasLength(2000));
    expect(find.text(l10n.demoSeedDone('2000')), findsOneWidget);
  });
}
