import 'package:equatable/equatable.dart';

/// Customer limits (research R13).
const int maxCustomerNameLength = 100;
const int maxCustomerTextLength = 200;
const int maxReasonLength = 200;

/// 10,000,000 EGP.
const int maxAmountPiasters = 1000000000;

/// The customer and payment form fields an error can belong to.
enum CustomerField { name, phone, address, note, opening, amount, reason }

enum CustomerProblem { required, tooLong, invalid, tooShort, tooLarge }

/// A problem with one form field. [max] is set for `tooLong` (code points)
/// and `tooLarge` (piasters).
final class CustomerFieldError extends Equatable {
  const CustomerFieldError(this.field, this.problem, {this.max});

  final CustomerField field;
  final CustomerProblem problem;
  final int? max;

  @override
  List<Object?> get props => [field, problem, max];
}

/// Why saving a customer failed.
sealed class CustomerSaveError extends Equatable {
  const CustomerSaveError();

  @override
  List<Object?> get props => [];
}

final class CustomerNotFound extends CustomerSaveError {
  const CustomerNotFound();
}

/// Why a payment could not be recorded or cancelled.
sealed class PaymentError extends Equatable {
  const PaymentError();

  @override
  List<Object?> get props => [];
}

final class PaymentCustomerNotFound extends PaymentError {
  const PaymentCustomerNotFound();
}

final class PaymentCustomerArchived extends PaymentError {
  const PaymentCustomerArchived();
}

/// Only a standalone payment (one with a receipt number) can be cancelled;
/// a payment made with a sale is undone by voiding the sale.
final class PaymentNotCancellable extends PaymentError {
  const PaymentNotCancellable();
}

final class PaymentAlreadyCancelled extends PaymentError {
  const PaymentAlreadyCancelled();
}
