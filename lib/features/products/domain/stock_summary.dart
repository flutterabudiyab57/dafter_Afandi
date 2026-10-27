import 'package:equatable/equatable.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/quantity.dart';
import 'product.dart';

/// What the shop holds, in one category or none.
final class StockGroup extends Equatable {
  const StockGroup({
    required this.categoryId,
    required this.categoryName,
    required this.productCount,
    required this.quantitiesMilli,
    required this.costPiasters,
    required this.salePiasters,
  });

  /// Null for products with no (active) category.
  final String? categoryId;
  final String? categoryName;

  /// Products in the group, with stock or without.
  final int productCount;

  /// The stock above 0, per unit, in [UnitType] order; units with none
  /// are left out.
  final Map<UnitType, int> quantitiesMilli;

  /// The stock above 0 at the average cost, and at the sale price.
  final int costPiasters;
  final int salePiasters;

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    productCount,
    quantitiesMilli,
    costPiasters,
    salePiasters,
  ];
}

/// The value and quantities of the stock of active products. Stock below
/// zero counts as none.
final class StockSummary extends Equatable {
  const StockSummary({
    required this.groups,
    required this.costPiasters,
    required this.salePiasters,
    required this.withoutCostCount,
  });

  /// Groups by category, in the order the products came (list order of
  /// each group's first product); products with no category last.
  factory StockSummary.of(List<ProductSummary> products) {
    final byCategory = <String?, List<ProductSummary>>{};
    for (final s in products) {
      byCategory.putIfAbsent(s.product.categoryId, () => []).add(s);
    }
    final none = byCategory.remove(null);
    final groups = [
      for (final list in byCategory.values) _group(list),
      if (none != null) _group(none),
    ];
    return StockSummary(
      groups: groups,
      costPiasters: groups.fold(0, (sum, g) => sum + g.costPiasters),
      salePiasters: groups.fold(0, (sum, g) => sum + g.salePiasters),
      withoutCostCount: products
          .where((s) => s.stockMilli > 0 && s.product.avgCostPiasters == 0)
          .length,
    );
  }

  final List<StockGroup> groups;
  final int costPiasters;
  final int salePiasters;

  /// Products in stock with no purchase cost yet: their cost value is 0.
  final int withoutCostCount;

  static StockGroup _group(List<ProductSummary> list) {
    final quantities = <UnitType, int>{};
    var cost = 0;
    var sale = 0;
    for (final s in list) {
      if (s.stockMilli <= 0) continue;
      final p = s.product;
      quantities.update(
        p.unit,
        (q) => q + s.stockMilli,
        ifAbsent: () => s.stockMilli,
      );
      cost += lineTotalPiasters(s.stockMilli, p.avgCostPiasters);
      sale += lineTotalPiasters(s.stockMilli, p.salePricePiasters);
    }
    final first = list.first.product;
    return StockGroup(
      categoryId: first.categoryId,
      categoryName: first.categoryName,
      productCount: list.length,
      quantitiesMilli: {for (final u in UnitType.values) u: ?quantities[u]},
      costPiasters: cost,
      salePiasters: sale,
    );
  }

  @override
  List<Object?> get props => [
    groups,
    costPiasters,
    salePiasters,
    withoutCostCount,
  ];
}
