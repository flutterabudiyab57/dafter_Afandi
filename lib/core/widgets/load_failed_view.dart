import 'package:material_ui/material_ui.dart';

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
