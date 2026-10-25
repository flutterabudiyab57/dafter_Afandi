import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/skeleton_list.dart';
import '../../../../core/widgets/status_banner.dart';
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
    final state = context.watch<LowStockCubit>().state;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
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
          if (state.loadFailed)
            _failed(context, l10n)
          else
            ..._body(context, l10n, state.snapshot),
        ],
      ),
    );
  }

  Widget _failed(BuildContext context, AppLocalizations l10n) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsetsDirectional.all(tokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.loadFailedTitle),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: context.read<LowStockCubit>().retry,
              child: Text(l10n.retryAction),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    AppLocalizations l10n,
    LowStockSnapshot? snapshot,
  ) {
    // Loading shows a skeleton; with a snapshot the switch below is total.
    final tokens = context.tokens;
    final message = Padding(
      padding: EdgeInsetsDirectional.all(tokens.spaceMd),
      child: Text(switch (snapshot) {
        LowStockSnapshot(hasAnyProduct: false) => l10n.lowStockNoProducts,
        _ => l10n.lowStockNone,
      }),
    );
    if (snapshot == null) return const [SkeletonList(rows: 2)];
    if (snapshot.items.isEmpty) return [message];

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
      // The count and "See all" are in [LowStockBanner] above.
      SizedBox(height: tokens.spaceSm),
    ];
  }
}

/// The Home warning when products are low (handoff 6): the count and a way
/// to the filtered list. Hidden when nothing is low.
class LowStockBanner extends StatelessWidget {
  const LowStockBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = context.select<LowStockCubit, int>(
      (c) => c.state.snapshot?.totalCount ?? 0,
    );
    if (count == 0) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceLg),
      child: StatusBanner(
        tone: StatusTone.warning,
        title: l10n.lowStockCount(count, context.count(count)),
        actionLabel: l10n.lowStockSeeAll,
        onAction: () => context.push(RoutePaths.productsLow),
      ),
    );
  }
}
