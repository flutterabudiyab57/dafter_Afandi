import 'package:daftar_afandi/core/utils/doc_number.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:flutter_test/flutter_test.dart';

SaleDraft withTea({int price = 1250}) => const SaleDraft().add(
  productId: 'tea',
  name: 'شاي',
  unit: UnitType.piece,
  unitPricePiasters: price,
);

void main() {
  test('adding the same product raises its quantity by one unit', () {
    final d = withTea().add(
      productId: 'tea',
      name: 'شاي',
      unit: UnitType.piece,
      unitPricePiasters: 1250,
    );
    expect(d.lines, hasLength(1));
    expect(d.lines.single.qtyMilli, 2000);
    expect(d.total, 2500);
    expect(d.paid, 2500);
    expect(d.validate(), isEmpty);
  });

  test('3 × 10.00, line discount 2.00, invoice discount 3.00', () {
    final d = withTea(price: 1000)
        .updateLine('tea', qtyMilli: 3000, lineDiscountPiasters: 200)
        .withInvoiceDiscount(300);
    expect(d.lines.single.lineTotal, 2800);
    expect(d.subtotal, 2800);
    expect(d.total, 2500);
    expect(d.shares, [300]);
    expect(d.validate(), isEmpty);
  });

  test('0.750 kg at 40.00 is 30.00; half up rounding', () {
    var d = const SaleDraft().add(
      productId: 'flour',
      name: 'دقيق',
      unit: UnitType.kg,
      unitPricePiasters: 4000,
    );
    d = d.updateLine('flour', qtyMilli: 750);
    expect(d.lines.single.lineTotal, 3000);
    // 0.333 kg × 0.15 = 0.04995 → 0.05
    d = d.updateLine('flour', qtyMilli: 333, unitPricePiasters: 15);
    expect(d.lines.single.gross, 5);
  });

  test('the invoice discount is shared exactly over the lines', () {
    var d = withTea(price: 100);
    for (final id in ['a', 'b']) {
      d = d.add(
        productId: id,
        name: id,
        unit: UnitType.piece,
        unitPricePiasters: 100,
      );
    }
    d = d.withInvoiceDiscount(100);
    expect(d.shares.fold(0, (s, x) => s + x), 100);
    expect(d.shares, [34, 33, 33]);
  });

  test('limits: discounts, paid, quantity, price', () {
    final d = withTea(price: 1000);
    expect(
      d.updateLine('tea', lineDiscountPiasters: 1001).validate(),
      contains(const LineDiscountTooLarge('tea')),
    );
    expect(
      d.withInvoiceDiscount(1001).validate(),
      contains(const InvoiceDiscountTooLarge()),
    );
    expect(d.withPaid(1001).validate(), contains(const PaidTooLarge()));
    expect(
      d.updateLine('tea', qtyMilli: 1500).validate(),
      contains(const LineQuantityInvalid('tea')),
    );
    expect(
      d.updateLine('tea', qtyMilli: 0).validate(),
      contains(const LineQuantityInvalid('tea')),
    );
    expect(
      d.updateLine('tea', unitPricePiasters: 1000000001).validate(),
      contains(const LinePriceInvalid('tea')),
    );
    expect(d.updateLine('tea', unitPricePiasters: 0).validate(), isEmpty);
  });

  test('no lines is blocked', () {
    expect(const SaleDraft().validate(), contains(const NoLines()));
  });

  test('credit or partial needs a named customer', () {
    final d = withTea(price: 10000).withPaid(4000);
    expect(d.remaining, 6000);
    expect(d.validate(), [const CreditNeedsCustomer()]);
    final named = d.withCustomer(const SaleCustomer(id: 'c', name: 'أحمد'));
    expect(named.validate(), isEmpty);
    expect(named.withPaid(null).paid, 10000);
    expect(named.withMethod(PaymentMethod.wallet).method, PaymentMethod.wallet);
  });

  test('remove takes the line off', () {
    expect(withTea().remove('tea').isEmpty, isTrue);
  });

  test('summary kind follows the amounts', () {
    SaleSummary s(int paid) => SaleSummary(
      id: 'x',
      number: 1,
      at: DateTime.utc(2026),
      totalPiasters: 100,
      paidPiasters: paid,
    );
    expect(s(100).kind, SaleKind.cash);
    expect(s(40).kind, SaleKind.partial);
    expect(s(0).kind, SaleKind.credit);
    expect(s(40).remainingPiasters, 60);
  });

  test('SaleQuery reads an invoice number in any digits or with S-', () {
    expect(const SaleQuery(text: '12').number, 12);
    expect(const SaleQuery(text: 's-000012').number, 12);
    expect(const SaleQuery(text: '١٢').number, 12);
    expect(const SaleQuery(text: 'أحمد').number, isNull);
    expect(const SaleQuery().number, isNull);
  });

  test('formatDocNumber pads to six digits', () {
    expect(formatDocNumber(saleNumberPrefix, 12), 'S-000012');
    expect(formatDocNumber(receiptNumberPrefix, 1), 'RC-000001');
    expect(formatDocNumber(saleNumberPrefix, 1234567), 'S-1234567');
  });
}
