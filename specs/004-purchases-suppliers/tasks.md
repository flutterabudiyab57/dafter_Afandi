# Tasks: Purchases and Suppliers

**Input**: design documents in `specs/004-purchases-suppliers/` (plan, research, data-model,
contracts, quickstart).

**Tests**: required (constitution quality gates).

**Organization**: the 7 phases of plan.md. Phases 1–3 are foundational. Phase 4 delivers US4,
Phase 5 US1 and US2, Phase 6 US3, US5 and US6.

**Standing rules**: commit once at each gate, never push (B1, approved 2026-10-21); no package or
schema change; material_ui only; no `double` in money or quantity paths; every string in both ARB
files; no `Color(`/`TextStyle(`/`EdgeInsets.only` outside `core/theme`; no delete; stop and ask if
anything is ambiguous.

## Phase 1: Domain (Foundational)

- [X] T001 Run the 14-day lock audit on `pubspec.lock`; report every `dependency_overrides` entry
  in `pubspec.yaml` past its "remove after" date. Change nothing without the owner's approval.
- [X] T002 [P] Keep `lib/features/customers/presentation/widgets/reason_dialog.dart` where it is
  (it depends on the customers domain; moving it to `core` would invert the layers); purchases and
  suppliers import it from customers, as sales does (research R3, updated).
