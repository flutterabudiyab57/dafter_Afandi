import 'package:equatable/equatable.dart';

import '../../../core/utils/quantity.dart';

/// The supplier's own invoice number, in code points (FR-005).
const int maxSupplierRefLength = 50;

/// A purchase note, in code points (FR-005).
const int maxPurchaseNoteLength = 200;

/// A rule a purchase breaks (FR-002, FR-004 to FR-006).
sealed class PurchaseError extends Equatable {
  const PurchaseError();

  @override
  List<Object?> get props => [];
}

final class PurchaseNoLines extends PurchaseError {
  const PurchaseNoLines();
}

/// The same product twice; the draft never builds this.
final class PurchaseDuplicateLine extends PurchaseError {
  const PurchaseDuplicateLine(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// Zero, too large, or a fraction of a piece.
final class PurchaseQuantityInvalid extends PurchaseError {
  const PurchaseQuantityInvalid(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// Below 0 or above 10,000,000 EGP.
final class PurchaseCostInvalid extends PurchaseError {
  const PurchaseCostInvalid(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// A line discount above the line's amount before discount.
final class PurchaseLineDiscountTooLarge extends PurchaseError {
  const PurchaseLineDiscountTooLarge(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// An invoice discount above the subtotal.
final class PurchaseInvoiceDiscountTooLarge extends PurchaseError {
  const PurchaseInvoiceDiscountTooLarge();
}

/// Paid now above the total.
final class PurchasePaidTooLarge extends PurchaseError {
  const PurchasePaidTooLarge();
}

/// Credit or partial payment without a named supplier.
final class CreditNeedsSupplier extends PurchaseError {
  const CreditNeedsSupplier();
}

/// An invoice date after today.
final class PurchaseDateInFuture extends PurchaseError {
  const PurchaseDateInFuture();
}

final class SupplierRefTooLong extends PurchaseError {
  const SupplierRefTooLong();
}

final class PurchaseNoteTooLong extends PurchaseError {
  const PurchaseNoteTooLong();
}

/// Why saving a purchase did not happen.
sealed class PurchaseSaveError extends Equatable {
  const PurchaseSaveError();

  @override
  List<Object?> get props => [];
}

/// The draft breaks a rule (re-checked inside the transaction).
final class PurchaseInvalid extends PurchaseSaveError {
  const PurchaseInvalid(this.errors);

  final List<PurchaseError> errors;

  @override
  List<Object?> get props => [errors];
}

/// A product on the purchase was archived or no longer exists.
final class PurchaseProductUnavailable extends PurchaseSaveError {
  const PurchaseProductUnavailable(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// The picked supplier was archived or no longer exists.
final class SupplierUnavailable extends PurchaseSaveError {
  const SupplierUnavailable();
}

/// One product whose stock a void would take below zero (FR-009a).
final class VoidShortage extends Equatable {
  const VoidShortage({
    required this.productId,
    required this.name,
    required this.unit,
    required this.stockAfterMilli,
  });

  final String productId;
  final String name;
  final UnitType unit;

  /// The stock after the void; below zero.
  final int stockAfterMilli;

  @override
  List<Object?> get props => [productId, name, unit, stockAfterMilli];
}

/// Why a purchase void did not happen.
sealed class PurchaseVoidError extends Equatable {
  const PurchaseVoidError();

  @override
  List<Object?> get props => [];
}

final class PurchaseNotFound extends PurchaseVoidError {
  const PurchaseNotFound();
}

final class PurchaseAlreadyVoided extends PurchaseVoidError {
  const PurchaseAlreadyVoided();
}

/// The reason is empty or longer than allowed (FR-009a).
final class PurchaseVoidReasonInvalid extends PurchaseVoidError {
  const PurchaseVoidReasonInvalid();
}

/// Stock would go below zero and the owner has not confirmed yet
/// (research R9).
final class VoidStockShortage extends PurchaseVoidError {
  const VoidStockShortage(this.items);

  final List<VoidShortage> items;

  @override
  List<Object?> get props => [items];
}
