import 'package:daftar_afandi/core/router/app_router.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Every route registered in this phase.
const List<String> _firstRun = [
  RoutePaths.welcome,
  RoutePaths.onboardingShop,
  RoutePaths.onboardingData,
];
const List<String> _afterFirstRun = [
  RoutePaths.home,
  RoutePaths.sales,
  RoutePaths.parties,
  RoutePaths.purchases,
  RoutePaths.reports,
  RoutePaths.settings,
  RoutePaths.settingsShop,
  RoutePaths.settingsData,
];

void main() {
  group('firstRunRedirect matrix', () {
    const all = [
      RoutePaths.welcome,
      RoutePaths.onboardingShop,
      RoutePaths.onboardingData,
      RoutePaths.home,
      RoutePaths.sales,
      RoutePaths.parties,
      RoutePaths.purchases,
      RoutePaths.reports,
      RoutePaths.settings,
      RoutePaths.settingsShop,
      RoutePaths.settingsData,
    ];

    test('not onboarded: only first-run routes, everything else → welcome', () {
      for (final path in all) {
        expect(
          firstRunRedirect(path, false),
          RoutePaths.isFirstRun(path) ? isNull : RoutePaths.welcome,
          reason: path,
        );
      }
    });

    test('onboarded: never first-run routes, which go → home', () {
      for (final path in all) {
        expect(
          firstRunRedirect(path, true),
          RoutePaths.isFirstRun(path) ? RoutePaths.home : isNull,
          reason: path,
        );
      }
    });

    test('isFirstRun does not match look-alikes', () {
      expect(RoutePaths.isFirstRun('/onboardingx'), isFalse);
      expect(RoutePaths.isFirstRun('/welcome2'), isFalse);
      expect(RoutePaths.isFirstRun('/onboarding/shop'), isTrue);
    });
  });

  group('in the app', () {
    testWidgets('a fresh start lands on /welcome', (tester) async {
      await pumpApp(tester, FakeSettingsRepository());
      expect(currentPath(tester), RoutePaths.welcome);
    });

    testWidgets('not onboarded: first-run routes stay, others redirect', (
      tester,
    ) async {
      await pumpApp(tester, FakeSettingsRepository());
      for (final path in _firstRun) {
        await goTo(tester, path);
        expect(currentPath(tester), path);
      }
      for (final path in _afterFirstRun) {
        await goTo(tester, path);
        expect(currentPath(tester), RoutePaths.welcome, reason: path);
      }
    });

    testWidgets('onboarded: starts on /home and first-run routes redirect', (
      tester,
    ) async {
      await pumpApp(tester, FakeSettingsRepository(kOnboardedSettings));
      expect(currentPath(tester), RoutePaths.home);
      for (final path in _afterFirstRun) {
        await goTo(tester, path);
        expect(currentPath(tester), path);
      }
      for (final path in _firstRun) {
        await goTo(tester, path);
        expect(currentPath(tester), RoutePaths.home, reason: path);
      }
    });

    testWidgets('a restart while not onboarded lands on /welcome again', (
      tester,
    ) async {
      final repo = FakeSettingsRepository();
      await pumpApp(tester, repo);
      await goTo(tester, RoutePaths.onboardingData);

      await pumpApp(tester, FakeSettingsRepository(repo.value));
      expect(currentPath(tester), RoutePaths.welcome);
    });

    testWidgets('completing onboarding moves to /home by itself', (
      tester,
    ) async {
      final repo = FakeSettingsRepository();
      await pumpApp(tester, repo);
      await goTo(tester, RoutePaths.onboardingData);

      await repo.completeOnboarding(kOnboardedSettings.shop!);
      await tester.pumpAndSettle();
      expect(currentPath(tester), RoutePaths.home);
    });
  });
}
