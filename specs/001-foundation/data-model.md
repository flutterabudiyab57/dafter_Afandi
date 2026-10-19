# Data Model: Foundation (001), schema v1

Source: report §3, amended by M0-DECISIONS (Q8, Q12, Q14, Q16, Q18, Q22–Q24) and the spec
(FR-002, FR-006, FR-011, FR-014). Only `app_settings` is used by screens in this feature. Every other
table exists now so that later features add no restructuring (FR-014).

## Conventions (all tables)

- `id TEXT PRIMARY KEY NOT NULL`: UUID v7, lowercase, 36 chars (`IdGenerator`). The implicit `rowid` is
  kept (never `WITHOUT ROWID`), so replays have a stable order.
- Times: `INTEGER` UTC epoch ms (`UtcMillisConverter`). Money: `INTEGER …Piasters`. Quantity:
  `INTEGER …Milli`. No `REAL` column exists.
- Enums: `TEXT` with `CHECK (col IN (…))`. Booleans: `INTEGER` 0/1 with CHECK.
- FKs: `ON DELETE RESTRICT`. `PRAGMA foreign_keys = ON` on every connection.
- `PRAGMA application_id = kAppApplicationId` (`0x44414641`, "DAFA") is set in `onCreate`;
  `user_version` = `kSchemaVersion` = 1. Journal mode is the SQLite default rollback journal
  (research R3, approval A1).
- `searchKey`: `arabicNormalize(name)` computed on write. It removes tashkeel and tatweel, folds
  أإآ→ا, ة→ه, ى→ي, maps digits to Latin, lowercases Latin, and collapses spaces.
- Table classes:

| Class | Tables | UPDATE | DELETE |
|---|---|---|---|
| Singleton/config | app_settings, counters | allowed | blocked |
| Mutable master | categories, products, customers, suppliers, expense_categories | allowed; archive via `archivedAt` | blocked |
| Voidable header | sales_invoices, purchase_invoices, expenses | only `voidedAt`, `voidReason`, `updatedAt`, once, NULL → set | blocked |
| Immutable | sale_items, sale_returns, sale_return_items, purchase_items, stock_movements, customer_ledger, supplier_ledger | blocked | blocked |

## Value domains

| Name | Values |
|---|---|
| LocaleCode | `ar`, `en` |
| DigitStylePreference | `follow`, `arabic`, `latin` |
| NegativeStockPolicy | `warn`, `block` |
| UnitType | `piece`, `kg`, `liter`, `meter`; `piece` qty must be a multiple of 1000 |
| PaymentMethod | `cash`, `wallet`, `instapay`, `card` (MVP UI shows the first three) |
| DocType | `SALE`, `SALE_RETURN`, `PURCHASE`, `EXPENSE`, `CUSTOMER_RECEIPT`, `SUPPLIER_PAYMENT` |
| MovementType | `OPENING`, `PURCHASE`, `PURCHASE_VOID`, `SALE`, `SALE_RETURN`, `SALE_VOID`, `ADJUSTMENT` |
| AdjustmentReason | `damage`, `count`, `other` |
| CustomerEntryType | `OPENING_BALANCE`, `SALE`, `PAYMENT_RECEIVED`, `SALE_RETURN`, `REFUND_PAID`, `SALE_VOID`, `ADJUSTMENT`, `REVERSAL` |
| SupplierEntryType | `OPENING_BALANCE`, `PURCHASE`, `PAYMENT_MADE`, `PURCHASE_VOID`, `ADJUSTMENT`, `REVERSAL` |

Display prefixes `S-`, `R-`, `P-`, `E-`, `RC-`, `PY-` are UI-only and never stored (Q22).

---

## Used by this feature

### app_settings (singleton)

