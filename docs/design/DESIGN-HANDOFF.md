# Daftar Afandi — UI states and visual design: handoff for Claude Code

This file is the brief for adding the new visual layer to the app: feedback states (success, warning, error, info), empty and result screens, loading, the illustration set and the component styling. Put it into the plan as its own feature (suggested name `specs/005-ui-states/`) and run it through the usual Spec Kit flow: specify → plan → tasks → implement, one phase at a time.

`.specify/memory/constitution.md` and `CLAUDE.md` still win over anything here. Nothing in this brief needs a new package.

## 1. Sources

| what | where |
| --- | --- |
| Design system (tokens, components with live previews, states, illustrations, screens) | https://claude.ai/artifact/4CMWRYbhV2E9j14EiFToas |
| Earlier screen mock-ups (14 screens) | https://claude.ai/artifact/7qibAr9AEY3YcuunC6s6rU |
| Illustration sources (SVG) | `docs/design/assets/illustrations/svg/{light,dark}/<name>.svg` |
| Illustrations ready for Flutter (PNG 1x, 2x, 3x) | `docs/design/assets/illustrations/png/{light,dark}/[2.0x/ 3.0x/]<name>.png` |
| This brief | `docs/design/DESIGN-HANDOFF.md` |

Read the design system's README, the `states` section and each component card before building the matching widget. The colors in the design system are the exact values below; never copy a value from a screenshot.

## 2. Decisions for the owner before implementation

Ask, don't assume:

1. **pubspec `flutter: assets:` entries** for `assets/illustrations/light/` and `assets/illustrations/dark/` (an asset list change, not a package change).
2. **New `AppColors` fields** (section 3) and **`AppTokens.radiusXl` / `illustrationWidth`**.
3. **New ARB keys** (section 7). The Arabic is written; the owner may want to change the wording.
4. **Sale-saved moment**: keep today's flow (snackbar "تم حفظ الفاتورة ١٢٤." and then the invoice), or add the full-screen `ResultView`. The brief assumes the snackbar; ResultView is optional.
5. **No SVG at runtime.** The app shows the PNG exports with `Image.asset`. Showing the SVGs directly would need `flutter_svg`, which is a new package and is not requested.

## 3. Theme changes (`lib/core/theme/` only)

### 3.1 `AppColors`: add four feedback tones

Add these fields, next to `owes`/`credit`/`voided`, with `copyWith` and `lerp` entries, and extend `test/core/theme/theme_test.dart` so every text pair below is checked at ≥4.5:1 in both themes (`on-…` on its fill, `on-…-container` on its container, the tone on `surface`).

| field | light | dark | use |
| --- | --- | --- | --- |
| `success` | `#1E6A66` | `#7FCFC8` | icon fill and text on surface: saved, paid |
| `onSuccess` | `#FFFFFF` | `#003734` | glyph on a success fill |
| `successContainer` | `#DDF0EE` | `#0E3B38` | banner, badge, snackbar dot |
| `onSuccessContainer` | `#0B3A37` | `#A6EFE8` | text on successContainer |
| `warning` | `#8F4A00` | `#F2B872` | needs attention, nothing lost |
| `onWarning` | `#FFFFFF` | `#452B00` | |
| `warningContainer` | `#FCEBD7` | `#4A2A05` | |
| `onWarningContainer` | `#4A2700` | `#FFDDB3` | |
| `info` | `#35597A` | `#A9C8E6` | tips and rules |
| `onInfo` | `#FFFFFF` | `#0B2740` | |
| `infoContainer` | `#E1EAF2` | `#1D3346` | |
| `onInfoContainer` | `#12304A` | `#D6E6F5` | |

Errors keep using `colorScheme.error`, `errorContainer` and `onErrorContainer`. All existing scheme and `AppColors` values stay exactly as they are; the design system mirrors them.

The design system's contrast check passed 96 of 96 pairs (48 pairs × 2 themes), including these.

### 3.2 `AppTokens` / `AppRadii`

- `radiusXl = 28` (dialogs, bottom sheets, the home summary card).
- `illustrationWidth = 192` (empty states; height = width × 200 / 240).
- Spacing and the other radii already match (`4/8/16/24/32`, `8/12/16`).

