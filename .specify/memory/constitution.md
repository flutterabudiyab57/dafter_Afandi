<!--
Sync Impact Report
- Version: 1.1.0 → 1.2.0 (MINOR: Principle III narrowed exception)
- Changed: Principle III, the no-hard-delete rule.
- Added: a customer or supplier with no history (no ledger row, invoice or return) may be removed
  for good after 7 days in the archive; archiving such a party warns that it will be removed.
- Removed: none.
- Templates: no change needed. Follow-up: schema v3 replaces the customers and suppliers delete
  triggers.
- Approved by the owner on 2026-10-27.

Previous: 1.0.0 → 1.1.0 (MINOR: Technical Rules expanded)
- Changed: Technical Rules, the paymentMethod rule; amends decision Q23.
- Added: split payments in `payment_parts` with the owner's optional account number; expenses
  record their method through their parts.
- Removed: none.
- Templates: no change needed. Follow-up: specs/006-reports-expenses implements it (schema v2).
- Approved by the owner on 2026-10-26.
-->
# Daftar Afandi (دفتر أفندي) Constitution

## Core Principles

### I. Local-First, Single Source of Truth

- The on-device SQLite database (Drift) is the ONLY source of truth. Single device.
- NO network code of any kind (no dio, http, Firebase, sockets, analytics) until a future
  milestone explicitly adds a one-way server copy. The schema MUST stay sync-ready
  (UUID keys, UTC timestamps, soft delete, append-only ledgers).
- The database file lives in `getApplicationSupportDirectory()`.

Rationale: shops work offline; one authoritative store removes reconciliation bugs.

### II. Arabic-First and Honest Documents

- Arabic (RTL) is the primary locale; English is secondary. `app_ar.arb` is the ARB template.
- Every user-facing string MUST live in ARB files and exist in both `app_ar.arb` and `app_en.arb`.
  No hard-coded UI text.
- EGP only, no tax. The in-app invoice is an internal document and MUST NEVER be labeled or
  presented as a tax receipt or tax invoice.

Rationale: the users read Arabic first; mislabeling a document as a tax receipt is a legal risk.

### III. Data Integrity (NON-NEGOTIABLE)

- Money is `int` piasters (1 EGP = 100); names end in `Piasters`. Quantity is `int` milli-units
  (1 unit = 1000); names end in `Milli`. NO `double` anywhere in a money or quantity path:
  not in the DB, domain, Cubit state, or formatting input. Rounding only via `core/utils/money.dart`
  helpers (line total = `roundHalfUpDiv(qtyMilli * unitPricePiasters, 1000)`); never inline it.
- Primary keys are UUID v7 TEXT via `IdGenerator`. Document numbers are a separate sequential column,
  issued from `counters` in the same transaction as the insert (gap-free), running forever.
  Prefixes (S-, R-, P-, E-, RC-, PY-) are display-only and never stored.
- Stock = SUM(stock_movements). Balances = SUM(ledger). The only cached value is
  `products.avgCostPiasters` (weighted average cost), written only by inbound-movement paths in the
  same transaction and rebuildable by replay.
- Saved invoices are immutable. Corrections only via returns or voids with reversing entries.
  Void is forbidden if returns exist; sale returns cannot be voided (v1). Immutability triggers allow
  updating only `voidedAt`, `voidReason`, and `updatedAt`.
- Ledgers and stock movements are append-only. No hard deletes of referenced data; archive via
  `archivedAt` instead. DB triggers enforce both.
- The one exception: a customer or supplier with no history (no ledger row, invoice or return)
  is removed for good once it has been archived for 7 days. Archiving it MUST warn the owner
  first, and the archive shows when it will go. The delete triggers refuse any other delete.
- Every financial operation runs in ONE database transaction (`TransactionRunner` in a repository impl).
- Every sale line snapshots its unit cost and product name. Purchases update WAC; returns and voids
  re-enter stock at the original snapshot cost.
- Secrets (PIN hash and salt) NEVER live in the database; they live only in `flutter_secure_storage`.

Rationale: an accounting app that loses a piaster or rewrites history is worthless.

### IV. Feature-First, Strict Layering

- Layout: `lib/core/{database,di,router,theme,l10n,utils,widgets}` and
  `lib/features/<name>/{data,domain,presentation}`.
- Direction (strict): Screen → Cubit → Repository interface (domain) → Repository impl (data) → DAO → Drift.
- Screens and Cubits MUST NOT import drift, `core/database`, DAOs, or another feature's `data/`.
- `domain/` is pure Dart: no Flutter, no Drift row classes. Rows ↔ entities are mapped in `data/`.
- `test/architecture/import_rules_test.dart` MUST pass.

