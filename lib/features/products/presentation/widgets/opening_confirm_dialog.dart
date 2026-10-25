import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/status_banner.dart';
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
  final confirmed = await showConfirmDialog(
    context,
    tone: StatusTone.info,
    title: l10n.openingConfirmTitle,
    message: l10n.openingConfirmBody(
      context.quantity(opening.qtyMilli, unit),
      context.money(opening.unitCostPiasters),
      context.money(opening.totalPiasters),
    ),
    confirmLabel: l10n.confirmAction,
    cancelLabel: l10n.backAction,
  );
  return confirmed ?? false;
}
