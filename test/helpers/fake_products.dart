import 'dart:async';

import 'package:daftar_afandi/core/utils/arabic_normalize.dart';
import 'package:daftar_afandi/core/utils/money.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/adjustment.dart';
import 'package:daftar_afandi/features/products/domain/category.dart';
import 'package:daftar_afandi/features/products/domain/category_repository.dart';
import 'package:daftar_afandi/features/products/domain/inventory_repository.dart';
import 'package:daftar_afandi/features/products/domain/product.dart';
import 'package:daftar_afandi/features/products/domain/product_draft.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:daftar_afandi/features/products/domain/product_repository.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/archived_products_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/categories_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/low_stock_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/opening_stock_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_details_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_form_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_list_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/stock_adjustment_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/stock_history_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/stock_summary_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/products_cubits.dart';

final class _StoredProduct {
  _StoredProduct(this.product, {this.categoryId});

  Product product;

  /// Stored even when the category is archived (research R17).
  String? categoryId;
  bool archived = false;
}

/// In-memory products, categories and stock history, with the same rules as
/// the real repositories. Every write is recorded in [writes] and notifies
/// the watch streams.
final class FakeProductsStore {
  final Map<String, _StoredProduct> _products = {};
  final List<Category> _categories = [];
  final Set<String> _archivedCategories = {};
  final Map<String, List<StockEntry>> _history = {};
  final StreamController<void> _changes = StreamController.broadcast();
  final List<String> writes = [];
  var _nextId = 1;
  var _clock = DateTime.utc(2026, 10, 20, 9);

  /// When set, the next write throws it (then it is cleared).
  Object? failNextWrite;

  late final FakeProductRepository products = FakeProductRepository(this);
  late final FakeInventoryRepository inventory = FakeInventoryRepository(this);
  late final FakeCategoryRepository categories = FakeCategoryRepository(this);

  String _id(String prefix) => '$prefix${_nextId++}';

  DateTime _now() => _clock = _clock.add(const Duration(minutes: 1));

  void _write(String what) {
    final failure = failNextWrite;
    if (failure != null) {
      failNextWrite = null;
      throw failure;
    }
    writes.add(what);
  }

  void _changed() => _changes.add(null);

  /// The current value on listen, then a new one after every change.
  /// When set, the next watch stream fails with it (then it is cleared).
  Object? failNextWatch;

  /// When set, the next paged read (history, statement) throws it (then it
  /// is cleared).
  Object? failNextRead;

  void _read() {
    final failure = failNextRead;
    if (failure != null) {
      failNextRead = null;
      throw failure;
    }
  }

