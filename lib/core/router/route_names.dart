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

  // Products, under the Home branch (002 research R10).
  static const String products = '/home/products';
  static const String productsLow = '/home/products?filter=low';
  static const String productNew = '/home/products/new';
  static const String productsArchived = '/home/products/archived';
  static const String categories = '/home/categories';

  static String productDetails(String id) => '$products/$id';
  static String productEdit(String id) => '$products/$id/edit';
  static String productOpening(String id) => '$products/$id/opening';
  static String productAdjust(String id) => '$products/$id/adjust';

  /// The five section roots, where the shell shows its own app bar.
  static bool isSectionRoot(String path) =>
      const {home, sales, parties, purchases, reports}.contains(path);

  /// The first-run routes: the only ones allowed before onboarding, and
  /// never shown after it.
  static bool isFirstRun(String path) =>
      path == welcome ||
      path == '/onboarding' ||
      path.startsWith('/onboarding/');
}
