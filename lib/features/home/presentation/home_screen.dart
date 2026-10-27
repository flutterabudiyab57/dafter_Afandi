import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_tokens.dart';
import '../../products/presentation/widgets/low_stock_card.dart';
import 'widgets/today_cards.dart';

/// Home: today's numbers (006 US1), the low-stock warning and card (002
/// FR-001a), and the Products and Categories shortcuts (002 FR-001).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return SingleChildScrollView(
      padding: tokens.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LowStockBanner(),
          const TodayCards(),
          SizedBox(height: tokens.spaceLg),
          FilledButton.icon(
            icon: const Icon(Icons.inventory_2_outlined),
            label: Text(l10n.homeProductsAction),
            onPressed: () => context.push(RoutePaths.products),
          ),
          SizedBox(height: tokens.spaceSm),
          OutlinedButton.icon(
            icon: const Icon(Icons.category_outlined),
            label: Text(l10n.homeCategoriesAction),
            onPressed: () => context.push(RoutePaths.categories),
          ),
          SizedBox(height: tokens.spaceLg),
          const LowStockCard(),
        ],
      ),
    );
  }
}