  Stream<T> _watch<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        final failure = failNextWatch;
        if (failure != null) {
          failNextWatch = null;
          controller.addError(failure);
          return;
        }
        changes = _changes.stream.listen((_) => controller.add(read()));
        controller.add(read());
      },
      // Not returned: Stream.first waits for this future, and under fake
      // async a broadcast cancel never completes.
      onCancel: () => unawaited(changes?.cancel()),
    );
    return controller.stream;
  }

  // ---- seeding (no write recorded) ----

  /// Adds a product directly, optionally with opening stock.
  String seedProduct(
    String name, {
    UnitType unit = UnitType.piece,
    int pricePiasters = 1000,
    int? stockMilli,
    int costPiasters = 0,
    int? lowStockMilli,
    String? barcode,
    String? sku,
    String? categoryId,
    bool archived = false,
  }) {
    final id = _id('p');
    _products[id] = _StoredProduct(
      Product(
        id: id,
        name: name,
        unit: unit,
        salePricePiasters: pricePiasters,
        avgCostPiasters: stockMilli == null ? 0 : costPiasters,
        barcode: barcode,
        sku: sku,
        lowStockThresholdMilli: lowStockMilli,
      ),
      categoryId: categoryId,
    )..archived = archived;
    if (stockMilli != null) {
      _addEntry(id, StockEntryType.opening, stockMilli, costPiasters);
    }
    _changed();
    return id;
  }

  String seedCategory(String name) {
    final id = _id('c');
    _categories.add(
      Category(id: id, name: name, sortOrder: _categories.length),
    );
    _changed();
    return id;
  }

  /// Adds a raw history entry (for types later features write).
  void seedEntry(
    String productId,
    StockEntryType type,
    int deltaMilli, {
    AdjustmentKind? reason,
    String? note,
  }) {
    _addEntry(productId, type, deltaMilli, 0, reason: reason, note: note);
    _changed();
  }

  void _addEntry(
    String productId,
    StockEntryType type,
    int delta,
    int cost, {
    AdjustmentKind? reason,
    String? note,
  }) {
    final list = _history.putIfAbsent(productId, () => []);
    list.add(
      StockEntry(
        id: _id('m'),
        type: type,
        qtyDeltaMilli: delta,
        unitCostPiasters: cost,
        at: _now(),
        rowOrder: list.length + 1,
        reason: reason,
        note: note,
      ),
    );
  }

  // ---- reads ----

  int stockOf(String id) =>
      (_history[id] ?? const []).fold(0, (s, e) => s + e.qtyDeltaMilli);

  bool _hasHistory(String id) => (_history[id] ?? const []).isNotEmpty;

  String? _activeCategory(_StoredProduct p) {
    final id = p.categoryId;
    if (id == null || _archivedCategories.contains(id)) return null;
    return _categories.any((c) => c.id == id) ? id : null;
  }

  ProductSummary _summary(_StoredProduct p) {
    final categoryId = _activeCategory(p);
    final category = categoryId == null
        ? null
        : _categories.firstWhere((c) => c.id == categoryId);
    final base = p.product;
    return ProductSummary(
      product: Product(
        id: base.id,
        name: base.name,
        unit: base.unit,
        salePricePiasters: base.salePricePiasters,
        avgCostPiasters: base.avgCostPiasters,
        categoryId: categoryId,
        categoryName: category?.name,
        barcode: base.barcode,
        sku: base.sku,
        lowStockThresholdMilli: base.lowStockThresholdMilli,
        archived: p.archived,
      ),
      stockMilli: stockOf(base.id),
      hasHistory: _hasHistory(base.id),
    );
  }

  /// Arabic first, then Latin and digits, then alphabetical (research R5).
  static int _order(ProductSummary a, ProductSummary b) {
    final ka = arabicNormalize(a.product.name);
    final kb = arabicNormalize(b.product.name);
    final la = ka.isNotEmpty && ka.runes.first < 0x600 ? 1 : 0;
    final lb = kb.isNotEmpty && kb.runes.first < 0x600 ? 1 : 0;
    if (la != lb) return la - lb;
    final byKey = ka.compareTo(kb);
    return byKey != 0 ? byKey : a.product.id.compareTo(b.product.id);
  }

  List<ProductSummary> summaries(ProductQuery query) {
    final q = query.normalizedText;
    final filter = query.categoryFilter;
    final items =
        [
            for (final p in _products.values)
              if (!p.archived) _summary(p),
          ].where((s) {
            final p = s.product;
            if (q.isNotEmpty &&
                !arabicNormalize(p.name).contains(q) &&
                !(p.sku ?? '').toLowerCase().contains(q) &&
                !(p.barcode ?? '').contains(q)) {
              return false;
            }
            final matchesCategory = switch (filter) {
              AllCategories() => true,
              NoCategory() => p.categoryId == null,
              InCategory(:final categoryId) => p.categoryId == categoryId,
            };
            return matchesCategory && (!query.lowOnly || s.isLow);
          }).toList()
          ..sort(_order);
    if (q.isNotEmpty) {
      final exact = items.indexWhere((s) => s.product.barcode == q);
      if (exact > 0) items.insert(0, items.removeAt(exact));
    }
    return items;
  }

  LowStockSnapshot lowStock(int limit) {
    final low = summaries(const ProductQuery(lowOnly: true))
      ..sort((a, b) {
        final byStock = a.stockMilli.compareTo(b.stockMilli);
        return byStock != 0 ? byStock : _order(a, b);
      });
    return LowStockSnapshot(
      items: low.take(limit).toList(),
      totalCount: low.length,
      hasAnyProduct: _products.values.any((p) => !p.archived),
    );
  }

  ProductSummary? summary(String id) {
    final p = _products[id];
    return p == null ? null : _summary(p);
  }

  List<ProductSummary> archived() => [
    for (final p in _products.values)
      if (p.archived) _summary(p),
  ]..sort(_order);

  List<Category> activeCategories() => [
    for (final c in _categories..sort((a, b) => a.sortOrder - b.sortOrder))
      if (!_archivedCategories.contains(c.id))
        Category(
          id: c.id,
          name: c.name,
          sortOrder: c.sortOrder,
          productCount: _products.values
              .where((p) => !p.archived && p.categoryId == c.id)
              .length,
        ),
  ];

  String? _barcodeOwner(String? barcode, {String? exceptId}) {
    if (barcode == null) return null;
    for (final p in _products.values) {
      if (!p.archived &&
          p.product.id != exceptId &&
          p.product.barcode == barcode) {
        return p.product.name;
      }
    }
    return null;
  }

  bool _nameExistsElsewhere(String name, String exceptId) {
    final key = arabicNormalize(name);
    return _products.values.any(
      (p) =>
          !p.archived &&
          p.product.id != exceptId &&
          arabicNormalize(p.product.name) == key,
    );
  }

  Product _withDraft(String id, ProductDraft d, int avgCost) => Product(
    id: id,
    name: d.name,
    unit: d.unit,
    salePricePiasters: d.salePricePiasters,
    avgCostPiasters: avgCost,
    barcode: d.barcode,
    sku: d.sku,
    lowStockThresholdMilli: d.lowStockThresholdMilli,
  );
}

