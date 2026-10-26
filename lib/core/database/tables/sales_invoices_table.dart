import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'customers_table.dart';
import 'enums.dart';

/// Sales invoice header. Voidable once; every other column is frozen by
/// `trg_sales_invoices_void_only`.
@DataClassName('SalesInvoiceRow')
class SalesInvoices extends Table {
  TextColumn get id => text()();
  IntColumn get number => integer().unique()();
  TextColumn get customerId => text().nullable().references(
    Customers,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get subtotalPiasters => integer()();
  IntColumn get discountPiasters => integer().withDefault(const Constant(0))();
  IntColumn get totalPiasters => integer()();
  IntColumn get paidAtSalePiasters => integer()();
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
    'CHECK (paid_at_sale_piasters >= 0 AND paid_at_sale_piasters <= total_piasters)',
    'CHECK (paid_at_sale_piasters = total_piasters OR customer_id IS NOT NULL)',
    "CHECK (payment_method IN ('cash', 'wallet', 'instapay', 'card'))",
    'CHECK ((voided_at IS NULL) = (void_reason IS NULL))',
  ];
}
