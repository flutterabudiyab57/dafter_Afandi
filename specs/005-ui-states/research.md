# Research: UI States and Visual Polish

Inputs: [spec.md](spec.md), `docs/design/DESIGN-HANDOFF.md` (the handoff), and the code as of
`03f96b8` (004 complete). The handoff gives exact values; this file records how they fit the
existing code and the decisions the handoff left open.

## R1. Where the new colors live

**Decision**: add the twelve success / warning / info fields of handoff 3.1 to `AppColors`, with
`copyWith` and `lerp`, next to `owes`, `credit` and `voided`. The new hex values go in `AppPalette`
(only `lib/core/theme/` may write `Color(`). Errors keep `colorScheme.error*`. No existing value
changes.

**Rationale**: screens already read semantic colors through `context.appColors`, and the
import-rules test keeps `Color(` inside `core/theme`.

**Alternatives**: Material's `tertiary` for success (rejected: tertiary is the credit teal and the
roles would blur); a second ThemeExtension (rejected: two lookups for one concept).

## R2. New tokens and their scaling

**Decision**: `AppRadii.xl = 28`, `AppSpacing.illustration = 192`, exposed as
`AppTokens.radiusXl` and `AppTokens.illustrationWidth`. Both scale with `AppTokens.scaled()` like
every other size. Illustration height is always width × 200 / 240.

**Rationale**: tokens already scale by the design factor; a fixed 192 would be too big on small
phones.

## R3. Component themes set once

**Decision**: handoff 3.3 goes into `_theme()` in `app_theme.dart` as the component themes listed
there: buttons, inputs, snackbar, dialog, navigation bar, chip, FAB, card and app bar. Screens then
drop their per-widget styling where it repeats the theme. For example, the `border:
OutlineInputBorder()` on search fields goes, because the input theme already gives it. Shape
radii read `AppRadii` (design px). The theme is built before `AppTokens` is available to widgets,
so it uses the same scale argument `_theme(scheme, scale)` already receives.

**Rationale**: FR-019. One place to change the look; screens stay free of styling.

## R4. Illustrations: bitmaps, resolution folders, one widget

**Decision**:
- **Copy:** copy `docs/design/assets/illustrations/png/{light,dark}/` to
  `assets/illustrations/{light,dark}/`, keeping `2.0x/` and `3.0x/`.
- **Register:** list both folders under `flutter: assets:` in `pubspec.yaml`. This is not a package
  change, and the owner approved it (Q3).
- **Enum:** `AppIllustration` holds the 19 names, with `assetPath(Brightness)` mapping camelCase to
  snake_case.
- **Widget:** `Illustration` shows it through `Image.asset`, with `excludeFromSemantics: true`.
- **Missing file:** an `errorBuilder` returns an empty box of the same size, so the state still
  shows its text (spec edge case).
- **Asset test:** a test checks that every value has all six files on disk.
- **Out of the app:** the SVG sources stay in `docs/design`.

**Rationale**: no `flutter_svg` (constitution V; spec assumption). Flutter picks 2x or 3x by device
pixel ratio.

**Alternatives**: SVG at runtime (rejected: new package); drawing the scenes in code (rejected:
months of work, no gain).

## R5. Shared widgets in `lib/core/widgets/`

**Decision**: the handoff 5 set, in `lib/core/widgets/`:
- `StatusBanner` and `StatusTone`
- `showAppSnackBar`
- `StatusBadge` and `BadgeTone`
- `EmptyState`
- `ResultView`
- `SkeletonList`
- `showConfirmDialog`
- `SaveButton` (the save-button loading state)
- `LoadFailedView` (the load-error state of R7)

All of them take every string from the caller, read colors from `colorScheme` / `appColors`, sizes
from `context.tokens`, and use directional padding. The exact APIs are in
[contracts/ui-components.md](contracts/ui-components.md).

**Rationale**: FR-001 to FR-012 repeat on about 30 screens. Shared widgets keep one look and one
set of tests.

## R6. Bottom messages: newest replaces, undo, durations

**Decision**: `showAppSnackBar` calls `hideCurrentSnackBar()` before showing. It shows for 4 s, or
10 s with an action, and the floating style comes from the theme. Each existing `SnackBar(` call
(48 in 17 files) moves to it with a tone.

**Rationale**: FR-003. The edge case "several messages at once" means a stacked queue is wrong.

## R7. Loading, empty and load-failed states for lists

**Decision**:
- **Load state:** every list cubit that subscribes to a stream gets `loadFailed` (bool) and
  `retry()`. Today `onError: addError` leaves the screen loading forever.
  - **On error:** the cubit sets `loadFailed: true, loading: false` and still reports the error
    with `addError`.
  - **retry():** subscribes again.
  - **Cubits affected:** product list, archived products, categories, low stock, stock history,
    sales list, customers list, archived customers, statement, suppliers list, archived suppliers,
    supplier statement, and purchases list.
- **Screen rule, one for all lists:**
  - **Load failed:** show `LoadFailedView` with "إعادة المحاولة".
  - **Loading with no items:** show `SkeletonList`, which shows nothing for its first 300 ms
    (FR-010).
  - **No items:** show `EmptyState` with the list's illustration. When a search or filter is
    active it shows `emptySearch` with "مسح البحث" instead (FR-009).
- **Pickers:** they keep a small spinner. They are not lists the owner manages, and a skeleton
  under a search box adds noise.

**Rationale**: FR-008 to FR-011. Today a failing stream shows a spinner forever.

