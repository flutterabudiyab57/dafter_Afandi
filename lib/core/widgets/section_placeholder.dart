import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'app_illustration.dart';

/// What a section will hold, shown until the feature arrives (FR-009).
/// No sample data.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({
    required this.icon,
    required this.title,
    required this.body,
    this.illustration,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Shown instead of [icon] when given.
  final AppIllustration? illustration;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: tokens.spaceXl),
          if (illustration case final kind?)
            Center(child: Illustration(kind))
          else
            ExcludeSemantics(
              child: Icon(
                icon,
                size: tokens.spaceXl * 2,
                color: theme.colorScheme.primary,
              ),
            ),
          SizedBox(height: tokens.spaceLg),
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: tokens.spaceSm),
          Text(
            body,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
