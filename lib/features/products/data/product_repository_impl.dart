import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/products_dao.dart';
import '../../../core/database/daos/stock_movements_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/arabic_normalize.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/result.dart';
import '../domain/product.dart';
import '../domain/product_draft.dart';
import '../domain/product_errors.dart';
import '../domain/product_query.dart';
import '../domain/product_repository.dart';
import 'mappers.dart';

final class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._products,
    this._movements,
    this._tx,
    this._ids,
    this._clock,
  );

  final ProductsDao _products;
  final StockMovementsDao _movements;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<ProductSummary>> watchSummaries(ProductQuery query) {
    final filter = query.categoryFilter;
    return _products
        .watchSummaries(
          normalizedQuery: query.normalizedText,
          scope: switch (filter) {
            AllCategories() => CategoryScope.all,
            NoCategory() => CategoryScope.none,
            InCategory() => CategoryScope.one,
          },
          categoryId: filter is InCategory ? filter.categoryId : null,
          lowOnly: query.lowOnly,
        )
        .map((rows) => rows.map(ProductMappers.summary).toList());
  }

  @override
  Stream<LowStockSnapshot> watchLowStock({int limit = 5}) => _products
      .watchLowStock(limit)
      .map(
        (low) => LowStockSnapshot(
          items: low.rows.map(ProductMappers.summary).toList(),
          totalCount: low.totalCount,
          hasAnyProduct: low.activeProductCount > 0,
        ),
      );

  @override
  Stream<ProductSummary?> watchSummary(String id) => _products
      .watchSummary(id)
      .map((row) => row == null ? null : ProductMappers.summary(row));

  @override
  Stream<List<ProductSummary>> watchArchived() => _products.watchArchived().map(
    (rows) => rows.map(ProductMappers.summary).toList(),
  );

  /// W1 product; with an opening, W2 OPENING movement and W3 average cost
  /// (data-model.md "Writes"), all in one transaction.
  @override
  Future<Result<ProductSaved, ProductSaveError>> create(ProductDraft draft) =>
      _guardBarcode(draft.barcode, () async {
        final barcodeOwner = await _barcodeOwner(draft.barcode);
        if (barcodeOwner != null) return Err(BarcodeTaken(barcodeOwner));

        final id = _ids.newId();
        final now = _clock.nowUtc();
        final searchKey = arabicNormalize(draft.name);
        await _products.insertProduct(
          ProductsCompanion.insert(
            id: id,
            categoryId: Value(draft.categoryId),
            name: draft.name,
            searchKey: searchKey,
            barcode: Value(draft.barcode),
            sku: Value(draft.sku),
            unitType: draft.unit,
            salePricePiasters: draft.salePricePiasters,
            lowStockThresholdMilli: Value(draft.lowStockThresholdMilli),
            createdAt: now,
            updatedAt: now,
          ),
        );
        final opening = draft.opening;
        if (opening != null) {
          await insertOpening(_movements, _products, _ids, id, opening, now);
        }
        return Ok(
          ProductSaved(
            id: id,
            nameExistsElsewhere: await _products.activeNameExists(
              searchKey,
              exceptId: id,
            ),
          ),
        );
      });

  /// R1 barcode, R2 history when the unit changes, W1 product. Never touches
  /// stock or the average cost.
  @override
  Future<Result<ProductSaved, ProductSaveError>> update(
    String id,
    ProductDraft draft,
  ) => _guardBarcode(draft.barcode, () async {
    final current = await _products.byId(id);
    if (current == null) return const Err(ProductNotFound());

    final barcodeOwner = await _barcodeOwner(draft.barcode, exceptId: id);
    if (barcodeOwner != null) return Err(BarcodeTaken(barcodeOwner));
    if (draft.unit != current.unitType && await _movements.hasAny(id)) {
      return const Err(UnitLocked());
    }

    final searchKey = arabicNormalize(draft.name);
    await _products.updateProduct(
      id,
      ProductsCompanion(
        categoryId: Value(draft.categoryId),
        name: Value(draft.name),
        searchKey: Value(searchKey),
        barcode: Value(draft.barcode),
        sku: Value(draft.sku),
        unitType: Value(draft.unit),
        salePricePiasters: Value(draft.salePricePiasters),
        lowStockThresholdMilli: Value(draft.lowStockThresholdMilli),
        updatedAt: Value(_clock.nowUtc()),
      ),
    );
    return Ok(
      ProductSaved(
        id: id,
        nameExistsElsewhere: await _products.activeNameExists(
          searchKey,
          exceptId: id,
        ),
      ),
    );
  });

  @override
  Future<void> archive(String id) => _tx.run(() {
    final now = _clock.nowUtc();
    return _products.setArchivedAt(id, now, now);
  });

  @override
  Future<Result<void, RestoreError>> restore(String id) => _tx.run(() async {
    final current = await _products.byId(id);
    if (current == null) throw StateError('no product $id');
    final barcode = current.barcode;
    if (barcode != null) {
      final owner = await _products.activeWithBarcode(barcode, exceptId: id);
      if (owner != null) return Err(RestoreBarcodeTaken(owner.name));
    }
    await _products.setArchivedAt(id, null, _clock.nowUtc());
    return const Ok(null);
  });

  Future<String?> _barcodeOwner(String? barcode, {String? exceptId}) async {
    if (barcode == null) return null;
    return (await _products.activeWithBarcode(
      barcode,
      exceptId: exceptId,
    ))?.name;
  }

  /// Runs [action] in one transaction. The unique index is the backstop for
  /// the barcode check (research R9): its failure maps to [BarcodeTaken].
  Future<Result<ProductSaved, ProductSaveError>> _guardBarcode(
    String? barcode,
    Future<Result<ProductSaved, ProductSaveError>> Function() action,
  ) async {
    try {
      return await _tx.run(action);
    } on Object catch (e) {
      if (barcode == null || !_isBarcodeConflict(e)) rethrow;
      return Err(BarcodeTaken(await _barcodeOwner(barcode) ?? ''));
    }
  }

  static bool _isBarcodeConflict(Object e) {
    final text = e.toString();
    return text.contains('UNIQUE constraint failed') &&
        text.contains('products.barcode');
  }
}

/// W1 OPENING movement and W2 average cost, inside the caller's transaction.
/// The product has no history, so its stock is 0 and the opening cost becomes
/// the average cost (research R7).
Future<void> insertOpening(
  StockMovementsDao movements,
  ProductsDao products,
  IdGenerator ids,
  String productId,
  OpeningStock opening,
  DateTime now,
) async {
  await movements.insertMovement(
    StockMovementsCompanion.insert(
      id: ids.newId(),
      productId: productId,
      movementType: db.MovementType.OPENING,
      qtyDeltaMilli: opening.qtyMilli,
      unitCostPiasters: opening.unitCostPiasters,
      createdAt: now,
    ),
  );
  await products.setAvgCost(
    productId,
    weightedAverageCost(
      stockMilli: 0,
      avgCostPiasters: 0,
      inQtyMilli: opening.qtyMilli,
      inTotalCostPiasters: opening.totalPiasters,
    ),
    now,
  );
}
