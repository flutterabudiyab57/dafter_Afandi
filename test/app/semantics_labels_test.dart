import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/screens.dart';

/// Every node a screen reader can tap, with what it would say.
List<SemanticsNode> _tappable(WidgetTester tester) {
  final out = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    final data = node.getSemanticsData();
    // A node merged into its parent is spoken as part of the parent.
    if (data.hasAction(SemanticsAction.tap) &&
        !node.isInvisible &&
        !node.isMergedIntoParent) {
      out.add(node);
    }
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.first.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return out;
}

void main() {
  for (final locale in AppLocale.values) {
    testWidgets('${locale.name}: every tappable widget has a spoken label '
        '(FR-020)', (tester) async {
      final semantics = tester.ensureSemantics();
      var screens = 0;
      var checked = 0;
      await visitEveryScreen(
        tester,
        locale: locale,
        check: (screen) async {
          screens++;
          for (final node in _tappable(tester)) {
            checked++;
            final data = node.getSemanticsData();
            final spoken = '${data.label}${data.tooltip}${data.value}';
            expect(
              spoken.trim(),
              isNotEmpty,
              reason: '$screen: ${node.toStringDeep()}',
            );
          }
        },
      );
      // 006 adds the 5 expense pages, void dialog, stock and 3 report views.
      expect(screens, 74);
      expect(checked, greaterThan(30), reason: 'the walk found the buttons');
      semantics.dispose();
    });

    testWidgets('${locale.name}: the logo has a label', (tester) async {
      final semantics = tester.ensureSemantics();
      final label = locale == AppLocale.ar
          ? 'شعار دفتر أفندي'
          : 'Daftar Afandi logo';
      await visitEveryScreen(
        tester,
        locale: locale,
        check: (screen) async {
          if (screen == '/welcome') {
            expect(find.bySemanticsLabel(label), findsOneWidget);
          }
          if (screen == 'StartingApp') {
            // The starting app is Arabic only.
            expect(find.bySemanticsLabel('شعار دفتر أفندي'), findsOneWidget);
          }
        },
      );
      semantics.dispose();
    });
  }
}
