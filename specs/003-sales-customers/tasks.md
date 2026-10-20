# Tasks: Sales and Customers

**Input**: design documents in `specs/003-sales-customers/` (plan, research, data-model,
contracts, quickstart).

**Tests**: required (constitution quality gates).

**Organization**: the 7 phases of plan.md. Phase 4 delivers US4, Phase 5 US1 and US2, Phase 6 US3,
US5 and US6.

**Standing rules**: commit once at each gate, never push; no package or schema change;
material_ui only; no `double` in money or quantity paths; every string in both ARB files; no
`Color(`/`TextStyle(`/`EdgeInsets.only` outside `core/theme`; no delete; stop and ask if anything
is ambiguous.

## Phase 1: Domain (Foundational)

- [X] T001 Run the 14-day lock audit; report overrides past their date. Change nothing.
- [X] T002 [P] `lib/core/utils/doc_number.dart`: `formatDocNumber(String prefix, int n)` → `S-000012`
  (six digits minimum, Latin; the screen applies the digit style). Tests in
  `test/core/utils/doc_number_test.dart`.
- [X] T003 [P] `lib/features/customers/domain/`: `customer.dart` (Customer, CustomerSummary,
  CustomerQuery), `customer_errors.dart` (limits: name 100, text 200, amount 1e9; CustomerField
  enum; CustomerFieldError; CustomerSaveError; PaymentError; ReasonError), `customer_draft.dart`
  (`CustomerDraft.create` with "name trimmed, 1–100 code points", phone via `parseShopPhone`,
  address/note "≤ 200 code points", opening "0 < amount ≤ 1,000,000,000 piasters, ≤ 2 decimals",
  sign by direction), `payment.dart` (PaymentMethod, PaymentRequest.create, validateReason
  "trimmed, 1–200 code points"), `ledger_entry.dart` (LedgerEntryType, LedgerEntry, LedgerCursor),
  `customer_repository.dart` (contract).
- [X] T004 [P] `lib/features/sales/domain/`: `sale_draft.dart` (SaleLine, SaleDraft with add /
  set / remove, totals, shares via `allocateLargestRemainder`, `validate()`), `sale_errors.dart`
  (SaleError, Shortage, SaleSaveError, VoidError), `sale.dart` (SaleSummary with kind, SaleInvoice,
  SaleItem, SaleQuery, SaleSaved), `sales_repository.dart` (contract).
- [X] T005 Add `activeByBarcode` to `ProductRepository`, its impl (via the existing
  `activeWithBarcode` DAO query) and the fake.
- [X] T006 [P] Tests: `test/features/customers/domain/` (draft limits, phone, opening sign,
  payment amount, reason) and `test/features/sales/domain/sale_draft_test.dart` (rounding half up,
  line and invoice discount limits, shares sum exactly, add same product raises qty, piece
  fraction rejected via the parsers, credit needs customer, paid > total).
- [X] T007 Gate: analyze clean, all tests green. Commit `feat(003): phase 1 domain`.

## Phase 2: Data (Foundational)

- [X] T008 `lib/core/database/daos/counters_dao.dart`: `take(DocType)` with `UPDATE … RETURNING`.
- [X] T009 `customers_dao.dart`: watchActive(query) with the balance subquery, list order and owes
  filter; watchOne; watchArchived; insert; update; setArchivedAt; activeNameExists.
- [X] T010 `customer_ledger_dao.dart`: insert; balanceOf; statementPage(customerId, before, limit)
  with the running-balance window and reversed flag; byId; reversalOf(entryId); rowsForInvoice.
- [X] T011 `sales_dao.dart`: insertInvoice, insertItem, watchList(query, limit), watchOne (header +
  customer name), items(invoiceId), setVoided; plus `stock_movements_dao` `saleMovementsOf`.
- [X] T012 Register the DAOs; `dart run build_runner build`; confirm `drift_schemas/` unchanged and
  schemaVersion 1.
