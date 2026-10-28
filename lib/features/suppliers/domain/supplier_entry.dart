import 'package:equatable/equatable.dart';

import '../../customers/domain/ledger_entry.dart';
import '../../customers/domain/payment.dart';
import '../../payments/domain/payment_split.dart';

/// The kinds of supplier account rows this feature shows.
enum SupplierEntryType {
  openingBalance,
  purchase,
  payment,
  purchaseVoid,
  reversal,
}

/// One row of a supplier's statement (FR-016), newest first.
final class SupplierEntry extends Equatable {
  const SupplierEntry({
    required this.id,
    required this.type,
    required this.amountPiasters,
    required this.runningBalancePiasters,
    required this.at,
    required this.rowOrder,
    this.purchaseId,
    this.purchaseNumber,
    this.paymentNumber,
    this.method,
    this.parts = const [],
    this.note,
    this.reversed = false,
  });

  final String id;
  final SupplierEntryType type;

  /// Signed: positive means the shop owes more.
  final int amountPiasters;

  /// The balance right after this row.
  final int runningBalancePiasters;

  /// UTC.
  final DateTime at;

  /// Insertion order, the tie-break for rows with the same time.
  final int rowOrder;

  final String? purchaseId;
  final int? purchaseNumber;
  final int? paymentNumber;
  final PaymentMethod? method;

  /// The payment's parts with their methods and account numbers (FR-039);
  /// empty for a record saved before 006 or with nothing paid.
  final List<PaymentPart> parts;
  final String? note;

  /// A later reversal row points to this one (a cancelled payment).
  final bool reversed;

  /// A standalone payment that has not been cancelled yet (FR-017a).
  bool get cancellable =>
      type == SupplierEntryType.payment && paymentNumber != null && !reversed;

  LedgerCursor get cursor => LedgerCursor(at: at, rowOrder: rowOrder);

  @override
  List<Object?> get props => [
    id,
    type,
    amountPiasters,
    runningBalancePiasters,
    at,
    rowOrder,
    purchaseId,
    purchaseNumber,
    paymentNumber,
    method,
    parts,
    note,
    reversed,
  ];
}
