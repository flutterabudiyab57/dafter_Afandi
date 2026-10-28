import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/report_period.dart';
import '../cubits/report_period_cubit.dart';

/// The report period chips and the chosen days (FR-001).
class PeriodBar extends StatelessWidget {
  const PeriodBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final period = context.watch<ReportPeriodCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: tokens.spaceSm,
      children: [
        Wrap(
          spacing: tokens.spaceSm,
          runSpacing: tokens.spaceXs,
          children: [
            for (final kind in ReportPeriodKind.values)
              ChoiceChip(
                label: Text(_label(l10n, kind)),
                selected: period.kind == kind,
                onSelected: (_) => kind == ReportPeriodKind.custom
                    ? _pickRange(context, period)
                    : context.read<ReportPeriodCubit>().choose(kind),
              ),
          ],
        ),
        Text(
          period.from == period.to
              ? context.date(period.from)
              : l10n.reportPeriodRange(
                  context.date(period.from),
                  context.date(period.to),
                ),
        ),
      ],
    );
  }

  static String _label(AppLocalizations l10n, ReportPeriodKind kind) =>
      switch (kind) {
        ReportPeriodKind.today => l10n.reportPeriodToday,
        ReportPeriodKind.yesterday => l10n.reportPeriodYesterday,
        ReportPeriodKind.thisWeek => l10n.reportPeriodThisWeek,
        ReportPeriodKind.thisMonth => l10n.reportPeriodThisMonth,
        ReportPeriodKind.lastMonth => l10n.reportPeriodLastMonth,
        ReportPeriodKind.custom => l10n.reportPeriodCustom,
      };

  Future<void> _pickRange(BuildContext context, ReportPeriod shown) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ReportPeriodCubit>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // As on the purchase date: Egyptian Arabic for Arabic-Indic digits.
    final arabicIndic =
        DigitStyleScope.of(context) == DigitStyle.arabicIndic &&
        Localizations.localeOf(context).languageCode == 'ar';
    final picked = await showDateRangePicker(
      context: context,
      locale: arabicIndic ? const Locale('ar', 'EG') : null,
      initialDateRange: DateTimeRange(
        start: shown.from.isAfter(today) ? today : shown.from,
        end: shown.to.isAfter(today) ? today : shown.to,
      ),
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked == null || !context.mounted) return;
    final refused = cubit.chooseRange(picked.start, picked.end);
    if (refused != null) {
      showAppSnackBar(context, switch (refused) {
        PeriodInvalid.endBeforeStart => l10n.reportPeriodEndBeforeStart,
        PeriodInvalid.inFuture => l10n.reportPeriodInFuture,
      }, tone: StatusTone.error);
    }
  }
}
