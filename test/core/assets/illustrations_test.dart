import 'dart:io';

import 'package:daftar_afandi/core/widgets/app_illustration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('every illustration ships in light and dark at 1x, 2x and 3x', () {
    final missing = <String>[];
    for (final kind in AppIllustration.values) {
      for (final brightness in Brightness.values) {
        final path = kind.assetPath(brightness);
        final slash = path.lastIndexOf('/');
        final dir = path.substring(0, slash);
        final file = path.substring(slash + 1);
        for (final p in [path, '$dir/2.0x/$file', '$dir/3.0x/$file']) {
          if (!File(p).existsSync()) missing.add(p);
        }
      }
    }
    expect(missing, isEmpty);
    expect(AppIllustration.values, hasLength(19));
  });
}
