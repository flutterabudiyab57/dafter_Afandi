import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/balance_tile.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../suppliers/presentation/widgets/supplier_text.dart';
import '../../domain/report_types.dart';
import '../cubits/balances_cubit.dart';

/// Who owes the shop and whom the shop owes, as of now, each with its
/// total (US5-3, US5-4, FR-015). Rows open the party.
class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<BalancesCubit>().state;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.reportBalancesTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.reportBalancesCustomersTab),
              Tab(text: l10n.reportBalancesSuppliersTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Tab(
              rows: state.customers,
              loadFailed: state.loadFailed,
              total: l10n.reportBalancesCustomersTotal,
              none: l10n.reportBalancesCustomersNone,
              balance: context.balance,
              open: RoutePaths.customerDetails,
            ),
            _Tab(
              rows: state.suppliers,
              loadFailed: state.loadFailed,
              total: l10n.reportBalancesSuppliersTotal,
              none: l10n.reportBalancesSuppliersNone,
              balance: context.supplierBalance,
              open: RoutePaths.supplierDetails,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.rows,
    required this.loadFailed,
    required this.total,
    required this.none,
    required this.balance,
    required this.open,
  });

  final List<BalanceRow>? rows;
  final bool loadFailed;
  final String Function(String amount) total;
  final String none;
  final String Function(int piasters) balance;
  final String Function(String id) open;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final rows = this.rows;
    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: tokens.spaceSm,
        children: [
          ?listLoadState(
            context,
            loadFailed: loadFailed,
            loading: rows == null,
            empty: true,
            onRetry: context.read<BalancesCubit>().retry,
          ),
          if (rows != null && !loadFailed) ...[
            Text(
              total(context.money(BalancesState.total(rows))),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (rows.isEmpty)
              Text(none)
            else
              for (final r in rows)
                BalanceTile(
                  name: r.name,
                  phone: null,
                  balancePiasters: r.balancePiasters,
                  balanceText: balance(r.balancePiasters),
                  onTap: () => context.push(open(r.partyId)),
                ),
          ],
        ],
      ),
    );
  }
}
