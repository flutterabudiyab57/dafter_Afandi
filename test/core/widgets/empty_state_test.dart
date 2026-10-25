import 'package:daftar_afandi/core/widgets/app_illustration.dart';
import 'package:daftar_afandi/core/widgets/empty_state.dart';
import 'package:daftar_afandi/core/widgets/load_failed_view.dart';
import 'package:daftar_afandi/core/widgets/result_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  testVariants('EmptyState shows its parts and scrolls when large', (
    tester,
    l10n,
  ) async {
    var added = false;
    await pumpInApp(
      tester,
      l10n,
      EmptyState(
        illustration: AppIllustration.emptyCustomers,
        title: l10n.customersEmptyTitle,
        message: l10n.customersEmptyBody,
        action: FilledButton(
          onPressed: () => added = true,
          child: Text(l10n.chooseAction),
        ),
      ),
    );
    expect(find.byType(Illustration), findsOneWidget);
    expect(find.text(l10n.customersEmptyTitle), findsOneWidget);
    expect(find.text(l10n.customersEmptyBody), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.chooseAction));
    await tester.tap(find.text(l10n.chooseAction));
    expect(added, isTrue);
  });

  testVariants('LoadFailedView retries', (tester, l10n) async {
    var retried = 0;
    await pumpInApp(
      tester,
      l10n,
      LoadFailedView(
        title: l10n.searchEmptyTitle,
        message: l10n.discardChangesBody,
        retryLabel: l10n.retryAction,
        onRetry: () => retried++,
      ),
    );
    final illustration = tester.widget<Illustration>(find.byType(Illustration));
    expect(illustration.kind, AppIllustration.errorGeneric);
    await tester.ensureVisible(find.text(l10n.retryAction));
    await tester.tap(find.widgetWithText(OutlinedButton, l10n.retryAction));
    expect(retried, 1);
  });

  testVariants('ResultView fills the screen, buttons optional', (
    tester,
    l10n,
  ) async {
    await pumpInApp(
      tester,
      l10n,
      ResultView(
        illustration: AppIllustration.errorDatabase,
        title: l10n.discardChangesTitle,
        message: l10n.discardChangesBody,
      ),
    );
    expect(find.text(l10n.discardChangesTitle), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    await pumpInApp(
      tester,
      l10n,
      ResultView(
        illustration: AppIllustration.errorDatabase,
        title: l10n.discardChangesTitle,
        message: l10n.discardChangesBody,
        primary: FilledButton(onPressed: () {}, child: Text(l10n.retryAction)),
        secondary: TextButton(onPressed: () {}, child: Text(l10n.undoAction)),
      ),
    );
    await tester.ensureVisible(find.text(l10n.undoAction));
    expect(find.text(l10n.retryAction), findsOneWidget);
    expect(find.text(l10n.undoAction), findsOneWidget);
  });
}
