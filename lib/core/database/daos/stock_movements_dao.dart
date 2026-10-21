import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/enums.dart';
import '../tables/purchase_items_table.dart';
import '../tables/stock_movements_table.dart';

part 'stock_movements_dao.g.dart';

/// A movement with its insertion order (the history tie-break).
final class OrderedMovement {
  const OrderedMovement(this.row, this.rowOrder);

  final StockMovementRow row;
  final int rowOrder;
}

/// A movement as the average-cost replay reads it (004 research R8).
final class ReplayRow {
  const ReplayRow(this.row, this.netLineCostPiasters);

  final StockMovementRow row;

  /// For a PURCHASE movement, its line's cost after discounts; null for
  /// every other type.
  final int? netLineCostPiasters;
}

/// The append-only stock ledger: inserts and reads only. Updates and deletes
/// are refused by triggers, and nothing here issues one.
@DriftAccessor(tables: [StockMovements, PurchaseItems])
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

  /// The SALE movement written for sale line [saleItemId].
  Future<StockMovementRow?> saleMovementOf(String saleItemId) =>
      (select(stockMovements)..where(
            (m) =>
                m.saleItemId.equals(saleItemId) &
                m.movementType.equalsValue(MovementType.SALE),
          ))
          .getSingleOrNull();

  /// The PURCHASE movement written for purchase line [purchaseItemId].
  Future<StockMovementRow?> purchaseMovementOf(String purchaseItemId) =>
      (select(stockMovements)..where(
            (m) =>
                m.purchaseItemId.equals(purchaseItemId) &
                m.movementType.equalsValue(MovementType.PURCHASE),
          ))
          .getSingleOrNull();

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

  /// Oldest first, for rebuilding the average cost (004 research R8).
  ///
  /// A voided purchase is left out as if it had never been recorded: its
  /// PURCHASE rows and the PURCHASE_VOID rows that reverse them.
  Future<List<ReplayRow>> replayRows(String productId) async {
    final rows = await customSelect(
      'SELECT m.*, p.net_line_cost_piasters AS net_line_cost '
      'FROM stock_movements m '
      "LEFT JOIN purchase_items p ON m.movement_type = 'PURCHASE' "
      'AND p.id = m.purchase_item_id '
      "WHERE m.product_id = ?1 AND m.movement_type != 'PURCHASE_VOID' "
      "AND NOT (m.movement_type = 'PURCHASE' AND EXISTS("
      'SELECT 1 FROM stock_movements v WHERE v.reverses_movement_id = m.id)) '
      'ORDER BY m.created_at ASC, m.rowid ASC',
      variables: [Variable<String>(productId)],
      readsFrom: {stockMovements, purchaseItems},
    ).get();
    return [
      for (final r in rows)
        ReplayRow(
          stockMovements.map(r.data),
          r.readNullable<int>('net_line_cost'),
        ),
    ];
  }

  OrderedMovement _read(QueryRow row) =>
      OrderedMovement(stockMovements.map(row.data), row.read<int>('row_order'));
}
