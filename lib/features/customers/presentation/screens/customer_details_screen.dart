import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/digits.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../sales/presentation/cubits/sales_list_cubit.dart';
import '../../../sales/presentation/widgets/sale_row.dart';
import '../../domain/customer.dart';
import '../../domain/ledger_entry.dart';
import '../cubits/customer_details_cubit.dart';
import '../widgets/customer_text.dart';
import '../widgets/reason_dialog.dart';

/// One customer: details, balance, actions, statement and invoices (US4,
/// US5, US6).
class CustomerDetailsScreen extends StatelessWidget {
  const CustomerDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.customerDetailsTitle)),
      body: BlocBuilder<CustomerDetailsCubit, CustomerDetailsState>(
        builder: (context, state) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final s = state.summary;
          if (s == null) return Center(child: Text(l10n.customerNotFound));
          return _Details(summary: s);
        },
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.summary});

  final CustomerSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final c = summary.customer;
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
    return BlocListener<CustomerDetailsCubit, CustomerDetailsState>(
      listenWhen: (a, b) => a.summary != b.summary,
      listener: (context, _) => context.read<StatementCubit>().load(),
      child: SingleChildScrollView(
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
                  Text(c.name, style: theme.textTheme.headlineSmall),
                  if (c.archived) Chip(label: Text(l10n.customerArchivedBadge)),
                ],
              ),
            ),
            ListTile(
              title: Text(l10n.customerBalanceLabel),
              subtitle: Text(
                context.balance(b),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: b > 0 ? theme.colorScheme.error : null,
                ),
              ),
            ),
            if (c.phone != null)
              ListTile(
                title: Text(l10n.customerPhoneLabel),
                subtitle: Text(ltrIsolate(c.phone!)),
              ),
            if (c.address != null)
              ListTile(
                title: Text(l10n.customerAddressLabel),
                subtitle: Text(c.address!),
              ),
            if (c.note != null)
              ListTile(
                title: Text(l10n.customerNoteLabel),
                subtitle: Text(c.note!),
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
            section(l10n.customerInvoicesTitle),
            const _Invoices(),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.summary});

  final CustomerSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<CustomerDetailsCubit>();
    final id = summary.customer.id;

    if (summary.customer.archived) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: FilledButton.icon(
          icon: const Icon(Icons.unarchive_outlined),
          label: Text(l10n.customerRestoreAction),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await cubit.restore();
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.customerRestored)),
            );
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
          label: Text(l10n.customerReceivePayment),
          onPressed: () => context.push(RoutePaths.customerPayment(id)),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.productEditAction),
          onPressed: () => context.push(RoutePaths.customerEdit(id)),
        ),
        TextButton.icon(
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.customerArchiveAction),
          onPressed: () async {
            if (await _confirmArchive(context)) await cubit.archive();
          },
        ),
      ],
    );
  }

  Future<bool> _confirmArchive(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final b = summary.balancePiasters;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: SingleChildScrollView(
          child: Text(
            b == 0
                ? l10n.customerArchiveConfirm
                : l10n.customerArchiveConfirmBalance(context.balance(b)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.customerArchiveAction),
          ),
        ],
      ),
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
    return BlocBuilder<StatementCubit, StatementState>(
      builder: (context, state) {
        if (state.entries.isEmpty) {
          return Padding(
            padding: EdgeInsetsDirectional.all(tokens.spaceMd),
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : Text(l10n.statementEmpty),
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
                      : context.read<StatementCubit>().loadMore,
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

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final e = entry;
    final method = e.method;
    final note = e.note;
    final invoiceId = e.invoiceId;
    return ListTile(
      title: Text(context.ledgerTitle(e)),
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
            l10n.ledgerBalanceAfter(context.balance(e.runningBalancePiasters)),
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
      onTap: invoiceId == null
          ? null
          : () => context.push(RoutePaths.saleInvoice(invoiceId)),
    );
  }

  Future<void> _cancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final statement = context.read<StatementCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(
      context,
      title: l10n.paymentCancelTitle,
      body: l10n.paymentCancelBody,
      action: l10n.paymentCancelAction,
    );
    if (reason == null) return;
    final error = await statement.cancelPayment(entry.id, reason);
    if (error == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.paymentCancelled)));
    }
  }
}

class _Invoices extends StatelessWidget {
  const _Invoices();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return BlocBuilder<SalesListCubit, SalesListState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return Padding(
            padding: EdgeInsetsDirectional.all(tokens.spaceMd),
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : Text(l10n.salesListEmpty),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in state.items) SaleRow(sale: s),
            if (state.hasMore)
              Padding(
                padding: EdgeInsetsDirectional.all(tokens.spaceSm),
                child: OutlinedButton(
                  onPressed: context.read<SalesListCubit>().showMore,
                  child: Text(l10n.listShowMore),
                ),
              ),
          ],
        );
      },
    );
  }
}
