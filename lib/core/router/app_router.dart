import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/customers/presentation/cubits/customer_form_cubit.dart';
import '../../features/customers/presentation/customers_cubits.dart';
import '../../features/customers/presentation/screens/archived_customers_screen.dart';
import '../../features/customers/presentation/screens/customer_details_screen.dart';
import '../../features/customers/presentation/screens/customer_form_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/customers/presentation/screens/payment_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/shop_details_step_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/products/domain/product_query.dart';
import '../../features/products/presentation/cubits/product_form_cubit.dart';
import '../../features/products/presentation/products_cubits.dart';
import '../../features/products/presentation/screens/archived_products_screen.dart';
import '../../features/products/presentation/screens/categories_screen.dart';
import '../../features/products/presentation/screens/opening_stock_screen.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/product_form_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/stock_adjustment_screen.dart';
import '../../features/purchases/presentation/purchases_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/sales/presentation/sales_cubits.dart';
import '../../features/sales/presentation/screens/new_sale_screen.dart';
import '../../features/sales/presentation/screens/sales_list_screen.dart';
import '../../features/settings/domain/shop_profile.dart';
import '../../features/settings/presentation/cubits/app_preferences_cubit.dart';
import '../../features/settings/presentation/cubits/shop_profile_form_cubit.dart';
import '../../features/settings/presentation/data_safety_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/shop_profile_edit_screen.dart';
import '../widgets/app_shell_scaffold.dart';
import 'route_names.dart';
import 'stream_listenable.dart';

/// Builds a [ShopProfileFormCubit]; the DI factory in the app, a fake in
/// tests.
typedef ShopProfileFormCubitFactory = ShopProfileFormCubit Function(
  ShopProfileFormMode mode,
  ShopProfile? initial,
);

/// The app's routes with one redirect (contracts/routes-and-screens.md):
/// before onboarding only the first-run routes, after it never them.
GoRouter createAppRouter(
  AppPreferencesCubit prefs, {
  required ShopProfileFormCubitFactory shopProfileForm,
  required ProductsCubits products,
  required CustomersCubits customers,
  required SalesCubits sales,
}) {
  StatefulShellBranch section(String path, Widget screen) =>
      StatefulShellBranch(
        routes: [GoRoute(path: path, builder: (context, state) => screen)],
      );

  return GoRouter(
    initialLocation: RoutePaths.welcome,
    refreshListenable: StreamListenable(prefs.stream),
    redirect: (context, state) => firstRunRedirect(
      state.matchedLocation,
      prefs.state.onboardingCompleted,
    ),
    routes: [
      GoRoute(
        path: RoutePaths.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      // One form cubit for both steps, so the typed values survive moving
      // between them.
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => shopProfileForm(ShopProfileFormMode.onboarding, null),
          child: child,
        ),
        routes: [
          GoRoute(
            path: RoutePaths.onboardingShop,
            builder: (context, state) => const ShopDetailsStepScreen(),
          ),
          GoRoute(
            path: RoutePaths.onboardingData,
            builder: (context, state) =>
                const DataSafetyScreen(mode: DataSafetyMode.onboarding),
          ),
        ],
      ),
      // The five sections, in the order of FR-008, each keeping its stack.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShellScaffold(
          navigationShell: shell,
          showAppBar: RoutePaths.isSectionRoot(state.uri.path),
        ),
        branches: [
          StatefulShellBranch(routes: [_homeRoute(products)]),
          StatefulShellBranch(routes: [_salesRoute(sales)]),
          StatefulShellBranch(routes: [_partiesRoute(customers, sales)]),
          section(RoutePaths.purchases, const PurchasesScreen()),
          section(RoutePaths.reports, const ReportsScreen()),
        ],
      ),
      // Settings are pushed above the shell.
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'shop',
            builder: (context, state) => BlocProvider(
              create: (_) => shopProfileForm(
                ShopProfileFormMode.settings,
                prefs.state.shop,
              ),
              child: const ShopProfileEditScreen(),
            ),
          ),
          GoRoute(
            path: 'data',
            builder: (context, state) =>
                const DataSafetyScreen(mode: DataSafetyMode.settings),
          ),
        ],
      ),
    ],
  );
}

