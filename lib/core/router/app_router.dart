import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';

/// Temporary single-route router. Phase 7 replaces it with the real routes
/// and redirects (contracts/routes-and-screens.md).
GoRouter createAppRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const _TemporaryHome()),
  ],
);

class _TemporaryHome extends StatelessWidget {
  const _TemporaryHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(AppLocalizations.of(context).appName)),
    );
  }
}
