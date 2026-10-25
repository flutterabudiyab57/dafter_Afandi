import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/product_query.dart';
import '../cubits/product_list_cubit.dart';
import '../widgets/product_row.dart';

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
      floatingActionButton: FloatingActionButton.extended(
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
          _Filters(state: state),
          Expanded(child: _Body(state: state)),
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
  const _Body({required this.state});

  final ProductListState state;

  @override
  Widget build(BuildContext context) {
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isNotEmpty) {
      return ListView.builder(
        // Room for the floating button over the last row.
        padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl * 3),
        itemCount: state.items.length,
        itemBuilder: (context, i) => ProductRow(summary: state.items[i]),
      );
    }
    return _Empty(query: state.query);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.query});

  final ProductQuery query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = query.text.trim();
    final filtered = query.lowOnly || query.categoryFilter is! AllCategories;

    final (String message, Widget? action) = switch ((text, filtered)) {
      ('', false) => (
        l10n.productsEmpty,
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.productsEmptyAction),
          onPressed: () => context.push(RoutePaths.productNew),
        ),
      ),
      ('', true) => (l10n.productsFilterEmpty, null),
      _ => (
        l10n.productsNoMatch(text),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.productsAddNamed(text)),
          onPressed: () => context.push(RoutePaths.productNew, extra: text),
        ),
      ),
    };

    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: tokens.spaceXl),
          ExcludeSemantics(
            child: Icon(
              Icons.inventory_2_outlined,
              size: tokens.spaceXl * 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: tokens.spaceLg),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[SizedBox(height: tokens.spaceLg), action],
        ],
      ),
    );
  }
}
