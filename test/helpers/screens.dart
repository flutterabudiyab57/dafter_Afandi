import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/widgets/startup_error_app.dart';
import 'package:daftar_afandi/core/widgets/update_required_app.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'pump_app.dart';

const List<String> kFirstRunPaths = [
  RoutePaths.welcome,
  RoutePaths.onboardingShop,
  RoutePaths.onboardingData,
];

const List<String> kOnboardedPaths = [
  RoutePaths.home,
  RoutePaths.sales,
  RoutePaths.parties,
  RoutePaths.purchases,
  RoutePaths.reports,
  RoutePaths.settings,
  RoutePaths.settingsShop,
  RoutePaths.settingsData,
];

const List<Widget> kBlockingApps = [
  UpdateRequiredApp(kind: UpdateRequiredKind.tooNew),
  UpdateRequiredApp(kind: UpdateRequiredKind.unrecognized),
  StartupErrorApp(),
];

/// Visits every screen of the app in [locale] and calls [check] on each,
/// with a name for failure messages. The view settings from [pumpApp]
/// stay in force for the blocking apps.
Future<void> visitEveryScreen(
  WidgetTester tester, {
  required AppLocale locale,
  required Future<void> Function(String screen) check,
  Size size = const Size(420, 812),
  double textScale = 1,
  Brightness brightness = Brightness.light,
}) async {
  Future<FakeSettingsRepository> repo(bool onboarded) async {
    final r = FakeSettingsRepository(
      onboarded ? kOnboardedSettings : kFreshSettings,
    );
    if (locale != AppLocale.ar) await r.setLocale(locale);
    return r;
  }

  Future<void> pump(bool onboarded) async => pumpApp(
    tester,
    await repo(onboarded),
    size: size,
    textScale: textScale,
    brightness: brightness,
  );

  await pump(false);
  for (final path in kFirstRunPaths) {
    await goTo(tester, path);
    await check(path);
  }
  await pump(true);
  for (final path in kOnboardedPaths) {
    await goTo(tester, path);
    await check(path);
  }
  for (final app in kBlockingApps) {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await check(app.toString());
  }
}
