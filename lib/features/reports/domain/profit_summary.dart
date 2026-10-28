import 'package:equatable/equatable.dart';

import '../../products/domain/stock_entry.dart';

/// The profit report for a period (US2, FR-003 to FR-012). Derived from
/// saved records, never stored.
final class ProfitSummary extends Equatable {
  const ProfitSummary({
    required this.salesPiasters,
    required this.returnsPiasters,
    required this.saleCostPiasters,
    required this.returnedCostPiasters,
    required this.inventoryLossesByReason,
    required this.expensesPiasters,
    required this.salesCount,
    required this.linesWithoutCost,
    this.hasAdjustments = false,
    this.hasReturns = false,
  });

  static const ProfitSummary empty = ProfitSummary(
    salesPiasters: 0,
    returnsPiasters: 0,
    saleCostPiasters: 0,
    returnedCostPiasters: 0,
    inventoryLossesByReason: {},
    expensesPiasters: 0,
    salesCount: 0,
    linesWithoutCost: 0,
  );

  /// Sales not voided in the period.
  final int salesPiasters;

  /// Refunds of returns made in the period (FR-010).
  final int returnsPiasters;

  /// The cost recorded on each sale line at the time of sale (FR-004).
  final int saleCostPiasters;
  final int returnedCostPiasters;

  /// Each reason's net: losses positive, gains from a count negative
  /// (FR-006, FR-012). Reasons with no adjustment are absent.
  final Map<AdjustmentKind, int> inventoryLossesByReason;

  /// Expenses not voided, dated in the period (FR-007).
  final int expensesPiasters;
  final int salesCount;

  /// Sale lines with no cost when sold (edge case: "some products had no
  /// cost").
  final int linesWithoutCost;
  final bool hasAdjustments;
  final bool hasReturns;

  int get netSalesPiasters => salesPiasters - returnsPiasters;

  int get costOfGoodsPiasters => saleCostPiasters - returnedCostPiasters;

  int get grossProfitPiasters => netSalesPiasters - costOfGoodsPiasters;

  /// Negative: a net gain.
  int get inventoryLossesPiasters =>
      inventoryLossesByReason.values.fold(0, (sum, v) => sum + v);

  /// FR-008. Negative: a loss.
  int get netProfitPiasters =>
      grossProfitPiasters - inventoryLossesPiasters - expensesPiasters;

  bool get isLoss => netProfitPiasters < 0;

  /// Nothing happened in the period.
  bool get isEmpty =>
      salesCount == 0 &&
      !hasReturns &&
      !hasAdjustments &&
      expensesPiasters == 0;

  @override
  List<Object?> get props => [
    salesPiasters,
    returnsPiasters,
    saleCostPiasters,
    returnedCostPiasters,
    inventoryLossesByReason,
    expensesPiasters,
    salesCount,
    linesWithoutCost,
    hasAdjustments,
    hasReturns,
  ];
}
