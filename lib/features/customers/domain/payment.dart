import 'package:equatable/equatable.dart';

import '../../../core/utils/result.dart';
import '../../../core/utils/text_length.dart';
import '../../payments/domain/payment_method.dart';
import '../../payments/domain/payment_split.dart';
import 'customer_draft.dart';
import 'customer_errors.dart';

export '../../payments/domain/payment_method.dart';

/// A validated payment from a customer (FR-016).
final class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.amountPiasters,
    required this.method,
    this.note,
  });

  /// Above 0.
  final int amountPiasters;
  final PaymentMethod method;

  /// How it was paid: one part in [method] for now (006).
  PaymentSplit get split => PaymentSplit.single(method, amountPiasters);

  final String? note;

  static Result<PaymentRequest, List<CustomerFieldError>> create({
    required String amountText,
    required PaymentMethod method,
    String note = '',
  }) {
    final errors = <CustomerFieldError>[];
    int? amount;
    switch (readAmount(amountText, CustomerField.amount)) {
      case Ok(:final value):
        amount = value;
      case Err(:final error):
        errors.add(error);
    }
    final trimmedNote = note.trim();
    if (codePointLength(trimmedNote) > maxCustomerTextLength) {
      errors.add(
        const CustomerFieldError(
          CustomerField.note,
          CustomerProblem.tooLong,
          max: maxCustomerTextLength,
        ),
      );
    }
    if (errors.isNotEmpty) return Err(errors);
    return Ok(
      PaymentRequest(
        amountPiasters: amount!,
        method: method,
        note: trimmedNote.isEmpty ? null : trimmedNote,
      ),
    );
  }

  @override
  List<Object?> get props => [amountPiasters, method, note];
}

/// A void or cancel reason: trimmed, 1–200 code points (FR-008a, FR-016a).
Result<String, CustomerFieldError> validateReason(String raw) {
  final text = raw.trim();
  final length = codePointLength(text);
  if (length == 0) {
    return const Err(
      CustomerFieldError(CustomerField.reason, CustomerProblem.required),
    );
  }
  if (length > maxReasonLength) {
    return const Err(
      CustomerFieldError(
        CustomerField.reason,
        CustomerProblem.tooLong,
        max: maxReasonLength,
      ),
    );
  }
  return Ok(text);
}
