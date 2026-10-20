import 'package:equatable/equatable.dart';

import '../../../core/utils/digits.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/quantity.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/text_length.dart';
import 'product_errors.dart';
import 'quantity_input.dart';

/// Stock on the shelf when the product is entered, with its cost per unit.
final class OpeningStock extends Equatable {
  const OpeningStock({required this.qtyMilli, required this.unitCostPiasters})
    : assert(qtyMilli > 0);

  final int qtyMilli;
  final int unitCostPiasters;

  /// `qty × cost`, rounded half up (shown on the confirmation, research R13).
  int get totalPiasters => lineTotalPiasters(qtyMilli, unitCostPiasters);

  /// Reads the opening fields (FR-004). A quantity of 0 or empty means no
  /// opening stock (`Ok(null)`); then the cost is ignored.
  static Result<OpeningStock?, List<ProductFieldError>> read({
    required String qtyText,
    required String costText,
    required UnitType unit,
  }) {
    final int qty;
    switch (readQuantity(qtyText, unit)) {
      case NumberEmpty():
        return const Ok(null);
      case NumberValue(:final value):
        if (value == 0) return const Ok(null);
        qty = value;
      case NumberProblem(:final kind):
        return Err([_quantityError(kind, ProductField.openingQty)]);
    }

    return switch (readMoney(costText)) {
      NumberEmpty() => const Err([OpeningCostRequired()]),
      NumberValue(:final value) => Ok(
        OpeningStock(qtyMilli: qty, unitCostPiasters: value),
      ),
      NumberProblem(:final kind) => Err([
        _moneyError(kind, ProductField.openingCost),
      ]),
    };
  }

  @override
  List<Object?> get props => [qtyMilli, unitCostPiasters];
}

/// Validated product input from the form (data-model.md).
final class ProductDraft extends Equatable {
  const ProductDraft({
    required this.name,
    required this.unit,
    required this.salePricePiasters,
    this.categoryId,
    this.barcode,
    this.sku,
    this.lowStockThresholdMilli,
    this.opening,
  });

  final String name;
  final UnitType unit;
  final int salePricePiasters;
  final String? categoryId;
  final String? barcode;
  final String? sku;
  final int? lowStockThresholdMilli;
  final OpeningStock? opening;

  /// Validates every field and returns all errors at once (research R8).
  static Result<ProductDraft, List<ProductFieldError>> create({
    required String name,
    required UnitType unit,
    required String priceText,
    String? categoryId,
    String barcode = '',
    String sku = '',
    String lowStockText = '',
    String openingQtyText = '',
    String openingCostText = '',
  }) {
    final errors = <ProductFieldError>[];

    final trimmedName = name.trim();
    final nameLength = codePointLength(trimmedName);
    if (nameLength == 0) {
      errors.add(const NameRequired());
    } else if (nameLength > maxProductNameLength) {
      errors.add(const NameTooLong(maxProductNameLength));
    }

    int? price;
    switch (readMoney(priceText)) {
      case NumberEmpty():
        errors.add(const PriceRequired());
      case NumberValue(:final value):
        price = value;
      case NumberProblem(:final kind):
        errors.add(_moneyError(kind, ProductField.price));
    }

    int? lowStock;
    switch (readQuantity(lowStockText, unit)) {
      case NumberEmpty():
        break;
      case NumberValue(:final value):
        lowStock = value;
      case NumberProblem(:final kind):
        errors.add(_quantityError(kind, ProductField.lowStock));
    }

    final normalizedBarcode = normalizeCode(barcode);
    if (normalizedBarcode != null &&
        codePointLength(normalizedBarcode) > maxCodeLength) {
      errors.add(const BarcodeTooLong(maxCodeLength));
    }
    final normalizedSku = normalizeCode(sku);
    if (normalizedSku != null &&
        codePointLength(normalizedSku) > maxCodeLength) {
      errors.add(const SkuTooLong(maxCodeLength));
    }

    OpeningStock? opening;
    switch (OpeningStock.read(
      qtyText: openingQtyText,
      costText: openingCostText,
      unit: unit,
    )) {
      case Ok(:final value):
        opening = value;
      case Err(:final error):
        errors.addAll(error);
    }

    if (errors.isNotEmpty) return Err(errors);
    return Ok(
      ProductDraft(
        name: trimmedName,
        unit: unit,
        salePricePiasters: price!,
        categoryId: categoryId,
        barcode: normalizedBarcode,
        sku: normalizedSku,
        lowStockThresholdMilli: lowStock,
        opening: opening,
      ),
    );
  }

  /// The same values without the opening stock (used by edits).
  ProductDraft withoutOpening() => ProductDraft(
    name: name,
    unit: unit,
    salePricePiasters: salePricePiasters,
    categoryId: categoryId,
    barcode: barcode,
    sku: sku,
    lowStockThresholdMilli: lowStockThresholdMilli,
  );

  @override
  List<Object?> get props => [
    name,
    unit,
    salePricePiasters,
    categoryId,
    barcode,
    sku,
    lowStockThresholdMilli,
    opening,
  ];
}

/// Trims a barcode or code and folds its digits to Latin; empty means none
/// (research R9). Inner spaces are kept.
String? normalizeCode(String raw) {
  final text = normalizeDigits(raw).trim();
  return text.isEmpty ? null : text;
}

ProductFieldError _quantityError(NumberProblemKind kind, ProductField field) =>
    switch (kind) {
      NumberProblemKind.invalid => QuantityInvalid(field),
      NumberProblemKind.notWhole => QuantityNotWhole(field),
      NumberProblemKind.tooLarge => QuantityTooLarge(field, maxQuantityMilli),
    };

ProductFieldError _moneyError(NumberProblemKind kind, ProductField field) =>
    switch (kind) {
      NumberProblemKind.tooLarge => PriceTooLarge(field, maxPricePiasters),
      NumberProblemKind.invalid ||
      NumberProblemKind.notWhole => PriceInvalid(field),
    };
