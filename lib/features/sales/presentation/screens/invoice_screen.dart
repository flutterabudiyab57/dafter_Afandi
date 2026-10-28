import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/load_failed_view.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../customers/presentation/widgets/reason_dialog.dart';
import '../../../payments/presentation/widgets/payment_parts_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/sale.dart';
import '../../domain/sale_errors.dart';
import '../cubits/sales_list_cubit.dart';
import '../widgets/sale_text.dart';

/// One saved invoice with every line and amount (US3, FR-010), and Void
/// (US6). Titled as a sales invoice, never a tax document.
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<InvoiceCubit, InvoiceState>(
      builder: (context, state) {
        final invoice = state.invoice;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              invoice == null
                  ? l10n.navSales
                  : l10n.invoiceTitle(
                      context.saleNumber(invoice.summary.number),
                    ),
            ),
          ),
          body: state.loadFailed
              ? dataLoadFailedView(
                  context,
                  onRetry: context.read<InvoiceCubit>().retry,
                )
              : !state.loaded
              ? const Center(child: CircularProgressIndicator())
              : invoice == null
              ? Center(child: Text(l10n.invoiceNotFound))
              : _Body(invoice: invoice),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.invoice});

  final SaleInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final s = invoice.summary;
    final voidedAt = invoice.voidedAt;
    final customerId = s.customerId;

    Widget amount(String label, int piasters, {TextStyle? style}) => Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tokens.spaceMd,
        vertical: tokens.spaceXs,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: tokens.spaceSm,
        children: [
          Text(label, style: style),
          Text(context.money(piasters), style: style),
        ],
      ),
    );

    // A column, not a lazy list, so every line exists at any text size.
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.only(bottom: tokens.spaceXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (voidedAt != null)
            Padding(
              padding: EdgeInsetsDirectional.all(tokens.spaceMd),
              child: StatusBanner(
                tone: StatusTone.voided,
                title: l10n.invoiceVoidedOn(
                  context.dateTime(voidedAt),
                  invoice.voidReason ?? '',
                ),
              ),
            ),
          ListTile(
            title: Text(l10n.invoiceDateLabel),
            subtitle: Text(context.dateTime(s.at)),
          ),
          ListTile(
            title: Text(l10n.saleCustomerLabel),
            subtitle: Text(s.customerName ?? l10n.walkInCustomer),
            trailing: customerId == null
                ? null
                : const Icon(Icons.chevron_right),
            onTap: customerId == null
                ? null
                : () => context.push(RoutePaths.customerDetails(customerId)),
          ),
          const Divider(),
          for (final item in invoice.items)
            ListTile(
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.invoiceLineDetail(
                      context.quantity(item.qtyMilli, item.unit),
                      context.money(item.unitPricePiasters),
                    ),
                  ),
                  if (item.lineDiscountPiasters > 0)
                    Text(
                      l10n.invoiceLineDiscount(
                        context.money(item.lineDiscountPiasters),
                      ),
                    ),
                ],
              ),
              trailing: Text(
                context.money(item.lineTotalPiasters),
                style: theme.textTheme.titleSmall,
              ),
            ),
          const Divider(),
          amount(l10n.saleSubtotal, invoice.subtotalPiasters),
          if (invoice.invoiceDiscountPiasters > 0)
            amount(
              l10n.saleInvoiceDiscountLabel,
              invoice.invoiceDiscountPiasters,
            ),
          amount(
            l10n.saleTotal,
            s.totalPiasters,
            style: theme.textTheme.titleLarge,
          ),
          amount(l10n.salePaidLabel, s.paidPiasters),
          if (s.remainingPiasters > 0)
            amount(l10n.saleRemaining, s.remainingPiasters),
          // Nothing was paid on a full-credit sale, so it has no method.
          if (s.paidPiasters > 0)
            ListTile(
              title: Text(l10n.saleMethodLabel),
              subtitle: PaymentPartsText(
                parts: invoice.parts,
                method: invoice.method,
              ),
            ),
          if (voidedAt == null)
            Padding(
              padding: EdgeInsetsDirectional.all(tokens.spaceMd),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.block),
                  label: Text(l10n.invoiceVoidAction),
                  onPressed: () => _void(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _void(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<InvoiceCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(
      context,
      title: l10n.invoiceVoidTitle,
      body: l10n.invoiceVoidBody,
      action: l10n.invoiceVoidAction,
    );
    if (reason == null) return;
    final VoidError? error;
    try {
      error = await cubit.voidSale(reason);
    } on Object {
      // The transaction rolled back, so nothing changed.
      showAppSnackBarOn(
        messenger,
        l10n.errorActionFailed,
        tone: StatusTone.error,
      );
      rethrow;
    }
    if (error == null) {
      showAppSnackBarOn(messenger, l10n.invoiceVoided);
    } else if (context.mounted) {
      showAppSnackBarOn(
        messenger,
        context.voidError(error),
        tone: StatusTone.error,
      );
    }
  }
}
