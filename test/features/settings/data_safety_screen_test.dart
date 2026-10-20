import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/settings/presentation/data_safety_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

/// Pumps the screen alone, as settings mode needs no form cubit.
Future<void> _pumpScreen(
  WidgetTester tester,
  DataSafetyMode mode,
  Locale locale,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: DataSafetyScreen(mode: mode),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in const [Locale('ar'), Locale('en')]) {
    final l10n = lookupAppLocalizations(locale);

    testWidgets('${locale.languageCode}: Android shows the auto-backup text', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await _pumpScreen(tester, DataSafetyMode.settings, locale);
        expect(find.text(l10n.dataSafetyLocalOnly), findsOneWidget);
        expect(find.text(l10n.dataSafetyAndroidBackup), findsOneWidget);
        expect(find.text(l10n.dataSafetyIosManual), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('${locale.languageCode}: iOS shows the manual-export text', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await _pumpScreen(tester, DataSafetyMode.settings, locale);
        expect(find.text(l10n.dataSafetyLocalOnly), findsOneWidget);
        expect(find.text(l10n.dataSafetyIosManual), findsOneWidget);
        expect(find.text(l10n.dataSafetyAndroidBackup), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('${locale.languageCode}: settings mode has no Finish', (
      tester,
    ) async {
      await _pumpScreen(tester, DataSafetyMode.settings, locale);
      expect(find.text(l10n.finishAction), findsNothing);
      expect(find.byType(FilledButton), findsNothing);
    });
  }

  group('onboarding mode', () {
    Future<FakeSettingsRepository> reachDataStep(WidgetTester tester) async {
      final repo = FakeSettingsRepository();
      await pumpApp(tester, repo);
      await goTo(tester, RoutePaths.onboardingShop);
      await tester.enterText(
        find.widgetWithText(TextField, 'اسم المحل'),
        'محل 23',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'متابعة'));
      await tester.pumpAndSettle();
      return repo;
    }

    testWidgets('Finish saves and the redirect goes to Home', (tester) async {
      final repo = await reachDataStep(tester);
      await tester.tap(find.text('ابدأ'));
      await tester.pumpAndSettle();
      expect(repo.writes.single.$1, 'completeOnboarding');
      expect(currentPath(tester), RoutePaths.home);
    });

    testWidgets('a failed save shows the error and keeps the inputs', (
      tester,
    ) async {
      final repo = await reachDataStep(tester);
      repo.failWith = 'disk full';
      await tester.tap(find.text('ابدأ'));
      await tester.pumpAndSettle();
      expect(
        find.text(lookupAppLocalizations(const Locale('ar')).errorSaveFailed),
        findsOneWidget,
      );
      expect(currentPath(tester), RoutePaths.onboardingData);

      await tapBack(tester);
      expect(find.text('محل 23'), findsOneWidget);

      // A retry after the problem is gone succeeds.
      repo.failWith = null;
      await tester.tap(find.widgetWithText(FilledButton, 'متابعة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ابدأ'));
      await tester.pumpAndSettle();
      expect(currentPath(tester), RoutePaths.home);
      expect(repo.value.locale, AppLocale.ar);
    });
  });
}
