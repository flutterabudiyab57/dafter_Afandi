import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/product.dart';
import 'package:daftar_afandi/features/products/domain/product_draft.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:daftar_afandi/features/products/domain/product_repository.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/archived_products_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/low_stock_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_products.dart';

/// Counts how often the list subscribes, around the fake repository.
final class _CountingRepository implements ProductRepository {
  _CountingRepository(this._inner);

  final ProductRepository _inner;
  final List<ProductQuery> queries = [];

  @override
  Stream<List<ProductSummary>> watchSummaries(ProductQuery query) {
    queries.add(query);
    return _inner.watchSummaries(query);
  }

  @override
  Stream<LowStockSnapshot> watchLowStock({int limit = 5}) =>
      _inner.watchLowStock(limit: limit);

  @override
  Stream<ProductSummary?> watchSummary(String id) => _inner.watchSummary(id);

  @override
  Stream<List<ProductSummary>> watchArchived() => _inner.watchArchived();

  @override
  Future<ProductSummary?> activeByBarcode(String barcode) =>
      _inner.activeByBarcode(barcode);

  @override
  Future<Result<ProductSaved, ProductSaveError>> create(ProductDraft d) =>
      _inner.create(d);

  @override
  Future<Result<ProductSaved, ProductSaveError>> update(
    String id,
    ProductDraft d,
  ) => _inner.update(id, d);

  @override
  Future<void> archive(String id) => _inner.archive(id);

  @override
  Future<Result<void, RestoreError>> restore(String id) => _inner.restore(id);
}

void main() {
  late FakeProductsStore store;

  setUp(() => store = FakeProductsStore());

  group('LowStockCubit', () {
    test(
      'starts loading, then shows the snapshot and follows writes',
      () async {
        final id = store.seedProduct(
          'أرز',
          stockMilli: 2000,
          lowStockMilli: 5000,
        );
        final cubit = LowStockCubit(store.products);
        addTearDown(cubit.close);
        expect(cubit.state, isNull);
        await pumpEventQueue();
        expect(cubit.state!.totalCount, 1);
        expect(cubit.state!.items.single.product.id, id);

        await store.products.archive(id);
        await pumpEventQueue();
        expect(cubit.state!.totalCount, 0);
        expect(cubit.state!.hasAnyProduct, isFalse);
      },
    );
  });

  group('ProductListCubit', () {
    late _CountingRepository repo;

    setUp(() {
      store
        ..seedProduct('أرز مصري', barcode: '622')
        ..seedProduct('شاي', stockMilli: 1000, lowStockMilli: 2000)
        ..seedProduct('Zeta');
      repo = _CountingRepository(store.products);
    });

    ProductListCubit build() => ProductListCubit(
      repo,
      store.categories,
      debounce: const Duration(milliseconds: 30),
    );

    test('lists every active product in order', () async {
      final cubit = build();
      addTearDown(cubit.close);
      expect(cubit.state.loading, isTrue);
      await pumpEventQueue();
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.items.map((s) => s.product.name), [
        'أرز مصري',
        'شاي',
        'Zeta',
      ]);
    });

    test(
      'typing shows the text at once and queries once after a pause',
      () async {
        final cubit = build();
        addTearDown(cubit.close);
        await pumpEventQueue();
        cubit
          ..search('ا')
          ..search('ار')
          ..search('ارز');
        expect(cubit.state.query.text, 'ارز');
        expect(repo.queries, hasLength(1));
        await Future<void>.delayed(const Duration(milliseconds: 80));
        await pumpEventQueue();
        expect(repo.queries, hasLength(2));
        expect(repo.queries.last.text, 'ارز');
        expect(cubit.state.items.map((s) => s.product.name), ['أرز مصري']);
      },
    );

    test('filters apply at once and combine with the search', () async {
      final drinks = store.seedCategory('مشروبات');
      store.seedProduct('عصير', categoryId: drinks);
      final cubit = build();
      addTearDown(cubit.close);
      await pumpEventQueue();
      expect(cubit.state.categories.single.name, 'مشروبات');

      cubit.toggleLow();
      await pumpEventQueue();
      expect(cubit.state.query.lowOnly, isTrue);
      expect(cubit.state.items.map((s) => s.product.name), ['شاي']);

      cubit
        ..toggleLow()
        ..setCategory(InCategory(drinks));
      await pumpEventQueue();
      expect(cubit.state.items.map((s) => s.product.name), ['عصير']);

      cubit.setCategory(const NoCategory());
      await pumpEventQueue();
      expect(cubit.state.items, hasLength(3));
    });

    test(
      'an initial low filter (from the Home card) applies at once',
      () async {
        final cubit = ProductListCubit(
          repo,
          store.categories,
          initialQuery: const ProductQuery(lowOnly: true),
        );
        addTearDown(cubit.close);
        await pumpEventQueue();
        expect(cubit.state.items.map((s) => s.product.name), ['شاي']);
      },
    );

    test('the list follows writes', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await pumpEventQueue();
      store.seedProduct('باذنجان');
      await pumpEventQueue();
      expect(cubit.state.items.map((s) => s.product.name), [
        'أرز مصري',
        'باذنجان',
        'شاي',
        'Zeta',
      ]);
    });
  });

  group('ArchivedProductsCubit', () {
    blocTest<ArchivedProductsCubit, ArchivedProductsState>(
      'lists archived products',
      setUp: () => store.seedProduct('قديم', archived: true),
      build: () => ArchivedProductsCubit(store.products),
      wait: Duration.zero,
      verify: (c) => expect(c.state.items.single.product.name, 'قديم'),
    );

    test(
      'restore returns the barcode conflict, or null when restored',
      () async {
        final old = store.seedProduct('قديم', barcode: '1', archived: true);
        store.seedProduct('جديد', barcode: '1');
        final free = store.seedProduct('حر', archived: true);
        final cubit = ArchivedProductsCubit(store.products);
        addTearDown(cubit.close);
        expect(await cubit.restore(old), const RestoreBarcodeTaken('جديد'));
        expect(await cubit.restore(free), isNull);
        await pumpEventQueue();
        expect(cubit.state.items.map((s) => s.product.name), ['قديم']);
      },
    );
  });
}
