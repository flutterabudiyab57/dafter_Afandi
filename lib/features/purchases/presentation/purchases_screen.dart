import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/section_placeholder.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionPlaceholder(
      icon: Icons.shopping_cart_outlined,
      title: l10n.placeholderPurchasesTitle,
      body: l10n.placeholderPurchasesBody,
    );
  }
}
