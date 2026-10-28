/// The owner's own wallet number or InstaPay address on a payment part
/// (006 research R6).
library;

import 'digits.dart';

/// The longest account number, in characters.
const int maxAccountRefLength = 40;

final RegExp _allowed = RegExp(r'^[0-9A-Za-z@._-]+$');

enum AccountRefProblem { invalidCharacters, tooLong }

/// Arabic and Persian digits become Latin and the ends are trimmed; an empty
/// result is null (no account number).
String? normalizeAccountRef(String input) {
  final text = normalizeDigits(input).trim();
  return text.isEmpty ? null : text;
}

/// Null when [normalized] (from [normalizeAccountRef]) can be saved.
AccountRefProblem? checkAccountRef(String normalized) {
  if (normalized.length > maxAccountRefLength) return AccountRefProblem.tooLong;
  if (!_allowed.hasMatch(normalized)) {
    return AccountRefProblem.invalidCharacters;
  }
  return null;
}
