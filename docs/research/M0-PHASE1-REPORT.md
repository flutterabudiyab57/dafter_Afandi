# دفتر أفندي (Daftar Afandi): Milestone 0, Phase 1 report

Date: 2026-10-19. Status: **proposal only.** No project created, no code, no packages, no commits.
The 14-day cutoff is **2026-10-05**: anything published after that date is rejected below.

---

## 1. Environment

### 1.1 Installed toolchain

| Tool | Installed | Required | Status |
|---|---|---|---|
| Flutter | **3.44.1** stable (2026-05-29), at `C:\src\flutter` | 3.47.x | **Not compliant** |
| Dart | **3.12.1** | 3.13 | **Not compliant** |

`material_ui` ≥ 1.4.0 declares `flutter: >=3.47.0, sdk: ^3.13.0`, so the required stack **cannot resolve on this machine** until Flutter is upgraded.

Flutter 3.47 stable releases (from the official `releases_windows.json`):

| Version | Date | Dart | Age today |
|---|---|---|---|
| 3.47.7 (current stable) | 2026-10-08 | 3.13.5 | 11 days |
| **3.47.6** | 2026-10-01 | 3.13.5 | 18 days |
| 3.47.5 | 2026-09-18 | 3.13.4 | 31 days |

**Proposal:** if the 14-day rule also applies to the SDK, use **3.47.6**. Running `flutter upgrade` would install 3.47.7. To get 3.47.6, run `git checkout 3.47.6` in `C:\src\flutter`, then `flutter --version`. → Open question Q1.

### 1.2 Package versions (checked on the pub.dev API today, not guessed)

| Package | Latest on pub.dev | **Proposed pin** | Published | Reason |
|---|---|---|---|---|
| material_ui | 1.7.0 (10-14) | **1.5.0** | 2026-09-28 | 1.7.0 (5 d) and 1.6.0 (13 d) are too new. 1.3.0 was retracted. |
| flutter_bloc | 9.1.1 | **9.1.1** | 2025-05-02 | |
| bloc (transitive; pinned for bloc_test) | 9.2.1 | **9.2.1** | 2026-05-12 | Only if added directly. See Q2. |
| go_router | 18.1.0 (10-14) | **18.0.2** | 2026-09-28 | 18.1.0 is too new. 18.x already uses material_ui (see 1.3). |
| drift | 2.35.2 (10-07) | **2.35.1** | 2026-09-30 | 2.35.2 is only 12 days old. |
| drift_dev | 2.35.1 | **2.35.1** | 2026-09-30 | Requires `drift >=2.30.0 <2.36.0`. Matches. |
| drift_flutter | 0.3.1 | **0.3.1** | 2026-07-11 | |
| build_runner | 2.17.1 (10-14) | **2.16.1** | 2026-09-02 | 2.17.1 is too new, 2.17.0 was retracted, 2.16.2 (10-07) is too new. |
| get_it | 9.3.0 | **9.3.0** | 2026-09-19 | |
| uuid | 4.6.0 | **4.6.0** | 2026-07-15 | Has `Uuid().v7()`. |
| flutter_screenutil | 5.9.3 | **5.9.3** | 2024-05-31 | Required pin. The package is unmaintained (no release in 2+ years). See R6. |
| intl | 0.20.3 | **0.20.3** | 2026-06-25 | `flutter_localizations` in 3.47.6 requires `^0.20.3`. |
| flutter_localizations | SDK | `sdk: flutter` | — | |
| bloc_test | 10.0.0 | **10.0.0** | 2025-01-12 | |
| mocktail | 1.0.5 | **1.0.5** | 2026-04-10 | |

**Transitive packages that would resolve too new.** These come in automatically and are not added by us:
- `sqlite3`: drift needs `^3.4.0`, so pub picks **3.7.1 (2026-10-13, 6 days)**. Last version that passes the rule: 3.7.0 (2026-09-30).
- `cupertino_ui` (needed by material_ui and go_router): pub picks **1.1.3 (2026-10-14)**. 1.1.2 (10-06) is also too new. Last that passes: 1.1.1 (2026-09-21).
- `sqlite3_flutter_libs` is now `0.6.0+eol`. sqlite3 3.x ships native code through build hooks. drift_flutter 0.3.1 still depends on the EOL stub, which is expected and harmless.

To hold these back I would need `dependency_overrides` or a direct pin, and that counts as adding packages. → Q3. In Phase 2 I will also check the publish date of **every** package in `pubspec.lock` before the first commit.

**Packages the MVP will need that are NOT in the approved stack.** I add nothing without your approval (Q4). Here they are with verified versions:

| Purpose | Package | Version (date) | Notes |
|---|---|---|---|
| Invoice sharing | share_plus | 13.3.1 (2026-10-01) | No `flutter/material` import |
| App lock (biometric) | local_auth | 3.0.2 (2026-07-09) | No material import. Needs `FlutterFragmentActivity` on Android |
| Restore: choose a backup file | file_picker | 13.1.0 (2026-09-15) | Or restore only through the Android share intent |
| Invoice PDF | pdf | 3.13.1 (2026-09-19) | Or share invoices as plain text / an image of a widget |
| Backup/restore paths | path_provider | 2.1.6 (2026-06-15) | Already transitive through drift_flutter. Must be direct if we import it |
| Launcher icon / splash (dev only) | flutter_launcher_icons / flutter_native_splash | 0.14.4 / 2.4.8 | Build-time tools only |
| Lints | flutter_lints | 6.0.0 | Comes with `flutter create` |
| PIN hashing | crypto | transitive through uuid | Needed for a salted PIN hash |

### 1.3 Do third-party packages still import `package:flutter/material.dart`?

I downloaded each archive and grepped `lib/`:

| Package | Imports | Material dependency |
|---|---|---|
| flutter_bloc 9.1.1 / provider 6.1.5+1 | `widgets`, `foundation` | None |
| go_router 18.0.2 | `widgets`, plus **`material_ui`** and **`cupertino_ui`** in `pages/` | Already migrated. `MaterialPage` comes from material_ui, so it matches our types |
| drift_flutter 0.3.1, share_plus 13.3.1, local_auth 3.0.2 | No UI imports | None |
| **flutter_screenutil 5.9.3** | **`package:flutter/material.dart`** in `size_extension.dart`, `r_padding.dart`, `r_sizedbox.dart` | **Yes** |
| material_ui 1.5.0 itself | `flutter/material.dart as legacy`, but only in `migration_utility.dart` | Only for the bridge |

