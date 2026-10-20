import 'package:equatable/equatable.dart';

import '../../../core/utils/quantity.dart';

/// A product the shop sells (data-model.md). Values are already valid; user
/// input goes through `ProductDraft.create`.
final class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.salePricePiasters,
    required this.avgCostPiasters,
    this.categoryId,
    this.categoryName,
    this.barcode,
    this.sku,
    this.lowStockThresholdMilli,
    this.archived = false,
  });

  final String id;

  /// Trimmed, shown as typed.
  final String name;
  final UnitType unit;

  /// Per 1 unit (1000 milli).
  final int salePricePiasters;

  /// Weighted average cost per unit, kept by the inventory paths only.
  final int avgCostPiasters;

  /// Null when the product has no category or its category is archived.
  final String? categoryId;
  final String? categoryName;
  final String? barcode;
  final String? sku;
  final int? lowStockThresholdMilli;
  final bool archived;

  @override
  List<Object?> get props => [
    id,
    name,
    unit,
    salePricePiasters,
    avgCostPiasters,
    categoryId,
    categoryName,
    barcode,
    sku,
    lowStockThresholdMilli,
    archived,
  ];
}

/// A product with its derived stock, as shown in lists and details.
final class ProductSummary extends Equatable {
  const ProductSummary({
    required this.product,
    required this.stockMilli,
    required this.hasHistory,
  });

  final Product product;

  /// The sum of the product's stock movements.
  final int stockMilli;

  /// Whether any stock movement exists. The unit and the opening stock can
  /// change only while this is false.
  final bool hasHistory;

  /// At or below the low-stock level, or below zero (FR-008).
  bool get isLow => isLowStock(stockMilli, product.lowStockThresholdMilli);

  bool get isBelowZero => stockMilli < 0;

  @override
  List<Object?> get props => [product, stockMilli, hasHistory];
}

/// The one low-stock rule, shared by the list filter and the Home card.
bool isLowStock(int stockMilli, int? thresholdMilli) =>
    stockMilli < 0 || (thresholdMilli != null && stockMilli <= thresholdMilli);

/// The Home card: the lowest items and how many are low in total.
final class LowStockSnapshot extends Equatable {
  const LowStockSnapshot({
    required this.items,
    required this.totalCount,
    required this.hasAnyProduct,
  });

  final List<ProductSummary> items;
  final int totalCount;

  /// False when the shop has no active product at all.
  final bool hasAnyProduct;

  @override
  List<Object?> get props => [items, totalCount, hasAnyProduct];
}
