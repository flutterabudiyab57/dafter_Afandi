import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/balance_tile.dart';
import '../../../../core/widgets/skeleton_list.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../payments/domain/payment_method.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../reports/domain/report_types.dart';
import '../cubits/dashboard_cubit.dart';

/// Today's sales, money collected and who owes most (US1, FR-016 to
/// FR-019). The running-low count is the low-stock banner and card below.
class TodayCards extends StatelessWidget {
  const TodayCards({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final state = context.watch<DashboardCubit>().state;
    final snapshot = state.snapshot;

    final List<Widget> cards;
    if (state.loadFailed) {
      cards = [const _Failed()];
    } else if (snapshot == null) {
      cards = [const SkeletonList(rows: 3)];
    } else {
      cards = [
        _SalesCard(snapshot),
        SizedBox(height: tokens.spaceSm),
        _CollectedCard(snapshot.todayCollected),
        SizedBox(height: tokens.spaceSm),
        _DebtorsCard(snapshot.topDebtors),
      ];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.dashboardTodayTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: tokens.spaceSm),
        ...cards,
      ],
    );
  }
}

/// The outlined card shape the Home cards share.
class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.children, this.onTap});

  final List<Widget> children;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: tokens.spaceXs,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard(this.snapshot);

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final n = snapshot.todaySalesCount;
    return _HomeCard(
      onTap: () => context.go(RoutePaths.sales),
      children: [
        Text(l10n.dashboardSalesTitle, style: theme.textTheme.titleMedium),
        Text(
          context.money(snapshot.todaySalesPiasters),
          style: theme.textTheme.headlineSmall,
        ),
        Text(l10n.dashboardSalesCount(n, context.count(n))),
      ],
    );
  }
}

class _CollectedCard extends StatelessWidget {
  const _CollectedCard(this.collected);

  final CollectedSummary collected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _HomeCard(
      children: [
        Text(l10n.dashboardCollectedTitle, style: theme.textTheme.titleMedium),
        Text(
          context.money(collected.totalPiasters),
          style: theme.textTheme.headlineSmall,
        ),
        for (final m in offeredPaymentMethods)
          if (collected.of(m) != 0)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: context.tokens.spaceSm,
              children: [
                Text(context.methodLabel(m)),
                Text(context.money(collected.of(m))),
              ],
            ),
      ],
    );
  }
}

class _DebtorsCard extends StatelessWidget {
  const _DebtorsCard(this.debtors);

  final List<BalanceRow> debtors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return _HomeCard(
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              l10n.dashboardDebtorsTitle,
              style: theme.textTheme.titleMedium,
            ),
            if (debtors.isNotEmpty)
              TextButton(
                onPressed: () => context.go(RoutePaths.parties),
                child: Text(l10n.dashboardSeeAll),
              ),
          ],
        ),
        if (debtors.isEmpty)
          Text(l10n.dashboardDebtorsNone)
        else
          for (final d in debtors)
            BalanceTile(
              name: d.name,
              phone: null,
              balancePiasters: d.balancePiasters,
              balanceText: context.balance(d.balancePiasters),
              onTap: () => context.go(RoutePaths.customerDetails(d.partyId)),
            ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _HomeCard(
      children: [
        Text(l10n.loadFailedTitle),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: context.read<DashboardCubit>().retry,
            child: Text(l10n.retryAction),
          ),
        ),
      ],
    );
  }
}
