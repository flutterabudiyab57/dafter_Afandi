import 'package:equatable/equatable.dart';

import '../../../core/utils/digits.dart';
import '../../../core/utils/quantity.dart';
import '../../customers/domain/payment.dart';
import '../../payments/domain/payment_split.dart';

/// How a purchase was paid, derived from its amounts.
enum PurchaseKind { cash, partial, credit }

/// One row of the purchase list (FR-010).
final class PurchaseSummary extends Equatable {
  const PurchaseSummary({
    required this.id,
    required this.number,
    required this.invoiceDate,
    required this.at,
    required this.totalPiasters,
    required this.paidPiasters,
    this.supplierId,
    this.supplierName,
    this.supplierRef,
    this.voided = false,
  });

  final String id;
  final int number;

  /// The local calendar date on the supplier's invoice.
  final DateTime invoiceDate;

  /// When it was saved, UTC.
  final DateTime at;
  final int totalPiasters;
  final int paidPiasters;
  final String? supplierId;

  /// Null for a purchase with no supplier.
  final String? supplierName;
  final String? supplierRef;
  final bool voided;

  int get remainingPiasters => totalPiasters - paidPiasters;

  PurchaseKind get kind => paidPiasters == totalPiasters
      ? PurchaseKind.cash
      : paidPiasters == 0
      ? PurchaseKind.credit
      : PurchaseKind.partial;

  @override
  List<Object?> get props => [
    id,
    number,
    invoiceDate,
    at,
    totalPiasters,
    paidPiasters,
    supplierId,
    supplierName,
    supplierRef,
    voided,
  ];
}

/// One line of a saved purchase, as it was at the time of purchase.
final class PurchaseItem extends Equatable {
  const PurchaseItem({
    required this.lineNo,
    required this.productId,
    required this.name,
    required this.unit,
    required this.qtyMilli,
    required this.unitCostPiasters,
    required this.lineDiscountPiasters,
    required this.lineTotalPiasters,
  });

  final int lineNo;
  final String productId;
  final String name;

  /// The product's current unit; it cannot change once it has stock
  /// movements (research R1).
  final UnitType unit;
  final int qtyMilli;
  final int unitCostPiasters;
  final int lineDiscountPiasters;
  final int lineTotalPiasters;

  @override
  List<Object?> get props => [
    lineNo,
    productId,
    name,
    unit,
    qtyMilli,
    unitCostPiasters,
    lineDiscountPiasters,
    lineTotalPiasters,
  ];
}

/// A saved purchase with its lines (FR-011).
final class Purchase extends Equatable {
  const Purchase({
    required this.summary,
    required this.subtotalPiasters,
    required this.invoiceDiscountPiasters,
    required this.method,
    this.parts = const [],
    required this.items,
    this.note,
    this.voidedAt,
    this.voidReason,
  });

  final PurchaseSummary summary;
  final int subtotalPiasters;
  final int invoiceDiscountPiasters;
  final PaymentMethod method;

  /// The payment's parts with their methods and account numbers (FR-039);
  /// empty for a record saved before 006 or with nothing paid.
  final List<PaymentPart> parts;
  final List<PurchaseItem> items;
  final String? note;
  final DateTime? voidedAt;
  final String? voidReason;

  @override
  List<Object?> get props => [
    summary,
    subtotalPiasters,
    invoiceDiscountPiasters,
    method,
    parts,
    items,
    note,
    voidedAt,
    voidReason,
  ];
}

/// The purchase list's search and filter (FR-010, research R16).
final class PurchaseQuery extends Equatable {
  const PurchaseQuery({
    this.text = '',
    this.unpaidOnly = false,
    this.supplierId,
  });

  final String text;

  /// Credit or partly paid, not voided.
  final bool unpaidOnly;

  /// Only this supplier's purchases (the supplier page).
  final String? supplierId;

  /// The number typed, when the text is a number with an optional `P-`.
  int? get number {
    var t = normalizeDigits(text.trim()).toUpperCase();
    if (t.startsWith('P-')) t = t.substring(2);
    if (t.isEmpty || !RegExp(r'^\d{1,12}$').hasMatch(t)) return null;
    return int.parse(t);
  }

  PurchaseQuery copyWith({String? text, bool? unpaidOnly}) => PurchaseQuery(
    text: text ?? this.text,
    unpaidOnly: unpaidOnly ?? this.unpaidOnly,
    supplierId: supplierId,
  );

  @override
  List<Object?> get props => [text, unpaidOnly, supplierId];
}

/// A saved purchase.
final class PurchaseSaved extends Equatable {
  const PurchaseSaved({required this.id, required this.number});

  final String id;
  final int number;

  @override
  List<Object?> get props => [id, number];
}
