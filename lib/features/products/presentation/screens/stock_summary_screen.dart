import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../domain/stock_summary.dart';
import '../cubits/stock_summary_cubit.dart';
import '../widgets/unit_label.dart';

/// The stock's value at cost and at sale price, and what each category
/// holds.
class StockSummaryScreen extends StatelessWidget {
  const StockSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<StockSummaryCubit>().state;
    final summary = state.summary;
    final loadState = listLoadState(
      context,
      loadFailed: state.loadFailed,
      loading: summary == null,
      empty: summary == null,
      onRetry: context.read<StockSummaryCubit>().retry,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.stockSummaryTitle)),
      body:
          loadState ??
          SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(bottom: tokens.spaceXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: tokens.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: tokens.spaceXs,
                    children: [
                      Text(
                        l10n.stockValueAtCost(
                          context.money(summary!.costPiasters),
                        ),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        l10n.stockValueAtSale(
                          context.money(summary.salePiasters),
                        ),
                      ),
                      if (summary.withoutCostCount > 0)
                        Text(
                          l10n.stockWithoutCost(
                            context.count(summary.withoutCostCount),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if (summary.groups.isEmpty)
                  Padding(
                    padding: tokens.pagePadding,
                    child: Text(l10n.stockSummaryEmpty),
                  )
                else ...[
                  Padding(
                    padding: tokens.pagePadding,
                    child: Text(
                      l10n.stockByCategory,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  for (final g in summary.groups) ...[
                    _GroupRow(group: g),
                    const Divider(height: 1),
                  ],
                ],
              ],
            ),
          ),
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({required this.group});

  final StockGroup group;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final g = group;
    final quantities = g.quantitiesMilli.isEmpty
        ? l10n.stockNone
        : g.quantitiesMilli.entries
              .map((e) => context.quantity(e.value, e.key))
              .join(' · ');
    return ListTile(
      title: Text(g.categoryName ?? l10n.productsFilterNoCategory),
      subtitle: Wrap(
        spacing: context.tokens.spaceSm,
        children: [
          Text(quantities, style: Theme.of(context).textTheme.titleSmall),
          Text(l10n.stockProductCount(context.count(g.productCount))),
          Text(l10n.stockGroupValue(context.money(g.costPiasters))),
        ],
      ),
    );
  }
}
