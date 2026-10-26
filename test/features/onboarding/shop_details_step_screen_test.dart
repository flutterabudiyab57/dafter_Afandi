import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Finder _field(String label) => find.widgetWithText(TextField, label);

void main() {
  Future<FakeSettingsRepository> open(
    WidgetTester tester, {
    AppLocale locale = AppLocale.ar,
  }) async {
    final repo = FakeSettingsRepository();
    if (locale != AppLocale.ar) await repo.setLocale(locale);
    await pumpApp(tester, repo);
    await goTo(tester, RoutePaths.onboardingShop);
    return repo;
  }

  Future<void> tapContinue(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
  }

  testWidgets('an empty name blocks Continue, in Arabic', (tester) async {
    await open(tester);
    await tapContinue(tester, 'متابعة');
    expect(find.text('اكتب اسم المحل.'), findsOneWidget);
    expect(currentPath(tester), RoutePaths.onboardingShop);
  });

  testWidgets('a spaces-only name blocks Continue, in English', (tester) async {
    await open(tester, locale: AppLocale.en);
    await tester.enterText(_field('Shop name'), '    ');
    await tapContinue(tester, 'Continue');
    expect(find.text('Enter the shop name.'), findsOneWidget);
    expect(currentPath(tester), RoutePaths.onboardingShop);
  });

  testWidgets('a 61st code point cannot be typed', (tester) async {
    await open(tester);
    final sixty = 'م' * 60;
    await tester.enterText(_field('اسم المحل'), sixty);
    await tester.enterText(_field('اسم المحل'), '${sixty}x');
    final field = tester.widget<TextField>(_field('اسم المحل'));
    expect(field.controller!.text, sixty);

    // A long paste into an empty field is cut at 60.
    await tester.enterText(_field('اسم المحل'), '');
    await tester.enterText(_field('اسم المحل'), 'a' * 70);
    expect(field.controller!.text, 'a' * 60);
  });

  testWidgets('an empty phone is allowed', (tester) async {
    final repo = await open(tester);
    await tester.enterText(_field('اسم المحل'), 'محل 23');
    await tapContinue(tester, 'متابعة');
    expect(currentPath(tester), RoutePaths.onboardingData);
    expect(repo.writes, isEmpty, reason: 'nothing is saved before Finish');
  });

  testWidgets('an Arabic-digit phone with spaces and a dash is accepted', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(_field('اسم المحل'), 'محل 23');
    await tester.enterText(_field('رقم هاتف المحل'), '٠١٠ ١٢٣٤-٥٦٧٨');
    await tapContinue(tester, 'متابعة');
    expect(currentPath(tester), RoutePaths.onboardingData);
  });

  testWidgets('phone errors show limits in the active digit style', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(_field('اسم المحل'), 'محل');
    await tester.enterText(_field('رقم هاتف المحل'), '123');
    await tapContinue(tester, 'متابعة');
    expect(find.text('رقم الهاتف لا يقل عن ٧ أرقام.'), findsOneWidget);

    await tester.enterText(_field('رقم هاتف المحل'), '01x');
    await tapContinue(tester, 'متابعة');
    expect(find.textContaining('يقبل الأرقام فقط'), findsOneWidget);
    expect(currentPath(tester), RoutePaths.onboardingShop);
  });

  testWidgets('typed values survive going back from the data step', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(_field('اسم المحل'), 'محل 23');
    await tapContinue(tester, 'متابعة');
    expect(currentPath(tester), RoutePaths.onboardingData);

    await tapBack(tester);
    expect(currentPath(tester), RoutePaths.onboardingShop);
    expect(find.text('محل 23'), findsOneWidget);
  });
}
