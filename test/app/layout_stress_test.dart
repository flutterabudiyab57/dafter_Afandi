import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/screens.dart';

/// Every screen at a small phone and a tablet, 200% text, both themes and
/// both languages, with no overflow (SC-002, FR-016, FR-019).
void main() {
  const sizes = [Size(375, 812), Size(800, 1280)];
  for (final size in sizes) {
    for (final brightness in Brightness.values) {
      for (final locale in AppLocale.values) {
        final name =
            '${size.width.toInt()}x${size.height.toInt()}, '
            '${brightness.name}, ${locale.name}';
        testWidgets('no overflow at 200% text ($name)', (tester) async {
          var screens = 0;
          await visitEveryScreen(
            tester,
            locale: locale,
            size: size,
            textScale: 2,
            brightness: brightness,
            check: (screen) async {
              screens++;
              expect(tester.takeException(), isNull, reason: screen);
            },
          );
          expect(screens, 15);
        });
      }
    }
  }
}
