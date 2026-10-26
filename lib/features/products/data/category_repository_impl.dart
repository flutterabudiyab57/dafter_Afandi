import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/categories_dao.dart';
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/arabic_normalize.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/result.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../domain/product_errors.dart';
import 'mappers.dart';

final class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._dao, this._tx, this._ids, this._clock);

  final CategoriesDao _dao;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<Category>> watchActive() => _dao.watchActive().map(
    (rows) => rows.map(ProductMappers.category).toList(),
  );

  /// R1 duplicate; W1 insert after every active category.
  @override
  Future<Result<Category, CategoryError>> create(String rawName) {
    final invalid = validateCategoryName(rawName);
    if (invalid != null) return Future.value(Err(invalid));
    final name = rawName.trim();
    final key = arabicNormalize(name);
    return _tx.run(() async {
      if (await _dao.activeKeyExists(key)) {
        return const Err(CategoryDuplicate());
      }
      final id = _ids.newId();
      final now = _clock.nowUtc();
      final sortOrder = await _dao.nextSortOrder();
      await _dao.insertCategory(
        CategoriesCompanion.insert(
          id: id,
          name: name,
          searchKey: key,
          sortOrder: Value(sortOrder),
          createdAt: now,
          updatedAt: now,
        ),
      );
      return Ok(Category(id: id, name: name, sortOrder: sortOrder));
    });
  }

  /// R1 duplicate; W1 name, searchKey, updatedAt.
  @override
  Future<Result<void, CategoryError>> rename(String id, String rawName) {
    final invalid = validateCategoryName(rawName);
    if (invalid != null) return Future.value(Err(invalid));
    final name = rawName.trim();
    final key = arabicNormalize(name);
    return _tx.run(() async {
      if (await _dao.activeKeyExists(key, exceptId: id)) {
        return const Err(CategoryDuplicate());
      }
      await _dao.updateCategory(
        id,
        CategoriesCompanion(
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
      CategoriesCompanion(archivedAt: Value(now), updatedAt: Value(now)),
    );
  });

  /// Swaps with the neighbour, then rewrites `sort_order` as 0..n-1 for every
  /// active category (research R16). Nothing happens at either end.
  @override
  Future<void> move(String id, MoveDirection direction) => _tx.run(() async {
    final ordered = (await _dao.activeInOrder()).map((c) => c.id).toList();
    final from = ordered.indexOf(id);
    if (from < 0) throw StateError('no active category $id');
    final to = direction == MoveDirection.up ? from - 1 : from + 1;
    if (to < 0 || to >= ordered.length) return;

    ordered[from] = ordered[to];
    ordered[to] = id;
    final now = _clock.nowUtc();
    for (final (index, categoryId) in ordered.indexed) {
      await _dao.updateCategory(
        categoryId,
        CategoriesCompanion(sortOrder: Value(index), updatedAt: Value(now)),
      );
    }
  });
}
