import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/form_error_banner.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../../core/widgets/save_button.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../../core/widgets/unsaved_changes_guard.dart';
import '../../domain/product_errors.dart';
import '../cubits/product_form_cubit.dart';
import '../widgets/opening_confirm_dialog.dart';
import '../widgets/product_error_text.dart';
import '../widgets/unit_label.dart';

/// Adds or edits a product (US1, US3). With opening stock, saving asks for
/// confirmation first.
class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ProductFormCubit>();
    final create = cubit.mode == ProductFormMode.create;

    return BlocListener<ProductFormCubit, ProductFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onStatus,
      child: BlocBuilder<ProductFormCubit, ProductFormState>(
        builder: (context, _) => UnsavedChangesGuard(
          dirty: context.read<ProductFormCubit>().hasUnsavedChanges,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                create ? l10n.productAddTitle : l10n.productEditTitle,
              ),
            ),
            body: BlocBuilder<ProductFormCubit, ProductFormState>(
              buildWhen: (a, b) =>
                  (a.status == ProductFormStatus.loading) !=
                      (b.status == ProductFormStatus.loading) ||
                  (a.status == ProductFormStatus.notFound) !=
                      (b.status == ProductFormStatus.notFound),
              builder: (context, state) => switch (state.status) {
                ProductFormStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                ProductFormStatus.notFound => Center(
                  child: Text(l10n.productNotFound),
                ),
                _ => const _Form(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onStatus(BuildContext context, ProductFormState state) async {
    final cubit = context.read<ProductFormCubit>();
    switch (state.status) {
      case ProductFormStatus.confirmOpening:
        final confirmed = await confirmOpeningStock(
          context,
          state.pendingOpening!,
          state.unit,
        );
        if (confirmed) {
          await cubit.confirm();
        } else {
          cubit.cancelConfirm();
        }
      case ProductFormStatus.saved:
        final l10n = AppLocalizations.of(context);
        if (state.nameExistsElsewhere) {
          showAppSnackBar(
            context,
            l10n.productNameExistsNotice,
            tone: StatusTone.warning,
          );
        }
        if (cubit.mode == ProductFormMode.create) {
          context.pushReplacement(RoutePaths.productDetails(state.savedId!));
        } else {
          context.pop();
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
  late final ProductFormCubit _cubit = context.read<ProductFormCubit>();
  late final ProductFormState _initial = _cubit.state;
  late final _name = TextEditingController(text: _initial.name);
  late final _price = TextEditingController(text: _initial.price);
  late final _barcode = TextEditingController(text: _initial.barcode);
  late final _sku = TextEditingController(text: _initial.sku);
  late final _lowStock = TextEditingController(text: _initial.lowStock);
  late final _openingQty = TextEditingController(text: _initial.openingQty);
  late final _openingCost = TextEditingController(text: _initial.openingCost);

  @override
  void dispose() {
    for (final c in [
      _name,
      _price,
      _barcode,
      _sku,
      _lowStock,
      _openingQty,
      _openingCost,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<ProductFormCubit>().state;
    final create = _cubit.mode == ProductFormMode.create;

    String? err(ProductField field) {
      final e = state.errorFor(field);
      if (e != null) return context.fieldError(e);
      if (field == ProductField.barcode && state.saveError is BarcodeTaken) {
        return context.saveError(state.saveError!);
      }
      return null;
    }

    final gap = SizedBox(height: tokens.spaceMd);
    return SafeArea(
      child: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.status == ProductFormStatus.failed) ...[
              FormErrorBanner(title: l10n.errorSaveFailed),
              gap,
            ],
            TextField(
              controller: _name,
              onChanged: _cubit.nameChanged,
              textInputAction: TextInputAction.next,
              inputFormatters: const [
                CodePointLengthFormatter(maxProductNameLength),
              ],
              decoration: InputDecoration(
                labelText: l10n.productNameLabel,
                errorText: err(ProductField.name),
                errorMaxLines: 3,
              ),
            ),
            gap,
            Text(l10n.productUnitLabel, style: theme.textTheme.labelLarge),
            SizedBox(height: tokens.spaceXs),
            Wrap(
              spacing: tokens.spaceSm,
              runSpacing: tokens.spaceSm,
              children: [
                for (final unit in UnitType.values)
                  ChoiceChip(
                    label: Text(unitFull(l10n, unit)),
                    selected: state.unit == unit,
                    onSelected: state.unitLocked
                        ? null
                        : (_) => _cubit.unitChanged(unit),
                  ),
              ],
            ),
            if (state.unitLocked) ...[
              SizedBox(height: tokens.spaceXs),
              Text(
                l10n.productUnitLockedNote,
                style: theme.textTheme.bodySmall,
              ),
            ],
            gap,
            MoneyField(
              controller: _price,
              label: l10n.productPriceLabel,
              onChanged: _cubit.priceChanged,
              errorText: err(ProductField.price),
            ),
            gap,
            DropdownButtonFormField<String?>(
              // Rebuilt when the categories arrive, so the stored category
              // shows once it is known.
              key: ValueKey(Object.hashAll(state.categories.map((c) => c.id))),
              initialValue:
                  state.categories.any((c) => c.id == state.categoryId)
                  ? state.categoryId
                  : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.productCategoryLabel),
              items: [
                DropdownMenuItem(child: Text(l10n.productNoCategory)),
                for (final c in state.categories)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: _cubit.categoryChanged,
            ),
            gap,
            TextField(
              controller: _barcode,
              onChanged: _cubit.barcodeChanged,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.ltr,
              inputFormatters: const [CodePointLengthFormatter(maxCodeLength)],
              decoration: InputDecoration(
                labelText: l10n.productBarcodeLabel,
                errorText: err(ProductField.barcode),
                errorMaxLines: 3,
              ),
            ),
            gap,
            TextField(
              controller: _sku,
              onChanged: _cubit.skuChanged,
              textInputAction: TextInputAction.next,
              inputFormatters: const [CodePointLengthFormatter(maxCodeLength)],
              decoration: InputDecoration(
                labelText: l10n.productSkuLabel,
                errorText: err(ProductField.sku),
                errorMaxLines: 3,
              ),
            ),
            gap,
            QuantityField(
              controller: _lowStock,
              label: l10n.productLowStockLabel,
              helperText: l10n.productLowStockHint,
              onChanged: _cubit.lowStockChanged,
              errorText: err(ProductField.lowStock),
            ),
            if (create) ...[
              SizedBox(height: tokens.spaceLg),
              Text(
                l10n.productOpeningSection,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: tokens.spaceXs),
              Text(l10n.productOpeningHint, style: theme.textTheme.bodySmall),
              gap,
              QuantityField(
                controller: _openingQty,
                label: l10n.productOpeningQtyLabel,
                onChanged: _cubit.openingQtyChanged,
                errorText: err(ProductField.openingQty),
              ),
              gap,
              MoneyField(
                controller: _openingCost,
                label: l10n.productOpeningCostLabel,
                onChanged: _cubit.openingCostChanged,
                errorText: err(ProductField.openingCost),
                textInputAction: TextInputAction.done,
              ),
            ],
            SizedBox(height: tokens.spaceXl),
            SaveButton(
              label: l10n.saveAction,
              savingLabel: l10n.savingLabel,
              saving: state.status == ProductFormStatus.saving,
              onPressed: _cubit.submit,
            ),
          ],
        ),
      ),
    );
  }
}
