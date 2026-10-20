import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';

/// Temporary Home; Phase 8 puts it in the navigation shell as a placeholder.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.placeholderHomeTitle)),
      body: SingleChildScrollView(
        padding: context.tokens.pagePadding,
        child: Text(l10n.placeholderHomeBody),
      ),
    );
  }
}
