import 'package:daftar_afandi/core/utils/app_locale_code.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:flutter_test/flutter_test.dart';

String _fmt(int milli, UnitType unit, [DigitStyle digits = DigitStyle.latin]) =>
    formatQuantityMilli(milli, unit, locale: AppLocaleCode.en, digits: digits);

void main() {
  test('milliPerUnit is 1000', () {
    expect(milliPerUnit, 1000);
  });

  test('UnitType fraction rules', () {
    expect(UnitType.piece.allowsFraction, isFalse);
    expect(UnitType.piece.maxDecimals, 0);
    for (final unit in [UnitType.kg, UnitType.liter, UnitType.meter]) {
      expect(unit.allowsFraction, isTrue);
      expect(unit.maxDecimals, 3);
    }
  });

  group('tryParseQuantityMilli', () {
    test('piece takes whole numbers and rejects fractions', () {
      expect(tryParseQuantityMilli('2', UnitType.piece), 2000);
      expect(tryParseQuantityMilli('٢', UnitType.piece), 2000);
      expect(tryParseQuantityMilli('1,250', UnitType.piece), 1250000);
      expect(tryParseQuantityMilli('2.5', UnitType.piece), isNull);
      expect(tryParseQuantityMilli('2.0', UnitType.piece), isNull);
      expect(tryParseQuantityMilli('٢٫٥', UnitType.piece), isNull);
    });

    test('fractional units take up to 3 decimals', () {
      expect(tryParseQuantityMilli('1.5', UnitType.kg), 1500);
      expect(tryParseQuantityMilli('0.125', UnitType.liter), 125);
      expect(tryParseQuantityMilli('۰٫۲۵', UnitType.meter), 250);
      expect(tryParseQuantityMilli('0.1255', UnitType.kg), isNull);
    });

    test('empty, whitespace, junk and negatives', () {
      expect(tryParseQuantityMilli('', UnitType.kg), isNull);
      expect(tryParseQuantityMilli('  ', UnitType.kg), isNull);
      expect(tryParseQuantityMilli(' 3 ', UnitType.kg), 3000);
      expect(tryParseQuantityMilli('kg', UnitType.kg), isNull);
      expect(tryParseQuantityMilli('-1', UnitType.kg), isNull);
    });
  });

  group('formatQuantityMilli', () {
    test('drops trailing zeros', () {
      expect(_fmt(2000, UnitType.piece), '2');
      expect(_fmt(1000, UnitType.kg), '1');
      expect(_fmt(1500, UnitType.kg), '1.5');
      expect(_fmt(1100, UnitType.kg), '1.1');
      expect(_fmt(125, UnitType.liter), '0.125');
      expect(_fmt(0, UnitType.piece), '0');
    });

    test('grouping, sign and digit style', () {
      expect(_fmt(1250000, UnitType.piece), '1,250');
      expect(_fmt(-1500, UnitType.kg), '-1.5');
      expect(_fmt(1500, UnitType.kg, DigitStyle.arabicIndic), '١٫٥');
      expect(_fmt(1250000, UnitType.piece, DigitStyle.arabicIndic), '١٬٢٥٠');
    });
  });

  group('round-trips', () {
    test('parse(format(v)) == v', () {
      const cases = {
        UnitType.piece: [0, 1000, 2000, 1250000],
        UnitType.kg: [0, 1, 125, 1500, 1000, 1234567],
      };
      cases.forEach((unit, values) {
        for (final style in DigitStyle.values) {
          for (final v in values) {
            final text = _fmt(v, unit, style);
            expect(tryParseQuantityMilli(text, unit), v, reason: '$unit $text');
          }
        }
      });
    });

    test('format(parse(x)) == x for canonical input', () {
      for (final x in ['0', '1.5', '0.125', '1,234.567']) {
        expect(_fmt(tryParseQuantityMilli(x, UnitType.kg)!, UnitType.kg), x);
      }
    });
  });
}
