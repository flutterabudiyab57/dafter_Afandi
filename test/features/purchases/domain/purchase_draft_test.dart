import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_errors.dart';
import 'package:flutter_test/flutter_test.dart';

final today = DateTime(2026, 10, 21, 15, 30);

const nour = PurchaseSupplier(id: 's1', name: 'شركة النور');

PurchaseDraft withTea({int cost = 1100, int salePrice = 1250}) =>
    const PurchaseDraft().add(
      productId: 'tea',
      name: 'شاي',
      unit: UnitType.piece,
      salePricePiasters: salePrice,
      unitCostPiasters: cost,
    );

PurchaseDraft withCoffee(PurchaseDraft d, {int cost = 30000}) => d.add(
  productId: 'coffee',
  name: 'بن',
  unit: UnitType.kg,
  salePricePiasters: 40000,
  unitCostPiasters: cost,
);

void main() {
  test('adding the same product raises its quantity by one unit', () {
    final d = withTea().add(
      productId: 'tea',
      name: 'شاي',
      unit: UnitType.piece,
      salePricePiasters: 1250,
      unitCostPiasters: 999,
    );
    expect(d.lines, hasLength(1));
    // The cost of the existing line is kept.
    expect(d.lines.single.qtyMilli, 2000);
    expect(d.lines.single.unitCostPiasters, 1100);
    expect(d.total, 2200);
    expect(d.validate(today: today), isEmpty);
  });

  test('10 × 11.00 for cash', () {
    final d = withTea().updateLine('tea', qtyMilli: 10000);
    expect(d.subtotal, 11000);
    expect(d.total, 11000);
    expect(d.paid, 11000);
    expect(d.remaining, 0);
    expect(d.netLineCosts, [11000]);
    expect(d.validate(today: today), isEmpty);
  });

  test('2.500 kg at 30.00 is 75.00; quantities round half up', () {
    final d = withCoffee(
      const PurchaseDraft(),
      cost: 3000,
    ).updateLine('coffee', qtyMilli: 2500);
    expect(d.lines.single.lineTotal, 7500);
    // 0.333 kg × 10.01 = 3.33333 → 3.33; 0.335 × 10.01 = 3.35335 → 3.35.
    final r = withCoffee(
      const PurchaseDraft(),
      cost: 1001,
    ).updateLine('coffee', qtyMilli: 333);
    expect(r.lines.single.gross, 333);
    expect(r.updateLine('coffee', qtyMilli: 335).lines.single.gross, 335);
    // Exactly half a piaster rounds up: 0.500 kg × 0.01 = 0.005 → 0.01.
    final half = withCoffee(
      const PurchaseDraft(),
      cost: 1,
    ).updateLine('coffee', qtyMilli: 500);
    expect(half.lines.single.gross, 1);
  });

  test('the invoice discount is shared so the shares add up exactly', () {
    // Lines of 100.00 and 300.00, discount 40.00 → 10.00 and 30.00.
    var d = withCoffee(
      withTea(cost: 10000),
      cost: 30000,
    ).updateLine('coffee', qtyMilli: 1000).withInvoiceDiscount(4000);
    expect(d.subtotal, 40000);
    expect(d.total, 36000);
    expect(d.shares, [1000, 3000]);
    expect(d.netLineCosts, [9000, 27000]);

    // An odd discount: 0.01 goes to the larger remainder.
    d = d.withInvoiceDiscount(1);
    expect(d.shares.fold<int>(0, (a, b) => a + b), 1);
    expect(d.netLineCosts.fold<int>(0, (a, b) => a + b), d.total);
  });

  test('line and invoice discount limits', () {
    final d = withTea(cost: 1000).updateLine('tea', qtyMilli: 3000);
    expect(
      d.updateLine('tea', lineDiscountPiasters: 3000).validate(today: today),
      isEmpty,
    );
    expect(
      d.updateLine('tea', lineDiscountPiasters: 3001).validate(today: today),
      contains(const PurchaseLineDiscountTooLarge('tea')),
    );
    expect(d.withInvoiceDiscount(3000).validate(today: today), isEmpty);
    expect(
      d.withInvoiceDiscount(3001).validate(today: today),
      contains(const PurchaseInvoiceDiscountTooLarge()),
    );
  });

  test('quantity: above 0, at most 1,000,000 units, whole for a piece', () {
    final d = withTea();
    for (final bad in [0, -1000, 1000000001, 1500]) {
      expect(
        d.updateLine('tea', qtyMilli: bad).validate(today: today),
        contains(const PurchaseQuantityInvalid('tea')),
        reason: '$bad',
      );
    }
    expect(
      d.updateLine('tea', qtyMilli: 1000000000).validate(today: today),
      isEmpty,
    );
    final kg = withCoffee(const PurchaseDraft())
        .updateLine('coffee', qtyMilli: 1500);
    expect(kg.validate(today: today), isEmpty);
  });

  test('cost: 0 to 10,000,000 EGP', () {
    final d = withTea();
    expect(
      d.updateLine('tea', unitCostPiasters: 0).validate(today: today),
      isEmpty,
    );
    expect(
      d.updateLine('tea', unitCostPiasters: 1000000000).validate(today: today),
      isEmpty,
    );
    for (final bad in [-1, 1000000001]) {
      expect(
        d.updateLine('tea', unitCostPiasters: bad).validate(today: today),
        contains(const PurchaseCostInvalid('tea')),
      );
    }
  });

  test('no lines blocks saving', () {
    expect(
      const PurchaseDraft().validate(today: today),
      contains(const PurchaseNoLines()),
    );
  });

  test('credit or partial needs a supplier; paid cannot exceed the total', () {
    final d = withTea().updateLine('tea', qtyMilli: 10000).withPaid(4000);
    expect(d.remaining, 7000);
    expect(d.validate(today: today), [const CreditNeedsSupplier()]);
    expect(d.withSupplier(nour).validate(today: today), isEmpty);
    expect(d.withSupplier(nour).withPaid(0).validate(today: today), isEmpty);
    expect(
      d.withSupplier(nour).withPaid(11001).validate(today: today),
      contains(const PurchasePaidTooLarge()),
    );
    // Back to "pay all".
    expect(d.withPaid(null).validate(today: today), isEmpty);
  });

  test('the invoice date: today or earlier, never later', () {
    final d = withTea();
    expect(d.invoiceDate, isNull);
    expect(
      d.withInvoiceDate(DateTime(2026, 10, 21, 23, 59)).invoiceDate,
      DateTime(2026, 10, 21),
    );
    expect(
      d.withInvoiceDate(DateTime(2026, 10, 21)).validate(today: today),
      isEmpty,
    );
    expect(
      d.withInvoiceDate(DateTime(2025, 1, 1)).validate(today: today),
      isEmpty,
    );
    expect(d.withInvoiceDate(DateTime(2026, 10, 22)).validate(today: today), [
      const PurchaseDateInFuture(),
    ]);
    expect(d.withInvoiceDate(null).invoiceDate, isNull);
  });

  test("the supplier's invoice number: trimmed, at most 50", () {
    final d = withTea();
    expect(d.withSupplierRef('  INV-77 ').supplierRef, 'INV-77');
    expect(d.withSupplierRef('   ').supplierRef, isNull);
    expect(d.withSupplierRef('ف' * 50).validate(today: today), isEmpty);
    expect(d.withSupplierRef('ف' * 51).validate(today: today), [
      const SupplierRefTooLong(),
    ]);
  });

  test('the note: trimmed, at most 200', () {
    final d = withTea();
    expect(d.withNote('  ok ').note, 'ok');
    expect(d.withNote('').note, isNull);
    expect(d.withNote('x' * 200).validate(today: today), isEmpty);
    expect(d.withNote('x' * 201).validate(today: today), [
      const PurchaseNoteTooLong(),
    ]);
  });

  test('editing one field keeps the others', () {
    final d = withTea()
        .withSupplier(nour)
        .withSupplierRef('A1')
        .withInvoiceDate(DateTime(2026, 10, 1))
        .withNote('n')
        .withPaid(0)
        .withMethod(PaymentMethod.instapay);
    final e = d.withInvoiceDiscount(100).updateLine('tea', qtyMilli: 2000);
    expect(e.supplier, nour);
    expect(e.supplierRef, 'A1');
    expect(e.invoiceDate, DateTime(2026, 10, 1));
    expect(e.note, 'n');
    expect(e.paidPiasters, 0);
    expect(e.method, PaymentMethod.instapay);
    expect(e.withSupplier(null).supplier, isNull);
    expect(e.withSupplier(null).supplierRef, 'A1');
  });

  group('cost notice (FR-002a)', () {
    test('shows at and above the selling price, not below', () {
      // Sells at 12.50.
      expect(withTea(cost: 1249).lines.single.costNotice, isFalse);
      expect(withTea(cost: 1250).lines.single.costNotice, isTrue);
      expect(withTea(cost: 1300).lines.single.costNotice, isTrue);
    });

    test('uses the line after its discount, on totals', () {
      // 3 at 13.00 = 39.00, less 2.00 = 37.00, against 3 × 12.50 = 37.50.
      final d = withTea(cost: 1300)
          .updateLine('tea', qtyMilli: 3000, lineDiscountPiasters: 200);
      expect(d.lines.single.costNotice, isFalse);
      expect(
        d.updateLine('tea', lineDiscountPiasters: 150).lines.single.costNotice,
        isTrue,
      );
    });

    test('ignores the invoice discount', () {
      final d = withTea(cost: 1300).withInvoiceDiscount(1300);
      expect(d.lines.single.costNotice, isTrue);
    });

    test('a free item with a selling price of 0 still shows it', () {
      expect(withTea(cost: 0, salePrice: 0).lines.single.costNotice, isTrue);
    });
  });

  group('PurchaseQuery.number', () {
    test('reads a number with or without P- in any digit set', () {
      expect(const PurchaseQuery(text: '12').number, 12);
      expect(const PurchaseQuery(text: ' p-000012 ').number, 12);
      expect(const PurchaseQuery(text: '١٢').number, 12);
      expect(const PurchaseQuery(text: 'النور').number, isNull);
      expect(const PurchaseQuery(text: 'S-1').number, isNull);
    });
  });

  test('kind from the amounts', () {
    PurchaseSummary s(int paid) => PurchaseSummary(
      id: 'p',
      number: 1,
      invoiceDate: DateTime(2026, 10, 21),
      at: DateTime.utc(2026, 10, 21),
      totalPiasters: 1000,
      paidPiasters: paid,
    );
    expect(s(1000).kind, PurchaseKind.cash);
    expect(s(400).kind, PurchaseKind.partial);
    expect(s(0).kind, PurchaseKind.credit);
    expect(s(400).remainingPiasters, 600);
  });
}
