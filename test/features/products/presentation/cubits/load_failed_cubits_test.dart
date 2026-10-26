import 'package:daftar_afandi/features/products/presentation/cubits/archived_products_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/categories_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/low_stock_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_list_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/stock_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_products.dart';

/// A failing load sets `loadFailed`; retry brings the data (research R7).
void main() {
  late FakeProductsStore store;
  late String id;

  setUp(() {
    store = FakeProductsStore();
    id = store.seedProduct('شاي', stockMilli: 1000, lowStockMilli: 2000);
  });

  test('product list: error, retry, and a new query clears the flag', () async {
    final cubit = ProductListCubit(
      store.products,
      store.categories,
      debounce: Duration.zero,
    );
    addTearDown(cubit.close);
    await pumpEventQueue();
    // The categories stream subscribes first, so fail the list on a retry.
    store.failNextWatch = StateError('db');
    cubit.retry();
    await pumpEventQueue();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.loading, isFalse);

    cubit.retry();
    expect(cubit.state.loading, isTrue);
    expect(cubit.state.loadFailed, isFalse);
    await pumpEventQueue();
    expect(cubit.state.items, hasLength(1));

    store.failNextWatch = StateError('db');
    cubit.retry();
    await pumpEventQueue();
    expect(cubit.state.loadFailed, isTrue);
    cubit.search('ش');
    await pumpEventQueue();
    expect(cubit.state.loadFailed, isFalse);
    expect(cubit.state.items, hasLength(1));
  });

  test('archived products and categories fail, then retry', () async {
    store.failNextWatch = StateError('db');
    final archived = ArchivedProductsCubit(store.products);
    addTearDown(archived.close);
    await pumpEventQueue();
    expect(archived.state.loadFailed, isTrue);
    archived.retry();
    expect(archived.state.loaded, isFalse);
    await pumpEventQueue();
    expect(archived.state.loadFailed, isFalse);
    expect(archived.state.loaded, isTrue);

    store.failNextWatch = StateError('db');
    final categories = CategoriesCubit(store.categories);
    addTearDown(categories.close);
    await pumpEventQueue();
    expect(categories.state.loadFailed, isTrue);
    categories.retry();
    await pumpEventQueue();
    expect(categories.state.loadFailed, isFalse);
    expect(categories.state.loaded, isTrue);
  });

  test('low stock fails, then retry shows the snapshot', () async {
    store.failNextWatch = StateError('db');
    final cubit = LowStockCubit(store.products);
    addTearDown(cubit.close);
    await pumpEventQueue();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.snapshot, isNull);
    cubit.retry();
    await pumpEventQueue();
    expect(cubit.state.loadFailed, isFalse);
    expect(cubit.state.snapshot!.totalCount, 1);
  });

  test('stock history: a failed first page, then load again', () async {
    store.failNextRead = StateError('db');
    final cubit = StockHistoryCubit(store.inventory, id);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.loading, isFalse);
    await cubit.load();
    expect(cubit.state.loadFailed, isFalse);
    expect(cubit.state.entries, isNotEmpty);
  });
}