final class FakeProductRepository implements ProductRepository {
  FakeProductRepository(this._s);

  final FakeProductsStore _s;

  @override
  Stream<List<ProductSummary>> watchSummaries(ProductQuery query) =>
      _s._watch(() => _s.summaries(query));

  @override
  Stream<LowStockSnapshot> watchLowStock({int limit = 5}) =>
      _s._watch(() => _s.lowStock(limit));

  @override
  Stream<ProductSummary?> watchSummary(String id) =>
      _s._watch(() => _s.summary(id));

  @override
  Stream<List<ProductSummary>> watchArchived() => _s._watch(_s.archived);

  @override
  Future<ProductSummary?> activeByBarcode(String barcode) async {
    final code = normalizeCode(barcode);
    for (final s in _s.summaries(const ProductQuery())) {
      if (code != null && s.product.barcode == code) return s;
    }
    return null;
  }

  @override
  Future<Result<ProductSaved, ProductSaveError>> create(
    ProductDraft draft,
  ) async {
    final owner = _s._barcodeOwner(draft.barcode);
    if (owner != null) return Err(BarcodeTaken(owner));
    _s._write('create ${draft.name}');
    final id = _s._id('p');
    final opening = draft.opening;
    _s._products[id] = _StoredProduct(
      _s._withDraft(id, draft, opening?.unitCostPiasters ?? 0),
      categoryId: draft.categoryId,
    );
    if (opening != null) {
      _s._addEntry(
        id,
        StockEntryType.opening,
        opening.qtyMilli,
        opening.unitCostPiasters,
      );
    }
    _s._changed();
    return Ok(
      ProductSaved(
        id: id,
        nameExistsElsewhere: _s._nameExistsElsewhere(draft.name, id),
      ),
    );
  }

  @override
  Future<Result<ProductSaved, ProductSaveError>> update(
    String id,
    ProductDraft draft,
  ) async {
    final current = _s._products[id];
    if (current == null) return const Err(ProductNotFound());
    final owner = _s._barcodeOwner(draft.barcode, exceptId: id);
    if (owner != null) return Err(BarcodeTaken(owner));
    if (draft.unit != current.product.unit && _s._hasHistory(id)) {
      return const Err(UnitLocked());
    }
    _s._write('update ${draft.name}');
    current
      ..product = _s._withDraft(id, draft, current.product.avgCostPiasters)
      ..categoryId = draft.categoryId;
    _s._changed();
    return Ok(
      ProductSaved(
        id: id,
        nameExistsElsewhere: _s._nameExistsElsewhere(draft.name, id),
      ),
    );
  }

  @override
  Future<void> archive(String id) async {
    _s._write('archive $id');
    _s._products[id]!.archived = true;
    _s._changed();
  }

  @override
  Future<Result<void, RestoreError>> restore(String id) async {
    final p = _s._products[id]!;
    final owner = _s._barcodeOwner(p.product.barcode, exceptId: id);
    if (owner != null) return Err(RestoreBarcodeTaken(owner));
    _s._write('restore $id');
    p.archived = false;
    _s._changed();
    return const Ok(null);
  }
}

final class FakeInventoryRepository implements InventoryRepository {
  FakeInventoryRepository(this._s);

  final FakeProductsStore _s;

  @override
  Future<Result<void, ProductSaveError>> setOpening(
    String productId,
    OpeningStock opening,
  ) async {
    final p = _s._products[productId];
    if (p == null) return const Err(ProductNotFound());
    if (_s._hasHistory(productId)) return const Err(OpeningNotAllowed());
    _s._write('opening $productId');
    _s._addEntry(
      productId,
      StockEntryType.opening,
      opening.qtyMilli,
      opening.unitCostPiasters,
    );
    p.product = Product(
      id: p.product.id,
      name: p.product.name,
      unit: p.product.unit,
      salePricePiasters: p.product.salePricePiasters,
      avgCostPiasters: weightedAverageCost(
        stockMilli: 0,
        avgCostPiasters: 0,
        inQtyMilli: opening.qtyMilli,
        inTotalCostPiasters: opening.totalPiasters,
      ),
      barcode: p.product.barcode,
      sku: p.product.sku,
      lowStockThresholdMilli: p.product.lowStockThresholdMilli,
    );
    _s._changed();
    return const Ok(null);
  }

