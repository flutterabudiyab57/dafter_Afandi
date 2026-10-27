import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/report_types.dart';
import '../cubits/top_sellers_cubit.dart';
import '../widgets/period_bar.dart';

/// Up to ten best-selling products in the report period, by sales value or
/// by quantity (US5-2, FR-014).
class TopSellersScreen extends StatelessWidget {
  const TopSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<TopSellersCubit>();
    final state = context.watch<TopSellersCubit>().state;
    final rows = state.rows;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportTopSellersTitle)),
      // A column, not a lazy list: at most ten rows, all built at 200%.
      body: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.spaceSm,
          children: [
            const PeriodBar(),
            Wrap(
              spacing: tokens.spaceSm,
              runSpacing: tokens.spaceXs,
              children: [
                for (final (order, label) in [
                  (TopSellerOrder.value, l10n.reportTopByValue),
                  (TopSellerOrder.quantity, l10n.reportTopByQuantity),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: state.order == order,
                    onSelected: (_) => cubit.orderBy(order),
                  ),
              ],
            ),
            ?listLoadState(
              context,
              loadFailed: state.loadFailed,
              loading: rows == null,
              empty: true,
              onRetry: cubit.retry,
            ),
            if (rows != null && !state.loadFailed)
              if (rows.isEmpty)
                Text(l10n.reportTopEmpty)
              else
                for (final (i, t) in rows.indexed) _Row(rank: i + 1, seller: t),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.rank, required this.seller});

  final int rank;
  final TopSeller seller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    // Not a ListTile: at 200% the amount alone can fill the width, so the
    // sold quantity and the amount wrap under the name.
    return InkWell(
      onTap: () => context.push(RoutePaths.productDetails(seller.productId)),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: tokens.spaceSm),
        child: Row(
          spacing: tokens.spaceSm,
          children: [
            CircleAvatar(child: Text(context.count(rank))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(seller.name, style: theme.textTheme.titleSmall),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: tokens.spaceSm,
                    children: [
                      Text(
                        l10n.reportTopSold(
                          context.quantity(seller.qtyMilli, seller.unit),
                        ),
                      ),
                      Text(context.money(seller.netSalesPiasters)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
