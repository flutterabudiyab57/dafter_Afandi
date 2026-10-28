import 'package:equatable/equatable.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/text_length.dart';
import '../../payments/domain/payment_method.dart';
import '../../payments/domain/payment_split.dart';
import 'expense.dart';
import 'expense_errors.dart';

/// A validated expense, ready to save (data-model "ExpenseDraft").
final class ExpenseDraft extends Equatable {
  const ExpenseDraft._({
    required this.categoryId,
    required this.amountPiasters,
    required this.split,
    required this.spentOn,
    this.note,
  });

  final String categoryId;
  final int amountPiasters;

  /// Adds up to [amountPiasters].
  final PaymentSplit split;

  /// Local midnight of the day it was spent; never after today.
  final DateTime spentOn;
  final String? note;

  /// Reads the form, collecting every error. [parts] defaults to one cash
  /// part that takes the whole amount; [today] is the local date.
  static Result<ExpenseDraft, List<ExpenseFieldError>> create({
    required String? categoryId,
    required String amountText,
    required DateTime spentOn,
    required DateTime today,
    List<PaymentPartInput> parts = const [
      PaymentPartInput(method: PaymentMethod.cash),
    ],
    String note = '',
  }) {
    final errors = <ExpenseFieldError>[];
    if (categoryId == null) errors.add(const ExpenseCategoryRequired());

    int? amount;
    if (amountText.trim().isEmpty) {
      errors.add(const ExpenseAmountRequired());
    } else {
      final parsed = tryParsePiasters(amountText);
      if (parsed == null || parsed == 0) {
        errors.add(const ExpenseAmountInvalid());
      } else if (parsed > maxExpensePiasters) {
        errors.add(const ExpenseAmountTooLarge());
      } else {
        amount = parsed;
      }
    }

    PaymentSplit? split;
    if (amount != null) {
      switch (PaymentSplit.create(totalPiasters: amount, inputs: parts)) {
        case Ok(:final value):
          split = value;
        case Err(:final error):
          errors.addAll(error.map(ExpenseSplitInvalid.new));
      }
    }

    final day = DateTime(spentOn.year, spentOn.month, spentOn.day);
    if (day.isAfter(today)) errors.add(const ExpenseDateInFuture());

    final trimmedNote = note.trim();
    if (codePointLength(trimmedNote) > maxExpenseNoteLength) {
      errors.add(const ExpenseNoteTooLong());
    }

    if (errors.isNotEmpty) return Err(errors);
    return Ok(
      ExpenseDraft._(
        categoryId: categoryId!,
        amountPiasters: amount!,
        split: split!,
        spentOn: day,
        note: trimmedNote.isEmpty ? null : trimmedNote,
      ),
    );
  }

  @override
  List<Object?> get props => [categoryId, amountPiasters, split, spentOn, note];
}

/// The name's error, or null when it is valid: trimmed, 1–50 code points.
/// Duplicates are checked by the repository.
ExpenseCategoryError? validateExpenseCategoryName(String raw) {
  final length = codePointLength(raw.trim());
  if (length == 0) return const ExpenseCategoryNameRequired();
  if (length > maxExpenseCategoryNameLength) {
    return const ExpenseCategoryNameTooLong();
  }
  return null;
}
