import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/account_ref.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/payment_method.dart';
import '../../domain/payment_split.dart';
import '../cubits/payment_split_cubit.dart';
import '../payments_cubits.dart';
import 'payment_text.dart';

/// How a payment is made (contracts "PaymentSplitField", FR-033 to FR-038):
/// method chips, cash first; an optional account number for wallet and
/// InstaPay with the ones used before; and "Split payment" for up to three
/// parts. It keeps its own [PaymentSplitCubit], from the [PaymentsCubits]
/// the app provides, and reports every change of the parts through
/// [onChanged]. A new key starts it again with one cash part.
class PaymentSplitField extends StatelessWidget {
  const PaymentSplitField({
    required this.totalPiasters,
    required this.onChanged,
    this.errors = const [],
    super.key,
  });

  /// The amount being paid.
  final int totalPiasters;
  final ValueChanged<List<PaymentPartInput>> onChanged;

  /// Shown after a save was refused.
  final List<PaymentSplitError> errors;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => context.read<PaymentsCubits>().paymentSplit(),
    child: _Body(
      totalPiasters: totalPiasters,
      onChanged: onChanged,
      errors: errors,
    ),
  );
}

class _Body extends StatefulWidget {
  const _Body({
    required this.totalPiasters,
    required this.onChanged,
    required this.errors,
  });

  final int totalPiasters;
  final ValueChanged<List<PaymentPartInput>> onChanged;
  final List<PaymentSplitError> errors;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final List<TextEditingController> _amounts = [];
  final List<TextEditingController> _accounts = [];

  PaymentSplitCubit get _cubit => context.read<PaymentSplitCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.totalChanged(widget.totalPiasters);
  }

  @override
  void didUpdateWidget(_Body old) {
    super.didUpdateWidget(old);
    if (old.totalPiasters != widget.totalPiasters) {
      _cubit.totalChanged(widget.totalPiasters);
    }
  }

  @override
  void dispose() {
    for (final c in [..._amounts, ..._accounts]) {
      c.dispose();
    }
    super.dispose();
  }

  /// One controller per part; text set by the cubit (part 1 following the
  /// rest, a removed part's amount, a picked account) is copied in.
  void _sync(List<PaymentPartInput> parts) {
    while (_amounts.length < parts.length) {
      _amounts.add(TextEditingController());
      _accounts.add(TextEditingController());
    }
    while (_amounts.length > parts.length) {
      _amounts.removeLast().dispose();
      _accounts.removeLast().dispose();
    }
    for (final (i, p) in parts.indexed) {
      _set(_amounts[i], p.amountText);
      _set(_accounts[i], p.accountText);
    }
  }

  static void _set(TextEditingController c, String text) {
    if (c.text == text) return;
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String? _errorAt(int index, bool Function(PaymentSplitError e) match) {
    for (final e in widget.errors) {
      if (e.index == index && match(e)) return context.paymentSplitError(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final errorStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.error,
    );
    return BlocConsumer<PaymentSplitCubit, PaymentSplitState>(
      listenWhen: (a, b) => a.parts != b.parts,
      listener: (context, s) => widget.onChanged(s.parts),
      builder: (context, s) {
        _sync(s.parts);
        final difference = s.differencePiasters;
        final overall = [
          for (final e in widget.errors)
            if (e.index == null) context.paymentSplitError(e),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.spaceSm,
          children: [
            Text(l10n.saleMethodLabel, style: theme.textTheme.labelLarge),
            for (final (i, part) in s.parts.indexed) ...[
              if (s.isSplit)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.paymentPartTitle(context.count(i + 1)),
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    if (i > 0)
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: l10n.paymentPartRemove(context.count(i + 1)),
                        onPressed: () => _cubit.removePart(i),
                      ),
                  ],
                ),
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                children: [
                  for (final m in offeredPaymentMethods)
                    ChoiceChip(
                      label: Text(context.methodLabel(m)),
                      selected: part.method == m,
                      onSelected: (_) => _cubit.methodChanged(i, m),
                    ),
                ],
              ),
              if (_errorAt(i, (e) => e is MethodRepeated) case final e?)
                Text(e, style: errorStyle),
              if (s.isSplit)
                MoneyField(
                  controller: _amounts[i],
                  label: l10n.paymentPartAmountLabel,
                  onChanged: (v) => _cubit.amountChanged(i, v),
                  errorText: _errorAt(
                    i,
                    (e) => e is PartAmountInvalid || e is PartAmountZero,
                  ),
                ),
              if (part.method != PaymentMethod.cash) ...[
                TextField(
                  controller: _accounts[i],
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: maxAccountRefLength,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: l10n.paymentAccountLabel,
                    helperText: l10n.paymentAccountHint,
                    errorText: _errorAt(
                      i,
                      (e) =>
                          e is AccountInvalid ||
                          e is AccountTooLong ||
                          e is AccountNotAllowed,
                    ),
                    counterText: '',
                  ),
                  onChanged: (v) => _cubit.accountChanged(i, v),
                ),
                if (s.suggestions[part.method] case final refs?
                    when refs.isNotEmpty) ...[
                  Text(
                    l10n.paymentAccountSuggestions,
                    style: theme.textTheme.bodySmall,
                  ),
                  Wrap(
                    spacing: tokens.spaceSm,
                    runSpacing: tokens.spaceXs,
                    children: [
                      for (final ref in refs)
                        ActionChip(
                          label: Text(ltrIsolate(ref)),
                          onPressed: () => _cubit.accountChanged(i, ref),
                        ),
                    ],
                  ),
                ],
              ],
              if (s.isSplit && i < s.parts.length - 1) const Divider(),
            ],
            if (difference != null)
              Text(
                difference < 0
                    ? l10n.paymentRemaining(context.money(-difference))
                    : difference > 0
                    ? l10n.paymentOverBy(context.money(difference))
                    : l10n.paymentSplitBalanced,
                style: difference == 0 ? null : errorStyle,
              ),
            for (final e in overall) Text(e, style: errorStyle),
            if (s.canSplit)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.call_split),
                  label: Text(l10n.paymentSplitAction),
                  onPressed: _cubit.split,
                ),
              ),
          ],
        );
      },
    );
  }
}
