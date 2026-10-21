import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../cubits/purchases_list_cubit.dart';
import '../widgets/purchase_row.dart';

/// The Purchases section root: New purchase and the purchase list with
/// search, the unpaid filter and Show more (US3, FR-010).
class PurchasesListScreen extends StatefulWidget {
  const PurchasesListScreen({super.key});

  @override
  State<PurchasesListScreen> createState() => _PurchasesListScreenState();
}

class _PurchasesListScreenState extends State<PurchasesListScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<PurchasesListCubit>();
    final state = context.watch<PurchasesListCubit>().state;
    final filtered =
        state.query.text.trim().isNotEmpty || state.query.unpaidOnly;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Section roots stay alive in the shell; a shared default tag
        // would clash during page transitions.
        heroTag: null,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.purchasesNewAction),
        onPressed: () => context.push(RoutePaths.purchasesNew),
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
                hintText: l10n.purchasesSearchHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spaceMd,
              vertical: tokens.spaceXs,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilterChip(
                label: Text(l10n.salesFilterUnpaid),
                selected: state.query.unpaidOnly,
                onSelected: (_) => cubit.toggleUnpaid(),
              ),
            ),
          ),
          Expanded(
            child: state.loading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                ? Center(
                    child: Padding(
                      padding: tokens.pagePadding,
                      child: Text(
                        filtered
                            ? l10n.purchasesNoMatch
                            : l10n.purchasesListEmpty,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsetsDirectional.only(
                      bottom: tokens.spaceXl * 3,
                    ),
                    itemCount: state.items.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, i) => i < state.items.length
                        ? PurchaseRow(purchase: state.items[i])
                        : Padding(
                            padding: EdgeInsetsDirectional.all(tokens.spaceSm),
                            child: OutlinedButton(
                              onPressed: cubit.showMore,
                              child: Text(l10n.listShowMore),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
