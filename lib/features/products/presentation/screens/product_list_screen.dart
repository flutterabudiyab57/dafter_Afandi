import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../domain/product_query.dart';
import '../cubits/product_list_cubit.dart';
import '../cubits/stock_summary_cubit.dart';
import '../widgets/product_row.dart';
import '../widgets/unit_label.dart';

/// Products: search, filters, marks and empty states (US2).
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<ProductListCubit>();
    final state = context.watch<ProductListCubit>().state;
    final query = state.query;
    final stock = context.watch<StockSummaryCubit>().state.summary;
    // The empty list has its own Add product button; one is enough.
    final emptyAction =
        !state.loading &&
        !state.loadFailed &&
        state.items.isEmpty &&
        query.text.trim().isEmpty &&
        !query.lowOnly &&
        query.categoryFilter is AllCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.productsTitle),
        actions: [
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => context.push(RoutePaths.productsArchived),
                child: Text(l10n.productsArchivedTitle),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: emptyAction
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: Text(l10n.productAddTitle),
              onPressed: () => context.push(RoutePaths.productNew),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.spaceMd,
              end: tokens.spaceMd,
              top: tokens.spaceSm,
            ),
            child: TextField(
              controller: _search,
              onChanged: cubit.search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.productsSearchHint,
              ),
            ),
          ),
          if (stock != null && !emptyAction)
            ListTile(
              title: Text(
                l10n.stockValueAtCost(context.money(stock.costPiasters)),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RoutePaths.productsStock),
            ),
          _Filters(state: state),
          Expanded(
            child: _Body(
              state: state,
              onClear: () {
                _search.clear();
                cubit.clearSearch();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final ProductListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<ProductListCubit>();
    final filter = state.query.categoryFilter;

    Widget choice(String label, CategoryFilter value) => Padding(
      padding: EdgeInsetsDirectional.only(end: tokens.spaceSm),
      child: ChoiceChip(
        label: Text(label),
        selected: filter == value,
        onSelected: (_) => cubit.setCategory(value),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tokens.spaceMd,
        vertical: tokens.spaceSm,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: tokens.spaceSm),
            child: FilterChip(
              label: Text(l10n.productsFilterLow),
              selected: state.query.lowOnly,
              onSelected: (_) => cubit.toggleLow(),
            ),
          ),
          choice(l10n.productsFilterAll, const AllCategories()),
          for (final c in state.categories) choice(c.name, InCategory(c.id)),
          if (state.categories.isNotEmpty)
            choice(l10n.productsFilterNoCategory, const NoCategory()),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onClear});

  final ProductListState state;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final loadState = listLoadState(
      context,
      loadFailed: state.loadFailed,
      loading: state.loading,
      empty: state.items.isEmpty,
      onRetry: context.read<ProductListCubit>().retry,
    );
    if (loadState != null) return loadState;
    if (state.items.isNotEmpty) {
      return ListView.builder(
        // Room for the floating button over the last row.
        padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl * 3),
        itemCount: state.items.length,
        itemBuilder: (context, i) => ProductRow(summary: state.items[i]),
      );
    }
    return _Empty(query: state.query, onClear: onClear);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.query, required this.onClear});

  final ProductQuery query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = query.text.trim();
    final filtered = query.lowOnly || query.categoryFilter is! AllCategories;

    if (text.isEmpty && !filtered) {
      return EmptyState(
        illustration: AppIllustration.emptyProducts,
        title: l10n.productsEmpty,
        action: FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.productsEmptyAction),
          onPressed: () => context.push(RoutePaths.productNew),
        ),
      );
    }
    final clear = OutlinedButton(
      onPressed: onClear,
      child: Text(l10n.searchClearAction),
    );
    return EmptyState(
      illustration: AppIllustration.emptySearch,
      title: l10n.searchEmptyTitle,
      message: text.isEmpty
          ? l10n.productsFilterEmpty
          : l10n.productsNoMatch(text),
      action: text.isEmpty
          ? clear
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l10n.productsAddNamed(text)),
                  onPressed: () =>
                      context.push(RoutePaths.productNew, extra: text),
                ),
                SizedBox(height: tokens.spaceSm),
                clear,
              ],
            ),
    );
  }
}
