# Contract: Routes, Screens, Cubits and Strings

This extends [001 routes-and-screens](../../001-foundation/contracts/routes-and-screens.md). The
first-run redirect is unchanged; every new path is allowed only after onboarding.

## Routes (children of the Home branch, research R10)

| Path | Screen (`lib/features/products/presentation/`) | Cubit |
|---|---|---|
| `/home` | `HomeScreen` (home): Products button, Categories entry, `LowStockCard` | `LowStockCubit` |
| `/home/products` | `ProductListScreen`; `?filter=low` starts with low only | `ProductListCubit` |
| `/home/products/new` | `ProductFormScreen(mode: create)` | `ProductFormCubit` |
| `/home/products/archived` | `ArchivedProductsScreen` | `ArchivedProductsCubit` |
| `/home/products/:id` | `ProductDetailsScreen`: header, actions, stock history | `ProductDetailsCubit`, `StockHistoryCubit` |
| `/home/products/:id/edit` | `ProductFormScreen(mode: edit)` | `ProductFormCubit` |
| `/home/products/:id/opening` | `OpeningStockScreen` (only while there is no history; otherwise it redirects to details) | `OpeningStockCubit` |
| `/home/products/:id/adjust` | `StockAdjustmentScreen` | `StockAdjustmentCubit` |
| `/home/categories` | `CategoriesScreen` | `CategoriesCubit` |

`RoutePaths` gains the constants and `productDetails(id)`-style builders. The product paths are
declared before `:id`, so `new` and `archived` never match as ids.

## Cubits (bloc_test + mocktail, fakes of the repositories)

| Cubit | State | Inputs, then effect |
|---|---|---|
| `LowStockCubit` | loading / `LowStockSnapshot` | watches `watchLowStock(5)` |
| `ProductListCubit` | `query`, `items`, `status` | `search(text)`: 200 ms debounce; `setCategory`; `toggleLow`; resubscribes on each change |
| `ProductFormCubit` | field texts, `errors`, `status` (editing / confirmOpening / saving / saved / failed), `unitLocked`, `categories` | `submit()` validates. With opening > 0 it goes to `confirmOpening(qty, cost, total)`. `confirm()` saves; `cancelConfirm()` returns to editing. `saved` carries `nameExistsElsewhere` |
| `ProductDetailsCubit` | `ProductSummary?` | watches the product; `archive()`, `restore()` (errors surface as state) |
| `StockHistoryCubit` | entries, `hasMore` | `load()`, `loadMore()`; reloads when details see a stock change |
| `OpeningStockCubit` | qty and cost text, errors, confirm state | same confirm flow as the form |
| `StockAdjustmentCubit` | kind, direction, qty or counted text, note, errors, status | `submit()` maps `AdjustmentError` to field errors; `alreadyMatches` is an info message, not an error |
| `CategoriesCubit` | categories, editing name, errors | `create`, `rename`, `archive` (with confirm), `moveUp`, `moveDown` |
| `ArchivedProductsCubit` | items | watches `watchArchived`; `restore(id)` |

Repository write failures (`SqliteException` other than the mapped UNIQUE) surface as a
`failed` status with `errorSaveFailed`, as in 001.

## Screen behaviour

- **List rows**:
  - name (wraps), sale price (`formatPiasters`), stock with the unit label (R18);
  - a low mark (icon plus a spoken "low stock" label) and a below-zero mark (icon plus a spoken
    "below zero" label);
  - tapping a row opens details.
- **List app bar**: a search field. The filters are chips: All / a category… / No category, and
  Low stock. An overflow action opens Archived products. A FAB adds a product.
- **Empty states**:
  - no products: "Add your first product" with an add button;
  - nothing found: "No product named “…”" with "Add “…”", which opens the form with the name
    filled in.
- **Form**:
  - Fields: name, unit (a segmented control of 4 options; disabled with a note when locked),
    sale price, category (picker with "No category"), barcode, code, low-stock level.
  - An "Opening stock" section with quantity and cost appears only in create mode.
  - Errors show under each field. Save stays enabled and shows all errors on tap.
- **Opening confirmation**: a dialog showing "12 قطعة × ٧٫٥٠ ج.م = ٩٠٫٠٠ ج.م" with Confirm and
  Back.
- **Details**:
  - Header: name, unit, price, average cost, stock, category, barcode, code, low-stock level.
  - Actions: Edit, Adjust stock, Set opening stock (only without history), Archive (with
    confirm). An archived product shows Restore instead.
  - History list below the header, with "Show more".
