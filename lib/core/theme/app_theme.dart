import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

ThemeData appLightTheme({double scale = 1}) => _theme(lightScheme, scale);

ThemeData appDarkTheme({double scale = 1}) => _theme(darkScheme, scale);

/// Buttons are at least 48 px tall: the touch target (handoff 3.3).
const Size _buttonMinimumSize = Size(64, 48);

ThemeData _theme(ColorScheme scheme, double scale) {
  RoundedRectangleBorder rounded(double radius) => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius * scale),
  );
  OutlineInputBorder inputBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md * scale),
        borderSide: BorderSide(color: color, width: width),
      );
  final buttonLabel = AppTypography.textTheme.labelLarge!.copyWith(
    fontWeight: AppFontWeights.semiBold,
  );
  final buttonStyle = ButtonStyle(
    shape: const WidgetStatePropertyAll(StadiumBorder()),
    minimumSize: const WidgetStatePropertyAll(_buttonMinimumSize),
    textStyle: WidgetStatePropertyAll(buttonLabel),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: kFontFamily,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    filledButtonTheme: FilledButtonThemeData(style: buttonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: buttonStyle),
    textButtonTheme: TextButtonThemeData(style: buttonStyle),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      errorMaxLines: 3,
      border: inputBorder(scheme.outline, 1),
      enabledBorder: inputBorder(scheme.outline, 1),
      focusedBorder: inputBorder(scheme.primary, 2),
      errorBorder: inputBorder(scheme.error, 2),
      focusedErrorBorder: inputBorder(scheme.error, 2),
      disabledBorder: inputBorder(scheme.outlineVariant, 1),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      actionTextColor: scheme.inversePrimary,
      shape: rounded(AppRadii.sm),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: rounded(AppRadii.xl),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTypography.textTheme.labelMedium!.copyWith(
          fontWeight: states.contains(WidgetState.selected)
              ? AppFontWeights.bold
              : AppFontWeights.medium,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: rounded(AppRadii.sm),
      selectedColor: scheme.secondaryContainer,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      shape: rounded(AppRadii.lg),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg * scale),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      scrolledUnderElevation: 0,
      backgroundColor: scheme.surface,
    ),
    extensions: [
      AppTokens.scaled(scale),
      scheme.brightness == Brightness.dark ? AppColors.dark : AppColors.light,
    ],
  );
}
