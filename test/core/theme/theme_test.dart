import 'package:daftar_afandi/core/theme/app_colors.dart';
import 'package:daftar_afandi/core/theme/app_theme.dart';
import 'package:daftar_afandi/core/theme/app_tokens.dart';
import 'package:daftar_afandi/core/theme/app_typography.dart';
import 'package:daftar_afandi/core/theme/font_license.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('light and dark themes use the brand schemes', () {
    final light = appLightTheme().colorScheme;
    final dark = appDarkTheme().colorScheme;
    expect(light, lightScheme);
    expect(dark, darkScheme);
    expect(light.primary, AppPalette.fez);
    expect(light.surface, AppPalette.paper);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
  });

  test('each theme carries the AppColors of its brightness', () {
    expect(appLightTheme().extension<AppColors>(), AppColors.light);
    expect(appDarkTheme().extension<AppColors>(), AppColors.dark);
    final mid = AppColors.light.lerp(AppColors.dark, 0.5);
    expect(mid.owes, Color.lerp(AppPalette.amber, AppPalette.nightAmber, 0.5));
    final copy = AppColors.light.copyWith(owes: AppPalette.fez);
    expect(copy.owes, AppPalette.fez);
    expect(copy.credit, AppColors.light.credit);
  });

  test('text colors reach WCAG AA (4.5:1) on their backgrounds', () {
    double contrast(Color a, Color b) {
      final la = a.computeLuminance();
      final lb = b.computeLuminance();
      final hi = la > lb ? la : lb;
      final lo = la > lb ? lb : la;
      return (hi + 0.05) / (lo + 0.05);
    }

    for (final (scheme, colors) in [
      (lightScheme, AppColors.light),
      (darkScheme, AppColors.dark),
    ]) {
      final pairs = <(Color, Color)>[
        (scheme.onSurface, scheme.surface),
        (scheme.onSurfaceVariant, scheme.surface),
        (scheme.onSurfaceVariant, scheme.surfaceContainerHigh),
        (scheme.primary, scheme.surface),
        (scheme.onPrimary, scheme.primary),
        (scheme.onPrimaryContainer, scheme.primaryContainer),
        (scheme.secondary, scheme.surface),
        (scheme.error, scheme.surface),
        (colors.owes, colors.owesContainer),
        (colors.owes, scheme.surface),
        (colors.credit, colors.creditContainer),
        (colors.credit, scheme.surface),
        (colors.voided, colors.voidedContainer),
        for (final (tone, onTone, container, onContainer) in [
          (
            colors.success,
            colors.onSuccess,
            colors.successContainer,
            colors.onSuccessContainer,
          ),
          (
            colors.warning,
            colors.onWarning,
            colors.warningContainer,
            colors.onWarningContainer,
          ),
          (
            colors.info,
            colors.onInfo,
            colors.infoContainer,
            colors.onInfoContainer,
          ),
        ]) ...[
          (onTone, tone),
          (onContainer, container),
          (tone, scheme.surface),
        ],
      ];
      for (final (fg, bg) in pairs) {
        expect(
          contrast(fg, bg),
          greaterThanOrEqualTo(4.5),
          reason: '$fg on $bg (${scheme.brightness})',
        );
      }
    }
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

  test('the feedback tones match the handoff palette', () {
    expect(AppColors.light.success, const Color(0xFF1E6A66));
    expect(AppColors.light.onWarningContainer, const Color(0xFF4A2700));
    expect(AppColors.light.info, const Color(0xFF35597A));
    expect(AppColors.dark.successContainer, const Color(0xFF0E3B38));
    expect(AppColors.dark.onWarning, const Color(0xFF452B00));
    expect(AppColors.dark.onInfoContainer, const Color(0xFFD6E6F5));
    final mid = AppColors.light.lerp(AppColors.dark, 0.5);
    expect(
      mid.info,
      Color.lerp(AppColors.light.info, AppColors.dark.info, 0.5),
    );
    final copy = AppColors.light.copyWith(warning: AppPalette.fez);
    expect(copy.warning, AppPalette.fez);
    expect(copy.success, AppColors.light.success);
  });

  test('component themes are set once in both themes', () {
    for (final theme in [appLightTheme(), appDarkTheme()]) {
      final scheme = theme.colorScheme;
      final tokens = theme.extension<AppTokens>()!;
      expect(theme.snackBarTheme.backgroundColor, scheme.inverseSurface);
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      final dialogShape = theme.dialogTheme.shape! as RoundedRectangleBorder;
      expect(dialogShape.borderRadius, BorderRadius.circular(tokens.radiusXl));
      final minSize = theme.filledButtonTheme.style!.minimumSize!.resolve({});
      expect(minSize!.height, 48);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.cardTheme.color, scheme.surfaceContainerLowest);
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.errorMaxLines, 3);
      expect(theme.appBarTheme.centerTitle, isFalse);
    }
  });

  test('the new tokens scale with the design factor', () {
    final base = AppTokens.scaled();
    expect(base.radiusXl, 28);
    expect(base.illustrationWidth, 192);
    final scaled = AppTokens.scaled(1.2);
    expect(scaled.radiusXl, closeTo(33.6, 1e-9));
    expect(scaled.illustrationWidth, closeTo(230.4, 1e-9));
    expect(base.lerp(scaled, 0.5).illustrationWidth, closeTo(211.2, 1e-9));
    final dialogShape =
        appLightTheme(scale: 1.2).dialogTheme.shape! as RoundedRectangleBorder;
    expect(dialogShape.borderRadius, BorderRadius.circular(scaled.radiusXl));
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
