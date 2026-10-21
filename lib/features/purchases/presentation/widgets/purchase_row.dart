import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../../suppliers/presentation/widgets/supplier_text.dart';
import '../../domain/purchase.dart';

/// One purchase in a list: number, invoice date, supplier, total and its
/// mark (FR-010).
class PurchaseRow extends StatelessWidget {
  const PurchaseRow({required this.purchase, this.onTap, super.key});

  final PurchaseSummary purchase;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = purchase;
    final mark = p.voided
        ? l10n.saleVoidedBadge
        : switch (p.kind) {
            PurchaseKind.cash => null,
            PurchaseKind.partial => l10n.saleKindPartial,
            PurchaseKind.credit => l10n.saleKindCredit,
          };
    final title =
        '${context.purchaseNumber(p.number)} · '
        '${p.supplierName ?? l10n.purchaseNoSupplier}';
    return ListTile(
      title: Text(title),
      subtitle: Wrap(
        spacing: context.tokens.spaceSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(context.date(p.invoiceDate)),
          if (p.supplierRef != null) Text(p.supplierRef!),
          if (mark != null)
            Text(
              mark,
              style: theme.textTheme.labelMedium?.copyWith(
                color: p.voided
                    ? context.appColors.voided
                    : context.appColors.owes,
              ),
            ),
        ],
      ),
      trailing: Text(
        context.money(p.totalPiasters),
        style: theme.textTheme.titleSmall?.copyWith(
          decoration: p.voided ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: onTap,
    );
  }
}
