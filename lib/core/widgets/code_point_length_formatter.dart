import 'package:flutter/services.dart';

/// Limits input to [maxLength] Unicode code points, the same count the
/// domain and the database CHECK use (research R10). `maxLength` on a
/// TextField counts grapheme clusters, which can differ.
final class CodePointLengthFormatter extends TextInputFormatter {
  const CodePointLengthFormatter(this.maxLength);

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final runes = newValue.text.runes;
    if (runes.length <= maxLength) return newValue;
    // A full field ignores the edit; a shorter one (e.g. a long paste) is
    // cut at the limit.
    if (oldValue.text.runes.length == maxLength) return oldValue;
    final text = String.fromCharCodes(runes.take(maxLength));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
