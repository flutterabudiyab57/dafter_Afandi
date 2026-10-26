# Implementation Plan: Sales and Customers

**Branch**: `003-sales-customers` | **Date**: 2026-10-20 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/003-sales-customers/spec.md`

## Summary

Adds selling and customer accounts on top of 002:
- a new-sale screen (search or barcode, quantity, price, line and invoice discounts, cash /
  wallet / InstaPay, walk-in or named customer, paid now for credit or partial sales, a stock
  shortage warning);
- the invoice list and invoice view, and voiding a whole invoice with a reason;
- customers (add, edit, archive, restore, opening balance), their balance and statement with a
  running balance, receiving a payment and cancelling one.

Stored data stays on **schema v1** and **no package is added**. Every sale, void and payment is one
transaction. Details: [research.md](research.md), [data-model.md](data-model.md),
[contracts/](contracts/), [quickstart.md](quickstart.md).

## Technical Context

**Language/Version**: Dart 3.13.5 on Flutter 3.47.7 stable

**Primary Dependencies**: unchanged (material_ui, flutter_bloc, go_router, drift, get_it,
equatable, intl; dev: bloc_test, mocktail, drift_dev, build_runner).

**Storage**: SQLite via Drift, schema v1: `sales_invoices`, `sale_items`, `customers`,
`customer_ledger`, `counters`, `stock_movements`, `products`. No new table, column, index or
trigger.

**Testing**: domain unit tests at every limit; repositories on `NativeDatabase.memory()` with
property tests (balance = Σ ledger, stock = Σ movements, avgCost = replay), rollback and number
sequence tests; cubit tests; widget tests in ar and en at 100% and 200%; existing import-rules
and ARB tests.

**Target Platform**: Android minSdk 24; iOS 15+. Phones, portrait.

**Performance Goals**: product search on the sale screen within 1 s with 2,000 products
(SC-002); a 3-line cash sale in under 30 s (SC-001).

**Constraints**: offline; integer money and quantities; no deletes; invoices immutable except the
void fields; ledgers and movements append-only.

**Scale/Scope**: about 10 screens, 2 repositories (+1 method on ProductRepository), 4 DAOs, about
12 cubits, about 130 ARB keys.

## Constitution Check

| Principle / rule | Status | Evidence / note |
|---|---|---|
| I. Local-first; no network | PASS | No network code. |
| II. Arabic-first; strings in ARB | PASS | ar + en keys; parity and literal-text tests. |
| II. Never "tax receipt" | PASS | Titled "فاتورة بيع" / "Sales invoice"; the ARB grep test covers it. |
| III. Integer money/qty | PASS | `int` throughout; existing parse, round and allocate helpers. |
| III. UUID PK; document numbers separate | PASS | `IdGenerator`; numbers from `counters` in the same transaction (R4). |
| III. Stock and balances derived | PASS | SUM subqueries (R8); avgCost written only by the void path, in its transaction (R11). |
| III. Immutable invoices; no hard delete | PASS | Insert-only items, movements, ledger; void fields only (trigger); no `delete(`. |
| III. One transaction per financial op | PASS | Write lists in data-model.md; rollback tests. |
| III. Sale line snapshots cost; WAC | PASS | `unitCostPiasters` = avgCost at sale; voids blend back at that cost (Q9). |
| III. Secrets not in DB | N/A | |
| IV. Feature-first, strict layers | PASS | `features/{sales,customers}`; presentation uses domain only (R3). |
| V. material_ui only; no new package | PASS | No pubspec change; lock audit re-run. |
| Schema change via make-migrations | N/A | No change. |
| Quality gates | PASS | Each phase ends with analyze clean and all tests green. |
| Workflow | PASS, note | The owner asked to run all phases to the end with the recommended defaults and to commit at each gate (as B1 in 002); never push. |

**Post-design re-check**: unchanged.

## Project Structure

```text
lib/core/database/daos/{counters_dao,customers_dao,customer_ledger_dao,sales_dao}.dart
lib/core/utils/doc_number.dart
lib/features/customers/domain|data|presentation/
lib/features/sales/domain|data|presentation/
test/features/customers/..., test/features/sales/..., test/helpers/fake_sales.dart
```

## Implementation phases

| Phase | Content | Gate |
|---|---|---|
| **1. Domain** | customers and sales types, drafts, validation, errors, interfaces; `formatDocNumber`; `ProductRepository.activeByBarcode` | unit tests at limits; analyze + tests green |
| **2. Data** | 4 DAOs, `CustomerRepositoryImpl`, `SalesRepositoryImpl`, barcode lookup, DI | repository tests, property tests, rollback and number tests, performance |
| **3. Cubits** | all cubits, `SalesCubits` / `CustomersCubits` bundles, fakes | bloc tests |
| **4. Customers UI (US4)** | strings, routes, customers list, form, details with statement, archived | widget tests ar/en 100/200% |
| **5. New sale (US1, US2)** | sale screen, product and customer pickers, shortage dialog, leave guard | widget tests |
| **6. Invoices, payments, voids (US3, US5, US6)** | invoice list and view, void dialog, payment screen, cancel payment | widget tests |
| **7. Polish** | every-screen walks, APK build, lock audit | all green |
