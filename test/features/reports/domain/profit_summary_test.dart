import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/reports/domain/profit_summary.dart';
import 'package:flutter_test/flutter_test.dart';

ProfitSummary _summary({
  int sales = 0,
  int returns = 0,
  int cost = 0,
  int returnedCost = 0,
  Map<AdjustmentKind, int> losses = const {},
  int expenses = 0,
  int count = 0,
}) => ProfitSummary(
  salesPiasters: sales,
  returnsPiasters: returns,
  saleCostPiasters: cost,
  returnedCostPiasters: returnedCost,
  inventoryLossesByReason: losses,
  expensesPiasters: expenses,
  salesCount: count,
  linesWithoutCost: 0,
  hasAdjustments: losses.isNotEmpty,
  hasReturns: returns != 0,
);

void main() {
  test('net profit = gross profit - inventory losses - expenses', () {
    final s = _summary(
      sales: 1000000,
      cost: 700000,
      losses: {AdjustmentKind.damage: 20000},
      expenses: 150000,
      count: 40,
    );
    expect(s.netSalesPiasters, 1000000);
    expect(s.grossProfitPiasters, 300000);
    expect(s.inventoryLossesPiasters, 20000);
    expect(s.netProfitPiasters, 130000);
    expect(s.isLoss, isFalse);
  });

  test('returns reduce net sales and cost of goods', () {
    final s = _summary(
      sales: 10000,
      returns: 2000,
      cost: 6000,
      returnedCost: 1200,
    );
    expect(s.netSalesPiasters, 8000);
    expect(s.costOfGoodsPiasters, 4800);
    expect(s.grossProfitPiasters, 3200);
  });

  test('count gains net against losses and can raise profit', () {
    final s = _summary(
      sales: 10000,
      cost: 8000,
      losses: {AdjustmentKind.damage: 500, AdjustmentKind.count: -1500},
    );
    expect(s.inventoryLossesPiasters, -1000);
    expect(s.netProfitPiasters, 3000);
  });

  test('costs above sales are a loss', () {
    final s = _summary(sales: 5000, cost: 4000, expenses: 3000, count: 1);
    expect(s.netProfitPiasters, -2000);
    expect(s.isLoss, isTrue);
  });

  test('empty only when nothing happened', () {
    expect(ProfitSummary.empty.isEmpty, isTrue);
    expect(_summary(expenses: 1).isEmpty, isFalse);
    expect(_summary(losses: {AdjustmentKind.other: 1}).isEmpty, isFalse);
    expect(_summary(returns: 1).isEmpty, isFalse);
  });
}
