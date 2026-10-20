import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_tokens.dart';
import 'core/widgets/digit_style_scope.dart';
import 'features/settings/domain/app_settings.dart';
import 'features/settings/domain/app_version.dart';
import 'features/settings/presentation/cubits/app_preferences_cubit.dart';

/// The app root: settings state, locale, digit style, themes and the router.
class App extends StatefulWidget {
  const App({
    required this.preferences,
    required this.appVersion,
    required this.shopProfileForm,
    super.key,
  });

  /// Lives as long as the app; owned by the caller.
  final AppPreferencesCubit preferences;

  /// Read once at startup; shown in settings (FR-010).
  final AppVersion appVersion;

  final ShopProfileFormCubitFactory shopProfileForm;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createAppRouter(
    widget.preferences,
    shopProfileForm: widget.shopProfileForm,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.preferences,
      child: RepositoryProvider.value(
        value: widget.appVersion,
        child: ScreenUtilInit(
          designSize: const Size(420, 812),
          builder: (context, _) => _buildApp(context),
        ),
      ),
    );
  }

  Widget _buildApp(BuildContext context) {
    final scale = designScale();
    return BlocBuilder<AppPreferencesCubit, AppSettings>(
      buildWhen: (a, b) =>
          a.locale != b.locale ||
          a.effectiveDigitStyle != b.effectiveDigitStyle,
      builder: (context, settings) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appName,
        locale: Locale(settings.locale.name),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        theme: appLightTheme(scale: scale),
        darkTheme: appDarkTheme(scale: scale),
        themeMode: ThemeMode.system,
        routerConfig: _router,
        builder: (context, child) => DigitStyleScope(
          style: settings.effectiveDigitStyle,
          child: _CappedWidth(child: child!),
        ),
      ),
    );
  }
}

/// Centers the content at `maxContentWidth` for tablets and landscape
/// (FR-019, K1).
class _CappedWidth extends StatelessWidget {
  const _CappedWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.maxContentWidth),
          child: child,
        ),
      ),
    );
  }
}
