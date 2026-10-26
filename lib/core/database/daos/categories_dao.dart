import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/products_table.dart';

part 'categories_dao.g.dart';

/// A category with its number of active products.
final class CategoryCountRow {
  const CategoryCountRow(this.category, this.productCount);

  final CategoryRow category;
  final int productCount;
}

/// Product categories. Archived, never deleted.
@DriftAccessor(tables: [Categories, Products])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.attachedDatabase);

  /// Active categories in display order (research R16).
  Stream<List<CategoryCountRow>> watchActive() =>
      customSelect(
        'SELECT c.*, (SELECT COUNT(*) FROM products p WHERE p.category_id = c.id '
        'AND p.archived_at IS NULL) AS product_count FROM categories c '
        'WHERE c.archived_at IS NULL ORDER BY c.sort_order ASC, c.search_key ASC',
        readsFrom: {categories, products},
      ).watch().map(
        (rows) => [
          for (final row in rows)
            CategoryCountRow(
              categories.map(row.data),
              row.read<int>('product_count'),
            ),
        ],
      );

  /// Active categories in display order, without counts.
  Future<List<CategoryRow>> activeInOrder() =>
      (select(categories)
            ..where((c) => c.archivedAt.isNull())
            ..orderBy([
              (c) => OrderingTerm.asc(c.sortOrder),
              (c) => OrderingTerm.asc(c.searchKey),
            ]))
          .get();

  Future<CategoryRow?> byId(String id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Whether an active category other than [exceptId] has [searchKey].
  Future<bool> activeKeyExists(String searchKey, {String? exceptId}) async {
    final query = select(categories)
      ..where((c) => c.searchKey.equals(searchKey) & c.archivedAt.isNull());
    if (exceptId != null) query.where((c) => c.id.equals(exceptId).not());
    return (await query.get()).isNotEmpty;
  }

  /// The next sort position after every active category.
  Future<int> nextSortOrder() async {
    final row = await customSelect(
      'SELECT COALESCE(MAX(sort_order) + 1, 0) AS n FROM categories '
      'WHERE archived_at IS NULL',
      readsFrom: {categories},
    ).getSingle();
    return row.read<int>('n');
  }

  Future<void> insertCategory(CategoriesCompanion row) =>
      into(categories).insert(row);

  /// Writes [changes] to category [id]. Throws [StateError] unless exactly one
  /// row was updated.
  Future<void> updateCategory(String id, CategoriesCompanion changes) async {
    final count = await (update(
      categories,
    )..where((c) => c.id.equals(id))).write(changes);
    if (count != 1) {
      throw StateError('categories update affected $count rows, expected 1');
    }
  }
}