Rationale: keeps financial logic testable without UI and the DB swappable for a future sync layer.

### V. Stack and Dependency Discipline

- UI imports `package:material_ui/material_ui.dart`, NEVER `package:flutter/material.dart` or
  `package:flutter/cupertino.dart`.
- Localization delegates: `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]`
  (from material_ui). NEVER `AppLocalizations.localizationsDelegates`. Never import
  `flutter_localizations` in the same file as material_ui.
- State: flutter_bloc Cubits only. DI: get_it. Routing: go_router. DB: drift + drift_flutter.
  Forbidden: dio, Firebase, Hive, Isar, Riverpod, Provider-as-state, GetX, MobX, any other state management.
- No package is added, removed, or upgraded without explicit human approval. Approved so far beyond
  the base stack: equatable, share_plus, local_auth, file_picker, path_provider, crypto,
  flutter_secure_storage; dev only: flutter_lints, flutter_launcher_icons, flutter_native_splash.
  `pdf` is NOT approved.
- All direct dependencies are pinned exactly (no `^`); `pubspec.lock` is committed. Never pick a pub
  package version less than 14 days old (the official stable Flutter SDK is exempt). Any
  `dependency_overrides` entry carries a "remove after <date>" comment.

Rationale: a small, approved, pinned stack keeps the app reproducible and reviewable.

## Technical Rules

- Time: UTC epoch milliseconds INTEGER via `Clock` + `UtcMillisConverter`.
- Mutable tables: `createdAt`, `updatedAt`, `archivedAt`. Immutable documents: `createdAt`, plus
  `voidedAt`, `voidReason`, `updatedAt` on voidable headers.
- `paymentMethod` is TEXT NOT NULL DEFAULT 'cash' CHECK IN ('cash','wallet','instapay','card')
  on sales, purchases, sale returns, and payment ledger rows. No external payment integration.
- A payment may be split into up to three parts, one per method, stored in the immutable
  `payment_parts` table; each wallet or InstaPay part may carry the owner's own account number.
  The header and ledger `paymentMethod` hold part 1's method. Expenses record their method only
  through their parts. The parts of a payment MUST add up exactly to the amount paid.
- Profit report: `netProfit = grossProfit - inventoryLosses - expenses`; inventory losses are a separate line.
- Schema change = bump `schemaVersion` + `dart run drift_dev make-migrations` + step-by-step migration
  + exported schema JSON + passing generated migration tests. Generated `*.g.dart` files are committed.
- UI: RTL-safe only (`EdgeInsetsDirectional`, `AlignmentDirectional`, start/end; never left/right).
  flutter_screenutil (design 420x812) for sizes only; never disable or clamp system text scaling.
  Money and quantity are formatted only via `core/utils`; Arabic and Latin digit input both work.

## Quality Gates and Workflow

Quality gates (a phase is not done until all pass):

- Every money/quantity utility and every financial flow has unit tests. Cubits are tested with
  bloc_test + mocktail; repositories on in-memory Drift (`NativeDatabase.memory()`).
- `flutter analyze` is clean and `flutter test` passes.
- Review checklist before presenting any change: no forbidden import or package; layer direction
  respected, no Drift types above `data/`; no `double` for money/qty and correct suffixes; every
  multi-write flow in one transaction, with every write listed; no hard delete, no update of
  immutable rows beyond void fields; schema changes carry version bump, schema JSON, and migration
  tests; new strings in both ARB files; RTL and 200% text scale checked.

Workflow (human-in-the-loop):

- `/speckit-implement` executes ONE phase of `tasks.md` at a time, then stops for human review.
- The agent NEVER commits, pushes, or merges. The human does.
- When anything is ambiguous, the agent stops and asks instead of guessing.

## Governance

- This constitution supersedes all other practices, including CLAUDE.md, specs, and plans. Where a
  later document conflicts, this file wins until amended.
- Amendments require explicit human approval, an updated Sync Impact Report, and a version bump:
  MAJOR for removing or redefining a principle, MINOR for adding a principle or materially expanding
  rules, PATCH for wording clarifications.
- Every plan's Constitution Check and every review MUST verify compliance. Any deviation needs a
  written justification approved by the human before implementation.
- `docs/research/M0-DECISIONS.md` records decisions that shaped this document; new product decisions
  are folded in here by amendment.

**Version**: 1.2.0 | **Ratified**: 2026-10-19 | **Last Amended**: 2026-10-27
