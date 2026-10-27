import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/skeleton_list.dart';
import '../../../core/widgets/status_badge.dart';
import '../../products/domain/stock_entry.dart';
import '../../products/presentation/widgets/history_labels.dart';
import '../../products/presentation/widgets/unit_label.dart';
import '../domain/profit_summary.dart';
import 'cubits/profit_cubit.dart';
import 'widgets/period_bar.dart';

/// Reports: the period and the profit for it (US2, FR-003 to FR-012).
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.spaceLg,
        children: const [PeriodBar(), _ProfitCard()],
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  const _ProfitCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<ProfitCubit>().state;
    final summary = state.summary;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusXl),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.spaceSm,
          children: [
            Text(l10n.profitTitle, style: theme.textTheme.titleMedium),
            if (state.loadFailed) ...[
              Text(l10n.loadFailedTitle),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: context.read<ProfitCubit>().retry,
                  child: Text(l10n.retryAction),
                ),
              ),
            ] else if (summary == null)
              const SkeletonList(rows: 4)
            else
              ..._lines(context, summary),
          ],
        ),
      ),
    );
  }

  List<Widget> _lines(BuildContext context, ProfitSummary s) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final losses = s.inventoryLossesPiasters;
    return [
      if (s.isEmpty) Text(l10n.profitEmpty),
      _Line(l10n.profitNetSales, context.money(s.netSalesPiasters)),
      _Line(l10n.profitCostOfGoods, context.money(s.costOfGoodsPiasters)),
      _Line(
        l10n.profitGross,
        context.money(s.grossProfitPiasters),
        strong: true,
      ),
      _Line(
        losses < 0 ? l10n.profitInventoryNetGain : l10n.profitInventoryLosses,
        context.money(losses.abs()),
      ),
      for (final kind in AdjustmentKind.values)
        if (s.inventoryLossesByReason[kind] case final value?)
          Padding(
            padding: EdgeInsetsDirectional.only(start: tokens.spaceMd),
            // A gain from a count reads with a plus.
            child: _Line(
              adjustmentKindLabel(l10n, kind),
              context.money(value.abs(), sign: value < 0 ? '+' : ''),
            ),
          ),
      _Line(l10n.profitExpenses, context.money(s.expensesPiasters)),
      const Divider(),
      if (s.isLoss)
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: tokens.spaceSm,
          children: [
            Text(l10n.profitNetLoss, style: theme.textTheme.titleMedium),
            StatusBadge(
              label: context.money(-s.netProfitPiasters),
              tone: BadgeTone.error,
            ),
          ],
        )
      else
        _Line(l10n.profitNet, context.money(s.netProfitPiasters), strong: true),
      if (s.linesWithoutCost > 0)
        Text(l10n.profitNoCostNote, style: theme.textTheme.bodySmall),
    ];
  }
}

/// A label and an amount, wrapping under each other when they do not fit.
class _Line extends StatelessWidget {
  const _Line(this.label, this.amount, {this.strong = false});

  final String label;
  final String amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong ? Theme.of(context).textTheme.titleMedium : null;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: context.tokens.spaceSm,
      children: [
        Text(label, style: style),
        Text(amount, style: style),
      ],
    );
  }
}
