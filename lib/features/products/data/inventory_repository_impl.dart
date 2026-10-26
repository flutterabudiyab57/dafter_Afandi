import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/products_dao.dart';
import '../../../core/database/daos/stock_movements_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/result.dart';
import '../domain/adjustment.dart';
import '../domain/average_cost_replay.dart';
import '../domain/inventory_repository.dart';
import '../domain/product_draft.dart';
import '../domain/product_errors.dart';
import '../domain/stock_entry.dart';
import 'mappers.dart';
import 'product_repository_impl.dart' show insertOpening;

final class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(
    this._products,
    this._movements,
    this._tx,
    this._ids,
    this._clock,
  );

  final ProductsDao _products;
  final StockMovementsDao _movements;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;

  /// R1 no history; W1 OPENING; W2 average cost.
  @override
  Future<Result<void, ProductSaveError>> setOpening(
    String productId,
    OpeningStock opening,
  ) => _tx.run(() async {
    if (await _products.byId(productId) == null) {
      return const Err(ProductNotFound());
    }
    if (await _movements.hasAny(productId)) {
      return const Err(OpeningNotAllowed());
    }
    await insertOpening(
      _movements,
      _products,
      _ids,
      productId,
      opening,
      _clock.nowUtc(),
    );
    return const Ok(null);
  });

  /// R1 stock and average cost; W1 one ADJUSTMENT at the current average
  /// cost, or nothing. The average cost is never changed (FR-007).
  @override
  Future<Result<AdjustmentResult, AdjustmentError>> adjust(
    String productId,
    AdjustmentRequest request,
  ) => _tx.run(() async {
    final product = await _products.byId(productId);
    if (product == null) throw StateError('no product $productId');
    final onHand = await _movements.stockOf(productId);

    switch (request.deltaAgainst(onHand)) {
      case Err(:final error):
        return Err(error);
      case Ok(value: final delta):
        await _movements.insertMovement(
          StockMovementsCompanion.insert(
            id: _ids.newId(),
            productId: productId,
            movementType: db.MovementType.ADJUSTMENT,
            qtyDeltaMilli: delta,
            unitCostPiasters: product.avgCostPiasters,
            adjustmentReason: Value(
              ProductMappers.adjustmentReason(request.kind),
            ),
            note: Value(request.note),
            createdAt: _clock.nowUtc(),
          ),
        );
        return Ok(
          AdjustmentResult(deltaMilli: delta, newStockMilli: onHand + delta),
        );
    }
  });

  @override
  Future<List<StockEntry>> history(
    String productId, {
    StockEntryCursor? before,
    int limit = 50,
  }) async {
    final rows = await _movements.page(
      productId,
      beforeAtMillis: before?.at.millisecondsSinceEpoch,
      beforeRowOrder: before?.rowOrder,
      limit: limit,
    );
    return rows.map(ProductMappers.entry).toList();
  }

  /// Replays the movements oldest first (004 research R8) and stores the
  /// result.
  @override
  Future<int> rebuildAverageCost(String productId) => _tx.run(() async {
    final avg = await replayedAverageCost(_movements, productId);
    await _products.setAvgCost(productId, avg, _clock.nowUtc());
    return avg;
  });
}

/// [productId]'s average cost from its movements, leaving out voided
/// purchases (004 research R8). Shared with the purchase void.
Future<int> replayedAverageCost(
  StockMovementsDao movements,
  String productId,
) async => replayAverageCost(
  (await movements.replayRows(productId)).map(ProductMappers.replay),
);
