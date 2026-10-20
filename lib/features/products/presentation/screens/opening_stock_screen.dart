import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../domain/product_errors.dart';
import '../cubits/opening_stock_cubit.dart';
import '../widgets/opening_confirm_dialog.dart';
import '../widgets/product_error_text.dart';

/// Sets the opening stock later, once, for a product with no history
/// (US4-7). A product that already has history goes back to its details.
class OpeningStockScreen extends StatelessWidget {
  const OpeningStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<OpeningStockCubit, OpeningStockState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onStatus,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.productSetOpeningAction)),
        body: BlocBuilder<OpeningStockCubit, OpeningStockState>(
          buildWhen: (a, b) =>
              (a.status == OpeningStockStatus.loading) !=
              (b.status == OpeningStockStatus.loading),
          builder: (context, state) =>
              state.status == OpeningStockStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : const _Form(),
        ),
      ),
    );
  }

  Future<void> _onStatus(BuildContext context, OpeningStockState state) async {
    final cubit = context.read<OpeningStockCubit>();
    switch (state.status) {
      case OpeningStockStatus.confirm:
        final confirmed = await confirmOpeningStock(
          context,
          state.pending!,
          state.unit,
        );
        if (confirmed) {
          await cubit.confirm();
        } else {
          cubit.cancelConfirm();
        }
      case OpeningStockStatus.saved || OpeningStockStatus.notAllowed:
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RoutePaths.productDetails(cubit.productId));
        }
      default:
        break;
    }
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final OpeningStockCubit _cubit = context.read<OpeningStockCubit>();
  late final _qty = TextEditingController(text: _cubit.state.qty);
  late final _cost = TextEditingController(text: _cubit.state.cost);

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<OpeningStockCubit>().state;

    String? err(ProductField field) {
      final e = state.errorFor(field);
      return e == null ? null : context.fieldError(e);
    }

    final gap = SizedBox(height: tokens.spaceMd);
    return SafeArea(
      child: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.productOpeningHint, style: theme.textTheme.bodyMedium),
            gap,
            QuantityField(
              controller: _qty,
              label: l10n.productOpeningQtyLabel,
              onChanged: _cubit.qtyChanged,
              errorText: err(ProductField.openingQty),
            ),
            gap,
            MoneyField(
              controller: _cost,
              label: l10n.productOpeningCostLabel,
              onChanged: _cubit.costChanged,
              errorText: err(ProductField.openingCost),
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: tokens.spaceXl),
            if (state.status == OpeningStockStatus.failed) ...[
              Text(
                l10n.errorSaveFailed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              gap,
            ],
            FilledButton(
              onPressed: state.status == OpeningStockStatus.saving
                  ? null
                  : _cubit.submit,
              child: Text(l10n.saveAction),
            ),
          ],
        ),
      ),
    );
  }
}
