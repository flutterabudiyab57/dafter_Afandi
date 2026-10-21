import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/digits.dart';
import '../../domain/customer.dart';
import '../cubits/customers_list_cubit.dart';
import '../widgets/customer_text.dart';
import '../widgets/parties_switch.dart';

/// The Parties section root: customers with search, the owes filter and
/// their balances (US4, FR-014).
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
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
    final cubit = context.read<CustomersListCubit>();
    final state = context.watch<CustomersListCubit>().state;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Section roots stay alive in the shell; a shared default tag
        // would clash during page transitions.
        heroTag: null,
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.customerAddTitle),
        onPressed: () => context.push(RoutePaths.customerNew),
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
                    child: PartiesSwitch(suppliers: false),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: l10n.customersArchivedTitle,
                  onPressed: () => context.push(RoutePaths.customersArchived),
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
                hintText: l10n.customersSearchHint,
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
                label: Text(l10n.customersFilterOwes),
                selected: state.query.owesOnly,
                onSelected: (_) => cubit.toggleOwes(),
              ),
            ),
          ),
          Expanded(child: _Body(state: state)),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final CustomersListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      final filtered =
          state.query.text.trim().isNotEmpty || state.query.owesOnly;
      return Center(
        child: Padding(
          padding: context.tokens.pagePadding,
          child: Text(
            filtered ? l10n.customersNoMatch : l10n.customersEmpty,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl * 3),
      itemCount: state.items.length,
      itemBuilder: (context, i) => CustomerRow(summary: state.items[i]),
    );
  }
}

/// One customer: name, phone and balance; opens the customer page, or
/// calls [onTap] instead (the picker).
class CustomerRow extends StatelessWidget {
  const CustomerRow({required this.summary, this.onTap, super.key});

  final CustomerSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = summary.customer;
    final b = summary.balancePiasters;
    return ListTile(
      title: Text(c.name),
      subtitle: c.phone == null ? null : Text(ltrIsolate(c.phone!)),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.4,
        ),
        child: Text(
          context.balance(b),
          textAlign: TextAlign.end,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: b > 0
                ? context.appColors.owes
                : b < 0
                ? context.appColors.credit
                : null,
          ),
        ),
      ),
      onTap: onTap ?? () => context.push(RoutePaths.customerDetails(c.id)),
    );
  }
}
