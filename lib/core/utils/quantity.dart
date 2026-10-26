/// Quantities in integer milli-units (constitution III). 1 unit = 1000 milli.
library;

import 'app_locale_code.dart';
import 'decimal_text.dart';
import 'digits.dart';

const int milliPerUnit = 1000;

enum UnitType {
  piece,
  kg,
  liter,
  meter;

  bool get allowsFraction => this != UnitType.piece;

  int get maxDecimals => allowsFraction ? 3 : 0;
}

/// Parses a quantity typed by the user into milli-units, or null.
///
/// Same digit and separator rules as money; up to [UnitType.maxDecimals]
/// decimals, so a piece rejects any fraction. Negative input is rejected.
int? tryParseQuantityMilli(String input, UnitType unit) =>
    parseScaledDecimal(input, scale: 3, maxDecimals: unit.maxDecimals);

/// Formats milli-units without trailing zeros: `2`, `1.5`, `0.125`,
/// `1,250`. [digits] picks the digit shapes. Unit names come from ARB, so
/// [locale] does not change the number.
String formatQuantityMilli(
  int milli,
  UnitType unit, {
  required AppLocaleCode locale,
  required DigitStyle digits,
}) => applyDigitStyle(
  formatScaledDecimal(milli, scale: 3, minDecimals: 0),
  digits,
);
