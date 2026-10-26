import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/widgets/app_illustration.dart';
import 'package:daftar_afandi/core/widgets/result_view.dart';
import 'package:daftar_afandi/core/widgets/starting_app.dart';
import 'package:daftar_afandi/core/widgets/startup_error_app.dart';
import 'package:daftar_afandi/core/widgets/status_banner.dart';
import 'package:daftar_afandi/core/widgets/update_required_app.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

/// Phase 6 of 005: app start, the blocking apps, welcome, data safety and
/// reports (US4).
void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  Future<void> phone(
    WidgetTester tester, {
    double textScale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(375, 812);
    tester.platformDispatcher
      ..textScaleFactorTestValue = textScale
      ..platformBrightnessTestValue = brightness;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);
  }

  AppIllustration shown(WidgetTester tester) =>
      tester.widget<Illustration>(find.byType(Illustration)).kind;

  testWidgets('the starting app shows the logo, progress and its text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await phone(tester);
    await tester.pumpWidget(const StartingApp());
    await tester.pump();
    expect(find.bySemanticsLabel(ar.logoSemantics), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(ar.openingDataLabel), findsOneWidget);
    handle.dispose();
  });

  for (final brightness in Brightness.values) {
    testWidgets('blocking apps at 200% in ${brightness.name}: illustration, '
        'title and text, no overflow (US4-1, US4-2)', (tester) async {
      await phone(tester, textScale: 2, brightness: brightness);
      for (final (app, kind, title) in [
        (const StartupErrorApp(), AppIllustration.errorDatabase, ar.appName),
        (
          const UpdateRequiredApp(kind: UpdateRequiredKind.tooNew),
          AppIllustration.updateRequired,
          ar.updateRequiredTitle,
        ),
      ]) {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(ResultView), findsOneWidget);
        expect(shown(tester), kind);
        expect(find.text(title), findsOneWidget);
        final image = tester.widget<Image>(
          find.descendant(
            of: find.byType(Illustration),
            matching: find.byType(Image),
          ),
        );
        final folder = brightness == Brightness.dark ? '/dark/' : '/light/';
        expect((image.image as AssetImage).assetName, contains(folder));
      }
    });
  }

  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    for (final textScale in [1.0, 2.0]) {
      final tag = '${locale.name} ×$textScale';

      Future<void> pumpIn(
        WidgetTester tester,
        FakeSettingsRepository repo,
      ) async {
        if (locale == AppLocale.en) await repo.setLocale(AppLocale.en);
        await pumpApp(tester, repo, textScale: textScale);
      }

      testWidgets(
        '$tag welcome shows its illustration, hidden from screen readers',
        (tester) async {
          final handle = tester.ensureSemantics();
          await pumpIn(tester, FakeSettingsRepository());
          await goTo(tester, RoutePaths.welcome);
          expect(shown(tester), AppIllustration.welcome);
          final image = tester.widget<Image>(
            find.descendant(
              of: find.byType(Illustration),
              matching: find.byType(Image),
            ),
          );
          expect(image.excludeFromSemantics, isTrue);
          handle.dispose();
        },
      );

      for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
        testWidgets(
          '$tag data safety on ${platform.name}: an info banner, and a '
          'warning on iOS only (US4-3)',
          (tester) async {
            debugDefaultTargetPlatformOverride = platform;
            addTearDown(() => debugDefaultTargetPlatformOverride = null);
            await pumpIn(tester, FakeSettingsRepository(kOnboardedSettings));
            await goTo(tester, RoutePaths.settingsData);
            expect(shown(tester), AppIllustration.dataSafety);
            final banners = tester
                .widgetList<StatusBanner>(find.byType(StatusBanner))
                .map((b) => b.tone)
                .toList();
            expect(
              banners,
              platform == TargetPlatform.iOS
                  ? [StatusTone.info, StatusTone.warning]
                  : [StatusTone.info],
            );
            debugDefaultTargetPlatformOverride = null;
          },
        );
      }

      testWidgets('$tag reports keeps its placeholder, with an illustration', (
        tester,
      ) async {
        await pumpIn(tester, FakeSettingsRepository(kOnboardedSettings));
        await goTo(tester, RoutePaths.reports);
        expect(shown(tester), AppIllustration.emptyReports);
        expect(find.text(l10n.placeholderReportsTitle), findsWidgets);
      });
    }
  }
}
