import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import 'app_illustration.dart';

/// A centered illustration, title, message and optional action. Never
/// inside a card; scrolls when the text is large.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.illustration,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  final AppIllustration illustration;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    // Room under the content for a floating button, so it never covers
    // the action at large text sizes.
    final fab = Scaffold.maybeOf(context)?.hasFloatingActionButton ?? false;
    final padding = tokens.pagePadding.copyWith(
      bottom: fab ? tokens.spaceXl * 3 : null,
    );
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          // Centered vertically while it fits.
          constraints: BoxConstraints(
            minHeight: constraints.hasBoundedHeight
                ? (constraints.maxHeight - padding.vertical).clamp(
                    0,
                    double.infinity,
                  )
                : 0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: tokens.emptyStateWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Illustration(illustration),
                  SizedBox(height: tokens.spaceLg),
                  Text(
                    title,
                    style: textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (message != null) ...[
                    SizedBox(height: tokens.spaceSm),
                    Text(
                      message!,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (action != null) ...[
                    SizedBox(height: tokens.spaceLg),
                    action!,
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
