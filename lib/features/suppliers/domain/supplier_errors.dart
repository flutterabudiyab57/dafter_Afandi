import 'package:equatable/equatable.dart';

/// Why saving a supplier failed.
sealed class SupplierSaveError extends Equatable {
  const SupplierSaveError();

  @override
  List<Object?> get props => [];
}

final class SupplierNotFound extends SupplierSaveError {
  const SupplierNotFound();
}

/// Why a payment to a supplier could not be recorded or cancelled.
sealed class SupplierPaymentError extends Equatable {
  const SupplierPaymentError();

  @override
  List<Object?> get props => [];
}

final class PaymentSupplierNotFound extends SupplierPaymentError {
  const PaymentSupplierNotFound();
}

final class PaymentSupplierArchived extends SupplierPaymentError {
  const PaymentSupplierArchived();
}

/// Only a standalone payment (one with a payment number) can be cancelled;
/// a payment made with a purchase is undone by voiding the purchase.
final class SupplierPaymentNotCancellable extends SupplierPaymentError {
  const SupplierPaymentNotCancellable();
}

final class SupplierPaymentAlreadyCancelled extends SupplierPaymentError {
  const SupplierPaymentAlreadyCancelled();
}

/// The cancel reason is empty or longer than allowed (FR-017a).
final class SupplierPaymentReasonInvalid extends SupplierPaymentError {
  const SupplierPaymentReasonInvalid();
}
