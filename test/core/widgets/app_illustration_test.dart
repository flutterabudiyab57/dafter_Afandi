import 'package:daftar_afandi/core/theme/app_theme.dart';
import 'package:daftar_afandi/core/widgets/app_illustration.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, ThemeData theme, Widget child) =>
      tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: Center(child: child)),
        ),
      );

  String assetOf(WidgetTester tester) =>
      (tester.widget<Image>(find.byType(Image)).image as AssetImage).assetName;

  test('assetPath maps camelCase names to snake_case files', () {
    expect(
      AppIllustration.emptyProducts.assetPath(Brightness.light),
      'assets/illustrations/light/empty_products.png',
    );
    expect(
      AppIllustration.warningLowStock.assetPath(Brightness.dark),
      'assets/illustrations/dark/warning_low_stock.png',
    );
  });

  testWidgets('follows the theme brightness', (tester) async {
    await pump(
      tester,
      appLightTheme(),
      const Illustration(AppIllustration.welcome),
    );
    expect(assetOf(tester), 'assets/illustrations/light/welcome.png');
    await pump(
      tester,
      appDarkTheme(),
      const Illustration(AppIllustration.welcome),
    );
    await tester.pumpAndSettle(); // the theme change animates
    expect(assetOf(tester), 'assets/illustrations/dark/welcome.png');
  });

  testWidgets('is the token width, 240:200, and hidden from screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      appLightTheme(),
      const Illustration(AppIllustration.infoTip),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.excludeFromSemantics, isTrue);
    expect(image.width, 192);
    expect(image.height, 160);
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });

  testWidgets('a missing file leaves an empty box of the same size', (
    tester,
  ) async {
    await pump(
      tester,
      appLightTheme(),
      DefaultAssetBundle(
        bundle: _MissingBundle(),
        child: const Illustration(AppIllustration.welcome, width: 120),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final box = find.descendant(
      of: find.byType(Image),
      matching: find.byType(SizedBox),
    );
    expect(box, findsOneWidget);
    expect(tester.getSize(box), const Size(120, 100));
  });
}

/// Every file is missing.
class _MissingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) =>
      Future.error(FlutterError('missing $key'));
}
