import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/load_failed_view.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../customers/presentation/widgets/reason_dialog.dart';
import '../../../payments/presentation/widgets/payment_parts_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/expense.dart';
import '../cubits/expense_cubit.dart';
import '../widgets/expense_text.dart';

/// One expense and Void (US3-3, US3-4). A voided expense has no actions.
class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final expense = state.expense;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              expense == null
                  ? l10n.expensesTitle
                  : l10n.expenseTitle(context.expenseNumber(expense.number)),
            ),
          ),
          body: state.loadFailed
              ? dataLoadFailedView(
                  context,
                  onRetry: context.read<ExpenseCubit>().retry,
                )
              : !state.loaded
              ? const Center(child: CircularProgressIndicator())
              : expense == null
              ? Center(child: Text(l10n.expenseNotFound))
              : _Body(expense: expense),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final e = expense;
    final voidedAt = e.voidedAt;
    final note = e.note;

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(bottom: tokens.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (voidedAt != null)
            Padding(
              padding: EdgeInsetsDirectional.all(tokens.spaceMd),
              child: StatusBanner(
                tone: StatusTone.voided,
                title: l10n.invoiceVoidedOn(
                  context.dateTime(voidedAt),
                  e.voidReason ?? '',
                ),
              ),
            ),
          ListTile(
            title: Text(l10n.paymentAmountLabel),
            subtitle: Text(
              context.money(e.amountPiasters),
              style: theme.textTheme.titleLarge,
            ),
          ),
          ListTile(
            title: Text(l10n.expenseCategoryLabel),
            subtitle: Text(e.category.name),
          ),
          ListTile(
            title: Text(l10n.expenseDateLabel),
            subtitle: Text(context.date(e.spentOn)),
          ),
          ListTile(
            title: Text(l10n.saleMethodLabel),
            subtitle: PaymentPartsText(parts: e.parts),
          ),
          if (note != null)
            ListTile(title: Text(l10n.customerNoteLabel), subtitle: Text(note)),
          if (voidedAt == null)
            Padding(
              padding: EdgeInsetsDirectional.all(tokens.spaceMd),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.block),
                  label: Text(l10n.expenseVoidAction),
                  onPressed: () => _void(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _void(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ExpenseCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(
      context,
      title: l10n.expenseVoidTitle,
      body: l10n.expenseVoidBody,
      action: l10n.expenseVoidAction,
    );
    if (reason == null || !context.mounted) return;
    final error = await cubit.voidExpense(reason);
    if (error == null) {
      showAppSnackBarOn(messenger, l10n.expenseVoided);
    } else if (context.mounted) {
      showAppSnackBarOn(
        messenger,
        context.expenseVoidError(error),
        tone: StatusTone.error,
      );
    }
  }
}
