import 'package:material_ui/material_ui.dart';

/// The brand seed until the final designs arrive (plan: theme and design).
const Color kSeedColor = Color(0xFF326CE9);

final ColorScheme lightScheme = ColorScheme.fromSeed(seedColor: kSeedColor);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: kSeedColor,
  brightness: Brightness.dark,
);

/// Semantic colors beyond the [ColorScheme]. None are needed yet; the final
/// designs add them here, not in screens.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors();

  @override
  AppColors copyWith() => const AppColors();

  @override
  AppColors lerp(AppColors? other, double t) => this;
}
