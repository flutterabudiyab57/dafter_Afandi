import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/expense_categories_dao.dart';
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/arabic_normalize.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/result.dart';
import '../domain/expense.dart';
import '../domain/expense_draft.dart';
import '../domain/expense_errors.dart';
import '../domain/expense_repository.dart';
import 'expense_repository_impl.dart' show ExpenseCategoryMappers;

final class ExpenseCategoryRepositoryImpl implements ExpenseCategoryRepository {
  ExpenseCategoryRepositoryImpl(this._dao, this._tx, this._ids, this._clock);

  final ExpenseCategoriesDao _dao;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<ExpenseCategory>> watchActive() => _watch(archived: false);

  @override
  Stream<List<ExpenseCategory>> watchArchived() => _watch(archived: true);

  Stream<List<ExpenseCategory>> _watch({required bool archived}) => _dao
      .watchAll(archived: archived)
      .map((rows) => rows.map(ExpenseCategoryMappers.category).toList());

  /// Research R13: only into an empty table, all in one transaction.
  @override
  Future<void> ensureDefaults(List<String> names) => _tx.run(() async {
    if (await _dao.countAll() > 0) return;
    for (final name in names) {
      await _insert(name.trim());
    }
  });

  @override
  Future<Result<String, ExpenseCategoryError>> create(String rawName) {
    final invalid = validateExpenseCategoryName(rawName);
    if (invalid != null) return Future.value(Err(invalid));
    final name = rawName.trim();
    return _tx.run(() async {
      final taken = await _dao.activeWithKey(arabicNormalize(name));
      if (taken != null) return Err(ExpenseCategoryNameTaken(taken.name));
      return Ok(await _insert(name));
    });
  }

  @override
  Future<Result<void, ExpenseCategoryError>> rename(String id, String rawName) {
    final invalid = validateExpenseCategoryName(rawName);
    if (invalid != null) return Future.value(Err(invalid));
    final name = rawName.trim();
    final key = arabicNormalize(name);
    return _tx.run(() async {
      if (await _dao.byId(id) == null) {
        return const Err(ExpenseCategoryNotFound());
      }
      final taken = await _dao.activeWithKey(key, exceptId: id);
      if (taken != null) return Err(ExpenseCategoryNameTaken(taken.name));
      await _dao.updateCategory(
        id,
        ExpenseCategoriesCompanion(
          name: Value(name),
          searchKey: Value(key),
          updatedAt: Value(_clock.nowUtc()),
        ),
      );
      return const Ok(null);
    });
  }

  @override
  Future<void> archive(String id) => _tx.run(() {
    final now = _clock.nowUtc();
    return _dao.updateCategory(
      id,
      ExpenseCategoriesCompanion(archivedAt: Value(now), updatedAt: Value(now)),
    );
  });

  @override
  Future<Result<void, ExpenseCategoryError>> restore(String id) =>
      _tx.run(() async {
        final row = await _dao.byId(id);
        if (row == null) return const Err(ExpenseCategoryNotFound());
        final taken = await _dao.activeWithKey(row.searchKey, exceptId: id);
        if (taken != null) return Err(ExpenseCategoryNameTaken(taken.name));
        await _dao.updateCategory(
          id,
          ExpenseCategoriesCompanion(
            archivedAt: const Value(null),
            updatedAt: Value(_clock.nowUtc()),
          ),
        );
        return const Ok(null);
      });

  Future<String> _insert(String name) async {
    final id = _ids.newId();
    final now = _clock.nowUtc();
    await _dao.insertCategory(
      ExpenseCategoriesCompanion.insert(
        id: id,
        name: name,
        searchKey: arabicNormalize(name),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }
}
