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

  // Sales, under the Sales branch (003 research R15).
  static const String salesNew = '/sales/new';
  static String saleInvoice(String id) => '$sales/$id';

  // Customers, under the Parties branch.
  static const String customerNew = '/parties/customers/new';
  static const String customersArchived = '/parties/customers/archived';
  static String customerDetails(String id) => '$parties/customers/$id';
  static String customerEdit(String id) => '$parties/customers/$id/edit';
  static String customerPayment(String id) => '$parties/customers/$id/payment';

  // Suppliers, a second root of the Parties branch (004 research R15).
  static const String suppliers = '/parties/suppliers';
  static const String supplierNew = '/parties/suppliers/new';
  static const String suppliersArchived = '/parties/suppliers/archived';
  static String supplierDetails(String id) => '$suppliers/$id';
  static String supplierEdit(String id) => '$suppliers/$id/edit';
  static String supplierPayment(String id) => '$suppliers/$id/payment';

  // Purchases, under the Purchases branch.
  static const String purchasesNew = '/purchases/new';
  static String purchase(String id) => '$purchases/$id';

  // Expenses, under the Reports branch (006 research R14).
  static const String expenses = '/reports/expenses';
  static const String expenseNew = '/reports/expenses/new';
  static const String expenseCategories = '/reports/expense-categories';
  static String expense(String id) => '$expenses/$id';

  /// The section roots, where the shell shows its own app bar. Parties
  /// has two: customers and suppliers.
  static bool isSectionRoot(String path) => const {
    home,
    sales,
    parties,
    suppliers,
    purchases,
    reports,
  }.contains(path);

  /// The first-run routes: the only ones allowed before onboarding, and
  /// never shown after it.
  static bool isFirstRun(String path) =>
      path == welcome ||
      path == '/onboarding' ||
      path.startsWith('/onboarding/');
}
