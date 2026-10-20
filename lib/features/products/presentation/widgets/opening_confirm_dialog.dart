import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/quantity.dart';
import '../../domain/product_draft.dart';
import 'unit_label.dart';

/// Asks the owner to confirm the opening stock: quantity × cost = total
/// (clarification Q1, research R13). True when confirmed; Back or a tap
/// outside returns false.
Future<bool> confirmOpeningStock(
  BuildContext context,
  OpeningStock opening,
  UnitType unit,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.openingConfirmTitle),
      content: SingleChildScrollView(
        child: Text(
          l10n.openingConfirmBody(
            context.quantity(opening.qtyMilli, unit),
            context.money(opening.unitCostPiasters),
            context.money(opening.totalPiasters),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.backAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.confirmAction),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
