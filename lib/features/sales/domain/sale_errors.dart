import 'package:equatable/equatable.dart';

import '../../../core/utils/quantity.dart';
import '../../payments/domain/payment_split.dart';

/// A rule a sale breaks (FR-002, FR-004, FR-005).
sealed class SaleError extends Equatable {
  const SaleError();

  @override
  List<Object?> get props => [];
}

final class NoLines extends SaleError {
  const NoLines();
}

/// The same product twice; the draft never builds this (research R6).
final class DuplicateLine extends SaleError {
  const DuplicateLine(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// Zero, too large, or a fraction of a piece.
final class LineQuantityInvalid extends SaleError {
  const LineQuantityInvalid(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class LinePriceInvalid extends SaleError {
  const LinePriceInvalid(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// A line discount above the line's amount before discount.
final class LineDiscountTooLarge extends SaleError {
  const LineDiscountTooLarge(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// An invoice discount above the subtotal.
final class InvoiceDiscountTooLarge extends SaleError {
  const InvoiceDiscountTooLarge();
}

/// Paid now above the total.
final class PaidTooLarge extends SaleError {
  const PaidTooLarge();
}

/// Credit or partial payment without a named customer.
final class CreditNeedsCustomer extends SaleError {
  const CreditNeedsCustomer();
}

/// One product a sale needs more of than is on hand (FR-006).
final class Shortage extends Equatable {
  const Shortage({
    required this.productId,
    required this.name,
    required this.unit,
    required this.stockMilli,
    required this.needMilli,
  });

  final String productId;
  final String name;
  final UnitType unit;
  final int stockMilli;
  final int needMilli;

  @override
  List<Object?> get props => [productId, name, unit, stockMilli, needMilli];
}

/// The payment parts are wrong (FR-036, FR-037); shown on the payment
/// field.
final class SalePaymentInvalid extends SaleError {
  const SalePaymentInvalid(this.errors);

  final List<PaymentSplitError> errors;

  @override
  List<Object?> get props => [errors];
}

/// Why saving a sale did not happen.
sealed class SaleSaveError extends Equatable {
  const SaleSaveError();

  @override
  List<Object?> get props => [];
}

/// The draft breaks a rule (re-checked inside the transaction).
final class SaleInvalid extends SaleSaveError {
  const SaleInvalid(this.errors);

  final List<SaleError> errors;

  @override
  List<Object?> get props => [errors];
}

/// Stock is short and the owner has not confirmed yet (research R7).
final class StockShortage extends SaleSaveError {
  const StockShortage(this.items);

  final List<Shortage> items;

  @override
  List<Object?> get props => [items];
}

/// A product on the sale was archived or no longer exists.
final class ProductUnavailable extends SaleSaveError {
  const ProductUnavailable(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// The picked customer was archived or no longer exists.
final class CustomerUnavailable extends SaleSaveError {
  const CustomerUnavailable();
}

/// Why a void did not happen.
sealed class VoidError extends Equatable {
  const VoidError();

  @override
  List<Object?> get props => [];
}

final class InvoiceNotFound extends VoidError {
  const InvoiceNotFound();
}

final class AlreadyVoided extends VoidError {
  const AlreadyVoided();
}

/// The reason is empty or longer than allowed (FR-008a).
final class VoidReasonInvalid extends VoidError {
  const VoidReasonInvalid();
}
