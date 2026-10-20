import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/product_draft.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:flutter_test/flutter_test.dart';

Result<ProductDraft, List<ProductFieldError>> draft({
  String name = 'أرز مصري',
  UnitType unit = UnitType.piece,
  String price = '25',
  String barcode = '',
  String sku = '',
  String lowStock = '',
  String openingQty = '',
  String openingCost = '',
}) => ProductDraft.create(
  name: name,
  unit: unit,
  priceText: price,
  barcode: barcode,
  sku: sku,
  lowStockText: lowStock,
  openingQtyText: openingQty,
  openingCostText: openingCost,
);

ProductDraft ok(Result<ProductDraft, List<ProductFieldError>> r) =>
    (r as Ok<ProductDraft, List<ProductFieldError>>).value;

List<ProductFieldError> errs(Result<ProductDraft, List<ProductFieldError>> r) =>
    (r as Err<ProductDraft, List<ProductFieldError>>).error;

void main() {
  group('name', () {
    test('is trimmed', () {
      expect(ok(draft(name: '  شاي  ')).name, 'شاي');
    });

    test('empty or only spaces is required', () {
      expect(errs(draft(name: '')), [const NameRequired()]);
      expect(errs(draft(name: '   ')), [const NameRequired()]);
    });

    test('1 and 100 code points pass, 101 fails', () {
      expect(ok(draft(name: 'ا')).name, 'ا');
      expect(ok(draft(name: 'ب' * 100)).name.runes.length, 100);
      expect(errs(draft(name: 'ب' * 101)), [const NameTooLong(100)]);
    });

    test('counts emoji as one code point each', () {
      final name = '😀' * 100; // 200 UTF-16 units
      expect(ok(draft(name: name)).name, name);
      expect(errs(draft(name: '😀' * 101)), [const NameTooLong(100)]);
    });
  });

  group('sale price', () {
    test('is required', () {
      expect(errs(draft(price: ' ')), [const PriceRequired()]);
    });

    test('0 and the 10,000,000.00 limit pass', () {
      expect(ok(draft(price: '0')).salePricePiasters, 0);
      expect(
        ok(draft(price: '10,000,000.00')).salePricePiasters,
        maxPricePiasters,
      );
    });

    test('10,000,000.01 is too large', () {
      expect(errs(draft(price: '10000000.01')), [
        const PriceTooLarge(ProductField.price, maxPricePiasters),
      ]);
    });

    test('3 decimals, text and negatives are invalid', () {
      for (final bad in ['1.234', 'abc', '-5', '1,23']) {
        expect(errs(draft(price: bad)), [
          const PriceInvalid(ProductField.price),
        ], reason: bad);
      }
    });

    test('Arabic digits, the Arabic decimal point and grouping', () {
      expect(ok(draft(price: '٧٫٥٠')).salePricePiasters, 750);
      expect(ok(draft(price: '١٬٢٣٤٫٥')).salePricePiasters, 123450);
    });
  });

  group('quantities', () {
    test('a piece product rejects fractions', () {
      expect(errs(draft(openingQty: '1.5', openingCost: '1')), [
        const QuantityNotWhole(ProductField.openingQty),
      ]);
      expect(errs(draft(lowStock: '0.5')), [
        const QuantityNotWhole(ProductField.lowStock),
      ]);
    });

    test('a kg product takes 3 decimals and no more', () {
      final d = ok(
        draft(unit: UnitType.kg, openingQty: '2.375', openingCost: '40'),
      );
      expect(d.opening!.qtyMilli, 2375);
      expect(errs(draft(unit: UnitType.kg, lowStock: '2.3755')), [
        const QuantityInvalid(ProductField.lowStock),
      ]);
    });

    test('1,000,000 units is the limit', () {
      expect(ok(draft(lowStock: '1000000')).lowStockThresholdMilli, 1000000000);
      expect(errs(draft(lowStock: '1000001')), [
        const QuantityTooLarge(ProductField.lowStock, maxQuantityMilli),
      ]);
    });

    test('an empty low-stock level means none', () {
      expect(ok(draft()).lowStockThresholdMilli, isNull);
      expect(ok(draft(lowStock: '0')).lowStockThresholdMilli, 0);
    });
  });

  group('opening stock', () {
    test('12 pieces at 7.50 totals 90.00', () {
      final opening = ok(draft(openingQty: '12', openingCost: '7.50')).opening!;
      expect(opening.qtyMilli, 12000);
      expect(opening.unitCostPiasters, 750);
      expect(opening.totalPiasters, 9000);
    });

    test('the total rounds half up', () {
      // 0.333 kg × 0.10 = 0.0333 EGP → 3 piasters.
      final opening = ok(
        draft(unit: UnitType.kg, openingQty: '0.333', openingCost: '0.10'),
      ).opening!;
      expect(opening.totalPiasters, 3);
    });

    test('a quantity without a cost needs the cost', () {
      expect(errs(draft(openingQty: '3')), [const OpeningCostRequired()]);
    });

    test('empty or zero quantity means no opening; the cost is ignored', () {
      expect(ok(draft(openingCost: '5')).opening, isNull);
      expect(ok(draft(openingQty: '0', openingCost: 'x')).opening, isNull);
    });

    test('the cost follows the price rules', () {
      expect(errs(draft(openingQty: '1', openingCost: '1.999')), [
        const PriceInvalid(ProductField.openingCost),
      ]);
      expect(errs(draft(openingQty: '1', openingCost: '10000001')), [
        const PriceTooLarge(ProductField.openingCost, maxPricePiasters),
      ]);
    });
  });

  group('barcode and code', () {
    test('trimmed, digits folded to Latin, inner spaces kept', () {
      final d = ok(draft(barcode: '  ٦٢٢١٢٣٤٥٦٧٨٩٠ ', sku: ' A 12 '));
      expect(d.barcode, '6221234567890');
      expect(d.sku, 'A 12');
    });

    test('empty means none', () {
      final d = ok(draft(barcode: '   '));
      expect(d.barcode, isNull);
      expect(d.sku, isNull);
    });

    test('64 code points pass, 65 fail', () {
      expect(ok(draft(barcode: '1' * 64)).barcode, hasLength(64));
      expect(errs(draft(barcode: '1' * 65)), [const BarcodeTooLong(64)]);
      expect(errs(draft(sku: 'x' * 65)), [const SkuTooLong(64)]);
    });
  });

  test('collects every error at once', () {
    final errors = errs(
      draft(
        name: '',
        price: '',
        lowStock: '1.5',
        barcode: '1' * 65,
        openingQty: '2',
      ),
    );
    expect(errors, [
      const NameRequired(),
      const PriceRequired(),
      const QuantityNotWhole(ProductField.lowStock),
      const BarcodeTooLong(64),
      const OpeningCostRequired(),
    ]);
  });

  test('withoutOpening keeps every other field', () {
    final d = ok(
      draft(barcode: '123', lowStock: '4', openingQty: '1', openingCost: '2'),
    );
    final edit = d.withoutOpening();
    expect(edit.opening, isNull);
    expect(edit.barcode, '123');
    expect(edit.lowStockThresholdMilli, 4000);
  });
}