- [X] T003 [P] `lib/features/products/domain/average_cost_replay.dart`: `ReplayMovement
  {qtyDeltaMilli, inboundCostPiasters?}` and `int replayAverageCost(Iterable<ReplayMovement>)`
  using `weightedAverageCost` (stock ≤ 0 → the inbound row's own cost). Tests in
  `test/features/products/domain/average_cost_replay_test.dart` (research R8).
- [X] T004 [P] `lib/features/suppliers/domain/`: `supplier.dart` (Supplier, SupplierSummary,
  SupplierQuery {text, owedOnly}), `supplier_errors.dart` (SupplierField, SupplierFieldError,
  SupplierSaveError: SupplierNotFound; SupplierPaymentError: SupplierNotFound, SupplierArchived,
  PaymentNotCancellable, PaymentAlreadyCancelled, PaymentReasonInvalid), `supplier_draft.dart`
  (`SupplierDraft.create` with name "trimmed, 1–100 code points", phone via `parseShopPhone`,
  address/note "≤ 200 code points", opening "0 < amount ≤ 1,000,000,000 piasters, ≤ 2 decimals",
  sign + when owed by the shop, − in the shop's favour), `supplier_payment.dart`
  (`SupplierPaymentRequest.create`: amount "0 < amount ≤ 1e9 piasters, ≤ 2 decimals", note
  "≤ 200 code points"; reuses `PaymentMethod` and `validateReason` from
  `features/customers/domain/payment.dart`), `supplier_entry.dart` (SupplierEntryType,
  SupplierEntry with reversed and cancellable), `supplier_repository.dart` (contract in
  `contracts/repositories-and-screens.md`).
- [X] T005 [P] `lib/features/purchases/domain/`: `purchase_draft.dart` (PurchaseLine with qty
  "0 < qty ≤ 1,000,000,000", whole for piece, unit cost "0 ≤ cost ≤ 1,000,000,000", discount
  "0 ≤ discount ≤ gross", `costNotice` = `lineTotal ≥ lineTotalPiasters(qty, salePrice)`;
  PurchaseDraft with add / set / remove, invoice discount "0 ≤ d ≤ subtotal", shares via
  `allocateLargestRemainder`, netLineCost, supplierRef "trimmed, ≤ 50 code points, empty → null",
  invoiceDate "local date ≤ today" default today, paid `int?` (null = pay all), method default
  cash, note "≤ 200", `validate()`), `purchase_errors.dart` (PurchaseInputError, PurchaseSaveError,
  PurchaseVoidError with VoidStockShortage), `purchase.dart` (PurchaseSummary with kind, Purchase,
  PurchaseItem, PurchaseQuery {text, unpaidOnly, supplierId?}, PurchaseSaved),
  `purchase_repository.dart` (contract, including `lastUnitCost` and
  `voidPurchase(..., {acknowledgeShortage})`).
- [X] T006 [P] Tests: `test/features/suppliers/domain/` (draft limits, phone, opening sign,
  payment amount) and `test/features/purchases/domain/purchase_draft_test.dart` (rounding half up,
  line and invoice discount limits, shares sum exactly, netLineCost = lineTotal − share, add same
  product raises qty, piece fraction rejected, credit needs supplier, paid > total, future date
  rejected, ref over 50 rejected, cost notice at equal and above the selling price, not below).
- [X] T007 Gate: analyze clean, all tests green. Commit `feat(004): phase 1 domain`.

## Phase 2: Data (Foundational)

- [X] T008 `lib/core/database/daos/suppliers_dao.dart`: watchActive(query) with the balance
  subquery, Arabic-first order and owed filter (balance > 0, highest first); watchOne;
  watchArchived; insert; update; setArchivedAt; activeNameExists (research R10).
- [X] T009 `lib/core/database/daos/supplier_ledger_dao.dart`: insert; balanceOf; statementPage
  (supplierId, before, limit) with the running-balance window and reversed flag; watchCountOf; byId;
  reversalOf(entryId); rowsForPurchase.
- [X] T010 `lib/core/database/daos/purchases_dao.dart`: insertInvoice, insertItem,
  watchList(query, limit) ordered `invoice_date DESC, number DESC` (search per research R16),
  watchOne (header + supplier name), items(invoiceId), setVoided, lastUnitCost(productId) over
  non-voided invoices by `created_at, rowid`.
- [X] T011 `lib/core/database/daos/stock_movements_dao.dart`: `purchaseMovementsOf(invoiceId)`;
  `replayRows` skips PURCHASE rows reversed by a PURCHASE_VOID and the PURCHASE_VOID rows, and
  carries `purchase_items.net_line_cost_piasters` for PURCHASE rows (research R8).
- [X] T012 `lib/features/products/data/inventory_repository_impl.dart`: `rebuildAverageCost` calls
  `replayAverageCost`; existing 002 and 003 tests still pass unchanged.
- [X] T013 Register the DAOs; `dart run build_runner build`; confirm `drift_schemas/` unchanged and
  schemaVersion 1.
- [X] T014 `lib/features/suppliers/data/supplier_repository_impl.dart` + mappers (research R10–R12;
  writes C1–C2, P1–P2, X1 in data-model.md).
- [X] T015 `lib/features/purchases/data/purchase_repository_impl.dart` + mappers (research R7, R9,
  R14; writes W1–W7 and V1–V5 in data-model.md).
- [X] T016 DI in `lib/core/di/service_locator.dart`.
- [X] T017 [P] Tests in `test/features/suppliers/data/` and `test/features/purchases/data/`:
  create/update/archive/restore, opening balance ±, statement running balance and paging, pay and
  cancel (cannot cancel twice, cannot cancel a payment made with a purchase, reason checked and
  trimmed); purchase W1–W7 for no supplier, cash with supplier, partial, credit; WAC per line,
  into zero and negative stock, same product twice sequenced; archived product or supplier blocks;
  lastUnitCost skips voided; void V1–V5 restores stock and balance, avgCost equals the replay
  without the voided purchase (two purchases, void the first), shortage needs acknowledgement;
  cannot void twice; P- and PY- numbers consecutive and unchanged after a forced rollback; property
  test of random purchases, sales, payments, cancels, voids and adjustments (balance = Σ ledger,
  stock = Σ movements, avgCost = replay); 2,000-product search timing reused from 002.
- [X] T018 Gate. Commit `feat(004): phase 2 data`.

## Phase 3: Cubits

- [X] T019 Suppliers cubits in `lib/features/suppliers/presentation/cubits/`: SuppliersListCubit
  (debounced search, owed filter), SupplierFormCubit (create/edit, same-name notice),
  SupplierDetailsCubit (archive, restore), SupplierStatementCubit (pages, reload on
  `watchStatementChanges`, generation guard), SupplierPaymentCubit ("supplier will owe the shop"
  notice, save), ArchivedSuppliersCubit, SupplierPickerCubit (search, quick add).
- [X] T020 Move `ProductPickerPage` and `ProductPickerCubit` from `lib/features/sales/presentation/`
  to `lib/features/products/presentation/` with an optional quick-add action (off for sales);
  update sales imports and tests (research R3, R13).
- [X] T021 Purchases cubits in `lib/features/purchases/presentation/cubits/`: PurchaseCubit (draft
  edits, cost prefill from `lastUnitCost` else avgCost, typed paid resets when the total changes as
  in the 003 fix, submit → saved, reset), PurchasesListCubit (search, unpaid, show more),
  PurchaseViewCubit (watch, void → shortage confirm → voided).
- [X] T022 Bundles `SuppliersCubits` / `PurchasesCubits` with app impls in
  `lib/features/{suppliers,purchases}/presentation/`; fakes in `test/helpers/fake_purchases.dart`
  (FakePurchasesStore sharing the products fake store).
- [X] T023 [P] bloc tests for every cubit in `test/features/{suppliers,purchases}/presentation/cubits/`.
- [X] T024 Gate. Commit `feat(004): phase 3 cubits`.

## Phase 4: Suppliers UI — US4 (P2)

**Goal**: suppliers next to customers in Parties, with balance and statement.
**Independent test**: add a supplier with an opening balance of 1,000.00 owed by the shop, buy
400.00 on credit (seeded), and see 1,400.00 in the list and both rows in the statement.

- [X] T025 [US4] ARB keys (ar + en) for all of 004 in `lib/core/l10n/arb/app_ar.arb` and
  `app_en.arb`; run `flutter gen-l10n`.
- [X] T026 [US4] Routes in `lib/core/router/route_names.dart` and `app_router.dart` (research R15)
  and wiring through App, bootstrap and `test/helpers/pump_app.dart`.
- [X] T027 [US4] Customers / Suppliers switch on `CustomersScreen` and `SuppliersScreen`
  (`lib/features/customers/presentation/screens/customers_screen.dart`,
  `lib/features/suppliers/presentation/screens/suppliers_screen.dart`).
- [X] T028 [US4] SuppliersScreen, SupplierFormScreen, SupplierDetailsScreen (balance, actions,
  statement section, purchases list), ArchivedSuppliersScreen in
  `lib/features/suppliers/presentation/screens/`.
- [X] T029 [P] [US4] Widget tests US4 scenarios 1–7 in ar/en at 100/200% in
  `test/features/suppliers/presentation/suppliers_screens_test.dart`.
- [X] T030 [US4] Gate. Commit `feat(004): phase 4 suppliers`.

## Phase 5: New purchase — US1, US2 (P1)

**Goal**: record a purchase, cash or on credit, which raises stock and updates average cost.
**Independent test**: "شاي" at 10 in stock and cost 9.00; buy 10 at 11.00 for cash; P-000001 is
listed, stock 20, average cost 10.00.

- [X] T031 [US1] NewPurchaseScreen in `lib/features/purchases/presentation/screens/new_purchase_screen.dart`:
  lines with quantity, cost and discount fields, cost notice under the line, totals, invoice
  discount, supplier chip, supplier's invoice number, invoice date picker (no future dates), paid
  now, method chips, note, Save, leave guard, snackbar with the number.
- [X] T032 [US1] Quick add product page (name, unit, selling price, optional barcode via
  `ProductRepository.create` with no opening stock) reachable from the product picker on purchases
  only (research R13).
- [X] T033 [US2] SupplierPickerPage with "Add «name»" quick add in
  `lib/features/suppliers/presentation/screens/supplier_picker_page.dart`.
- [X] T034 [US1] Purchases section root replaces `purchases_screen.dart` placeholder: list
  placeholder replaced in Phase 6, New purchase button.
- [X] T035 [P] [US1] [US2] Widget tests US1 scenarios 1–10 and US2 scenarios 1–5 in
  `test/features/purchases/presentation/new_purchase_screen_test.dart`.
- [X] T036 [US1] Gate. Commit `feat(004): phase 5 new purchase`.

## Phase 6: Purchases, payments, voids — US3, US5, US6

**Goal**: see past purchases, pay suppliers, correct mistakes.
**Independent test**: buy 10 pieces on credit for 100.00, void with a reason; stock, average cost
and balance are back and the purchase shows as voided.

- [X] T037 [US3] PurchasesListScreen (search by number, supplier name and supplier's invoice
  number; unpaid filter; show more) and PurchaseScreen (all fields, method only when paid > 0,
  titled "فاتورة شراء" / "Purchase invoice") in `lib/features/purchases/presentation/screens/`.
- [X] T038 [US6] Void on PurchaseScreen: reason dialog, then the stock shortage dialog naming each
  product and its resulting stock; refusals and unexpected failures in a SnackBar.
- [X] T039 [US5] SupplierPaymentScreen and Cancel payment on statement rows; tapping a purchase row
  opens the purchase.
- [X] T040 [P] [US3] [US5] [US6] Widget tests US3 1–4, US5 1–3, US6 1–8 in
  `test/features/purchases/presentation/purchases_and_payments_test.dart`.
- [X] T041 Gate. Commit `feat(004): phase 6 purchases, payments and voids`.

## Phase 7: Polish

- [ ] T042 Extend `visitEveryScreen` in `test/helpers/screens.dart` with every new screen, picker
  and dialog (seeded fakes); update the screen counts in `test/app/`; semantics and 200% layout
  walks pass.
- [ ] T043 Full gate; `flutter build apk --debug`; quickstart on a phone if connected, otherwise
  list it for the owner.
- [ ] T044 Re-run the lock audit; mark all tasks; commit `feat(004): phase 7 polish`.

## Dependencies

Phases run in order 1 → 7. Phase 2 needs Phase 1's contracts and the replay function; Phase 5
needs Phase 4's routes and strings and Phase 3's moved product picker; Phase 6 needs Phase 5's
purchases section. Within a phase, tasks marked [P] touch different files and can run together.

**Parallel examples**: Phase 1 T002, T003, T004 and T005; Phase 2 the supplier tests and the
purchase tests in T017; Phase 3 the bloc tests in T023.

## Implementation strategy

MVP = Phases 1–5: cash and credit purchases from named suppliers, so stock and average cost become
correct (Phase 5 needs Phase 4's routes and strings). Phase 6 adds the list, payments and
corrections. Each phase ends at a
gate with a commit and stops for review.
