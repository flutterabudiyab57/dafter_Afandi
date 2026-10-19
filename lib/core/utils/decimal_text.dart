/// Shared parsing and formatting of scaled integers ("12.50" ↔ 1250).
///
/// Used by money.dart and quantity.dart. Integer math only (constitution III).
library;

import 'digits.dart';

/// Upper bound on integer-part digits, so `value * 10^scale` stays in range.
const int _maxIntegerDigits = 15;

final RegExp _number = RegExp(r'^(\d{1,3}(?:,\d{3})+|\d+)(?:\.(\d+))?$');

/// Parses [input] as a decimal with up to [maxDecimals] fraction digits and
/// returns it scaled by `10^scale`, or null when the text is not a valid
/// number.
///
/// - Digits: `0-9`, `٠-٩`, `۰-۹`.
/// - Decimal point: `.` or `٫`.
/// - Grouping: `,` or `٬`, only in groups of three in the integer part.
/// - Leading and trailing whitespace is ignored. A leading `-` is accepted only
///   when [allowNegative] is true.
int? parseScaledDecimal(
  String input, {
  required int scale,
  required int maxDecimals,
  bool allowNegative = false,
}) {
  assert(maxDecimals <= scale);
  var text = normalizeDigits(input)
      .trim()
      .replaceAll('٫', '.')
      .replaceAll('٬', ',');
  var negative = false;
  if (text.startsWith('-')) {
    if (!allowNegative) return null;
    negative = true;
    text = text.substring(1);
  }
  final match = _number.firstMatch(text);
  if (match == null) return null;

  final integerDigits = match.group(1)!.replaceAll(',', '');
  final fraction = match.group(2) ?? '';
  if (fraction.length > maxDecimals) return null;
  if (integerDigits.length > _maxIntegerDigits) return null;

  final value = int.parse(integerDigits) * _pow10(scale) +
      (fraction.isEmpty ? 0 : int.parse(fraction.padRight(scale, '0')));
  return negative ? -value : value;
}

/// Formats [value] (scaled by `10^scale`) with Latin digits, `,` grouping and
/// `.` as the decimal point.
///
/// Shows exactly [minDecimals] fraction digits, or more, up to [scale], when
/// the value needs them (trailing zeros beyond [minDecimals] are dropped).
String formatScaledDecimal(
  int value, {
  required int scale,
  required int minDecimals,
}) {
  final unit = _pow10(scale);
  final magnitude = value.abs();
  final integerPart = _group((magnitude ~/ unit).toString());
  var fraction = (magnitude % unit).toString().padLeft(scale, '0');
  while (fraction.length > minDecimals && fraction.endsWith('0')) {
    fraction = fraction.substring(0, fraction.length - 1);
  }
  final sign = value < 0 ? '-' : '';
  return fraction.isEmpty ? '$sign$integerPart' : '$sign$integerPart.$fraction';
}

String _group(String digits) {
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return out.toString();
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
