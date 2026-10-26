import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

/// A one-screen app in Arabic and RTL with no routes or data access
/// (contracts/startup-guard.md). Used before the database is open, or when
/// it must not be opened. It follows the system's light or dark theme.
class BlockingAppShell extends StatelessWidget {
  const BlockingAppShell({required this.builder, super.key});

  /// The screen's content, under the app's theme and Arabic strings.
  final Widget Function(BuildContext context, AppLocalizations l10n) builder;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      theme: appLightTheme(),
      darkTheme: appDarkTheme(),
      themeMode: ThemeMode.system,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      home: Builder(
        builder: (context) => builder(context, AppLocalizations.of(context)),
      ),
    );
  }
}
