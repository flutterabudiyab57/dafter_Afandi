import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// A form's save button. While [saving] it shows a spinner and
/// [savingLabel] and takes no taps, so a record is never saved twice
/// (SC-004).
class SaveButton extends StatelessWidget {
  const SaveButton({
    required this.label,
    required this.savingLabel,
    required this.saving,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String savingLabel;
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return FilledButton(
      onPressed: saving ? null : onPressed,
      child: saving
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 18 design px, in the button's own foreground color.
                Builder(
                  builder: (context) => SizedBox.square(
                    dimension: tokens.spaceMd + tokens.spaceXs / 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: IconTheme.of(context).color,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spaceSm),
                Flexible(child: Text(savingLabel)),
              ],
            )
          : Text(label),
    );
  }
}
