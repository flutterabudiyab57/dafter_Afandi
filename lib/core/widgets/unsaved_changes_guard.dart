import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import 'confirm_dialog.dart';
import 'status_banner.dart';

/// Asks before leaving a form with unsaved changes. Leaves at once when
/// clean.
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    required this.dirty,
    required this.child,
    super.key,
  });

  final bool dirty;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !dirty,
    onPopInvokedWithResult: (didPop, result) async {
      if (didPop) return;
      final l10n = AppLocalizations.of(context);
      final leave = await showConfirmDialog(
        context,
        tone: StatusTone.warning,
        title: l10n.discardChangesTitle,
        message: l10n.discardChangesBody,
        confirmLabel: l10n.discardAction,
        cancelLabel: l10n.keepEditingAction,
        destructive: true,
      );
      if (leave == true && context.mounted) Navigator.of(context).pop(result);
    },
    child: child,
  );
}
