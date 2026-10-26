import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/balance_tile.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../customers/presentation/widgets/parties_switch.dart';
import '../../domain/supplier.dart';
import '../cubits/suppliers_list_cubit.dart';
import '../widgets/supplier_text.dart';

/// The Parties section's second root: suppliers with search, the owed
/// filter and their balances (US4, FR-015).
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
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
    final cubit = context.read<SuppliersListCubit>();
    final state = context.watch<SuppliersListCubit>().state;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Section roots stay alive in the shell; a shared default tag
        // would clash during page transitions.
        heroTag: null,
        icon: const Icon(Icons.add_business_outlined),
        label: Text(l10n.supplierAddTitle),
        onPressed: () => context.push(RoutePaths.supplierNew),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.spaceMd,
              end: tokens.spaceXs,
              top: tokens.spaceSm,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PartiesSwitch(suppliers: true),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: l10n.suppliersArchivedTitle,
                  onPressed: () => context.push(RoutePaths.suppliersArchived),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spaceMd,
            ),
            child: TextField(
              controller: _search,
              onChanged: cubit.search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.suppliersSearchHint,
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
                label: Text(l10n.suppliersFilterOwed),
                selected: state.query.owedOnly,
                onSelected: (_) => cubit.toggleOwed(),
              ),
            ),
          ),
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

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.onClear});

  final SuppliersListState state;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loadState = listLoadState(
      context,
      loadFailed: state.loadFailed,
      loading: state.loading,
      empty: state.items.isEmpty,
      onRetry: context.read<SuppliersListCubit>().retry,
    );
    if (loadState != null) return loadState;
    if (state.items.isEmpty) {
      final filtered =
          state.query.text.trim().isNotEmpty || state.query.owedOnly;
      if (filtered) {
        return searchEmptyState(
          context,
          message: l10n.suppliersNoMatch,
          onClear: onClear,
        );
      }
      return EmptyState(
        illustration: AppIllustration.emptySuppliers,
        title: l10n.suppliersEmptyTitle,
        message: l10n.suppliersEmptyBody,
        action: FilledButton.icon(
          icon: const Icon(Icons.person_add_alt),
          label: Text(l10n.supplierAddTitle),
          onPressed: () => context.push(RoutePaths.supplierNew),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl * 3),
      itemCount: state.items.length,
      itemBuilder: (context, i) => SupplierRow(summary: state.items[i]),
    );
  }
}

/// One supplier: name, phone and balance; opens the supplier page, or
/// calls [onTap] instead (the picker).
class SupplierRow extends StatelessWidget {
  const SupplierRow({required this.summary, this.onTap, super.key});

  final SupplierSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = summary.supplier;
    return BalanceTile(
      name: s.name,
      phone: s.phone,
      balancePiasters: summary.balancePiasters,
      balanceText: context.supplierBalance(summary.balancePiasters),
      onTap: onTap ?? () => context.push(RoutePaths.supplierDetails(s.id)),
    );
  }
}
