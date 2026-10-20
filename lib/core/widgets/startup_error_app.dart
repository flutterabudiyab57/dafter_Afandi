import 'package:material_ui/material_ui.dart';

import 'blocking_app_shell.dart';

/// Shown when opening or upgrading the database fails. It never retries.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlockingAppShell(
      title: (l10n) => l10n.appName,
      body: (l10n) => l10n.startupErrorBody,
    );
  }
}
