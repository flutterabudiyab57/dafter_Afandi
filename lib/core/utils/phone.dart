/// Shop phone validation (research R10).
library;

import 'digits.dart';

const int minPhoneDigits = 7;
const int maxPhoneDigits = 15;

sealed class PhoneParse {
  const PhoneParse();
}

/// A valid phone, normalized to Latin digits with an optional leading `+`.
final class PhoneOk extends PhoneParse {
  const PhoneOk(this.normalized);

  final String normalized;

  @override
  bool operator ==(Object other) =>
      other is PhoneOk && other.normalized == normalized;

  @override
  int get hashCode => normalized.hashCode;

  @override
  String toString() => 'PhoneOk($normalized)';
}

final class PhoneEmpty extends PhoneParse {
  const PhoneEmpty();
}

final class PhoneInvalidChars extends PhoneParse {
  const PhoneInvalidChars();
}

final class PhoneTooShort extends PhoneParse {
  const PhoneTooShort();
}

final class PhoneTooLong extends PhoneParse {
  const PhoneTooLong();
}

final RegExp _separators = RegExp(r'[\s\-]');
final RegExp _phone = RegExp(r'^\+?\d*$');

/// Strips spaces and `-`, maps Arabic-Indic and Persian digits to Latin,
/// allows one leading `+`, and requires 7–15 digits.
PhoneParse parseShopPhone(String raw) {
  final text = normalizeDigits(raw.replaceAll(_separators, ''));
  if (text.isEmpty) return const PhoneEmpty();
  if (!_phone.hasMatch(text)) return const PhoneInvalidChars();
  final digitCount = text.startsWith('+') ? text.length - 1 : text.length;
  if (digitCount < minPhoneDigits) return const PhoneTooShort();
  if (digitCount > maxPhoneDigits) return const PhoneTooLong();
  return PhoneOk(text);
}
