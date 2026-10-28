import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/doc_number.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/expense.dart';
import '../../domain/expense_errors.dart';

/// Expense messages in the active language and digit style.
extension ExpenseText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  /// "E-000012" in the digit style, kept left-to-right.
  String expenseNumber(int n) => docNumber(expenseNumberPrefix, n);

  /// The four categories a new shop starts with (research R13).
  List<String> get defaultExpenseCategoryNames => [
    _l10n.expenseCategoryRent,
    _l10n.expenseCategoryElectricity,
    _l10n.expenseCategorySalaries,
    _l10n.expenseCategoryOther,
  ];

  String expenseFieldError(ExpenseFieldError e) => switch (e) {
    ExpenseCategoryRequired() => _l10n.errorExpenseCategoryRequired,
    ExpenseCategoryArchived() => _l10n.errorExpenseCategoryArchived,
    ExpenseAmountRequired() => _l10n.errorAmountRequired,
    ExpenseAmountInvalid() => _l10n.errorExpenseAmountInvalid,
    ExpenseAmountTooLarge() => _l10n.errorPriceTooLarge(
      money(maxExpensePiasters),
    ),
    ExpenseDateInFuture() => _l10n.errorExpenseDateInFuture,
    ExpenseNoteTooLong() => _l10n.errorNoteTooLong(count(maxExpenseNoteLength)),
    ExpenseSplitInvalid() => _l10n.errorPaymentDetails,
  };

  String expenseSaveError(ExpenseSaveError e) => switch (e) {
    ExpenseInvalid() => _l10n.errorSaveFailed,
    ExpenseCategoryUnavailable() => _l10n.errorExpenseCategoryUnavailable,
  };

  String expenseVoidError(ExpenseVoidError e) => switch (e) {
    ExpenseNotFound() => _l10n.expenseNotFound,
    ExpenseAlreadyVoided() => _l10n.expenseAlreadyVoided,
    ExpenseVoidReasonInvalid() => _l10n.errorSaveFailed,
  };

  String expenseCategoryError(ExpenseCategoryError e) => switch (e) {
    ExpenseCategoryNameRequired() => _l10n.errorExpenseCategoryNameRequired,
    ExpenseCategoryNameTooLong() => _l10n.errorExpenseCategoryNameTooLong(
      count(maxExpenseCategoryNameLength),
    ),
    ExpenseCategoryNameTaken(:final existing) =>
      _l10n.errorExpenseCategoryNameTaken(existing),
    ExpenseCategoryNotFound() => _l10n.errorExpenseCategoryNotFound,
  };
}
