import 'package:equatable/equatable.dart';

import '../../../core/utils/digits.dart';
import 'app_locale.dart';
import 'shop_profile.dart';

final class AppSettings extends Equatable {
  const AppSettings({
    required this.locale,
    required this.digitStyle,
    required this.onboardingCompleted,
    this.shop,
  });

  final AppLocale locale;
  final DigitStylePreference digitStyle;
  final ShopProfile? shop;
  final bool onboardingCompleted;

  /// `followLanguage`: Arabic-Indic in ar, Latin in en (research R9).
  DigitStyle get effectiveDigitStyle => switch (digitStyle) {
    DigitStylePreference.arabicIndic => DigitStyle.arabicIndic,
    DigitStylePreference.latin => DigitStyle.latin,
    DigitStylePreference.followLanguage => switch (locale) {
      AppLocale.ar => DigitStyle.arabicIndic,
      AppLocale.en => DigitStyle.latin,
    },
  };

  @override
  List<Object?> get props => [locale, digitStyle, shop, onboardingCompleted];
}
