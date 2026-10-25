# Tasks: UI States and Visual Polish

**Input**: design documents in `specs/005-ui-states/` (plan, research, data-model, contracts,
quickstart) and `docs/design/DESIGN-HANDOFF.md` (the handoff).

**Tests**: required (constitution quality gates; FR-021, FR-022).

**Organization**: the 7 phases of plan.md. Phases 1–3 are foundational (US5 theme, assets,
shared widgets). Phase 4 delivers US2, with the US1 archive undo and the US3 marks. Phase 5
delivers US1 and US3 in forms. Phase 6 delivers US4. Phase 7 closes US5 across every screen.

**Standing rules**:
- **Commits:** commit once at each gate (B1 for 005, approved 2026-10-22). Never push or merge.
- **No changes to:** packages, schema, data, or financial rules.
- **Code rules:**
  - material_ui only;
  - every string in both ARB files, in MSA;
  - no `Color(`, `TextStyle(` or `EdgeInsets.only` outside `core/theme`;
  - start/end only;
  - no text-scale clamp.
- **Wording:** existing wording stays unless a key is reused.
- **Ambiguity:** stop and ask.

**Screen tests**: every new or changed screen state is tested in ar and en at text scale 1.0 and
2.0 (`pumpApp`, `goTo` from `test/helpers/pump_app.dart`). Existing finders keep matching texts;
where a mark moves from an icon to a word, the test looks for the word.

## Phase 1: Theme (Foundational, US5)

**Goal**: the three feedback tones, the two new tokens and the component themes, set once.

- [X] T001 Run the 14-day lock audit on `pubspec.lock`. Report every `dependency_overrides` entry in
  `pubspec.yaml` that is past its "remove after" date. Change nothing without the owner's approval.
- [X] T002 [P] `lib/core/theme/app_colors.dart`: add the twelve fields `success`, `onSuccess`,
  `successContainer`, `onSuccessContainer`, `warning`, `onWarning`, `warningContainer`,
  `onWarningContainer`, `info`, `onInfo`, `infoContainer`, `onInfoContainer`.
  - Put them next to `owes`/`credit`/`voided`, with `copyWith` and `lerp` entries.
  - Light and dark hex values go in `AppPalette`, exactly as in handoff 3.1.
  - No existing value changes (research R1).
- [X] T003 [P] `lib/core/theme/app_radii.dart` `xl = 28`, `lib/core/theme/app_spacing.dart`
  `illustration = 192`, and `lib/core/theme/app_tokens.dart` `radiusXl` and `illustrationWidth`.
  Both scale through `AppTokens.scaled()` (research R2).
- [X] T004 `lib/core/theme/app_theme.dart` `_theme(scheme, scale)`: add the component themes of
  handoff 3.3 with the values given there, with radii read from `AppRadii` × scale (research R3):
  - `filledButtonTheme`, `outlinedButtonTheme` and `textButtonTheme`;
  - `inputDecorationTheme`;
  - `snackBarTheme`;
  - `dialogTheme`;
  - `navigationBarTheme`;
  - `chipTheme`;
  - `floatingActionButtonTheme`;
  - `cardTheme`;
  - `appBarTheme`.
- [X] T005 Remove per-widget styling that now repeats the theme, such as `border:
  OutlineInputBorder()` on search and form fields and per-button `minimumSize`. Find it with
  `grep -rn "OutlineInputBorder\|minimumSize\|StadiumBorder" lib/features lib/core/widgets`. Keep
  any styling that differs on purpose, and list it in the gate report.
- [X] T006 `test/core/theme/theme_test.dart`, in both themes:
  - every new pair is ≥ 4.5:1: `on…` on its fill, `on…Container` on its container, and the tone
    on `surface`;
  - a few component themes read back: snackbar background = `inverseSurface`, dialog shape radius
    = `radiusXl`, filled button minimum height 48, card elevation 0;
  - the new tokens scale.
- [X] T007 Gate: `flutter analyze` clean and `flutter test` green. Report any test that changed
  because the look changed. Commit `feat(005): phase 1 theme`.

## Phase 2: Assets (Foundational)

