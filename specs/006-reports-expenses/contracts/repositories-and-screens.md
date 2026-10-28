# Contracts: Reports, Home Dashboard and Expenses

Domain interfaces (pure Dart) and the screens that use them. Names may be refined during
implementation; data-model.md will record the final names.

## Payments (`features/payments/`)

```dart
// domain/account_suggestions_repository.dart
abstract interface class AccountSuggestionsRepository {
  /// Distinct account numbers used with [method], most recent first.
  Future<List<AccountSuggestion>> forMethod(PaymentMethod method, {int limit = 5});
}

// data/payment_parts_writer.dart, used only by repository impls inside their transaction
final class PaymentPartsWriter {
  /// Throws [PaymentPartsMismatch] (rolls back) unless split.total == paidPiasters.
  Future<void> write(PaymentParent parent, PaymentSplit split,
      {required int paidPiasters, required DateTime at});
  Future<List<PaymentPart>> partsOf(PaymentParent parent);
}

sealed class PaymentParent { /* SaleParent(id), PurchaseParent(id), ReceiptParent(ledgerId),
                                SupplierPaymentParent(ledgerId), ExpenseParent(id) */ }
```

### PaymentSplitField (presentation widget)
- Inputs: total to pay (`int` piasters), current `PaymentSplit`, `onChanged`.
- Unsplit: method chips (cash, wallet, InstaPay), cash selected; the amount is the total.
- Wallet or InstaPay: an optional "your account number" field with up to 5 suggestion chips.
- "Split payment": adds a second part (and a third), each with method, amount and account; shows
  "remaining" or "over by" live; a removed part gives its amount back to part 1.
- Errors are shown per part, the sum error under the parts.
- Used by: new sale (paid now), customer payment, new purchase (paid now), supplier payment,
  new expense.

## Expenses (`features/expenses/`)

```dart
abstract interface class ExpenseRepository {
  Stream<List<Expense>> watchList(ExpenseQuery query, {int limit = 50});
  Stream<int> watchTotal(ExpenseQuery query);             // non-voided only
  Stream<Expense?> watchOne(String id);
  Future<Result<ExpenseSaved, ExpenseSaveError>> create(ExpenseDraft draft); // {id, number}
  Future<Result<void, ExpenseVoidError>> voidExpense(String id, String reason);
}

abstract interface class ExpenseCategoryRepository {
  Stream<List<ExpenseCategory>> watchActive();
  Stream<List<ExpenseCategory>> watchArchived();
  Future<void> ensureDefaults(List<String> names);         // only when the table is empty
  Future<Result<String, ExpenseCategoryError>> create(String name);
  Future<Result<void, ExpenseCategoryError>> rename(String id, String name);
  Future<void> archive(String id);
  Future<Result<void, ExpenseCategoryError>> restore(String id); // NameTaken if clashing
}
```

## Reports (`features/reports/`)

```dart
abstract interface class ReportsRepository {
  Stream<ProfitSummary> watchProfit(ReportPeriod period);
  Stream<CollectedSummary> watchCollected(ReportPeriod period);
  Stream<List<TopSeller>> watchTopSellers(ReportPeriod period, TopSellerOrder order);
  Stream<List<BalanceRow>> watchCustomersOwing({int? limit});
  Stream<List<BalanceRow>> watchSuppliersOwed();
  Stream<DashboardSnapshot> watchDashboard();             // today, by the injected Clock
}
```

## Changed contracts (003, 004)

- `SalesRepository.create` → `SaleSaved{id, number, lowStock}`; `SaleDraft.split`.
- `CustomerRepository.receivePayment(customerId, PaymentRequest)` with `request.split`.
- `PurchaseRepository.create` with `PurchaseDraft.split`.
- `SupplierRepository.pay(supplierId, SupplierPaymentRequest)` with `request.split`.
- `SaleInvoice`, `Purchase`, `LedgerEntry`, `SupplierEntry` expose `parts`.

## Cubits

| Cubit | State |
|---|---|
| `DashboardCubit` | loading / loaded(DashboardSnapshot) / failed; re-reads on resume (new day) |
| `ReportPeriodCubit` | the chosen `ReportPeriod`, shared by the report screens |
| `ProfitCubit`, `CollectedCubit`, `TopSellersCubit`, `BalancesCubit` | loading / loaded / failed |
| `ExpensesListCubit` | query, rows, total, load state |
| `ExpenseFormCubit` | draft, field errors, saving, saved(number) |
| `ExpenseCubit` | one expense; void |
| `ExpenseCategoriesCubit` | active, archived, errors |
| `PaymentSplitCubit` | parts, errors, suggestions per method |

Bundles: `ReportsCubits` / `AppReportsCubits`, `ExpensesCubits` / `AppExpensesCubits`; fakes in
`test/helpers/fake_reports.dart` and `test/helpers/fake_expenses.dart`.

## Routes and screens

| Path | Screen | Story |
|---|---|---|
| `/home` | Dashboard: today's sales, collected, running low, top 3 debtors, shortcuts | US1 |
| `/reports` | Period bar, profit summary, links to the views below and to expenses | US2 |
| `/reports/collected` | Money collected by method | US5 |
| `/reports/top` | Top sellers, value / quantity switch | US5 |
| `/reports/balances` | Who owes the shop / what the shop owes (two tabs) | US5 |
| `/reports/expenses` | Expenses list, period and category filters, total | US3 |
| `/reports/expenses/new` | Expense form with `PaymentSplitField` | US3, US6 |
| `/reports/expenses/:id` | Expense details, void | US3 |
| `/reports/expense-categories` | Categories: add, rename, archive, restore | US3 |

Changed screens: new sale (split, low-stock message), invoice (parts), customer payment (split),
customer statement (parts), new purchase (split), purchase (parts), supplier payment (split),
supplier statement (parts).

Every new screen is added to `test/helpers/screens.dart` (`visitEveryScreen`, `kOnboardedPaths`).