**Impact of flutter_screenutil:**
- Flutter 3.47.6 still ships `package:flutter/material.dart` (confirmed in the 3.47.6 source), so the package compiles. The app then contains two Material libraries: the legacy one in the framework and `material_ui`. A class like `ThemeData` from the legacy library is a different Dart type from `material_ui`'s `ThemeData`.
- I checked what screenutil actually uses from material.dart: `Padding`, `SizedBox`, `EdgeInsets`, `MediaQuery`. These are all widgets-layer classes that material.dart merely re-exports. It never calls `Theme.of`, `MaterialLocalizations.of`, or `Material` ancestors. So **no runtime mismatch**, no need for `MaterialUiCompatibilityBridge` (which is already `@Deprecated`), and the unused legacy widgets are tree-shaken.
- **How to handle it:** our own code never imports `flutter/material.dart`, enforced by an import-boundary test (section 2). We call screenutil only through `.w/.h/.r` (and maybe `.sp`) extensions in `core/`. We never use its `RPadding` / `RSizedBox` widgets. If a future screenutil release or Flutter version removes legacy material, we vendor the roughly 60 lines of extension math into `core/utils/sizing.dart`.
- Another risk: `ScreenUtil.textScaleFactor` reads the deprecated `MediaQueryData.textScaleFactor`. It still exists in 3.47.6 (line 434), but removal would break the build. See R6.

### 1.4 Material localization delegates with material_ui

- `material_ui` exports its **own** `GlobalMaterialLocalizations`, `MaterialLocalizations`, and the generated `ar` translations (`l10n/generated_material_localizations.dart`). Its `GlobalMaterialLocalizations.delegates` contains:
  `GlobalCupertinoLocalizations.delegate` (from cupertino_ui), `GlobalMaterialLocalizations.delegate` (material_ui), and `GlobalWidgetsLocalizations.delegate`.
- `material_ui` itself depends on `flutter_localizations` (SDK), but only for `GlobalWidgetsLocalizations` and date-symbol initialisation.
- **Trap found:** in Flutter 3.47.6, `flutter_localizations` **still exports the legacy** `GlobalMaterialLocalizations`. The gen_l10n template (`flutter_tools/.../gen_l10n_templates.dart`) still generates
  `AppLocalizations.localizationsDelegates = [delegate, GlobalMaterialLocalizations.delegate (legacy), …]`.
  If we use that list, material_ui widgets (date picker, dialogs, text-field tooltips) would not find a `material_ui.MaterialLocalizations`. They would fall back to the English defaults, which breaks Arabic.
- **Rule:**
  ```
  localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates /* material_ui */]
  ```
  `AppLocalizations.localizationsDelegates` is banned (checked in review and by a grep test).
  Still needed from `flutter_localizations`: the direct SDK dependency, because the generated `app_localizations.dart` imports it and `GlobalWidgetsLocalizations` lives there. Never import it next to `material_ui` in the same file, because the two `GlobalMaterialLocalizations` names would clash.

---

## 2. Folder structure

```
lib/
  main.dart                      # bootstrap: DI, runApp
  app.dart                       # MaterialApp.router (material_ui), theme, l10n, ScreenUtilInit
  core/
    database/
      app_database.dart          # @DriftDatabase, schemaVersion, migration, PRAGMAs
      tables/                    # one file per table (Drift Table classes)
      daos/                      # one DAO per aggregate (SalesDao, StockDao, LedgerDao, CountersDao…)
      converters/                # UtcMillisConverter, enum converters
      transaction_runner.dart    # interface + Drift impl used by repository impls
      schema_versions.dart       # generated by make-migrations (from v2 on)
    di/                          # get_it registration (service_locator.dart)
    router/                      # go_router config, route names
    theme/                       # ColorScheme.fromSeed(0xFF326CE9), text theme, RTL-safe spacing
    l10n/                        # arb/app_ar.arb (template), app_en.arb, generated/
    utils/                       # money.dart, quantity.dart, id.dart, clock.dart, arabic_normalize.dart, result.dart
    widgets/                     # shared widgets (MoneyText, QtyField, EmptyState, ConfirmDialog…)
  features/
    products/      {data,domain,presentation}   # products + categories
    inventory/     {data,domain,presentation}   # stock view, adjustments, movement history
    customers/     {data,domain,presentation}   # customers + customer ledger/statement + receipts
    suppliers/     {data,domain,presentation}   # suppliers + supplier ledger + payments
    sales/         {data,domain,presentation}   # POS, invoices, returns, voids, invoice sharing
    purchases/     {data,domain,presentation}
    expenses/      {data,domain,presentation}   # expenses + expense categories
    reports/       {data,domain,presentation}   # profit report
    backup/        {data,domain,presentation}   # export/restore
    settings/      {data,domain,presentation}   # shop profile, language, app lock, stock policy
    home/          {presentation}               # dashboard
test/
  architecture/import_rules_test.dart   # fails on forbidden imports (below)
  drift/                                 # generated migration tests (make-migrations)
  core/utils/…  features/<name>/…
drift_schemas/app_database/              # drift_schema_vN.json, committed
```

**Layer direction:** Screen → Cubit → Repository interface (`domain/`) → Repository impl (`data/`) → DAO (`core/database/daos`) → Drift.

- `domain/` holds pure Dart: entities (immutable, no Drift row types), repository interfaces, value objects, and pure calculators (pricing, discount allocation, WAC). It imports no Flutter and no Drift.
- `data/` holds repository impls and Drift-row↔entity mappers. This is the **only** layer outside `core/database` allowed to import DAOs or `TransactionRunner`.
- Cross-feature writes (a sale writes stock, the ledger and counters) run in **one** `TransactionRunner.run(() async {…})` inside `SalesRepositoryImpl`, which calls several DAOs.
- Tables and DAOs live in `core/database`, not in features. One Drift database must know every table, and a single transaction crosses feature boundaries.

**Enforced by `test/architecture/import_rules_test.dart`.** This is a plain Dart test that scans `lib/`, so no new package is needed. It fails when:
- any file imports `package:flutter/material.dart` or `package:flutter/cupertino.dart`;
- a `presentation/` or `domain/` file imports `drift`, `core/database/`, or another feature's `data/`;
- a `domain/` file imports `package:flutter/`;
- `AppLocalizations.localizationsDelegates` is used;
- a `.dart` file contains `double` inside `lib/features/*/domain` or `core/utils/money.dart` / `quantity.dart` (heuristic; reviewed manually).

---

## 3. Drift schema (v1, entire MVP)

### 3.0 Global conventions

- **PK:** `id TEXT NOT NULL PRIMARY KEY` holds a UUID v7 in canonical lowercase form (36 chars). Rows keep their implicit `rowid`. We never use `WITHOUT ROWID`, so `rowid` gives stable insertion order for replays.
- **Time:** every timestamp is `INTEGER` **UTC epoch milliseconds**, mapped to `DateTime` by `UtcMillisConverter`.
  I avoid Drift's default `dateTime()` because it stores whole seconds. ISO-text mode is also unsafe: `toIso8601String()` sometimes adds microseconds, which breaks lexicographic range queries.
  Report day boundaries are computed in local time (Africa/Cairo, which has DST) and converted to UTC.
- **Money:** `INTEGER`, name ends in `Piasters`. **Quantity:** `INTEGER`, name ends in `Milli`. No `REAL` column anywhere.
- **Enums:** `TEXT` with `CHECK (col IN (...))` (Drift `textEnum`). Renaming an enum value requires a migration.
- **Booleans:** `INTEGER 0/1` with CHECK (Drift default).
- **Mutable master tables:** `createdAt`, `updatedAt`, `archivedAt NULL`.
  **Immutable documents:** `createdAt`, plus `voidedAt NULL` and `voidReason NULL` where voiding applies. **Ledgers and movements are append-only:** no `voidedAt`, corrected only by reversing rows.
