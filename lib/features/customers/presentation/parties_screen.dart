import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/section_placeholder.dart';

/// Customers & Suppliers.
class PartiesScreen extends StatelessWidget {
  const PartiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionPlaceholder(
      icon: Icons.people_outline,
      title: l10n.placeholderPartiesTitle,
      body: l10n.placeholderPartiesBody,
    );
  }
}
