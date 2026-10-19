# Contract: core/utils (pure Dart; full unit tests required)

Signatures follow report §5. Additions are marked (+).

```dart
// money.dart
const int piastersPerPound = 100;
int roundHalfUpDiv(int numerator, int denominator);           // half away from zero; denominator > 0
int lineTotalPiasters(int qtyMilli, int unitPricePiasters);   // roundHalfUpDiv(qty*price, 1000)
List<int> allocateLargestRemainder(int total, List<int> weights); // Σ = total; ties → lower index
int weightedAverageCost({required int stockMilli, required int avgCostPiasters,
                         required int inQtyMilli, required int inTotalCostPiasters}); // S<=0 → incoming cost
int? tryParsePiasters(String input, {bool allowNegative = false}); // ٠-٩ ۰-۹ 0-9, "٫"/"." decimal, "٬"/"," grouping, ≤2 decimals
String formatPiasters(int piasters, {required AppLocaleCode locale, required DigitStyle digits,
                      bool withCurrency = true});             // "١٬٢٣٤٫٥٠ ج.م" / "EGP 1,234.50"

// quantity.dart
const int milliPerUnit = 1000;
enum UnitType { piece, kg, liter, meter }                     // allowsFraction, maxDecimals (0 or 3)
int? tryParseQuantityMilli(String input, UnitType unit);
String formatQuantityMilli(int milli, UnitType unit, {required AppLocaleCode locale, required DigitStyle digits});

// digits.dart (+)
enum DigitStyle { arabicIndic, latin }
String normalizeDigits(String input);                         // Arabic-Indic and Persian → Latin
String applyDigitStyle(String latin, DigitStyle style);       // 0-9 → ٠-٩, "." → "٫", "," → "٬"
String ltrIsolate(String s);                                  // wraps in U+2066 … U+2069

// phone.dart (+)
sealed class PhoneParse { }                                   // ok(normalized) | empty | invalidChars | tooShort | tooLong
PhoneParse parseShopPhone(String raw);                        // strips spaces and "-", optional leading "+", 7–15 digits

// arabic_normalize.dart
String arabicNormalize(String input);                         // searchKey rules in data-model.md

// id.dart
abstract interface class IdGenerator { String newId(); }
final class UuidV7Generator implements IdGenerator { const UuidV7Generator(); }

// clock.dart
abstract interface class Clock { DateTime nowUtc(); }
final class SystemClock implements Clock { const SystemClock(); }
final class FixedClock implements Clock { FixedClock(DateTime utc); }   // tests

// text_length.dart (+)
int codePointLength(String s);                                // matches SQLite length()
```

`AppLocaleCode` is a tiny enum in core (`ar`, `en`), so `core/utils` doesn't depend on a feature.

## Required test coverage

- `roundHalfUpDiv`: positives, negatives (half away from zero), exact halves, denominator 1, large
  values near 1e18, and an assertion on denominator ≤ 0.
- `allocateLargestRemainder`: Σ = total for random inputs (property test with a seeded Random), ties
  go to the lower index, zero weights, a single line, total 0.
- `weightedAverageCost`: S > 0 blend, S = 0, S < 0 (incoming cost wins), rounding at .5.
- Parsing and formatting: every digit family, separators, too many decimals, empty, whitespace,
  negative handling, piece rejecting fractions, round-trips `format(parse(x))`.
- `arabicNormalize`: each folding rule, tashkeel and tatweel, mixed scripts, idempotence.
- `UuidV7Generator`: format regex, lowercase, monotonic order across 1,000 ids.
- `parseShopPhone`: each outcome, Arabic digits, `+` only at the start, 7 and 15 boundaries.
- A test greps for `double` in `money.dart` and `quantity.dart` (constitution III).