**Alternatives**: one generic `ListLoadState<T>` class shared by all cubits (rejected: each
cubit's state already has different fields, and a mixin would need the same edits anyway).

## R8. Status marks with words

**Decision**: `StatusBadge` is a stadium chip with an icon and a word. It replaces:
- the icon-only `StockMarks` (low stock → `BadgeTone.owes` + "مخزون قليل" (`markLowStock`); below zero →
  `BadgeTone.error` + the existing below-zero word);
- the colored text marks in `SaleRow`, `PurchaseRow`, customer and supplier rows (credit,
  partly paid, voided, archived).

Balances keep their amount text and add the badge only where the row has room. At 200% the
badge wraps under the title instead of shrinking it.

**Rationale**: FR-002 and FR-014. Today the low-stock and below-zero marks are icons that only a
screen reader names.

## R9. Unsaved-changes guard on forms

**Decision**:
- **Cubits:** each form cubit gets `bool get hasUnsavedChanges`. It compares the current
  field texts with a snapshot taken when the form became editable (after loading in edit mode),
  and is false once the form is saved.
- **Widget:** a shared `UnsavedChangesGuard(dirty:, child:)` wraps `PopScope` and asks with
  `showConfirmDialog` (warning tone, `discardChangesTitle` / `discardChangesBody`,
  `keepEditingAction` / `discardAction`).
- **Forms:**
  - product form;
  - opening stock;
  - stock adjustment;
  - customer and supplier forms;
  - customer and supplier payments;
  - shop profile edit.
- **New sale and new purchase:** they keep their existing line-based guards (003, 004) and only
  move to the shared dialog look. They keep their own wording ("تجاهل هذا البيع؟"), which says
  more than the generic one.

**Rationale**: FR-013 and the edge case "a form that was opened and not changed leaves without a
question".

## R10. Save buttons

**Decision**: `SaveButton(label, saving, onPressed)` shows an 18 px spinner and "جارٍ الحفظ…" while
`saving`, and is disabled. It replaces each form's `FilledButton(onPressed: saving ? null : …)`.

**Rationale**: FR-012. Today the button only greys out, with no word.

## R11. Banners in forms

**Decision**:
- **Save errors:** a failed save (`errorSaveFailed`, product or customer unavailable, supplier
  unavailable) shows an error `StatusBanner` at the top of the form. It replaces the red text
  above the Save button. The page scrolls to the top so the banner is seen.
- **Blocking rules:** rules that block saving but lose nothing show a warning banner with an
  action. Examples: credit with no customer or supplier ("اختيار" opens the picker), and paid
  above the total.
- **Field errors:** these stay under their fields.

**Rationale**: FR-005 and FR-006. Today these messages sit above the Save button, below the
fold at 200%.

## R12. Whole-app screens

**Decision**:
- **Startup error and update required:** `BlockingAppShell` (Arabic, RTL, no routes) shows its
  content through `ResultView`, with `errorDatabase` and `updateRequired` and their existing texts.
- **App start:** `bootstrap()` first runs a `StartingApp` built on the same Arabic-only shell: the
  logo, a `LinearProgressIndicator` and `openingDataLabel`. Then it opens the database and replaces
  it with the real app or a blocking app. Before the database opens the chosen language is not
  known, so this screen is in Arabic like the other blocking apps. The native splash stays as it
  is.
- **Welcome:** shows the `welcome` illustration above its title.
- **Data safety:** shows the `dataSafety` illustration, an info banner (`dataSafetyLocalOnly`), and
  on iOS a warning banner (`dataSafetyIosManual`).
- **Home:** the low-stock card becomes a warning banner with `lowStockSeeAll`.
- **Reports:** the reports feature does not exist yet, so it keeps its placeholder text and only
  gains the `emptyReports` illustration. `reportsEmptyBody` is deferred to the reports feature, so
  no unused key is added now.

## R13. Strings

**Decision**: add the 18 approved keys of handoff 7 that are used here (`reportsEmptyBody` is
deferred, R12) to `app_ar.arb` and `app_en.arb`. Reuse existing keys as handoff 7 lists.

The undo and load-failed states need texts the handoff does not list. The owner approved the five
below as written on 2026-10-22. The Arabic is MSA.

| key | ar | en |
| --- | --- | --- |
| `productArchivedMessage` | أُرشف المنتج. | Product archived. |
| `customerArchivedMessage` | أُرشف العميل. | Customer archived. |
| `supplierArchivedMessage` | أُرشف المورد. | Supplier archived. |
| `loadFailedTitle` | تعذّر عرض البيانات | Couldn’t show the data |
| `loadFailedBody` | لم يتغيّر شيء في بياناتك. حاول مرة أخرى. | Nothing in your data changed. Try again. |

## R14. Tests

**Decision**:
- **Theme:**
  - `theme_test.dart` checks every new tone pair at ≥ 4.5:1 in both themes;
  - it reads a few component themes back, e.g. the snackbar background is `inverseSurface`.
- **Shared widgets:** each widget has tests in ar and en at text scale 1.0 and 2.0, plus:
  - `SkeletonList` is hidden before 300 ms and does not shimmer under `disableAnimations`;
  - `showAppSnackBar` replaces an older message;
  - the banner is a live region.
- **Assets:** a test checks that every illustration file exists.
- **Every-screen walk:** `visitEveryScreen` gains the empty, load-failed and banner states
  (seeded fakes with a failing stream), and its count in `test/app/` is updated.
- **Existing widget tests:** they keep their finders on texts. Where a mark moved from an icon to
  a badge, the test looks for the word.

**Rationale**: SC-001 to SC-007; the constitution's quality gates.
