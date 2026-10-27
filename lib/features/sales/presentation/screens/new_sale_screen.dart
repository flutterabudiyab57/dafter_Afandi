import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/decimal_text.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_error_banner.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../../core/widgets/save_button.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../customers/domain/customer.dart';
import '../../../customers/domain/payment.dart';
import '../../../customers/presentation/cubits/customer_form_cubit.dart';
import '../../../customers/presentation/cubits/customers_list_cubit.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/quantity_input.dart';
import '../../../products/presentation/cubits/product_picker_cubit.dart';
import '../../../products/presentation/screens/product_picker_page.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/sale_draft.dart';
import '../../domain/sale_errors.dart';
import '../cubits/sale_cubit.dart';
import '../widgets/sale_text.dart';
import 'pickers.dart';

/// Rings up a sale (US1, US2): products, discounts, customer, paid now and
/// method. After saving it is empty and ready for the next sale.
class NewSaleScreen extends StatelessWidget {
  const NewSaleScreen({
    required this.productPicker,
    required this.customerPicker,
    required this.newCustomer,
    super.key,
  });

  final ProductPickerCubit Function() productPicker;
  final CustomersListCubit Function() customerPicker;
  final CustomerFormCubit Function(String name) newCustomer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SaleCubit>();
    return BlocListener<SaleCubit, SaleState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onStatus,
      child: BlocBuilder<SaleCubit, SaleState>(
        buildWhen: (a, b) => a.draft.isEmpty != b.draft.isEmpty,
        builder: (context, state) => PopScope(
          canPop: !cubit.hasUnsavedLines,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final router = GoRouter.of(context);
            if (await _confirmDiscard(context)) router.pop();
          },
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.saleNewTitle)),
            body: _Body(
              productPicker: productPicker,
              customerPicker: customerPicker,
              newCustomer: newCustomer,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onStatus(BuildContext context, SaleState state) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SaleCubit>();
    switch (state.status) {
      case SaleStatus.confirmShortage:
        if (await _confirmShortage(context, state.shortages)) {
          await cubit.confirmShortage();
        } else {
          cubit.cancelShortage();
        }
      case SaleStatus.saved:
        showAppSnackBar(
          context,
          l10n.saleSaved(context.saleNumber(state.saved!.number)),
        );
        // Back to where the sale was started; the message stays.
        if (context.canPop()) {
          context.pop();
        } else {
          cubit.startNew();
        }
      default:
        break;
    }
  }

  Future<bool> _confirmShortage(
    BuildContext context,
    List<Shortage> items,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      tone: StatusTone.warning,
      title: l10n.shortageTitle,
      message: [
        l10n.shortageBody,
        for (final s in items)
          l10n.shortageLine(
            s.name,
            context.quantity(s.stockMilli, s.unit),
            context.quantity(s.needMilli, s.unit),
          ),
      ].join('\n'),
      confirmLabel: l10n.shortageConfirm,
      cancelLabel: l10n.backAction,
    );
    return ok ?? false;
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      tone: StatusTone.warning,
      title: l10n.saleDiscardTitle,
      message: l10n.saleDiscardBody,
      confirmLabel: l10n.saleDiscardAction,
      cancelLabel: l10n.saleKeepAction,
      destructive: true,
    );
    return ok ?? false;
  }
}

class _Body extends StatefulWidget {
  const _Body({
    required this.productPicker,
    required this.customerPicker,
    required this.newCustomer,
  });

  final ProductPickerCubit Function() productPicker;
  final CustomersListCubit Function() customerPicker;
  final CustomerFormCubit Function(String name) newCustomer;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final SaleCubit _cubit = context.read<SaleCubit>();
  final _barcode = TextEditingController();
  final _barcodeFocus = FocusNode();
  final _invoiceDiscount = TextEditingController();
  final _paid = TextEditingController();

