import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/load_failed_view.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../customers/presentation/widgets/reason_dialog.dart';
import '../../../payments/presentation/widgets/payment_parts_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../suppliers/presentation/widgets/supplier_text.dart';
import '../../domain/purchase.dart';
import '../../domain/purchase_errors.dart';
import '../cubits/purchases_list_cubit.dart';
import '../widgets/purchase_text.dart';

/// One saved purchase with every line and amount (US3, FR-011), and Void
/// (US6). Titled as a purchase invoice, never a tax document.
class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PurchaseViewCubit, PurchaseViewState>(
      builder: (context, state) {
        final purchase = state.purchase;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              purchase == null
                  ? l10n.navPurchases
                  : l10n.purchaseTitle(
                      context.purchaseNumber(purchase.summary.number),
                    ),
            ),
          ),
          body: state.loadFailed
              ? dataLoadFailedView(
                  context,
                  onRetry: context.read<PurchaseViewCubit>().retry,
                )
              : !state.loaded
              ? const Center(child: CircularProgressIndicator())
              : purchase == null
              ? Center(child: Text(l10n.purchaseNotFound))
              : _Body(purchase: purchase),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final s = purchase.summary;
    final voidedAt = purchase.voidedAt;
    final supplierId = s.supplierId;
    final ref = s.supplierRef;
    final note = purchase.note;

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
                  purchase.voidReason ?? '',
                ),
              ),
            ),
          ListTile(
            title: Text(l10n.purchaseDateLabel),
            subtitle: Text(context.date(s.invoiceDate)),
          ),
          ListTile(
            title: Text(l10n.purchaseSupplierLabel),
            subtitle: Text(s.supplierName ?? l10n.purchaseNoSupplier),
            trailing: supplierId == null
                ? null
                : const Icon(Icons.chevron_right),
            onTap: supplierId == null
                ? null
                : () => context.push(RoutePaths.supplierDetails(supplierId)),
          ),
          if (ref != null)
            ListTile(
              title: Text(l10n.purchaseSupplierRefLabel),
              subtitle: Text(ref),
            ),
          const Divider(),
          for (final item in purchase.items)
            ListTile(
              title: Text(item.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.invoiceLineDetail(
                      context.quantity(item.qtyMilli, item.unit),
                      context.money(item.unitCostPiasters),
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
          amount(l10n.saleSubtotal, purchase.subtotalPiasters),
          if (purchase.invoiceDiscountPiasters > 0)
            amount(
              l10n.saleInvoiceDiscountLabel,
              purchase.invoiceDiscountPiasters,
            ),
          amount(
            l10n.saleTotal,
            s.totalPiasters,
            style: theme.textTheme.titleLarge,
          ),
          amount(l10n.salePaidLabel, s.paidPiasters),
          if (s.remainingPiasters > 0)
            amount(l10n.saleRemaining, s.remainingPiasters),
          // Nothing was paid on a full-credit purchase, so it has no method.
          if (s.paidPiasters > 0)
            ListTile(
              title: Text(l10n.saleMethodLabel),
              subtitle: PaymentPartsText(
                parts: purchase.parts,
                method: purchase.method,
              ),
            ),
          if (note != null)
            ListTile(title: Text(l10n.customerNoteLabel), subtitle: Text(note)),
          if (voidedAt == null)
            Padding(
              padding: EdgeInsetsDirectional.all(tokens.spaceMd),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.block),
                  label: Text(l10n.purchaseVoidAction),
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
    final cubit = context.read<PurchaseViewCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(
      context,
      title: l10n.purchaseVoidTitle,
      body: l10n.purchaseVoidBody,
      action: l10n.purchaseVoidAction,
    );
    if (reason == null || !context.mounted) return;
    PurchaseVoidError? error;
    try {
      error = await cubit.voidPurchase(reason);
      if (error case VoidStockShortage(:final items)) {
        if (!context.mounted || !await _confirmShortage(context, items)) {
          return;
        }
        error = await cubit.voidPurchase(reason, acknowledgeShortage: true);
      }
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
      showAppSnackBarOn(messenger, l10n.purchaseVoided);
    } else if (context.mounted) {
      final text = context.purchaseVoidError(error);
      if (text != null) {
        showAppSnackBarOn(messenger, text, tone: StatusTone.error);
      }
    }
  }

  /// Names each product the void takes below zero (FR-009a).
  Future<bool> _confirmShortage(
    BuildContext context,
    List<VoidShortage> items,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showConfirmDialog(
      context,
      tone: StatusTone.warning,
      title: l10n.shortageTitle,
      message: [
        l10n.shortageBody,
        for (final s in items)
          l10n.voidShortageLine(
            s.name,
            context.quantity(s.stockAfterMilli, s.unit),
          ),
      ].join('\n'),
      confirmLabel: l10n.voidShortageConfirm,
      cancelLabel: l10n.backAction,
      destructive: true,
    );
    return ok ?? false;
  }
}
