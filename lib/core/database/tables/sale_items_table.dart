import 'package:drift/drift.dart';

import 'enums.dart';
import 'products_table.dart';
import 'sales_invoices_table.dart';

/// Sales invoice lines. Immutable. Name, unit type and unit cost are
/// snapshots taken at sale time.
@DataClassName('SaleItemRow')
class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get salesInvoiceId =>
      text().references(SalesInvoices, #id, onDelete: KeyAction.restrict)();
  IntColumn get lineNo => integer()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();
  TextColumn get productNameSnapshot => text()();
  TextColumn get unitTypeSnapshot => textEnum<UnitType>()();
  IntColumn get qtyMilli => integer()();
  IntColumn get unitPricePiasters => integer()();
  IntColumn get discountPiasters => integer()();
  IntColumn get lineTotalPiasters => integer()();
  IntColumn get invoiceDiscountSharePiasters => integer()();
  IntColumn get unitCostPiasters => integer()();
  IntColumn get lineCostPiasters => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {salesInvoiceId, lineNo},
  ];

  // Gross is qty x price / 1000 rounded half up. Both factors are >= 0 here,
  // so the integer form (x + 500) / 1000 is exact.
  @override
  List<String> get customConstraints => [
    "CHECK (unit_type_snapshot IN ('piece', 'kg', 'liter', 'meter'))",
    'CHECK (qty_milli > 0)',
    'CHECK (unit_price_piasters >= 0)',
    'CHECK (discount_piasters >= 0 AND discount_piasters <= (qty_milli * unit_price_piasters + 500) / 1000)',
  ];
}
