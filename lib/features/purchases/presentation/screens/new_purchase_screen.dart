import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/decimal_text.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../../../core/widgets/form_error_banner.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../../core/widgets/save_button.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../customers/domain/payment.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/quantity_input.dart';
import '../../../products/presentation/cubits/product_form_cubit.dart';
import '../../../products/presentation/cubits/product_picker_cubit.dart';
import '../../../products/presentation/screens/product_picker_page.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../suppliers/domain/supplier.dart';
import '../../../suppliers/presentation/cubits/supplier_form_cubit.dart';
import '../../../suppliers/presentation/cubits/suppliers_list_cubit.dart';
import '../../../suppliers/presentation/screens/supplier_picker_page.dart';
import '../../../suppliers/presentation/widgets/supplier_text.dart';
import '../../domain/purchase_draft.dart';
import '../../domain/purchase_errors.dart';
import '../cubits/purchase_cubit.dart';
import '../widgets/purchase_text.dart';
import 'quick_add_product_page.dart';

/// Records a purchase (US1, US2): products with their cost, discounts,
/// supplier and their invoice number and date, paid now and method. After
/// saving it is empty and ready for the next purchase.
class NewPurchaseScreen extends StatelessWidget {
  const NewPurchaseScreen({
    required this.productPicker,
    required this.quickAddProduct,
    required this.supplierPicker,
    required this.newSupplier,
    super.key,
  });