**Goal**: the 19 illustrations ship in light and dark at 1x, 2x and 3x and follow the theme.

- [X] T008 Copy the PNGs, keeping the `2.0x/` and `3.0x/` folders, 114 files in all:
  - `docs/design/assets/illustrations/png/light/` → `assets/illustrations/light/`;
  - `docs/design/assets/illustrations/png/dark/` → `assets/illustrations/dark/`.
  Do not copy the SVGs.
- [X] T009 `pubspec.yaml`: list `assets/illustrations/light/` and `assets/illustrations/dark/`
  under `flutter: assets:` (approved, Q3). Touch nothing else in the file.
- [X] T010 `lib/core/widgets/app_illustration.dart` (research R4):
  - **Enum:** `enum AppIllustration` with the 19 values in data-model order, and
    `String assetPath(Brightness)`, which returns `assets/illustrations/{light|dark}/<snake_case>.png`.
  - **Widget:** `Illustration(this.kind, {super.key, this.width})`. Width defaults to
    `context.tokens.illustrationWidth` and height = width × 200 / 240. It shows the image with
    `Image.asset`, `excludeFromSemantics: true`, and an `errorBuilder` that returns a `SizedBox` of
    the same size.
- [X] T011 [P] `test/core/assets/illustrations_test.dart`: every value has its light and dark file
  at 1x, `2.0x/` and `3.0x/` on disk (`File(...).existsSync()`).
- [X] T012 [P] `test/core/widgets/app_illustration_test.dart`:
  - the light path shows in the light theme and the dark path in the dark theme;
  - the image is excluded from semantics;
  - a missing asset renders an empty box of the same size with no exception;
  - `assetPath` gives the snake_case name for `emptyProducts` and `warningLowStock`.
- [X] T013 Gate: analyze clean and all tests green. Commit `feat(005): phase 2 illustrations`
 .

## Phase 3: Shared widgets (Foundational)

**Goal**: the building blocks of contracts/ui-components.md, tested alone, plus the approved texts.

- [X] T014 `lib/core/l10n/arb/app_ar.arb` and `app_en.arb`: add the 18 approved keys of handoff 7,
  with the exact texts. Leave out `reportsEmptyBody` (deferred, research R12). Run
  `flutter gen-l10n`.
- [X] T015 [P] `lib/core/widgets/status_banner.dart`: `enum StatusTone { success, warning, error,
  info }` and `StatusBanner({required tone, required title, message, actionLabel, onAction})`.
  - **Colors:** the tone's container and on-container colors; error uses
    `colorScheme.errorContainer` / `onErrorContainer`.
  - **Icons:** filled `check_circle`, `warning`, `error`, `info`.
  - **Shape:** radiusMd, directional padding 14/16.
  - **Semantics:** `Semantics(liveRegion: true)`.
  - **Text scale:** the action wraps under the text at 200%.
  - **Tone values:** one `StatusToneColors` lookup that the other widgets reuse.
- [X] T016 [P] `lib/core/widgets/app_snack_bar.dart`: `showAppSnackBar(context, message, {tone =
  StatusTone.success, actionLabel, onAction})`. It calls `hideCurrentSnackBar()` first, shows for
  4 s (10 s with an action), and has a 24 px dot in the tone's container color with the
  on-container glyph. The floating style comes from the theme (research R6).
- [X] T017 [P] `lib/core/widgets/status_badge.dart`: `enum BadgeTone { success, owes, credit,
  error, voided, neutral }` and `StatusBadge({required label, required tone, icon})`.
  - **Look:** stadium shape; 12/600 label from the type scale; directional padding 4/10.
  - **Icon:** each tone has a default icon.
  - **Text scale:** the label wraps and never ellipsizes mid-word.
- [X] T018 [P] `lib/core/widgets/empty_state.dart`: `EmptyState({required illustration, required
  title, message, action})`. It is centered with a maximum width of 360 × scale, and scrolls at
  200%.
- [X] T019 [P] `lib/core/widgets/result_view.dart`: `ResultView({required illustration, required
  title, required message, primary, secondary})`. It is full screen, scrolls at 200%, and both
  buttons are optional.
