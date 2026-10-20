import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'products_table.dart';
import 'sale_items_table.dart';
import 'sale_returns_table.dart';

/// Sale return lines. Immutable. `trg_sale_return_items_qty_ceiling` stops a
/// sale line from being returned beyond its sold quantity.
@DataClassName('SaleReturnItemRow')
class SaleReturnItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleReturnId =>
      text().references(SaleReturns, #id, onDelete: KeyAction.restrict)();
  TextColumn get saleItemId =>
      text().references(SaleItems, #id, onDelete: KeyAction.restrict)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();
  IntColumn get qtyMilli => integer()();
  IntColumn get unitPricePiasters => integer()();
  IntColumn get unitCostPiasters => integer()();
  IntColumn get refundPiasters => integer()();
  IntColumn get costPiasters => integer()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (qty_milli > 0)'];
}
