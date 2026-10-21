import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/product.dart';
import '../cubits/product_picker_cubit.dart';
import '../widgets/product_row.dart';

/// Picks a product (003 FR-003). Pops with the product; Enter on an exact
/// barcode picks it at once.
///
/// With [onQuickAdd], a button adds the search text as a new product and
/// pops with it (004 research R13, purchases only).
class ProductPickerPage extends StatelessWidget {
  const ProductPickerPage({super.key, this.onQuickAdd, this.quickAddLabel});

  /// Opens the quick-add form for the typed name; null when cancelled.
  final Future<ProductSummary?> Function(BuildContext context, String name)?
  onQuickAdd;

  /// The quick-add button's text for the typed name.
  final String Function(String name)? quickAddLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProductPickerCubit>();
    final state = context.watch<ProductPickerCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.saleAddProductAction)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: context.tokens.pagePadding,
            child: TextField(
              autofocus: true,
              onChanged: cubit.search,
              textInputAction: TextInputAction.search,
              onSubmitted: (text) async {
                final navigator = Navigator.of(context);
                final exact = await cubit.exact(text);
                if (exact != null) navigator.pop(exact);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.productsSearchHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (onQuickAdd case final add? when quickAddLabel != null)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: context.tokens.spaceMd,
              ),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_box_outlined),
                label: Text(quickAddLabel!(state.text.trim())),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final added = await add(context, state.text.trim());
                  if (added != null) navigator.pop<ProductSummary>(added);
                },
              ),
            ),
          Expanded(
            child: state.loading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                ? Center(child: Text(l10n.productsNoMatch(state.text)))
                : ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) => ProductRow(
                      summary: state.items[i],
                      onTap: () =>
                          Navigator.of(context)
                              .pop<ProductSummary>(state.items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