### 3.3 Component themes in `app_theme.dart`

Set these once in `_theme()` so screens don't style widgets one by one:

- `filledButtonTheme`, `outlinedButtonTheme`, `textButtonTheme`: `StadiumBorder`, `minimumSize: Size(64, 48)`, label 14/600.
- `inputDecorationTheme`: outlined, `radiusMd`, `fillColor: surfaceContainerLowest`, `filled: true`, enabled border `outline` 1px, focused `primary` 2px, error `error` 2px, `errorMaxLines: 3`.
- `snackBarTheme`: `behavior: floating`, `backgroundColor: inverseSurface`, `actionTextColor: inversePrimary`, shape `radiusSm`.
- `dialogTheme`: `backgroundColor: surfaceContainerHigh`, shape `radiusXl`.
- `navigationBarTheme`: `backgroundColor: surfaceContainer`, `indicatorColor: secondaryContainer`, selected label 12/700.
- `chipTheme`: shape `radiusSm`, selected `secondaryContainer`.
- `floatingActionButtonTheme`: `backgroundColor: primary`, `foregroundColor: onPrimary`, shape `radiusLg`.
- `cardTheme`: `elevation: 0`, `color: surfaceContainerLowest`, border `outlineVariant` 1px, shape `radiusLg`.
- `appBarTheme`: `centerTitle: false`, `scrolledUnderElevation: 0`, `backgroundColor: surface`.

Add a theme test that reads a few of these back (e.g. the snackbar background equals `inverseSurface` in both themes).

## 4. Illustrations

1. Copy `docs/design/assets/illustrations/png/light/` → `assets/illustrations/light/` and `png/dark/` → `assets/illustrations/dark/`, keeping the `2.0x/` and `3.0x/` folders (Flutter picks the density itself).
2. Register both folders in `pubspec.yaml` (after the owner approves, section 2).
3. Add `lib/core/widgets/app_illustration.dart`:

```dart
enum AppIllustration {
  welcome, emptyProducts, emptySales, emptyCustomers, emptySuppliers,
  emptyPurchases, emptySearch, emptyReports, emptyArchive, successSale,
  successPayment, successSaved, errorGeneric, errorDatabase, warningLowStock,
  warningUnsaved, dataSafety, updateRequired, infoTip;

  /// snake_case file name, e.g. emptyProducts -> empty_products.png
  String assetPath(Brightness brightness) => ...;
}

class Illustration extends StatelessWidget {
  const Illustration(this.kind, {super.key, this.width});
  final AppIllustration kind;
  final double? width; // default context.tokens.illustrationWidth
  // Image.asset(kind.assetPath(Theme.of(context).brightness),
  //   width: w, height: w * 200 / 240, excludeFromSemantics: true)
}
```

4. Add a test that every enum value has a light and a dark PNG at 1x, 2x and 3x on disk.

The 19 files: `welcome`, `empty_products`, `empty_sales`, `empty_customers`, `empty_suppliers`, `empty_purchases`, `empty_search`, `empty_reports`, `empty_archive`, `success_sale`, `success_payment`, `success_saved`, `error_generic`, `error_database`, `warning_low_stock`, `warning_unsaved`, `data_safety`, `update_required`, `info_tip`.

## 5. Shared widgets (`lib/core/widgets/`)

Each widget reads colors only from `colorScheme` / `context.appColors`, sizes from `context.tokens`, uses `EdgeInsetsDirectional`, takes every string from the caller (no literals) and works at 200% text in Arabic and English. Each gets widget tests in both locales at text scales 1.0 and 2.0.

