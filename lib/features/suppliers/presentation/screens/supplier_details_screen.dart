import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../../core/widgets/load_failed_view.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../customers/presentation/widgets/reason_dialog.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../purchases/presentation/cubits/purchases_list_cubit.dart';
import '../../../purchases/presentation/widgets/purchase_row.dart';
import '../../domain/supplier.dart';
import '../../domain/supplier_entry.dart';
import '../../domain/supplier_errors.dart';
import '../cubits/supplier_details_cubit.dart';
import '../widgets/supplier_text.dart';

/// One supplier: details, balance, actions, statement and purchases (US4).
class SupplierDetailsScreen extends StatelessWidget {
  const SupplierDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supplierDetailsTitle)),
      body: BlocBuilder<SupplierDetailsCubit, SupplierDetailsState>(
        builder: (context, state) {
          if (state.loadFailed) {
            return dataLoadFailedView(
              context,
              onRetry: context.read<SupplierDetailsCubit>().retry,
            );
          }
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = state.summary;
          if (s == null) return Center(child: Text(l10n.supplierNotFound));
          return _Details(summary: s);
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.summary});

  final SupplierSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final s = summary.supplier;
    final b = summary.balancePiasters;

    Widget section(String title) => Padding(
      padding: tokens.sectionHeaderPadding,
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    // A column, not a lazy list, so every row exists at any text size.
    // The statement reloads itself on every new account row.
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
                Text(s.name, style: theme.textTheme.headlineSmall),
                if (s.archived) Chip(label: Text(l10n.customerArchivedBadge)),
              ],
            ),
          ),
          ListTile(
            title: Text(l10n.customerBalanceLabel),
            subtitle: Text(
              context.supplierBalance(b),
              style: theme.textTheme.titleMedium?.copyWith(
                color: b > 0
                    ? context.appColors.owes
                    : b < 0
                    ? context.appColors.credit
                    : null,
              ),
            ),
          ),
          if (s.phone != null)
            ListTile(
              title: Text(l10n.customerPhoneLabel),
              subtitle: Text(ltrIsolate(s.phone!)),
            ),
          if (s.address != null)
            ListTile(
              title: Text(l10n.customerAddressLabel),
              subtitle: Text(s.address!),
            ),
          if (s.note != null)
            ListTile(
              title: Text(l10n.customerNoteLabel),
              subtitle: Text(s.note!),
            ),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceSm,
            ),
            child: _Actions(summary: summary),
          ),
          const Divider(),
          section(l10n.statementTitle),
          const _Statement(),
          const Divider(),
          section(l10n.supplierPurchasesTitle),
          const _Purchases(),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.summary});

  final SupplierSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<SupplierDetailsCubit>();
    final id = summary.supplier.id;

    if (summary.supplier.archived) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilledButton.icon(
          icon: const Icon(Icons.unarchive_outlined),
          label: Text(l10n.customerRestoreAction),
          onPressed: () async {
            await cubit.restore();
            if (context.mounted) {
              showAppSnackBar(context, l10n.supplierRestored);
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
          icon: const Icon(Icons.payments_outlined),
          label: Text(l10n.supplierPayAction),
          onPressed: () => context.push(RoutePaths.supplierPayment(id)),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.productEditAction),
          onPressed: () => context.push(RoutePaths.supplierEdit(id)),
        ),
        TextButton.icon(
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.supplierArchiveAction),
          onPressed: () async {
            if (!await _confirmArchive(context)) return;
            await cubit.archive();
            if (!context.mounted) return;
            // The cubit restores by its own id, even after this screen is
            // gone (FR-004).
            showAppSnackBar(
              context,
              l10n.supplierArchivedMessage,
              actionLabel: l10n.undoAction,
              onAction: () => unawaited(cubit.restore()),
            );
          },
        ),
      ],
    );
  }

  Future<bool> _confirmArchive(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final b = summary.balancePiasters;
    final ok = await showConfirmDialog(
      context,
      tone: StatusTone.warning,
      title: null,
      message: b == 0
          ? l10n.supplierArchiveConfirm
          : l10n.supplierArchiveConfirmBalance(context.supplierBalance(b)),
      confirmLabel: l10n.supplierArchiveAction,
      cancelLabel: l10n.cancelAction,
    );
    return ok ?? false;
  }
}

