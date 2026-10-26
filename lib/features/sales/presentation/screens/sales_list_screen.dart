import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../cubits/sales_list_cubit.dart';
import '../widgets/sale_row.dart';

/// The Sales section root: New sale and the invoice list with search, the
/// unpaid filter and Show more (US3, FR-009).
class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
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
    final cubit = context.read<SalesListCubit>();
    final state = context.watch<SalesListCubit>().state;
    final filtered =
        state.query.text.trim().isNotEmpty || state.query.unpaidOnly;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Section roots stay alive in the shell; a shared default tag
        // would clash during page transitions.
        heroTag: null,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.salesNewAction),
        onPressed: () => context.push(RoutePaths.salesNew),
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
                hintText: l10n.salesSearchHint,
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
            child:
                listLoadState(
                  context,
                  loadFailed: state.loadFailed,
                  loading: state.loading,
                  empty: state.items.isEmpty,
                  onRetry: cubit.retry,
                ) ??
                (state.items.isEmpty
                    ? filtered
                          ? searchEmptyState(
                              context,
                              message: l10n.salesNoMatch,
                              onClear: () {
                                _search.clear();
                                cubit.clearSearch();
                              },
                            )
                          : EmptyState(
                              illustration: AppIllustration.emptySales,
                              title: l10n.salesListEmpty,
                            )
                    : ListView.builder(
                        padding: EdgeInsetsDirectional.only(
                          bottom: tokens.spaceXl * 3,
                        ),
                        itemCount: state.items.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, i) => i < state.items.length
                            ? SaleRow(sale: state.items[i])
                            : Padding(
                                padding: EdgeInsetsDirectional.all(
                                  tokens.spaceSm,
                                ),
                                child: OutlinedButton(
                                  onPressed: cubit.showMore,
                                  child: Text(l10n.listShowMore),
                                ),
                              ),
                      )),
          ),
        ],
      ),
    );
  }
}
