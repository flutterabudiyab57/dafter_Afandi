import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';

/// The Customers | Suppliers switch at the top of both Parties lists (004
/// research R15). Each list keeps its own route; switching uses `go`.
class PartiesSwitch extends StatelessWidget {
  const PartiesSwitch({required this.suppliers, super.key});

  /// Whether the suppliers list is the one shown.
  final bool suppliers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: false,
          icon: const Icon(Icons.people_outline),
          label: Text(l10n.partiesCustomersTab),
        ),
        ButtonSegment(
          value: true,
          icon: const Icon(Icons.local_shipping_outlined),
          label: Text(l10n.partiesSuppliersTab),
        ),
      ],
      selected: {suppliers},
      onSelectionChanged: (s) {
        if (s.single != suppliers) {
          context.go(s.single ? RoutePaths.suppliers : RoutePaths.parties);
        }
      },
    );
  }
}
