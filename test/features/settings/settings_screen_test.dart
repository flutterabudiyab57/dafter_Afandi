import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<FakeSettingsRepository> openSettings(WidgetTester tester) async {
    final repo = FakeSettingsRepository(kOnboardedSettings);
    await pumpApp(tester, repo);
    await goTo(tester, RoutePaths.settings);
    return repo;
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  // The stored phone is 01012345678.
  final arabicPhone = ltrIsolate('٠١٠١٢٣٤٥٦٧٨');
  final latinPhone = ltrIsolate('01012345678');

  testWidgets('only the five rows of FR-010', (tester) async {
    await openSettings(tester);
    for (final text in [
      'بيانات المحل',
      'اللغة',
      'شكل الأرقام',
      'عن بياناتك',
      'إصدار التطبيق',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  testWidgets('switching to English rebuilds LTR with no restart', (
    tester,
  ) async {
    final repo = await openSettings(tester);
    await tapText(tester, 'English');

    expect(repo.writes.last, ('setLocale', AppLocale.en));
    expect(find.text('Settings'), findsOneWidget);
    expect(currentPath(tester), RoutePaths.settings);
    final context = tester.element(find.text('Settings'));
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('follow-language digits: Arabic-Indic in ar, Latin in en', (
    tester,
  ) async {
    await openSettings(tester);
    expect(find.text(arabicPhone), findsOneWidget);

    await tapText(tester, 'English');
    expect(find.text(latinPhone), findsOneWidget);
  });

  testWidgets('an explicit digit style survives a language switch', (
    tester,
  ) async {
    final repo = await openSettings(tester);
    await tapText(tester, 'أرقام لاتينية (0123)');
    expect(repo.writes.last, ('setDigitStyle', DigitStylePreference.latin));
    expect(find.text(latinPhone), findsOneWidget);

    await tapText(tester, 'English');
    await tapText(tester, 'العربية');
    expect(find.text(latinPhone), findsOneWidget, reason: 'still Latin in ar');

    await tapText(tester, 'حسب اللغة');
    expect(find.text(arabicPhone), findsOneWidget, reason: 'follow restored');
  });

  testWidgets('the shop name is shown exactly as typed under both styles', (
    tester,
  ) async {
    await openSettings(tester);
    expect(find.text('محل 23'), findsOneWidget);
    expect(find.text(arabicPhone), findsOneWidget);

    await tapText(tester, 'أرقام لاتينية (0123)');
    expect(find.text('محل 23'), findsOneWidget);
    expect(find.text(latinPhone), findsOneWidget);

    await tapText(tester, 'أرقام عربية (٠١٢٣)');
    expect(find.text('محل 23'), findsOneWidget, reason: 'never ٢٣');
  });

  testWidgets('the version is Latin even under Arabic-Indic digits', (
    tester,
  ) async {
    await openSettings(tester);
    await tapText(tester, 'أرقام عربية (٠١٢٣)');
    await tester.scrollUntilVisible(find.text(ltrIsolate('1.0.0 (1)')), 50);
    expect(find.text(ltrIsolate('1.0.0 (1)')), findsOneWidget);
  });

  testWidgets('rows open the shop editor and the data screen', (tester) async {
    await openSettings(tester);
    await tapText(tester, 'بيانات المحل');
    expect(currentPath(tester), RoutePaths.settingsShop);
    await tapBack(tester);

    await tapText(tester, 'عن بياناتك');
    expect(currentPath(tester), RoutePaths.settingsData);
    expect(find.text('ابدأ'), findsNothing, reason: 'no Finish in settings');
    await tapBack(tester);
    expect(currentPath(tester), RoutePaths.settings);
  });
}
