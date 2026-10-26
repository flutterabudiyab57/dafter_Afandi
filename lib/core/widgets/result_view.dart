import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'app_illustration.dart';

/// A full-screen outcome: startup error, update required. Both buttons are
/// optional; the blocking apps have none.
class ResultView extends StatelessWidget {
  const ResultView({
    required this.illustration,
    required this.title,
    required this.message,
    this.primary,
    this.secondary,
    super.key,
  });

  final AppIllustration illustration;
  final String title;
  final String message;
  final Widget? primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: SingleChildScrollView(
              padding: tokens.pagePadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Illustration(illustration)),
                  SizedBox(height: tokens.spaceLg),
                  Text(
                    title,
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Text(
                    message,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (primary != null) ...[
                    SizedBox(height: tokens.spaceXl),
                    primary!,
                  ],
                  if (secondary != null) ...[
                    SizedBox(height: tokens.spaceSm),
                    secondary!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