- [X] T013 `lib/features/customers/data/customer_repository_impl.dart` + mappers (R12, R13).
- [X] T014 `lib/features/sales/data/sales_repository_impl.dart` (R10, R11) + mappers.
- [X] T015 DI in `service_locator.dart`.
- [X] T016 [P] Tests in `test/features/customers/data/` and `test/features/sales/data/`:
  create/update/archive/restore, opening balance ±, statement running balance and paging,
  receive and cancel payment (cannot cancel twice, cannot cancel a sale payment), sale W1–W6 for
  walk-in, cash with customer, partial, credit; shortage needs acknowledgement; archived product or
  customer blocks; void V1–V5 restores stock, avgCost and balance; cannot void twice; numbers
  consecutive and unchanged after a forced rollback; property test of random sales, payments,
  cancels and voids (balance = Σ ledger, stock = Σ movements, avgCost = replay); 2,000-product
  search timing reused from 002.
- [X] T017 Gate. Commit `feat(003): phase 2 data`.

## Phase 3: Cubits

- [X] T018 Customers cubits: CustomersListCubit (debounced search, owes filter), CustomerFormCubit
  (create/edit, same-name notice), CustomerDetailsCubit (archive, restore), StatementCubit (pages,
  reload on change), PaymentCubit (credit notice, save), ArchivedCustomersCubit,
  CustomerPickerCubit (search, quick add).
- [X] T019 Sales cubits: SaleCubit (draft edits, submit → shortage confirm → saved, reset),
  ProductPickerCubit (search, exact barcode), SalesListCubit (search, unpaid, show more),
  InvoiceCubit (watch, void).
- [X] T020 Bundles `CustomersCubits` / `SalesCubits` with app impls; fakes in
  `test/helpers/fake_sales.dart` (FakeSalesStore sharing the products fake store).
- [X] T021 [P] bloc tests for every cubit.
- [X] T022 Gate. Commit `feat(003): phase 3 cubits`.

## Phase 4: Customers UI — US4 (P2)

- [X] T023 ARB keys (ar + en) for all of 003.
- [X] T024 Routes (R15) and wiring through App, bootstrap and pumpApp; Parties root shows the
  customers list.
- [X] T025 CustomersScreen, CustomerFormScreen, CustomerDetailsScreen (balance, actions, statement
  section, invoices list), ArchivedCustomersScreen.
- [X] T026 [P] Widget tests US4 scenarios 1–7 in ar/en at 100/200%.
- [X] T027 Gate. Commit `feat(003): phase 4 customers`.

## Phase 5: New sale — US1, US2 (P1)

- [X] T028 NewSaleScreen: lines with quantity, price and discount fields; totals; invoice
  discount; customer chip; paid now; method chips; Save; leave guard; shortage dialog; snackbar
  with the number.
- [X] T029 ProductPickerPage and CustomerPickerPage (quick add).
- [X] T030 Sales section root: invoice list placeholder replaced in Phase 6; New sale button.
- [X] T031 [P] Widget tests US1 1–7 and US2 1–5.
- [X] T032 Gate. Commit `feat(003): phase 5 new sale`.

## Phase 6: Invoices, payments, voids — US3, US5, US6

- [ ] T033 SalesListScreen (search, unpaid filter, show more) and InvoiceScreen with Void dialog.
- [ ] T034 PaymentScreen and Cancel payment on statement rows; tapping a sale row opens the
  invoice.
- [ ] T035 [P] Widget tests US3 1–4, US5 1–3, US6 1–6.
- [ ] T036 Gate. Commit `feat(003): phase 6 invoices, payments and voids`.

## Phase 7: Polish

- [ ] T037 Extend `visitEveryScreen` with every new screen and dialog (seeded fakes); semantics and
  200% layout walks pass.
- [ ] T038 Full gate; `flutter build apk --debug`; quickstart on a phone if connected, otherwise
  list it for the owner.
- [ ] T039 Re-run the lock audit; mark all tasks; commit `feat(003): phase 7 polish`.

## Dependencies

Phases run in order 1 → 7. Phase 5 needs Phase 4's routes and strings; Phase 6 needs Phase 5's
sales section.
