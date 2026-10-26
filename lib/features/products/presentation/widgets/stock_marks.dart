import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/product.dart';

/// The low-stock or below-zero mark of a product, as a badge with a word
/// (FR-002, research R8). Nothing when the stock is fine.
class StockMarks extends StatelessWidget {
  const StockMarks({required this.summary, super.key});

  final ProductSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (summary.isBelowZero) {
      return StatusBadge(label: l10n.markBelowZero, tone: BadgeTone.error);
    }
    if (summary.isLow) {
      return StatusBadge(label: l10n.markLowStock, tone: BadgeTone.owes);
    }
    return const SizedBox.shrink();
  }
}
