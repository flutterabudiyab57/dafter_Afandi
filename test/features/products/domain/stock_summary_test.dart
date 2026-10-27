import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/products/domain/product.dart';
import 'package:daftar_afandi/features/products/domain/stock_summary.dart';
import 'package:flutter_test/flutter_test.dart';

ProductSummary item(
  String id,
  int stockMilli, {
  String? category,
  UnitType unit = UnitType.piece,
  int cost = 0,
  int price = 0,
}) => ProductSummary(
  product: Product(
    id: id,
    name: id,
    unit: unit,
    salePricePiasters: price,
    avgCostPiasters: cost,
    categoryId: category,
    categoryName: category,
  ),
  stockMilli: stockMilli,
  hasHistory: true,
);

void main() {
  test('sums quantities per unit and values per category; no category '
      'last; stock below zero counts as none', () {
    final s = StockSummary.of([
      item('loose', 5000, cost: 100, price: 150),
      item('rumi', 60000, category: 'cheese', cost: 1000, price: 1200),
      item('halawa', 30000, category: 'halawa', cost: 500, price: 700),
      item(
        'feta',
        2500,
        category: 'cheese',
        unit: UnitType.kg,
        cost: 8000,
        price: 9000,
      ),
      item('cream', 40000, category: 'cheese', price: 300),
      item('short', -2000, cost: 100, price: 150),
    ]);

    expect(s.groups.map((g) => g.categoryId), ['cheese', 'halawa', null]);
    final cheese = s.groups.first;
    expect(cheese.productCount, 3);
    expect(cheese.quantitiesMilli, {UnitType.piece: 100000, UnitType.kg: 2500});
    // 60 × 10.00 + 2.5 × 80.00 + 40 × 0.
    expect(cheese.costPiasters, 80000);
    // 60 × 12.00 + 2.5 × 90.00 + 40 × 3.00.
    expect(cheese.salePiasters, 72000 + 22500 + 12000);

    final none = s.groups.last;
    expect(none.productCount, 2);
    expect(none.quantitiesMilli, {UnitType.piece: 5000});
    expect(none.costPiasters, 500);

    expect(s.costPiasters, 80000 + 15000 + 500);
    expect(s.salePiasters, 106500 + 21000 + 750);
    expect(s.withoutCostCount, 1);
  });

  test('no products: no groups and zero values', () {
    final s = StockSummary.of(const []);
    expect(s.groups, isEmpty);
    expect(s.costPiasters, 0);
    expect(s.withoutCostCount, 0);
  });

  test('a category with no stock lists no quantities', () {
    final s = StockSummary.of([item('a', 0, category: 'c', cost: 100)]);
    expect(s.groups.single.quantitiesMilli, isEmpty);
    expect(s.groups.single.costPiasters, 0);
  });
}
