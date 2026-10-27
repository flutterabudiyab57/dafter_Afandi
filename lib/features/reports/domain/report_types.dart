import 'package:equatable/equatable.dart';

import '../../../core/utils/quantity.dart';
import '../../payments/domain/payment_method.dart';

/// Money that came in during a period, by method (FR-013, research R8):
/// paid at sale time on sales not voided, plus customer receipts not
/// cancelled, minus refunds paid. A split payment counts each part under its
/// own method.
final class CollectedSummary extends Equatable {
  const CollectedSummary(this.byMethod);

  static const CollectedSummary empty = CollectedSummary({});

  /// Methods with no money are absent.
  final Map<PaymentMethod, int> byMethod;

  int of(PaymentMethod method) => byMethod[method] ?? 0;

  int get totalPiasters => byMethod.values.fold(0, (sum, v) => sum + v);

  @override
  List<Object?> get props => [byMethod];
}

/// A customer or supplier with what is owed (FR-015). Balances are as of
/// now, not for a period.
final class BalanceRow extends Equatable {
  const BalanceRow({
    required this.partyId,
    required this.name,
    required this.balancePiasters,
    this.archived = false,
  });

  final String partyId;
  final String name;

  /// Above 0: owed to the shop (a customer) or by the shop (a supplier).
  final int balancePiasters;
  final bool archived;

  @override
  List<Object?> get props => [partyId, name, balancePiasters, archived];
}

/// Today on the home screen (US1, FR-016 to FR-019). The running-low count
/// comes from the existing low-stock card's cubit.
final class DashboardSnapshot extends Equatable {
  const DashboardSnapshot({
    required this.todaySalesPiasters,
    required this.todaySalesCount,
    required this.todayCollected,
    required this.topDebtors,
  });

  /// Net: sales not voided minus returns made today.
  final int todaySalesPiasters;

  /// Sales not voided.
  final int todaySalesCount;
  final CollectedSummary todayCollected;

  /// The three customers who owe the most, largest first.
  final List<BalanceRow> topDebtors;

  @override
  List<Object?> get props => [
    todaySalesPiasters,
    todaySalesCount,
    todayCollected,
    topDebtors,
  ];
}

/// How the top sellers are ordered (FR-014).
enum TopSellerOrder { value, quantity }

/// A product sold in a period: sold minus returned, on sales not voided
/// (FR-014). Archived products are still listed.
final class TopSeller extends Equatable {
  const TopSeller({
    required this.productId,
    required this.name,
    required this.unit,
    required this.qtyMilli,
    required this.netSalesPiasters,
  });

  final String productId;

  /// The name on its latest sale.
  final String name;
  final UnitType unit;
  final int qtyMilli;

  /// After line and invoice discounts, minus refunds.
  final int netSalesPiasters;

  @override
  List<Object?> get props => [
    productId,
    name,
    unit,
    qtyMilli,
    netSalesPiasters,
  ];
}
