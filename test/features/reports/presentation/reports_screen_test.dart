import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/widgets/status_badge.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/reports/domain/profit_summary.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_reports.dart';
import '../../../helpers/pump_app.dart';

/// US2-2: sales 10,000, cost 7,000, damage 200, expenses 1,500.
const _month = ProfitSummary(
  salesPiasters: 1000000,
  returnsPiasters: 0,
  saleCostPiasters: 700000,
  returnedCostPiasters: 0,
  inventoryLossesByReason: {AdjustmentKind.damage: 20000},
  expensesPiasters: 150000,
  salesCount: 40,
  linesWithoutCost: 0,
  hasAdjustments: true,
);

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    String digits(String latin) => locale == AppLocale.ar
        ? latin
              .replaceAllMapped(
                RegExp('[0-9]'),
                (m) => String.fromCharCode(0x0660 + int.parse(m[0]!)),
              )
              .replaceAll('.', '٫')
              .replaceAll(',', '٬')
        : latin;

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeReportsStore reports;

        setUp(() => reports = FakeReportsStore());

        Future<void> open(
          WidgetTester tester, {
          void Function()? onHome,
        }) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (locale == AppLocale.en) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            textScale: textScale,
            reports: FakeReportsCubits(reports),
          );
          // Home loads first; this runs before Reports opens.
          onHome?.call();
          await goTo(tester, RoutePaths.reports);
          expect(tester.takeException(), isNull);
        }

        Finder amount(String latin) => find.textContaining(digits(latin));

        testWidgets('every profit line, with the loss reason (US2-1, 2)', (
          tester,
        ) async {
          reports.profit = _month;
          await open(tester);
          expect(find.text(l10n.profitNetSales), findsOneWidget);
          expect(amount('10,000.00'), findsOneWidget);
          expect(amount('7,000.00'), findsOneWidget);
          expect(amount('3,000.00'), findsOneWidget);
          expect(find.text(l10n.profitInventoryLosses), findsOneWidget);
          expect(find.text(l10n.reasonDamage), findsOneWidget);
          expect(amount('200.00'), findsNWidgets(2));
          expect(amount('1,500.00'), findsOneWidget);
          expect(find.text(l10n.profitNet), findsOneWidget);
          expect(amount('1,300.00'), findsOneWidget);
          expect(find.text(l10n.profitEmpty), findsNothing);
        });

        testWidgets('a quiet period says so (US2-5)', (tester) async {
          await open(tester);
          expect(find.text(l10n.profitEmpty), findsOneWidget);
        });

        testWidgets('costs above sales show a marked loss (US2-6)', (
          tester,
        ) async {
          reports.profit = const ProfitSummary(
            salesPiasters: 5000,
            returnsPiasters: 0,
            saleCostPiasters: 4000,
            returnedCostPiasters: 0,
            inventoryLossesByReason: {},
            expensesPiasters: 3000,
            salesCount: 1,
            linesWithoutCost: 1,
          );
          await open(tester);
          expect(find.text(l10n.profitNetLoss), findsOneWidget);
          expect(find.text(l10n.profitNet), findsNothing);
          final badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
          expect(badge.tone, BadgeTone.error);
          expect(badge.label, contains(digits('20.00')));
          await tester.ensureVisible(find.text(l10n.profitNoCostNote));
          expect(find.text(l10n.profitNoCostNote), findsOneWidget);
        });

        testWidgets('count gains above losses read as a net gain (FR-012)', (
          tester,
        ) async {
          reports.profit = const ProfitSummary(
            salesPiasters: 0,
            returnsPiasters: 0,
            saleCostPiasters: 0,
            returnedCostPiasters: 0,
            inventoryLossesByReason: {
              AdjustmentKind.damage: 7000,
              AdjustmentKind.count: -21000,
            },
            expensesPiasters: 0,
            salesCount: 0,
            linesWithoutCost: 0,
            hasAdjustments: true,
          );
          await open(tester);
          expect(find.text(l10n.profitInventoryNetGain), findsOneWidget);
          expect(amount('+210.00'), findsOneWidget);
        });

        testWidgets('picking a period reloads the report for it', (
          tester,
        ) async {
          await open(tester);
          expect(reports.profitPeriods.last.kind, ReportPeriodKind.thisMonth);
          await tester.tap(find.text(l10n.reportPeriodToday));
          await tester.pumpAndSettle();
          expect(reports.profitPeriods.last.kind, ReportPeriodKind.today);
          final chip = tester.widget<ChoiceChip>(
            find.ancestor(
              of: find.text(l10n.reportPeriodToday),
              matching: find.byType(ChoiceChip),
            ),
          );
          expect(chip.selected, isTrue);
        });

        testWidgets('a failed load offers Retry, which loads', (tester) async {
          reports.profit = _month;
          await open(
            tester,
            onHome: () => reports.failNextWatch = StateError('db'),
          );
          expect(find.text(l10n.profitNetSales), findsNothing);
          await tester.ensureVisible(find.text(l10n.retryAction));
          await tester.tap(find.text(l10n.retryAction));
          await tester.pumpAndSettle();
          expect(find.text(l10n.profitNetSales), findsOneWidget);
        });
      });
    }
  }
}
