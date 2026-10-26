import 'dart:io';
import 'dart:ui' as ui;

import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/screens.dart';
import 'capture.dart';

/// Renders every screen with the app's real fonts, for the user guide and
/// for looking over the app. Off by default:
///
///     flutter test test/screenshots --dart-define=SCREENSHOTS=true
///
/// Writes `build/screenshots/<variant>/NN-<screen>.png` and contact sheets
/// of eight screens each in `build/screenshots/<variant>/sheets/`.
const bool _enabled = bool.fromEnvironment('SCREENSHOTS');

String _slug(String screen) => screen
    .replaceAll(RegExp('^/'), '')
    .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')
    .replaceAll(RegExp(r'-$'), '');

void main() {
  setUpAll(loadAppFonts);

  for (final (variant, locale, textScale, brightness) in [
    ('ar', AppLocale.ar, 1.0, Brightness.light),
    ('ar-dark', AppLocale.ar, 1.0, Brightness.dark),
    ('ar-200', AppLocale.ar, 2.0, Brightness.light),
    ('en', AppLocale.en, 1.0, Brightness.light),
  ]) {
    testWidgets('screenshots $variant', skip: !_enabled, (tester) async {
      debugDisableShadows = false;
      final dir = 'build/screenshots/$variant';
      final old = Directory(dir);
      if (old.existsSync()) old.deleteSync(recursive: true);
      final shots = <(String, ui.Image)>[];
      await visitEveryScreen(
        tester,
        locale: locale,
        size: kPhone,
        devicePixelRatio: kRatio,
        textScale: textScale,
        brightness: brightness,
        check: (screen) async {
          await settleImages(tester);
          final image = await captureScreen(tester);
          final n = (shots.length + 1).toString().padLeft(2, '0');
          final name = '$n-${_slug(screen)}';
          shots.add((name, image));
          await writePng(tester, image, '$dir/$name.png');
        },
      );
      for (var i = 0; i < shots.length; i += 8) {
        final sheet = await contactSheet(
          tester,
          shots.sublist(i, (i + 8).clamp(0, shots.length)),
        );
        final n = (i ~/ 8 + 1).toString().padLeft(2, '0');
        await writePng(tester, sheet, '$dir/sheets/sheet-$n.png');
      }
      debugDisableShadows = true;
    });
  }
}
