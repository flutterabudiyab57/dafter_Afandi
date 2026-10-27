import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_illustration.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../products/presentation/widgets/unit_label.dart';
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
                  title: l10n.suppliersArchivedEmpty,
                )
              : ListView(
                  children: [
                    for (final s in state.items)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SupplierRow(summary: s),
                          if (s.purgeAt case final at?)
                            Padding(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: context.tokens.spaceMd,
                              ),
                              child: Text(
                                l10n.partyPurgeOn(context.date(at.toLocal())),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                    ),
                              ),
                            ),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () async {
                                await cubit.restore(s.supplier.id);
                                if (context.mounted) {
                                  showAppSnackBar(
                                    context,
                                    l10n.supplierRestored,
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
