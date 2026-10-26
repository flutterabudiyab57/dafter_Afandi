import 'package:equatable/equatable.dart';

/// Every kind of stock change. This feature writes only [opening] and
/// [adjustment]; the history already shows the others (FR-016).
enum StockEntryType {
  opening,
  purchase,
  purchaseVoid,
  sale,
  saleReturn,
  saleVoid,
  adjustment,
}

/// Why stock was adjusted (decision Q14).
enum AdjustmentKind { damage, count, other }

/// One permanent entry in a product's stock history.
final class StockEntry extends Equatable {
  const StockEntry({
    required this.id,
    required this.type,
    required this.qtyDeltaMilli,
    required this.unitCostPiasters,
    required this.at,
    required this.rowOrder,
    this.reason,
    this.note,
  });

  final String id;
  final StockEntryType type;

  /// Signed: positive adds stock.
  final int qtyDeltaMilli;

  /// The cost per unit recorded with the entry.
  final int unitCostPiasters;

  /// UTC.
  final DateTime at;

  /// Insertion order, the tie-break for entries with the same time.
  final int rowOrder;

  /// Set only for [StockEntryType.adjustment].
  final AdjustmentKind? reason;
  final String? note;

  /// Where the next history page starts.
  StockEntryCursor get cursor => StockEntryCursor(at: at, rowOrder: rowOrder);

  @override
  List<Object?> get props => [
    id,
    type,
    qtyDeltaMilli,
    unitCostPiasters,
    at,
    rowOrder,
    reason,
    note,
  ];
}

/// History pages are newest first; a page continues strictly before this.
final class StockEntryCursor extends Equatable {
  const StockEntryCursor({required this.at, required this.rowOrder});

  final DateTime at;
  final int rowOrder;

  @override
  List<Object?> get props => [at, rowOrder];
}