/// Home and the products screens below it, so the bottom bar stays and Back
/// returns to Home (002 research R10).
GoRoute _homeRoute(ProductsCubits products) => GoRoute(
  path: RoutePaths.home,
  builder: (context, state) => BlocProvider(
    create: (_) => products.lowStock(),
    child: const HomeScreen(),
  ),
  routes: [
    GoRoute(
      path: 'products',
      builder: (context, state) => BlocProvider(
        create: (_) => products.productList(
          initialQuery: ProductQuery(
            lowOnly: state.uri.queryParameters['filter'] == 'low',
          ),
        ),
        child: const ProductListScreen(),
      ),
      routes: [
        // Before ':id', so these never match as ids.
        GoRoute(
          path: 'new',
          builder: (context, state) => BlocProvider(
            create: (_) => products.productForm(
              mode: ProductFormMode.create,
              initialName: state.extra is String ? state.extra! as String : '',
            ),
            child: const ProductFormScreen(),
          ),
        ),
        GoRoute(
          path: 'archived',
          builder: (context, state) => BlocProvider(
            create: (_) => products.archivedProducts(),
            child: const ArchivedProductsScreen(),
          ),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => products.productDetails(id)),
                BlocProvider(create: (_) => products.stockHistory(id)..load()),
              ],
              child: const ProductDetailsScreen(),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) => BlocProvider(
                create: (_) => products.productForm(
                  mode: ProductFormMode.edit,
                  productId: state.pathParameters['id'],
                ),
                child: const ProductFormScreen(),
              ),
            ),
            GoRoute(
              path: 'opening',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    products.openingStock(state.pathParameters['id']!),
                child: const OpeningStockScreen(),
              ),
            ),
            GoRoute(
              path: 'adjust',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    products.stockAdjustment(state.pathParameters['id']!),
                child: const StockAdjustmentScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: 'categories',
      builder: (context, state) => BlocProvider(
        create: (_) => products.categories(),
        child: const CategoriesScreen(),
      ),
    ),
  ],
);

/// The Sales section: the invoice list, a new sale and one invoice (003
/// research R15).
GoRoute _salesRoute(SalesCubits sales) => GoRoute(
  path: RoutePaths.sales,
  builder: (context, state) => BlocProvider(
    create: (_) => sales.salesList(),
    child: const SalesListScreen(),
  ),
  routes: [
    GoRoute(
      path: 'new',
      builder: (context, state) => BlocProvider(
        create: (_) => sales.sale(),
        child: NewSaleScreen(
          productPicker: sales.productPicker,
          customerPicker: sales.customerPicker,
        ),
      ),
    ),
  ],
);

/// The Parties section: customers and the pages below them (003 research
/// R15).
GoRoute _partiesRoute(CustomersCubits customers, SalesCubits sales) => GoRoute(
  path: RoutePaths.parties,
  builder: (context, state) => BlocProvider(
    create: (_) => customers.customersList(),
    child: const CustomersScreen(),
  ),
  routes: [
    // Before 'customers/:id', so these never match as ids.
    GoRoute(
      path: 'customers/new',
      builder: (context, state) => BlocProvider(
        create: (_) => customers.customerForm(
          mode: CustomerFormMode.create,
          initialName: state.extra is String ? state.extra! as String : '',
        ),
        child: const CustomerFormScreen(),
      ),
    ),
    GoRoute(
      path: 'customers/archived',
      builder: (context, state) => BlocProvider(
        create: (_) => customers.archivedCustomers(),
        child: const ArchivedCustomersScreen(),
      ),
    ),
    GoRoute(
      path: 'customers/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => customers.customerDetails(id)),
            BlocProvider(create: (_) => customers.statement(id)..load()),
            BlocProvider(create: (_) => sales.salesList(customerId: id)),
          ],
          child: const CustomerDetailsScreen(),
        );
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => BlocProvider(
            create: (_) => customers.customerForm(
              mode: CustomerFormMode.edit,
              customerId: state.pathParameters['id'],
            ),
            child: const CustomerFormScreen(),
          ),
        ),
        GoRoute(
          path: 'payment',
          builder: (context, state) => BlocProvider(
            create: (_) => customers.payment(state.pathParameters['id']!),
            child: const PaymentScreen(),
          ),
        ),
      ],
    ),
  ],
);

/// The redirect matrix, separate so it can be tested on its own.
String? firstRunRedirect(String location, bool onboardingCompleted) {
  final inFirstRun = RoutePaths.isFirstRun(location);
  if (!onboardingCompleted) return inFirstRun ? null : RoutePaths.welcome;
  return inFirstRun ? RoutePaths.home : null;
}
