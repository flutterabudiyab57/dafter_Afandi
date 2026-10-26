/// Money in integer piasters (constitution III). 1 EGP = 100 piasters.
library;

import 'app_locale_code.dart';
import 'decimal_text.dart';
import 'digits.dart';

const int piastersPerPound = 100;

/// `numerator / denominator` rounded to the nearest integer, halves away
/// from zero (2.5 → 3, -2.5 → -3). Throws when [denominator] is not positive.
int roundHalfUpDiv(int numerator, int denominator) {
  if (denominator <= 0) {
    throw ArgumentError.value(denominator, 'denominator', 'must be > 0');
  }
  final quotient = numerator ~/ denominator;
  final remainder = numerator.remainder(denominator).abs();
  // remainder >= denominator - remainder  ⇔  2·remainder >= denominator,
  // written this way so it cannot overflow.
  if (remainder >= denominator - remainder) {
    return numerator < 0 ? quotient - 1 : quotient + 1;
  }
  return quotient;
}

/// Total for a line: quantity in milli-units times the unit price, rounded
/// half away from zero to whole piasters.
int lineTotalPiasters(int qtyMilli, int unitPricePiasters) =>
    roundHalfUpDiv(qtyMilli * unitPricePiasters, 1000);

/// Splits [total] in proportion to [weights] (largest-remainder method).
///
/// The parts always sum to [total]. Leftover piasters go to the largest
/// remainders; ties go to the lower index. Weights must be non-negative,
/// and at least one must be positive unless [total] is 0.
List<int> allocateLargestRemainder(int total, List<int> weights) {
  if (weights.any((w) => w < 0)) {
    throw ArgumentError.value(weights, 'weights', 'must be non-negative');
  }
  final weightSum = weights.fold(0, (sum, w) => sum + w);
  if (weightSum == 0) {
    if (total == 0) return List.filled(weights.length, 0);
    throw ArgumentError.value(weights, 'weights', 'must not all be zero');
  }

  final sign = total < 0 ? -1 : 1;
  final magnitude = total.abs();
  final parts = <int>[];
  final remainders = <int>[];
  for (final w in weights) {
    final share = magnitude * w;
    parts.add(share ~/ weightSum);
    remainders.add(share % weightSum);
  }

  var leftover = magnitude - parts.fold(0, (sum, p) => sum + p);
  final order = List<int>.generate(weights.length, (i) => i)
    ..sort((a, b) {
      final byRemainder = remainders[b].compareTo(remainders[a]);
      return byRemainder != 0 ? byRemainder : a.compareTo(b);
    });
  for (final index in order) {
    if (leftover == 0) break;
    parts[index] += 1;
    leftover -= 1;
  }
  return [for (final p in parts) sign * p];
}

/// Weighted average unit cost after receiving [inQtyMilli] for
/// [inTotalCostPiasters].
///
/// When the current stock [stockMilli] is zero or negative, the incoming unit
/// cost replaces the old average.
int weightedAverageCost({
  required int stockMilli,
  required int avgCostPiasters,
  required int inQtyMilli,
  required int inTotalCostPiasters,
}) {
  if (inQtyMilli <= 0) {
    throw ArgumentError.value(inQtyMilli, 'inQtyMilli', 'must be > 0');
  }
  if (stockMilli <= 0) {
    return roundHalfUpDiv(inTotalCostPiasters * 1000, inQtyMilli);
  }
  return roundHalfUpDiv(
    stockMilli * avgCostPiasters + inTotalCostPiasters * 1000,
    stockMilli + inQtyMilli,
  );
}

/// Parses a pound amount typed by the user into piasters, or null.
///
/// Accepts `0-9`, `٠-٩`, `۰-۹`; `.` or `٫` as the decimal point; `,` or `٬`
/// grouping in threes; at most 2 decimals. A leading `-` only when
/// [allowNegative] is true.
int? tryParsePiasters(String input, {bool allowNegative = false}) =>
    parseScaledDecimal(
      input,
      scale: 2,
      maxDecimals: 2,
      allowNegative: allowNegative,
    );

/// Formats piasters with 2 decimals, e.g. `١٬٢٣٤٫٥٠ ج.م` (Arabic) or
/// `EGP 1,234.50` (English). [digits] picks the digit shapes. A [sign]
/// such as `+` is kept left-to-right with the number, so in Arabic it stays
/// in front of the number and the currency stays after it.
String formatPiasters(
  int piasters, {
  required AppLocaleCode locale,
  required DigitStyle digits,
  bool withCurrency = true,
  String sign = '',
}) {
  final plain = applyDigitStyle(
    formatScaledDecimal(piasters, scale: 2, minDecimals: 2),
    digits,
  );
  final number = sign.isEmpty ? plain : ltrIsolate('$sign$plain');
  if (!withCurrency) return number;
  // A no-break space: an amount never wraps away from its currency.
  return switch (locale) {
    AppLocaleCode.ar => '$number ج.م',
    AppLocaleCode.en => 'EGP $number',
  };
}
