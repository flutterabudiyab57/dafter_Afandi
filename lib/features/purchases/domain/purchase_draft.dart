import 'package:equatable/equatable.dart';

import '../../../core/utils/money.dart';
import '../../../core/utils/quantity.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/text_length.dart';
import '../../customers/domain/payment.dart';
import '../../payments/domain/payment_split.dart';
import '../../products/domain/product_errors.dart';
import 'purchase_errors.dart';

/// One product on an unsaved purchase (FR-002). Amounts are integers; the
/// screen parses the typed text.
final class PurchaseLine extends Equatable {
  const PurchaseLine({
    required this.productId,
    required this.name,
    required this.unit,
    required this.salePricePiasters,
    required this.qtyMilli,
    required this.unitCostPiasters,
    this.lineDiscountPiasters = 0,
  });

  final String productId;
  final String name;
  final UnitType unit;

  /// The product's selling price, for [costNotice] only.
  final int salePricePiasters;
  final int qtyMilli;
  final int unitCostPiasters;
  final int lineDiscountPiasters;

  /// Quantity × cost, rounded half up to the piaster (FR-004).
  int get gross => lineTotalPiasters(qtyMilli, unitCostPiasters);

  int get lineTotal => gross - lineDiscountPiasters;

  /// The line, after its discount, costs at least what the same quantity
  /// sells for (FR-002a, research R14). Compared on totals, so no per-unit
  /// rounding.
  bool get costNotice =>
      lineTotal >= lineTotalPiasters(qtyMilli, salePricePiasters);

  PurchaseLine copyWith({
    int? qtyMilli,
    int? unitCostPiasters,
    int? lineDiscountPiasters,
  }) => PurchaseLine(
    productId: productId,
    name: name,
    unit: unit,
    salePricePiasters: salePricePiasters,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
    lineDiscountPiasters: lineDiscountPiasters ?? this.lineDiscountPiasters,
  );

  @override
  List<Object?> get props => [
    productId,
    name,
    unit,
    salePricePiasters,
    qtyMilli,
    unitCostPiasters,
    lineDiscountPiasters,
  ];
}

