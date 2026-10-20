import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'products_table.dart';
import 'purchase_invoices_table.dart';

/// Purchase invoice lines. Immutable. Records the weighted average cost
/// before and after the line, so the cost history can be replayed.
@DataClassName('PurchaseItemRow')
class PurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseInvoiceId =>
      text().references(PurchaseInvoices, #id, onDelete: KeyAction.restrict)();
  IntColumn get lineNo => integer()();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.restrict)();
  TextColumn get productNameSnapshot => text()();
  IntColumn get qtyMilli => integer()();
  IntColumn get unitCostPiasters => integer()();
  IntColumn get discountPiasters => integer().withDefault(const Constant(0))();
  IntColumn get lineTotalPiasters => integer()();
  IntColumn get invoiceDiscountSharePiasters => integer()();
  IntColumn get netLineCostPiasters => integer()();
  IntColumn get avgCostBeforePiasters => integer()();
  IntColumn get avgCostAfterPiasters => integer()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {purchaseInvoiceId, lineNo},
  ];

  @override
  List<String> get customConstraints => ['CHECK (qty_milli > 0)'];
}
