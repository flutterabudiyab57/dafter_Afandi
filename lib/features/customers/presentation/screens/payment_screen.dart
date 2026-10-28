import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_error_banner.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../../core/widgets/save_button.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../../core/widgets/unsaved_changes_guard.dart';
import '../../../payments/presentation/widgets/payment_split_field.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/customer_errors.dart';
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
      child: BlocSelector<PaymentCubit, PaymentState, bool>(
        // Rebuilt only when the answer to "leave?" changes.
        selector: (_) => context.read<PaymentCubit>().hasUnsavedChanges,
        builder: (context, dirty) => UnsavedChangesGuard(
          dirty: dirty,
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
        ),
      ),
    );
  }

  Future<void> _onStatus(BuildContext context, PaymentState state) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<PaymentCubit>();
    switch (state.status) {
      case PaymentStatus.confirmCredit:
        final ok = await showConfirmDialog(
          context,
          tone: StatusTone.warning,
          title: l10n.paymentCreditTitle,
          message: l10n.paymentCreditBody(
            context.money(state.creditAfterPiasters),
          ),
          confirmLabel: l10n.confirmAction,
          cancelLabel: l10n.backAction,
        );
        if (ok ?? false) {
          await cubit.confirmCredit();
        } else {
          cubit.cancelCredit();
        }
      case PaymentStatus.saved:
        showAppSnackBar(
          context,
          l10n.paymentSaved(context.receiptNumber(state.receiptNumber!)),
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
            if (refusal != null || state.status == PaymentStatus.failed) ...[
              FormErrorBanner(
                title: refusal == null
                    ? l10n.errorSaveFailed
                    : context.paymentError(refusal),
              ),
              gap,
            ],
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
            PaymentSplitField(
              totalPiasters: tryParsePiasters(state.amount) ?? 0,
              onChanged: _cubit.paymentChanged,
              errors: state.paymentErrors,
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
            SaveButton(
              label: l10n.saveAction,
              savingLabel: l10n.savingLabel,
              saving: state.status == PaymentStatus.saving,
              onPressed: _cubit.submit,
            ),
          ],
        ),
      ),
    );
  }
}
