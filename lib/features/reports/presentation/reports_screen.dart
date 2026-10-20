import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/section_placeholder.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionPlaceholder(
      icon: Icons.bar_chart_outlined,
      title: l10n.placeholderReportsTitle,
      body: l10n.placeholderReportsBody,
    );
  }
}
