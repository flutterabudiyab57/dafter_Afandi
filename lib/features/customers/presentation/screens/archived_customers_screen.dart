import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../cubits/customers_list_cubit.dart';
import 'customers_screen.dart';

/// Archived customers, each with Restore (FR-017).
class ArchivedCustomersScreen extends StatelessWidget {
  const ArchivedCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ArchivedCustomersCubit>();
    final state = context.watch<ArchivedCustomersCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.customersArchivedTitle)),
      body: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
          ? Center(child: Text(l10n.customersArchivedEmpty))
          : ListView(
              children: [
                for (final s in state.items)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomerRow(summary: s),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await cubit.restore(s.customer.id);
                            messenger.showSnackBar(
                              SnackBar(content: Text(l10n.customerRestored)),
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
