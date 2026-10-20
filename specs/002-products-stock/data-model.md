# Data Model: Products and Stock

Stored data is schema v1 from [001 data-model](../001-foundation/data-model.md), with no change
(research R1). This file defines the **domain types** this feature adds, how they map to the
tables, the queries, and every write.

## Domain types (`lib/features/products/domain/`, pure Dart)

### Product

| Field | Type | Notes |
|---|---|---|
| id | String | UUID v7 |
| name | String | as typed, trimmed |
| unit | UnitType | piece, kg, liter, meter (`core/utils/quantity.dart`) |
| salePricePiasters | int | per 1 unit |
| avgCostPiasters | int | kept by inventory paths only |
| categoryId | String? | null, or the id of an **active** category (R17) |
| categoryName | String? | joined, for display |
| barcode | String? | normalized (R9) |
| sku | String? | normalized (R9) |
| lowStockThresholdMilli | int? | |
| archived | bool | from `archivedAt != null` |

### ProductSummary (list rows, Home card, details header)

`Product` plus:
- `stockMilli` (int, derived);
- `isLow` (R6 rule);
- `isBelowZero` (`stockMilli < 0`);
- `hasHistory` (any movement exists; controls whether unit and opening can change).

### ProductDraft (validated input)

Created by `ProductDraft.create(...)` from raw form text. It returns
`Result<ProductDraft, List<ProductFieldError>>`.

The fields are: name, unit, salePricePiasters, categoryId, barcode, sku, lowStockThresholdMilli,
and `opening` (`OpeningStock?`).

`OpeningStock` has `qtyMilli > 0` and `unitCostPiasters`, and a `totalPiasters` getter equal to
`lineTotalPiasters`. When the quantity is 0, `opening` is null.

`ProductFieldError` (sealed):

| Error | Raised when |
|---|---|
| nameRequired | the name is empty after trimming |
| nameTooLong(max: 100) | the name is over 100 code points |
| priceRequired | no sale price |
| priceInvalid | not a number, or more than 2 decimals |
| priceTooLarge(max) | above 10,000,000 EGP |
| quantityInvalid | not a number, or too many decimals |
| quantityNotWhole | a fraction for a piece product |
| quantityTooLarge(max) | above 1,000,000 units |
| openingCostRequired | opening quantity above 0 with no cost |
| barcodeTooLong(max: 64) | |
| skuTooLong(max: 64) | |

### Repository-level errors

`ProductSaveError` (sealed):
- `barcodeTaken(otherProductName)`;
- `unitLocked`: the unit changed on a product that has history;
- `openingNotAllowed`: the product already has history;
- `notFound`.

`RestoreError` (sealed): `barcodeTaken(otherProductName)`.

### Category

`id`, `name`, `sortOrder`, `productCount` (active products, derived).

`CategoryError` (sealed): `nameRequired`, `nameTooLong(max: 40)`, `duplicate`.

### StockEntry (history row)

`id`, `type` (`StockEntryType`), `qtyDeltaMilli` (signed), `unitCostPiasters`, `reason`
(`AdjustmentKind?`), `note`, and `at` (DateTime, UTC).

`StockEntryType`: opening, purchase, purchaseVoid, sale, saleReturn, saleVoid, adjustment.

### AdjustmentRequest

| Kind | Input | Effect |
|---|---|---|
| `damage` | qtyMilli > 0 | removes `qtyMilli` |
| `count` | countedMilli ≥ 0 | `delta = counted − stock` |
| `other` | qtyMilli > 0, a direction (add or remove), required note | adds or removes `qtyMilli` |

Damage and count take an optional note.

`AdjustmentError` (sealed):
- `quantityRequired`, `quantityInvalid`, `quantityNotWhole`, `quantityTooLarge`;
- `noteRequired`, `noteTooLong(max: 200)`;
- `exceedsStock(onHandMilli)`;
- `alreadyMatches` (a count equal to the stock; nothing is written).

### ProductQuery (list state input)

`text` (raw), `categoryFilter` (`all` | `none` | `category(id)`), and `lowOnly` (bool).

## Mapping to tables

| Domain | Table / column | Notes |
|---|---|---|
| Product.name | products.name, products.search_key | `searchKey = arabicNormalize(name)` on every write |
| Product.unit | products.unit_type | DB enum is the same `UnitType` |
| barcode, sku | products.barcode, products.sku | NULL when empty |
| archived | products.archived_at | set to `clock.nowUtc()`; restore sets NULL |
| Category.name | categories.name, categories.search_key | |
| StockEntry | stock_movements | `adjustment_reason` ↔ `AdjustmentKind` |