- **Search:** `searchKey TEXT` is the name normalised for Arabic. It removes tashkeel and tatweel, folds أإآ→ا, ة→ه, ى→ي, and converts digits to Latin. `core/utils/arabic_normalize.dart` computes it on write.
- **Safety at the DB layer:**
  - `PRAGMA foreign_keys = ON` and `PRAGMA journal_mode = WAL` in `beforeOpen` / `setup`.
  - `PRAGMA application_id = <fixed 32-bit int>`, used for restore checks.
  - Every FK is `ON DELETE RESTRICT`.
  - `BEFORE DELETE` triggers on **every** table `RAISE(ABORT)`: no hard deletes.
  - `BEFORE UPDATE` triggers on immutable tables `RAISE(ABORT)`. The one allowed update is `voidedAt`/`voidReason` going from `NULL` to set on voidable headers.
  - Triggers are created in `onCreate` and in migrations, and are covered by tests.
- **Limits (overflow safety, validated in domain):**
  - unit price/cost ≤ 1,000,000,000 piasters (10M EGP);
  - qty ≤ 1,000,000,000 milli (1M units);
  - largest product `qty × price` = 1e18, which is less than int64's 9.22e18.

### 3.1 Tables

**`app_settings`** holds shop configuration. It is a single typed row, not key/value, so it stays type-safe.

| Column | Type | Null | Notes |
|---|---|---|---|
| id | TEXT PK | no | UUID v7 |
| singleton | INTEGER | no | `DEFAULT 1 UNIQUE CHECK(singleton=1)`: enforces one row |
| shopName, shopPhone, shopAddress, invoiceFooter | TEXT | yes (name no) | Printed on shared invoices |
| localeCode | TEXT | no | `'ar'`/`'en'`, default `'ar'` |
| digitStyle | TEXT | no | `'arabic'`/`'latin'` (Q10) |
| negativeStockPolicy | TEXT | no | `CHECK IN ('warn','block')`, default `'warn'` |
| appLockEnabled, biometricEnabled | INTEGER bool | no | |
| pinHash, pinSalt | TEXT | yes | Salted hash, never plaintext (Q8) |
| deviceId | TEXT | no | UUID v7 generated once. Identifies the source for a future server copy |
| createdAt, updatedAt | INTEGER | no | `archivedAt` omitted: the row is never archived |

**`counters`** issues gap-free document numbers.

| Column | Type | Null | Notes |
|---|---|---|---|
| id | TEXT PK | no | |
| docType | TEXT | no | **UNIQUE**, `CHECK IN ('SALE','SALE_RETURN','PURCHASE','EXPENSE','CUSTOMER_RECEIPT','SUPPLIER_PAYMENT')` |
| nextValue | INTEGER | no | `CHECK(nextValue >= 1)`, starts at 1 |
| createdAt, updatedAt | INTEGER | no | No `archivedAt`: never archived |

The `onCreate` seed inserts one row per docType.

How numbers stay gap-free: allocation happens **inside the same write transaction** as the document insert:
`UPDATE counters SET nextValue = nextValue + 1, updatedAt = ? WHERE docType = ? RETURNING nextValue - 1`
(SQLite ≥ 3.35 supports `RETURNING`; the bundled sqlite3 is much newer).
- SQLite allows one writer, and Drift serialises transactions on one connection, so two documents can never get the same number.
- If anything later in the transaction throws, the rollback also undoes the increment, so no number is burned.
- Voided documents **keep** their number and show as voided. Numbers are never reused.
- Each document table also has `UNIQUE(number)` as a backstop.
- The display format (`S-000123`) is applied in the UI only.

**`categories`** groups products for browsing and filtering.
`id`, `name TEXT NOT NULL`, `searchKey TEXT NOT NULL`, `sortOrder INTEGER NOT NULL DEFAULT 0`, `createdAt`, `updatedAt`, `archivedAt`.
Index: partial `UNIQUE(searchKey) WHERE archivedAt IS NULL`.

**`products`** is the catalogue.

| Column | Type | Null | Notes |
|---|---|---|---|
| id | TEXT PK | no | |
| categoryId | TEXT FK→categories | yes | |
| name / searchKey | TEXT | no | |
| barcode | TEXT | yes | Partial `UNIQUE WHERE barcode IS NOT NULL AND archivedAt IS NULL` |
| sku | TEXT | yes | |
| unitType | TEXT | no | `CHECK IN ('piece','kg','liter','meter')`. `piece` requires qty to be a multiple of 1000 (Q11) |
| salePricePiasters | INTEGER | no | Price per **1 unit** (1000 milli). `CHECK >= 0` |
| avgCostPiasters | INTEGER | no | WAC per unit, `DEFAULT 0`, `CHECK >= 0`. **Cached state**, justified below |
| lowStockThresholdMilli | INTEGER | yes | |
| createdAt, updatedAt, archivedAt | INTEGER | no/no/yes | |

Indexes: `(categoryId)`, `(searchKey)`, `(archivedAt)`.

*Why `avgCostPiasters` is cached:* WAC depends on the path. It is the result of folding over every cost-bearing inbound movement in order, so it cannot be computed with a cheap `SUM`.
How it stays consistent:
1. The **only** writers are the inbound-movement code paths (opening stock, purchase, sale return, sale void, purchase void), and each runs inside the same transaction as its `stock_movements` row.
2. Each inbound movement stores its `unitCostPiasters` cost basis, so WAC can be rebuilt by replaying `stock_movements ORDER BY createdAt, rowid`. `InventoryRepository.rebuildAverageCosts()` exists for maintenance and tests.
3. A test property asserts that replay equals the stored value after random operation sequences.

**Stock is NOT cached.** It is computed as `SUM(qtyDeltaMilli) FROM stock_movements WHERE productId = ?` using the covering index `(productId, qtyDeltaMilli)`. A shop with about 100k movement rows aggregates that in milliseconds. If profiling later shows a problem, a `product_stock` cache maintained **by SQLite triggers** (so it cannot drift) can be added by migration.

**`customers`** / **`suppliers`** are counterparties.
`id`, `name`, `searchKey`, `phone TEXT NULL`, `address TEXT NULL`, `note TEXT NULL`, `createdAt`, `updatedAt`, `archivedAt`.
`customers` also has `creditLimitPiasters INTEGER NULL` (warning only, Q12).
Indexes: `(searchKey)`, `(phone)`.
Balances are **derived**: `SUM(amountPiasters)` from the ledger, with no cached column. The ledger index `(customerId, createdAt)` makes this cheap.
Opening balances are ledger rows of type `OPENING_BALANCE`, not a column.

**`expense_categories`**: `id`, `name`, `searchKey`, `createdAt`, `updatedAt`, `archivedAt`. Partial unique `(searchKey) WHERE archivedAt IS NULL`.

**`sales_invoices`** is the immutable sale header.