  @override
  Future<Result<AdjustmentResult, AdjustmentError>> adjust(
    String productId,
    AdjustmentRequest request,
  ) async {
    final onHand = _s.stockOf(productId);
    switch (request.deltaAgainst(onHand)) {
      case Err(:final error):
        return Err(error);
      case Ok(value: final delta):
        _s._write('adjust $productId $delta');
        _s._addEntry(
          productId,
          StockEntryType.adjustment,
          delta,
          _s._products[productId]!.product.avgCostPiasters,
          reason: request.kind,
          note: request.note,
        );
        _s._changed();
        return Ok(
          AdjustmentResult(deltaMilli: delta, newStockMilli: onHand + delta),
        );
    }
  }

  @override
  Future<List<StockEntry>> history(
    String productId, {
    StockEntryCursor? before,
    int limit = 50,
  }) async {
    _s._read();
    final newestFirst = (_s._history[productId] ?? const <StockEntry>[])
        .reversed
        .toList();
    final start = before == null
        ? 0
        : newestFirst.indexWhere((e) => e.rowOrder == before.rowOrder) + 1;
    return newestFirst.skip(start).take(limit).toList();
  }

  @override
  Future<int> rebuildAverageCost(String productId) async =>
      _s._products[productId]!.product.avgCostPiasters;
}

final class FakeCategoryRepository implements CategoryRepository {
  FakeCategoryRepository(this._s);

  final FakeProductsStore _s;

  @override
  Stream<List<Category>> watchActive() => _s._watch(_s.activeCategories);

  bool _duplicate(String name, {String? exceptId}) {
    final key = arabicNormalize(name);
    return _s.activeCategories().any(
      (c) => c.id != exceptId && arabicNormalize(c.name) == key,
    );
  }

  @override
  Future<Result<Category, CategoryError>> create(String name) async {
    final invalid = validateCategoryName(name);
    if (invalid != null) return Err(invalid);
    if (_duplicate(name)) return const Err(CategoryDuplicate());
    _s._write('category ${name.trim()}');
    final id = _s.seedCategory(name.trim());
    return Ok(_s._categories.firstWhere((c) => c.id == id));
  }

  @override
  Future<Result<void, CategoryError>> rename(String id, String name) async {
    final invalid = validateCategoryName(name);
    if (invalid != null) return Err(invalid);
    if (_duplicate(name, exceptId: id)) return const Err(CategoryDuplicate());
    _s._write('rename $id');
    final i = _s._categories.indexWhere((c) => c.id == id);
    final old = _s._categories[i];
    _s._categories[i] = Category(
      id: id,
      name: name.trim(),
      sortOrder: old.sortOrder,
    );
    _s._changed();
    return const Ok(null);
  }

  @override
  Future<void> archive(String id) async {
    _s._write('archive category $id');
    _s._archivedCategories.add(id);
    _s._changed();
  }

  @override
  Future<void> move(String id, MoveDirection direction) async {
    final ordered = _s.activeCategories().map((c) => c.id).toList();
    final from = ordered.indexOf(id);
    final to = direction == MoveDirection.up ? from - 1 : from + 1;
    if (to < 0 || to >= ordered.length) return;
    _s._write('move $id ${direction.name}');
    ordered[from] = ordered[to];
    ordered[to] = id;
    for (final (index, cid) in ordered.indexed) {
      final i = _s._categories.indexWhere((c) => c.id == cid);
      final c = _s._categories[i];
      _s._categories[i] = Category(id: c.id, name: c.name, sortOrder: index);
    }
    _s._changed();
  }
}

/// Real cubits built on a [FakeProductsStore].
final class FakeProductsCubits implements ProductsCubits {
  FakeProductsCubits([FakeProductsStore? store])
    : store = store ?? FakeProductsStore();

  final FakeProductsStore store;

  @override
  LowStockCubit lowStock() => LowStockCubit(store.products);

  @override
  ProductListCubit productList({
    ProductQuery initialQuery = const ProductQuery(),
  }) => ProductListCubit(
    store.products,
    store.categories,
    initialQuery: initialQuery,
  );

  @override
  ProductFormCubit productForm({
    required ProductFormMode mode,
    String? productId,
    String initialName = '',
  }) => ProductFormCubit(
    store.products,
    store.categories,
    mode: mode,
    productId: productId,
    initialName: initialName,
  );

  @override
  ProductDetailsCubit productDetails(String productId) =>
      ProductDetailsCubit(store.products, productId);

  @override
  StockHistoryCubit stockHistory(String productId) =>
      StockHistoryCubit(store.inventory, productId);

  @override
  OpeningStockCubit openingStock(String productId) =>
      OpeningStockCubit(store.products, store.inventory, productId);

  @override
  StockAdjustmentCubit stockAdjustment(String productId) =>
      StockAdjustmentCubit(store.products, store.inventory, productId);

  @override
  CategoriesCubit categories() => CategoriesCubit(store.categories);

  @override
  ArchivedProductsCubit archivedProducts() =>
      ArchivedProductsCubit(store.products);

  @override
  StockSummaryCubit stockSummary() => StockSummaryCubit(store.products);
}
