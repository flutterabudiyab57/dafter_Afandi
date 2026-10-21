import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/product.dart';

/// The low-stock and below-zero marks of a product, each an icon with a
/// spoken label (FR-008, FR-018).
class StockMarks extends StatelessWidget {
  const StockMarks({required this.summary, super.key});

  final ProductSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (summary.isBelowZero)
          Icon(
            Icons.remove_circle_outline,
            color: colors.error,
            semanticLabel: l10n.markBelowZero,
          )
        else if (summary.isLow)
          Icon(
            Icons.warning_amber_rounded,
            color: context.appColors.owes,
            semanticLabel: l10n.markLowStock,
          ),
      ],
    );
  }
}
