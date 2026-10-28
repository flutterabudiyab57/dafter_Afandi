import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/expense_categories_table.dart';
import '../tables/expenses_table.dart';

part 'expenses_dao.g.dart';

/// An expense with its category.
final class ExpenseWithCategoryRow {
  const ExpenseWithCategoryRow(this.expense, this.category);

  final ExpenseRow expense;
  final ExpenseCategoryRow category;
}

/// Expenses (006): inserts, reads and the void fields only; a trigger
/// refuses every other change.
@DriftAccessor(tables: [Expenses, ExpenseCategories])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.attachedDatabase);

  /// Expenses spent in `[startUtc, endUtc)`, of [categoryId] when set,
  /// newest day first, then newest number.
  Stream<List<ExpenseWithCategoryRow>> watchList({
    required DateTime startUtc,
    required DateTime endUtc,
    String? categoryId,
    int limit = 50,
  }) {
    final query =
        select(expenses).join([
            innerJoin(
              expenseCategories,
              expenseCategories.id.equalsExp(expenses.expenseCategoryId),
            ),
          ])
          ..where(_inPeriod(startUtc, endUtc, categoryId))
          ..orderBy([
            OrderingTerm.desc(expenses.spentAt),
            OrderingTerm.desc(expenses.number),
          ])
          ..limit(limit);
    return query.watch().map((rows) => rows.map(_read).toList());
  }

  /// The sum of the expenses in the period that are not voided.
  Stream<int> watchTotal({
    required DateTime startUtc,
    required DateTime endUtc,
    String? categoryId,
  }) {
    final sum = expenses.amountPiasters.sum();
    final query = selectOnly(expenses)
      ..addColumns([sum])
      ..where(
        _inPeriod(startUtc, endUtc, categoryId) & expenses.voidedAt.isNull(),
      );
    return query.watchSingle().map((row) => row.read(sum) ?? 0);
  }

  Stream<ExpenseWithCategoryRow?> watchOne(String id) =>
      (select(expenses).join([
        innerJoin(
          expenseCategories,
          expenseCategories.id.equalsExp(expenses.expenseCategoryId),
        ),
      ])..where(expenses.id.equals(id))).watchSingleOrNull().map(
        (row) => row == null ? null : _read(row),
      );

  Future<ExpenseRow?> byId(String id) =>
      (select(expenses)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<void> insertExpense(ExpensesCompanion row) =>
      into(expenses).insert(row);

  /// Writes the void fields. Throws [StateError] unless exactly one row was
  /// updated.
  Future<void> setVoided(String id, String reason, DateTime now) async {
    final count = await (update(expenses)..where((e) => e.id.equals(id))).write(
      ExpensesCompanion(
        voidedAt: Value(now),
        voidReason: Value(reason),
        updatedAt: Value(now),
      ),
    );
    if (count != 1) {
      throw StateError('expenses void affected $count rows, expected 1');
    }
  }

  Expression<bool> _inPeriod(
    DateTime startUtc,
    DateTime endUtc,
    String? categoryId,
  ) {
    var where =
        expenses.spentAt.isBiggerOrEqualValue(startUtc.millisecondsSinceEpoch) &
        expenses.spentAt.isSmallerThanValue(endUtc.millisecondsSinceEpoch);
    if (categoryId != null) {
      where = where & expenses.expenseCategoryId.equals(categoryId);
    }
    return where;
  }

  ExpenseWithCategoryRow _read(TypedResult row) => ExpenseWithCategoryRow(
    row.readTable(expenses),
    row.readTable(expenseCategories),
  );
}
