import 'package:daftar_afandi/core/widgets/skeleton_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'widget_harness.dart';

void main() {
  Finder rows() => find.descendant(
    of: find.byType(SkeletonList),
    matching: find.byType(Container),
  );

  testVariants('nothing for 300 ms, then the rows', (tester, l10n) async {
    final handle = tester.ensureSemantics();
    await pumpInApp(tester, l10n, const SkeletonList(rows: 3));
    await tester.pump(const Duration(milliseconds: 299));
    expect(rows(), findsNothing);
    await tester.pump(const Duration(milliseconds: 2));
    expect(rows(), findsNWidgets(3));
    expect(
      find.descendant(
        of: find.byType(SkeletonList),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
    handle.dispose();
    // Removing it before or after the delay leaves no timer running.
    await pumpInApp(tester, l10n, const SizedBox());
  });

  testVariants('no animation runs when animations are off', (
    tester,
    l10n,
  ) async {
    await pumpInApp(
      tester,
      l10n,
      const SkeletonList(),
      disableAnimations: true,
    );
    await tester.pump(const Duration(milliseconds: 301));
    expect(rows(), findsNWidgets(4));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
