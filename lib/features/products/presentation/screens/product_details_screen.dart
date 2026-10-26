import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/load_failed_view.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../domain/product.dart';
import '../cubits/product_details_cubit.dart';
import '../widgets/product_error_text.dart';
import '../widgets/stock_history_section.dart';
import '../widgets/stock_marks.dart';
import '../widgets/unit_label.dart';

/// One product: its details, actions and stock history (US3, US4).
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<ProductDetailsCubit, ProductDetailsState>(
      listenWhen: (a, b) =>
          b.restoreError != null && a.restoreError != b.restoreError,
      listener: (context, state) {
        showAppSnackBar(
          context,
          context.restoreError(state.restoreError!),
          tone: StatusTone.error,
        );
        context.read<ProductDetailsCubit>().clearMessage();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.productDetailsTitle)),
        body: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            if (state.loadFailed) {
              return dataLoadFailedView(
                context,
                onRetry: context.read<ProductDetailsCubit>().retry,
              );
            }
            if (!state.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            final summary = state.summary;
            if (summary == null) {
              return Center(child: Text(l10n.productNotFound));
            }
            return _Details(summary: summary);
          },
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.summary});

  final ProductSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final p = summary.product;

    Widget row(String label, String value, {Widget? leading}) => ListTile(
      title: Text(label),
      subtitle: Wrap(
        spacing: tokens.spaceXs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [?leading, Text(value)],
      ),
    );

    // A column, not a lazy list: the page is short and every row should
    // exist for screen readers and tests at any text size.
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(bottom: tokens.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.spaceMd,
              end: tokens.spaceMd,
              top: tokens.spaceMd,
            ),
            child: Wrap(
              spacing: tokens.spaceSm,
              runSpacing: tokens.spaceXs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(p.name, style: theme.textTheme.headlineSmall),
                if (p.archived) Chip(label: Text(l10n.productArchivedBadge)),
              ],
            ),
          ),
          row(
            l10n.productStockOnHand,
            context.quantity(summary.stockMilli, p.unit),
            leading: summary.isLow || summary.isBelowZero
                ? StockMarks(summary: summary)
                : null,
          ),
          row(l10n.productPriceLabel, context.money(p.salePricePiasters)),
          row(l10n.productAvgCost, context.money(p.avgCostPiasters)),
          row(l10n.productUnitLabel, unitFull(l10n, p.unit)),
          row(
            l10n.productCategoryLabel,
            p.categoryName ?? l10n.productNoCategory,
          ),
          if (p.barcode != null)
            row(l10n.productBarcodeLabel, ltrIsolate(p.barcode!)),
          if (p.sku != null) row(l10n.productSkuLabel, p.sku!),
          if (p.lowStockThresholdMilli != null)
            row(
              l10n.productLowStockLabel,
              context.quantity(p.lowStockThresholdMilli!, p.unit),
            ),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceSm,
            ),
            child: _Actions(summary: summary),
          ),
          const Divider(),
          Padding(
            padding: context.tokens.sectionHeaderPadding,
            child: Text(
              l10n.historyTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          StockHistorySection(unit: p.unit),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.summary});

  final ProductSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<ProductDetailsCubit>();
    final id = summary.product.id;

    if (summary.product.archived) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilledButton.icon(
          icon: const Icon(Icons.unarchive_outlined),
          label: Text(l10n.productRestoreAction),
          onPressed: () async {
            if (await cubit.restore() == null && context.mounted) {
              showAppSnackBar(context, l10n.productRestored);
            }
          },
        ),
      );
    }

    return Wrap(
      spacing: tokens.spaceSm,
      runSpacing: tokens.spaceSm,
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.productEditAction),
          onPressed: () => context.push(RoutePaths.productEdit(id)),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.tune),
          label: Text(l10n.productAdjustAction),
          onPressed: () => context.push(RoutePaths.productAdjust(id)),
        ),
        if (!summary.hasHistory)
          OutlinedButton.icon(
            icon: const Icon(Icons.inventory_outlined),
            label: Text(l10n.productSetOpeningAction),
            onPressed: () => context.push(RoutePaths.productOpening(id)),
          ),
        TextButton.icon(
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.productArchiveAction),
          onPressed: () async {
            if (!await _confirmArchive(context)) return;
            await cubit.archive();
            if (!context.mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            // The cubit restores by its own id, even after this screen is
            // gone (FR-004). Then its listener is gone too, so the Undo
            // explains a refusal itself.
            showAppSnackBar(
              context,
              l10n.productArchivedMessage,
              actionLabel: l10n.undoAction,
              onAction: () => unawaited(() async {
                final error = await cubit.restore();
                if (error != null && !context.mounted) {
                  showAppSnackBarOn(
                    messenger,
                    restoreErrorText(l10n, error),
                    tone: StatusTone.error,
                  );
                }
              }()),
            );
          },
        ),
      ],
    );
  }

  Future<bool> _confirmArchive(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      tone: StatusTone.warning,
      title: null,
      message: l10n.productArchiveConfirm,
      confirmLabel: l10n.productArchiveAction,
      cancelLabel: l10n.cancelAction,
    );
    return ok ?? false;
  }
}
