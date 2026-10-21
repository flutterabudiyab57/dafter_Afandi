import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/section_placeholder.dart';

/// The Purchases section root: New purchase. The purchase list replaces
/// the placeholder in Phase 6.
class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        // Section roots stay alive in the shell; a shared default tag
        // would clash during page transitions.
        heroTag: null,
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.purchasesNewAction),
        onPressed: () => context.push(RoutePaths.purchasesNew),
      ),
      body: SectionPlaceholder(
        icon: Icons.shopping_cart_outlined,
        title: l10n.placeholderPurchasesTitle,
        body: l10n.placeholderPurchasesBody,
      ),
    );
  }
}
