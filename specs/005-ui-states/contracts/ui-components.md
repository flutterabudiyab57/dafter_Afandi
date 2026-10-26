# Contracts: shared UI components and screen states

The components live in `lib/core/widgets/`. Each one:
- reads colors only from `colorScheme` and `context.appColors`;
- reads sizes from `context.tokens`;
- uses `EdgeInsetsDirectional`;
- takes every user-visible string from its caller;
- works at text scale 2.0 in Arabic and English.

Names may be refined during implementation; tasks.md will record the final ones.

## Components

```dart
enum StatusTone { success, warning, error, info }

/// In-page message with a filled icon; announced when it appears.
class StatusBanner extends StatelessWidget {
  const StatusBanner({required StatusTone tone, required String title,
      String? message, String? actionLabel, VoidCallback? onAction});
}

/// Replaces the current message; 4 s, or 10 s with an action.
void showAppSnackBar(BuildContext context, String message,
    {StatusTone tone = StatusTone.success, String? actionLabel, VoidCallback? onAction});

enum BadgeTone { success, owes, credit, error, voided, neutral }

/// Stadium chip: icon + word; never color alone.
class StatusBadge extends StatelessWidget {
  const StatusBadge({required String label, required BadgeTone tone, IconData? icon});
}

/// Centered, max width 360, never inside a card.
class EmptyState extends StatelessWidget {
  const EmptyState({required AppIllustration illustration, required String title,
      String? message, Widget? action});
}

/// Full screen: startup error, update required.
class ResultView extends StatelessWidget {
  const ResultView({required AppIllustration illustration, required String title,
      required String message, Widget? primary, Widget? secondary});
}

/// Placeholder rows of real row height; shown only after 300 ms; no
/// shimmer under MediaQuery.disableAnimations.
class SkeletonList extends StatefulWidget { const SkeletonList({int rows = 4}); }

/// Error state of a list, with Retry.
class LoadFailedView extends StatelessWidget {
  const LoadFailedView({required String title, required String message,
      required String retryLabel, required VoidCallback onRetry});
}

/// Destructive choice last. Null when dismissed.
Future<bool?> showConfirmDialog(BuildContext context, {required StatusTone tone,
    required String title, required String message, required String confirmLabel,
    required String cancelLabel, bool destructive = false});

/// Spinner 18 + savingLabel while saving; disabled then.
class SaveButton extends StatelessWidget {
  const SaveButton({required String label, required String savingLabel,
      required bool saving, required VoidCallback onPressed});
}

/// PopScope that asks before leaving when [dirty].
class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({required bool dirty, required Widget child});
}

class Illustration extends StatelessWidget {
  const Illustration(AppIllustration kind, {double? width}); // excluded from semantics
}
```

`ResultView` allows no buttons (`primary` and `secondary` are optional), because the blocking
apps have none.

## Screen states

The source of truth is handoff section 6, with these differences:
- **New sale and new purchase:** they keep their own discard wording.
- **Reports:** it keeps its placeholder, with the `emptyReports` illustration.
- **Every list:** each list also gets a load-failed state.
- **Sale-saved moment:** a snackbar, then the invoice (Q2).

| screen | empty | loading | load failed | success | warning / error |
|---|---|---|---|---|---|
| Products list | emptyProducts + add | skeleton | yes | archive → snackbar + Undo | low / below-zero badges |
| Products filtered/searched | emptySearch + Clear | — | — | — | — |
| Archived products/customers/suppliers | emptyArchive | skeleton | yes | restore → snackbar | barcode taken → error banner |
| Categories | emptyProducts + `categoriesEmpty` | skeleton | yes | snackbar | field errors |
| Product form, opening stock, adjustment | — | SaveButton | — | snackbar / banner | field errors; save-failed banner; unsaved guard |
| Stock history | `historyEmpty` text | skeleton rows | yes | — | below-zero rows |
| Sales list | emptySales | skeleton | yes | — | voided badge |
| New sale | `saleEmpty` | SaveButton | — | `saleSaved` snackbar | credit-needs-customer / paid-too-large warning banner; unavailable → error banner |
| Invoice | — | — | — | void → snackbar | destructive confirm; voided banner |
| Customers / suppliers lists | emptyCustomers / emptySuppliers | skeleton | yes | — | owes / credit badges |
| Customer / supplier details | — | — | statement: yes | archive → snackbar + Undo; payment snackbar | — |
| Payments (both) | — | SaveButton | — | snackbar | field errors; overpay confirm; unsaved guard |
| Purchases list | emptyPurchases | skeleton | yes | — | credit / partial / voided badges |
| New purchase | `saleEmpty` | SaveButton | — | `purchaseSaved` snackbar | as new sale, with supplier |
| Purchase | — | — | — | void → snackbar | destructive confirm; shortage warning; voided banner |
| Home | — | skeleton card | — | — | low-stock warning banner + See all |
| Reports | placeholder + emptyReports | — | — | — | — |
| Data safety | — | — | — | — | dataSafety illustration; info banner; iOS warning banner |
| Welcome | — | — | — | — | welcome illustration |
| App start | — | logo + progress + `openingDataLabel` | — | — | — |
| Startup error / update required | — | — | — | — | ResultView |
