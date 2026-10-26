# Implementation Plan: UI States and Visual Polish

**Branch**: `005-ui-states` | **Date**: 2026-10-22 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/005-ui-states/spec.md`, and the design handoff
`docs/design/DESIGN-HANDOFF.md`.

## Summary

Every screen shows the same, finished states: success, warning, error, info, empty, no results,
loading, load failed, saving, and voided or archived. It does so in light and dark themes, in
Arabic and English, at any text size. The work:

- **Theme:** three feedback tones in `AppColors`, `radiusXl` and `illustrationWidth` tokens, and
  component themes set once in `app_theme.dart`.
- **Illustrations:** the 19 original PNGs from `docs/design`, shown through one `Illustration`
  widget.
- **Shared widgets:** in `lib/core/widgets/`: banner, bottom message, badge, empty state, result
  view, skeleton, confirm dialog, save button, load-failed view and unsaved-changes guard.
- **Load states:** list cubits gain a load-failed state with retry.
- **Screens:** each one moves to the shared widgets, following the handoff's screen table.

No data, schema, financial rule or package changes. The only `pubspec.yaml` change is the two
asset folders, which the owner approved (Q3). Details: [research.md](research.md),
[data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md).

## Technical Context

**Language/Version**: Dart 3.13.5 on Flutter 3.47.7 stable

**Primary Dependencies**: unchanged (material_ui, flutter_bloc, go_router, get_it, equatable,
flutter_screenutil; dev: bloc_test, mocktail).

**Storage**: none touched. Schema v1 unchanged.

**Testing**:
- theme contrast and component-theme tests;
- an asset-existence test;
- widget tests for each shared widget in ar and en at text scale 1.0 and 2.0;
- cubit tests for load-failed and retry and for `hasUnsavedChanges`;
- the existing screen tests updated where a mark moved from an icon to a word;
- the every-screen semantics, layout-stress and text-scale walks extended with empty, load-failed
  and banner states.

**Target Platform**: Android minSdk 24; iOS 15+. Phones, portrait.

**Project Type**: mobile app (Flutter), feature-first.

**Performance Goals**: no loading placeholder for loads under 300 ms (SC-006). Illustrations
decode from 2x and 3x PNGs of at most 720×600 px.

**Constraints**:
- offline;
- RTL-safe layout;
- no `Color(`, `TextStyle(` or `EdgeInsets.only` outside `core/theme`;
- no text-scale clamp;
- reduced motion respected.

**Scale/Scope**:
- about 30 screens and 8 dialogs touched;
- 10 shared widgets;
- about 13 list cubits and 9 form cubits;
- 23 approved ARB keys (18 from the handoff, 5 from R13);
- 114 PNG files.

## Constitution Check

| Principle / rule | Status | Evidence / note |
|---|---|---|
| I. Local-first; no network | PASS | No network code; illustrations are bundled assets. |
| II. Arabic-first; strings in ARB | PASS | New texts go in both ARB files; widgets take every string from the caller; MSA. |
| II. Never "tax receipt" | PASS | No document titles change. |
| III. Data integrity | N/A | No data, money or quantity path changes; formatting keeps using `core/utils`. |
| IV. Feature-first, strict layers | PASS | Shared widgets live in `core/widgets` and import no feature. Feature screens import them. Cubits gain UI state only. |
| V. material_ui only; no new package | PASS | No package added. The PNGs are shown with `Image.asset`, with no `flutter_svg` (R4). The asset list change was approved in Q3. |
| Schema change via make-migrations | N/A | No schema change. |
| Technical rules: RTL, text scale | PASS | `EdgeInsetsDirectional` and start/end only; 200% walks extended (R14). |
| Quality gates | PASS | Each phase ends with analyze clean and all tests green. |
| Workflow: agent never commits | PASS (B1) | The owner approved B1 for 005 on 2026-10-22: the agent commits once at each phase gate and never pushes or merges. |

**Owner approvals** (2026-10-22):
1. **B1 for 005:** the agent commits once at each phase gate. It never pushes or merges.
2. **The 5 keys in research R13:** approved with the texts as written.

**Post-design re-check**: unchanged. No violation needs a justification.

## Project Structure

### Documentation (this feature)

```text
specs/005-ui-states/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/ui-components.md
├── checklists/requirements.md
└── tasks.md             (/speckit-tasks)
```

### Source Code (repository root)

```text
assets/illustrations/{light,dark}/[2.0x/|3.0x/]<name>.png   (new, copied from docs/design)
pubspec.yaml                                         (two asset folders)
lib/core/theme/app_colors.dart                       (12 tone fields, palette values)
lib/core/theme/app_radii.dart, app_spacing.dart, app_tokens.dart   (radiusXl, illustrationWidth)
lib/core/theme/app_theme.dart                        (component themes)
lib/core/widgets/app_illustration.dart               (enum + Illustration)
lib/core/widgets/status_banner.dart                  (StatusTone, StatusBanner)
lib/core/widgets/app_snack_bar.dart                  (showAppSnackBar)
lib/core/widgets/status_badge.dart                   (BadgeTone, StatusBadge)
lib/core/widgets/empty_state.dart, result_view.dart, skeleton_list.dart
lib/core/widgets/confirm_dialog.dart, save_button.dart, load_failed_view.dart
lib/core/widgets/unsaved_changes_guard.dart
lib/core/widgets/blocking_app_shell.dart, startup_error_app.dart, update_required_app.dart
lib/core/widgets/starting_app.dart                   (new) + lib/bootstrap.dart
lib/core/widgets/section_placeholder.dart            (illustration)
lib/features/*/presentation/cubits/*                 (loadFailed + retry; hasUnsavedChanges)
lib/features/*/presentation/screens|widgets/*        (shared widgets adopted)
lib/core/l10n/arb/app_ar.arb, app_en.arb
test/core/theme/theme_test.dart, test/core/widgets/*, test/core/assets/illustrations_test.dart
test/helpers/screens.dart, test/app/*
```

**Structure Decision**: the existing feature-first layout. Shared UI goes in `lib/core/widgets`,
theme values in `lib/core/theme`, and nothing new in `domain/` or `data/`.

## Implementation phases

| Phase | Content | Gate |
|---|---|---|
| **1. Theme** | `AppColors` tones, `radiusXl`, `illustrationWidth`, component themes (R1–R3); remove per-widget styling the theme now covers | contrast and theme tests; analyze + all tests green |
| **2. Assets** | copy PNGs, pubspec asset folders, `AppIllustration` + `Illustration` (R4) | asset-existence test |
| **3. Shared widgets** | the 10 widgets of R5, R6, R9 and R10; the 18 approved ARB keys | widget tests ar/en × 1.0/2.0 |
| **4. Lists** | load-failed + retry in list cubits; empty, no-results, skeleton and load-failed on every list; `StatusBadge` replaces marks; archive undo (R7, R8, R13 keys) | cubit and screen tests |
| **5. Forms** | `SaveButton`, error and warning banners, `UnsavedChangesGuard`, `showAppSnackBar` everywhere, dialogs to `showConfirmDialog` (R6, R9–R11) | screen tests; existing 003/004 flows green |
| **6. Whole-app screens** | starting app, startup error, update required, welcome, data safety, home banner, reports illustration (R12) | screen tests |
| **7. Polish** | every-screen walk with the new states; dark mode on a phone if connected; debug APK | full gate |

Every phase stops for review at its gate.
