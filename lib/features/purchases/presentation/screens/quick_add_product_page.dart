import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../products/domain/product_errors.dart';
import '../../../products/presentation/cubits/product_form_cubit.dart';
import '../../../products/presentation/widgets/product_error_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';

/// Adds a product from the purchase's picker (US1-9, research R13): name,
/// unit, selling price and an optional barcode, with no opening stock; its
/// stock and cost come from the purchase. Pops with the new product's id.
class QuickAddProductPage extends StatelessWidget {
  const QuickAddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<ProductFormCubit, ProductFormState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == ProductFormStatus.saved,
      listener: (context, state) {
        if (state.nameExistsElsewhere) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.productNameExistsNotice)));
        }
        Navigator.of(context).pop<String>(state.savedId);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.purchaseQuickAddTitle)),
        body: const _Form(),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final ProductFormCubit _cubit = context.read<ProductFormCubit>();
  late final _name = TextEditingController(text: _cubit.state.name);
  final _price = TextEditingController();
  final _barcode = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _barcode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<ProductFormCubit>().state;

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
                    onSelected: (_) => _cubit.unitChanged(unit),
                  ),
              ],
            ),
            gap,
            MoneyField(
              controller: _price,
              label: l10n.productPriceLabel,
              onChanged: _cubit.priceChanged,
              errorText: err(ProductField.price),
            ),
            gap,
            TextField(
              controller: _barcode,
              onChanged: _cubit.barcodeChanged,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              inputFormatters: const [CodePointLengthFormatter(maxCodeLength)],
              decoration: InputDecoration(
                labelText: l10n.productBarcodeLabel,
                errorText: err(ProductField.barcode),
                errorMaxLines: 3,
              ),
            ),
            SizedBox(height: tokens.spaceXl),
            if (state.status == ProductFormStatus.failed) ...[
              Text(
                l10n.errorSaveFailed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              gap,
            ],
            FilledButton(
              onPressed: state.status == ProductFormStatus.saving
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
