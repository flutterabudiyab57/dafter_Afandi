import 'package:daftar_afandi/core/widgets/save_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  testVariants('ignores taps while saving (SC-004)', (tester, l10n) async {
    var taps = 0;
    Future<void> pump({required bool saving}) => pumpInApp(
      tester,
      l10n,
      Center(
        child: SaveButton(
          label: l10n.saveAction,
          savingLabel: l10n.savingLabel,
          saving: saving,
          onPressed: () => taps++,
        ),
      ),
    );

    await pump(saving: false);
    await tester.tap(find.text(l10n.saveAction));
    expect(taps, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await pump(saving: true);
    expect(find.text(l10n.savingLabel), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(SaveButton), warnIfMissed: false);
    await tester.tap(find.byType(SaveButton), warnIfMissed: false);
    expect(taps, 1);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
}
