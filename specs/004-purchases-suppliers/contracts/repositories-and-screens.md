# Contracts: Purchases and Suppliers

Domain interfaces (pure Dart) and the screens that use them. Names may be refined during
implementation; the data-model.md appendix will record the final names.

## SupplierRepository (`features/suppliers/domain/supplier_repository.dart`)

```dart
abstract interface class SupplierRepository {
  Stream<List<SupplierSummary>> watchActive(SupplierQuery query); // text, owedOnly
  Stream<SupplierSummary?> watchOne(String id);                    // archived too
  Stream<List<SupplierSummary>> watchArchived();
  Future<Result<SupplierSaved, SupplierSaveError>> create(SupplierDraft draft);
  Future<Result<SupplierSaved, SupplierSaveError>> update(String id, SupplierDraft draft);
  Future<void> archive(String id);
  Future<void> restore(String id);
  Future<List<SupplierEntry>> statement(String id, {LedgerCursor? before, int limit = 50});
  Stream<void> watchStatementChanges(String supplierId);
  Future<Result<int, SupplierPaymentError>> pay(String supplierId, SupplierPaymentRequest request); // payment number
  Future<Result<void, SupplierPaymentError>> cancelPayment(String entryId, String reason);
}
```
`SupplierSaved{id, nameExistsElsewhere}`.

## PurchaseRepository (`features/purchases/domain/purchase_repository.dart`)

```dart
abstract interface class PurchaseRepository {
  Future<Result<PurchaseSaved, PurchaseSaveError>> create(PurchaseDraft draft);
  Stream<List<PurchaseSummary>> watchList(PurchaseQuery query, {int limit = 50});
  Stream<Purchase?> watchOne(String id);
  Future<int?> lastUnitCost(String productId);   // newest non-voided purchase line
  Future<Result<void, PurchaseVoidError>> voidPurchase(
    String id, String reason, {bool acknowledgeShortage = false});
}
```
`PurchaseSaved{id, number}`.

## InventoryRepository change (002)

`rebuildAverageCost(productId)` keeps its signature; it now skips voided purchase pairs and uses
the stored net line cost of purchases (research R8).

## Screens and cubits

| Route | Screen | Cubit(s) | Notes |
|---|---|---|---|
| `/purchases` | PurchasesListScreen | PurchasesListCubit | search, unpaid filter, Show more, FAB New purchase |
| `/purchases/new` | NewPurchaseScreen | PurchaseCubit | lines, cost notice, discounts, supplier, ref, date, paid, method; leave guard |
| (pushed) | ProductPickerPage | ProductPickerCubit | moved to products; quick add on purchases only |
| (pushed) | QuickAddProductPage | ProductFormCubit (002) | name, unit, price, barcode; returns the product |
| (pushed) | SupplierPickerPage | SupplierPickerCubit | search; "Add «name»" quick add |
| `/purchases/:id` | PurchaseScreen | PurchaseViewCubit | all fields; Void (reason dialog, then shortage dialog) |
| `/parties` | CustomersScreen (003) | CustomersListCubit | gains the Customers / Suppliers switch |
| `/parties/suppliers` | SuppliersScreen | SuppliersListCubit | search, owed filter, archived link, FAB add, switch |
| `/parties/suppliers/new` | SupplierFormScreen | SupplierFormCubit | opening balance with direction |
| `/parties/suppliers/:id/edit` | SupplierFormScreen | SupplierFormCubit | no opening balance |
| `/parties/suppliers/:id` | SupplierDetailsScreen | SupplierDetailsCubit, SupplierStatementCubit | balance, actions, statement, purchases |
| `/parties/suppliers/:id/payment` | SupplierPaymentScreen | SupplierPaymentCubit | "supplier will owe the shop" notice |
| `/parties/suppliers/archived` | ArchivedSuppliersScreen | ArchivedSuppliersCubit | restore |

Every screen: strings from ARB (ar + en), digits in the chosen style, Arabic and Latin digit
input, 200% text without overflow, spoken labels on every control. Every new screen and dialog is
added to `visitEveryScreen`.
