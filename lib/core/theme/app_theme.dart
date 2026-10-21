import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

ThemeData appLightTheme({double scale = 1}) => _theme(lightScheme, scale);

ThemeData appDarkTheme({double scale = 1}) => _theme(darkScheme, scale);

ThemeData _theme(ColorScheme scheme, double scale) => ThemeData(
  useMaterial3: true,
  colorScheme: scheme,
  fontFamily: kFontFamily,
  textTheme: AppTypography.textTheme.apply(
    bodyColor: scheme.onSurface,
    displayColor: scheme.onSurface,
  ),
  extensions: [
    AppTokens.scaled(scale),
    scheme.brightness == Brightness.dark ? AppColors.dark : AppColors.light,
  ],
);
