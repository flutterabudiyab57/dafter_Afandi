import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../domain/customer_errors.dart';
import '../../domain/payment.dart';
import 'customer_text.dart';

/// Asks for a void or cancel reason (FR-008a, FR-016a). Returns the
/// validated reason, or null when the owner backs out.
Future<String?> askReason(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) => showDialog<String>(
  context: context,
  builder: (_) => _ReasonDialog(title: title, body: body, action: action),
);

class _ReasonDialog extends StatefulWidget {
  const _ReasonDialog({
    required this.title,
    required this.body,
    required this.action,
  });

  final String title;
  final String body;
  final String action;

  @override
  State<_ReasonDialog> createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _reason = TextEditingController();
  CustomerFieldError? _error;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    switch (validateReason(_reason.text)) {
      case Ok(:final value):
        Navigator.of(context).pop(value);
      case Err(:final error):
        setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // The same look as showConfirmDialog: the error tone, as a void or a
    // cancel cannot be undone, with the destructive choice last.
    final tone = StatusToneColors.of(context, StatusTone.error);
    return AlertDialog(
      icon: ExcludeSemantics(child: Icon(tone.icon, color: tone.fill)),
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.body),
            SizedBox(height: context.tokens.spaceSm),
            TextField(
              controller: _reason,
              autofocus: true,
              maxLines: null,
              inputFormatters: const [
                CodePointLengthFormatter(maxReasonLength),
              ],
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: l10n.reasonLabel,
                errorText: _error == null
                    ? null
                    : context.customerFieldError(_error!),
                errorMaxLines: 3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.backAction),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          child: Text(widget.action),
        ),
      ],
    );
  }
}
