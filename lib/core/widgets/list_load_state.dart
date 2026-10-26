import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/app_tokens.dart';
import 'app_illustration.dart';
import 'empty_state.dart';
import 'load_failed_view.dart';
import 'skeleton_list.dart';

/// The one rule every list follows before it shows rows or its empty state
/// (research R7): a failed load shows [LoadFailedView] with Retry, and a
/// first load shows [SkeletonList]. Null means the list has its answer.
Widget? listLoadState(
  BuildContext context, {
  required bool loadFailed,
  required bool loading,
  required bool empty,
  required VoidCallback onRetry,
}) {
  if (loadFailed) return dataLoadFailedView(context, onRetry: onRetry);
  if (loading && empty) return const SkeletonList();
  return null;
}

/// A search or filter that matched nothing, with a way to clear it
/// (FR-009).
Widget searchEmptyState(
  BuildContext context, {
  required String message,
  required VoidCallback onClear,
  Widget? extraAction,
}) {
  final l10n = AppLocalizations.of(context);
  final clear = OutlinedButton(
    onPressed: onClear,
    child: Text(l10n.searchClearAction),
  );
  return EmptyState(
    illustration: AppIllustration.emptySearch,
    title: l10n.searchEmptyTitle,
    message: message,
    action: extraAction == null
        ? clear
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: context.tokens.spaceSm,
            children: [extraAction, clear],
          ),
  );
}