| Column | Type | Null | Rule |
|---|---|---|---|
| id | TEXT PK | no | |
| singleton | INTEGER | no | `DEFAULT 1 UNIQUE CHECK (singleton = 1)` |
| shopName | TEXT | yes | NULL until first run completes |
| shopPhone | TEXT | yes | normalized: optional `+`, then 7–15 Latin digits; `CHECK (shopPhone IS NULL OR shopPhone GLOB '[+0-9]*')` |
| shopAddress, invoiceFooter | TEXT | yes | for invoice sharing later; no UI now |
| localeCode | TEXT | no | LocaleCode, `DEFAULT 'ar'` |
| digitStyle | TEXT | no | DigitStylePreference, `DEFAULT 'follow'` |
| negativeStockPolicy | TEXT | no | `DEFAULT 'warn'` |
| appLockEnabled, biometricEnabled | INTEGER bool | no | `DEFAULT 0` (feature: app lock) |
| deviceId | TEXT | no | UUID v7 generated once at create |
| onboardingCompletedAt | INTEGER | yes | NULL means first run is not finished |
| createdAt, updatedAt | INTEGER | no | |

Table CHECK: `onboardingCompletedAt IS NULL OR (shopName IS NOT NULL AND length(trim(shopName)) BETWEEN 1 AND 60)`.

Amendments vs report: `pinHash` and `pinSalt` removed (Q8, they live in flutter_secure_storage later);
`digitStyle` gains `follow` (spec); `shopName` becomes nullable, guarded by
`onboardingCompletedAt`; `onboardingCompletedAt` is added.

Seed (`onCreate`): one row with defaults, `shopName` NULL, `onboardingCompletedAt` NULL.

Lifecycle:

```
created (seed) ──setLocale/setDigitStyle──▶ created
created ──completeOnboarding(profile)──▶ onboarded   (one TX: shopName, shopPhone, onboardingCompletedAt, updatedAt)
onboarded ──saveShopProfile/setLocale/setDigitStyle──▶ onboarded
```

`onboardingCompletedAt` is never reset in this feature.

### Domain entities (pure Dart, `features/settings/domain`)

- **ShopProfile** {name: String, phone: String?}. Created only via
  `ShopProfile.create(rawName, rawPhone) → Result<ShopProfile, ShopProfileError>`.
  - Errors: `nameRequired`, `nameTooLong`, `phoneInvalidCharacters`, `phoneTooShort`, `phoneTooLong`.
  - Name: trim; 1–60 code points.
  - Phone: empty becomes null; strip spaces and `-`; `normalizeDigits`; optional single leading `+`;
    7–15 digits.
- **AppSettings** {locale: AppLocale, digitStyle: DigitStylePreference, shop: ShopProfile?,
  onboardingCompleted: bool}. `effectiveDigitStyle` resolves `follow` from the locale.
- **AppVersion** {name: "1.0.0", build: "1"}, read once from package_info_plus.
  `display` = `"1.0.0 (1)"`, always Latin.

---

## Prepared for later features (created in v1, no screens yet)

### counters

`id`, `docType` (DocType, **UNIQUE**), `nextValue INTEGER CHECK (nextValue >= 1)`, `createdAt`, `updatedAt`.
The seed adds 6 rows, each with `nextValue = 1`. Numbers are allocated inside the document's transaction
with `UPDATE … SET nextValue = nextValue + 1 … RETURNING nextValue - 1`. They run forever (Q22) and
are never reused.

### categories (product categories)

`id`, `name`, `searchKey`, `sortOrder INTEGER DEFAULT 0`, `createdAt`, `updatedAt`, `archivedAt`.
Partial `UNIQUE(searchKey) WHERE archivedAt IS NULL`.

### products

| Column | Rule |
|---|---|
| id, categoryId FK→categories NULL | |
| name, searchKey | NOT NULL |
| barcode TEXT NULL | partial `UNIQUE WHERE barcode IS NOT NULL AND archivedAt IS NULL` (scanning later) |
| sku TEXT NULL | |
| unitType | UnitType |
| salePricePiasters | per 1 unit, `CHECK >= 0` |
| avgCostPiasters | WAC per unit, `DEFAULT 0`, `CHECK >= 0`; written only by inbound-movement paths in the same TX, and can be rebuilt by replay |
| lowStockThresholdMilli NULL | |
| createdAt, updatedAt, archivedAt | |

Indexes: `(categoryId)`, `(searchKey)`, `(archivedAt)`. Stock is **not** stored; it is
`SUM(stock_movements.qtyDeltaMilli)`.

### customers / suppliers

`id`, `name`, `searchKey`, `phone NULL`, `address NULL`, `note NULL`, `createdAt`, `updatedAt`, `archivedAt`.
Indexes: `(searchKey)`, `(phone)`. No `creditLimitPiasters` (Q12). Balances come from the ledgers.

