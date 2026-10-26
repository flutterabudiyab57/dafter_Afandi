import 'package:equatable/equatable.dart';

import 'payment.dart';

/// The kinds of customer account rows this feature shows.
enum LedgerEntryType { openingBalance, sale, payment, saleVoid, reversal }

/// One row of a customer's statement (FR-015), newest first.
final class LedgerEntry extends Equatable {
  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amountPiasters,
    required this.runningBalancePiasters,
    required this.at,
    required this.rowOrder,
    this.invoiceId,
    this.invoiceNumber,
    this.receiptNumber,
    this.method,
    this.note,
    this.reversed = false,
  });

  final String id;
  final LedgerEntryType type;

  /// Signed: positive means the customer owes more.
  final int amountPiasters;

  /// The balance right after this row.
  final int runningBalancePiasters;

  /// UTC.
  final DateTime at;

  /// Insertion order, the tie-break for rows with the same time.
  final int rowOrder;

  final String? invoiceId;
  final int? invoiceNumber;
  final int? receiptNumber;
  final PaymentMethod? method;
  final String? note;

  /// A later reversal row points to this one (a cancelled payment).
  final bool reversed;

  /// A standalone payment that has not been cancelled yet (FR-016a).
  bool get cancellable =>
      type == LedgerEntryType.payment && receiptNumber != null && !reversed;

  LedgerCursor get cursor => LedgerCursor(at: at, rowOrder: rowOrder);

  @override
  List<Object?> get props => [
    id,
    type,
    amountPiasters,
    runningBalancePiasters,
    at,
    rowOrder,
    invoiceId,
    invoiceNumber,
    receiptNumber,
    method,
    note,
    reversed,
  ];
}

/// Statement pages continue strictly before this row.
final class LedgerCursor extends Equatable {
  const LedgerCursor({required this.at, required this.rowOrder});

  final DateTime at;
  final int rowOrder;

  @override
  List<Object?> get props => [at, rowOrder];
}