  final ProductPickerCubit Function() productPicker;
  final ProductFormCubit Function(String name) quickAddProduct;
  final SuppliersListCubit Function() supplierPicker;
  final SupplierFormCubit Function(String name) newSupplier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PurchaseCubit>();
    return BlocListener<PurchaseCubit, PurchaseState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == PurchaseStatus.saved,
      listener: (context, state) {
        showAppSnackBar(
          context,
          l10n.purchaseSaved(context.purchaseNumber(state.saved!.number)),
        );
        // Back to where the purchase was started; the message stays.
        if (context.canPop()) {
          context.pop();
        } else {
          cubit.startNew();
        }
      },
      child: BlocBuilder<PurchaseCubit, PurchaseState>(
        buildWhen: (a, b) => a.draft.isEmpty != b.draft.isEmpty,
        builder: (context, state) => PopScope(
          canPop: !cubit.hasUnsavedLines,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final router = GoRouter.of(context);
            if (await _confirmDiscard(context)) router.pop();
          },
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.purchaseNewTitle)),
            body: _Body(
              productPicker: productPicker,
              quickAddProduct: quickAddProduct,
              supplierPicker: supplierPicker,
              newSupplier: newSupplier,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      tone: StatusTone.warning,
      title: l10n.purchaseDiscardTitle,
      message: l10n.saleDiscardBody,
      confirmLabel: l10n.saleDiscardAction,
      cancelLabel: l10n.purchaseKeepAction,
      destructive: true,
    );
    return ok ?? false;
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.productPicker,
    required this.quickAddProduct,
    required this.supplierPicker,
    required this.newSupplier,
  });

  final ProductPickerCubit Function() productPicker;
  final ProductFormCubit Function(String name) quickAddProduct;
  final SuppliersListCubit Function() supplierPicker;
  final SupplierFormCubit Function(String name) newSupplier;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final PurchaseCubit _cubit = context.read<PurchaseCubit>();
  final _barcode = TextEditingController();
  final _barcodeFocus = FocusNode();
  final _invoiceDiscount = TextEditingController();
  final _supplierRef = TextEditingController();
  final _paid = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    for (final c in [_barcode, _invoiceDiscount, _supplierRef, _paid, _note]) {
      c.dispose();
    }
    _barcodeFocus.dispose();
    super.dispose();
  }

  Future<void> _scan(String code) async {
    if (code.trim().isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final found = await _cubit.addByBarcode(code);
    _barcode.clear();
    _barcodeFocus.requestFocus();
    if (!found) {
      showAppSnackBarOn(
        messenger,
        l10n.saleBarcodeNotFound,
        tone: StatusTone.error,
      );
    }
  }

  Future<void> _pickProduct() async {
    final l10n = AppLocalizations.of(context);
    final picked = await Navigator.of(context).push<ProductSummary>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => widget.productPicker(),
          child: ProductPickerPage(
            onQuickAdd: _quickAdd,
            quickAddLabel: l10n.purchaseAddProductNamed,
          ),
        ),
      ),
    );
    if (picked != null) await _cubit.addProduct(picked);
  }

  /// Opens the quick-add form from the picker; the new product, or null.
  Future<ProductSummary?> _quickAdd(BuildContext picker, String name) async {
    final pickerCubit = picker.read<ProductPickerCubit>();
    final id = await Navigator.of(picker).push<String>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => widget.quickAddProduct(name),
          child: const QuickAddProductPage(),
        ),
      ),
    );
    return id == null ? null : pickerCubit.byId(id);
  }

  Future<void> _pickSupplier() async {
    final picked = await Navigator.of(context).push<SupplierSummary>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => widget.supplierPicker(),
          child: SupplierPickerPage(newSupplier: widget.newSupplier),
        ),
      ),
    );
    if (picked != null) {
      _cubit.supplierChanged(
        PurchaseSupplier(id: picked.supplier.id, name: picked.supplier.name),
      );
    }
  }

  Future<void> _pickDate(DateTime shown) async {
    // Plain Arabic numbers the days in Latin digits while its dates use
    // Arabic-Indic ones; Egyptian Arabic uses Arabic-Indic for both.
    final arabicIndic =
        DigitStyleScope.of(context) == DigitStyle.arabicIndic &&
        Localizations.localeOf(context).languageCode == 'ar';
    final picked = await showDatePicker(
      context: context,
      locale: arabicIndic ? const Locale('ar', 'EG') : null,
      initialDate: shown,
      firstDate: DateTime(2000),
      // No future dates (FR-005).
      lastDate: _cubit.today,
    );
    if (picked != null) _cubit.invoiceDateChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<PurchaseCubit>().state;
    final draft = state.draft;
    final gap = SizedBox(height: tokens.spaceMd);
    final date = draft.invoiceDate ?? _cubit.today;

    String? fieldError(PurchaseField f) {
      final p = state.inputError(f);
      return p == null ? null : context.purchaseInputProblem(f, p);
    }

    // Rules that block saving but lose nothing are warnings with a way
    // forward; failures are errors (research R11).
    final banners = <Widget?>[
      for (final e in state.errors)
        switch (e) {
          CreditNeedsSupplier() => FormErrorBanner(
            tone: StatusTone.warning,
            title: context.purchaseError(e)!,
            actionLabel: l10n.chooseAction,
            onAction: _pickSupplier,
          ),
          PurchasePaidTooLarge() => FormErrorBanner(
            tone: StatusTone.warning,
            title: context.purchaseError(e)!,
          ),
          _ => switch (context.purchaseError(e)) {
            final text? => FormErrorBanner(title: text),
            null => null,
          },
        },
      if (state.saveError != null)
        if (context.purchaseSaveError(state.saveError!) case final text?)
          FormErrorBanner(title: text),
      if (state.status == PurchaseStatus.failed)
        FormErrorBanner(title: l10n.errorSaveFailed),
    ].nonNulls.toList();

    return BlocListener<PurchaseCubit, PurchaseState>(
      // A saved purchase empties the fields for the next one; a paid amount
      // reset by a new total (PurchaseCubit._update) empties the paid field.
      listenWhen: (a, b) =>
          (a.status != b.status && b.status == PurchaseStatus.saved) ||
          (a.draft.paidPiasters != null && b.draft.paidPiasters == null),
      listener: (_, s) {
        _paid.clear();
        if (s.status != PurchaseStatus.saved) return;
        for (final c in [_invoiceDiscount, _barcode, _supplierRef, _note]) {
          c.clear();
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: tokens.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final b in banners) ...[b, SizedBox(height: tokens.spaceSm)],
              TextField(
                controller: _barcode,
                focusNode: _barcodeFocus,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.done,
                onSubmitted: _scan,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.qr_code_scanner),
                  labelText: l10n.saleBarcodeLabel,
                ),
              ),
              SizedBox(height: tokens.spaceSm),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_box_outlined),
                label: Text(l10n.saleAddProductAction),
                onPressed: _pickProduct,
              ),
              gap,
              if (draft.isEmpty)
                Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: tokens.spaceMd,
                  ),
                  child: Text(l10n.saleEmpty, textAlign: TextAlign.center),
                ),
              for (final line in draft.lines)
                _LineEditor(
                  key: ValueKey(line.productId),
                  line: line,
                  errors: state.errors,
                ),
              gap,
              MoneyField(
                controller: _invoiceDiscount,
                label: l10n.saleInvoiceDiscountLabel,
                onChanged: _cubit.invoiceDiscountChanged,
                errorText:
                    fieldError(PurchaseField.invoiceDiscount) ??
                    (state.errors.contains(
                          const PurchaseInvoiceDiscountTooLarge(),
                        )
                        ? l10n.errorInvoiceDiscountTooLarge
                        : null),
              ),
              gap,
              _AmountRow(label: l10n.saleSubtotal, piasters: draft.subtotal),
              _AmountRow(
                label: l10n.saleTotal,
                piasters: draft.total,
                style: theme.textTheme.titleLarge,
              ),
              gap,
              Text(
                l10n.purchaseSupplierLabel,
                style: theme.textTheme.labelLarge,
              ),
              SizedBox(height: tokens.spaceXs),
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(draft.supplier?.name ?? l10n.purchaseNoSupplier),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_search),
                    label: Text(l10n.purchaseSupplierPick),
                    onPressed: _pickSupplier,
                  ),
                  if (draft.supplier != null)
                    TextButton(
                      onPressed: () => _cubit.supplierChanged(null),
                      child: Text(l10n.purchaseNoSupplier),
                    ),
                ],
              ),
              gap,
              TextField(
                controller: _supplierRef,
                onChanged: _cubit.supplierRefChanged,
                textInputAction: TextInputAction.next,
                inputFormatters: const [
                  CodePointLengthFormatter(maxSupplierRefLength),
                ],
                decoration: InputDecoration(
                  labelText: l10n.purchaseSupplierRefLabel,
                  errorText: state.errors.contains(const SupplierRefTooLong())
                      ? l10n.errorCodeTooLong(
                          context.count(maxSupplierRefLength),
                        )
                      : null,
                  errorMaxLines: 3,
                ),
              ),
              gap,
              Text(l10n.purchaseDateLabel, style: theme.textTheme.labelLarge),
              SizedBox(height: tokens.spaceXs),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(context.date(date)),
                  onPressed: () => _pickDate(date),
                ),
              ),
              gap,
              MoneyField(
                controller: _paid,
                label: l10n.salePaidLabel,
                helperText: l10n.salePaidHint,
                onChanged: _cubit.paidChanged,
                errorText: fieldError(PurchaseField.paid),
                textInputAction: TextInputAction.done,
              ),
              if (draft.remaining > 0)
                _AmountRow(
                  label: l10n.saleRemaining,
                  piasters: draft.remaining,
                ),
              gap,
              Text(l10n.saleMethodLabel, style: theme.textTheme.labelLarge),
              SizedBox(height: tokens.spaceXs),
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                children: [
                  for (final m in offeredPaymentMethods)
                    ChoiceChip(
                      label: Text(context.methodLabel(m)),
                      selected: draft.method == m,
                      onSelected: (_) => _cubit.methodChanged(m),
                    ),
                ],
              ),
              gap,
              TextField(
                controller: _note,
                onChanged: _cubit.noteChanged,
                maxLines: null,
                inputFormatters: const [
                  CodePointLengthFormatter(maxPurchaseNoteLength),
                ],
                decoration: InputDecoration(labelText: l10n.customerNoteLabel),
              ),
              SizedBox(height: tokens.spaceXl),
              SaveButton(
                label: l10n.purchaseSaveAction,
                savingLabel: l10n.savingLabel,
                saving: state.status == PurchaseStatus.saving,
                onPressed: _cubit.submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.piasters, this.style});

  final String label;
  final int piasters;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.symmetric(vertical: context.tokens.spaceXs),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: context.tokens.spaceSm,
      children: [
        Text(label, style: style),
        Text(context.money(piasters), style: style),
      ],
    ),
  );
}

