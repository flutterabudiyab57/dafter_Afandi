import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'customers_table.dart';
import 'enums.dart';
import 'sales_invoices_table.dart';

/// Sale return header. Immutable; a return cannot be voided (Q13).
@DataClassName('SaleReturnRow')
class SaleReturns extends Table {
  TextColumn get id => text()();
  IntColumn get number => integer().unique()();
  TextColumn get salesInvoiceId =>
      text().references(SalesInvoices, #id, onDelete: KeyAction.restrict)();
  TextColumn get customerId => text().nullable().references(
    Customers,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get totalRefundPiasters => integer()();
  IntColumn get totalCostPiasters => integer()();
  IntColumn get refundPaidPiasters => integer()();
  TextColumn get paymentMethod =>
      textEnum<PaymentMethod>().withDefault(const Constant('cash'))();
  TextColumn get reason => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (refund_paid_piasters >= 0 AND refund_paid_piasters <= total_refund_piasters)',
    'CHECK (refund_paid_piasters = total_refund_piasters OR customer_id IS NOT NULL)',
    "CHECK (payment_method IN ('cash', 'wallet', 'instapay', 'card'))",
  ];
}
