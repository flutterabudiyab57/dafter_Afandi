import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/shop_details_step_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/settings/domain/shop_profile.dart';
import '../../features/settings/presentation/cubits/app_preferences_cubit.dart';
import '../../features/settings/presentation/cubits/shop_profile_form_cubit.dart';
import '../../features/settings/presentation/data_safety_screen.dart';
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
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomeScreen(),
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
