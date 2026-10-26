import 'package:daftar_afandi/core/widgets/status_banner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  const icons = {
    StatusTone.success: Icons.check_circle,
    StatusTone.warning: Icons.warning,
    StatusTone.error: Icons.error,
    StatusTone.info: Icons.info,
    StatusTone.voided: Icons.block,
  };

  testVariants('each tone shows its icon, title, message and action', (
    tester,
    l10n,
  ) async {
    for (final tone in StatusTone.values) {
      var tapped = false;
      await pumpInApp(
        tester,
        l10n,
        Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: StatusBanner(
            tone: tone,
            title: l10n.creditNeedsCustomerTitle,
            message: l10n.discardChangesBody,
            actionLabel: l10n.chooseAction,
            onAction: () => tapped = true,
          ),
        ),
      );
      expect(find.byIcon(icons[tone]!), findsOneWidget);
      expect(find.text(l10n.creditNeedsCustomerTitle), findsOneWidget);
      expect(find.text(l10n.discardChangesBody), findsOneWidget);
      await tester.tap(find.text(l10n.chooseAction));
      expect(tapped, isTrue);
    }
  });

  testVariants('is a live region', (tester, l10n) async {
    final handle = tester.ensureSemantics();
    await pumpInApp(
      tester,
      l10n,
      StatusBanner(tone: StatusTone.info, title: l10n.searchEmptyTitle),
    );
    expect(
      tester.getSemantics(find.byType(StatusBanner)),
      isSemantics(isLiveRegion: true, label: l10n.searchEmptyTitle),
    );
    handle.dispose();
  });

  testVariants('error uses the scheme error container', (tester, l10n) async {
    await pumpInApp(
      tester,
      l10n,
      StatusBanner(tone: StatusTone.error, title: l10n.searchEmptyTitle),
    );
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(StatusBanner),
        matching: find.byType(DecoratedBox),
      ),
    );
    final context = tester.element(find.byType(StatusBanner));
    expect(
      (box.decoration as BoxDecoration).color,
      Theme.of(context).colorScheme.errorContainer,
    );
  });
}
