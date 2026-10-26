# Contracts: Sales and Customers

Domain interfaces (pure Dart) and the screens that use them. Names may be refined during
implementation; the data-model.md appendix will record the final names.

## CustomerRepository (`features/customers/domain/customer_repository.dart`)

```dart
abstract interface class CustomerRepository {
  Stream<List<CustomerSummary>> watchActive(CustomerQuery query); // text, owesOnly
  Stream<CustomerSummary?> watchOne(String id);                    // archived too
  Stream<List<CustomerSummary>> watchArchived();
  Future<Result<CustomerSaved, CustomerSaveError>> create(CustomerDraft draft);
  Future<Result<CustomerSaved, CustomerSaveError>> update(String id, CustomerDraft draft);
  Future<void> archive(String id);
  Future<void> restore(String id);
  Future<List<LedgerEntry>> statement(String id, {LedgerCursor? before, int limit = 50});
  Future<Result<int, PaymentError>> receivePayment(String customerId, PaymentRequest request); // receipt number
  Future<Result<void, PaymentError>> cancelPayment(String entryId, String reason);
}
```
`CustomerSaved{id, nameExistsElsewhere}`.

## SalesRepository (`features/sales/domain/sales_repository.dart`)

```dart
abstract interface class SalesRepository {
  Future<Result<SaleSaved, SaleSaveError>> create(SaleDraft draft, {bool acknowledgeShortage = false});
  Stream<List<SaleSummary>> watchList(SaleQuery query, {int limit = 50}); // text, unpaidOnly, customerId?
  Stream<SaleInvoice?> watchOne(String id);
  Future<Result<void, VoidError>> voidSale(String id, String reason);
}
```
`SaleSaved{id, number}`.

## ProductRepository addition (002)

`Future<ProductSummary?> activeByBarcode(String barcode)`: the active product whose barcode equals
the folded input, or null.

## Screens and cubits

| Route | Screen | Cubit(s) | Notes |
|---|---|---|---|
| `/sales` | SalesListScreen | SalesListCubit | search, unpaid filter, Show more, FAB New sale |
| `/sales/new` | NewSaleScreen | SaleCubit | lines, discounts, customer, paid, method; shortage dialog; leave guard |
| (pushed) | ProductPickerPage | ProductPickerCubit | search; Enter on an exact barcode picks it |
| (pushed) | CustomerPickerPage | CustomerPickerCubit | search; "Add «name»" quick add |
| `/sales/:id` | InvoiceScreen | InvoiceCubit | all fields; Void (dialog with reason) |
| `/parties` | CustomersScreen | CustomersListCubit | search, owes filter, archived link, FAB add |
| `/parties/customers/new` | CustomerFormScreen | CustomerFormCubit | opening balance with direction |
| `/parties/customers/:id/edit` | CustomerFormScreen | CustomerFormCubit | no opening balance |
| `/parties/customers/:id` | CustomerDetailsScreen | CustomerDetailsCubit, StatementCubit | balance, actions, statement, invoices |
| `/parties/customers/:id/payment` | PaymentScreen | PaymentCubit | credit notice |
| `/parties/customers/archived` | ArchivedCustomersScreen | ArchivedCustomersCubit | restore |

Every screen: strings from ARB (ar + en), digits in the chosen style, Arabic and Latin digit
input, 200% text without overflow, spoken labels on every control.
