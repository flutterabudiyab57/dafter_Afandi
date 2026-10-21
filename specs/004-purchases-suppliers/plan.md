# Implementation Plan: Purchases and Suppliers

**Branch**: `004-purchases-suppliers` | **Date**: 2026-10-21 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/004-purchases-suppliers/spec.md`

## Summary

Adds buying and supplier accounts on top of 002 and 003:
- a new-purchase screen (search or barcode, quick add of a new product, quantity, unit cost
  prefilled from the last purchase, line and invoice discounts, a notice when the cost reaches the
  selling price, supplier's invoice number and date, cash / wallet / InstaPay, optional or named
  supplier, paid now for credit or partial purchases, a leave guard);
- the purchase list and purchase view, and voiding a whole purchase with a reason, which rebuilds
  the average cost by replay and warns when stock would go below zero;
- suppliers next to customers in Parties (add, edit, archive, restore, opening balance), their
  balance and statement with a running balance, paying a supplier and cancelling a payment.

Stored data stays on **schema v1** and **no package is added**. Every purchase, void and payment is
one transaction. Details: [research.md](research.md), [data-model.md](data-model.md),
[contracts/](contracts/), [quickstart.md](quickstart.md).

## Technical Context

**Language/Version**: Dart 3.13.5 on Flutter 3.47.7 stable

**Primary Dependencies**: unchanged (material_ui, flutter_bloc, go_router, drift, get_it,
equatable, intl; dev: bloc_test, mocktail, drift_dev, build_runner).

**Storage**: SQLite via Drift, schema v1: `purchase_invoices`, `purchase_items`, `suppliers`,
`supplier_ledger`, `counters` (PURCHASE, SUPPLIER_PAYMENT already seeded), `stock_movements`,
`products`. No new table, column, index or trigger.

**Testing**: domain unit tests at every limit; repositories on `NativeDatabase.memory()` with
property tests (supplier balance = Σ ledger, stock = Σ movements, stored avgCost = replay after
random purchases, sales, voids and adjustments), rollback and number sequence tests; cubit tests;
widget tests in ar and en at 100% and 200%; every-screen walks; existing import-rules and ARB
tests.

**Target Platform**: Android minSdk 24; iOS 15+. Phones, portrait.

**Performance Goals**: product search on the purchase screen within 1 s with 2,000 products
(SC-002); a 5-line purchase from a named supplier in under 90 s (SC-001).

**Constraints**: offline; integer money and quantities; no deletes; purchases immutable except the
void fields; ledgers and movements append-only.

**Scale/Scope**: about 11 screens, 2 repositories (+ replay change in InventoryRepository), 3 new
DAOs (+ methods on stock movements and counters), about 12 cubits, about 120 ARB keys; small
moves in 003 code (product picker, reason dialog, Parties switch).

## Constitution Check

| Principle / rule | Status | Evidence / note |
|---|---|---|
| I. Local-first; no network | PASS | No network code. |
| II. Arabic-first; strings in ARB | PASS | ar + en keys; parity and literal-text tests. |
| II. Never "tax receipt" | PASS | Titled "فاتورة شراء" / "Purchase invoice"; the ARB grep test covers it. |
| III. Integer money/qty | PASS | `int` throughout; existing parse, round, allocate and WAC helpers (R5, R7). |
| III. UUID PK; document numbers separate | PASS | `IdGenerator`; P- and PY- numbers from `counters` in the same transaction (R4). |
| III. Stock and balances derived | PASS | SUM subqueries; avgCost written only by the purchase and purchase-void paths, in their transaction (R7, R11). |
| III. Rebuildable by replay | PASS | Replay skips voided purchase pairs and uses the stored net line cost, so stored = replay (R8). |
| III. Immutable invoices; no hard delete | PASS | Insert-only items, movements, ledger; void fields only (existing trigger); no `delete(`. |
| III. One transaction per financial op | PASS | Write lists in data-model.md; rollback tests. Quick add of a product is its own 002 create (R13). |
| III. Purchases update WAC | PASS | Per line, in lineNo order, from stock and average before the line (R7). |
| III. Secrets not in DB | N/A | |
| IV. Feature-first, strict layers | PASS | `features/{suppliers,purchases}`; presentation uses domain only (R3). |
| V. material_ui only; no new package | PASS | No pubspec change; lock audit before the first commit (R2). |
| Schema change via make-migrations | N/A | No change (R1). |
| Quality gates | PASS | Each phase ends with analyze clean and all tests green. |
| Workflow | PASS, note | **B1 for 004**, approved by the owner on 2026-10-21: the agent commits once at each phase gate, for this feature only; never pushes or merges. |

**Post-design re-check**: unchanged; no violation needs justification.

## Project Structure

```text
lib/core/database/daos/{suppliers_dao,supplier_ledger_dao,purchases_dao}.dart   (new)
lib/core/database/daos/stock_movements_dao.dart     (purchase rows; replay skips voided pairs)
lib/core/utils/money.dart                           (unchanged helpers reused)
lib/core/widgets/reason_dialog.dart                 (moved from customers, unchanged)
lib/features/products/presentation/screens/product_picker_page.dart   (moved from sales; quick add)
lib/features/suppliers/domain|data|presentation/
lib/features/purchases/domain|data|presentation/   (replaces the placeholder screen)
test/features/suppliers/..., test/features/purchases/..., test/helpers/fake_purchases.dart
```

## Implementation phases

| Phase | Content | Gate |
|---|---|---|
| **1. Domain** | supplier and purchase types, drafts, validation, errors, interfaces; last-cost and cost-notice rules; lock audit | unit tests at limits; analyze + tests green |
| **2. Data** | 3 DAOs, stock movement and replay changes, `SupplierRepositoryImpl`, `PurchaseRepositoryImpl`, DI | repository tests; property tests (balance, stock, avgCost = replay); rollback and number tests; performance |
| **3. Cubits** | all cubits, `SuppliersCubits` / `PurchasesCubits` bundles, fakes | bloc tests |
| **4. Suppliers UI (US4)** | strings, routes, Parties switch, supplier list, form, details with statement, archived | widget tests ar/en 100/200% |
| **5. New purchase (US1, US2)** | purchase screen, shared product picker with quick add, supplier picker, cost notice, leave guard | widget tests |
| **6. Purchases, payments, voids (US3, US5, US6)** | purchase list and view, void with shortage warning, supplier payment, cancel payment | widget tests |
| **7. Polish** | every-screen walks, APK build, quickstart on a phone or listed for the owner, lock audit | all green |
