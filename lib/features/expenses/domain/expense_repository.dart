import '../../../core/utils/result.dart';
import 'expense.dart';
import 'expense_draft.dart';
import 'expense_errors.dart';

/// Shop expenses (contracts "Expenses").
abstract interface class ExpenseRepository {
  /// Expenses matching [query], newest day first, at most [limit]. Voided
  /// ones are included and marked.
  Stream<List<Expense>> watchList(ExpenseQuery query, {int limit = 50});

  /// The sum of the expenses matching [query] that are not voided.
  Stream<int> watchTotal(ExpenseQuery query);

  /// One expense; null when it does not exist.
  Stream<Expense?> watchOne(String id);

  /// Saves the expense with the next E- number, in one transaction.
  Future<Result<ExpenseSaved, ExpenseSaveError>> create(ExpenseDraft draft);

  /// Voids it once, with a reason.
  Future<Result<void, ExpenseVoidError>> voidExpense(String id, String reason);
}

/// Expense categories (contracts "Expenses").
abstract interface class ExpenseCategoryRepository {
  /// Active categories by name.
  Stream<List<ExpenseCategory>> watchActive();

  /// Archived categories by name.
  Stream<List<ExpenseCategory>> watchArchived();

  /// Inserts [names] only when there has never been a category (research
  /// R13), so archived defaults never come back.
  Future<void> ensureDefaults(List<String> names);

  /// The new category's id.
  Future<Result<String, ExpenseCategoryError>> create(String name);

  Future<Result<void, ExpenseCategoryError>> rename(String id, String name);

  /// Past expenses keep showing its name.
  Future<void> archive(String id);

  /// Refused with [ExpenseCategoryNameTaken] when an active one has its name.
  Future<Result<void, ExpenseCategoryError>> restore(String id);
}
