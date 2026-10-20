import 'package:equatable/equatable.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/quantity.dart';
import '../../customers/domain/payment.dart';
import '../../products/domain/product_errors.dart';
import 'sale_errors.dart';

/// One product on an unsaved sale (FR-002). Amounts are integers; the
/// screen parses the typed text.
final class SaleLine extends Equatable {
  const SaleLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.qtyMilli,
    required this.unitPricePiasters,
    this.lineDiscountPiasters = 0,
  });

  final String productId;
  final String name;
  final UnitType unit;
  final int qtyMilli;
  final int unitPricePiasters;
  final int lineDiscountPiasters;

  /// Quantity × price, rounded half up to the piaster (FR-004).
  int get gross => lineTotalPiasters(qtyMilli, unitPricePiasters);

  int get lineTotal => gross - lineDiscountPiasters;

  SaleLine copyWith({
    int? qtyMilli,
    int? unitPricePiasters,
    int? lineDiscountPiasters,
  }) => SaleLine(
    productId: productId,
    name: name,
    unit: unit,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    unitPricePiasters: unitPricePiasters ?? this.unitPricePiasters,
    lineDiscountPiasters: lineDiscountPiasters ?? this.lineDiscountPiasters,
  );

  @override
  List<Object?> get props => [
    productId,
    name,
    unit,
    qtyMilli,
    unitPricePiasters,
    lineDiscountPiasters,
  ];
}

/// The customer picked for a sale.
final class SaleCustomer extends Equatable {
  const SaleCustomer({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// An unsaved sale (data-model.md). Immutable: every edit returns a new
/// draft.
final class SaleDraft extends Equatable {
  const SaleDraft({
    this.lines = const [],
    this.invoiceDiscountPiasters = 0,
    this.paidPiasters,
    this.method = PaymentMethod.cash,
    this.customer,
    this.note,
  });

  final List<SaleLine> lines;
  final int invoiceDiscountPiasters;

  /// Paid now; null means the whole total (FR-005).
  final int? paidPiasters;
  final PaymentMethod method;
  final SaleCustomer? customer;
  final String? note;

  bool get isEmpty => lines.isEmpty;

  int get subtotal => lines.fold(0, (sum, l) => sum + l.lineTotal);

  int get total => subtotal - invoiceDiscountPiasters;

  int get paid => paidPiasters ?? (total < 0 ? 0 : total);

  int get remaining => total - paid;

  /// Each line's share of the invoice discount; they add up to it exactly
  /// (FR-004). Only meaningful when [validate] is empty.
  List<int> get shares => allocateLargestRemainder(invoiceDiscountPiasters, [
    for (final l in lines) l.lineTotal < 0 ? 0 : l.lineTotal,
  ]);

  SaleLine? lineOf(String productId) {
    for (final l in lines) {
      if (l.productId == productId) return l;
    }
    return null;
  }

  /// Adds one unit of a product, or one more unit when it is already on the
  /// sale (research R6).
  SaleDraft add({
    required String productId,
    required String name,
    required UnitType unit,
    required int unitPricePiasters,
  }) {
    final existing = lineOf(productId);
    if (existing != null) {
      return updateLine(productId, qtyMilli: existing.qtyMilli + milliPerUnit);
    }
    return _with(
      lines: [
        ...lines,
        SaleLine(
          productId: productId,
          name: name,
          unit: unit,
          qtyMilli: milliPerUnit,
          unitPricePiasters: unitPricePiasters,
        ),
      ],
    );
  }

  SaleDraft updateLine(
    String productId, {
    int? qtyMilli,
    int? unitPricePiasters,
    int? lineDiscountPiasters,
  }) => _with(
    lines: [
      for (final l in lines)
        l.productId == productId
            ? l.copyWith(
                qtyMilli: qtyMilli,
                unitPricePiasters: unitPricePiasters,
                lineDiscountPiasters: lineDiscountPiasters,
              )
            : l,
    ],
  );

  SaleDraft remove(String productId) =>
      _with(lines: [...lines.where((l) => l.productId != productId)]);

  SaleDraft withInvoiceDiscount(int piasters) =>
      _with(invoiceDiscountPiasters: piasters);

  /// [piasters] null pays the whole total.
  SaleDraft withPaid(int? piasters) => SaleDraft(
    lines: lines,
    invoiceDiscountPiasters: invoiceDiscountPiasters,
    paidPiasters: piasters,
    method: method,
    customer: customer,
    note: note,
  );

  SaleDraft withMethod(PaymentMethod method) => _with(method: method);

  SaleDraft withCustomer(SaleCustomer? customer) => SaleDraft(
    lines: lines,
    invoiceDiscountPiasters: invoiceDiscountPiasters,
    paidPiasters: paidPiasters,
    method: method,
    customer: customer,
    note: note,
  );

  SaleDraft withNote(String? note) => SaleDraft(
    lines: lines,
    invoiceDiscountPiasters: invoiceDiscountPiasters,
    paidPiasters: paidPiasters,
    method: method,
    customer: customer,
    note: note,
  );

  SaleDraft _with({
    List<SaleLine>? lines,
    int? invoiceDiscountPiasters,
    PaymentMethod? method,
  }) => SaleDraft(
    lines: lines ?? this.lines,
    invoiceDiscountPiasters:
        invoiceDiscountPiasters ?? this.invoiceDiscountPiasters,
    paidPiasters: paidPiasters,
    method: method ?? this.method,
    customer: customer,
    note: note,
  );

  /// Every rule of FR-002, FR-004 and FR-005; empty when the sale can be
  /// saved.
  List<SaleError> validate() {
    final errors = <SaleError>[];
    if (lines.isEmpty) errors.add(const NoLines());
    final seen = <String>{};
    for (final l in lines) {
      if (!seen.add(l.productId)) errors.add(DuplicateLine(l.productId));
      final wholeOk = l.unit.allowsFraction || l.qtyMilli % milliPerUnit == 0;
      if (l.qtyMilli <= 0 || l.qtyMilli > maxQuantityMilli || !wholeOk) {
        errors.add(LineQuantityInvalid(l.productId));
      }
      if (l.unitPricePiasters < 0 || l.unitPricePiasters > maxPricePiasters) {
        errors.add(LinePriceInvalid(l.productId));
      }
      if (l.lineDiscountPiasters < 0 || l.lineDiscountPiasters > l.gross) {
        errors.add(LineDiscountTooLarge(l.productId));
      }
    }
    if (invoiceDiscountPiasters < 0 || invoiceDiscountPiasters > subtotal) {
      errors.add(const InvoiceDiscountTooLarge());
    }
    final p = paid;
    if (p < 0 || p > total) errors.add(const PaidTooLarge());
    if (p < total && customer == null) errors.add(const CreditNeedsCustomer());
    return errors;
  }

  @override
  List<Object?> get props => [
    lines,
    invoiceDiscountPiasters,
    paidPiasters,
    method,
    customer,
    note,
  ];
}
