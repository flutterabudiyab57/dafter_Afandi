/// Digit display and input normalization (research R9).
library;

enum DigitStyle { arabicIndic, latin }

const int _latinZero = 0x30;
const int _arabicIndicZero = 0x0660;
const int _persianZero = 0x06F0;

const String _arabicDecimal = '٫'; // ٫
const String _arabicGrouping = '٬'; // ٬

/// Maps Arabic-Indic (U+0660–0669) and Persian (U+06F0–06F9) digits to `0-9`.
/// Every other character is kept.
String normalizeDigits(String input) {
  final out = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= _arabicIndicZero && rune <= _arabicIndicZero + 9) {
      out.writeCharCode(_latinZero + rune - _arabicIndicZero);
    } else if (rune >= _persianZero && rune <= _persianZero + 9) {
      out.writeCharCode(_latinZero + rune - _persianZero);
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

/// Renders a Latin-formatted number in [style]. For Arabic-Indic, `0-9`
/// become `٠-٩`, `.` becomes `٫` and `,` becomes `٬`; Latin is unchanged.
String applyDigitStyle(String latin, DigitStyle style) {
  if (style == DigitStyle.latin) return latin;
  final out = StringBuffer();
  for (final rune in latin.runes) {
    if (rune >= _latinZero && rune <= _latinZero + 9) {
      out.writeCharCode(_arabicIndicZero + rune - _latinZero);
    } else if (rune == 0x2E) {
      out.write(_arabicDecimal);
    } else if (rune == 0x2C) {
      out.write(_arabicGrouping);
    } else {
      out.writeCharCode(rune);
    }
  }
  return out.toString();
}

/// Wraps [s] in a left-to-right isolate (U+2066 … U+2069), so phone numbers
/// and versions keep their order inside right-to-left text.
String ltrIsolate(String s) => '\u2066$s\u2069';
