import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/app_typography.dart';

/// What a badge says about a record.
enum BadgeTone { success, owes, credit, error, voided, neutral }

/// A stadium chip with an icon and a word: a state is never color alone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.tone,
    this.icon,
    super.key,
  });

  final String label;
  final BadgeTone tone;

  /// Defaults to the tone's icon; [BadgeTone.neutral] has none.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final (background, foreground, defaultIcon) = switch (tone) {
      BadgeTone.success => (
        colors.successContainer,
        colors.onSuccessContainer,
        Icons.check_circle,
      ),
      BadgeTone.owes => (
        colors.owesContainer,
        colors.owes,
        Icons.warning_amber_rounded,
      ),
      BadgeTone.credit => (
        colors.creditContainer,
        colors.credit,
        Icons.account_balance_wallet_outlined,
      ),
      BadgeTone.error => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.remove_circle_outline,
      ),
      BadgeTone.voided => (colors.voidedContainer, colors.voided, Icons.block),
      BadgeTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        null,
      ),
    };
    final shownIcon = icon ?? defaultIcon;
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(color: foreground, fontWeight: AppFontWeights.semiBold);
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: background,
        shape: const StadiumBorder(),
      ),
      child: Padding(
        // 4/10 in design px.
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.spaceSm * 10 / 8,
          vertical: tokens.spaceXs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (shownIcon != null) ...[
              ExcludeSemantics(
                child: Icon(shownIcon, size: tokens.spaceMd, color: foreground),
              ),
              SizedBox(width: tokens.spaceXs),
            ],
            Flexible(child: Text(label, style: style)),
          ],
        ),
      ),
    );
  }
}
