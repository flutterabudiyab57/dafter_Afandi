import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'enums.dart';
import 'purchase_invoices_table.dart';
import 'suppliers_table.dart';

/// Supplier ledger. Immutable; positive means we owe the supplier more.
///
/// `paymentMethod` is required exactly on payment rows (deviation D2).
@DataClassName('SupplierLedgerRow')
class SupplierLedger extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId =>
      text().references(Suppliers, #id, onDelete: KeyAction.restrict)();
  TextColumn get entryType => textEnum<SupplierEntryType>()();
  IntColumn get amountPiasters => integer()();
  TextColumn get purchaseInvoiceId => text().nullable().references(
    PurchaseInvoices,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get paymentNumber => integer().nullable()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>().nullable()();
  TextColumn get reversesEntryId => text().nullable().references(
    SupplierLedger,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (entry_type IN ('OPENING_BALANCE', 'PURCHASE', 'PAYMENT_MADE', 'PURCHASE_VOID', 'ADJUSTMENT', 'REVERSAL'))",
    "CHECK (payment_method IS NULL OR payment_method IN ('cash', 'wallet', 'instapay', 'card'))",
    'CHECK (amount_piasters != 0)',
    "CHECK ((entry_type = 'PAYMENT_MADE') = (payment_method IS NOT NULL))",
  ];
}
