import 'package:material_ui/material_ui.dart';

import 'status_banner.dart';

/// Asks a yes/no question. The confirm button is last, in error colors when
/// [destructive]. Returns null when dismissed.
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required StatusTone tone,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) => showDialog<bool>(
  context: context,
  builder: (context) {
    final scheme = Theme.of(context).colorScheme;
    final tc = StatusToneColors.of(context, tone);
    return AlertDialog(
      scrollable: true,
      icon: ExcludeSemantics(child: Icon(tc.icon, color: tc.fill)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  },
);
