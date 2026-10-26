import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/widgets/confirm_dialog.dart';
import 'package:daftar_afandi/core/widgets/status_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  Future<Future<bool?>> open(WidgetTester tester, AppLocalizations l10n) async {
    await pumpInApp(tester, l10n, const SizedBox.expand());
    final result = showConfirmDialog(
      tester.element(find.byType(SizedBox).last),
      tone: StatusTone.warning,
      title: l10n.discardChangesTitle,
      message: l10n.discardChangesBody,
      confirmLabel: l10n.discardAction,
      cancelLabel: l10n.keepEditingAction,
      destructive: true,
    );
    await tester.pumpAndSettle();
    return result;
  }

  testVariants('the destructive button is last, in error colors', (
    tester,
    l10n,
  ) async {
    await open(tester, l10n);
    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(dialog.actions!.last, isA<FilledButton>());
    expect(dialog.actions!.first, isA<TextButton>());
    final context = tester.element(find.byType(AlertDialog));
    final style = (dialog.actions!.last as FilledButton).style!;
    expect(
      style.backgroundColor!.resolve({}),
      Theme.of(context).colorScheme.error,
    );
    expect(find.byIcon(Icons.warning), findsOneWidget);
  });

  testVariants('returns true, false or null', (tester, l10n) async {
    var result = await open(tester, l10n);
    await tester.tap(find.text(l10n.discardAction));
    await tester.pumpAndSettle();
    expect(await result, isTrue);

    result = await open(tester, l10n);
    await tester.tap(find.text(l10n.keepEditingAction));
    await tester.pumpAndSettle();
    expect(await result, isFalse);

    result = await open(tester, l10n);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
