import 'package:material_ui/material_ui.dart';

import 'app_illustration.dart';
import 'blocking_app_shell.dart';
import 'result_view.dart';

enum UpdateRequiredKind { tooNew, unrecognized }

/// Shown instead of the app when the data file is newer or not ours (FR-018).
class UpdateRequiredApp extends StatelessWidget {
  const UpdateRequiredApp({required this.kind, super.key});

  final UpdateRequiredKind kind;

  @override
  Widget build(BuildContext context) {
    return BlockingAppShell(
      builder: (context, l10n) => ResultView(
        illustration: AppIllustration.updateRequired,
        title: l10n.updateRequiredTitle,
        message: switch (kind) {
          UpdateRequiredKind.tooNew => l10n.updateRequiredBody,
          UpdateRequiredKind.unrecognized => l10n.dataUnrecognizedBody,
        },
      ),
    );
  }
}
