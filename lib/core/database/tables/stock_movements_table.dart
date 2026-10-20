import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'enums.dart';
import 'products_table.dart';
import 'purchase_items_table.dart';
import 'sale_items_table.dart';
import 'sale_return_items_table.dart';

/// Append-only stock ledger. Stock on hand is `SUM(qty_delta_milli)`.
///
/// The per-type CHECK (data-model.md) fixes, for each movement type, the sign
/// and exactly which source columns are set; every other source is NULL.
@DataClassName('StockMovementRow')
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();
  TextColumn get movementType => textEnum<MovementType>()();
  IntColumn get qtyDeltaMilli => integer()();
  IntColumn get unitCostPiasters => integer()();
  TextColumn get saleItemId => text().nullable().references(
    SaleItems,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get saleReturnItemId => text().nullable().references(
    SaleReturnItems,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get purchaseItemId => text().nullable().references(
    PurchaseItems,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get reversesMovementId => text().nullable().references(
    StockMovements,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get adjustmentReason => textEnum<AdjustmentReason>().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (movement_type IN ('OPENING', 'PURCHASE', 'PURCHASE_VOID', 'SALE', 'SALE_RETURN', 'SALE_VOID', 'ADJUSTMENT'))",
    "CHECK (adjustment_reason IS NULL OR adjustment_reason IN ('damage', 'count', 'other'))",
    'CHECK (qty_delta_milli != 0)',
    "CHECK ((adjustment_reason IS NOT NULL) = (movement_type = 'ADJUSTMENT'))",
    "CHECK (CASE movement_type WHEN 'OPENING' THEN qty_delta_milli > 0 AND sale_item_id IS NULL AND sale_return_item_id IS NULL AND purchase_item_id IS NULL AND reverses_movement_id IS NULL WHEN 'PURCHASE' THEN qty_delta_milli > 0 AND purchase_item_id IS NOT NULL AND sale_item_id IS NULL AND sale_return_item_id IS NULL AND reverses_movement_id IS NULL WHEN 'PURCHASE_VOID' THEN qty_delta_milli < 0 AND purchase_item_id IS NOT NULL AND reverses_movement_id IS NOT NULL AND sale_item_id IS NULL AND sale_return_item_id IS NULL WHEN 'SALE' THEN qty_delta_milli < 0 AND sale_item_id IS NOT NULL AND sale_return_item_id IS NULL AND purchase_item_id IS NULL AND reverses_movement_id IS NULL WHEN 'SALE_RETURN' THEN qty_delta_milli > 0 AND sale_return_item_id IS NOT NULL AND sale_item_id IS NULL AND purchase_item_id IS NULL AND reverses_movement_id IS NULL WHEN 'SALE_VOID' THEN qty_delta_milli > 0 AND sale_item_id IS NOT NULL AND reverses_movement_id IS NOT NULL AND sale_return_item_id IS NULL AND purchase_item_id IS NULL WHEN 'ADJUSTMENT' THEN sale_item_id IS NULL AND sale_return_item_id IS NULL AND purchase_item_id IS NULL AND reverses_movement_id IS NULL ELSE 0 END)",
  ];
}
