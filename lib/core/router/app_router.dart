import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/customers/presentation/parties_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/shop_details_step_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/purchases/presentation/purchases_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/sales/presentation/sales_screen.dart';
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
        builder: (context, state, shell) =>
            AppShellScaffold(navigationShell: shell),
        branches: [
          section(RoutePaths.home, const HomeScreen()),
          section(RoutePaths.sales, const SalesScreen()),
          section(RoutePaths.parties, const PartiesScreen()),
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

/// The redirect matrix, separate so it can be tested on its own.
String? firstRunRedirect(String location, bool onboardingCompleted) {
  final inFirstRun = RoutePaths.isFirstRun(location);
  if (!onboardingCompleted) return inFirstRun ? null : RoutePaths.welcome;
  return inFirstRun ? RoutePaths.home : null;
}
