import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/supplier.dart';
import '../cubits/supplier_form_cubit.dart';
import '../cubits/suppliers_list_cubit.dart';
import 'supplier_form_screen.dart';
import 'suppliers_screen.dart';

/// Picks or quickly adds the purchase's supplier (US2-4). Pops with them.
class SupplierPickerPage extends StatelessWidget {
  const SupplierPickerPage({required this.newSupplier, super.key});

  /// The full supplier form, its name prefilled from the search.
  final SupplierFormCubit Function(String name) newSupplier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SuppliersListCubit>();
    final state = context.watch<SuppliersListCubit>().state;
    final name = state.query.text.trim();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.purchaseSupplierPick)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: context.tokens.pagePadding,
            child: TextField(
              autofocus: true,
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
              horizontal: context.tokens.spaceMd,
            ),
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.add),
              label: Text(l10n.supplierNewAction),
              onPressed: () => _addNew(context, name),
            ),
          ),
          SizedBox(height: context.tokens.spaceSm),
          if (name.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: context.tokens.spaceMd,
              ),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_add_alt),
                label: Text(l10n.supplierAddNamed(name)),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final added = await cubit.quickAdd();
                  if (added != null) navigator.pop<SupplierSummary>(added);
                },
              ),
            ),
          Expanded(
            child: state.loading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) => SupplierRow(
                      summary: state.items[i],
                      onTap: () =>
                          Navigator.of(context)
                              .pop<SupplierSummary>(state.items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Opens the full form; a saved supplier is chosen at once.
  Future<void> _addNew(BuildContext context, String name) async {
    final cubit = context.read<SuppliersListCubit>();
    final navigator = Navigator.of(context);
    final id = await navigator.push<String>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => newSupplier(name),
          child: const SupplierFormScreen(popOnCreate: true),
        ),
      ),
    );
    if (id == null) return;
    final added = await cubit.byId(id);
    if (added != null) navigator.pop<SupplierSummary>(added);
  }
}
