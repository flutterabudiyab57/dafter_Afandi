import 'package:daftar_afandi/features/purchases/presentation/cubits/purchases_list_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_details_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/suppliers_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_purchases.dart';

/// Purchases and suppliers lists: a failing load sets `loadFailed`; retry
/// brings the data; a new search clears the flag (research R7).
void main() {
  late FakePurchasesStore store;

  setUp(() => store = FakePurchasesStore());

  test('purchases list', () async {
    store.failNextWatch = StateError('db');
    final cubit = PurchasesListCubit(store.purchases, debounce: Duration.zero);
    addTearDown(cubit.close);
    await pumpEventQueue();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.loading, isFalse);
    cubit.retry();
    expect(cubit.state.loadFailed, isFalse);
    await pumpEventQueue();
    expect(cubit.state.loading, isFalse);

    store.failNextWatch = StateError('db');
    cubit.retry();
    await pumpEventQueue();
    cubit.search('1');
    await pumpEventQueue();
    expect(cubit.state.loadFailed, isFalse);
  });

  test('suppliers list and archived suppliers', () async {
    store.failNextWatch = StateError('db');
    final list = SuppliersListCubit(store.suppliers, debounce: Duration.zero);
    addTearDown(list.close);
    await pumpEventQueue();
    expect(list.state.loadFailed, isTrue);
    list.search('ن');
    await pumpEventQueue();
    expect(list.state.loadFailed, isFalse);
    expect(list.state.loading, isFalse);

    store.failNextWatch = StateError('db');
    final archived = ArchivedSuppliersCubit(store.suppliers);
    addTearDown(archived.close);
    await pumpEventQueue();
    expect(archived.state.loadFailed, isTrue);
    archived.retry();
    await pumpEventQueue();
    expect(archived.state.loadFailed, isFalse);
    expect(archived.state.loaded, isTrue);
  });

  test('supplier statement: a failed first page, then load again', () async {
    final id = store.seedSupplier('النور');
    store.failNextRead = StateError('db');
    final cubit = SupplierStatementCubit(store.suppliers, id);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.loading, isFalse);
    await cubit.load();
    expect(cubit.state.loadFailed, isFalse);
  });
}
