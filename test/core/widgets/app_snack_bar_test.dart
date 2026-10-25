import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/widgets/app_snack_bar.dart';
import 'package:daftar_afandi/core/widgets/status_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  Future<BuildContext> open(WidgetTester tester, AppLocalizations l10n) async {
    await pumpInApp(tester, l10n, const SizedBox.expand());
    return tester.element(find.byType(SizedBox).last);
  }

  testVariants('a second message replaces the first', (tester, l10n) async {
    final context = await open(tester, l10n);
    showAppSnackBar(context, l10n.discardChangesTitle);
    await tester.pumpAndSettle();
    showAppSnackBar(context, l10n.openingDataLabel, tone: StatusTone.warning);
    await tester.pumpAndSettle();
    expect(find.text(l10n.discardChangesTitle), findsNothing);
    expect(find.text(l10n.openingDataLabel), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testVariants('stays 4 s, or 10 s with an action', (tester, l10n) async {
    final context = await open(tester, l10n);
    showAppSnackBar(context, l10n.discardChangesTitle);
    await tester.pump();
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).duration,
      const Duration(seconds: 4),
    );
    var undone = false;
    showAppSnackBar(
      context,
      l10n.discardChangesTitle,
      actionLabel: l10n.undoAction,
      onAction: () => undone = true,
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).duration,
      const Duration(seconds: 10),
    );
    await tester.tap(find.text(l10n.undoAction));
    expect(undone, isTrue);
  });
}
