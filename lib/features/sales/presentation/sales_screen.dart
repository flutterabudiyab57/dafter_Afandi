import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/section_placeholder.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionPlaceholder(
      icon: Icons.point_of_sale_outlined,
      title: l10n.placeholderSalesTitle,
      body: l10n.placeholderSalesBody,
    );
  }
}
