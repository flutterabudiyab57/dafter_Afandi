// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier_ledger_dao.dart';

// ignore_for_file: type=lint
mixin _$SupplierLedgerDaoMixin on DatabaseAccessor<AppDatabase> {
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $PurchaseInvoicesTable get purchaseInvoices =>
      attachedDatabase.purchaseInvoices;
  $SupplierLedgerTable get supplierLedger => attachedDatabase.supplierLedger;
  SupplierLedgerDaoManager get managers => SupplierLedgerDaoManager(this);
}

class SupplierLedgerDaoManager {
  final _$SupplierLedgerDaoMixin _db;
  SupplierLedgerDaoManager(this._db);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db.attachedDatabase, _db.suppliers);
  $$PurchaseInvoicesTableTableManager get purchaseInvoices =>
      $$PurchaseInvoicesTableTableManager(
        _db.attachedDatabase,
        _db.purchaseInvoices,
      );
  $$SupplierLedgerTableTableManager get supplierLedger =>
      $$SupplierLedgerTableTableManager(
        _db.attachedDatabase,
        _db.supplierLedger,
      );
}