| Column | Type | Null | Notes |
|---|---|---|---|
| id | TEXT PK | no | |
| number | INTEGER | no | UNIQUE, from counter `SALE` |
| customerId | TEXT FK→customers | yes | NULL means walk-in |
| subtotalPiasters | INTEGER | no | Σ `sale_items.lineTotalPiasters` |
| discountPiasters | INTEGER | no | Invoice-level, `DEFAULT 0`, `CHECK 0 ≤ discount ≤ subtotal` |
| totalPiasters | INTEGER | no | `CHECK total = subtotal - discount` |
| paidAtSalePiasters | INTEGER | no | `CHECK 0 ≤ paid ≤ total` |
| note | TEXT | yes | |
| createdAt | INTEGER | no | Sale time, used by reports |
| voidedAt, voidReason | INTEGER / TEXT | yes | `CHECK ((voidedAt IS NULL) = (voidReason IS NULL))` |

Additional CHECK: `paidAtSalePiasters = totalPiasters OR customerId IS NOT NULL`. Credit and partial sales need a named customer.
The payment kind (cash/credit/partial) is **derived** (`paid = total` → cash, `paid = 0` → credit, otherwise partial) and never stored, so it cannot contradict the amounts.
Indexes: `(createdAt)`, `(customerId, createdAt)`, `(voidedAt)`.

**`sale_items`** are the immutable sale lines.

| Column | Type | Null | Notes |
|---|---|---|---|
| id | TEXT PK | no | |
| salesInvoiceId | TEXT FK | no | |
| lineNo | INTEGER | no | `UNIQUE(salesInvoiceId, lineNo)` |
| productId | TEXT FK | no | |
| productNameSnapshot | TEXT | no | Old invoices keep printing the name used at sale time |
| unitTypeSnapshot | TEXT | no | |
| qtyMilli | INTEGER | no | `CHECK > 0` |
| unitPricePiasters | INTEGER | no | `CHECK >= 0` |
| discountPiasters | INTEGER | no | Line-level, `DEFAULT 0`, `CHECK 0 ≤ d ≤ gross` |
| lineTotalPiasters | INTEGER | no | `round½↑(qty×price/1000) − discount` |
| invoiceDiscountSharePiasters | INTEGER | no | This line's share of the header discount (largest-remainder allocation). Makes partial returns and per-product profit exact |
| unitCostPiasters | INTEGER | no | **WAC snapshot at sale time** |
| lineCostPiasters | INTEGER | no | `round½↑(qty×unitCost/1000)`, the COGS for the line |

Indexes: `(salesInvoiceId)`, `(productId)`.
Net revenue of a line = `lineTotalPiasters − invoiceDiscountSharePiasters`.

**`sale_returns`** is the immutable return header.

| Column | Null | Notes |
|---|---|---|
| id, number (UNIQUE, counter `SALE_RETURN`) | no | |
| salesInvoiceId FK | no | |
| customerId FK | yes | Copied from the invoice |
| totalRefundPiasters | no | Σ item refunds |
| totalCostPiasters | no | Σ item costs (COGS reversal) |
| refundPaidPiasters | no | Cash handed back. `CHECK 0 ≤ x ≤ total`. Walk-in requires `x = total` (CHECK `x = total OR customerId IS NOT NULL`) |
| reason | yes | |
| createdAt | no | |

No `voidedAt`: returns are final in v1 (Q13).
Indexes: `(salesInvoiceId)`, `(createdAt)`.

**`sale_return_items`**: `id`, `saleReturnId FK`, `saleItemId FK`, `productId FK` (denormalised for indexing), `qtyMilli CHECK > 0`, `unitPricePiasters` and `unitCostPiasters` (copied from the sale item), `refundPiasters`, `costPiasters`, `createdAt`.
Indexes: `(saleItemId)`, `(saleReturnId)`.
**Defence in depth:** a `BEFORE INSERT` trigger aborts if `SUM(qtyMilli) for saleItemId + NEW.qtyMilli > sale_items.qtyMilli`. The repository checks first and the trigger guarantees it.

