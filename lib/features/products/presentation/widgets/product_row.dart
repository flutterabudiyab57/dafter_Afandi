import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/product.dart';
import 'stock_marks.dart';
import 'unit_label.dart';

/// One product in a list: name, sale price, stock and marks. Tapping opens
/// its details. The details wrap, so nothing is cut at 200% text.
class ProductRow extends StatelessWidget {
  const ProductRow({required this.summary, this.onTap, super.key});

  final ProductSummary summary;

  /// Replaces opening the details, e.g. to pick the product for a sale.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = summary.product;
    final tokens = context.tokens;
    final stockColor = summary.isBelowZero
        ? Theme.of(context).colorScheme.error
        : summary.isLow
        ? context.appColors.owes
        : null;
    return ListTile(
      title: Text(p.name),
      subtitle: Wrap(
        spacing: tokens.spaceMd,
        runSpacing: tokens.spaceXs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(context.money(p.salePricePiasters)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StockMarks(summary: summary),
              if (summary.isLow) SizedBox(width: tokens.spaceXs),
              Text(
                context.quantity(summary.stockMilli, p.unit),
                style: TextTheme.of(context).bodyMedium
                    ?.copyWith(color: stockColor),
              ),
            ],
          ),
        ],
      ),
      trailing: onTap == null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap ?? () => context.push(RoutePaths.productDetails(p.id)),
    );
  }
}
