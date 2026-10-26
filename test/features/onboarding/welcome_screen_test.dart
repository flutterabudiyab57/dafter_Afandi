import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('opens in Arabic and RTL even when the phone is in English', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await pumpApp(tester, FakeSettingsRepository());

    expect(find.text('أهلًا بك في دفتر أفندي'), findsOneWidget);
    expect(find.text('دفتر أفندي'), findsOneWidget);
    final context = tester.element(find.text('أهلًا بك في دفتر أفندي'));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('tapping English switches at once and is stored', (tester) async {
    final repo = FakeSettingsRepository();
    await pumpApp(tester, repo);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(repo.writes, [('setLocale', AppLocale.en)]);
    expect(find.text('Welcome to Daftar Afandi'), findsOneWidget);
    final context = tester.element(find.text('Welcome to Daftar Afandi'));
    expect(Directionality.of(context), TextDirection.ltr);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(repo.writes.last, ('setLocale', AppLocale.ar));
    expect(find.text('أهلًا بك في دفتر أفندي'), findsOneWidget);
  });

  testWidgets('the logo has a spoken label in both languages', (tester) async {
    final repo = FakeSettingsRepository();
    final semantics = tester.ensureSemantics();
    await pumpApp(tester, repo);
    expect(find.bySemanticsLabel('شعار دفتر أفندي'), findsOneWidget);

    await repo.setLocale(AppLocale.en);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Daftar Afandi logo'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('Continue opens the shop details step', (tester) async {
    await pumpApp(tester, FakeSettingsRepository());
    await tester.tap(find.text('متابعة'));
    await tester.pumpAndSettle();
    expect(currentPath(tester), RoutePaths.onboardingShop);
    expect(find.text('بيانات المحل'), findsOneWidget);
  });
}
