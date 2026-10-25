import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import 'app_radii.dart';
import 'app_spacing.dart';

/// Every size a screen may use, read with `context.tokens` (research R7).
@immutable
final class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusXl,
    required this.maxContentWidth,
    required this.logoHeight,
    required this.illustrationWidth,
    required this.emptyStateWidth,
  });

  /// Design values times [scale] (see `designScale()`).
  factory AppTokens.scaled([double scale = 1]) => AppTokens(
    spaceXs: AppSpacing.xs * scale,
    spaceSm: AppSpacing.sm * scale,
    spaceMd: AppSpacing.md * scale,
    spaceLg: AppSpacing.lg * scale,
    spaceXl: AppSpacing.xl * scale,
    radiusSm: AppRadii.sm * scale,
    radiusMd: AppRadii.md * scale,
    radiusLg: AppRadii.lg * scale,
    radiusXl: AppRadii.xl * scale,
    maxContentWidth: kMaxContentWidth,
    logoHeight: AppSpacing.logo * scale,
    illustrationWidth: AppSpacing.illustration * scale,
    emptyStateWidth: AppSpacing.emptyState * scale,
  );

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double maxContentWidth;
  final double logoHeight;
  final double illustrationWidth;
  final double emptyStateWidth;

  /// Padding around a screen's scrollable content.
  EdgeInsets get pagePadding => EdgeInsets.all(spaceLg);

  /// Padding of a small header above a group of list rows.
  EdgeInsetsDirectional get sectionHeaderPadding =>
      EdgeInsetsDirectional.only(start: spaceMd, end: spaceMd, top: spaceSm);

  @override
  AppTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? maxContentWidth,
    double? logoHeight,
    double? illustrationWidth,
    double? emptyStateWidth,
  }) => AppTokens(
    spaceXs: spaceXs ?? this.spaceXs,
    spaceSm: spaceSm ?? this.spaceSm,
    spaceMd: spaceMd ?? this.spaceMd,
    spaceLg: spaceLg ?? this.spaceLg,
    spaceXl: spaceXl ?? this.spaceXl,
    radiusSm: radiusSm ?? this.radiusSm,
    radiusMd: radiusMd ?? this.radiusMd,
    radiusLg: radiusLg ?? this.radiusLg,
    radiusXl: radiusXl ?? this.radiusXl,
    maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    logoHeight: logoHeight ?? this.logoHeight,
    illustrationWidth: illustrationWidth ?? this.illustrationWidth,
    emptyStateWidth: emptyStateWidth ?? this.emptyStateWidth,
  );

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    double l(double a, double b) => lerpDouble(a, b, t)!;
    return AppTokens(
      spaceXs: l(spaceXs, other.spaceXs),
      spaceSm: l(spaceSm, other.spaceSm),
      spaceMd: l(spaceMd, other.spaceMd),
      spaceLg: l(spaceLg, other.spaceLg),
      spaceXl: l(spaceXl, other.spaceXl),
      radiusSm: l(radiusSm, other.radiusSm),
      radiusMd: l(radiusMd, other.radiusMd),
      radiusLg: l(radiusLg, other.radiusLg),
      radiusXl: l(radiusXl, other.radiusXl),
      maxContentWidth: l(maxContentWidth, other.maxContentWidth),
      logoHeight: l(logoHeight, other.logoHeight),
      illustrationWidth: l(illustrationWidth, other.illustrationWidth),
      emptyStateWidth: l(emptyStateWidth, other.emptyStateWidth),
    );
  }
}

extension AppTokensContext on BuildContext {
  /// The tokens of the current theme (unscaled if the theme has none).
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.scaled();
}
