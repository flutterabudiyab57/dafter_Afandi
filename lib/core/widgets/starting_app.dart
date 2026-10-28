import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'blocking_app_shell.dart';

/// Shown while the database opens (research R12). The chosen language is
/// not known yet, so it is in Arabic like the other blocking apps.
class StartingApp extends StatelessWidget {
  const StartingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlockingAppShell(
      builder: (context, l10n) {
        final tokens = context.tokens;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: tokens.pagePadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: tokens.emptyStateWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: l10n.logoSemantics,
                        image: true,
                        child: ExcludeSemantics(
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                tokens.radiusLg,
                              ),
                              child: Image.asset(
                                'assets/images/afandi.jpg',
                                height: tokens.logoHeight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: tokens.spaceXl),
                      const LinearProgressIndicator(),
                      SizedBox(height: tokens.spaceMd),
                      Text(
                        l10n.openingDataLabel,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