- [X] T020 [P] `lib/core/widgets/skeleton_list.dart`: `SkeletonList({rows = 4})`.
  - **Delay:** nothing shows for the first 300 ms (a `Timer` cancelled on dispose).
  - **Rows:** rows of the real list-row height in `surfaceContainerHighest`.
  - **Shimmer:** a slow shimmer, none under `MediaQuery.disableAnimationsOf(context)`.
  - **Semantics:** excluded from semantics.
- [X] T021 [P] `lib/core/widgets/load_failed_view.dart`: `LoadFailedView({required title,
  required message, required retryLabel, required onRetry})`, built as an `EmptyState` with
  `errorGeneric` and an outlined retry button.
- [X] T022 [P] `lib/core/widgets/confirm_dialog.dart`: `Future<bool?> showConfirmDialog(context,
  {required tone, required title, required message, required confirmLabel, required cancelLabel,
  destructive = false})`.
  - **Icon:** the tone icon above the title.
  - **Buttons:** cancel is a `TextButton`. Confirm is a `FilledButton`, in error colors when
    `destructive`, and is placed last.
  - **Return value:** null when dismissed.
- [X] T023 [P] `lib/core/widgets/save_button.dart`: `SaveButton({required label, required
  savingLabel, required saving, required onPressed})`. While `saving` it shows an 18 px
  `CircularProgressIndicator` and `savingLabel`, and `onPressed` is null.
- [X] T024 [P] `lib/core/widgets/unsaved_changes_guard.dart`: `UnsavedChangesGuard({required
  dirty, required child})`.
  - **Wrapper:** `PopScope(canPop: !dirty)`.
  - **On a blocked pop:** it shows `showConfirmDialog` in the warning tone with
    `discardChangesTitle` / `discardChangesBody`, `keepEditingAction` / `discardAction`, and
    `destructive: true`.
  - **Leaving:** it pops only on `true`.
- [X] T025 Tests in `test/core/widgets/`, one file per widget, each in ar and en at 1.0 and 2.0
  with no overflow:
  - the banner is a live region and shows the icon for each tone;
  - a second `showAppSnackBar` replaces the first, and the durations are 4 s and 10 s;
  - the badge shows its word;
  - `EmptyState` and `ResultView` scroll at 200%;
  - the skeleton is absent at 299 ms, present at 301 ms, and has no running animation under
    `disableAnimations`;
  - the confirm dialog puts the destructive button last and returns true, false or null;
  - `SaveButton` ignores taps while saving (SC-004);
  - the guard leaves at once when clean, asks when dirty, stays on "متابعة التعديل" and leaves on
    "تجاهل".
- [X] T026 Gate: analyze clean, all tests green, and `test/l10n/arb_test.dart` green. Commit
  `feat(005): phase 3 shared widgets`.

**Checkpoint**: phases 4, 5 and 6 can start.

## Phase 4: Lists (US2, with US1 undo and US3 marks)

**Goal**: every list shows empty, no-results, loading, load-failed and labelled marks, and
archiving offers undo.

**Independent test**: on a fresh install every list shows its own illustration and action.
Searching "zzz" shows no results, and "مسح البحث" clears it. A failing stream shows "إعادة
المحاولة". Archiving "شاي" offers "تراجع", which brings it back.

- [X] T027 [US2] Add the five R13 keys approved on 2026-10-22: `productArchivedMessage`,
  `customerArchivedMessage`, `supplierArchivedMessage`, `loadFailedTitle` and `loadFailedBody` to
  both ARB files with the texts in research R13. Run `flutter gen-l10n`.
