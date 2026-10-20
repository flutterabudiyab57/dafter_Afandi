import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_tokens.dart';

/// A one-screen app in Arabic and RTL with no routes, buttons or data access
/// (contracts/startup-guard.md). Used when the database must not be opened.
class BlockingAppShell extends StatelessWidget {
  const BlockingAppShell({required this.title, required this.body, super.key});

  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;

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
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final tokens = context.tokens;
          final textTheme = Theme.of(context).textTheme;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                  child: SingleChildScrollView(
                    padding: tokens.pagePadding,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: l10n.logoSemantics,
                          image: true,
                          child: ExcludeSemantics(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: tokens.logoHeight,
                            ),
                          ),
                        ),
                        SizedBox(height: tokens.spaceLg),
                        Text(
                          title(l10n),
                          style: textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: tokens.spaceMd),
                        Text(
                          body(l10n),
                          style: textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
