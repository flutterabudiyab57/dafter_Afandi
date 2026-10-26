import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'customer_ledger_table.dart';
import 'enums.dart';
import 'expenses_table.dart';
import 'purchase_invoices_table.dart';
import 'sales_invoices_table.dart';
import 'supplier_ledger_table.dart';

/// One piece of a payment in one method (006 data-model, schema v2).
/// Immutable. Exactly one parent is set: a sale or purchase (paid at the
/// time), a customer receipt or supplier payment ledger row, or an expense.
/// The parts of a parent add up to what it paid (checked by
/// `PaymentPartsWriter`).
@DataClassName('PaymentPartRow')
class PaymentParts extends Table {
  TextColumn get id => text()();
  TextColumn get salesInvoiceId => text().nullable().references(
    SalesInvoices,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get purchaseInvoiceId => text().nullable().references(
    PurchaseInvoices,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get customerLedgerId => text().nullable().references(
    CustomerLedger,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get supplierLedgerId => text().nullable().references(
    SupplierLedger,
    #id,
    onDelete: KeyAction.restrict,
  )();
  TextColumn get expenseId => text().nullable().references(
    Expenses,
    #id,
    onDelete: KeyAction.restrict,
  )();
  IntColumn get partNo => integer()();
  TextColumn get method => textEnum<PaymentMethod>()();
  IntColumn get amountPiasters => integer()();
  TextColumn get accountRef => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK ((sales_invoice_id IS NOT NULL) + (purchase_invoice_id IS NOT NULL) '
        '+ (customer_ledger_id IS NOT NULL) + (supplier_ledger_id IS NOT NULL) '
        '+ (expense_id IS NOT NULL) = 1)',
    'CHECK (amount_piasters > 0)',
    'CHECK (part_no BETWEEN 1 AND 3)',
    "CHECK (method IN ('cash', 'wallet', 'instapay', 'card'))",
    "CHECK (account_ref IS NULL OR (method IN ('wallet', 'instapay') "
        'AND length(account_ref) BETWEEN 1 AND 40))',
  ];
}
