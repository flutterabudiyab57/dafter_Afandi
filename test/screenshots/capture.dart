import 'dart:io';
import 'dart:ui' as ui;

import 'package:daftar_afandi/core/theme/app_typography.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Capturing the app as PNGs with its real fonts, for the screenshot and
/// user-guide tests.

/// A phone the size of a common Android one.
const Size kPhone = Size(392, 820);
const double kRatio = 2.5;

Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load(kFontFamily, [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'assets/fonts/IBMPlexSansArabic-$w.ttf',
  ]);
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  await load('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

/// Decodes every image on screen; the test clock does not run decoders.
Future<void> settleImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final e in find.byType(Image).evaluate()) {
      await precacheImage((e.widget as Image).image, e);
    }
  });
  await tester.pump();
}

Future<ui.Image> captureScreen(WidgetTester tester) async {
  final view = tester.binding.renderViews.first;
  // The root layer is in physical pixels already.
  final layer = view.debugLayer! as OffsetLayer;
  return (await tester.runAsync(
    () => layer.toImage(Offset.zero & (view.size * kRatio)),
  ))!;
}

Future<void> writePng(WidgetTester tester, ui.Image image, String path) =>
    tester
        .runAsync(() async {
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File(path)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data!.buffer.asUint8List());
        })
        .then((_) {});

/// Eight shots side by side, each at a third of its size, with its name.
Future<ui.Image> contactSheet(
  WidgetTester tester,
  List<(String, ui.Image)> shots,
) async => (await tester.runAsync(() async {
  const cols = 4;
  const scale = 1 / 3;
  final w = shots.first.$2.width * scale;
  final h = shots.first.$2.height * scale;
  const label = 28.0;
  final rows = (shots.length / cols).ceil();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)
    ..drawRect(
      Rect.fromLTWH(0, 0, w * cols, (h + label) * rows),
      Paint()..color = const Color(0xFFFFFFFF),
    );
  for (var i = 0; i < shots.length; i++) {
    final (name, image) = shots[i];
    final dx = (i % cols) * w;
    final dy = (i ~/ cols) * (h + label);
    final para =
        (ui.ParagraphBuilder(
                ui.ParagraphStyle(fontSize: 18, fontFamily: kFontFamily),
              )
              ..pushStyle(ui.TextStyle(color: const Color(0xFF000000)))
              ..addText(name))
            .build()
          ..layout(ui.ParagraphConstraints(width: w));
    canvas
      ..drawParagraph(para, Offset(dx + 4, dy + 2))
      ..drawImageRect(
        image,
        Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(dx, dy + label, w, h),
        Paint()..filterQuality = FilterQuality.medium,
      )
      ..drawRect(
        Rect.fromLTWH(dx, dy + label, w, h),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xFF888888),
      );
  }
  return recorder.endRecording().toImage(
    (w * cols).ceil(),
    ((h + label) * rows).ceil(),
  );
}))!;
