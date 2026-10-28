import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/expense.dart';
import 'expense_text.dart';

/// One expense in a list: number, category, amount, day, method and the
/// voided mark (US3-3). Opens the expense.
class ExpenseRow extends StatelessWidget {
  const ExpenseRow({required this.expense, super.key});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final e = expense;
    final title = '${context.expenseNumber(e.number)} · ${e.category.name}';
    return ListTile(
      title: Text(title),
      // The amount wraps with the rest, not as the trailing, so a large
      // amount fits at any text size.
      subtitle: Wrap(
        spacing: context.tokens.spaceSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.money(e.amountPiasters),
            style: theme.textTheme.titleSmall?.copyWith(
              decoration: e.isVoided ? TextDecoration.lineThrough : null,
            ),
          ),
          Text(context.date(e.spentOn)),
          Text(context.methodLabel(e.method)),
          if (e.isVoided)
            StatusBadge(label: l10n.saleVoidedBadge, tone: BadgeTone.voided),
        ],
      ),
      onTap: () => context.push(RoutePaths.expense(e.id)),
    );
  }
}
