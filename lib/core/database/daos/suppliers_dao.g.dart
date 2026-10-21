// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suppliers_dao.dart';

// ignore_for_file: type=lint
mixin _$SuppliersDaoMixin on DatabaseAccessor<AppDatabase> {
  $SuppliersTable get suppliers => attachedDatabase.suppliers;
  $PurchaseInvoicesTable get purchaseInvoices =>
      attachedDatabase.purchaseInvoices;
  $SupplierLedgerTable get supplierLedger => attachedDatabase.supplierLedger;
  SuppliersDaoManager get managers => SuppliersDaoManager(this);
}

class SuppliersDaoManager {
  final _$SuppliersDaoMixin _db;
  SuppliersDaoManager(this._db);
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
