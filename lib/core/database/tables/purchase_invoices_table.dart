import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'enums.dart';
import 'suppliers_table.dart';

/// Purchase invoice header. Voidable once (Q18); every other column is frozen
/// by `trg_purchase_invoices_void_only`.
@DataClassName('PurchaseInvoiceRow')
class PurchaseInvoices extends Table {
  TextColumn get id => text()();
  IntColumn get number => integer().unique()();
  TextColumn get supplierId => text().nullable().references(
    Suppliers,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get supplierRef => text().nullable()();
  IntColumn get invoiceDate => integer().map(const UtcMillisConverter())();
  IntColumn get subtotalPiasters => integer()();
  IntColumn get discountPiasters => integer().withDefault(const Constant(0))();
  IntColumn get totalPiasters => integer()();
  IntColumn get paidPiasters => integer()();
  TextColumn get paymentMethod =>
      textEnum<PaymentMethod>().withDefault(const Constant('cash'))();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();
  IntColumn get updatedAt => integer().map(const UtcMillisConverter())();
  IntColumn get voidedAt =>
      integer().map(const UtcMillisConverter()).nullable()();
  TextColumn get voidReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (discount_piasters >= 0 AND discount_piasters <= subtotal_piasters)',
    'CHECK (total_piasters = subtotal_piasters - discount_piasters)',
    'CHECK (paid_piasters >= 0 AND paid_piasters <= total_piasters)',
    'CHECK (paid_piasters = total_piasters OR supplier_id IS NOT NULL)',
    "CHECK (payment_method IN ('cash', 'wallet', 'instapay', 'card'))",
    'CHECK ((voided_at IS NULL) = (void_reason IS NULL))',
  ];
}
