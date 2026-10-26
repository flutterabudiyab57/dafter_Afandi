import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'categories_table.dart';
import 'enums.dart';

/// Products. Stock is not stored: it is the sum of `stock_movements`.
@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get name => text()();
  TextColumn get searchKey => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get unitType => textEnum<UnitType>()();
  IntColumn get salePricePiasters => integer()();
  IntColumn get avgCostPiasters => integer().withDefault(const Constant(0))();
  IntColumn get lowStockThresholdMilli => integer().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();
  IntColumn get updatedAt => integer().map(const UtcMillisConverter())();
  IntColumn get archivedAt =>
      integer().map(const UtcMillisConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (unit_type IN ('piece', 'kg', 'liter', 'meter'))",
    'CHECK (sale_price_piasters >= 0)',
    'CHECK (avg_cost_piasters >= 0)',
  ];
}
