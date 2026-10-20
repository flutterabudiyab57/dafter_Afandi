/// Every route path (contracts/routes-and-screens.md).
abstract final class RoutePaths {
  static const String welcome = '/welcome';
  static const String onboardingShop = '/onboarding/shop';
  static const String onboardingData = '/onboarding/data';
  static const String home = '/home';
  static const String sales = '/sales';
  static const String parties = '/parties';
  static const String purchases = '/purchases';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String settingsShop = '/settings/shop';
  static const String settingsData = '/settings/data';

  /// The first-run routes: the only ones allowed before onboarding, and
  /// never shown after it.
  static bool isFirstRun(String path) =>
      path == welcome ||
      path == '/onboarding' ||
      path.startsWith('/onboarding/');
}
