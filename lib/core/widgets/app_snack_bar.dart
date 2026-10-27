import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'status_banner.dart';

/// How long a bottom message stays (research R6).
const Duration kSnackBarDuration = Duration(seconds: 4);

/// Longer when it carries an action such as Undo.
const Duration kSnackBarActionDuration = Duration(seconds: 10);

/// Shows a bottom message that replaces the current one. The floating
/// style comes from the theme.
void showAppSnackBar(
  BuildContext context,
  String message, {
  StatusTone tone = StatusTone.success,
  String? actionLabel,
  VoidCallback? onAction,
}) => showAppSnackBarOn(
  ScaffoldMessenger.of(context),
  message,
  tone: tone,
  actionLabel: actionLabel,
  onAction: onAction,
);

/// [showAppSnackBar] on a messenger read before an `await`, for messages
/// that outlive the screen that started the work.
void showAppSnackBarOn(
  ScaffoldMessengerState messenger,
  String message, {
  StatusTone tone = StatusTone.success,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  if (!messenger.mounted) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: actionLabel == null
            ? kSnackBarDuration
            : kSnackBarActionDuration,
        // A snack bar with an action would otherwise stay until tapped and
        // cover the Save buttons of the screens after it.
        persist: false,
        // Built under the Scaffold, so it reads the app's theme; the
        // messenger itself sits above it.
        content: Builder(
          builder: (context) {
            final tokens = context.tokens;
            final tc = StatusToneColors.of(context, tone);
            // A 24 px dot in design px.
            final dot = tokens.spaceLg;
            return Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: dot,
                    height: dot,
                    decoration: BoxDecoration(
                      color: tc.container,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      tc.icon,
                      size: dot * 2 / 3,
                      color: tc.onContainer,
                    ),
                  ),
                ),
                SizedBox(width: tokens.spaceSm + tokens.spaceXs),
                Expanded(child: Text(message)),
              ],
            );
          },
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
}
