import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/expense_categories_table.dart';

part 'expense_categories_dao.g.dart';

/// Expense categories (006). Archived, never deleted.
@DriftAccessor(tables: [ExpenseCategories])
class ExpenseCategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpenseCategoriesDaoMixin {
  ExpenseCategoriesDao(super.attachedDatabase);

  /// Active ([archived] false) or archived categories, by name.
  Stream<List<ExpenseCategoryRow>> watchAll({required bool archived}) =>
      (select(expenseCategories)
            ..where(
              (c) =>
                  archived ? c.archivedAt.isNotNull() : c.archivedAt.isNull(),
            )
            ..orderBy([(c) => OrderingTerm.asc(c.searchKey)]))
          .watch();

  Future<ExpenseCategoryRow?> byId(String id) => (select(
    expenseCategories,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  /// The active category other than [exceptId] with [searchKey], if any.
  Future<ExpenseCategoryRow?> activeWithKey(
    String searchKey, {
    String? exceptId,
  }) {
    final query = select(expenseCategories)
      ..where((c) => c.searchKey.equals(searchKey) & c.archivedAt.isNull());
    if (exceptId != null) query.where((c) => c.id.equals(exceptId).not());
    return query.getSingleOrNull();
  }

  /// Every category ever added, archived ones included.
  Future<int> countAll() async {
    final count = expenseCategories.id.count();
    final row = await (selectOnly(
      expenseCategories,
    )..addColumns([count])).getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> insertCategory(ExpenseCategoriesCompanion row) =>
      into(expenseCategories).insert(row);

  /// Writes [changes] to category [id]. Throws [StateError] unless exactly one
  /// row was updated.
  Future<void> updateCategory(
    String id,
    ExpenseCategoriesCompanion changes,
  ) async {
    final count = await (update(
      expenseCategories,
    )..where((c) => c.id.equals(id))).write(changes);
    if (count != 1) {
      throw StateError(
        'expense_categories update affected $count rows, expected 1',
      );
    }
  }
}
