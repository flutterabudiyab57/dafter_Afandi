import 'package:material_ui/material_ui.dart';

import 'app_illustration.dart';
import 'blocking_app_shell.dart';
import 'result_view.dart';

/// Shown when opening or upgrading the database fails. It never retries.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlockingAppShell(
      builder: (context, l10n) => ResultView(
        illustration: AppIllustration.errorDatabase,
        title: l10n.appName,
        message: l10n.startupErrorBody,
      ),
    );
  }
}
