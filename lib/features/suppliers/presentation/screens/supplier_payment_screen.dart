import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/form_error_banner.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../../core/widgets/save_button.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../../core/widgets/unsaved_changes_guard.dart';
import '../../../customers/domain/customer_errors.dart';
import '../../../customers/domain/payment.dart';
import '../../../customers/presentation/cubits/customers_list_cubit.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../cubits/supplier_payment_cubit.dart';
import '../widgets/supplier_text.dart';

/// Pays a supplier (US5, FR-016).
class SupplierPaymentScreen extends StatelessWidget {
  const SupplierPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<SupplierPaymentCubit, SupplierPaymentState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: _onStatus,
      child: BlocSelector<SupplierPaymentCubit, SupplierPaymentState, bool>(
        // Rebuilt only when the answer to "leave?" changes.
        selector: (_) => context.read<SupplierPaymentCubit>().hasUnsavedChanges,
        builder: (context, dirty) => UnsavedChangesGuard(
          dirty: dirty,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.supplierPaymentTitle)),
            body: BlocBuilder<SupplierPaymentCubit, SupplierPaymentState>(
              buildWhen: (a, b) =>
                  (a.status == SupplierPaymentStatus.loading) !=
                      (b.status == SupplierPaymentStatus.loading) ||
                  (a.status == SupplierPaymentStatus.notFound) !=
                      (b.status == SupplierPaymentStatus.notFound),
              builder: (context, state) => switch (state.status) {
                SupplierPaymentStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                SupplierPaymentStatus.notFound => Center(
                  child: Text(l10n.supplierNotFound),
                ),
                _ => const _Form(),
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onStatus(
    BuildContext context,
    SupplierPaymentState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SupplierPaymentCubit>();
    switch (state.status) {
      case SupplierPaymentStatus.confirmOverpay:
        final ok = await showConfirmDialog(
          context,
          tone: StatusTone.warning,
          title: l10n.supplierOverpayTitle,
          message: l10n.supplierOverpayBody(
            context.money(state.supplierOwesAfterPiasters),
          ),
          confirmLabel: l10n.confirmAction,
          cancelLabel: l10n.backAction,
        );
        if (ok ?? false) {
          await cubit.confirmOverpay();
        } else {
          cubit.cancelOverpay();
        }
      case SupplierPaymentStatus.saved:
        showAppSnackBar(
          context,
          l10n.paymentSaved(
            context.supplierPaymentNumber(state.paymentNumber!),
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
  late final SupplierPaymentCubit _cubit = context.read<SupplierPaymentCubit>();
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
    final state = context.watch<SupplierPaymentCubit>().state;

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
            if (refusal != null ||
                state.status == SupplierPaymentStatus.failed) ...[
              FormErrorBanner(
                title: refusal == null
                    ? l10n.errorSaveFailed
                    : context.supplierPaymentError(refusal),
              ),
              gap,
            ],
            Text(state.supplierName, style: theme.textTheme.titleLarge),
            SizedBox(height: tokens.spaceXs),
            Text(
              l10n.paymentBalanceNow(
                context.supplierBalance(state.balancePiasters),
              ),
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
            SaveButton(
              label: l10n.saveAction,
              savingLabel: l10n.savingLabel,
              saving: state.status == SupplierPaymentStatus.saving,
              onPressed: _cubit.submit,
            ),
          ],
        ),
      ),
    );
  }
}