**`purchase_invoices`**: `id`, `number` (UNIQUE, counter `PURCHASE`), `supplierId FK NULL`, `supplierRef TEXT NULL` (the supplier's own invoice number), `invoiceDate INTEGER` (business date, may be in the past), `subtotalPiasters`, `discountPiasters`, `totalPiasters`, `paidPiasters`, `note`, `createdAt`, `voidedAt`, `voidReason`.
CHECKs mirror the sales header, including `paid = total OR supplierId IS NOT NULL`.
Indexes: `(invoiceDate)`, `(supplierId, invoiceDate)`.

**`purchase_items`**: `id`, `purchaseInvoiceId FK`, `lineNo`, `productId FK`, `qtyMilli > 0`, `unitCostPiasters`, `discountPiasters DEFAULT 0`, `lineTotalPiasters`, `invoiceDiscountSharePiasters`, `netLineCostPiasters` (= lineTotal − share, the amount that feeds WAC), `avgCostBeforePiasters`, `avgCostAfterPiasters` (audit trail and replay check), `createdAt`.
Indexes: `(purchaseInvoiceId)`, `(productId)`.

**`stock_movements`** is the append-only source of truth for stock.

| Column | Null | Notes |
|---|---|---|
| id | no | |
| productId FK | no | |
| movementType | no | `OPENING, PURCHASE, PURCHASE_VOID, SALE, SALE_RETURN, SALE_VOID, ADJUSTMENT` |
| qtyDeltaMilli | no | Signed, `CHECK != 0` |
| unitCostPiasters | no | Cost basis: snapshot cost for sales and returns, net cost for purchases, current WAC for adjustments |
| saleItemId / saleReturnItemId / purchaseItemId | yes | FKs. A CHECK requires the right one to be set for each type |
| reversesMovementId | yes | Self-FK, used by void reversals |
| reason / note | yes | Required for `ADJUSTMENT` (`damage`, `count`, `other`; Q14) |
| createdAt | no | |

Indexes: `(productId, qtyDeltaMilli)` covering for stock, `(productId, createdAt)` for history, and each source FK.

**`customer_ledger`** is append-only. Sign convention: **+ means the customer owes us more.**

| Column | Null | Notes |
|---|---|---|
| id, customerId FK | no | |
| entryType | no | `OPENING_BALANCE (±)`, `SALE (+)`, `PAYMENT_RECEIVED (−)`, `SALE_RETURN (−)`, `REFUND_PAID (+)`, `SALE_VOID (reversal)`, `ADJUSTMENT (±)`, `REVERSAL (±)` |
| amountPiasters | no | Signed, `CHECK != 0` |
| salesInvoiceId / saleReturnId | yes | FKs |
| receiptNumber | yes | From counter `CUSTOMER_RECEIPT`, standalone payments only. `UNIQUE WHERE NOT NULL` |
| reversesEntryId | yes | Self-FK. Cancelling a standalone payment means adding a `REVERSAL` row with a reason. Balance stays a plain `SUM` |
| note | yes | |
| createdAt | no | |

Indexes: `(customerId, createdAt)`, `(salesInvoiceId)`, `(saleReturnId)`.

**`supplier_ledger`** mirrors the customer ledger. **+ means we owe the supplier more.** Types: `OPENING_BALANCE`, `PURCHASE (+)`, `PAYMENT_MADE (−)`, `PURCHASE_VOID (reversal)`, `ADJUSTMENT`, `REVERSAL`. It has `purchaseInvoiceId FK NULL` and `paymentNumber` (counter `SUPPLIER_PAYMENT`).

**`expenses`** are immutable and voidable.
`id`, `number` (counter `EXPENSE`), `expenseCategoryId FK NOT NULL`, `amountPiasters CHECK > 0`, `spentAt INTEGER` (business date), `note`, `createdAt`, `voidedAt`, `voidReason`.
Editing means voiding and re-entering.
Indexes: `(spentAt)`, `(expenseCategoryId)`.

**Changes from your expected table list:** none removed, none added. I deliberately did **not** add a cash-drawer table or a sync/outbox table (Q15, Q16).

### 3.2 Weighted average cost

Applies to every **inbound movement that carries a cost**: OPENING, PURCHASE, SALE_RETURN, SALE_VOID, and the replay after PURCHASE_VOID. Outbound movements never change WAC. (Q9: confirm that returns re-enter at their snapshot cost.)

```
S  = current stock (milli)        before the movement
A  = current avgCostPiasters      (per 1 unit)
q  = inbound qty (milli) > 0
C  = inbound total cost (piasters) for q   (purchase: netLineCostPiasters;
                                            return/void: q × unitCost / 1000 rounded,
                                            opening: q × enteredUnitCost / 1000 rounded)

if S <= 0:   A' = roundHalfUp(C × 1000, q)                  # no cost basis left
else:        A' = roundHalfUp(S × A + C × 1000, S + q)

roundHalfUp(n, d)  (n ≥ 0, d > 0) = (2n + d) ~/ (2d)
```

- Units: `S×A` is milli·piasters/unit and `C×1000` is piasters·milli/q. Divided by milli, both give piasters/unit.
- Using the line **total** `C`, not a rounded per-unit cost, avoids compounding rounding loss.
- **Zero or negative stock:** if the shop sold stock it had not recorded (S < 0), those units already left at the old A snapshot, and sales are immutable. The incoming batch therefore sets A' = its own unit cost. Units that "fill the hole" are not retroactively re-costed. This is a known accounting limitation and will be documented in-app as "costs may be inaccurate after selling unrecorded stock".
- Overflow: S, q ≤ 1e9 and A ≤ 1e9, so S×A ≤ 1e18. Adding C×1000 needs C ≤ ~8e15, which validation guarantees.

### 3.3 Discount allocation (largest remainder)

`allocate(total D, weights w_i = lineTotal_i)` works like this:
- `share_i = floor(D × w_i / Σw)`.
- The leftover piasters go one each to the largest fractional remainders. Ties go to the lower `lineNo`.
- Σshare = D exactly. Deterministic.

### 3.4 make-migrations from v1

`build.yaml` (Phase 2):
```yaml
targets:
  $default:
    builders:
      drift_dev:
        options:
          databases:
            app_database: lib/core/database/app_database.dart
          schema_dir: drift_schemas/
          test_dir: test/drift/
          sql:
            dialect: sqlite
            options:
              version: "3.45"     # lets drift analyze RETURNING, partial indexes
```
Workflow:
1. **v1:** after the first `build_runner build`, run `dart run drift_dev make-migrations`. It exports `drift_schemas/app_database/drift_schema_v1.json` and scaffolds `test/drift/app_database/migration_test.dart`. Commit both.
2. **Every schema change:**
   - edit the tables;
   - bump `schemaVersion`;
   - run `dart run drift_dev make-migrations`, which exports vN and generates `schema_versions.dart` with `stepByStep` helpers plus a test for each version pair;
   - implement `onUpgrade: stepByStep(from1To2: …)`;
   - run the generated migration tests and the data-integrity tests;
   - commit the schema JSON, the generated code, and the migration together.
3. A schema-JSON file is **never** edited by hand. A failing generated migration test blocks merging.
4. Triggers and partial indexes live in Drift `@TableIndex.sql` / `customStatement` and are re-created in the migration step that changes them.

I will confirm the exact output paths and file names against drift_dev 2.35.1 when Phase 2 runs.

---

## 4. Critical flows (each one = ONE `transaction`)

Common pre-step: validate input in the domain layer first (pure). Then the repository impl opens the transaction, re-reads the state it depends on, and re-validates. Any throw rolls back everything.

### 4.1 Sale (cash / credit / partial)

```
input: lines[{productId, qtyMilli, unitPricePiasters, lineDiscountPiasters}], invoiceDiscountPiasters,
       paidPiasters, customerId?, note?, shortageAcknowledged: bool
TX:
  for each distinct productId:
      p     = SELECT product WHERE id AND archivedAt IS NULL          (else ProductUnavailable)
      stock = SELECT SUM(qtyDeltaMilli) FROM stock_movements WHERE productId
      need  = Σ qtyMilli of lines for this product
      if need > stock:
          if settings.negativeStockPolicy == 'block'  -> throw InsufficientStock(details)
          if !shortageAcknowledged                    -> throw StockShortageNeedsConfirmation(details)
  compute per line: gross = roundHalfUp(qty*price, 1000); lineTotal = gross - lineDiscount
                    unitCost = p.avgCostPiasters; lineCost = roundHalfUp(qty*unitCost, 1000)
  subtotal = Σ lineTotal; total = subtotal - invoiceDiscount; shares = allocate(invoiceDiscount, lineTotals)
  check 0 <= paid <= total; if paid < total require customerId (not archived)
  number = UPDATE counters ... 'SALE' RETURNING                                   -- W1
  INSERT sales_invoices                                                           -- W2
  INSERT sale_items × n                                                           -- W3
  INSERT stock_movements × n  (SALE, -qty, unitCost snapshot, saleItemId)         -- W4
  if customerId:
      INSERT customer_ledger (SALE, +total, salesInvoiceId)                       -- W5
      if paid > 0: INSERT customer_ledger (PAYMENT_RECEIVED, -paid, salesInvoiceId)  -- W6
```
The two policies are enforced by the same code path, with the setting selecting one. The UI catches `StockShortageNeedsConfirmation`, shows the warning, and resubmits with `shortageAcknowledged = true`. (Q17: should a cash sale with a named customer write W5+W6, which net to zero, so the statement shows the purchase? Proposed: yes.)

### 4.2 Purchase

```
input: supplierId?, supplierRef?, invoiceDate, lines[{productId, qtyMilli, unitCostPiasters, lineDiscount}],
       invoiceDiscount, paidPiasters, note?
TX:
  validate products exist & not archived; paid <= total; paid < total requires supplierId
  compute lineTotal, shares = allocate(invoiceDiscount, lineTotals), netLineCost = lineTotal - share
  number = next counter 'PURCHASE'                                                -- W1
  INSERT purchase_invoices                                                        -- W2
  for each line in lineNo order (same product twice -> applied sequentially):
      S = SUM(stock_movements.qtyDeltaMilli) for productId   (includes earlier lines of this TX)
      A = products.avgCostPiasters
      A' = WAC(S, A, qty, netLineCost)
      INSERT purchase_items (avgCostBefore=A, avgCostAfter=A')                    -- W3
      INSERT stock_movements (PURCHASE, +qty, unitCost=roundHalfUp(netLineCost*1000, qty), purchaseItemId) -- W4
      UPDATE products SET avgCostPiasters=A', updatedAt=now WHERE id              -- W5
  if supplierId:
      INSERT supplier_ledger (PURCHASE, +total, purchaseInvoiceId)                -- W6
      if paid > 0: INSERT supplier_ledger (PAYMENT_MADE, -paid, purchaseInvoiceId) -- W7
```
Optional W8: `UPDATE products.salePricePiasters` if the user edits the sale price on the purchase screen (UI decision).

### 4.3 Sale return (partial or full)

```
input: salesInvoiceId, lines[{saleItemId, qtyMilli}], refundPaidPiasters, reason?
TX:
  inv = SELECT sales_invoices WHERE id; reject if voidedAt IS NOT NULL
  for each line:
      si = SELECT sale_items WHERE id AND salesInvoiceId = inv.id               (else InvalidLine)
      returnedQty, refundedSoFar, costSoFar = SELECT SUM(qtyMilli), SUM(refundPiasters), SUM(costPiasters)
                                              FROM sale_return_items WHERE saleItemId = si.id
      remaining = si.qtyMilli - returnedQty
      require 0 < qty <= remaining
      net = si.lineTotalPiasters - si.invoiceDiscountSharePiasters
      if qty == remaining:  refund = net - refundedSoFar;  cost = si.lineCostPiasters - costSoFar   # exact closure
      else:                 refund = roundHalfUp(net*qty, si.qtyMilli); cost = roundHalfUp(si.lineCostPiasters*qty, si.qtyMilli)
  total = Σ refund; require 0 <= refundPaid <= total; if inv.customerId IS NULL require refundPaid == total
  number = next counter 'SALE_RETURN'                                             -- W1
  INSERT sale_returns                                                             -- W2
  INSERT sale_return_items × n   (trigger re-checks the qty ceiling)              -- W3
  for each item: S, A = current; A' = WAC(S, A, qty, cost)
      INSERT stock_movements (SALE_RETURN, +qty, unitCost=si.unitCostPiasters, saleReturnItemId)  -- W4
      UPDATE products SET avgCostPiasters = A'                                    -- W5 (if Q9 = yes)
  if inv.customerId:
      INSERT customer_ledger (SALE_RETURN, -total, saleReturnId)                  -- W6
      if refundPaid > 0: INSERT customer_ledger (REFUND_PAID, +refundPaid, saleReturnId)  -- W7
```
A "full return" is the same flow with every line at `qty = remaining`. Because of the exact-closure rule, the sum of all returns equals the invoice net exactly.

### 4.4 Void sales invoice

```
input: salesInvoiceId, reason (required, non-empty)
TX:
  inv = SELECT sales_invoices WHERE id
  reject if inv.voidedAt IS NOT NULL                       (AlreadyVoided)
  reject if EXISTS(SELECT 1 FROM sale_returns WHERE salesInvoiceId = inv.id)   (HasReturns)
  UPDATE sales_invoices SET voidedAt=now, voidReason=? WHERE id=? AND voidedAt IS NULL   -- W1 (assert 1 row)
  for each m in SELECT stock_movements WHERE saleItemId IN (items of inv):
      S, A = current; A' = WAC(S, A, -m.qty, roundHalfUp(-m.qty*m.unitCost, 1000))
      INSERT stock_movements (SALE_VOID, +|m.qty|, m.unitCost, saleItemId, reversesMovementId=m.id)  -- W2
      UPDATE products SET avgCostPiasters = A'                                    -- W3 (if Q9 = yes)
  for each e in SELECT customer_ledger WHERE salesInvoiceId = inv.id:
      INSERT customer_ledger (SALE_VOID, -e.amount, salesInvoiceId, reversesEntryId=e.id)          -- W4
```
The counter is untouched and the number stays visible as "voided". Cash taken at the sale is assumed handed back (no cash drawer, Q15). Purchase void is analogous (Q18): reverse movements and supplier-ledger rows, then **rebuild WAC by replay** for the affected products, because a later purchase may already be blended in.

### 4.5 Profit report `[from, to)` (local days → UTC ms)

```
S  = sales_invoices  WHERE voidedAt IS NULL AND createdAt in range
R  = sale_returns    WHERE createdAt in range            (returns of voided invoices cannot exist)
E  = expenses        WHERE voidedAt IS NULL AND spentAt in range

grossSales      = Σ sale_items.lineTotalPiasters   over S
invoiceDiscount = Σ S.discountPiasters
returns         = Σ R.totalRefundPiasters
netSales        = grossSales − invoiceDiscount − returns
COGS            = Σ sale_items.lineCostPiasters over S − Σ R.totalCostPiasters
grossProfit     = netSales − COGS
expenses        = Σ E.amountPiasters
netProfit       = grossProfit − expenses
```
These are 4 aggregate SELECTs, read-only, in one transaction so the snapshot is consistent. Returns count in the period **in which they happen**, not the period of the original sale (Q19). Stock adjustments (damage/loss) are **not** in this formula, as specified. Q14 asks whether to show them as a separate line.

---

## 5. Core utilities (signatures only)

```dart
// core/utils/money.dart
const int piastersPerPound = 100;
int  roundHalfUpDiv(int numerator, int denominator);         // half away from zero; denominator > 0
int  lineTotalPiasters(int qtyMilli, int unitPricePiasters); // roundHalfUpDiv(qty*price, 1000)
List<int> allocateLargestRemainder(int total, List<int> weights);
int  weightedAverageCost({required int stockMilli, required int avgCostPiasters,
                          required int inQtyMilli, required int inTotalCostPiasters});
int? tryParsePiasters(String input, {bool allowNegative = false}); // accepts ٠-٩, ۰-۹, 0-9; "٫" "." decimal; "٬" "," grouping; ≤ 2 decimals
String formatPiasters(int piasters, {required Locale locale, DigitStyle digits = DigitStyle.locale,
                      bool withCurrency = true});            // "١٬٢٣٤٫٥٠ ج.م" / "EGP 1,234.50"
String normalizeDigits(String input);                        // Arabic-Indic/Persian -> Latin

// core/utils/quantity.dart
const int milliPerUnit = 1000;
enum UnitType { piece, kg, liter, meter }                    // + allowsFraction, maxDecimals (0 or 3)
int? tryParseQuantityMilli(String input, UnitType unit);     // rejects fractions for piece
String formatQuantityMilli(int milli, UnitType unit, {required Locale locale, DigitStyle digits = DigitStyle.locale});

// core/utils/id.dart
abstract interface class IdGenerator { String newId(); }     // UUID v7, lowercase canonical
final class UuidV7Generator implements IdGenerator { const UuidV7Generator(); @override String newId(); }

// core/utils/clock.dart  (added, so tests control time)
abstract interface class Clock { DateTime nowUtc(); }
```

---

## 6. Backup readiness

### 6.1 Where drift_flutter puts the DB (verified in `drift_flutter 0.3.1/lib/src/native.dart`)

- By default it opens `p.join(await getApplicationDocumentsDirectory(), '$name.sqlite')`. On Android that is `/data/user/0/com.ahmedmaher.daftarafandi/app_flutter/<name>.sqlite`, which is backup domain **`root`**, path `app_flutter/`.
- `DriftNativeOptions(databaseDirectory: …)` or `databasePath` can override this.
- It sets `sqlite3.tempDirectory` to `getTemporaryDirectory()`, which is the cache dir.
- It does **not** enable WAL. We set it ourselves.

**Proposal (Q20):**
```
driftDatabase(name: 'daftar_afandi', native: DriftNativeOptions(databaseDirectory: getApplicationSupportDirectory))
```
This gives Android `files/daftar_afandi.sqlite` (domain **`file`**). On iOS it uses Application Support instead of user-visible Documents. The XML below assumes this choice. With the default instead, replace `domain="file" path="…"` with `domain="root" path="app_flutter/…"`.

### 6.2 `android/app/src/main/res/xml/data_extraction_rules.xml` (API 31+)
```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup disableIfNoEncryptionCapabilities="false">
        <include domain="file" path="daftar_afandi.sqlite" />
        <include domain="file" path="daftar_afandi.sqlite-wal" />
        <!-- -shm is a transient WAL index; SQLite rebuilds it. Cache is excluded implicitly:
             once <include> is used, only listed paths are backed up, and the cache domain is never backed up. -->
    </cloud-backup>
    <device-transfer>
        <include domain="file" path="daftar_afandi.sqlite" />
        <include domain="file" path="daftar_afandi.sqlite-wal" />
    </device-transfer>
</data-extraction-rules>
```

### 6.3 `android/app/src/main/res/xml/full_backup_content.xml` (API ≤ 30)
```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="file" path="daftar_afandi.sqlite" />
    <include domain="file" path="daftar_afandi.sqlite-wal" />
</full-backup-content>
```
Manifest `<application>` gets:
`android:allowBackup="true" android:fullBackupContent="@xml/full_backup_content" android:dataExtractionRules="@xml/data_extraction_rules"`.

Consistency of the main file and the `-wal` file: on `AppLifecycleState.paused`, run `PRAGMA wal_checkpoint(TRUNCATE)`, so the WAL file is normally empty when the OS takes a snapshot (R3).

### 6.4 Schema version and restore guard

- Drift stores `schemaVersion` in **`PRAGMA user_version`**. We also set **`PRAGMA application_id`** to a fixed constant on create.
- **Manual backup (export):** `VACUUM INTO '<cache>/backup_<ts>.sqlite'` produces a single consistent file with no WAL, which is then shared or saved.
- **Restore (future milestone):**
  1. Open the candidate file read-only on a separate connection.
  2. Check `application_id` matches.
  3. Check `user_version ≤ AppDatabase.schemaVersion`. A **newer** version is rejected with "backup made by a newer app version".
  4. Check `PRAGMA integrity_check = 'ok'` and `foreign_key_check` is empty.
  5. Close the live DB and checkpoint it.
  6. Keep the current file as `*.pre-restore`.
  7. Copy in the candidate and reopen. Drift `onUpgrade` migrates older versions.

---

## 7. Repo setup

### 7.1 Draft `CLAUDE.md`

```markdown
# دفتر أفندي — Daftar Afandi

Offline, single-device accounting for small Egyptian retail shops. Arabic-first (RTL) + English. EGP only, no tax.
The on-device SQLite DB is the source of truth. NO network code (no dio/http/Firebase). Schema must stay sync-ready.

## Hard rules
- NEVER commit. NEVER add, remove or upgrade a package without asking first. Never pick a version < 14 days old.
- Import `package:material_ui/material_ui.dart`, NEVER `package:flutter/material.dart` or `cupertino.dart`.
- Localization delegates: `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]` (material_ui).
  NEVER `AppLocalizations.localizationsDelegates`. Never import flutter_localizations in the same file as material_ui.
- State: flutter_bloc Cubits only. DI: get_it. Routing: go_router. DB: drift.
  Forbidden: dio, Firebase, Hive, Isar, Riverpod/Provider-as-state/GetX/MobX, any other state management.

## Architecture
Feature-first: `lib/core/{database,di,router,theme,l10n,utils,widgets}`, `lib/features/<name>/{data,domain,presentation}`.
Direction (strict): Screen -> Cubit -> Repository interface (domain) -> Repository impl (data) -> DAO -> Drift.
- Screens/Cubits never import drift, `core/database`, DAOs or another feature's `data/`.
- `domain/` is pure Dart: no Flutter, no Drift row classes. Map rows <-> entities in `data/`.
- Every multi-table write runs in ONE transaction via `TransactionRunner` inside a repository impl.
- `test/architecture/import_rules_test.dart` must pass.

## Data rules
- PKs: UUID v7 TEXT via `IdGenerator`. Time: UTC epoch ms INTEGER via `Clock` + `UtcMillisConverter`.
- Money: int piasters (1 EGP = 100), column/field names end with `Piasters`. Quantity: int milli (1 unit = 1000), names end with `Milli`.
  NO `double` for money or quantity anywhere — not in DB, domain, cubit state, or formatting input.
- Line total = roundHalfUpDiv(qtyMilli * unitPricePiasters, 1000). Use helpers in core/utils/money.dart; never inline rounding.
- Mutable tables: createdAt, updatedAt, archivedAt (soft delete). Immutable docs: createdAt (+ voidedAt/voidReason).
  Ledgers & stock movements are append-only; corrections are reversing rows. No hard deletes (DB triggers enforce).
- Stock = SUM(stock_movements). Balances = SUM(ledger). Only cached value: products.avgCostPiasters (WAC), written
  only by inbound-movement paths in the same transaction; rebuildable by replay.
- Sales invoices are immutable; corrections only by return or void. Void forbidden if returns exist.
- Document numbers come from `counters` inside the same transaction as the insert (gap-free).
- Schema change = bump schemaVersion + `dart run drift_dev make-migrations` + stepByStep migration + passing migration tests.

## UI rules
- RTL-safe: EdgeInsetsDirectional / AlignmentDirectional / start/end, never left/right.
- flutter_screenutil (design 420x812) for sizes only; never disable or clamp system text scaling. Test at 200% text scale.
- All user-visible strings in ARB (app_ar.arb is the template). Format money/qty only via core/utils.

## Review checklist (run before presenting any change)
- [ ] No `flutter/material.dart` / `cupertino.dart` import; no forbidden package.
- [ ] Layer direction respected; no Drift types above `data/`.
- [ ] No `double` for money/qty; names end in `Piasters` / `Milli`; rounding via helpers.
- [ ] Every multi-write flow is in one transaction; every write listed in the PR description.
- [ ] No hard delete; immutable rows not updated (except void fields).
- [ ] Schema change has bumped version, exported schema JSON, migration + generated tests.
- [ ] New strings in both ARB files; RTL + 200% text scale checked; Arabic & Latin digit input works.
- [ ] Cubit tests (bloc_test + mocktail) and repository tests on in-memory drift (`NativeDatabase.memory()`).
- [ ] `flutter analyze` clean, `flutter test` green.
- [ ] Nothing committed; no package added without approval.
```

