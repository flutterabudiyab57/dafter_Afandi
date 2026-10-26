import '../../../core/database/daos/categories_dao.dart';
import '../../../core/database/daos/products_dao.dart';
import '../../../core/database/daos/stock_movements_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/utils/money.dart';
import '../domain/average_cost_replay.dart';
import '../domain/category.dart';
import '../domain/product.dart';
import '../domain/stock_entry.dart';

/// Row ↔ entity mapping for the products feature (constitution IV).
abstract final class ProductMappers {
  static ProductSummary summary(ProductStockRow row) => ProductSummary(
    product: product(row),
    stockMilli: row.stockMilli,
    hasHistory: row.hasHistory,
  );

  static Product product(ProductStockRow row) {
    final p = row.product;
    return Product(
      id: p.id,
      name: p.name,
      unit: p.unitType,
      salePricePiasters: p.salePricePiasters,
      avgCostPiasters: p.avgCostPiasters,
      categoryId: row.activeCategoryId,
      categoryName: row.activeCategoryName,
      barcode: p.barcode,
      sku: p.sku,
      lowStockThresholdMilli: p.lowStockThresholdMilli,
      archived: p.archivedAt != null,
    );
  }

  static Category category(CategoryCountRow row) => Category(
    id: row.category.id,
    name: row.category.name,
    sortOrder: row.category.sortOrder,
    productCount: row.productCount,
  );

  static StockEntry entry(OrderedMovement m) => StockEntry(
    id: m.row.id,
    type: entryType(m.row.movementType),
    qtyDeltaMilli: m.row.qtyDeltaMilli,
    unitCostPiasters: m.row.unitCostPiasters,
    at: m.row.createdAt,
    rowOrder: m.rowOrder,
    reason: switch (m.row.adjustmentReason) {
      null => null,
      final reason => adjustmentKind(reason),
    },
    note: m.row.note,
  );

  static StockEntryType entryType(db.MovementType type) => switch (type) {
    db.MovementType.OPENING => StockEntryType.opening,
    db.MovementType.PURCHASE => StockEntryType.purchase,
    db.MovementType.PURCHASE_VOID => StockEntryType.purchaseVoid,
    db.MovementType.SALE => StockEntryType.sale,
    db.MovementType.SALE_RETURN => StockEntryType.saleReturn,
    db.MovementType.SALE_VOID => StockEntryType.saleVoid,
    db.MovementType.ADJUSTMENT => StockEntryType.adjustment,
  };

  static AdjustmentKind adjustmentKind(db.AdjustmentReason reason) =>
      switch (reason) {
        db.AdjustmentReason.damage => AdjustmentKind.damage,
        db.AdjustmentReason.count => AdjustmentKind.count,
        db.AdjustmentReason.other => AdjustmentKind.other,
      };

  static db.AdjustmentReason adjustmentReason(AdjustmentKind kind) =>
      switch (kind) {
        AdjustmentKind.damage => db.AdjustmentReason.damage,
        AdjustmentKind.count => db.AdjustmentReason.count,
        AdjustmentKind.other => db.AdjustmentReason.other,
      };

  /// Inbound movements that carry a cost and so move the average cost
  /// (report §3.2). Adjustments and outbound movements change stock only.
  static bool isCostBearingInbound(db.MovementType type) => switch (type) {
    db.MovementType.OPENING ||
    db.MovementType.PURCHASE ||
    db.MovementType.SALE_RETURN ||
    db.MovementType.SALE_VOID => true,
    db.MovementType.PURCHASE_VOID ||
    db.MovementType.SALE ||
    db.MovementType.ADJUSTMENT => false,
  };

  /// A purchase enters with its line's cost after discounts; other
  /// cost-bearing rows with quantity × unit cost (004 research R8).
  static ReplayMovement replay(ReplayRow r) {
    final m = r.row;
    return ReplayMovement(
      qtyDeltaMilli: m.qtyDeltaMilli,
      inboundCostPiasters: isCostBearingInbound(m.movementType)
          ? r.netLineCostPiasters ??
                lineTotalPiasters(m.qtyDeltaMilli, m.unitCostPiasters)
          : null,
    );
  }
}
