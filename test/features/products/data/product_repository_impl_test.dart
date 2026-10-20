import 'package:daftar_afandi/core/database/daos/products_dao.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:daftar_afandi/features/products/domain/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/database/test_database.dart';
import 'products_env.dart';

/// Fails the average-cost write (W3 of a create with opening stock).
final class _FailingAvgCostDao extends ProductsDao {
  _FailingAvgCostDao(super.attachedDatabase);

  @override
  Future<void> setAvgCost(String id, int avgCostPiasters, DateTime now) =>
      throw StateError('W3 failed');
}

void main() {
  late ProductsEnv env;

  setUp(() => env = ProductsEnv());
  tearDown(() => env.dispose());

  group('create', () {
    test('without opening: stock 0, average cost 0, no history', () async {
      final id = await env.addProduct('أرز مصري', price: '25');
      final s = await env.summary(id);
      expect(s.product.name, 'أرز مصري');
      expect(s.product.salePricePiasters, 2500);
      expect(s.product.avgCostPiasters, 0);
      expect(s.stockMilli, 0);
      expect(s.hasHistory, isFalse);
      expect(
        await env.db.scalar("SELECT search_key FROM products WHERE id = '$id'"),
        'ارز مصري',
      );
    });

    test(
      'opening 12 at 7.50: stock 12, average cost 7.50, one OPENING row',
      () async {
        final id = await env.addProduct(
          'شاي',
          openingQty: '12',
          openingCost: '7.50',
        );
        final s = await env.summary(id);
        expect(s.stockMilli, 12000);
        expect(s.product.avgCostPiasters, 750);
        expect(s.hasHistory, isTrue);
        final rows = await env.db.rows(
          'SELECT movement_type, qty_delta_milli, unit_cost_piasters '
          'FROM stock_movements',
        );
        expect(rows, [
          {
            'movement_type': 'OPENING',
            'qty_delta_milli': 12000,
            'unit_cost_piasters': 750,
          },
        ]);
      },
    );

    test('a failure after the movement write leaves nothing behind', () async {
      final failing = ProductsEnv(productsDao: _FailingAvgCostDao.new);
      addTearDown(failing.dispose);
      await expectLater(
        failing.productRepo.create(
          draftOf('شاي', openingQty: '1', openingCost: '2'),
        ),
        throwsStateError,
      );
      expect(await failing.db.scalar('SELECT COUNT(*) FROM products'), 0);
      expect(
        await failing.db.scalar('SELECT COUNT(*) FROM stock_movements'),
        0,
      );
    });

    test('flags another active product with the same folded name', () async {
      await env.addProduct('أرز');
      final saved = okValue(await env.productRepo.create(draftOf('ارز')));
      expect(saved.nameExistsElsewhere, isTrue);
      final other = okValue(await env.productRepo.create(draftOf('سكر')));
      expect(other.nameExistsElsewhere, isFalse);
    });
  });

  group('barcode', () {
    test('another active product with it blocks create, naming it', () async {
      await env.addProduct('أرز مصري', barcode: '6221234567890');
      final result = await env.productRepo.create(
        draftOf('شاي', barcode: '٦٢٢١٢٣٤٥٦٧٨٩٠'),
      );
      expect(
        errValue<ProductSaved, ProductSaveError>(result),
        const BarcodeTaken('أرز مصري'),
      );
      expect(await env.db.scalar('SELECT COUNT(*) FROM products'), 1);
    });

    test('blocks update; keeping its own barcode is fine', () async {
      await env.addProduct('أرز', barcode: '111');
      final tea = await env.addProduct('شاي', barcode: '222');
      expect(
        errValue<ProductSaved, ProductSaveError>(
          await env.productRepo.update(tea, draftOf('شاي', barcode: '111')),
        ),
        const BarcodeTaken('أرز'),
      );
      okValue(
        await env.productRepo.update(tea, draftOf('شاي', barcode: '222')),
      );
      expect((await env.summary(tea)).product.barcode, '222');
    });

    test(
      'an archived holder does not block, but blocks its own restore',
      () async {
        final rice = await env.addProduct('أرز', barcode: '111');
        await env.productRepo.archive(rice);
        await env.addProduct('أرز جديد', barcode: '111');
        expect(
          errValue<void, RestoreError>(await env.productRepo.restore(rice)),
          const RestoreBarcodeTaken('أرز جديد'),
        );
        expect((await env.summary(rice)).product.archived, isTrue);
      },
    );
  });

  group('update', () {
    test('changes fields but never stock or average cost', () async {
      final id = await env.addProduct(
        'شاي',
        price: '5',
        openingQty: '4',
        openingCost: '3',
      );
      final saved = await env.productRepo.update(
        id,
        draftOf('شاي أخضر', price: '6.25', sku: 'T-1', lowStock: '2'),
      );
      expect(okValue(saved).id, id);
      final s = await env.summary(id);
      expect(s.product.name, 'شاي أخضر');
      expect(s.product.salePricePiasters, 625);
      expect(s.product.sku, 'T-1');
      expect(s.product.lowStockThresholdMilli, 2000);
      expect(s.product.avgCostPiasters, 300);
      expect(s.stockMilli, 4000);
    });

    test('the unit is locked once the product has history', () async {
      final fresh = await env.addProduct('سكر');
      expect(
        okValue(
          await env.productRepo.update(
            fresh,
            draftOf('سكر', unit: UnitType.kg),
          ),
        ).id,
        fresh,
      );
      final stocked = await env.addProduct(
        'أرز',
        openingQty: '1',
        openingCost: '1',
      );
      expect(
        errValue<ProductSaved, ProductSaveError>(
          await env.productRepo.update(
            stocked,
            draftOf('أرز', unit: UnitType.kg),
          ),
        ),
        const UnitLocked(),
      );
    });

    test('a missing product is not found', () async {
      expect(
        errValue<ProductSaved, ProductSaveError>(
          await env.productRepo.update('nope', draftOf('x')),
        ),
        const ProductNotFound(),
      );
    });
  });

  group('archive and restore', () {
    test('archived products leave the list, search and Home card', () async {
      final id = await env.addProduct('أرز', lowStock: '5');
      await env.productRepo.archive(id);
      expect(await env.list(), isEmpty);
      expect(await env.list(const ProductQuery(text: 'ارز')), isEmpty);
      final low = await env.productRepo.watchLowStock().first;
      expect(low.items, isEmpty);
      expect(low.hasAnyProduct, isFalse);
      final archived = await env.productRepo.watchArchived().first;
      expect(archived.single.product.id, id);
      expect(archived.single.product.archived, isTrue);
    });

    test('restore brings it back with stock and history', () async {
      final id = await env.addProduct('أرز', openingQty: '9', openingCost: '1');
      await env.productRepo.archive(id);
      expect(await env.productRepo.restore(id), isA<Ok<void, RestoreError>>());
      final s = (await env.list()).single;
      expect(s.product.id, id);
      expect(s.stockMilli, 9000);
      expect(s.hasHistory, isTrue);
    });
  });

  test('an archived category reads as no category', () async {
    final drinks = okValue(await env.categories.create('مشروبات'));
    final tea = await env.addProduct('شاي', categoryId: drinks.id);
    await env.addProduct('سكر');
    expect((await env.summary(tea)).product.categoryName, 'مشروبات');

    await env.categories.archive(drinks.id);
    final s = await env.summary(tea);
    expect(s.product.categoryId, isNull);
    expect(s.product.categoryName, isNull);
    final none = await env.list(
      const ProductQuery(categoryFilter: NoCategory()),
    );
    expect(none.map((p) => p.product.name), ['سكر', 'شاي']);
    expect(
      await env.list(ProductQuery(categoryFilter: InCategory(drinks.id))),
      isEmpty,
    );
  });

  test('watch queries emit again after a write', () async {
    final stream = env.productRepo.watchSummaries(const ProductQuery());
    final seen = <int>[];
    final sub = stream.listen((items) => seen.add(items.length));
    await pumpEventQueue();
    await env.addProduct('أرز');
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [0, 1]);
  });
}