- [X] T028 [US2] Add `loadFailed` (bool, in props) and `retry()` to the list cubits (research R7;
  data-model "List cubits: load state").
  - **On a stream error:** set `loadFailed: true, loading: false`, then still call `addError`.
  - **`retry()`:** clears the flag, sets `loading`, and subscribes again.
  - **Search or filter change:** clears `loadFailed`.
  - **Cubits:**
    - `product_list_cubit.dart`, `archived_products_cubit.dart`, `categories_cubit.dart`,
      `low_stock_cubit.dart`, and the history stream in `product_details_cubit.dart` (in
      `lib/features/products/presentation/cubits/`);
    - `sales_list_cubit.dart` (in `lib/features/sales/presentation/cubits/`);
    - `CustomersListCubit` and `ArchivedCustomersCubit` in `customers_list_cubit.dart`, and the
      statement in `customer_details_cubit.dart` (in `lib/features/customers/presentation/cubits/`);
    - `SuppliersListCubit` and `ArchivedSuppliersCubit` in `suppliers_list_cubit.dart`, and the
      statement in `supplier_details_cubit.dart` (in `lib/features/suppliers/presentation/cubits/`);
    - `purchases_list_cubit.dart` (in `lib/features/purchases/presentation/cubits/`).
  - **Pickers:** leave them as they are.
- [X] T029 [P] [US2] Cubit tests next to each cubit's existing test (bloc_test):
  - error → `loadFailed`;
  - `retry()` → loading → loaded;
  - a query change clears the flag.
- [X] T030 [US2] Fakes: add a way to make a watch stream fail to the in-memory stores in
  `test/helpers/fake_products.dart`, `fake_sales.dart` and `fake_purchases.dart`, and to the
  customers and suppliers fakes. For example `store.failNextWatch()`. Follow the existing
  `onCancel` rule (no cancel future from a broadcast stream).
- [X] T031 [US2] Products list (`lib/features/products/presentation/screens/product_list_screen.dart`):
  - **States, in order:** `LoadFailedView` → `SkeletonList` while loading with no items →
    `EmptyState` (`emptyProducts`, `productsEmpty`, `productsEmptyAction` opening the form) → the
    list.
  - **Search or filter with no items:** `EmptyState` (`emptySearch`, `searchEmptyTitle`,
    `productsFilterEmpty`, a `searchClearAction` button that clears the text and the filter).
- [X] T032 [US3] `lib/features/products/presentation/widgets/stock_marks.dart` and `product_row.dart`:
  - **Marks:** the icon-only marks become `StatusBadge`. Low stock is `BadgeTone.owes` +
    `markLowStock`; below zero is `BadgeTone.error` + the existing below-zero word.
  - **Text scale:** at 200% the badge wraps under the title.
  - **Semantics:** the row's semantics label still names the mark once.
- [X] T033 [US1] Archive undo (research R6, FR-004): after a successful archive call
  `showAppSnackBar` with `undoAction` and an action that restores that record's id through the
  same cubit's restore path.
  - **Products:** `product_details_screen.dart` uses `productArchivedMessage`.
  - **Customers:** `customer_details_screen.dart` uses `customerArchivedMessage`.
  - **Suppliers:** `supplier_details_screen.dart` uses `supplierArchivedMessage`.
  - **Leaving the screen:** the undo targets the captured id and the bundle's cubit, not the
    screen's, so it still restores the right record after the screen is left (edge case).
- [X] T034 [P] [US2] Archived lists: `archived_products_screen.dart`, `archived_customers_screen.dart`
  and `archived_suppliers_screen.dart`.
  - **Empty:** `EmptyState(emptyArchive)` with the existing empty keys.
  - **Loading and failure:** skeleton and load-failed.
  - **Restore:** success `showAppSnackBar`.
  - **Barcode taken:** `errorRestoreBarcodeTaken` shows as an error `StatusBanner` at the top.
- [X] T035 [P] [US2] Categories (`categories_screen.dart`): empty `EmptyState(emptyProducts,
  categoriesEmpty)`, skeleton and load-failed. Saves show success snackbars through
  `showAppSnackBar`.
- [X] T036 [P] [US2] Stock history (`lib/features/products/presentation/widgets/stock_history_section.dart`):
  - **Empty:** keeps the `historyEmpty` text.
  - **Loading and failure:** skeleton rows and load-failed with retry.
  - **Below zero:** rows read the error colour with a word.
- [X] T037 [P] [US2] Sales list (`sales_list_screen.dart`, `widgets/sale_row.dart`):
  - **States:** empty `EmptyState(emptySales, salesListEmpty)`, search no-results, skeleton and
    load-failed.
  - **Badges:** the voided, credit and partly-paid marks become `StatusBadge` (`voided`, `owes`,
    `credit` tones with the existing words).