### 7.2 Release signing plan
- Upload keystore lives **outside the repo**, at `%USERPROFILE%\.keystores\daftar-afandi-upload.jks`. Two offline backups (e.g. an encrypted USB drive and a password manager attachment).
- `android/key.properties` (**gitignored**) contains `storePassword`, `keyPassword`, `keyAlias=upload`, and `storeFile=<absolute path above>`.
- `android/app/build.gradle.kts` loads `key.properties` if it exists and defines `signingConfigs.release`.
  A `release` build **fails** when the file is missing; it never silently falls back to debug signing.
- Play App Signing enabled: Google holds the app signing key, and we hold only the upload key, which can be reset if lost.
- Commit `android/key.properties.example` with placeholder values.

### 7.3 Proposed `.gitignore`
```gitignore
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
coverage/
*.iml
.idea/
.vscode/*
!.vscode/settings.json
!.vscode/extensions.json
.metadata.local

# Android
android/.gradle/
android/.kotlin/
android/local.properties
android/key.properties
android/app/release/
android/app/debug/
android/captures/
**/*.jks
**/*.keystore
*.hprof

# iOS / macOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Generated.xcconfig
ios/Flutter/flutter_export_environment.sh
ios/Flutter/ephemeral/
ios/Runner.xcworkspace/xcuserdata/
**/xcuserdata/
**/DerivedData/

# Local data / secrets
*.sqlite
*.sqlite-wal
*.sqlite-shm
*.db
.env
.env.*

# OS
.DS_Store
Thumbs.db
```
`pubspec.lock` **is committed** (this is an app). `drift_schemas/` is committed. Whether `*.g.dart` is committed is Q21.

