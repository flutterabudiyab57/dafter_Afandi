import 'package:equatable/equatable.dart';

import '../../../core/utils/digits.dart';
import '../../../core/utils/quantity.dart';
import '../../customers/domain/payment.dart';

/// How a sale was paid, derived from its amounts (report §3.1).
enum SaleKind { cash, partial, credit }

/// One row of the invoice list (FR-009).
final class SaleSummary extends Equatable {
  const SaleSummary({
    required this.id,
    required this.number,
    required this.at,
    required this.totalPiasters,
    required this.paidPiasters,
    this.customerId,
    this.customerName,
    this.voided = false,
  });

  final String id;
  final int number;

  /// UTC.
  final DateTime at;
  final int totalPiasters;
  final int paidPiasters;
  final String? customerId;

  /// Null for a walk-in sale.
  final String? customerName;
  final bool voided;

  int get remainingPiasters => totalPiasters - paidPiasters;

  SaleKind get kind => paidPiasters == totalPiasters
      ? SaleKind.cash
      : paidPiasters == 0
      ? SaleKind.credit
      : SaleKind.partial;

  @override
  List<Object?> get props => [
    id,
    number,
    at,
    totalPiasters,
    paidPiasters,
    customerId,
    customerName,
    voided,
  ];
}

/// One line of a saved invoice, as it was at the time of sale.
final class SaleItem extends Equatable {
  const SaleItem({
    required this.lineNo,
    required this.productId,
    required this.name,
    required this.unit,
    required this.qtyMilli,
    required this.unitPricePiasters,
    required this.lineDiscountPiasters,
    required this.lineTotalPiasters,
  });

  final int lineNo;
  final String productId;
  final String name;
  final UnitType unit;
  final int qtyMilli;
  final int unitPricePiasters;
  final int lineDiscountPiasters;
  final int lineTotalPiasters;

  @override
  List<Object?> get props => [
    lineNo,
    productId,
    name,
    unit,
    qtyMilli,
    unitPricePiasters,
    lineDiscountPiasters,
    lineTotalPiasters,
  ];
}

/// A saved invoice with its lines (FR-010).
final class SaleInvoice extends Equatable {
  const SaleInvoice({
    required this.summary,
    required this.subtotalPiasters,
    required this.invoiceDiscountPiasters,
    required this.method,
    required this.items,
    this.note,
    this.voidedAt,
    this.voidReason,
  });

  final SaleSummary summary;
  final int subtotalPiasters;
  final int invoiceDiscountPiasters;
  final PaymentMethod method;
  final List<SaleItem> items;
  final String? note;
  final DateTime? voidedAt;
  final String? voidReason;

  @override
  List<Object?> get props => [
    summary,
    subtotalPiasters,
    invoiceDiscountPiasters,
    method,
    items,
    note,
    voidedAt,
    voidReason,
  ];
}

/// The invoice list's search and filter (FR-009, research R16).
final class SaleQuery extends Equatable {
  const SaleQuery({this.text = '', this.unpaidOnly = false, this.customerId});

  final String text;

  /// Credit or partly paid, not voided.
  final bool unpaidOnly;

  /// Only this customer's invoices (the customer page).
  final String? customerId;

  /// The number typed, when the text is a number with an optional `S-`.
  int? get number {
    var t = normalizeDigits(text.trim()).toUpperCase();
    if (t.startsWith('S-')) t = t.substring(2);
    if (t.isEmpty || !RegExp(r'^\d{1,12}$').hasMatch(t)) return null;
    return int.parse(t);
  }

  SaleQuery copyWith({String? text, bool? unpaidOnly}) => SaleQuery(
    text: text ?? this.text,
    unpaidOnly: unpaidOnly ?? this.unpaidOnly,
    customerId: customerId,
  );

  @override
  List<Object?> get props => [text, unpaidOnly, customerId];
}

/// A saved sale.
final class SaleSaved extends Equatable {
  const SaleSaved({required this.id, required this.number});

  final String id;
  final int number;

  @override
  List<Object?> get props => [id, number];
}