- [X] T038 [P] [US2] Customers and suppliers lists (`customers_screen.dart`, `suppliers_screen.dart`):
  - **Empty:** `EmptyState(emptyCustomers, customersEmptyTitle, customersEmptyBody, add action)`,
    and the same for suppliers.
  - **Other states:** search or filter no-results, skeleton and load-failed.
  - **Balances:** keep their amount and gain an `owes` / `credit` badge with the existing words.
- [X] T039 [P] [US2] Purchases list (`purchases_list_screen.dart`, `widgets/purchase_row.dart`):
  - **States:** empty `EmptyState(emptyPurchases, purchasesEmptyTitle, purchasesEmptyBody, new
    purchase action)`, no-results, skeleton and load-failed.
  - **Badges:** credit, partial and voided become badges.
- [X] T040 [P] [US2] Customer and supplier statements (`customer_details_screen.dart`,
  `supplier_details_screen.dart`): load-failed with retry on the statement section.
- [X] T041 [US2] Screen tests for T031–T040 in ar and en at 1.0 and 2.0:
  - each empty list shows its own illustration and never another's (US2-3);
  - no-results and clear (US2-2);
  - load-failed and retry;
  - the skeleton only after 300 ms (US2-4);
  - two different low-stock and below-zero badges (US3-2);
  - archive → "تراجع" → the record is back (US1-1);
  - the last item archived → empty state at once (edge case).
  Update existing tests whose icon finders become word finders.
- [X] T042 Gate: analyze clean and all tests green. Commit `feat(005): phase 4 lists`.

## Phase 5: Forms (US1, US3)

**Goal**: saving, save errors, blocking warnings, unsaved changes and success messages look and
behave the same in every form.

**Independent test**: a failed save keeps the values and shows an error banner at the top. Saving
shows "جارٍ الحفظ…" and can't be tapped twice. Credit with no customer shows a warning banner with
"اختيار". Back on a changed form asks "تجاهل التغييرات؟", and on an unchanged form it leaves at once.

- [X] T043 [US3] `hasUnsavedChanges` getter (research R9; data-model "Form cubits"): true when a
  field differs from the snapshot taken when the form became editable (after loading in edit
  mode), and false once saved.
  - **Cubits:** `product_form_cubit.dart`, `opening_stock_cubit.dart`,
    `stock_adjustment_cubit.dart`, `customer_form_cubit.dart`, `payment_cubit.dart`,
    `supplier_form_cubit.dart`, `supplier_payment_cubit.dart` and `shop_profile_form_cubit.dart`.
  - **Tests:** bloc tests for unchanged, changed, changed back and saved.
- [X] T044 [US3] Wrap those forms' screens in `UnsavedChangesGuard(dirty: cubit.hasUnsavedChanges)`:
  - product form, opening stock and stock adjustment;
  - customer form and payment;
  - supplier form and payment;
  - shop profile edit.
  New sale and new purchase keep `hasUnsavedLines` and their own wording, and only move their
  dialog to `showConfirmDialog` (warning, destructive).
- [X] T045 [US1] Replace each form's `FilledButton(onPressed: saving ? null : …)` with
  `SaveButton(label, savingLabel: l10n.savingLabel, saving, onPressed)`. The forms are those in
  T044, plus new sale, new purchase, quick add product and onboarding shop details.
- [X] T046 [US1] Save errors become an error `StatusBanner` at the top of the form, replacing the
  red text above Save (research R11). The page scrolls to the top when a save fails, and the typed
  values stay.
  - **Errors:** `errorSaveFailed`, and product, customer or supplier no longer available.
  - **Text helpers:** `product_error_text.dart`, `sale_text.dart`, `purchase_text.dart`,
    `customer_text.dart`, `supplier_text.dart` and `shop_profile_error_text.dart` keep producing
    the strings; only where they are shown changes.
  - **Field errors:** they stay under their fields.
- [X] T047 [US3] New sale (`new_sale_screen.dart`): `errorCreditNeedsCustomer` and
  `errorPaidTooLarge` show as a warning `StatusBanner` at the top. They still show their field
  error.
  - **Credit with no customer:** title `creditNeedsCustomerTitle`, action `chooseAction`, which
    opens the customer picker.
  - **Empty sale:** `saleEmpty` stays inline.
