import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/widgets/unsaved_changes_guard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  const formKey = Key('form');

  /// A home page that opens a guarded form; returns once the form is up.
  Future<void> openForm(
    WidgetTester tester,
    AppLocalizations l10n, {
    required bool dirty,
  }) async {
    await pumpInApp(
      tester,
      l10n,
      Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UnsavedChangesGuard(
                  dirty: dirty,
                  child: const Scaffold(key: formKey, body: SizedBox.expand()),
                ),
              ),
            ),
            child: Text(l10n.chooseAction),
          ),
        ),
      ),
    );
    await tester.tap(find.text(l10n.chooseAction));
    await tester.pumpAndSettle();
    expect(find.byKey(formKey), findsOneWidget);
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  testVariants('leaves at once when clean', (tester, l10n) async {
    await openForm(tester, l10n, dirty: false);
    await back(tester);
    expect(find.byKey(formKey), findsNothing);
    expect(find.text(l10n.discardChangesTitle), findsNothing);
  });

  testVariants('asks when dirty; keep editing stays, discard leaves', (
    tester,
    l10n,
  ) async {
    await openForm(tester, l10n, dirty: true);
    await back(tester);
    expect(find.text(l10n.discardChangesTitle), findsOneWidget);
    await tester.tap(find.text(l10n.keepEditingAction));
    await tester.pumpAndSettle();
    expect(find.byKey(formKey), findsOneWidget);

    await back(tester);
    await tester.tap(find.text(l10n.discardAction));
    await tester.pumpAndSettle();
    expect(find.byKey(formKey), findsNothing);
  });
}
