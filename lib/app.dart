import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/domain/app_version.dart';

/// The app root: locale, themes and the router.
class App extends StatefulWidget {
  const App({required this.locale, required this.appVersion, super.key});

  final Locale locale;

  /// Read once at startup; shown in settings (FR-010).
  final AppVersion appVersion;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router = createAppRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(420, 812),
      builder: (context, _) {
        final scale = designScale();
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          locale: widget.locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          theme: appLightTheme(scale: scale),
          darkTheme: appDarkTheme(scale: scale),
          themeMode: ThemeMode.system,
          routerConfig: _router,
        );
      },
    );
  }
}
