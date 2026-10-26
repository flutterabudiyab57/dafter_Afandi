# Implementation Plan: Reports, Home Dashboard and Expenses

**Branch**: `006-reports-expenses` | **Date**: 2026-10-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/006-reports-expenses/spec.md`

## Summary

Adds the numbers an owner reads every day, on top of 001–005:
- a home dashboard: today's sales and count, money collected today, the running-low count and the
  top 3 who owe, with the existing shortcuts plus "record expense";
- Reports: a period bar (today, yesterday, this week from Saturday, this month, last month, custom),
  the profit summary (net sales, cost of goods, gross profit, net inventory losses by reason,
  expenses, net profit or loss), money collected by method, top sellers and balances;
- expenses with E- numbers, categories (four defaults, add, rename, archive), void with a reason;
- a low-stock message right after a sale;
- every payment (sale, receipt, purchase, supplier payment, expense) can be split across up to
  three methods, and wallet or InstaPay parts can record the owner's own account number, with
  suggestions from earlier use.

The schema moves to **v2** with one new table, `payment_parts`, and one index; no existing table
changes, and existing payments are backfilled as one part each. **No package is added.** Details:
[research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/),
[quickstart.md](quickstart.md).

## Technical Context

**Language/Version**: Dart 3.13.5 on Flutter 3.47.7 stable

**Primary Dependencies**: unchanged (material_ui, flutter_bloc, go_router, drift, get_it,
equatable, intl; dev: bloc_test, mocktail, drift_dev, build_runner).

**Storage**: SQLite via Drift, schema v1 → **v2**: new `payment_parts` (immutable) and
`ix_stock_movements_type_created`. Read: `sales_invoices`, `sale_items`, `sale_returns`,
`purchase_invoices`, `stock_movements`, `customer_ledger`, `supplier_ledger`, `expenses`,
`expense_categories`, `products`, `counters` (EXPENSE already seeded).

**Testing**: domain unit tests at every limit (periods across midnight, Saturday weeks, month ends;
split sums; account numbers); repositories on `NativeDatabase.memory()` with property tests
(profit lines = hand sums, Σ parts = paid, balances unchanged); the generated v1 → v2 migration
test plus an upgrade data test; a performance test (20,000 sales, 2,000 expenses); cubit tests;
widget tests in ar and en at 100% and 200%; every-screen walks; import-rules and ARB tests.

**Target Platform**: Android minSdk 24; iOS 15+. Phones, portrait.

**Performance Goals**: dashboard within 2 s of opening (SC-001); any report within 2 s on a year of
data (SC-005); an expense in under 30 s (SC-003); an unsplit payment with no extra taps (SC-008).

**Constraints**: offline; integer money and quantities; parts immutable; derived numbers never
stored; every write in one transaction.

**Scale/Scope**: about 9 new screens and 8 changed ones; 3 new features (payments, expenses,
reports) and changes in sales, customers, purchases, suppliers, home; 4 new DAOs
(payment parts, expenses, expense categories, reports); about 14 cubits; about 140 ARB keys.

## Constitution Check

| Principle / rule | Status | Evidence / note |
|---|---|---|
| I. Local-first; no network | PASS | No network code. |
| II. Arabic-first; strings in ARB | PASS | ar + en keys; parity and literal-text tests. |
| II. Never "tax receipt" | PASS | No new document is called a receipt for tax; expenses are "مصروف". |
| III. Integer money/qty | PASS | `int` everywhere; adjustment values through `roundHalfUpDiv` (R9). |
| III. UUID PK; document numbers separate | PASS | Parts and expenses use `IdGenerator`; E- numbers from the `EXPENSE` counter in the same transaction. |
| III. Stock and balances derived | PASS | Every report is a query over saved rows; nothing cached (R9, R11). |
| III. Immutable invoices; no hard delete | PASS | `payment_parts` joins the immutable and no-delete trigger lists; expenses void only (existing trigger). |
| III. One transaction per financial op | PASS | Parts are written inside each existing transaction by `PaymentPartsWriter`, which rolls back on a sum mismatch (R5). |
| III. Secrets not in DB | PASS | The account number is the owner's public wallet number, not a secret (spec Assumptions). |
| IV. Feature-first, strict layers | PASS | `features/{payments,expenses,reports}`; repository impls use `payments/data`, screens and cubits only domain (R7). |
| V. material_ui only; no new package | PASS | Built-in date range picker; no pubspec change. |
| Technical rule: `paymentMethod` columns | PASS | Header and ledger `payment_method` stay and hold part 1's method (R3). Splits, the account number and expense methods follow constitution **1.1.0**, approved by the owner on 2026-10-26 (R15.1). |
| Technical rule: profit formula | PASS | `netProfit = grossProfit - inventoryLosses - expenses`, losses on their own line, gains netted (FR-012). |
| Schema change via make-migrations | PASS | v2: `schemaVersion` bump, `make-migrations`, `from1To2`, schema JSON, generated tests (R1, R4). |
| Quality gates | PASS | Each phase ends with analyze clean and all tests green. |
| Workflow | PASS, note | **B1 for 006**, approved by the owner on 2026-10-26: the agent commits once at each phase gate, for this feature only; never pushes or merges (R15.2). |

**Post-design re-check**: unchanged; no violation needs justification.

## Project Structure

```text
lib/core/database/tables/payment_parts_table.dart                   (new)
lib/core/database/daos/{payment_parts,expenses,expense_categories,reports}_dao.dart   (new)
lib/core/database/{app_database,schema_sql,schema_constants}.dart   (v2, migration)
lib/core/utils/account_ref.dart                                     (normalizeAccountRef)
lib/features/payments/domain|data|presentation/                     (new: split, writer, field)
lib/features/expenses/domain|data|presentation/                     (new)
lib/features/reports/domain|data|presentation/                      (replaces the placeholder)
lib/features/home/presentation/                                     (dashboard)
lib/features/{sales,customers,purchases,suppliers}/...              (split, parts, low-stock result)
drift_schemas/app_database/drift_schema_v2.json, test/drift/app_database/...
test/features/{payments,expenses,reports}/..., test/helpers/fake_{reports,expenses}.dart
```

## Implementation phases

| Phase | Content | Gate |
|---|---|---|
| **1. Domain** | `ReportPeriod`, `ProfitSummary` and the report types; `PaymentSplit`, `PaymentPart`, errors, `normalizeAccountRef`; expense and category drafts and errors; `PaymentMethod` move with re-export | unit tests at limits; analyze + tests green |
| **2. Schema v2** | `payment_parts` table, indexes, triggers, `from1To2` with backfill, schema JSON, generated tests, upgrade data test | migration tests; trigger coverage; all old tests green |
| **3. Payments in existing flows (US6 data)** | `PaymentPartsWriter`, suggestions; sale, receipt, purchase and supplier payment write parts; invoices and statements read parts; `SaleSaved.lowStock` | repository and property tests (Σ parts = paid, balances unchanged); rollback tests |
| **4. Expenses and reports data** | expense and category repositories, defaults seeding, reports DAO and repository, DI | repository tests; profit property test; performance test |
| **5. Cubits** | all new cubits and bundles, fakes; changed sale, payment and purchase cubits | bloc tests |
| **6. Payment field UI (US6, US4)** | `PaymentSplitField` in the five forms; parts on invoice, purchase and statements; low-stock message | widget tests ar/en 100/200% |
| **7. Expenses UI (US3)** | list, form, details with void, categories | widget tests |
| **8. Reports and dashboard UI (US1, US2, US5)** | period bar, profit, collected, top sellers, balances, home dashboard | widget tests; every-screen walks |
| **9. Polish** | ARB review, screenshots, APK build, quickstart on a phone over a 005 install, lock audit | all green |

Phases 2 and 3 change how existing money is stored; each ends with the full suite and the upgrade
test passing before the next starts.
