import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_movements_table.dart';

part 'stock_movements_dao.g.dart';

/// A movement with its insertion order (the history tie-break).
final class OrderedMovement {
  const OrderedMovement(this.row, this.rowOrder);

  final StockMovementRow row;
  final int rowOrder;
}

/// The append-only stock ledger: inserts and reads only. Updates and deletes
/// are refused by triggers, and nothing here issues one.
@DriftAccessor(tables: [StockMovements])
class StockMovementsDao extends DatabaseAccessor<AppDatabase>
    with _$StockMovementsDaoMixin {
  StockMovementsDao(super.attachedDatabase);

  /// Stock on hand: the sum of every movement (constitution III).
  Future<int> stockOf(String productId) async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(qty_delta_milli), 0) AS s FROM stock_movements '
      'WHERE product_id = ?1',
      variables: [Variable<String>(productId)],
      readsFrom: {stockMovements},
    ).getSingle();
    return row.read<int>('s');
  }

  Future<bool> hasAny(String productId) async {
    final row = await customSelect(
      'SELECT EXISTS(SELECT 1 FROM stock_movements WHERE product_id = ?1) '
      'AS e',
      variables: [Variable<String>(productId)],
      readsFrom: {stockMovements},
    ).getSingle();
    return row.read<int>('e') != 0;
  }

  Future<void> insertMovement(StockMovementsCompanion row) =>
      into(stockMovements).insert(row);

  /// Newest first, strictly before ([beforeAtMillis], [beforeRowOrder]) when
  /// given.
  Future<List<OrderedMovement>> page(
    String productId, {
    int? beforeAtMillis,
    int? beforeRowOrder,
    required int limit,
  }) async {
    final hasCursor = beforeAtMillis != null && beforeRowOrder != null;
    final rows = await customSelect(
      'SELECT *, rowid AS row_order FROM stock_movements WHERE product_id = ?1 '
      '${hasCursor ? 'AND (created_at < ?3 OR (created_at = ?3 AND rowid < ?4)) ' : ''}'
      'ORDER BY created_at DESC, rowid DESC LIMIT ?2',
      variables: [
        Variable<String>(productId),
        Variable<int>(limit),
        if (hasCursor) ...[
          Variable<int>(beforeAtMillis),
          Variable<int>(beforeRowOrder),
        ],
      ],
      readsFrom: {stockMovements},
    ).get();
    return rows.map(_read).toList();
  }

  /// Oldest first, for rebuilding the average cost (research R7).
  Future<List<OrderedMovement>> replayRows(String productId) async {
    final rows = await customSelect(
      'SELECT *, rowid AS row_order FROM stock_movements WHERE product_id = ?1 '
      'ORDER BY created_at ASC, rowid ASC',
      variables: [Variable<String>(productId)],
      readsFrom: {stockMovements},
    ).get();
    return rows.map(_read).toList();
  }

  OrderedMovement _read(QueryRow row) =>
      OrderedMovement(stockMovements.map(row.data), row.read<int>('row_order'));
}
