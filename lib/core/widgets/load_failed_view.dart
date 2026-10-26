import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_illustration.dart';
import 'empty_state.dart';

/// The state of a list that could not load, with a way to try again.
class LoadFailedView extends StatelessWidget {
  const LoadFailedView({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    illustration: AppIllustration.errorGeneric,
    title: title,
    message: message,
    action: OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
  );
}

/// [LoadFailedView] with the app's own text, for a list or a details page
/// whose data could not be read (research R7).
Widget dataLoadFailedView(
  BuildContext context, {
  required VoidCallback onRetry,
}) {
  final l10n = AppLocalizations.of(context);
  return LoadFailedView(
    title: l10n.loadFailedTitle,
    message: l10n.loadFailedBody,
    retryLabel: l10n.retryAction,
    onRetry: onRetry,
  );
}
