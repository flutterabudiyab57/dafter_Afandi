import 'package:daftar_afandi/core/widgets/status_badge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  testVariants('every tone shows its word; neutral has no icon', (
    tester,
    l10n,
  ) async {
    await pumpInApp(
      tester,
      l10n,
      SingleChildScrollView(
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final tone in BadgeTone.values)
                StatusBadge(
                  label: '${tone.name} ${l10n.markLowStock}',
                  tone: tone,
                ),
            ],
          ),
        ),
      ),
    );
    for (final tone in BadgeTone.values) {
      expect(find.text('${tone.name} ${l10n.markLowStock}'), findsOneWidget);
    }
    expect(find.byType(Icon), findsNWidgets(BadgeTone.values.length - 1));
  });

  testVariants('a long label wraps instead of being cut', (tester, l10n) async {
    await pumpInApp(
      tester,
      l10n,
      Center(
        child: SizedBox(
          width: 120,
          child: StatusBadge(label: l10n.markBelowZero, tone: BadgeTone.error),
        ),
      ),
    );
    final text = tester.widget<Text>(find.text(l10n.markBelowZero));
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(text.maxLines, isNull);
  });
}