---

## 8. Risks and open questions

### Risks
- **R1. Toolchain mismatch.** Flutter 3.44.1 is installed. Nothing in the stack resolves until you upgrade (Q1).
- **R2. Two Material libraries.** The legacy `flutter/material.dart` still ships in 3.47 and flutter_screenutil imports it. The type mixing is harmless today (verified), but it could break silently if we ever use one of its Material-dependent widgets. The import test and the "extensions only" rule mitigate this.
- **R3. Auto Backup snapshot of main + `-wal`.** Taken at an arbitrary moment, the two files could be inconsistent. Checkpointing on pause reduces the risk. I have not verified whether Android stops the app process during Auto Backup, and will check in Phase 2. Auto Backup also has a 25 MB quota. A restored device gets the DB silently, without our version check (only manual restores go through 6.4).
- **R4. gen_l10n still emits legacy delegates.** A future refactor could easily reintroduce them. A test guards against it.
- **R5. Negative stock and WAC.** Selling unrecorded stock makes COGS inaccurate for those units. This is inherent to "warn, don't block".
- **R6. flutter_screenutil 5.9.3 is unmaintained.** It reads the deprecated `MediaQueryData.textScaleFactor`, which would break the build if removed. Its `.sp` scales by **width** on top of system text scaling, so large text on small phones may overflow. Proposal: do **not** use `.sp` for fonts; use theme sizes in logical pixels so system scaling applies once. Test at 200%.
- **R7. Device clock changes.** `createdAt` comes from a user-settable clock, so ordering and report ranges can be wrong after clock changes. WAC replay uses `(createdAt, rowid)`, and we could fall back to `rowid` only.
- **R8. PIN in the DB.** The hash and salt go into backups, and offline brute force of a 4–6 digit PIN is trivial. This is acceptable only because the app lock is a "nosy-person" barrier, not encryption. Encryption (SQLCipher) would be a separate decision.
- **R9. Sync later.** Voiding mutates a header row (`voidedAt`), so a one-way copy cannot rely on append-only diffs alone. It will need `updatedAt` on voidable headers or a change-log table added by migration (Q16).
- **R10. Transitive packages too new** (sqlite3, cupertino_ui). See Q3.

