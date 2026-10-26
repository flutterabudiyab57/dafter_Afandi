// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_parts_dao.dart';

// ignore_for_file: type=lint
mixin _$PaymentPartsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $SalesInvoicesTable get salesInvoices => attachedDatabase.salesInvoices;
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $PurchaseInvoicesTable get purchaseInvoices =>
      attachedDatabase.purchaseInvoices;
  $SaleReturnsTable get saleReturns => attachedDatabase.saleReturns;
  $CustomerLedgerTable get customerLedger => attachedDatabase.customerLedger;
  $SupplierLedgerTable get supplierLedger => attachedDatabase.supplierLedger;
  $ExpenseCategoriesTable get expenseCategories =>
      attachedDatabase.expenseCategories;
  $ExpensesTable get expenses => attachedDatabase.expenses;
  $PaymentPartsTable get paymentParts => attachedDatabase.paymentParts;
  PaymentPartsDaoManager get managers => PaymentPartsDaoManager(this);
}

class PaymentPartsDaoManager {
  final _$PaymentPartsDaoMixin _db;
  PaymentPartsDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$SalesInvoicesTableTableManager get salesInvoices =>
      $$SalesInvoicesTableTableManager(_db.attachedDatabase, _db.salesInvoices);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db.attachedDatabase, _db.suppliers);
  $$PurchaseInvoicesTableTableManager get purchaseInvoices =>
      $$PurchaseInvoicesTableTableManager(
        _db.attachedDatabase,
        _db.purchaseInvoices,
      );
  $$SaleReturnsTableTableManager get saleReturns =>
      $$SaleReturnsTableTableManager(_db.attachedDatabase, _db.saleReturns);
  $$CustomerLedgerTableTableManager get customerLedger =>
      $$CustomerLedgerTableTableManager(
        _db.attachedDatabase,
        _db.customerLedger,
      );
  $$SupplierLedgerTableTableManager get supplierLedger =>
      $$SupplierLedgerTableTableManager(
        _db.attachedDatabase,
        _db.supplierLedger,
      );
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.expenseCategories,
      );
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db.attachedDatabase, _db.expenses);
  $$PaymentPartsTableTableManager get paymentParts =>
      $$PaymentPartsTableTableManager(_db.attachedDatabase, _db.paymentParts);
}