- [X] T048 [US3] New purchase (`new_purchase_screen.dart`): the same as T047 with the supplier and
  its picker, reusing `chooseAction`.
- [X] T049 [US1] Move every remaining `SnackBar(` call to `showAppSnackBar` with a tone (success for
  saves, payments, adjustments, voids and restores; error for failures). The calls are in the 17
  files from `grep -rln "SnackBar(" lib`. After this, that grep finds only
  `lib/core/widgets/app_snack_bar.dart`. `saleSaved` keeps its flow: snackbar, then the invoice
  (Q2).
- [X] T050 [US1] Move confirmation dialogs to `showConfirmDialog`, with the destructive choice last:
  - **Void dialogs:** the invoice and purchase void (`invoice_screen.dart`, `purchase_screen.dart`)
    use the error tone and `destructive: true`, with `invoiceVoidTitle`/`invoiceVoidBody` and the
    purchase equivalents.
  - **Reason field:** `lib/features/customers/presentation/widgets/reason_dialog.dart` keeps it and
    gets the same look (tone icon, radiusXl from the theme, destructive last).
  - **Other dialogs:** the overpay confirms in `payment_screen.dart` and
    `supplier_payment_screen.dart`, `opening_confirm_dialog.dart`, the purchase shortage warning,
    and the categories dialog. Their texts stay.
  - **After voiding:** a snackbar, then the voided banner in the `voided` tone on the invoice and
    the purchase.
- [X] T051 [US1] Stock adjustment: `adjustSaved` shows as a success snackbar (or the banner the
  handoff names, if the screen stays open). Opening stock does the same with its existing saved
  key.
- [X] T052 Screen tests in ar and en at 1.0 and 2.0:
  - **Saving:** a failed save keeps values and shows the top banner (US1-3); the save button shows
    "جارٍ الحفظ…" and a second tap does nothing (US1-4, SC-004).
  - **Void:** the dialog's destructive choice is last and the voided banner shows (US1-5).
  - **New sale:** the warning banner and "اختيار" open the picker (US3-3); `saleSaved` is followed
    by the invoice (US1-2).
  - **Unsaved changes:** a changed form asks and an unchanged one leaves (US3-4).
  - **New purchase:** the discard prompt still works.
  All existing 003 and 004 flow tests stay green.
- [X] T053 Gate: analyze clean and all tests green. Commit `feat(005): phase 5 forms`.

## Phase 6: Whole-app screens (US4, US3 home)

**Goal**: app start, startup error, update required, welcome, data safety, home and reports look
finished.

**Independent test**: force the startup error and the update-required state in tests. Each shows
its illustration, title and text in ar at 200% in both themes. Data safety shows two banners on iOS
and one on Android.

- [ ] T054 [US4] `lib/core/widgets/starting_app.dart` (new): `StartingApp` on `BlockingAppShell`
  (Arabic, RTL) with the logo `assets/images/logo.png`, a `LinearProgressIndicator` and
  `openingDataLabel`. `lib/bootstrap.dart` runs it with `runApp` before opening the database, then
  replaces it with the real app or a blocking app. The native splash is unchanged (research R12).
- [ ] T055 [P] [US4] `lib/core/widgets/startup_error_app.dart` and `update_required_app.dart`:
  - **Startup error:** content through `ResultView` with `errorDatabase`, the existing title and
    `startupErrorBody`, and its existing action if any.
  - **Update required:** `updateRequired` with `updateRequiredTitle` / `updateRequiredBody`.
  - **Check:** `lib/core/widgets/blocking_app_shell.dart` must provide the theme (light and dark)
    so the illustration switches.
- [ ] T056 [P] [US4] `lib/features/onboarding/presentation/welcome_screen.dart`: `Illustration(welcome)`
  above the title, inside the scroll view.
- [ ] T057 [P] [US4] `lib/features/settings/presentation/data_safety_screen.dart`:
  - `Illustration(dataSafety)`;
  - an info `StatusBanner` with `dataSafetyLocalOnly`;
  - on iOS only (`defaultTargetPlatform == TargetPlatform.iOS`), a warning banner with
    `dataSafetyIosManual`.
  Existing texts are reused.
