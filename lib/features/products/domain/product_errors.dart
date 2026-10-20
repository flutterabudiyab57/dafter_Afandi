import 'package:equatable/equatable.dart';

/// Product and stock limits (research R8).
const int maxProductNameLength = 100;
const int maxCodeLength = 64;
const int maxCategoryNameLength = 40;
const int maxNoteLength = 200;

/// 10,000,000 EGP.
const int maxPricePiasters = 1000000000;

/// 1,000,000 units.
const int maxQuantityMilli = 1000000000;

/// The product form fields an error can belong to.
enum ProductField {
  name,
  price,
  lowStock,
  openingQty,
  openingCost,
  barcode,
  sku,
}

/// A problem with one product form field.
sealed class ProductFieldError extends Equatable {
  const ProductFieldError();

  ProductField get field;

  @override
  List<Object?> get props => [field];
}

final class NameRequired extends ProductFieldError {
  const NameRequired();

  @override
  ProductField get field => ProductField.name;
}

final class NameTooLong extends ProductFieldError {
  const NameTooLong(this.max);

  final int max;

  @override
  ProductField get field => ProductField.name;

  @override
  List<Object?> get props => [field, max];
}

final class PriceRequired extends ProductFieldError {
  const PriceRequired();

  @override
  ProductField get field => ProductField.price;
}

/// Not a number, or more than 2 decimals.
final class PriceInvalid extends ProductFieldError {
  const PriceInvalid(this.field);

  @override
  final ProductField field;
}

final class PriceTooLarge extends ProductFieldError {
  const PriceTooLarge(this.field, this.maxPiasters);

  @override
  final ProductField field;
  final int maxPiasters;

  @override
  List<Object?> get props => [field, maxPiasters];
}

/// Not a number, negative, or more than 3 decimals.
final class QuantityInvalid extends ProductFieldError {
  const QuantityInvalid(this.field);

  @override
  final ProductField field;
}

/// A fraction for a piece product.
final class QuantityNotWhole extends ProductFieldError {
  const QuantityNotWhole(this.field);

  @override
  final ProductField field;
}

final class QuantityTooLarge extends ProductFieldError {
  const QuantityTooLarge(this.field, this.maxMilli);

  @override
  final ProductField field;
  final int maxMilli;

  @override
  List<Object?> get props => [field, maxMilli];
}

/// An opening quantity above zero with no cost.
final class OpeningCostRequired extends ProductFieldError {
  const OpeningCostRequired();

  @override
  ProductField get field => ProductField.openingCost;
}

final class BarcodeTooLong extends ProductFieldError {
  const BarcodeTooLong(this.max);

  final int max;

  @override
  ProductField get field => ProductField.barcode;

  @override
  List<Object?> get props => [field, max];
}

final class SkuTooLong extends ProductFieldError {
  const SkuTooLong(this.max);

  final int max;

  @override
  ProductField get field => ProductField.sku;

  @override
  List<Object?> get props => [field, max];
}

/// Why a product save failed in the repository.
sealed class ProductSaveError extends Equatable {
  const ProductSaveError();

  @override
  List<Object?> get props => [];
}

/// Another active product already has this barcode.
final class BarcodeTaken extends ProductSaveError {
  const BarcodeTaken(this.otherProductName);

  final String otherProductName;

  @override
  List<Object?> get props => [otherProductName];
}

/// The unit changed on a product that has stock history.
final class UnitLocked extends ProductSaveError {
  const UnitLocked();
}

/// Opening stock on a product that already has stock history.
final class OpeningNotAllowed extends ProductSaveError {
  const OpeningNotAllowed();
}

final class ProductNotFound extends ProductSaveError {
  const ProductNotFound();
}

/// Why restoring an archived product failed.
sealed class RestoreError extends Equatable {
  const RestoreError();

  @override
  List<Object?> get props => [];
}

final class RestoreBarcodeTaken extends RestoreError {
  const RestoreBarcodeTaken(this.otherProductName);

  final String otherProductName;

  @override
  List<Object?> get props => [otherProductName];
}

/// A problem with a category name.
sealed class CategoryError extends Equatable {
  const CategoryError();

  @override
  List<Object?> get props => [];
}

final class CategoryNameRequired extends CategoryError {
  const CategoryNameRequired();
}

final class CategoryNameTooLong extends CategoryError {
  const CategoryNameTooLong(this.max);

  final int max;

  @override
  List<Object?> get props => [max];
}

/// An active category already has a name that search treats as equal.
final class CategoryDuplicate extends CategoryError {
  const CategoryDuplicate();
}

/// A problem with a stock adjustment.
sealed class AdjustmentError extends Equatable {
  const AdjustmentError();

  @override
  List<Object?> get props => [];
}

/// Empty, or zero where a quantity to add or remove is needed.
final class AdjustmentQuantityRequired extends AdjustmentError {
  const AdjustmentQuantityRequired();
}

final class AdjustmentQuantityInvalid extends AdjustmentError {
  const AdjustmentQuantityInvalid();
}

final class AdjustmentQuantityNotWhole extends AdjustmentError {
  const AdjustmentQuantityNotWhole();
}

final class AdjustmentQuantityTooLarge extends AdjustmentError {
  const AdjustmentQuantityTooLarge(this.maxMilli);

  final int maxMilli;

  @override
  List<Object?> get props => [maxMilli];
}

final class AdjustmentNoteRequired extends AdjustmentError {
  const AdjustmentNoteRequired();
}

final class AdjustmentNoteTooLong extends AdjustmentError {
  const AdjustmentNoteTooLong(this.max);

  final int max;

  @override
  List<Object?> get props => [max];
}

/// The removal is larger than the stock on hand.
final class ExceedsStock extends AdjustmentError {
  const ExceedsStock(this.onHandMilli);

  final int onHandMilli;

  @override
  List<Object?> get props => [onHandMilli];
}

/// A count equal to the stock: nothing to record.
final class AlreadyMatches extends AdjustmentError {
  const AlreadyMatches();
}
