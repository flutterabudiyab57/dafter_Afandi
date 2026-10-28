import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../payments/domain/payment_method.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../cubits/collected_cubit.dart';
import '../widgets/period_bar.dart';
import '../widgets/report_line.dart';

/// Money collected in the report period, one row per method and the total
/// (US5-1, US5-5, FR-013).
class CollectedScreen extends StatelessWidget {
  const CollectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final cubit = context.read<CollectedCubit>();
    final state = context.watch<CollectedCubit>().state;
    final summary = state.summary;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportCollectedTitle)),
      body: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: tokens.spaceSm,
          children: [
            const PeriodBar(),
            ?listLoadState(
              context,
              loadFailed: state.loadFailed,
              loading: summary == null,
              empty: true,
              onRetry: cubit.retry,
            ),
            if (summary != null && !state.loadFailed) ...[
              if (summary.byMethod.isEmpty) Text(l10n.reportCollectedEmpty),
              for (final m in offeredPaymentMethods)
                if (summary.of(m) != 0)
                  ReportLine(
                    context.methodLabel(m),
                    context.money(summary.of(m)),
                  ),
              const Divider(),
              Text(
                l10n.reportCollectedTotal(context.money(summary.totalPiasters)),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