class _Statement extends StatelessWidget {
  const _Statement();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return BlocBuilder<SupplierStatementCubit, SupplierStatementState>(
      builder: (context, state) {
        final loadState = listLoadState(
          context,
          loadFailed: state.loadFailed,
          loading: state.loading,
          empty: state.entries.isEmpty,
          onRetry: context.read<SupplierStatementCubit>().load,
        );
        if (loadState != null) return loadState;
        if (state.entries.isEmpty) {
          return Padding(
            padding: EdgeInsetsDirectional.all(tokens.spaceMd),
            child: Text(l10n.statementEmpty),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final e in state.entries) _EntryRow(entry: e),
            if (state.hasMore)
              Padding(
                padding: EdgeInsetsDirectional.all(tokens.spaceSm),
                child: OutlinedButton(
                  onPressed: state.loading
                      ? null
                      : context.read<SupplierStatementCubit>().loadMore,
                  child: Text(l10n.listShowMore),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final SupplierEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final e = entry;
    final method = e.method;
    final note = e.note;
    final purchaseId = e.purchaseId;
    return ListTile(
      title: Text(context.supplierLedgerTitle(e)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.dateTime(e.at)),
          if (method != null) Text(context.methodLabel(method)),
          if (note != null && note.isNotEmpty) Text(note),
          if (e.reversed)
            Text(
              l10n.ledgerCancelled,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          Text(
            l10n.ledgerBalanceAfter(
              context.supplierBalance(e.runningBalancePiasters),
            ),
          ),
          if (e.cancellable)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                icon: const Icon(Icons.undo),
                label: Text(l10n.paymentCancelAction),
                onPressed: () => _cancel(context),
              ),
            ),
        ],
      ),
      trailing: Text(
        context.signedMoney(e.amountPiasters),
        style: theme.textTheme.titleSmall,
      ),
      onTap: purchaseId == null
          ? null
          : () => context.push(RoutePaths.purchase(purchaseId)),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final statement = context.read<SupplierStatementCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(
      context,
      title: l10n.paymentCancelTitle,
      body: l10n.paymentCancelBody,
      action: l10n.paymentCancelAction,
    );
    if (reason == null) return;
    final SupplierPaymentError? error;
    try {
      error = await statement.cancelPayment(entry.id, reason);
    } on Object {
      // The transaction rolled back, so nothing changed.
      showAppSnackBarOn(
        messenger,
        l10n.errorActionFailed,
        tone: StatusTone.error,
      );
      rethrow;
    }
    // The statement reloads after a cancel and may rebuild this row, so
    // the success message does not need its context.
    if (error == null) {
      showAppSnackBarOn(messenger, l10n.paymentCancelled);
    } else if (context.mounted) {
      showAppSnackBarOn(
        messenger,
        context.supplierPaymentError(error),
        tone: StatusTone.error,
      );
    }
  }
}

class _Purchases extends StatelessWidget {
  const _Purchases();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return BlocBuilder<PurchasesListCubit, PurchasesListState>(
      builder: (context, state) {
        final loadState = listLoadState(
          context,
          loadFailed: state.loadFailed,
          loading: state.loading,
          empty: state.items.isEmpty,
          onRetry: context.read<PurchasesListCubit>().retry,
        );
        if (loadState != null) return loadState;
        if (state.items.isEmpty) {
          return Padding(
            padding: EdgeInsetsDirectional.all(tokens.spaceMd),
            child: Text(l10n.purchasesListEmpty),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final p in state.items) PurchaseRow(purchase: p),
            if (state.hasMore)
              Padding(
                padding: EdgeInsetsDirectional.all(tokens.spaceSm),
                child: OutlinedButton(
                  onPressed: context.read<PurchasesListCubit>().showMore,
                  child: Text(l10n.listShowMore),
                ),
              ),
          ],
        );
      },
    );
  }
}