### expense_categories

`id`, `name`, `searchKey`, `createdAt`, `updatedAt`, `archivedAt`. Partial `UNIQUE(searchKey) WHERE archivedAt IS NULL`.

### sales_invoices (voidable header)

`id`, `number` (UNIQUE, counter SALE), `customerId FK NULL`, `subtotalPiasters`,
`discountPiasters DEFAULT 0`, `totalPiasters`, `paidAtSalePiasters`, **`paymentMethod`** (NOT NULL
DEFAULT `'cash'`, Q23), `note`, `createdAt`, **`updatedAt`** (Q16), `voidedAt NULL`, `voidReason NULL`.

CHECKs:
- `0 <= discount <= subtotal`
- `total = subtotal - discount`
- `0 <= paid <= total`
- `paid = total OR customerId IS NOT NULL`
- `(voidedAt IS NULL) = (voidReason IS NULL)`

Indexes: `(createdAt)`, `(customerId, createdAt)`, `(voidedAt)`.

### sale_items (immutable)

`id`, `salesInvoiceId FK`, `lineNo` (`UNIQUE(salesInvoiceId, lineNo)`), `productId FK`,
`productNameSnapshot` (Q24), `unitTypeSnapshot`, `qtyMilli > 0`, `unitPricePiasters >= 0`,
`discountPiasters` (0 ≤ d ≤ gross), `lineTotalPiasters`, `invoiceDiscountSharePiasters`,
`unitCostPiasters` (WAC snapshot), `lineCostPiasters`. Indexes: `(salesInvoiceId)`, `(productId)`.

### sale_returns (immutable; cannot be voided, Q13)

`id`, `number` (UNIQUE, counter SALE_RETURN), `salesInvoiceId FK`, `customerId FK NULL`,
`totalRefundPiasters`, `totalCostPiasters`, `refundPaidPiasters`
(`0..total`; `= total OR customerId IS NOT NULL`), **`paymentMethod`** (NOT NULL DEFAULT `'cash'`),
`reason NULL`, `createdAt`. Indexes: `(salesInvoiceId)`, `(createdAt)`.

### sale_return_items (immutable)

`id`, `saleReturnId FK`, `saleItemId FK`, `productId FK`, `qtyMilli > 0`, `unitPricePiasters`,
`unitCostPiasters`, `refundPiasters`, `costPiasters`, `createdAt`. Indexes: `(saleItemId)`, `(saleReturnId)`.
Trigger: a `BEFORE INSERT` aborts if the returned qty for a `saleItemId` would exceed `sale_items.qtyMilli`.

### purchase_invoices (voidable header; void allowed, Q18)

`id`, `number` (UNIQUE, counter PURCHASE), `supplierId FK NULL`, `supplierRef NULL`, `invoiceDate`,
`subtotalPiasters`, `discountPiasters`, `totalPiasters`, `paidPiasters`, **`paymentMethod`** (NOT NULL
DEFAULT `'cash'`), `note`, `createdAt`, **`updatedAt`**, `voidedAt`, `voidReason`. The CHECKs mirror
sales (`paid = total OR supplierId IS NOT NULL`). Indexes: `(invoiceDate)`, `(supplierId, invoiceDate)`.

### purchase_items (immutable)

`id`, `purchaseInvoiceId FK`, `lineNo` (UNIQUE per invoice), `productId FK`,
**`productNameSnapshot`** (Q24), `qtyMilli > 0`, `unitCostPiasters`, `discountPiasters DEFAULT 0`,
`lineTotalPiasters`, `invoiceDiscountSharePiasters`, `netLineCostPiasters`, `avgCostBeforePiasters`,
`avgCostAfterPiasters`, `createdAt`. Indexes: `(purchaseInvoiceId)`, `(productId)`.

### stock_movements (immutable, append-only)

`id`, `productId FK`, `movementType`, `qtyDeltaMilli` (signed, `!= 0`), `unitCostPiasters`,
`saleItemId NULL`, `saleReturnItemId NULL`, `purchaseItemId NULL`, `reversesMovementId NULL` (self-FK),
`adjustmentReason NULL`, `note NULL`, `createdAt`.

Per-type CHECK:

