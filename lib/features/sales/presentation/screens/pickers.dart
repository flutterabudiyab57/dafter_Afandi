import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../customers/domain/customer.dart';
import '../../../customers/presentation/cubits/customers_list_cubit.dart';
import '../../../customers/presentation/screens/customers_screen.dart';
import '../../../products/domain/product.dart';
import '../../../products/presentation/widgets/product_row.dart';
import '../cubits/sales_list_cubit.dart';

/// Picks a product for the sale (FR-003). Pops with the product; Enter on
/// an exact barcode picks it at once.
class ProductPickerPage extends StatelessWidget {
  const ProductPickerPage({super.key});

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

/// Picks or quickly adds the sale's customer (US2-4). Pops with them.
class CustomerPickerPage extends StatelessWidget {
  const CustomerPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CustomersListCubit>();
    final state = context.watch<CustomersListCubit>().state;
    final name = state.query.text.trim();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.saleCustomerPick)),
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
                hintText: l10n.customersSearchHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          if (name.isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: context.tokens.spaceMd,
              ),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.person_add_alt),
                label: Text(l10n.customerAddNamed(name)),
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final added = await cubit.quickAdd();
                  if (added != null) navigator.pop<CustomerSummary>(added);
                },
              ),
            ),
          Expanded(
            child: state.loading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, i) => CustomerRow(
                      summary: state.items[i],
                      onTap: () =>
                          Navigator.of(context)
                              .pop<CustomerSummary>(state.items[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