| widget | API | notes |
| --- | --- | --- |
| `StatusBanner` | `StatusBanner({required StatusTone tone, required String title, String? message, String? actionLabel, VoidCallback? onAction})` | `enum StatusTone { success, warning, error, info }`; filled icons `check_circle`, `warning`, `error`, `info`; `Semantics(liveRegion: true)`; radiusMd; padding 14/16. |
| `showAppSnackBar` | `void showAppSnackBar(BuildContext context, String message, {StatusTone tone = StatusTone.success, String? actionLabel, VoidCallback? onAction})` | 4 s; 10 s with an action; a 24px dot in the tone's container color with the on-container glyph. |
| `StatusBadge` | `StatusBadge({required String label, required BadgeTone tone, IconData? icon})` | `enum BadgeTone { success, owes, credit, error, voided, neutral }`; stadium, 12/600, padding 4/10. |
| `EmptyState` | `EmptyState({required AppIllustration illustration, required String title, String? message, Widget? action})` | centered, max width 360, never inside a card. |
| `ResultView` | `ResultView({required AppIllustration illustration, required String title, required String message, required Widget primary, Widget? secondary})` | full screen; used by `startup_error_app.dart`, `update_required_app.dart`. |
| `SkeletonList` | `SkeletonList({int rows = 4})` | rows the height of real rows; shimmer stops under `MediaQuery.disableAnimations`; shown only after 300 ms. |
| `ConfirmDialog` | `Future<bool?> showConfirmDialog(context, {required StatusTone tone, required String title, required String message, required String confirmLabel, required String cancelLabel, bool destructive = false})` | danger button last; `reason_dialog.dart` keeps its reason field and gets the same look. |
| Save button loading | in each form | spinner 18px + label, disabled while saving. |

`stock_marks.dart`, `product_row.dart`, `sale_row.dart`, `purchase_row.dart` and the customer and supplier rows switch their marks to `StatusBadge`.

## 6. Screen-by-screen states

| screen (file) | empty | loading | success | warning / error |
| --- | --- | --- | --- | --- |
| Welcome (`welcome_screen.dart`) | — | — | — | `welcome` illustration above the title |
| Home (`home_screen.dart`) | summary with zeros | skeleton cards | — | low-stock `StatusBanner` warning (`lowStockCount`, `lowStockSeeAll`) |
| Products (`product_list_screen.dart`) | `emptyProducts` + `productsEmpty` / `productsEmptyAction` | `SkeletonList` | snackbar after archive with Undo | rows: low → `StatusBadge.owes`, below zero → `StatusBadge.error` |
| Products filtered / searched | `emptySearch` + `productsFilterEmpty` + clear action | — | — | — |
| Archived products / customers / suppliers | `emptyArchive` + existing keys | `SkeletonList` | snackbar after restore | `errorRestoreBarcodeTaken` as error banner |
| Categories (`categories_screen.dart`) | `emptyProducts` + `categoriesEmpty` | — | snackbar | field errors |
| Product form, opening stock, stock adjustment | — | save button | snackbar / `adjustSaved` banner | field errors; `errorSaveFailed` error banner; unsaved-changes dialog (`warningUnsaved`) |
| Product details stock history | text `historyEmpty` | skeleton rows | — | below-zero rows in `error` |
| Sales list (`sales_list_screen.dart`) | `emptySales` + `salesListEmpty` | `SkeletonList` | — | voided rows `StatusBadge.voided` |
| New sale (`new_sale_screen.dart`) | `saleEmpty` inline | save button | snackbar `saleSaved` | `errorCreditNeedsCustomer`, `errorPaidTooLarge` → warning banner at top + field error; product or customer no longer available → error banner |
| Invoice (`invoice_screen.dart`) | — | — | arrives with the `saleSaved` snackbar | void → `ConfirmDialog` destructive (`invoiceVoidTitle`, `invoiceVoidBody`) then snackbar `invoiceVoided`; voided banner uses `voided` |
| Customers / suppliers lists | `emptyCustomers` / `emptySuppliers` | `SkeletonList` | snackbar | balances `owes` / `credit` |
| Customer / supplier details, payment | — | save button | snackbar after payment (`successPayment` not needed in a snackbar) | field errors |
| Purchases (`purchases_screen.dart`), new purchase | `emptyPurchases` | `SkeletonList` | snackbar | same rules as new sale |
| Reports (`reports_screen.dart`) | `emptyReports` | skeleton | — | — |
| Data safety (`data_safety_screen.dart`) | — | — | — | `dataSafety` illustration; `dataSafetyLocalOnly` info banner; `dataSafetyIosManual` warning banner on iOS |
| Startup error (`startup_error_app.dart`) | — | — | — | `ResultView` + `errorDatabase` + `startupErrorBody` |
| Update required (`update_required_app.dart`) | — | — | — | `ResultView` + `updateRequired` + `updateRequiredTitle` / `updateRequiredBody` |
| App start | — | logo + `LinearProgressIndicator` | — | — |

