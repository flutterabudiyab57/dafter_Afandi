import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../../../core/widgets/form_error_banner.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../../core/widgets/save_button.dart';
import '../../../../core/widgets/unsaved_changes_guard.dart';
import '../../../payments/presentation/widgets/payment_split_field.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/expense.dart';
import '../../domain/expense_errors.dart';
import '../cubits/expense_form_cubit.dart';
import '../widgets/expense_text.dart';

/// Records an expense (US3-1, US3-2): category, amount, how it was paid,
/// the day and a note.
class ExpenseFormScreen extends StatelessWidget {
  const ExpenseFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<ExpenseFormCubit, ExpenseFormState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == ExpenseFormStatus.saved,
      listener: (context, state) {
        showAppSnackBar(
          context,
          l10n.expenseSaved(context.expenseNumber(state.saved!.number)),
        );
        context.pop();
      },
      child: BlocSelector<ExpenseFormCubit, ExpenseFormState, bool>(
        // Rebuilt only when the answer to "leave?" changes.
        selector: (_) => context.read<ExpenseFormCubit>().hasUnsavedChanges,
        builder: (context, dirty) => UnsavedChangesGuard(
          dirty: dirty,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.expenseNewTitle)),
            body: const _Form(),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final ExpenseFormCubit _cubit = context.read<ExpenseFormCubit>();
  late final _amount = TextEditingController(text: _cubit.state.amount);
  late final _note = TextEditingController(text: _cubit.state.note);
  bool _defaultsAsked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // In the shop's language at this moment (research R13).
    if (!_defaultsAsked) {
      _defaultsAsked = true;
      _cubit.ensureDefaults(context.defaultExpenseCategoryNames);
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final state = _cubit.state;
    // As on the purchase date: Egyptian Arabic for Arabic-Indic digits.
    final arabicIndic =
        DigitStyleScope.of(context) == DigitStyle.arabicIndic &&
        Localizations.localeOf(context).languageCode == 'ar';
    final picked = await showDatePicker(
      context: context,
      locale: arabicIndic ? const Locale('ar', 'EG') : null,
      initialDate: state.spentOn,
      firstDate: DateTime(2000),
      lastDate: _cubit.today,
    );
    if (picked != null) _cubit.dateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<ExpenseFormCubit>().state;

    String? err(bool Function(ExpenseFieldError e) match) {
      for (final e in state.errors) {
        if (match(e)) return context.expenseFieldError(e);
      }
      return null;
    }

    final categoryError = err(
      (e) => e is ExpenseCategoryRequired || e is ExpenseCategoryArchived,
    );
    final amountError = err(
      (e) =>
          e is ExpenseAmountRequired ||
          e is ExpenseAmountInvalid ||
          e is ExpenseAmountTooLarge,
    );
    final dateError = err((e) => e is ExpenseDateInFuture);
    final noteError = err((e) => e is ExpenseNoteTooLong);
    final errorStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.error,
    );
    final saveError = state.saveError;
    final gap = SizedBox(height: tokens.spaceMd);

    return SafeArea(
      child: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (saveError != null ||
                state.status == ExpenseFormStatus.failed) ...[
              FormErrorBanner(
                title: saveError == null
                    ? l10n.errorSaveFailed
                    : context.expenseSaveError(saveError),
              ),
              gap,
            ],
            Text(l10n.expenseCategoryLabel, style: theme.textTheme.labelLarge),
            SizedBox(height: tokens.spaceXs),
            Wrap(
              spacing: tokens.spaceSm,
              runSpacing: tokens.spaceSm,
              children: [
                for (final ExpenseCategory c in state.categories)
                  ChoiceChip(
                    label: Text(c.name),
                    selected: state.categoryId == c.id,
                    onSelected: (_) => _cubit.categoryChanged(c.id),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.edit_outlined),
                  label: Text(l10n.expenseCategoriesTitle),
                  onPressed: () => context.push(RoutePaths.expenseCategories),
                ),
              ],
            ),
            if (categoryError != null) ...[
              SizedBox(height: tokens.spaceXs),
              Text(categoryError, style: errorStyle),
            ],
            gap,
            MoneyField(
              controller: _amount,
              label: l10n.paymentAmountLabel,
              onChanged: _cubit.amountChanged,
              errorText: amountError,
            ),
            gap,
            PaymentSplitField(
              totalPiasters: tryParsePiasters(state.amount) ?? 0,
              onChanged: _cubit.paymentChanged,
              errors: [
                for (final e in state.errors)
                  if (e is ExpenseSplitInvalid) e.error,
              ],
            ),
            gap,
            ListTile(
              contentPadding: EdgeInsetsDirectional.zero,
              leading: const Icon(Icons.event_outlined),
              title: Text(l10n.expenseDateLabel),
              subtitle: Text(dateError ?? context.date(state.spentOn)),
              subtitleTextStyle: dateError == null ? null : errorStyle,
              onTap: _pickDate,
            ),
            gap,
            TextField(
              controller: _note,
              onChanged: _cubit.noteChanged,
              maxLines: null,
              inputFormatters: const [
                CodePointLengthFormatter(maxExpenseNoteLength),
              ],
              decoration: InputDecoration(
                labelText: l10n.customerNoteLabel,
                errorText: noteError,
                errorMaxLines: 3,
              ),
            ),
            SizedBox(height: tokens.spaceXl),
            SaveButton(
              label: l10n.saveAction,
              savingLabel: l10n.savingLabel,
              saving: state.status == ExpenseFormStatus.saving,
              onPressed: _cubit.submit,
            ),
          ],
        ),
      ),
    );
  }
}