Row ↔ entity mapping happens only in `lib/features/products/data/` (constitution IV).

## Queries (`lib/core/database/daos/`)

| DAO method | SQL outline | Used by |
|---|---|---|
| `ProductsDao.watchSummaries(query)` | products + stock subquery (R3) + category join; `archived_at IS NULL`; search (R4), filter, order (R5) | list |
| `ProductsDao.watchLowStock(limit: 5)` | same base, low rule (R6), `ORDER BY stock ASC, …`, `COUNT(*) OVER ()` | Home card |
| `ProductsDao.watchSummary(id)` | one row, with `has_history = EXISTS(movement)` | details, edit |
| `ProductsDao.watchArchived()` | `archived_at IS NOT NULL`, list order | archived view |
| `ProductsDao.activeWithBarcode(barcode, exceptId)` | conflict check (R9) | save, restore |
| `ProductsDao.activeNameExists(searchKey, exceptId)` | duplicate-name notice (R14) | after save |
| `StockMovementsDao.stockOf(productId)` | `COALESCE(SUM(qty_delta_milli), 0)` | adjustment |
| `StockMovementsDao.hasAny(productId)` | `EXISTS` | opening, unit lock |
| `StockMovementsDao.page(productId, before, 50)` | `ORDER BY created_at DESC, rowid DESC` | history |
| `StockMovementsDao.replayRows(productId)` | `ORDER BY created_at, rowid` | WAC rebuild |
| `CategoriesDao.watchActive()` | with an active product count, `ORDER BY sort_order, search_key` | categories, pickers, filter |

## Writes (each list is one transaction)

| Operation | Writes |
|---|---|
| Create product without opening | W1 insert `products` (`avgCost = 0`) |
| Create product with opening | W1 insert `products`; W2 insert `stock_movements` OPENING; W3 update `products.avg_cost_piasters` |
| Set opening later | R1 `hasAny` must be false; W1 insert OPENING; W2 update avg cost |
| Edit product | R1 barcode conflict; R2 `hasAny` if the unit changed; W1 update `products` (name, searchKey, unit, price, category, barcode, sku, threshold, updatedAt), never `avg_cost` |
| Archive product | W1 update `archived_at`, `updated_at` |
| Restore product | R1 barcode conflict; W1 update `archived_at = NULL`, `updated_at` |
| Adjustment | R1 `stockOf`; R2 avg cost; W1 insert ADJUSTMENT (none when the delta is 0) |
| Create category | R1 duplicate check; W1 insert (`sortOrder = max + 1`) |
| Rename category | R1 duplicate check; W1 update name, searchKey, updatedAt |
| Archive category | W1 update `archived_at`, `updated_at` |
| Move category | W1..Wn update `sort_order` for every active category |

No operation deletes a row or updates a `stock_movements` row; the v1 triggers enforce both.

## State transitions

- **Product**: active ⇄ archived. History is never removed. The unit can change only while there
  is no history.
- **Product opening**: none → set (once, while there is no history). There is no path back.
- **Category**: active → archived (no restore in this feature).

## Names as implemented (Phase 1, 2026-10-20)

The domain code follows this file with these naming details:
- Every `ProductFieldError` carries a `field` (`ProductField`: name, price, lowStock, openingQty,
  openingCost, barcode, sku), so the form puts each error under its field. `PriceInvalid` and
  `PriceTooLarge` also cover the opening cost, and the quantity errors cover the low-stock level
  and the opening quantity.
- `ProductSaveError.notFound` is `ProductNotFound`, and `RestoreError.barcodeTaken` is
  `RestoreBarcodeTaken`.
- `AdjustmentError` subclasses are prefixed (`AdjustmentQuantityRequired`, ...), plus
  `ExceedsStock` and `AlreadyMatches`.
- `AdjustmentRequest.deltaAgainst(onHandMilli)` holds the stock rules (FR-014), so the repository
  only reads the stock and writes the result.
- `LowStockSnapshot` also has `hasAnyProduct`, for the card's "add products" state. `isLow` is
  derived by the shared `isLowStock` rule.
- `CategoryFilter` is `AllCategories`, `NoCategory` or `InCategory(id)`.
