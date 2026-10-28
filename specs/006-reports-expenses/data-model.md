# Data Model: Reports, Home Dashboard and Expenses

Money is `int` piasters, quantity `int` milli, time UTC `DateTime` (local only for display and
periods). Decisions are in [research.md](research.md).

## Stored: schema v2

### New table `payment_parts` (immutable)

| Column | Type | Rule |
|---|---|---|
| id | TEXT PK | UUID v7 |
| sales_invoice_id | TEXT NULL → sales_invoices | RESTRICT |
| purchase_invoice_id | TEXT NULL → purchase_invoices | RESTRICT |
| customer_ledger_id | TEXT NULL → customer_ledger | RESTRICT; only a `PAYMENT_RECEIVED` row with a receipt number |
| supplier_ledger_id | TEXT NULL → supplier_ledger | RESTRICT; only a `PAYMENT_MADE` row with a payment number |
| expense_id | TEXT NULL → expenses | RESTRICT |
| part_no | INTEGER | 1–3 |
| method | TEXT | `cash`, `wallet`, `instapay`, `card` (card never written by the app) |
| amount_piasters | INTEGER | > 0 |
| account_ref | TEXT NULL | 1–40 chars of `[0-9A-Za-z@._-]`; NULL when method is cash or card |
| created_at | INTEGER | UTC ms; equals the parent's `created_at` |

CHECKs: exactly one parent column is set; `amount_piasters > 0`; `part_no BETWEEN 1 AND 3`; the
method list; `account_ref IS NULL OR (method IN ('wallet','instapay') AND length(account_ref)
BETWEEN 1 AND 40)`.

Indexes:
- one unique `(parent_id, method)` and one unique `(parent_id, part_no)` per parent column, each
  partial `WHERE parent_id IS NOT NULL` (10 indexes);
- `ix_payment_parts_created_at (created_at)`;
- `ix_payment_parts_method_account (method, account_ref, created_at) WHERE account_ref IS NOT NULL`.

Triggers: `trg_payment_parts_no_delete`, `trg_payment_parts_immutable` (it joins `kAllTables` and
`kImmutableTables`).

### Other v2 changes

- `ix_stock_movements_type_created ON stock_movements (movement_type, created_at)`.
- No other table, column, CHECK or trigger changes.

### Migration `from1To2` (one transaction)

1. Create `payment_parts`, its indexes and triggers, and the new stock movements index.
2. Backfill part 1 for every existing payment (research R4): sales with paid at sale > 0,
   purchases with paid > 0, receipt rows, supplier payment rows, expenses. `account_ref` NULL.
3. `user_version` = 2.

Tests: the generated v1 → v2 migration test; a data test that fills v1 with sales (cash, credit,
partial, voided, with and without customer), purchases, receipts, a reversed receipt, supplier
payments and adjustments, upgrades, and checks every balance, stock, statement total and parts sum.

## Payments domain (`lib/features/payments/domain/`)

### PaymentMethod
Moved from `customers/domain/payment.dart` (re-exported there): `cash, wallet, instapay, card`;
`offeredPaymentMethods` = cash, wallet, instapay.

### PaymentPart
| Field | Type | Rule |
|---|---|---|
| method | PaymentMethod | offered methods only |
| amountPiasters | int | > 0 |
| accountRef | String? | wallet or InstaPay only; normalised (R6) |

### PaymentSplit
`List<PaymentPart>` of 1–3 parts.
- `PaymentSplit.single(method, amount, {accountRef})`: the unsplit case.
- `PaymentSplit.create({required int totalPiasters, required List<PaymentPartInput> inputs})` →
  `Result<PaymentSplit, List<PaymentSplitError>>`, collecting every error.
- Derived: `total`, `first.method` (written to the header and ledger `payment_method`).
- A zero total is "nothing paid": no split is asked for and no parts are written.

### PaymentPartInput
`method`, `amountText`, `accountText`, as typed.

### PaymentSplitError (sealed, each with the part index)
PartAmountInvalid, PartAmountZero, MethodRepeated, TooManyParts, AccountInvalid, AccountTooLong,
AccountNotAllowed (on cash), SumMismatch(differencePiasters).

### AccountSuggestion
`method`, `accountRef`, `lastUsedAt`.

## Changes to existing drafts and results