### Open questions (I have not guessed any of these)
1. **Q1.** Upgrade to 3.47.6 (respects the 14-day rule) or 3.47.7 (current stable)? Do you want me to run the upgrade, or will you?
2. **Q2.** Pin direct dependencies **exactly** (no `^`) for all packages, or only material_ui?
3. **Q3.** May I use `dependency_overrides` to hold `sqlite3` at 3.7.0 and `cupertino_ui` at 1.1.1? Or accept transitive versions newer than 14 days?
4. **Q4.** Which extra packages are approved: share_plus, local_auth, file_picker, pdf, path_provider (direct), flutter_launcher_icons, flutter_native_splash, flutter_lints, crypto (direct)? Is `equatable` wanted, or should Cubit states use hand-written `==` / records?
5. **Q5.** Minimum Android SDK (it affects whether `full_backup_content.xml` matters)? Is iOS in scope for the MVP?
6. **Q6.** Should invoice sharing produce a PDF, an image, or WhatsApp-friendly text? Printer support (Bluetooth thermal) now or later?
7. **Q7.** Should backup/restore in the MVP be manual export plus import of a `.sqlite` file, or Auto Backup only? Where are exports saved (share sheet vs Downloads)?
8. **Q8.** App lock: PIN only, biometric with PIN fallback, or both? What PIN length? What lock timeout after backgrounding?
9. **Q9.** Should returns and voids re-enter stock at the **original snapshot cost** and blend into WAC (proposed), or at the current WAC (no WAC change)?
10. **Q10.** Digit display: follow the locale (`ar` → Arabic-Indic), or let the user choose? Currency label: `ج.م`, `جنيه`, or `EGP` in Arabic UI?
11. **Q11.** Is the unit list `piece, kg, liter, meter` enough? Do you need packs/cartons with conversion (e.g. carton = 12 pieces)? That would add a `product_units` table.
12. **Q12.** Customer credit limit: should exceeding it warn, block, or not exist?
13. **Q13.** Can a sale return be voided or cancelled (proposed: no in v1)?
14. **Q14.** Stock adjustments (damage, count corrections): in scope for the MVP? Should losses appear in the profit report as a separate line?
15. **Q15.** Cash-drawer / treasury tracking (cash in hand, daily close)? Not in the MVP list, so not designed.
16. **Q16.** For the future server copy: add `updatedAt` to voidable headers now, or add a change-log table later by migration?
17. **Q17.** Cash sale with a named customer: write SALE + PAYMENT ledger rows (net zero) so it shows on their statement?
18. **Q18.** Can **purchase** invoices be voided? If so, is WAC rebuilt by replay acceptable? Are purchase returns (to supplier) in the MVP?
19. **Q19.** Should returns count in the period they occur (proposed) or reduce the original sale's period?
20. **Q20.** DB location: `getApplicationSupportDirectory()` (proposed) or drift_flutter's default Documents directory?
21. **Q21.** Commit generated `*.g.dart` files (builds without codegen, schema diffs visible), or gitignore them?
22. **Q22.** Should document numbers reset yearly (e.g. `2026-000123`) or run forever? Are prefixes per document type wanted?
23. **Q23.** Payment methods beyond cash (Vodafone Cash, InstaPay, card)? If so, ledger and payment rows need a `method` column.
24. **Q24.** Should old documents on the profit report and invoices show the product name at sale time (`productNameSnapshot`, proposed) or the current name?

**STOP: waiting for your approval before Phase 2.**
