import 'package:daftar_afandi/core/theme/app_theme.dart';
import 'package:daftar_afandi/core/theme/app_tokens.dart';
import 'package:daftar_afandi/core/theme/app_typography.dart';
import 'package:daftar_afandi/core/theme/font_license.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light and dark schemes derive from the 0xFF326CE9 seed', () {
    const seed = Color(0xFF326CE9);
    final light = appLightTheme().colorScheme;
    final dark = appDarkTheme().colorScheme;
    expect(light, ColorScheme.fromSeed(seedColor: seed));
    expect(
      dark,
      ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    );
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
  });

  test('both themes carry AppTokens and the bundled font', () {
    for (final theme in [appLightTheme(), appDarkTheme()]) {
      final tokens = theme.extension<AppTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.spaceMd, 16);
      expect(tokens.maxContentWidth, 600);
      expect(theme.textTheme.bodyLarge!.fontFamily, kFontFamily);
      expect(theme.textTheme.titleLarge!.fontFamily, 'IBMPlexSansArabic');
    }
  });

  test('only the bundled weights 400-700 are used', () {
    final allowed = {
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    };
    final t = AppTypography.textTheme;
    final styles = [
      t.displayLarge, t.displayMedium, t.displaySmall, //
      t.headlineLarge, t.headlineMedium, t.headlineSmall,
      t.titleLarge, t.titleMedium, t.titleSmall,
      t.bodyLarge, t.bodyMedium, t.bodySmall,
      t.labelLarge, t.labelMedium, t.labelSmall,
    ];
    for (final style in styles) {
      expect(allowed, contains(style!.fontWeight));
    }
  });

  test('tokens scale spacing but never the content width', () {
    final scaled = AppTokens.scaled(1.2);
    expect(scaled.spaceMd, closeTo(19.2, 1e-9));
    expect(scaled.maxContentWidth, 600);
    expect(AppTokens.scaled().lerp(scaled, 0.5).spaceMd, closeTo(17.6, 1e-9));
  });

  test('the OFL license is registered for IBM Plex Sans Arabic', () async {
    registerFontLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    final plex = entries.where(
      (e) => e.packages.contains('IBM Plex Sans Arabic'),
    );
    expect(plex, isNotEmpty);
    final text = plex.first.paragraphs.map((p) => p.text).join('\n');
    expect(text, contains('Open Font License'));
  });
}
