import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeDigits', () {
    test('maps Arabic-Indic and Persian digits to Latin', () {
      expect(normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(normalizeDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
    });

    test('keeps every other character', () {
      expect(normalizeDigits('abc 12 ٣ ۴ ٫ ٬ +'), 'abc 12 3 4 ٫ ٬ +');
      expect(normalizeDigits(''), '');
    });
  });

  group('applyDigitStyle', () {
    test('Arabic-Indic maps digits and separators', () {
      expect(applyDigitStyle('1,234.50', DigitStyle.arabicIndic), '١٬٢٣٤٫٥٠');
      expect(applyDigitStyle('0123456789', DigitStyle.arabicIndic), '٠١٢٣٤٥٦٧٨٩');
    });

    test('Arabic-Indic keeps other characters', () {
      expect(applyDigitStyle('-7 x', DigitStyle.arabicIndic), '-٧ x');
    });

    test('Latin is unchanged', () {
      expect(applyDigitStyle('1,234.50', DigitStyle.latin), '1,234.50');
    });

    test('round-trips through normalizeDigits', () {
      expect(
        normalizeDigits(applyDigitStyle('9876543210', DigitStyle.arabicIndic)),
        '9876543210',
      );
    });
  });

  test('ltrIsolate wraps in U+2066 … U+2069', () {
    expect(ltrIsolate('+201001234567'), '\u2066+201001234567\u2069');
    expect(ltrIsolate(''), '\u2066\u2069');
  });
}
