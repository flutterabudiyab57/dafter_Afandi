import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/product.dart';
import '../cubits/low_stock_cubit.dart';
import 'stock_marks.dart';
import 'unit_label.dart';

/// The Home card: the products lowest on stock (FR-001a).
class LowStockCard extends StatelessWidget {
  const LowStockCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final snapshot = context.watch<LowStockCubit>().state;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.spaceMd,
              end: tokens.spaceMd,
              top: tokens.spaceMd,
            ),
            child: Text(
              l10n.lowStockCardTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          ..._body(context, l10n, snapshot),
        ],
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    AppLocalizations l10n,
    LowStockSnapshot? snapshot,
  ) {
    final tokens = context.tokens;
    final message = Padding(
      padding: EdgeInsetsDirectional.all(tokens.spaceMd),
      child: Text(switch (snapshot) {
        null => '',
        LowStockSnapshot(hasAnyProduct: false) => l10n.lowStockNoProducts,
        _ => l10n.lowStockNone,
      }),
    );
    if (snapshot == null || snapshot.items.isEmpty) return [message];

    return [
      for (final s in snapshot.items)
        ListTile(
          title: Text(s.product.name),
          subtitle: Wrap(
            spacing: tokens.spaceXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StockMarks(summary: s),
              Text(context.quantity(s.stockMilli, s.product.unit)),
            ],
          ),
          onTap: () => context.push(RoutePaths.productDetails(s.product.id)),
        ),
      ListTile(
        title: Text(
          l10n.lowStockCount(
            snapshot.totalCount,
            context.count(snapshot.totalCount),
          ),
        ),
        subtitle: Text(l10n.lowStockSeeAll),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(RoutePaths.productsLow),
      ),
    ];
  }
}
