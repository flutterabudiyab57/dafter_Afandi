import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// The four variants every shared-widget test runs in.
const List<(String, double)> kVariants = [
  ('ar', 1.0),
  ('ar', 2.0),
  ('en', 1.0),
  ('en', 2.0),
];

/// Runs [body] as one test per locale and text scale.
void testVariants(
  String description,
  Future<void> Function(WidgetTester tester, AppLocalizations l10n) body,
) {
  for (final (locale, scale) in kVariants) {
    testWidgets('$locale ×$scale $description', (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(420, 812);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await body(tester, lookupAppLocalizations(Locale(locale)));
    });
  }
}

/// Pumps [child] in a phone-sized app in [l10n]'s locale and RTL/LTR.
Future<void> pumpInApp(
  WidgetTester tester,
  AppLocalizations l10n,
  Widget child, {
  ThemeData? theme,
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(l10n.localeName),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: theme ?? appLightTheme(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
}
