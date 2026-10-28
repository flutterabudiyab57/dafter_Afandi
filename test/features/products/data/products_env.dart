import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/daos/products_dao.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/data/category_repository_impl.dart';
import 'package:daftar_afandi/features/products/data/inventory_repository_impl.dart';
import 'package:daftar_afandi/features/products/data/product_repository_impl.dart';
import 'package:daftar_afandi/features/products/domain/product.dart';
import 'package:daftar_afandi/features/products/domain/product_draft.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:daftar_afandi/features/products/domain/product_repository.dart';
import 'package:drift/native.dart';

/// A clock that moves one second forward on every read, so rows written in
/// sequence get distinct, ordered times.
final class StepClock implements Clock {
  StepClock([DateTime? start]) : _now = start ?? DateTime.utc(2026, 10, 20, 9);

  DateTime _now;

  @override
  DateTime nowUtc() => _now = _now.add(const Duration(seconds: 1));

  /// Jumps [by] forward, e.g. past the archive's 7 days.
  void advance(Duration by) => _now = _now.add(by);
}

/// An in-memory database with the three product repositories.
final class ProductsEnv {
  ProductsEnv._(this.db, ProductsDao? productsDao) {
    final products = productsDao ?? db.productsDao;
    final tx = DriftTransactionRunner(db);
    productRepo = ProductRepositoryImpl(
      products,
      db.stockMovementsDao,
      tx,
      ids,
      clock,
    );
    inventory = InventoryRepositoryImpl(
      products,
      db.stockMovementsDao,
      tx,
      ids,
      clock,
    );
    categories = CategoryRepositoryImpl(db.categoriesDao, tx, ids, clock);
  }

  /// [productsDao] replaces the real DAO, e.g. with one that fails a write.
  factory ProductsEnv({ProductsDao Function(AppDatabase db)? productsDao}) {
    final db = AppDatabase(
      NativeDatabase.memory(),
      const UuidV7Generator(),
      FixedClock(DateTime.utc(2026, 10, 20)),
    );
    return ProductsEnv._(db, productsDao?.call(db));
  }

  final AppDatabase db;
  final IdGenerator ids = const UuidV7Generator();
  final StepClock clock = StepClock();
  late final ProductRepositoryImpl productRepo;
  late final InventoryRepositoryImpl inventory;
  late final CategoryRepositoryImpl categories;

  Future<void> dispose() => db.close();

  /// Creates a valid product and returns its id.
  Future<String> addProduct(
    String name, {
    UnitType unit = UnitType.piece,
    String price = '10',
    String barcode = '',
    String sku = '',
    String lowStock = '',
    String openingQty = '',
    String openingCost = '',
    String? categoryId,
  }) async {
    final saved = await productRepo.create(
      draftOf(
        name,
        unit: unit,
        price: price,
        barcode: barcode,
        sku: sku,
        lowStock: lowStock,
        openingQty: openingQty,
        openingCost: openingCost,
        categoryId: categoryId,
      ),
    );
    return (saved as Ok<ProductSaved, ProductSaveError>).value.id;
  }

  Future<List<ProductSummary>> list([
    ProductQuery query = const ProductQuery(),
  ]) => productRepo.watchSummaries(query).first;

  Future<ProductSummary> summary(String id) async =>
      (await productRepo.watchSummary(id).first)!;
}

ProductDraft draftOf(
  String name, {
  UnitType unit = UnitType.piece,
  String price = '10',
  String barcode = '',
  String sku = '',
  String lowStock = '',
  String openingQty = '',
  String openingCost = '',
  String? categoryId,
}) {
  final result = ProductDraft.create(
    name: name,
    unit: unit,
    priceText: price,
    barcode: barcode,
    sku: sku,
    lowStockText: lowStock,
    openingQtyText: openingQty,
    openingCostText: openingCost,
    categoryId: categoryId,
  );
  return (result as Ok<ProductDraft, List<ProductFieldError>>).value;
}

T okValue<T, E>(Result<T, E> r) => (r as Ok<T, E>).value;

E errValue<T, E>(Result<T, E> r) => (r as Err<T, E>).error;