| Type | Required | Sign |
|---|---|---|
| OPENING | no source FK | + |
| PURCHASE | purchaseItemId | + |
| PURCHASE_VOID | purchaseItemId, reversesMovementId | − |
| SALE | saleItemId | − |
| SALE_RETURN | saleReturnItemId | + |
| SALE_VOID | saleItemId, reversesMovementId | + |
| ADJUSTMENT | adjustmentReason (`damage`/`count`/`other`, Q14) | ± |

`adjustmentReason IS NOT NULL` only when the type is ADJUSTMENT. Indexes: `(productId, qtyDeltaMilli)`
(covering for stock), `(productId, createdAt)`, plus each source FK. Inventory losses for the profit
report (Q14) are derived from ADJUSTMENT rows. No column is added for them.

### customer_ledger (immutable; + means the customer owes us more)

`id`, `customerId FK`, `entryType`, `amountPiasters` (signed, `!= 0`), `salesInvoiceId NULL`,
`saleReturnId NULL`, `receiptNumber NULL` (partial UNIQUE, counter CUSTOMER_RECEIPT),
**`paymentMethod NULL`**, `reversesEntryId NULL` (self-FK), `note NULL`, `createdAt`.
CHECK: `(entryType IN ('PAYMENT_RECEIVED','REFUND_PAID')) = (paymentMethod IS NOT NULL)`.
Indexes: `(customerId, createdAt)`, `(salesInvoiceId)`, `(saleReturnId)`.
A cash sale to a named customer writes SALE + PAYMENT_RECEIVED (Q17).

### supplier_ledger (immutable; + means we owe the supplier more)

The same shape as customer_ledger, with `purchaseInvoiceId NULL` and `paymentNumber NULL` (counter
SUPPLIER_PAYMENT). CHECK: `(entryType = 'PAYMENT_MADE') = (paymentMethod IS NOT NULL)`.
Indexes: `(supplierId, createdAt)`, `(purchaseInvoiceId)`.

> Deviation D2 (wording of Q23): Q23 says "TEXT NOT NULL DEFAULT 'cash'" for "the payment ledger
> rows". The ledgers also hold non-payment rows (SALE, OPENING_BALANCE …), so the column is nullable
> with a CHECK that makes it **required exactly on payment rows**. A NOT NULL default would
> attach a fake "cash" method to every sale and opening-balance row.

### expenses (voidable header)

`id`, `number` (UNIQUE, counter EXPENSE), `expenseCategoryId FK NOT NULL`, `amountPiasters > 0`,
`spentAt`, `note`, `createdAt`, **`updatedAt`** (Q16), `voidedAt`, `voidReason`.
Indexes: `(spentAt)`, `(expenseCategoryId)`. No paymentMethod (Q23 doesn't list expenses).

---

## Triggers (all created in `onCreate` from `schema_sql.dart`)

1. `trg_<table>_no_delete` on **every** table: `BEFORE DELETE … RAISE(ABORT, 'no hard delete: <table>')`.
2. `trg_<table>_immutable` on each immutable table: `BEFORE UPDATE … RAISE(ABORT, 'immutable: <table>')`.
3. `trg_<table>_void_only` on each voidable header: `BEFORE UPDATE` aborts when
   `OLD.voidedAt IS NOT NULL OR NEW.voidedAt IS NULL OR NEW.voidReason IS NULL` or any column other
   than `voidedAt`, `voidReason`, `updatedAt` changes (`NEW.x IS NOT OLD.x` for each column).
4. `trg_sale_return_items_qty_ceiling`: `BEFORE INSERT`, the returned-qty limit.
5. Meta-test (research R14): every column of tables in classes 2 and 3 appears in its trigger.

## Validation summary (where each rule lives)

| Rule | Domain | DB |
|---|---|---|
| Shop name 1–60 code points, trimmed | ShopProfile.create | CHECK when onboarded |
| Phone 7–15 digits, optional + | ShopProfile.create | GLOB check |
| One settings row | — | singleton UNIQUE/CHECK |
| No delete anywhere | repositories never issue DELETE | trigger 1 |
| Immutability | repositories never update | triggers 2–3 |
| Money/qty integer only | `int` types, no `double` (test) | INTEGER columns, CHECKs |
