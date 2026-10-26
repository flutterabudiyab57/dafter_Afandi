import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/sale.dart';

/// One invoice in a list: number, time, customer, total and its mark
/// (FR-009). Opens the invoice.
class SaleRow extends StatelessWidget {
  const SaleRow({required this.sale, super.key});

  final SaleSummary sale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mark = sale.voided
        ? l10n.saleVoidedBadge
        : switch (sale.kind) {
            SaleKind.cash => null,
            SaleKind.partial => l10n.saleKindPartial,
            SaleKind.credit => l10n.saleKindCredit,
          };
    final title =
        '${context.saleNumber(sale.number)} · '
        '${sale.customerName ?? l10n.walkInCustomer}';
    return ListTile(
      title: Text(title),
      subtitle: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(context.dateTime(sale.at)),
          if (mark != null)
            StatusBadge(
              label: mark,
              tone: sale.voided ? BadgeTone.voided : BadgeTone.owes,
            ),
        ],
      ),
      trailing: Text(
        context.money(sale.totalPiasters),
        style: theme.textTheme.titleSmall?.copyWith(
          decoration: sale.voided ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: () => context.push(RoutePaths.saleInvoice(sale.id)),
    );
  }
}
