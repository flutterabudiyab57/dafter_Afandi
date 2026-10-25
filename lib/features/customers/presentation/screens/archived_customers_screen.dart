import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_load_state.dart';
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
      body:
          listLoadState(
            context,
            loadFailed: state.loadFailed,
            loading: !state.loaded,
            empty: state.items.isEmpty,
            onRetry: cubit.retry,
          ) ??
          (state.items.isEmpty
              ? EmptyState(
                  illustration: AppIllustration.emptyArchive,
                  title: l10n.customersArchivedEmpty,
                )
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
                                await cubit.restore(s.customer.id);
                                if (context.mounted) {
                                  showAppSnackBar(
                                    context,
                                    l10n.customerRestored,
                                  );
                                }
                              },
                              child: Text(l10n.customerRestoreAction),
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                      ),
                  ],
                )),
    );
  }
}