/// One line: name, quantity, cost and discount fields, its total and the
/// cost notice (FR-002a).
class _LineEditor extends StatefulWidget {
  const _LineEditor({required this.line, required this.errors, super.key});

  final PurchaseLine line;
  final List<PurchaseError> errors;

  @override
  State<_LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends State<_LineEditor> {
  late final PurchaseCubit _cubit = context.read<PurchaseCubit>();
  late final _qty = TextEditingController(text: _qtyText(widget.line.qtyMilli));
  late final _cost = TextEditingController(
    text: _moneyText(widget.line.unitCostPiasters),
  );
  final _discount = TextEditingController();

  static String _qtyText(int milli) =>
      formatScaledDecimal(milli, scale: 3, minDecimals: 0);

  static String _moneyText(int piasters) =>
      formatScaledDecimal(piasters, scale: 2, minDecimals: 0);

  @override
  void didUpdateWidget(_LineEditor old) {
    super.didUpdateWidget(old);
    // Adding the same product again raises the quantity from outside.
    final typed = readQuantity(_qty.text, widget.line.unit);
    final shown = typed is NumberValue ? typed.value : null;
    if (shown != widget.line.qtyMilli &&
        old.line.qtyMilli != widget.line.qtyMilli) {
      _qty.text = _qtyText(widget.line.qtyMilli);
    }
  }

  @override
  void dispose() {
    _qty.dispose();
    _cost.dispose();
    _discount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<PurchaseCubit>().state;
    final line = widget.line;
    final id = line.productId;

    String? err(PurchaseField f, PurchaseError rule, String ruleText) {
      final p = state.inputError(f, id);
      if (p != null) return context.purchaseInputProblem(f, p);
      return widget.errors.contains(rule) ? ruleText : null;
    }

    return Card(
      margin: EdgeInsetsDirectional.only(bottom: tokens.spaceSm),
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.spaceSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(line.name, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: l10n.purchaseRemoveLine(line.name),
                  onPressed: () => _cubit.remove(id),
                ),
              ],
            ),
            QuantityField(
              controller: _qty,
              label: l10n.saleQtyLabel,
              helperText: unitFull(l10n, line.unit),
              onChanged: (t) => _cubit.qtyChanged(id, t),
              errorText: err(
                PurchaseField.qty,
                PurchaseQuantityInvalid(id),
                l10n.errorQuantityInvalid,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            MoneyField(
              controller: _cost,
              label: l10n.purchaseCostLabel,
              onChanged: (t) => _cubit.costChanged(id, t),
              errorText: err(
                PurchaseField.cost,
                PurchaseCostInvalid(id),
                l10n.errorPriceInvalid,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            MoneyField(
              controller: _discount,
              label: l10n.saleLineDiscountLabel,
              onChanged: (t) => _cubit.lineDiscountChanged(id, t),
              errorText: err(
                PurchaseField.discount,
                PurchaseLineDiscountTooLarge(id),
                l10n.errorLineDiscountTooLarge,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              l10n.saleLineTotal(context.money(line.lineTotal)),
              style: theme.textTheme.titleSmall,
            ),
            if (line.costNotice) ...[
              SizedBox(height: tokens.spaceXs),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: tokens.spaceXs),
                  Expanded(
                    child: Text(
                      l10n.purchaseCostNotice,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
