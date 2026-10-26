# Contract: Repositories and Domain

Interfaces live in `lib/features/products/domain/`. Their implementations live in
`lib/features/products/data/` and use DAOs from `lib/core/database/daos/` plus `TransactionRunner`.
Types are defined in [data-model.md](../data-model.md).

## ProductRepository

```dart
abstract interface class ProductRepository {
  Stream<List<ProductSummary>> watchSummaries(ProductQuery query);
  Stream<LowStockSnapshot> watchLowStock({int limit = 5}); // items + totalCount
  Stream<ProductSummary?> watchSummary(String id);          // null when not found
  Stream<List<ProductSummary>> watchArchived();

  /// One transaction; inserts OPENING and sets avg cost when draft.opening != null.
  Future<Result<ProductSaved, ProductSaveError>> create(ProductDraft draft);

  /// Never changes stock or avg cost. draft.opening must be null.
  Future<Result<ProductSaved, ProductSaveError>> update(String id, ProductDraft draft);

  Future<void> archive(String id);
  Future<Result<void, RestoreError>> restore(String id);
}
```

`ProductSaved` holds `id` and `nameExistsElsewhere` (bool, for the R14 notice).

## InventoryRepository

```dart
abstract interface class InventoryRepository {
  /// Only while the product has no history; otherwise Err(openingNotAllowed).
  Future<Result<void, ProductSaveError>> setOpening(String productId, OpeningStock opening);

  /// One transaction: reads stock, validates, inserts one ADJUSTMENT (or nothing).
  Future<Result<AdjustmentResult, AdjustmentError>> adjust(String productId, AdjustmentRequest req);

  Future<List<StockEntry>> history(String productId, {StockEntryCursor? before, int limit = 50});

  /// Maintenance and tests: rebuilds avgCostPiasters by replay (research R7) and returns it.
  Future<int> rebuildAverageCost(String productId);
}
```

`AdjustmentResult` holds `deltaMilli` and `newStockMilli`.

## CategoryRepository

```dart
abstract interface class CategoryRepository {
  Stream<List<Category>> watchActive();
  Future<Result<Category, CategoryError>> create(String name);
  Future<Result<void, CategoryError>> rename(String id, String name);
  Future<void> archive(String id);
  Future<void> move(String id, MoveDirection direction); // up or down; one transaction
}
```

## Behaviour rules (each one is tested)

| Rule | Test |
|---|---|
| Every multi-write in one transaction | A failing write (fake runner throws after W2) leaves no product and no movement |
| Stock equals the sum of movements | Property test over random opening and adjustment sequences |
| Avg cost equals replay | `rebuildAverageCost` equals the stored value after each sequence |
| Adjustment never changes avg cost | Before and after compare |
| Damage or other remove ≤ stock | `exceedsStock(onHand)` at the limit and limit + 1 milli |
| Count equal to stock writes nothing | Movement count unchanged, `Err(alreadyMatches)` |
| Barcode unique among active | Create, update and restore return `barcodeTaken(name)`; an archived holder does not block |
| Unit locked after history | `update` with a new unit returns `Err(unitLocked)` |
| Opening once | A second `setOpening` returns `Err(openingNotAllowed)` |
| Archived hidden | Not in summaries, search or low stock; present in `watchArchived` |
| Archived category | Its products match the `none` filter and show `categoryId == null` |
| No delete, no movement update | Repositories issue none (grep test); triggers already tested in 001 |
| Search folding | "ارز" finds "أرز مصري"; Arabic-digit barcode finds the Latin one; exact barcode first |
| Order | Arabic names before Latin names, alphabetical; tie by name, then id |
| Performance | 2,000 products and 100,000 movements: list plus search under 300 ms (R3) |

## Domain validation (pure tests)

`ProductDraft.create`, `AdjustmentRequest` constructors and the category name validator are
tested at every limit in the data-model.md tables (empty, 1, max, max + 1, decimals, Arabic
digits, piece fractions).
