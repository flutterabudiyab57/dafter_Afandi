import 'package:material_ui/material_ui.dart';

/// Brand palette from the logo: fez red, brass gold and ledger paper.
/// Screens never read these directly; they use the [ColorScheme] or
/// [AppColors] through the theme.
abstract final class AppPalette {
  static const Color fez = Color(0xFF9E2B25);
  static const Color fezSoft = Color(0xFFF7E4DF);
  static const Color fezDark = Color(0xFF7C1F1A);
  static const Color paper = Color(0xFFFAF6EE);
  static const Color card = Color(0xFFFFFFFF);
  static const Color sunk = Color(0xFFF2EBDF);
  static const Color ink = Color(0xFF24232A);
  static const Color ink2 = Color(0xFF5E5850);
  static const Color line = Color(0xFFE3D9C8);
  static const Color gold = Color(0xFFC8A464);
  static const Color goldInk = Color(0xFF7A5A26);
  static const Color amber = Color(0xFF8F4A00);
  static const Color amberSoft = Color(0xFFFCEBD7);
  static const Color teal = Color(0xFF1E6A66);
  static const Color tealSoft = Color(0xFFDDF0EE);
  static const Color graySoft = Color(0xFFECE8E1);

  static const Color nightPaper = Color(0xFF17161B);
  static const Color nightCard = Color(0xFF222128);
  static const Color nightInk = Color(0xFFEFE9DF);
  static const Color nightFez = Color(0xFFF0A49A);
  static const Color nightAmber = Color(0xFFF2B872);
  static const Color nightTeal = Color(0xFF7FCFC8);
}

const ColorScheme lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppPalette.fez,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: AppPalette.fezSoft,
  onPrimaryContainer: AppPalette.fezDark,
  secondary: AppPalette.goldInk,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF2E6CC),
  onSecondaryContainer: Color(0xFF3D2C0F),
  tertiary: AppPalette.teal,
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: AppPalette.tealSoft,
  onTertiaryContainer: Color(0xFF0B3A37),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: AppPalette.paper,
  onSurface: AppPalette.ink,
  onSurfaceVariant: AppPalette.ink2,
  surfaceDim: Color(0xFFE4DCCE),
  surfaceBright: AppPalette.paper,
  surfaceContainerLowest: AppPalette.card,
  surfaceContainerLow: AppPalette.card,
  surfaceContainer: Color(0xFFF7F1E7),
  surfaceContainerHigh: AppPalette.sunk,
  surfaceContainerHighest: Color(0xFFECE4D6),
  outline: Color(0xFF8A8174),
  outlineVariant: AppPalette.line,
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: AppPalette.ink,
  onInverseSurface: Color(0xFFF4EFE6),
  inversePrimary: AppPalette.nightFez,
  surfaceTint: AppPalette.fez,
);

const ColorScheme darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppPalette.nightFez,
  onPrimary: Color(0xFF561410),
  primaryContainer: Color(0xFF6E2420),
  onPrimaryContainer: Color(0xFFFFDAD4),
  secondary: Color(0xFFD9BE8A),
  onSecondary: Color(0xFF3D2C0F),
  secondaryContainer: Color(0xFF574119),
  onSecondaryContainer: Color(0xFFF6E3BE),
  tertiary: AppPalette.nightTeal,
  onTertiary: Color(0xFF003734),
  tertiaryContainer: Color(0xFF0E4F4B),
  onTertiaryContainer: Color(0xFFA6EFE8),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: AppPalette.nightPaper,
  onSurface: AppPalette.nightInk,
  onSurfaceVariant: Color(0xFFCFC6B8),
  surfaceDim: AppPalette.nightPaper,
  surfaceBright: Color(0xFF3B3940),
  surfaceContainerLowest: Color(0xFF111015),
  surfaceContainerLow: Color(0xFF1C1B20),
  surfaceContainer: AppPalette.nightCard,
  surfaceContainerHigh: Color(0xFF2B2A31),
  surfaceContainerHighest: Color(0xFF36343C),
  outline: Color(0xFF9A9184),
  outlineVariant: Color(0xFF3F3B36),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: AppPalette.nightInk,
  onInverseSurface: Color(0xFF2A2930),
  inversePrimary: AppPalette.fez,
  surfaceTint: AppPalette.nightFez,
);

/// Semantic colors beyond the [ColorScheme], read with `context.appColors`.
@immutable
final class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.owes,
    required this.owesContainer,
    required this.credit,
    required this.creditContainer,
    required this.voided,
    required this.voidedContainer,
    required this.ornament,
  });

  static const AppColors light = AppColors(
    owes: AppPalette.amber,
    owesContainer: AppPalette.amberSoft,
    credit: AppPalette.teal,
    creditContainer: AppPalette.tealSoft,
    voided: AppPalette.ink2,
    voidedContainer: AppPalette.graySoft,
    ornament: AppPalette.gold,
  );

  static const AppColors dark = AppColors(
    owes: AppPalette.nightAmber,
    owesContainer: Color(0xFF4A2A05),
    credit: AppPalette.nightTeal,
    creditContainer: Color(0xFF0E3B38),
    voided: Color(0xFFB9B2A8),
    voidedContainer: Color(0xFF2E2C33),
    ornament: Color(0xFFD4B47A),
  );

  /// Money owed or attention needed: "عليه", low stock, unpaid.
  final Color owes;
  final Color owesContainer;

  /// Money in the other party's favour, paid, or stock that is fine.
  final Color credit;
  final Color creditContainer;

  /// Voided invoices and archived records.
  final Color voided;
  final Color voidedContainer;

  /// Gold lines and small decoration only, never text.
  final Color ornament;

  @override
  AppColors copyWith({
    Color? owes,
    Color? owesContainer,
    Color? credit,
    Color? creditContainer,
    Color? voided,
    Color? voidedContainer,
    Color? ornament,
  }) => AppColors(
    owes: owes ?? this.owes,
    owesContainer: owesContainer ?? this.owesContainer,
    credit: credit ?? this.credit,
    creditContainer: creditContainer ?? this.creditContainer,
    voided: voided ?? this.voided,
    voidedContainer: voidedContainer ?? this.voidedContainer,
    ornament: ornament ?? this.ornament,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      owes: l(owes, other.owes),
      owesContainer: l(owesContainer, other.owesContainer),
      credit: l(credit, other.credit),
      creditContainer: l(creditContainer, other.creditContainer),
      voided: l(voided, other.voided),
      voidedContainer: l(voidedContainer, other.voidedContainer),
      ornament: l(ornament, other.ornament),
    );
  }
}

extension AppColorsContext on BuildContext {
  /// The semantic colors of the current theme (light if the theme has none).
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
