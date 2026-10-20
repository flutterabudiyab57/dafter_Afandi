// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_ledger_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerLedgerDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomersTable get customers => attachedDatabase.customers;
  $SalesInvoicesTable get salesInvoices => attachedDatabase.salesInvoices;
  $SaleReturnsTable get saleReturns => attachedDatabase.saleReturns;
  $CustomerLedgerTable get customerLedger => attachedDatabase.customerLedger;
  CustomerLedgerDaoManager get managers => CustomerLedgerDaoManager(this);
}

class CustomerLedgerDaoManager {
  final _$CustomerLedgerDaoMixin _db;
  CustomerLedgerDaoManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$SalesInvoicesTableTableManager get salesInvoices =>
      $$SalesInvoicesTableTableManager(_db.attachedDatabase, _db.salesInvoices);
  $$SaleReturnsTableTableManager get saleReturns =>
      $$SaleReturnsTableTableManager(_db.attachedDatabase, _db.saleReturns);
  $$CustomerLedgerTableTableManager get customerLedger =>
      $$CustomerLedgerTableTableManager(
        _db.attachedDatabase,
        _db.customerLedger,
      );
}
