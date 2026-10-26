import 'package:equatable/equatable.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/text_length.dart';
import 'customer_errors.dart';

/// Validated customer fields, ready to save (research R13).
final class CustomerDraft extends Equatable {
  const CustomerDraft({
    required this.name,
    this.phone,
    this.address,
    this.note,
    this.openingBalancePiasters = 0,
  });

  final String name;
  final String? phone;
  final String? address;
  final String? note;

  /// Signed: positive means the customer owes the shop, negative that the
  /// shop owes them. 0 means none. Used only when adding.
  final int openingBalancePiasters;

  /// Validates every field and returns all errors at once.
  static Result<CustomerDraft, List<CustomerFieldError>> create({
    required String name,
    String phone = '',
    String address = '',
    String note = '',
    String openingText = '',
    bool openingInFavour = false,
  }) {
    final errors = <CustomerFieldError>[];

    final trimmedName = name.trim();
    final nameLength = codePointLength(trimmedName);
    if (nameLength == 0) {
      errors.add(
        const CustomerFieldError(CustomerField.name, CustomerProblem.required),
      );
    } else if (nameLength > maxCustomerNameLength) {
      errors.add(
        const CustomerFieldError(
          CustomerField.name,
          CustomerProblem.tooLong,
          max: maxCustomerNameLength,
        ),
      );
    }

    String? normalizedPhone;
    switch (parseShopPhone(phone)) {
      case PhoneEmpty():
        break;
      case PhoneOk(:final normalized):
        normalizedPhone = normalized;
      case PhoneInvalidChars():
        errors.add(
          const CustomerFieldError(
            CustomerField.phone,
            CustomerProblem.invalid,
          ),
        );
      case PhoneTooShort():
        errors.add(
          const CustomerFieldError(
            CustomerField.phone,
            CustomerProblem.tooShort,
          ),
        );
      case PhoneTooLong():
        errors.add(
          const CustomerFieldError(
            CustomerField.phone,
            CustomerProblem.tooLong,
          ),
        );
    }

    String? optionalText(String raw, CustomerField field) {
      final text = raw.trim();
      if (codePointLength(text) > maxCustomerTextLength) {
        errors.add(
          CustomerFieldError(
            field,
            CustomerProblem.tooLong,
            max: maxCustomerTextLength,
          ),
        );
      }
      return text.isEmpty ? null : text;
    }

    final trimmedAddress = optionalText(address, CustomerField.address);
    final trimmedNote = optionalText(note, CustomerField.note);

    var opening = 0;
    switch (readAmount(openingText, CustomerField.opening, allowZero: true)) {
      case Ok(:final value):
        opening = openingInFavour ? -value : value;
      case Err(:final error):
        errors.add(error);
    }

    if (errors.isNotEmpty) return Err(errors);
    return Ok(
      CustomerDraft(
        name: trimmedName,
        phone: normalizedPhone,
        address: trimmedAddress,
        note: trimmedNote,
        openingBalancePiasters: opening,
      ),
    );
  }

  @override
  List<Object?> get props => [
    name,
    phone,
    address,
    note,
    openingBalancePiasters,
  ];
}

/// Reads an amount typed by the user: up to [maxAmountPiasters], at most two
/// decimals, Arabic or Latin digits. With [allowZero], empty and 0 read as
/// 0; otherwise both are "required".
Result<int, CustomerFieldError> readAmount(
  String text,
  CustomerField field, {
  bool allowZero = false,
}) {
  if (text.trim().isEmpty) {
    return allowZero
        ? const Ok(0)
        : Err(CustomerFieldError(field, CustomerProblem.required));
  }
  final piasters = tryParsePiasters(text);
  if (piasters == null) {
    return Err(CustomerFieldError(field, CustomerProblem.invalid));
  }
  if (piasters > maxAmountPiasters) {
    return Err(
      CustomerFieldError(
        field,
        CustomerProblem.tooLarge,
        max: maxAmountPiasters,
      ),
    );
  }
  if (piasters == 0 && !allowZero) {
    return Err(CustomerFieldError(field, CustomerProblem.required));
  }
  return Ok(piasters);
}
