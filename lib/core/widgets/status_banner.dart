import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// The four feedback tones (handoff 3.1). Errors use the scheme's error
/// colors; the other three use [AppColors].
enum StatusTone { success, warning, error, info }

/// The colors and filled icon of a [StatusTone], shared by the banner,
/// the bottom message and the confirm dialog.
@immutable
final class StatusToneColors {
  const StatusToneColors({
    required this.fill,
    required this.onFill,
    required this.container,
    required this.onContainer,
    required this.icon,
  });

  factory StatusToneColors.of(BuildContext context, StatusTone tone) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return switch (tone) {
      StatusTone.success => StatusToneColors(
        fill: colors.success,
        onFill: colors.onSuccess,
        container: colors.successContainer,
        onContainer: colors.onSuccessContainer,
        icon: Icons.check_circle,
      ),
      StatusTone.warning => StatusToneColors(
        fill: colors.warning,
        onFill: colors.onWarning,
        container: colors.warningContainer,
        onContainer: colors.onWarningContainer,
        icon: Icons.warning,
      ),
      StatusTone.error => StatusToneColors(
        fill: scheme.error,
        onFill: scheme.onError,
        container: scheme.errorContainer,
        onContainer: scheme.onErrorContainer,
        icon: Icons.error,
      ),
      StatusTone.info => StatusToneColors(
        fill: colors.info,
        onFill: colors.onInfo,
        container: colors.infoContainer,
        onContainer: colors.onInfoContainer,
        icon: Icons.info,
      ),
    };
  }

  final Color fill;
  final Color onFill;
  final Color container;
  final Color onContainer;
  final IconData icon;
}

/// An in-page message with a filled icon, announced when it appears.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    required this.tone,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final StatusTone tone;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Above this text scale the action moves under the text.
  static const double _wrapActionScale = 1.3;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final tc = StatusToneColors.of(context, tone);
    final action = actionLabel == null
        ? null
        : TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: tc.onContainer),
            child: Text(actionLabel!),
          );
    final wrapAction =
        MediaQuery.textScalerOf(context).scale(1) > _wrapActionScale;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(color: tc.onContainer),
        ),
        if (message != null) ...[
          SizedBox(height: tokens.spaceXs),
          Text(
            message!,
            style: textTheme.bodyMedium?.copyWith(color: tc.onContainer),
          ),
        ],
        if (action != null && wrapAction)
          Align(alignment: AlignmentDirectional.centerEnd, child: action),
      ],
    );
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tc.container,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        child: Padding(
          // 14/16 in design px.
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.spaceMd,
            vertical: tokens.spaceMd * 14 / 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(child: Icon(tc.icon, color: tc.fill)),
              SizedBox(width: tokens.spaceSm + tokens.spaceXs),
              Expanded(child: text),
              if (action != null && !wrapAction) ...[
                SizedBox(width: tokens.spaceSm),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
