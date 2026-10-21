import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../cubits/suppliers_list_cubit.dart';
import 'suppliers_screen.dart';

/// Archived suppliers, each with Restore (FR-013).
class ArchivedSuppliersScreen extends StatelessWidget {
  const ArchivedSuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ArchivedSuppliersCubit>();
    final state = context.watch<ArchivedSuppliersCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.suppliersArchivedTitle)),
      body: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
          ? Center(child: Text(l10n.suppliersArchivedEmpty))
          : ListView(
              children: [
                for (final s in state.items)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SupplierRow(summary: s),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await cubit.restore(s.supplier.id);
                            messenger.showSnackBar(
                              SnackBar(content: Text(l10n.supplierRestored)),
                            );
                          },
                          child: Text(l10n.customerRestoreAction),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ),
              ],
            ),
    );
  }
}
