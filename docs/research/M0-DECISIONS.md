# M0 decisions
Decisions on M0-PHASE1-REPORT.md (2026-10-19). These override the report where they differ.

Q1  Flutter 3.47.7 / Dart 3.13.5 installed (SDK from the official stable channel is exempt
    from the 14-day rule, which applies to pub packages).
Q2  Pin ALL direct dependencies exactly (no ^). pubspec.lock is committed.
Q3  Use dependency_overrides for sqlite3 3.7.0 and cupertino_ui 1.1.1, each with a
    "remove after <date+14d>" comment. Re-check all transitive dates before the first commit of each feature.
Q4  Approved: equatable, share_plus, local_auth, file_picker, path_provider (direct),
    flutter_secure_storage, flutter_lints, flutter_launcher_icons + flutter_native_splash (dev only),
    crypto (direct). NOT approved yet: pdf (decide in 007).
Q5  Android minSdk: Flutter default if >= 24, else 24. iOS is in scope (min iOS 15).
Q6  Invoice sharing = render a Flutter widget to an image + optional plain-text summary for WhatsApp.
    No PDF and no printer in the MVP.
Q7  Both: Android Auto Backup configured in 001; manual export (VACUUM INTO) + import in 007.
    Export via share sheet and the system save dialog only. Never write to Downloads directly.
Q8  PIN 4-6 digits + optional biometric with PIN fallback. Re-lock after 60 s in background.
    PIN hash + salt live in flutter_secure_storage, NOT in the database. Remove pinHash/pinSalt
    from app_settings. Restoring a backup on a new device clears the lock and requires a new PIN.
Q9  Yes: returns and voids re-enter stock at the original snapshot cost and blend into WAC.
Q10 Digits follow the locale by default, user can override in settings. Arabic currency label: "ج.م".
Q11 piece, kg, liter, meter is enough for the MVP. Cartons/packs with conversion are planned for v1.1.
Q12 No credit limit in the MVP. Do not add the column.
Q13 Sale returns cannot be voided in v1.
Q14 Stock adjustments are in the MVP (damage, count, other). The profit report shows inventory
    losses as a SEPARATE line: netProfit = grossProfit - inventoryLosses - expenses.
Q15 No cash drawer in the MVP.
Q16 Add updatedAt to voidable headers now (set on void). Immutability triggers allow updating
    only voidedAt, voidReason and updatedAt.
Q17 Yes: a cash sale with a named customer writes SALE + PAYMENT_RECEIVED rows.
Q18 Purchase void: yes, with WAC rebuild by replay. Purchase returns: not in the MVP.
Q19 Returns count in the period they occur.
Q20 DB in getApplicationSupportDirectory().
Q21 Commit generated *.g.dart files.
Q22 Numbers run forever. Display prefixes per type in the UI only (S-, R-, P-, E-, RC-, PY-).
Q23 Add paymentMethod TEXT NOT NULL DEFAULT 'cash' CHECK IN ('cash','wallet','instapay','card')
    to sales_invoices, purchase_invoices, sale_returns, and the payment ledger rows. MVP UI shows cash
    + wallet + instapay. No external integration.
Q24 Yes: product name snapshot on sale and purchase lines.
