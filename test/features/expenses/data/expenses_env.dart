import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/features/expenses/data/expense_category_repository_impl.dart';
import 'package:daftar_afandi/features/expenses/data/expense_repository_impl.dart';
import 'package:daftar_afandi/features/expenses/domain/expense.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_draft.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_errors.dart';
import 'package:daftar_afandi/features/payments/data/payment_parts_writer.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';

import '../../products/data/products_env.dart';

/// The products environment plus the expense repositories, on one in-memory
/// database. [parts] replaces the real writer, e.g. with one that fails.
final class ExpensesEnv {
  ExpensesEnv({PaymentPartsWriter Function(AppDatabase db)? parts})
    : products = ProductsEnv() {
    final db = products.db;
    final tx = DriftTransactionRunner(db);
    categories = ExpenseCategoryRepositoryImpl(
      db.expenseCategoriesDao,
      tx,
      products.ids,
      products.clock,
    );
    expenses = ExpenseRepositoryImpl(
      db.expensesDao,
      db.expenseCategoriesDao,
      db.countersDao,
      tx,
      products.ids,
      products.clock,
      parts?.call(db) ?? PaymentPartsWriter(db.paymentPartsDao, products.ids),
    );
  }

  final ProductsEnv products;
  late final ExpenseCategoryRepositoryImpl categories;
  late final ExpenseRepositoryImpl expenses;

  /// The records' local day (StepClock starts 2026-10-20 09:00 UTC).
  static final DateTime today = DateTime(2026, 10, 20);

  Future<void> dispose() => products.db.close();

  Future<String> addCategory(String name) async =>
      okValue<String, ExpenseCategoryError>(await categories.create(name));

  ExpenseDraft draft(
    String categoryId,
    String amount, {
    DateTime? spentOn,
    DateTime? formToday,
    PaymentMethod method = PaymentMethod.cash,
    String account = '',
    String note = '',
  }) => okValue<ExpenseDraft, List<ExpenseFieldError>>(
    ExpenseDraft.create(
      categoryId: categoryId,
      amountText: amount,
      spentOn: spentOn ?? today,
      today: formToday ?? today,
      parts: [PaymentPartInput(method: method, accountText: account)],
      note: note,
    ),
  );

  Future<ExpenseSaved> record(
    String categoryId,
    String amount, {
    DateTime? spentOn,
    PaymentMethod method = PaymentMethod.cash,
  }) async => okValue<ExpenseSaved, ExpenseSaveError>(
    await expenses.create(
      draft(categoryId, amount, spentOn: spentOn, method: method),
    ),
  );
}
