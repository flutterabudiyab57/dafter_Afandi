import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../reports/presentation/widgets/period_bar.dart';
import '../cubits/expenses_list_cubit.dart';
import '../widgets/expense_row.dart';

/// Expenses for the report period, by category, with their total (US3-5).
class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<ExpensesListCubit>();
    final state = context.watch<ExpensesListCubit>().state;
    final selected = state.query.categoryId;

    Widget record() => FilledButton.icon(
      icon: const Icon(Icons.add),
      label: Text(l10n.expenseNewAction),
      onPressed: () => context.push(RoutePaths.expenseNew),
    );

    final rows =
        listLoadState(
          context,
          loadFailed: state.loadFailed,
          loading: state.loading,
          empty: state.items.isEmpty,
          onRetry: cubit.retry,
        ) ??
        (state.items.isEmpty
            ? EmptyState(
                illustration: AppIllustration.emptyReports,
                title: l10n.expensesEmptyTitle,
                message: l10n.expensesEmptyBody,
                action: record(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final e in state.items) ExpenseRow(expense: e),
                  if (state.hasMore)
                    Padding(
                      padding: EdgeInsetsDirectional.all(tokens.spaceSm),
                      child: OutlinedButton(
                        onPressed: cubit.showMore,
                        child: Text(l10n.listShowMore),
                      ),
                    ),
                ],
              ));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expensesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: l10n.expenseCategoriesTitle,
            onPressed: () => context.push(RoutePaths.expenseCategories),
          ),
        ],
      ),
      floatingActionButton: state.items.isEmpty
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              icon: const Icon(Icons.add),
              label: Text(l10n.expenseNewAction),
              onPressed: () => context.push(RoutePaths.expenseNew),
            ),
      // A column, not a lazy list, so every row exists at any text size.
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(bottom: tokens.spaceXl * 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
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
                      ChoiceChip(
                        label: Text(l10n.expensesAllCategories),
                        selected: selected == null,
                        onSelected: (_) => cubit.filterCategory(null),
                      ),
                      for (final c in state.categories)
                        ChoiceChip(
                          label: Text(c.name),
                          selected: selected == c.id,
                          onSelected: (_) => cubit.filterCategory(c.id),
                        ),
                    ],
                  ),
                  Text(
                    l10n.expensesTotal(context.money(state.totalPiasters)),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            rows,
          ],
        ),
      ),
    );
  }
}
