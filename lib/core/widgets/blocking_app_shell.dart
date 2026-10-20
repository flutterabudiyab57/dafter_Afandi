import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';

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
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);
          final textTheme = Theme.of(context).textTheme;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title(l10n),
                        style: textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
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
          );
        },
      ),
    );
  }
}
