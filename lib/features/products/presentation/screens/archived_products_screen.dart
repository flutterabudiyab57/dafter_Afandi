import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../cubits/archived_products_cubit.dart';
import '../widgets/product_error_text.dart';
import '../widgets/unit_label.dart';

/// Archived products, each with Restore (FR-012, US3).
class ArchivedProductsScreen extends StatelessWidget {
  const ArchivedProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ArchivedProductsCubit>();
    final state = context.watch<ArchivedProductsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.productsArchivedTitle)),
      body: !state.loaded
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
          ? Center(child: Text(l10n.productsArchivedEmpty))
          : ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, i) {
                final s = state.items[i];
                return ListTile(
                  title: Text(s.product.name),
                  subtitle: Text(
                    context.quantity(s.stockMilli, s.product.unit),
                  ),
                  onTap: () =>
                      context.push(RoutePaths.productDetails(s.product.id)),
                  trailing: TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final error = await cubit.restore(s.product.id);
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            error == null
                                ? l10n.productRestored
                                : context.restoreError(error),
                          ),
                        ),
                      );
                    },
                    child: Text(l10n.productRestoreAction),
                  ),
                );
              },
            ),
    );
  }
}
