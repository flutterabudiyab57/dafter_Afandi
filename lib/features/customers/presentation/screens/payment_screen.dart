import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/customer_errors.dart';
import '../../domain/payment.dart';
import '../cubits/customers_list_cubit.dart';
import '../cubits/payment_cubit.dart';
import '../widgets/customer_text.dart';

/// Receives a payment from a customer (US5, FR-016).
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<PaymentCubit, PaymentState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onStatus,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.paymentTitle)),
        body: BlocBuilder<PaymentCubit, PaymentState>(
          buildWhen: (a, b) =>
              (a.status == PaymentStatus.loading) !=
                  (b.status == PaymentStatus.loading) ||
              (a.status == PaymentStatus.notFound) !=
                  (b.status == PaymentStatus.notFound),
          builder: (context, state) => switch (state.status) {
            PaymentStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            PaymentStatus.notFound => Center(
              child: Text(l10n.customerNotFound),
            ),
            _ => const _Form(),
          },
        ),
      ),
    );
  }

  Future<void> _onStatus(BuildContext context, PaymentState state) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PaymentCubit>();
    switch (state.status) {
      case PaymentStatus.confirmCredit:
        final ok = await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: Text(l10n.paymentCreditTitle),
            content: SingleChildScrollView(
              child: Text(
                l10n.paymentCreditBody(
                  context.money(state.creditAfterPiasters),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialog).pop(false),
                child: Text(l10n.backAction),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialog).pop(true),
                child: Text(l10n.confirmAction),
              ),
            ],
          ),
        );
        if (ok ?? false) {
          await cubit.confirmCredit();
        } else {
          cubit.cancelCredit();
        }
      case PaymentStatus.saved:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.paymentSaved(context.receiptNumber(state.receiptNumber!)),
            ),
          ),
        );
        context.pop();
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
  late final PaymentCubit _cubit = context.read<PaymentCubit>();
  late final _amount = TextEditingController(text: _cubit.state.amount);
  late final _note = TextEditingController(text: _cubit.state.note);

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<PaymentCubit>().state;

    String? err(CustomerField f) {
      final e = errorFor(state.errors, f);
      return e == null ? null : context.customerFieldError(e);
    }

    final gap = SizedBox(height: tokens.spaceMd);
    final refusal = state.refusal;
    return SafeArea(
      child: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(state.customerName, style: theme.textTheme.titleLarge),
            SizedBox(height: tokens.spaceXs),
            Text(
              l10n.paymentBalanceNow(context.balance(state.balancePiasters)),
            ),
            gap,
            MoneyField(
              controller: _amount,
              label: l10n.paymentAmountLabel,
              onChanged: _cubit.amountChanged,
              errorText: err(CustomerField.amount),
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
                    selected: state.method == m,
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
                CodePointLengthFormatter(maxCustomerTextLength),
              ],
              decoration: InputDecoration(
                labelText: l10n.customerNoteLabel,
                errorText: err(CustomerField.note),
                errorMaxLines: 3,
              ),
            ),
            SizedBox(height: tokens.spaceXl),
            if (refusal != null || state.status == PaymentStatus.failed) ...[
              Text(
                refusal == null
                    ? l10n.errorSaveFailed
                    : context.paymentError(refusal),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              gap,
            ],
            FilledButton(
              onPressed: state.status == PaymentStatus.saving
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
