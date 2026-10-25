import 'package:daftar_afandi/features/customers/presentation/cubits/customer_details_cubit.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/customers_list_cubit.dart';
import 'package:daftar_afandi/features/sales/presentation/cubits/sales_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_sales.dart';

/// Sales and customers lists: a failing load sets `loadFailed`; retry
/// brings the data; a new search clears the flag (research R7).
void main() {
  late FakeSalesStore store;

  setUp(() => store = FakeSalesStore());

  test('sales list', () async {
    store.failNextWatch = StateError('db');
    final cubit = SalesListCubit(store.sales, debounce: Duration.zero);
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

  test('customers list and archived customers', () async {
    store.failNextWatch = StateError('db');
    final list = CustomersListCubit(store.customers, debounce: Duration.zero);
    addTearDown(list.close);
    await pumpEventQueue();
    expect(list.state.loadFailed, isTrue);
    list.search('م');
    await pumpEventQueue();
    expect(list.state.loadFailed, isFalse);
    expect(list.state.loading, isFalse);

    store.failNextWatch = StateError('db');
    final archived = ArchivedCustomersCubit(store.customers);
    addTearDown(archived.close);
    await pumpEventQueue();
    expect(archived.state.loadFailed, isTrue);
    archived.retry();
    await pumpEventQueue();
    expect(archived.state.loadFailed, isFalse);
    expect(archived.state.loaded, isTrue);
  });

  test('customer statement: a failed first page, then load again', () async {
    final id = store.seedCustomer('منى');
    store.failNextRead = StateError('db');
    final cubit = StatementCubit(store.customers, id);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.loadFailed, isTrue);
    expect(cubit.state.loading, isFalse);
    await cubit.load();
    expect(cubit.state.loadFailed, isFalse);
  });
}
