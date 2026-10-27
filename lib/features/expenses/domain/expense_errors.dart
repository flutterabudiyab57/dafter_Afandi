import 'package:equatable/equatable.dart';

import '../../payments/domain/payment_split.dart';

/// A rule an expense breaks (data-model "Errors").
sealed class ExpenseFieldError extends Equatable {
  const ExpenseFieldError();

  @override
  List<Object?> get props => [];
}

final class ExpenseCategoryRequired extends ExpenseFieldError {
  const ExpenseCategoryRequired();
}

/// The category was archived while the form was open.
final class ExpenseCategoryArchived extends ExpenseFieldError {
  const ExpenseCategoryArchived();
}

final class ExpenseAmountRequired extends ExpenseFieldError {
  const ExpenseAmountRequired();
}

/// Not a number, more than two decimals, or zero.
final class ExpenseAmountInvalid extends ExpenseFieldError {
  const ExpenseAmountInvalid();
}

final class ExpenseAmountTooLarge extends ExpenseFieldError {
  const ExpenseAmountTooLarge();
}

final class ExpenseDateInFuture extends ExpenseFieldError {
  const ExpenseDateInFuture();
}

final class ExpenseNoteTooLong extends ExpenseFieldError {
  const ExpenseNoteTooLong();
}

/// How it was paid does not add up or is badly typed.
final class ExpenseSplitInvalid extends ExpenseFieldError {
  const ExpenseSplitInvalid(this.error);

  final PaymentSplitError error;

  @override
  List<Object?> get props => [error];
}

/// Why saving an expense did not happen.
sealed class ExpenseSaveError extends Equatable {
  const ExpenseSaveError();

  @override
  List<Object?> get props => [];
}

/// The draft breaks a rule (re-checked inside the transaction).
final class ExpenseInvalid extends ExpenseSaveError {
  const ExpenseInvalid(this.errors);

  final List<ExpenseFieldError> errors;

  @override
  List<Object?> get props => [errors];
}

/// The category no longer exists.
final class ExpenseCategoryUnavailable extends ExpenseSaveError {
  const ExpenseCategoryUnavailable();
}

/// Why voiding an expense did not happen.
sealed class ExpenseVoidError extends Equatable {
  const ExpenseVoidError();

  @override
  List<Object?> get props => [];
}

final class ExpenseNotFound extends ExpenseVoidError {
  const ExpenseNotFound();
}

final class ExpenseAlreadyVoided extends ExpenseVoidError {
  const ExpenseAlreadyVoided();
}

/// The reason is empty or too long.
final class ExpenseVoidReasonInvalid extends ExpenseVoidError {
  const ExpenseVoidReasonInvalid();
}

/// Why a category change did not happen.
sealed class ExpenseCategoryError extends Equatable {
  const ExpenseCategoryError();

  @override
  List<Object?> get props => [];
}

final class ExpenseCategoryNameRequired extends ExpenseCategoryError {
  const ExpenseCategoryNameRequired();
}

final class ExpenseCategoryNameTooLong extends ExpenseCategoryError {
  const ExpenseCategoryNameTooLong();
}

/// An active category already has this name (ignoring case, Arabic letter
/// forms and extra spaces).
final class ExpenseCategoryNameTaken extends ExpenseCategoryError {
  const ExpenseCategoryNameTaken(this.existing);

  /// The active category's name as it was saved.
  final String existing;

  @override
  List<Object?> get props => [existing];
}

final class ExpenseCategoryNotFound extends ExpenseCategoryError {
  const ExpenseCategoryNotFound();
}