## 7. New ARB keys (both `app_ar.arb` and `app_en.arb`)

| key | ar | en |
| --- | --- | --- |
| `customersEmptyTitle` | لا يوجد عملاء بعد | No customers yet |
| `customersEmptyBody` | أضف عميلًا لتسجّل البيع الآجل وتتابع ما عليه. | Add a customer to record credit sales and track what they owe. |
| `suppliersEmptyTitle` | لا يوجد موردون بعد | No suppliers yet |
| `suppliersEmptyBody` | أضف موردًا لتسجّل مشترياتك وما عليك له. | Add a supplier to record purchases and what you owe them. |
| `purchasesEmptyTitle` | لا توجد مشتريات بعد | No purchases yet |
| `purchasesEmptyBody` | سجّل أول شراء ليزيد المخزون وتُحسب التكلفة. | Record your first purchase to add stock and track cost. |
| `reportsEmptyBody` | ستظهر التقارير بعد أول بيع. | Reports appear after your first sale. |
| `searchEmptyTitle` | لا توجد نتائج | No results |
| `searchClearAction` | مسح البحث | Clear search |
| `retryAction` | إعادة المحاولة | Try again |
| `undoAction` | تراجع | Undo |
| `savingLabel` | جارٍ الحفظ… | Saving… |
| `discardChangesTitle` | تجاهل التغييرات؟ | Discard changes? |
| `discardChangesBody` | لم تُحفظ التغييرات. إذا خرجت الآن فستضيع. | Your changes are not saved. If you leave now they will be lost. |
| `discardAction` | تجاهل | Discard |
| `keepEditingAction` | متابعة التعديل | Keep editing |
| `creditNeedsCustomerTitle` | اختر عميلًا للبيع الآجل | Choose a customer for a credit sale |
| `chooseAction` | اختيار | Choose |
| `openingDataLabel` | جارٍ فتح بياناتك… | Opening your data… |

Reuse existing keys wherever one fits (`productsEmpty`, `salesListEmpty`, `errorSaveFailed`, `saleSaved`, `invoiceVoided`, `startupErrorBody`, `updateRequiredBody`, …). `test/l10n/arb_test.dart` must stay green.

## 8. Suggested phases (for `tasks.md`)

1. **Theme**: `AppColors` tones, `radiusXl`, `illustrationWidth`, component themes; theme and contrast tests. Gate: analyze clean, tests green.
2. **Assets**: copy PNGs, pubspec entries (approved), `AppIllustration` + `Illustration`, asset-existence test.
3. **Shared widgets**: `StatusBanner`, `showAppSnackBar`, `StatusBadge`, `EmptyState`, `ResultView`, `SkeletonList`, `ConfirmDialog`; widget tests in ar/en at 1.0/2.0.
4. **Lists**: empty, loading and badge states in products, archived lists, categories, sales, customers, suppliers, purchases, reports.
5. **Forms**: saving, field errors, warning/error banners, unsaved-changes dialog in product form, stock adjustment, opening stock, new sale, new purchase, payment, shop profile.
6. **Whole-app screens**: startup error, update required, app-start loading, data safety, welcome, home summary card.
7. **Polish**: add new screens to `test/helpers/screens.dart` if any; run the semantics and layout-stress tests in `test/app/`; check dark mode on a device; commit at the gate (decision B1 pattern, no push).

## 9. Done means

- `flutter analyze` clean and `flutter test` green after every phase.
- `test/architecture/import_rules_test.dart` passes: no `Color(`, `TextStyle(`, `EdgeInsets.only` or left/right outside `lib/core/theme/`.
- Every screen in section 6 shows its states in both themes, both languages, at text scale 2.0, with no overflow.
- Every feedback state has an icon and a word as well as a color.
- Illustrations switch with the theme and are excluded from semantics.
- Screen readers announce banners and snackbars; field errors are tied to their fields.
