# Data Model: UI States and Visual Polish

No stored data changes. Schema v1, the repositories and the domain types stay as they are. This
file lists the presentation-level types and state fields the feature adds.

## Theme values

### AppColors (ThemeExtension), new fields

Values per theme are in handoff 3.1; each is checked in tests at ≥ 4.5:1.

| field | role |
|---|---|
| `success`, `onSuccess`, `successContainer`, `onSuccessContainer` | saved, paid, done |
| `warning`, `onWarning`, `warningContainer`, `onWarningContainer` | needs attention, nothing lost |
| `info`, `onInfo`, `infoContainer`, `onInfoContainer` | tips and rules |

The existing `owes`, `credit`, `voided`, `ornament` and their containers are unchanged. Errors use
`colorScheme.error*`.

### AppTokens, new fields

| field | design value | rule |
|---|---|---|
| `radiusXl` | 28 | dialogs, bottom sheets, the home summary card |
| `illustrationWidth` | 192 | scaled like every token; height = width × 200 / 240 |

## Enums

- **`StatusTone`**: `success`, `warning`, `error`, `info`. Each maps to a fill, an on-fill, a
  container, an on-container and a filled icon (`check_circle`, `warning`, `error`, `info`).
- **`BadgeTone`**: `success`, `owes`, `credit`, `error`, `voided`, `neutral`. Each maps to a
  container color, an on-container text color and a default icon.
- **`AppIllustration`**: the 19 scenes `welcome`, `emptyProducts`, `emptySales`,
  `emptyCustomers`, `emptySuppliers`, `emptyPurchases`, `emptySearch`, `emptyReports`,
  `emptyArchive`, `successSale`, `successPayment`, `successSaved`, `errorGeneric`,
  `errorDatabase`, `warningLowStock`, `warningUnsaved`, `dataSafety`, `updateRequired` and
  `infoTip`.
  - **Asset path:** `assetPath(Brightness)` returns
    `assets/illustrations/{light|dark}/<snake_case>.png`.
  - **Densities:** Flutter picks the 2x or 3x file from the sibling folders.

## Cubit state additions

### List cubits: load state

Applies to the list cubits named in research R7.

| field / method | meaning |
|---|---|
| `loadFailed: bool` | the stream reported an error; `loading` is false |
| `retry()` | clears `loadFailed`, sets `loading`, subscribes again |

**Transitions**:
- `loading` → `loaded`, or `loading` → `loadFailed`.
- `loadFailed` → (`retry`) → `loading`.
- A search or filter change subscribes again and clears `loadFailed`.

**What the screen shows**:

| state | screen shows |
|---|---|
| loadFailed | `LoadFailedView` with Retry |
| loading and no items | `SkeletonList` (after 300 ms) |
| no items, no query | `EmptyState` with the list's illustration |
| no items, with a search or filter | no-results `EmptyState` with Clear |
| items | the list |

### Form cubits: unsaved changes

Applies to the product form, opening stock, stock adjustment, customer and supplier forms, both
payment forms, and the shop profile form.

| member | meaning |
|---|---|
| `hasUnsavedChanges: bool` (getter) | a field differs from the snapshot taken when the form became editable, and the form is not saved |

New sale and new purchase keep `hasUnsavedLines` (003, 004).

## Strings

There are 18 approved keys (handoff 7, without `reportsEmptyBody`) and 5 more from research R13,
approved on 2026-10-22. They go in both `app_ar.arb` and `app_en.arb`.
