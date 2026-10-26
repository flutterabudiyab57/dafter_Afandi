import 'package:equatable/equatable.dart';

import '../../../core/utils/phone.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/text_length.dart';

const int maxShopNameLength = 60;

enum ShopProfileError {
  nameRequired,
  nameTooLong,
  phoneInvalidCharacters,
  phoneTooShort,
  phoneTooLong,
}

/// The shop's name and optional phone (FR-004, FR-005, research R10).
final class ShopProfile extends Equatable {
  /// Values that are already valid, e.g. read back from the database.
  /// User input goes through [create].
  const ShopProfile({required this.name, this.phone});

  /// Trimmed, 1–60 code points. Shown exactly as typed (FR-011).
  final String name;

  /// Latin digits with an optional leading `+`, or null.
  final String? phone;

  static Result<ShopProfile, ShopProfileError> create(
    String rawName,
    String rawPhone,
  ) {
    final nameError = validateName(rawName);
    if (nameError != null) return Err(nameError);
    return switch (parseShopPhone(rawPhone)) {
      PhoneOk(:final normalized) => Ok(
        ShopProfile(name: rawName.trim(), phone: normalized),
      ),
      PhoneEmpty() => Ok(ShopProfile(name: rawName.trim())),
      PhoneInvalidChars() => const Err(ShopProfileError.phoneInvalidCharacters),
      PhoneTooShort() => const Err(ShopProfileError.phoneTooShort),
      PhoneTooLong() => const Err(ShopProfileError.phoneTooLong),
    };
  }

  /// The name's error, or null when it is valid.
  static ShopProfileError? validateName(String rawName) {
    final length = codePointLength(rawName.trim());
    if (length == 0) return ShopProfileError.nameRequired;
    if (length > maxShopNameLength) return ShopProfileError.nameTooLong;
    return null;
  }

  /// The phone's error, or null when it is valid or empty.
  static ShopProfileError? validatePhone(String rawPhone) =>
      switch (parseShopPhone(rawPhone)) {
        PhoneOk() || PhoneEmpty() => null,
        PhoneInvalidChars() => ShopProfileError.phoneInvalidCharacters,
        PhoneTooShort() => ShopProfileError.phoneTooShort,
        PhoneTooLong() => ShopProfileError.phoneTooLong,
      };

  @override
  List<Object?> get props => [name, phone];
}