- **Adjustment**:
  - A reason picker: Damaged / Stock count / Other.
  - Count shows "On hand now: X" and a "Counted quantity" field. Damaged shows "Quantity to
    remove". Other shows an Add/Remove toggle, a quantity field and a required note.
  - Saving returns to details and shows a SnackBar with the new stock.
- **Categories**: a list with the product count. Each row has Rename, Move up, Move down and
  Archive. A field at the top adds a new category.
- **Home**: the Products button and the Categories entry are always visible.
  - The low-stock card lists up to 5 rows (name, stock and unit) and "X products low on stock",
    and opens `/home/products?filter=low`.
  - With nothing low it says stock is fine. With no products at all it says "Add products to
    track stock".
- All new screens follow the 001 layout rules: they scroll, have no fixed text heights, use
  directional padding and a capped width, label every control, and survive 200% text.

## ARB keys (new; both files, ar is the template)

**Home**: `homeProductsAction`, `homeCategoriesAction`, `lowStockCardTitle`, `lowStockCount`
(`{count}` plural), `lowStockNone`, `lowStockNoProducts`, `lowStockSeeAll`.

**Products**:
- `productsTitle`, `productsSearchHint`, `productsFilterAll`, `productsFilterNoCategory`,
  `productsFilterLow`, `productsArchivedTitle`;
- `productsEmpty`, `productsEmptyAction`, `productsNoMatch` (`{query}`), `productsAddNamed`
  (`{name}`);
- `markLowStock`, `markBelowZero`.

**Units**: `unitPiece`, `unitKg`, `unitLiter`, `unitMeter` (the full names, for the form) and
`unitPieceShort`, `unitKgShort`, `unitLiterShort`, `unitMeterShort`.

**Form**:
- `productAddTitle`, `productEditTitle`;
- field labels: `productNameLabel`, `productUnitLabel`, `productPriceLabel`,
  `productCategoryLabel`, `productNoCategory`, `productBarcodeLabel`, `productSkuLabel`,
  `productLowStockLabel`, `productOpeningSection`, `productOpeningQtyLabel`,
  `productOpeningCostLabel`, `productUnitLockedNote`, `saveAction`;
- opening confirmation: `openingConfirmTitle`, `openingConfirmBody` (`{qty}`, `{cost}`,
  `{total}`), `confirmAction`, `backAction`;
- after save: `productNameExistsNotice`.

**Errors**:
- `errorNameRequired`, `errorNameTooLong` (`{max}`);
- `errorPriceRequired`, `errorPriceInvalid`, `errorPriceTooLarge` (`{max}`);
- `errorQuantityInvalid`, `errorQuantityNotWhole`, `errorQuantityTooLarge` (`{max}`);
- `errorOpeningCostRequired`, `errorBarcodeTaken` (`{name}`), `errorCodeTooLong` (`{max}`),
  `errorRestoreBarcodeTaken` (`{name}`).

**Details**: `productDetailsTitle`, `productAvgCost`, `productStockOnHand`, `productEditAction`,
`productAdjustAction`, `productSetOpeningAction`, `productArchiveAction`,
`productArchiveConfirm`, `productRestoreAction`, `productRestored`, `historyTitle`,
`historyEmpty`, `historyShowMore`.

**History types**: `stockOpening`, `stockPurchase`, `stockPurchaseVoid`, `stockSale`,
`stockSaleReturn`, `stockSaleVoid`, `stockAdjustment`, `reasonDamage`, `reasonCount`,
`reasonOther`.

**Adjustment**:
- `adjustTitle`, `adjustReasonLabel`, `adjustOnHand` (`{qty}`), `adjustCountedLabel`,
  `adjustRemoveLabel`, `adjustAdd`, `adjustRemove`, `adjustQtyLabel`, `adjustNoteLabel`,
  `adjustNoteRequired`;
- `adjustExceedsStock` (`{qty}`), `adjustAlreadyMatches`, `adjustSaved` (`{qty}`).

**Categories**: `categoriesTitle`, `categoryAddHint`, `categoryRename`, `categoryMoveUp`,
`categoryMoveDown`, `categoryArchive`, `categoryArchiveConfirm`, `categoryProductCount`
(`{count}` plural), `errorCategoryDuplicate`, `errorCategoryNameTooLong` (`{max}`).

Number placeholders are formatted before they reach the ARB string, so they follow the digit style.
The existing ARB tests (key parity, no literal `Text('…')`, no tax wording) cover the new keys.
