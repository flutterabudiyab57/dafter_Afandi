import 'package:material_ui/material_ui.dart';

import 'blocking_app_shell.dart';

enum UpdateRequiredKind { tooNew, unrecognized }

/// Shown instead of the app when the data file is newer or not ours (FR-018).
class UpdateRequiredApp extends StatelessWidget {
  const UpdateRequiredApp({required this.kind, super.key});

  final UpdateRequiredKind kind;

  @override
  Widget build(BuildContext context) {
    return BlockingAppShell(
      title: (l10n) => l10n.updateRequiredTitle,
      body: (l10n) => switch (kind) {
        UpdateRequiredKind.tooNew => l10n.updateRequiredBody,
        UpdateRequiredKind.unrecognized => l10n.dataUnrecognizedBody,
      },
    );
  }
}
