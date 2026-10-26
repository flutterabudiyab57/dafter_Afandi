import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'customers_table.dart';
import 'enums.dart';
import 'sale_returns_table.dart';
import 'sales_invoices_table.dart';

/// Customer ledger. Immutable; positive means the customer owes us more.
///
/// `paymentMethod` is required exactly on payment rows (deviation D2).
@DataClassName('CustomerLedgerRow')
class CustomerLedger extends Table {
  TextColumn get id => text()();
  TextColumn get customerId =>
      text().references(Customers, #id, onDelete: KeyAction.restrict)();
  TextColumn get entryType => textEnum<CustomerEntryType>()();
  IntColumn get amountPiasters => integer()();
  TextColumn get salesInvoiceId => text().nullable().references(
    SalesInvoices,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get saleReturnId => text().nullable().references(
    SaleReturns,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get receiptNumber => integer().nullable()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>().nullable()();
  TextColumn get reversesEntryId => text().nullable().references(
    CustomerLedger,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (entry_type IN ('OPENING_BALANCE', 'SALE', 'PAYMENT_RECEIVED', 'SALE_RETURN', 'REFUND_PAID', 'SALE_VOID', 'ADJUSTMENT', 'REVERSAL'))",
    "CHECK (payment_method IS NULL OR payment_method IN ('cash', 'wallet', 'instapay', 'card'))",
    'CHECK (amount_piasters != 0)',
    "CHECK ((entry_type IN ('PAYMENT_RECEIVED', 'REFUND_PAID')) = (payment_method IS NOT NULL))",
  ];
}
