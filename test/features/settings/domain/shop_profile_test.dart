import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/settings/domain/app_settings.dart';
import 'package:daftar_afandi/features/settings/domain/app_version.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:flutter_test/flutter_test.dart';

Result<ShopProfile, ShopProfileError> _create(
  String name, [
  String phone = '',
]) => ShopProfile.create(name, phone);

void main() {
  group('name', () {
    test('empty and spaces-only are required errors', () {
      expect(
        _create(''),
        const Err<ShopProfile, ShopProfileError>(ShopProfileError.nameRequired),
      );
      expect(
        _create('   \t '),
        const Err<ShopProfile, ShopProfileError>(ShopProfileError.nameRequired),
      );
    });

    test('is trimmed and otherwise kept exactly as typed', () {
      expect(
        _create('  محل 23  '),
        const Ok<ShopProfile, ShopProfileError>(ShopProfile(name: 'محل 23')),
      );
    });

    test('60 code points pass, 61 fail (after trim)', () {
      final sixty = 'م' * 60;
      expect(
        _create(' $sixty '),
        Ok<ShopProfile, ShopProfileError>(ShopProfile(name: sixty)),
      );
      expect(
        _create('${sixty}x'),
        const Err<ShopProfile, ShopProfileError>(ShopProfileError.nameTooLong),
      );
    });

    test('an emoji counts as one code point', () {
      final name = '${'a' * 59}😀';
      expect(ShopProfile.validateName(name), isNull);
      expect(
        ShopProfile.validateName('${name}b'),
        ShopProfileError.nameTooLong,
      );
    });
  });

  group('phone', () {
    test('empty → no phone', () {
      expect(
        _create('Shop', '  '),
        const Ok<ShopProfile, ShopProfileError>(ShopProfile(name: 'Shop')),
      );
    });

    test('Arabic-Indic digits with spaces and dashes are normalized', () {
      expect(
        _create('Shop', '٠١٠ ١٢٣٤-٥٦٧٨'),
        const Ok<ShopProfile, ShopProfileError>(
          ShopProfile(name: 'Shop', phone: '01012345678'),
        ),
      );
      expect(
        _create('Shop', '+٢٠١٠١٢٣٤٥٦٧٨'),
        const Ok<ShopProfile, ShopProfileError>(
          ShopProfile(name: 'Shop', phone: '+201012345678'),
        ),
      );
    });

    test('every phone error', () {
      expect(
        _create('Shop', '010-abc'),
        const Err<ShopProfile, ShopProfileError>(
          ShopProfileError.phoneInvalidCharacters,
        ),
      );
      expect(
        _create('Shop', '123456'),
        const Err<ShopProfile, ShopProfileError>(
          ShopProfileError.phoneTooShort,
        ),
      );
      expect(
        _create('Shop', '1' * 16),
        const Err<ShopProfile, ShopProfileError>(ShopProfileError.phoneTooLong),
      );
      expect(ShopProfile.validatePhone('1234567'), isNull);
      expect(ShopProfile.validatePhone('1' * 15), isNull);
    });

    test('a name error wins over a phone error', () {
      expect(
        _create('', 'x'),
        const Err<ShopProfile, ShopProfileError>(ShopProfileError.nameRequired),
      );
    });
  });

  group('AppSettings.effectiveDigitStyle', () {
    AppSettings settings(AppLocale l, DigitStylePreference d) =>
        AppSettings(locale: l, digitStyle: d, onboardingCompleted: false);

    test('follow resolves per language', () {
      expect(
        settings(
          AppLocale.ar,
          DigitStylePreference.followLanguage,
        ).effectiveDigitStyle,
        DigitStyle.arabicIndic,
      );
      expect(
        settings(
          AppLocale.en,
          DigitStylePreference.followLanguage,
        ).effectiveDigitStyle,
        DigitStyle.latin,
      );
    });

    test('an explicit choice ignores the language', () {
      for (final l in AppLocale.values) {
        expect(
          settings(l, DigitStylePreference.latin).effectiveDigitStyle,
          DigitStyle.latin,
        );
        expect(
          settings(l, DigitStylePreference.arabicIndic).effectiveDigitStyle,
          DigitStyle.arabicIndic,
        );
      }
    });
  });

  test('AppVersion.display is Latin name (build)', () {
    expect(const AppVersion(name: '1.0.0', build: '1').display, '1.0.0 (1)');
  });
}