- [ ] T058 [P] [US3] Home (`lib/features/home/presentation/home_screen.dart`,
  `lib/features/products/presentation/widgets/low_stock_card.dart`):
  - **Low stock:** the card becomes a warning `StatusBanner` with `lowStockCount` and a
    `lowStockSeeAll` action that opens the filtered product list. It is hidden when the count is 0.
  - **Summary card:** gets radiusXl and a skeleton while loading.
- [ ] T059 [P] [US4] Reports (`lib/features/reports/presentation/reports_screen.dart`,
  `lib/core/widgets/section_placeholder.dart`): the placeholder gains `Illustration(emptyReports)`
  and keeps its current text. Do not add `reportsEmptyBody`.
- [ ] T060 [US4] Tests:
  - **Starting app:** `test/core/widgets/starting_app_test.dart` shows the logo, the progress bar
    and the text.
  - **Blocking apps:** `startup_error_app` and `update_required_app` tests at 200%, in light and
    dark, with no overflow (US4-1, US4-2).
  - **Welcome:** the illustration is present and excluded from semantics.
  - **Data safety:** the banners with `debugDefaultTargetPlatformOverride` set to iOS and to
    Android (US4-3).
  - **Home:** the banner opens the filtered list (US3-1).
- [ ] T061 Gate: analyze clean and all tests green. Commit `feat(005): phase 6 whole-app screens`
 .

## Phase 7: Polish (US5, cross-cutting)

- [ ] T062 `test/helpers/screens.dart` (`visitEveryScreen`): add the empty, no-results, load-failed
  and banner states using the failing and seeded fakes, plus the starting app. Update the counts in
  `test/app/semantics_labels_test.dart`, `layout_stress_test.dart` and `text_scale_test.dart`.
- [ ] T063 Run the every-screen walks in both themes (add a dark pass if the walks only run light).
  Fix any overflow, missing label or unreadable pair (US5-1, FR-022, SC-001).
- [ ] T064 [P] Sweep the code:
  - `grep -rn "SnackBar(\|AlertDialog(" lib/features` returns nothing;
  - no list has a bare spinner except pickers;
  - every save button is a `SaveButton`;
  - every status mark is a `StatusBadge` (SC-003).
- [ ] T065 [P] Run `test/architecture/import_rules_test.dart` and `test/l10n/arb_test.dart`, and
  confirm no new `Color(`/`TextStyle(`/left/right outside `core/theme`.
- [ ] T066 Build the debug APK with `flutter build apk --debug`. If a phone is connected, run the
  quickstart phone steps 1–9. If not, list them for the owner.
- [ ] T067 Final gate: analyze clean, full suite green, APK built. Commit `feat(005): phase 7
  polish`. Never push.

## Dependencies

- **Phase order:** Phase 1 → Phase 2 → Phase 3 → {Phase 4, Phase 5, Phase 6} → Phase 7.
- **Phase 4:** T027 (the R13 keys) comes before T031–T041. T028–T030 can start earlier.
- **Phases 4, 5 and 6:** they touch mostly different files and could run in any order. Shared
  files are the details screens (T033, T040, T049) and `new_sale_screen.dart` (T045, T047, T049),
  so run them in plan order: 4 → 5 → 6.
- **Inside a phase:** cubit changes come before screens, and screens before their tests.

## Parallel examples

- **Phase 1:** T002 and T003 together, then T004.
- **Phase 3:** T015–T024 are separate files and can all run in parallel after T014.
- **Phase 4:** after T028 and T030, T034–T040 run in parallel (separate screens).
- **Phase 6:** T055–T059 run in parallel after T054.

## Implementation strategy

- **MVP:** phases 1–4. These give US2 (empty, loading and failed lists), the US3 row marks and the
  US1 archive undo across every list, which is the most visible part of the feature.
- **Next:** phase 5 completes US1 and US3 in forms, and phase 6 adds US4.
- **Close:** phase 7 proves US5 on every screen.
- **Review:** each phase stops at its gate for the owner's review.
