import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'products_env.dart';

void main() {
  late ProductsEnv env;

  setUp(() => env = ProductsEnv());
  tearDown(() => env.dispose());

  Future<List<String>> names([ProductQuery q = const ProductQuery()]) async => [
    for (final s in await env.list(q)) s.product.name,
  ];

  group('search (FR-009, research R4)', () {
    setUp(() async {
      await env.addProduct('أرز مصري', barcode: '6221234567890', sku: 'R-01');
      await env.addProduct('مكرونة', sku: 'PAS-9');
      await env.addProduct('شاي العروسة', barcode: '1234');
    });

    test('ignores hamza, taa marbuta, diacritics and tatweel', () async {
      expect(await names(const ProductQuery(text: 'ارز')), ['أرز مصري']);
      expect(await names(const ProductQuery(text: 'العروسه')), ['شاي العروسة']);
      expect(await names(const ProductQuery(text: 'مـكـرُونة')), ['مكرونة']);
    });

    test('matches part of the code, ignoring case', () async {
      expect(await names(const ProductQuery(text: 'pas')), ['مكرونة']);
    });

    test('an Arabic-digit barcode finds the Latin one', () async {
      expect(await names(const ProductQuery(text: '٦٢٢١٢٣٤٥٦٧٨٩٠')), [
        'أرز مصري',
      ]);
    });

    test('an exact barcode match is listed first', () async {
      // "1234" is inside both barcodes; only one is an exact match.
      expect(await names(const ProductQuery(text: '1234')), [
        'شاي العروسة',
        'أرز مصري',
      ]);
    });

    test('an empty search lists everything', () async {
      expect(await names(const ProductQuery(text: '   ')), hasLength(3));
    });
  });

  group('order (clarification Q3, research R5)', () {
    test('Arabic alphabetical, Latin and digits after Arabic', () async {
      for (final name in ['Zeta', 'تفاح', '7up', 'باذنجان', 'أرز', 'apple']) {
        await env.addProduct(name);
      }
      expect(await names(), ['أرز', 'باذنجان', 'تفاح', '7up', 'apple', 'Zeta']);
    });

    test(
      'spelling variants sort together; ء sorts before ا (known, K2)',
      () async {
        for (final name in ['ايس كريم', 'إبرة', 'ءاخر', 'آلة']) {
          await env.addProduct(name);
        }
        expect(await names(), ['ءاخر', 'إبرة', 'آلة', 'ايس كريم']);
      },
    );

    test('filters keep the order', () async {
      final drinks = okValue(await env.categories.create('مشروبات'));
      for (final name in ['عصير', 'بيبسي', 'Cola']) {
        await env.addProduct(name, categoryId: drinks.id);
      }
      await env.addProduct('أرز');
      expect(await names(ProductQuery(categoryFilter: InCategory(drinks.id))), [
        'بيبسي',
        'عصير',
        'Cola',
      ]);
    });
  });

  group('low stock (FR-008, research R6)', () {
    setUp(() async {
      await env.addProduct(
        'at level',
        lowStock: '5',
        openingQty: '5',
        openingCost: '1',
      );
      await env.addProduct(
        'below level',
        lowStock: '5',
        openingQty: '3',
        openingCost: '1',
      );
      await env.addProduct(
        'above level',
        lowStock: '5',
        openingQty: '6',
        openingCost: '1',
      );
      await env.addProduct('no level', openingQty: '1', openingCost: '1');
      await env.addProduct('zero level', lowStock: '0');
    });

    test('the filter includes at-level, below-level and zero-level', () async {
      final low = await env.list(const ProductQuery(lowOnly: true));
      expect(low.map((s) => s.product.name).toSet(), {
        'at level',
        'below level',
        'zero level',
      });
      expect(low.every((s) => s.isLow), isTrue);
    });

    test('below zero counts as low without a level', () async {
      final id = await env.addProduct('negative');
      // Stock below zero arrives with sales; write the movement directly.
      await env.db.customStatement(
        'INSERT INTO stock_movements (id, product_id, movement_type, '
        "qty_delta_milli, unit_cost_piasters, adjustment_reason, created_at) "
        "VALUES ('neg', '$id', 'ADJUSTMENT', -2000, 0, 'other', 1)",
      );
      final s = await env.summary(id);
      expect(s.isBelowZero, isTrue);
      expect(s.isLow, isTrue);
      expect(
        (await env.list(const ProductQuery(lowOnly: true)))
            .map((s) => s.product.name),
        contains('negative'),
      );
    });

    test('combines with search', () async {
      expect(await names(const ProductQuery(text: 'level', lowOnly: true)), [
        'at level',
        'below level',
        'zero level',
      ]);
    });
  });

  test('the Home card lists the 5 lowest and counts all 7', () async {
    for (var i = 1; i <= 7; i++) {
      await env.addProduct(
        'p$i',
        lowStock: '10',
        openingQty: '$i',
        openingCost: '1',
      );
    }
    await env.addProduct(
      'fine',
      lowStock: '1',
      openingQty: '50',
      openingCost: '1',
    );
    final snapshot = await env.productRepo.watchLowStock().first;
    expect(snapshot.totalCount, 7);
    expect(snapshot.hasAnyProduct, isTrue);
    expect(snapshot.items.map((s) => s.product.name), [
      'p1',
      'p2',
      'p3',
      'p4',
      'p5',
    ]);
  });

  test('the Home card with none low and with no products', () async {
    final empty = await env.productRepo.watchLowStock().first;
    expect(empty.items, isEmpty);
    expect(empty.totalCount, 0);
    expect(empty.hasAnyProduct, isFalse);

    await env.addProduct('fine');
    final none = await env.productRepo.watchLowStock().first;
    expect(none.totalCount, 0);
    expect(none.hasAnyProduct, isTrue);
  });
}
