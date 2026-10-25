import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../../core/widgets/status_banner.dart';
import '../cubits/archived_products_cubit.dart';
import '../widgets/product_error_text.dart';
import '../widgets/unit_label.dart';

/// Archived products, each with Restore (FR-012, US3).
class ArchivedProductsScreen extends StatefulWidget {
  const ArchivedProductsScreen({this.debugTools = kDebugMode, super.key});

  /// Shows the demo-seed menu (decision B2). Never true in a release build.
  final bool debugTools;

  @override
  State<ArchivedProductsScreen> createState() => _ArchivedProductsScreenState();
}

class _ArchivedProductsScreenState extends State<ArchivedProductsScreen> {
  /// Why the last restore was refused, e.g. the barcode is taken.
  String? _restoreError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ArchivedProductsCubit>();
    final state = context.watch<ArchivedProductsCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsArchivedTitle),
        actions: [
          if (widget.debugTools)
            PopupMenuButton<void>(
              tooltip: l10n.demoSeedMenu,
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () async {
                    final added = await cubit.seedDemo();
                    if (!context.mounted) return;
                    showAppSnackBar(
                      context,
                      l10n.demoSeedDone(context.count(added)),
                    );
                  },
                  child: Text(l10n.demoSeedAction),
                ),
              ],
            ),
        ],
      ),
      body:
          listLoadState(
            context,
            loadFailed: state.loadFailed,
            loading: !state.loaded,
            empty: state.items.isEmpty,
            onRetry: cubit.retry,
          ) ??
          (state.items.isEmpty
              ? EmptyState(
                  illustration: AppIllustration.emptyArchive,
                  title: l10n.productsArchivedEmpty,
                )
              : ListView.builder(
                  itemCount: state.items.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) return _banner(context);
                    final s = state.items[i - 1];
                    return ListTile(
                      title: Text(s.product.name),
                      subtitle: Text(
                        context.quantity(s.stockMilli, s.product.unit),
                      ),
                      onTap: () =>
                          context.push(RoutePaths.productDetails(s.product.id)),
                      trailing: TextButton(
                        onPressed: () async {
                          final error = await cubit.restore(s.product.id);
                          if (!context.mounted) return;
                          setState(
                            () => _restoreError = error == null
                                ? null
                                : context.restoreError(error),
                          );
                          if (error == null) {
                            showAppSnackBar(context, l10n.productRestored);
                          }
                        },
                        child: Text(l10n.productRestoreAction),
                      ),
                    );
                  },
                )),
    );
  }

  Widget _banner(BuildContext context) {
    final error = _restoreError;
    if (error == null) return const SizedBox.shrink();
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        tokens.spaceMd,
        tokens.spaceSm,
        tokens.spaceMd,
        0,
      ),
      child: StatusBanner(tone: StatusTone.error, title: error),
    );
  }
}
