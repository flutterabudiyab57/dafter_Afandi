import 'package:daftar_afandi/core/database/daos/purchases_dao.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/purchases/data/purchase_repository_impl.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/suppliers/data/supplier_repository_impl.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_draft.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_errors.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_repository.dart';

import '../../products/data/products_env.dart';
import '../../sales/data/sales_env.dart';

/// The sales environment plus the supplier and purchase repositories, on
/// one in-memory database.
final class PurchasesEnv {
  PurchasesEnv({PurchasesDao Function(PurchasesEnv env)? purchasesDao})
    : sales = SalesEnv() {
    final db = products.db;
    final tx = DriftTransactionRunner(db);
    suppliers = SupplierRepositoryImpl(
      db.suppliersDao,
      db.supplierLedgerDao,
      db.countersDao,
      tx,
      products.ids,
      products.clock,
      sales.parts,
    );
    purchases = PurchaseRepositoryImpl(
      purchasesDao?.call(this) ?? db.purchasesDao,
      db.productsDao,
      db.stockMovementsDao,
      db.suppliersDao,
      db.supplierLedgerDao,
      db.countersDao,
      tx,
      products.ids,
      products.clock,
      sales.parts,
    );
  }

  final SalesEnv sales;
  late final SupplierRepositoryImpl suppliers;
  late final PurchaseRepositoryImpl purchases;

  ProductsEnv get products => sales.products;

  Future<void> dispose() => sales.dispose();

  Future<String> addSupplier(
    String name, {
    String phone = '',
    String opening = '',
    bool inShopFavour = false,
  }) async {
    final draft = SupplierDraft.create(
      name: name,
      phone: phone,
      openingText: opening,
      openingInShopFavour: inShopFavour,
    );
    final saved = await suppliers.create(
      okValue<SupplierDraft, List<CustomerFieldError>>(draft),
    );
    return okValue<SupplierSaved, SupplierSaveError>(saved).id;
  }

  Future<SupplierSummary> supplier(String id) async =>
      (await suppliers.watchOne(id).first)!;

  Future<List<SupplierEntry>> statement(String id) =>
      suppliers.statement(id, limit: 1000);

  /// A draft buying [lines] (product id → (quantity, unit cost)).
  Future<PurchaseDraft> draftFor(
    Map<String, (int qtyMilli, int costPiasters)> lines, {
    PurchaseSupplier? supplier,
  }) async {
    var d = const PurchaseDraft();
    for (final MapEntry(key: id, value: (qty, cost)) in lines.entries) {
      final p = (await products.summary(id)).product;
      d = d
          .add(
            productId: id,
            name: p.name,
            unit: p.unit,
            salePricePiasters: p.salePricePiasters,
            unitCostPiasters: cost,
          )
          .updateLine(id, qtyMilli: qty);
    }
    return d.withSupplier(supplier);
  }

  Future<int> stock(String id) async => (await products.summary(id)).stockMilli;

  Future<int> avgCost(String id) async =>
      (await products.summary(id)).product.avgCostPiasters;
}
