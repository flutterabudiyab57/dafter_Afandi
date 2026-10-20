import 'package:daftar_afandi/core/database/daos/sales_dao.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/data/customer_repository_impl.dart';
import 'package:daftar_afandi/features/customers/domain/customer.dart';
import 'package:daftar_afandi/features/customers/domain/customer_draft.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/customer_repository.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/sales/data/sales_repository_impl.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';

import '../../products/data/products_env.dart';

/// The products environment plus the customer and sales repositories, on
/// one in-memory database.
final class SalesEnv {
  SalesEnv({SalesDao Function(SalesEnv env)? salesDao})
    : products = ProductsEnv() {
    final db = products.db;
    final tx = DriftTransactionRunner(db);
    customers = CustomerRepositoryImpl(
      db.customersDao,
      db.customerLedgerDao,
      db.countersDao,
      tx,
      products.ids,
      products.clock,
    );
    sales = SalesRepositoryImpl(
      salesDao?.call(this) ?? db.salesDao,
      db.productsDao,
      db.stockMovementsDao,
      db.customersDao,
      db.customerLedgerDao,
      db.countersDao,
      tx,
      products.ids,
      products.clock,
    );
  }

  final ProductsEnv products;
  late final CustomerRepositoryImpl customers;
  late final SalesRepositoryImpl sales;

  Future<void> dispose() => products.dispose();

  Future<String> addCustomer(
    String name, {
    String phone = '',
    String opening = '',
    bool inFavour = false,
  }) async {
    final draft = CustomerDraft.create(
      name: name,
      phone: phone,
      openingText: opening,
      openingInFavour: inFavour,
    );
    final saved = await customers.create(
      okValue<CustomerDraft, List<CustomerFieldError>>(draft),
    );
    return okValue<CustomerSaved, CustomerSaveError>(saved).id;
  }

  Future<CustomerSummary> customer(String id) async =>
      (await customers.watchOne(id).first)!;

  Future<List<LedgerEntry>> statement(String id) =>
      customers.statement(id, limit: 1000);

  /// A draft with [qty] units of each product at its stored price.
  Future<SaleDraft> draftFor(
    Map<String, int> qtyMilliByProduct, {
    SaleCustomer? customer,
  }) async {
    var d = const SaleDraft();
    for (final MapEntry(key: id, value: qty) in qtyMilliByProduct.entries) {
      final p = (await products.summary(id)).product;
      d = d
          .add(
            productId: id,
            name: p.name,
            unit: p.unit,
            unitPricePiasters: p.salePricePiasters,
          )
          .updateLine(id, qtyMilli: qty);
    }
    return d.withCustomer(customer);
  }
}

const int one = milliPerUnit;