/// The supplier picked for a purchase.
final class PurchaseSupplier extends Equatable {
  const PurchaseSupplier({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// An unsaved purchase (data-model.md). Immutable: every edit returns a new
/// draft.
final class PurchaseDraft extends Equatable {
  const PurchaseDraft({
    this.lines = const [],
    this.invoiceDiscountPiasters = 0,
    this.paidPiasters,
    this.payment = const [PaymentPartInput(method: PaymentMethod.cash)],
    this.supplier,
    this.supplierRef,
    this.invoiceDate,
    this.note,
  });

  final List<PurchaseLine> lines;
  final int invoiceDiscountPiasters;

  /// Paid now; null means the whole total (FR-006).
  final int? paidPiasters;

  /// How [paid] is paid, as typed: one part, or up to three (FR-036).
  final List<PaymentPartInput> payment;
  final PurchaseSupplier? supplier;

  /// The supplier's own invoice number, trimmed; null when not given.
  final String? supplierRef;

  /// The local calendar date on the supplier's invoice (year, month and day
  /// only); null means today (research R6).
  final DateTime? invoiceDate;
  final String? note;

  bool get isEmpty => lines.isEmpty;

  int get subtotal => lines.fold(0, (sum, l) => sum + l.lineTotal);

  int get total => subtotal - invoiceDiscountPiasters;

  int get paid => paidPiasters ?? (total < 0 ? 0 : total);

  int get remaining => total - paid;

  /// Part 1's method, kept on the invoice header.
  PaymentMethod get method => payment.first.method;

  /// [payment] read against [paid]; empty when nothing is paid. Only
  /// meaningful when [validate] is empty.
  PaymentSplit get split =>
      switch (PaymentSplit.create(totalPiasters: paid, inputs: payment)) {
        Ok(:final value) => value,
        Err() => PaymentSplit.none,
      };

  /// Each line's share of the invoice discount; they add up to it exactly
  /// (FR-004). Only meaningful when [validate] is empty.
  List<int> get shares => allocateLargestRemainder(invoiceDiscountPiasters, [
    for (final l in lines) l.lineTotal < 0 ? 0 : l.lineTotal,
  ]);

  /// What each line adds to its product's average cost: its total after
  /// its share of the invoice discount (research R5).
  List<int> get netLineCosts {
    final s = shares;
    return [for (var i = 0; i < lines.length; i++) lines[i].lineTotal - s[i]];
  }

  PurchaseLine? lineOf(String productId) {
    for (final l in lines) {
      if (l.productId == productId) return l;
    }
    return null;
  }

  /// Adds one unit of a product at [unitCostPiasters], or one more unit when
  /// it is already on the purchase.
  PurchaseDraft add({
    required String productId,
    required String name,
    required UnitType unit,
    required int salePricePiasters,
    required int unitCostPiasters,
  }) {
    final existing = lineOf(productId);
    if (existing != null) {
      return updateLine(productId, qtyMilli: existing.qtyMilli + milliPerUnit);
    }
    return _with(
      lines: [
        ...lines,
        PurchaseLine(
          productId: productId,
          name: name,
          unit: unit,
          salePricePiasters: salePricePiasters,
          qtyMilli: milliPerUnit,
          unitCostPiasters: unitCostPiasters,
        ),
      ],
    );
  }

  PurchaseDraft updateLine(
    String productId, {
    int? qtyMilli,
    int? unitCostPiasters,
    int? lineDiscountPiasters,
  }) => _with(
    lines: [
      for (final l in lines)
        l.productId == productId
            ? l.copyWith(
                qtyMilli: qtyMilli,
                unitCostPiasters: unitCostPiasters,
                lineDiscountPiasters: lineDiscountPiasters,
              )
            : l,
    ],
  );

  PurchaseDraft remove(String productId) =>
      _with(lines: [...lines.where((l) => l.productId != productId)]);

  PurchaseDraft withInvoiceDiscount(int piasters) =>
      _with(invoiceDiscountPiasters: piasters);

  /// [piasters] null pays the whole total.
  PurchaseDraft withPaid(int? piasters) => _copy(paidPiasters: () => piasters);

  /// One part in [method] that takes the whole amount paid.
  PurchaseDraft withMethod(PaymentMethod method) =>
      withPayment([PaymentPartInput(method: method)]);

  PurchaseDraft withPayment(List<PaymentPartInput> payment) =>
      _with(payment: payment);

  PurchaseDraft withSupplier(PurchaseSupplier? supplier) =>
      _copy(supplier: () => supplier);

  /// Trimmed; empty clears it.
  PurchaseDraft withSupplierRef(String ref) {
    final t = ref.trim();
    return _copy(supplierRef: () => t.isEmpty ? null : t);
  }

  /// Keeps the calendar date only; null means today.
  PurchaseDraft withInvoiceDate(DateTime? date) => _copy(
    invoiceDate: () =>
        date == null ? null : DateTime(date.year, date.month, date.day),
  );

  /// Trimmed; empty clears it.
  PurchaseDraft withNote(String note) {
    final t = note.trim();
    return _copy(note: () => t.isEmpty ? null : t);
  }

  PurchaseDraft _with({
    List<PurchaseLine>? lines,
    int? invoiceDiscountPiasters,
    List<PaymentPartInput>? payment,
  }) => PurchaseDraft(
    lines: lines ?? this.lines,
    invoiceDiscountPiasters:
        invoiceDiscountPiasters ?? this.invoiceDiscountPiasters,
    paidPiasters: paidPiasters,
    payment: payment ?? this.payment,
    supplier: supplier,
    supplierRef: supplierRef,
    invoiceDate: invoiceDate,
    note: note,
  );

  /// Replaces nullable fields; a missing argument keeps the current value.
  PurchaseDraft _copy({
    int? Function()? paidPiasters,
    PurchaseSupplier? Function()? supplier,
    String? Function()? supplierRef,
    DateTime? Function()? invoiceDate,
    String? Function()? note,
  }) => PurchaseDraft(
    lines: lines,
    invoiceDiscountPiasters: invoiceDiscountPiasters,
    paidPiasters: paidPiasters != null ? paidPiasters() : this.paidPiasters,
    payment: payment,
    supplier: supplier != null ? supplier() : this.supplier,
    supplierRef: supplierRef != null ? supplierRef() : this.supplierRef,
    invoiceDate: invoiceDate != null ? invoiceDate() : this.invoiceDate,
    note: note != null ? note() : this.note,
  );

  /// Every rule of FR-002 and FR-004 to FR-006; empty when the purchase can
  /// be saved. [today] is the local date, from the injected clock.
  List<PurchaseError> validate({required DateTime today}) {
    final errors = <PurchaseError>[];
    if (lines.isEmpty) errors.add(const PurchaseNoLines());
    final seen = <String>{};
    for (final l in lines) {
      if (!seen.add(l.productId)) {
        errors.add(PurchaseDuplicateLine(l.productId));
      }
      final wholeOk = l.unit.allowsFraction || l.qtyMilli % milliPerUnit == 0;
      if (l.qtyMilli <= 0 || l.qtyMilli > maxQuantityMilli || !wholeOk) {
        errors.add(PurchaseQuantityInvalid(l.productId));
      }
      if (l.unitCostPiasters < 0 || l.unitCostPiasters > maxPricePiasters) {
        errors.add(PurchaseCostInvalid(l.productId));
      }
      if (l.lineDiscountPiasters < 0 || l.lineDiscountPiasters > l.gross) {
        errors.add(PurchaseLineDiscountTooLarge(l.productId));
      }
    }
    if (invoiceDiscountPiasters < 0 || invoiceDiscountPiasters > subtotal) {
      errors.add(const PurchaseInvoiceDiscountTooLarge());
    }
    final p = paid;
    if (p < 0 || p > total) errors.add(const PurchasePaidTooLarge());
    if (p < total && supplier == null) errors.add(const CreditNeedsSupplier());
    if (p > 0 && p <= total) {
      if (PaymentSplit.create(totalPiasters: p, inputs: payment) case Err(
        :final error,
      )) {
        errors.add(PurchasePaymentInvalid(error));
      }
    }
    final date = invoiceDate;
    if (date != null &&
        date.isAfter(DateTime(today.year, today.month, today.day))) {
      errors.add(const PurchaseDateInFuture());
    }
    final ref = supplierRef;
    if (ref != null && codePointLength(ref) > maxSupplierRefLength) {
      errors.add(const SupplierRefTooLong());
    }
    final n = note;
    if (n != null && codePointLength(n) > maxPurchaseNoteLength) {
      errors.add(const PurchaseNoteTooLong());
    }
    return errors;
  }

  @override
  List<Object?> get props => [
    lines,
    invoiceDiscountPiasters,
    paidPiasters,
    payment,
    supplier,
    supplierRef,
    invoiceDate,
    note,
  ];
}