| Type | Change |
|---|---|
| `SaleDraft` | `method` → `split: PaymentSplit` over `paid`; validation adds the split errors |
| `SaleSaved` | adds `lowStock: List<LowStockItem>` |
| `SaleInvoice`, `Purchase` | add `parts: List<PaymentPart>` (`method` = part 1's) |
| `PurchaseDraft` | `method` → `split` over `paid` |
| `PaymentRequest` (customer) | `method` → `split` over `amount` |
| `SupplierPaymentRequest` | `method` → `split` over `amount` |
| `LedgerEntry`, `SupplierEntry` | add `parts` (from the invoice for sale and purchase payments, own parts for receipts and payments) |

### LowStockItem
productId, name, unit, stockMilli, thresholdMilli? (null when only below zero).

## Expenses domain (`lib/features/expenses/domain/`)

### ExpenseCategory
id, name (trimmed, 1–50 code points), archived. Unique among active by `arabicNormalize(name)`.

### ExpenseDraft.create({categoryId, amountText, split inputs, spentOn (local date), note})
- category: required and active;
- amount: 0 < amount ≤ 1,000,000,000 piasters, ≤ 2 decimals;
- split: over the amount; default `PaymentSplit.single(cash, amount)`;
- spentOn: ≤ today (local); stored as the local day's start in UTC ms;
- note: ≤ 200 code points, empty → null.

### Expense (saved)
id, number (shown E-n), category (id, name, archived), amount, parts, spentAt, note, createdAt,
voidedAt?, voidReason?.

### ExpenseQuery
period (`ReportPeriod`), categoryId?.

### Errors
- `ExpenseFieldError` (sealed): CategoryRequired, CategoryArchived, AmountRequired, AmountInvalid,
  AmountTooLarge, DateInFuture, NoteTooLong, plus split errors.
- `ExpenseSaveError`: Invalid(errors), CategoryUnavailable.
- `ExpenseVoidError`: NotFound, AlreadyVoided, ReasonInvalid (reused `validateReason`).
- `ExpenseCategoryError`: NameRequired, NameTooLong, NameTaken(existing), NotFound.

### Writes (each one transaction)
| Operation | Reads | Writes |
|---|---|---|
| Record expense | category active | W1 `EXPENSE` number; W2 `expenses` row; W3 1–3 `payment_parts` |
| Void expense | not voided | W1 `voided_at`, `void_reason`, `updated_at` |
| Add / rename / archive / restore category | name free among active | `expense_categories` insert or update |
| Seed defaults | table empty | 4 `expense_categories` rows |

## Changed writes in existing flows

Each flow keeps its transaction and adds W-parts at the end, through `PaymentPartsWriter`, which
re-checks `parts.sum == paid` and rolls back on a mismatch:

| Flow | Parts written for |
|---|---|
| Sale create (003) | the invoice, when paid at sale > 0 |
| Customer receipt (003) | the new `PAYMENT_RECEIVED` row |
| Purchase create (004) | the invoice, when paid > 0 |
| Supplier payment (004) | the new `PAYMENT_MADE` row |
| Expense record (006) | the expense |

Voids and payment cancels write no parts: a voided parent or reversed ledger row excludes its parts
from every report.

## Reports domain (`lib/features/reports/domain/`)

### ReportPeriod
kind (`today`, `yesterday`, `thisWeek`, `thisMonth`, `lastMonth`, `custom`), from and to local
dates. `range(Clock)` → `[startUtc, endUtc)`. Week starts Saturday. Custom: to ≥ from, to ≤ today.
Error: `PeriodInvalid` (EndBeforeStart, InFuture).

### ProfitSummary
| Field | Rule |
|---|---|
| salesPiasters | Σ non-voided sale totals in period |
| returnsPiasters | Σ return refunds in period |
| netSalesPiasters | sales − returns |
| costOfGoodsPiasters | Σ line costs − Σ returned costs |
| grossProfitPiasters | netSales − costOfGoods |
| inventoryLossesByReason | `Map<AdjustmentReason, int>`, each the net (gains negative) |
| inventoryLossesPiasters | Σ by reason; negative = net gain |
| expensesPiasters | Σ non-voided expenses in period |
| netProfitPiasters | gross − inventoryLosses − expenses; negative = loss |
| salesCount | non-voided sales in period |
| linesWithoutCost | sale lines in period with unit cost 0 |
| isEmpty | no sales, returns, adjustments or expenses |

### CollectedSummary
`Map<PaymentMethod, int>` for cash, wallet and InstaPay (in − refunds) and `totalPiasters`.

### TopSeller
productId, name (latest snapshot), unit, qtyMilli (sold − returned), netSalesPiasters. Up to 10,
ordered by value or quantity (`TopSellerOrder`).

### BalanceRow
partyId, name, balancePiasters, archived. Two lists: customers owing (balance > 0, largest first)
and suppliers owed (balance > 0, largest first), each with a total.

### DashboardSnapshot
todaySalesPiasters, todaySalesCount, todayCollected (`CollectedSummary`), runningLowCount,
topDebtors (`List<BalanceRow>`, 3).
