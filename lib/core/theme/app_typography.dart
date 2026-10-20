import 'package:material_ui/material_ui.dart';

const String kFontFamily = 'IBMPlexSansArabic';

/// Bundled weights only (pubspec.yaml): 400, 500, 600, 700.
abstract final class AppFontWeights {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// Material 3 sizes in logical px. Never `.sp`: the system text scale is
/// applied once, by Flutter (FR-016, research R7).
abstract final class AppTypography {
  static TextStyle _style(double size, FontWeight weight, double height) =>
      TextStyle(
        fontFamily: kFontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
      );

  static final TextTheme textTheme = TextTheme(
    displayLarge: _style(57, AppFontWeights.regular, 1.12),
    displayMedium: _style(45, AppFontWeights.regular, 1.16),
    displaySmall: _style(36, AppFontWeights.regular, 1.22),
    headlineLarge: _style(32, AppFontWeights.semiBold, 1.25),
    headlineMedium: _style(28, AppFontWeights.semiBold, 1.29),
    headlineSmall: _style(24, AppFontWeights.semiBold, 1.33),
    titleLarge: _style(22, AppFontWeights.semiBold, 1.27),
    titleMedium: _style(16, AppFontWeights.medium, 1.5),
    titleSmall: _style(14, AppFontWeights.medium, 1.43),
    bodyLarge: _style(16, AppFontWeights.regular, 1.5),
    bodyMedium: _style(14, AppFontWeights.regular, 1.43),
    bodySmall: _style(12, AppFontWeights.regular, 1.33),
    labelLarge: _style(14, AppFontWeights.medium, 1.43),
    labelMedium: _style(12, AppFontWeights.medium, 1.33),
    labelSmall: _style(11, AppFontWeights.medium, 1.45),
  );
}
