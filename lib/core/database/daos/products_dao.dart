import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';
import '../tables/products_table.dart';
import '../tables/stock_movements_table.dart';

part 'products_dao.g.dart';

/// A product row with its derived stock (research R3).
final class ProductStockRow {
  const ProductStockRow({
    required this.product,
    required this.stockMilli,
    required this.hasHistory,
    required this.activeCategoryId,
    required this.activeCategoryName,
  });

  final ProductRow product;

  /// `SUM(qty_delta_milli)` over the product's movements; 0 without any.
  final int stockMilli;
  final bool hasHistory;

  /// The category, or null when there is none or it is archived (R17).
  final String? activeCategoryId;
  final String? activeCategoryName;
}

/// The low-stock list for the Home card.
final class LowStockRows {
  const LowStockRows({
    required this.rows,
    required this.totalCount,
    required this.activeProductCount,
  });

  final List<ProductStockRow> rows;
  final int totalCount;
  final int activeProductCount;
}

/// The category part of the list filter.
enum CategoryScope { all, none, one }

/// Products and their stock. Never deletes (constitution III).
@DriftAccessor(tables: [Products, Categories, StockMovements])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.attachedDatabase);

  /// Every product with its stock, history flag and active category.
  static const String _base = '''
SELECT p.*,
  COALESCE((SELECT SUM(m.qty_delta_milli) FROM stock_movements m
            WHERE m.product_id = p.id), 0) AS stock_milli,
  EXISTS(SELECT 1 FROM stock_movements h WHERE h.product_id = p.id)
    AS has_history,
  c.id AS active_category_id,
  c.name AS active_category_name
FROM products p
LEFT JOIN categories c ON c.id = p.category_id AND c.archived_at IS NULL''';

  /// The one low-stock rule (FR-008, research R6), on a row of [_base].
  static const String lowStockSql =
      '(stock_milli < 0 OR (low_stock_threshold_milli IS NOT NULL '
      'AND stock_milli <= low_stock_threshold_milli))';

  /// Arabic names first, then Latin and digits, then alphabetical (R5).
  static const String _listOrder =
      '(unicode(search_key) < 1536) ASC, search_key ASC, name ASC, id ASC';

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    products,
    stockMovements,
    categories,
  };

  /// Active products for the list (research R4–R6). [normalizedQuery] is
  /// already folded with `arabicNormalize`; empty means no search.
  Stream<List<ProductStockRow>> watchSummaries({
    required String normalizedQuery,
    required CategoryScope scope,
    String? categoryId,
    required bool lowOnly,
  }) {
    final where = <String>['archived_at IS NULL'];
    final variables = <Variable<Object>>[];
    if (normalizedQuery.isNotEmpty) {
      where.add(
        '(instr(search_key, ?1) > 0 OR instr(lower(sku), ?1) > 0 '
        'OR instr(barcode, ?1) > 0)',
      );
    }
    variables.add(Variable<String>(normalizedQuery));
    switch (scope) {
      case CategoryScope.all:
        break;
      case CategoryScope.none:
        where.add('active_category_id IS NULL');
      case CategoryScope.one:
        where.add('active_category_id = ?2');
        variables.add(Variable<String>(categoryId!));
    }
    if (lowOnly) where.add(lowStockSql);

    return customSelect(
      'SELECT * FROM ($_base) WHERE ${where.join(' AND ')} '
      'ORDER BY (barcode IS NOT NULL AND barcode = ?1) DESC, $_listOrder',
      variables: variables,
      readsFrom: _reads,
    ).watch().map((rows) => rows.map(_read).toList());
  }

  /// The [limit] lowest low-stock products, the number of low products and
  /// the number of active products (FR-001a).
  Stream<LowStockRows> watchLowStock(int limit) =>
      customSelect(
        'SELECT *, COUNT(*) OVER () AS low_total FROM ($_base) '
        'WHERE archived_at IS NULL AND $lowStockSql '
        'ORDER BY stock_milli ASC, $_listOrder LIMIT ?1',
        variables: [Variable<int>(limit)],
        readsFrom: _reads,
      ).watch().asyncMap((rows) async {
        final active = await customSelect(
          'SELECT COUNT(*) AS n FROM products WHERE archived_at IS NULL',
          readsFrom: {products},
        ).getSingle();
        return LowStockRows(
          rows: rows.map(_read).toList(),
          totalCount: rows.isEmpty ? 0 : rows.first.read<int>('low_total'),
          activeProductCount: active.read<int>('n'),
        );
      });

  /// One product, archived or not.
  Stream<ProductStockRow?> watchSummary(String id) => customSelect(
    'SELECT * FROM ($_base) WHERE id = ?1',
    variables: [Variable<String>(id)],
    readsFrom: _reads,
  ).watchSingleOrNull().map((row) => row == null ? null : _read(row));

  Stream<List<ProductStockRow>> watchArchived() => customSelect(
    'SELECT * FROM ($_base) WHERE archived_at IS NOT NULL ORDER BY $_listOrder',
    readsFrom: _reads,
  ).watch().map((rows) => rows.map(_read).toList());

  Future<ProductRow?> byId(String id) =>
      (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// The active product, other than [exceptId], that has [barcode].
  Future<ProductRow?> activeWithBarcode(String barcode, {String? exceptId}) {
    final query = select(products)
      ..where((p) => p.barcode.equals(barcode) & p.archivedAt.isNull());
    if (exceptId != null) query.where((p) => p.id.equals(exceptId).not());
    return query.getSingleOrNull();
  }

  /// Whether an active product other than [exceptId] has [searchKey].
  Future<bool> activeNameExists(String searchKey, {required String exceptId}) =>
      (select(products)..where(
            (p) =>
                p.searchKey.equals(searchKey) &
                p.archivedAt.isNull() &
                p.id.equals(exceptId).not(),
          ))
          .get()
          .then((rows) => rows.isNotEmpty);

  Future<void> insertProduct(ProductsCompanion row) =>
      into(products).insert(row);

  /// Writes [changes] to product [id]. Throws [StateError] unless exactly one
  /// row was updated.
  Future<void> updateProduct(String id, ProductsCompanion changes) async {
    final count = await (update(
      products,
    )..where((p) => p.id.equals(id))).write(changes);
    if (count != 1) {
      throw StateError('products update affected $count rows, expected 1');
    }
  }

  Future<void> setAvgCost(String id, int avgCostPiasters, DateTime now) =>
      updateProduct(
        id,
        ProductsCompanion(
          avgCostPiasters: Value(avgCostPiasters),
          updatedAt: Value(now),
        ),
      );

  /// Archives ([at] set) or restores ([at] null) product [id].
  Future<void> setArchivedAt(String id, DateTime? at, DateTime now) =>
      updateProduct(
        id,
        ProductsCompanion(archivedAt: Value(at), updatedAt: Value(now)),
      );

  ProductStockRow _read(QueryRow row) => ProductStockRow(
    product: products.map(row.data),
    stockMilli: row.read<int>('stock_milli'),
    hasHistory: row.read<int>('has_history') != 0,
    activeCategoryId: row.readNullable<String>('active_category_id'),
    activeCategoryName: row.readNullable<String>('active_category_name'),
  );
}
