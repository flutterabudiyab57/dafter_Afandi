import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/widgets/section_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionPlaceholder(
      icon: Icons.home_outlined,
      title: l10n.placeholderHomeTitle,
      body: l10n.placeholderHomeBody,
    );
  }
}
