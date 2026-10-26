import 'dart:io';
import 'dart:math';

import 'package:daftar_afandi/core/utils/app_locale_code.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('piastersPerPound is 100', () {
    expect(piastersPerPound, 100);
  });

  group('roundHalfUpDiv', () {
    test('positives', () {
      expect(roundHalfUpDiv(4, 3), 1);
      expect(roundHalfUpDiv(5, 3), 2);
      expect(roundHalfUpDiv(1, 3), 0);
      expect(roundHalfUpDiv(0, 7), 0);
    });

    test('exact halves round away from zero', () {
      expect(roundHalfUpDiv(5, 2), 3);
      expect(roundHalfUpDiv(7, 2), 4);
      expect(roundHalfUpDiv(1, 2), 1);
      expect(roundHalfUpDiv(-5, 2), -3);
      expect(roundHalfUpDiv(-1, 2), -1);
    });

    test('negatives', () {
      expect(roundHalfUpDiv(-4, 3), -1);
      expect(roundHalfUpDiv(-5, 3), -2);
      expect(roundHalfUpDiv(-1, 3), 0);
    });

    test('denominator 1', () {
      expect(roundHalfUpDiv(10, 1), 10);
      expect(roundHalfUpDiv(-10, 1), -10);
    });

    test('large values near 1e18', () {
      expect(roundHalfUpDiv(999999999999999999, 2), 500000000000000000);
      expect(roundHalfUpDiv(4500000000000000000, 1000000000000000000), 5);
      expect(roundHalfUpDiv(1499999999999999999, 1000000000000000000), 1);
      expect(roundHalfUpDiv(-4500000000000000000, 1000000000000000000), -5);
    });

    test('rejects a denominator <= 0', () {
      expect(() => roundHalfUpDiv(1, 0), throwsArgumentError);
      expect(() => roundHalfUpDiv(1, -2), throwsArgumentError);
    });
  });

  group('lineTotalPiasters', () {
    test('quantity times price, rounded', () {
      expect(lineTotalPiasters(1500, 1000), 1500); // 1.5 × 10.00
      expect(lineTotalPiasters(1000, 999), 999);
      expect(lineTotalPiasters(333, 100), 33); // 0.333 × 1.00 = 0.333
      expect(lineTotalPiasters(500, 1), 1); // 0.5 piaster → 1
      expect(lineTotalPiasters(-500, 1), -1);
      expect(lineTotalPiasters(0, 12345), 0);
    });
  });

  group('allocateLargestRemainder', () {
    test('ties go to the lower index', () {
      expect(allocateLargestRemainder(100, [1, 1, 1]), [34, 33, 33]);
      expect(allocateLargestRemainder(1, [1, 1]), [1, 0]);
      expect(allocateLargestRemainder(2, [1, 1, 1]), [1, 1, 0]);
    });

    test('leftover goes to the largest remainder', () {
      expect(allocateLargestRemainder(10, [1, 2]), [3, 7]);
    });

    test('even split', () {
      expect(allocateLargestRemainder(100, [1, 1, 1, 1]), [25, 25, 25, 25]);
    });

    test('zero weights get nothing', () {
      expect(allocateLargestRemainder(10, [0, 5, 5]), [0, 5, 5]);
      expect(allocateLargestRemainder(7, [0, 1]), [0, 7]);
    });

    test('a single line takes the whole total', () {
      expect(allocateLargestRemainder(123, [9]), [123]);
    });

    test('total 0', () {
      expect(allocateLargestRemainder(0, [3, 4]), [0, 0]);
      expect(allocateLargestRemainder(0, [0, 0]), [0, 0]);
    });

    test('negative total mirrors the positive split', () {
      expect(allocateLargestRemainder(-100, [1, 1, 1]), [-34, -33, -33]);
    });

    test('rejects negative or all-zero weights', () {
      expect(() => allocateLargestRemainder(10, [1, -1]), throwsArgumentError);
      expect(() => allocateLargestRemainder(10, [0, 0]), throwsArgumentError);
    });

    test(
      'property: parts sum to total and stay within 1 of the exact share',
      () {
        final random = Random(20261019);
        for (var run = 0; run < 1000; run++) {
          final length = 1 + random.nextInt(10);
          final weights = [
            for (var i = 0; i < length; i++) random.nextInt(10001),
          ];
          if (weights.every((w) => w == 0)) weights[0] = 1;
          final total = random.nextInt(2000001) - 1000000;
          final weightSum = weights.reduce((a, b) => a + b);

          final parts = allocateLargestRemainder(total, weights);

          expect(parts.length, length);
          expect(
            parts.reduce((a, b) => a + b),
            total,
            reason: 'total=$total weights=$weights',
          );
          for (var i = 0; i < length; i++) {
            // |part − total·w/Σw| < 1, kept in integers.
            final error = (parts[i] * weightSum - total * weights[i]).abs();
            expect(
              error < weightSum,
              isTrue,
              reason: 'i=$i total=$total weights=$weights parts=$parts',
            );
          }
        }
      },
    );
  });

  group('weightedAverageCost', () {
    test('blends with existing stock', () {
      expect(
        weightedAverageCost(
          stockMilli: 2000,
          avgCostPiasters: 1000,
          inQtyMilli: 1000,
          inTotalCostPiasters: 1600,
        ),
        1200,
      );
    });

    test('rounds .5 up', () {
      expect(
        weightedAverageCost(
          stockMilli: 1000,
          avgCostPiasters: 100,
          inQtyMilli: 1000,
          inTotalCostPiasters: 101,
        ),
        101, // 100.5
      );
    });

    test('S = 0 uses the incoming unit cost', () {
      expect(
        weightedAverageCost(
          stockMilli: 0,
          avgCostPiasters: 999,
          inQtyMilli: 3000,
          inTotalCostPiasters: 1000,
        ),
        333,
      );
    });

    test('S < 0: the incoming cost wins', () {
      expect(
        weightedAverageCost(
          stockMilli: -500,
          avgCostPiasters: 50,
          inQtyMilli: 2000,
          inTotalCostPiasters: 1001,
        ),
        501, // 500.5
      );
    });

    test('rejects an incoming quantity <= 0', () {
      expect(
        () => weightedAverageCost(
          stockMilli: 1000,
          avgCostPiasters: 100,
          inQtyMilli: 0,
          inTotalCostPiasters: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('tryParsePiasters', () {
    test('Latin digits', () {
      expect(tryParsePiasters('12'), 1200);
      expect(tryParsePiasters('12.5'), 1250);
      expect(tryParsePiasters('12.50'), 1250);
      expect(tryParsePiasters('0.05'), 5);
      expect(tryParsePiasters('0'), 0);
    });

    test('Arabic-Indic and Persian digits', () {
      expect(tryParsePiasters('١٢٫٥٠'), 1250);
      expect(tryParsePiasters('١٢.٥'), 1250);
      expect(tryParsePiasters('۱۲.۵'), 1250);
      expect(tryParsePiasters('۱۲٫۵۰'), 1250);
    });

    test('grouping separators in threes', () {
      expect(tryParsePiasters('1,234.50'), 123450);
      expect(tryParsePiasters('١٬٢٣٤٫٥٠'), 123450);
      expect(tryParsePiasters('1,234,567'), 123456700);
      expect(tryParsePiasters('1,23'), isNull);
      expect(tryParsePiasters('12,34.5'), isNull);
      expect(tryParsePiasters(',123'), isNull);
    });

    test('too many decimals', () {
      expect(tryParsePiasters('12.345'), isNull);
    });

    test('empty, whitespace and junk', () {
      expect(tryParsePiasters(''), isNull);
      expect(tryParsePiasters('   '), isNull);
      expect(tryParsePiasters('  7 '), 700);
      expect(tryParsePiasters('abc'), isNull);
      expect(tryParsePiasters('1 234'), isNull);
      expect(tryParsePiasters('1.'), isNull);
      expect(tryParsePiasters('.5'), isNull);
      expect(tryParsePiasters('1.2.3'), isNull);
    });

    test('negative handling', () {
      expect(tryParsePiasters('-5'), isNull);
      expect(tryParsePiasters('-5', allowNegative: true), -500);
      expect(tryParsePiasters('-١٫٥', allowNegative: true), -150);
      expect(tryParsePiasters('--5', allowNegative: true), isNull);
      expect(tryParsePiasters('5-', allowNegative: true), isNull);
    });

    test('rejects more than 15 integer digits', () {
      expect(tryParsePiasters('999999999999999.99'), 99999999999999999);
      expect(tryParsePiasters('1000000000000000'), isNull);
    });
  });

  group('formatPiasters', () {
    test('Arabic with Arabic-Indic digits', () {
      expect(
        formatPiasters(
          123450,
          locale: AppLocaleCode.ar,
          digits: DigitStyle.arabicIndic,
        ),
        '١٬٢٣٤٫٥٠\u00A0ج.م',
      );
    });

    test('English with Latin digits', () {
      expect(
        formatPiasters(
          123450,
          locale: AppLocaleCode.en,
          digits: DigitStyle.latin,
        ),
        'EGP\u00A01,234.50',
      );
    });

    test('digit style is independent of the language', () {
      expect(
        formatPiasters(
          123450,
          locale: AppLocaleCode.ar,
          digits: DigitStyle.latin,
        ),
        '1,234.50\u00A0ج.م',
      );
      expect(
        formatPiasters(
          123450,
          locale: AppLocaleCode.en,
          digits: DigitStyle.arabicIndic,
        ),
        'EGP\u00A0١٬٢٣٤٫٥٠',
      );
    });

    test('always two decimals, grouping and sign', () {
      String en(int p) => formatPiasters(
        p,
        locale: AppLocaleCode.en,
        digits: DigitStyle.latin,
        withCurrency: false,
      );
      expect(en(0), '0.00');
      expect(en(5), '0.05');
      expect(en(100), '1.00');
      expect(en(100000000), '1,000,000.00');
      expect(en(-123450), '-1,234.50');
    });

    test('withCurrency: false gives the number only', () {
      expect(
        formatPiasters(
          123450,
          locale: AppLocaleCode.ar,
          digits: DigitStyle.arabicIndic,
          withCurrency: false,
        ),
        '١٬٢٣٤٫٥٠',
      );
    });
  });

  group('round-trips', () {
    const values = [0, 1, 5, 99, 100, 1250, 123450, 100000000, -1, -123450];

    test('parse(format(v)) == v in both digit styles', () {
      for (final style in DigitStyle.values) {
        for (final v in values) {
          final text = formatPiasters(
            v,
            locale: AppLocaleCode.ar,
            digits: style,
            withCurrency: false,
          );
          expect(
            tryParsePiasters(text, allowNegative: true),
            v,
            reason: '$style $text',
          );
        }
      }
    });

    test('format(parse(x)) == x for canonical input', () {
      for (final x in ['0.00', '0.05', '12.50', '1,234.50', '1,000,000.00']) {
        expect(
          formatPiasters(
            tryParsePiasters(x)!,
            locale: AppLocaleCode.en,
            digits: DigitStyle.latin,
            withCurrency: false,
          ),
          x,
        );
      }
    });
  });

  test('money and quantity code never uses double (constitution III)', () {
    for (final path in [
      'lib/core/utils/money.dart',
      'lib/core/utils/quantity.dart',
      'lib/core/utils/decimal_text.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(RegExp(r'\bdouble\b').hasMatch(source), isFalse, reason: path);
      expect(source.contains('toDouble'), isFalse, reason: path);
    }
  });

  test('a sign stays with the number, and the currency after both', () {
    expect(
      formatPiasters(
        6000,
        locale: AppLocaleCode.ar,
        digits: DigitStyle.arabicIndic,
        sign: '+',
      ),
      '\u2066+٦٠٫٠٠\u2069\u00A0ج.م',
    );
    expect(
      formatPiasters(
        2500,
        locale: AppLocaleCode.en,
        digits: DigitStyle.latin,
        sign: '−',
      ),
      'EGP\u00A0\u2066−25.00\u2069',
    );
  });
}