  @override
  void dispose() {
    _barcode.dispose();
    _barcodeFocus.dispose();
    _invoiceDiscount.dispose();
    _paid.dispose();
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
    final picked = await Navigator.of(context).push<ProductSummary>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => widget.productPicker(),
          child: const ProductPickerPage(),
        ),
      ),
    );
    if (picked != null) _cubit.addProduct(picked);
  }

  Future<void> _pickCustomer() async {
    final picked = await Navigator.of(context).push<CustomerSummary>(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => widget.customerPicker(),
          child: CustomerPickerPage(newCustomer: widget.newCustomer),
        ),
      ),
    );
    if (picked != null) {
      _cubit.customerChanged(
        SaleCustomer(id: picked.customer.id, name: picked.customer.name),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<SaleCubit>().state;
    final draft = state.draft;
    final gap = SizedBox(height: tokens.spaceMd);

    String? fieldError(SaleField f) {
      final p = state.inputError(f);
      return p == null ? null : context.inputProblem(f, p);
    }

    // Rules that block saving but lose nothing are warnings with a way
    // forward; failures are errors (research R11). Line errors stay on
    // their lines.
    final banners = <Widget?>[
      for (final e in state.errors)
        switch (e) {
          CreditNeedsCustomer() => FormErrorBanner(
            tone: StatusTone.warning,
            title: l10n.creditNeedsCustomerTitle,
            message: context.saleError(e),
            actionLabel: l10n.chooseAction,
            onAction: _pickCustomer,
          ),
          PaidTooLarge() => FormErrorBanner(
            tone: StatusTone.warning,
            title: context.saleError(e)!,
          ),
          LineQuantityInvalid() ||
          LinePriceInvalid() ||
          LineDiscountTooLarge() => null,
          _ => switch (context.saleError(e)) {
            final text? => FormErrorBanner(title: text),
            null => null,
          },
        },
      if (state.saveError != null)
        if (context.saveError(state.saveError!) case final text?)
          FormErrorBanner(title: text),
      if (state.status == SaleStatus.failed)
        FormErrorBanner(title: l10n.errorSaveFailed),
    ].nonNulls.toList();

    return BlocListener<SaleCubit, SaleState>(
      // A saved sale empties the fields for the next one; a paid amount
      // reset by a new total (SaleCubit._update) empties the paid field.
      listenWhen: (a, b) =>
          (a.status != b.status && b.status == SaleStatus.saved) ||
          (a.draft.paidPiasters != null && b.draft.paidPiasters == null),
      listener: (_, s) {
        _paid.clear();
        if (s.status != SaleStatus.saved) return;
        _invoiceDiscount.clear();
        _barcode.clear();
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
                icon: const Icon(Icons.add_shopping_cart),
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
                    fieldError(SaleField.invoiceDiscount) ??
                    (state.errors.contains(const InvoiceDiscountTooLarge())
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
              Text(l10n.saleCustomerLabel, style: theme.textTheme.labelLarge),
              SizedBox(height: tokens.spaceXs),
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(draft.customer?.name ?? l10n.walkInCustomer),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.person_search),
                    label: Text(l10n.saleCustomerPick),
                    onPressed: _pickCustomer,
                  ),
                  if (draft.customer != null)
                    TextButton(
                      onPressed: () => _cubit.customerChanged(null),
                      child: Text(l10n.saleCustomerClear),
                    ),
                ],
              ),
              gap,
              MoneyField(
                controller: _paid,
                label: l10n.salePaidLabel,
                helperText: l10n.salePaidHint,
                onChanged: _cubit.paidChanged,
                errorText: fieldError(SaleField.paid),
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
              SizedBox(height: tokens.spaceXl),
              SaveButton(
                label: l10n.saleSaveAction,
                savingLabel: l10n.savingLabel,
                saving: state.status == SaleStatus.saving,
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

/// One line: name, quantity, price and discount fields, and its total.
class _LineEditor extends StatefulWidget {
  const _LineEditor({required this.line, required this.errors, super.key});

  final SaleLine line;
  final List<SaleError> errors;

  @override
  State<_LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends State<_LineEditor> {
  late final SaleCubit _cubit = context.read<SaleCubit>();
  late final _qty = TextEditingController(text: _qtyText(widget.line.qtyMilli));
  late final _price = TextEditingController(
    text: _moneyText(widget.line.unitPricePiasters),
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
    _price.dispose();
    _discount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<SaleCubit>().state;
    final line = widget.line;
    final id = line.productId;

    String? err(SaleField f, SaleError? rule, String ruleText) {
      final p = state.inputError(f, id);
      if (p != null) return context.inputProblem(f, p);
      return rule != null && widget.errors.contains(rule) ? ruleText : null;
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
                  tooltip: l10n.saleRemoveLine(line.name),
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
                SaleField.qty,
                LineQuantityInvalid(id),
                l10n.errorQuantityInvalid,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            MoneyField(
              controller: _price,
              label: l10n.salePriceLabel,
              onChanged: (t) => _cubit.priceChanged(id, t),
              errorText: err(
                SaleField.price,
                LinePriceInvalid(id),
                l10n.errorPriceInvalid,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            MoneyField(
              controller: _discount,
              label: l10n.saleLineDiscountLabel,
              onChanged: (t) => _cubit.lineDiscountChanged(id, t),
              errorText: err(
                SaleField.discount,
                LineDiscountTooLarge(id),
                l10n.errorLineDiscountTooLarge,
              ),
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              l10n.saleLineTotal(context.money(line.lineTotal)),
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
