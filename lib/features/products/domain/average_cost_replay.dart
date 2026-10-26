import '../../../core/utils/money.dart';

/// One stock movement as the average-cost replay sees it (research R8 of
/// 004).
///
/// [inboundCostPiasters] is the total cost of an inbound movement that
/// changes the average (opening, purchase, sale return, sale void), or null
/// for a movement that changes stock only.
final class ReplayMovement {
  const ReplayMovement({required this.qtyDeltaMilli, this.inboundCostPiasters});

  final int qtyDeltaMilli;
  final int? inboundCostPiasters;
}

/// The weighted average unit cost after [rows], oldest first, starting from
/// no stock at cost 0.
///
/// The caller leaves out voided purchases and their reversals, so the result
/// is as if they had never been recorded.
int replayAverageCost(Iterable<ReplayMovement> rows) {
  var stock = 0;
  var avg = 0;
  for (final row in rows) {
    final cost = row.inboundCostPiasters;
    if (row.qtyDeltaMilli > 0 && cost != null) {
      avg = weightedAverageCost(
        stockMilli: stock,
        avgCostPiasters: avg,
        inQtyMilli: row.qtyDeltaMilli,
        inTotalCostPiasters: cost,
      );
    }
    stock += row.qtyDeltaMilli;
  }
  return avg;
}
