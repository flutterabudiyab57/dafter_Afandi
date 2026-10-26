import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/customer_form_cubit.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/payment_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_sales.dart';

void main() {
  late FakeSalesStore store;
  late FakeCustomersCubits cubits;

  setUp(() {
    store = FakeSalesStore();
    cubits = FakeCustomersCubits(store);
  });

  test('list: search, owes filter, quick add', () async {
    store
      ..seedCustomer('أحمد', phone: '0101', openingPiasters: 100)
      ..seedCustomer('محمد', openingPiasters: 900)
      ..seedCustomer('علي');
    final c = cubits.customersList();
    await pumpEventQueue();
    expect(c.state.items, hasLength(3));
    c.toggleOwes();
    await pumpEventQueue();
    expect(c.state.items.map((s) => s.customer.name), ['محمد', 'أحمد']);
    c
      ..toggleOwes()
      ..search('احمد');
    await pumpEventQueue();
    expect(c.state.items.single.customer.name, 'أحمد');
    c.search('سمير');
    await pumpEventQueue();
    expect(c.state.items, isEmpty);
    final added = await c.quickAdd();
    expect(added!.customer.name, 'سمير');
    c.search('   ');
    expect(await c.quickAdd(), isNull);
    await c.close();
  });

  test('form: errors, opening in favour, same-name notice, edit', () async {
    store.seedCustomer('أحمد');
    final f = cubits.customerForm(mode: CustomerFormMode.create);
    await f.submit();
    expect(f.state.errors.single.field, CustomerField.name);
    f
      ..nameChanged('احمد')
      ..openingChanged('20')
      ..openingDirectionChanged(inFavour: true);
    await f.submit();
    expect(f.state.status, CustomerFormStatus.saved);
    expect(f.state.nameExistsElsewhere, isTrue);
    expect(store.balanceOf(f.state.savedId!), -2000);
    await f.close();

    final e = cubits.customerForm(
      mode: CustomerFormMode.edit,
      customerId: f.state.savedId,
    );
    await pumpEventQueue();
    expect(e.state.name, 'احمد');
    e.nameChanged('أحمد سعيد');
    await e.submit();
    expect(store.customer(f.state.savedId!)!.customer.name, 'أحمد سعيد');
    await e.close();

    final missing = cubits.customerForm(
      mode: CustomerFormMode.edit,
      customerId: 'nope',
    );
    await pumpEventQueue();
    expect(missing.state.status, CustomerFormStatus.notFound);
    await missing.close();
  });

  test('payment: a credit notice when paying more than the balance', () async {
    final k = store.seedCustomer('أحمد', openingPiasters: 6000);
    final p = cubits.payment(k);
    await pumpEventQueue();
    expect(p.state.balancePiasters, 6000);
    p.amountChanged('80');
    await p.submit();
    expect(p.state.status, PaymentStatus.confirmCredit);
    expect(p.state.creditAfterPiasters, 2000);
    p.cancelCredit();
    expect(store.writes, isEmpty);
    p
      ..amountChanged('25')
      ..methodChanged(PaymentMethod.wallet);
    await p.submit();
    expect(p.state.status, PaymentStatus.saved);
    expect(p.state.receiptNumber, 1);
    expect(store.balanceOf(k), 3500);
    await p.close();
  });

  test('statement pages and cancels a payment once', () async {
    final k = store.seedCustomer('أحمد', openingPiasters: 100);
    await store.customers.receivePayment(
      k,
      const PaymentRequest(amountPiasters: 50, method: PaymentMethod.cash),
    );
    final s = cubits.statement(k);
    await s.load();
    expect(s.state.entries.map((e) => e.type), [
      LedgerEntryType.payment,
      LedgerEntryType.openingBalance,
    ]);
    final pay = s.state.entries.first;
    expect(await s.cancelPayment(pay.id, 'خطأ'), isNull);
    expect(
      await s.cancelPayment(pay.id, 'خطأ'),
      const PaymentAlreadyCancelled(),
    );
    await s.load();
    expect(s.state.entries.first.type, LedgerEntryType.reversal);
    expect(store.balanceOf(k), 100);
    await s.close();
  });

  test('details archive and restore; archived list', () async {
    final k = store.seedCustomer('أحمد');
    final d = cubits.customerDetails(k);
    final a = cubits.archivedCustomers();
    await pumpEventQueue();
    await d.archive();
    await pumpEventQueue();
    expect(d.state.summary!.customer.archived, isTrue);
    expect(a.state.items.single.customer.id, k);
    await a.restore(k);
    await pumpEventQueue();
    expect(a.state.items, isEmpty);
    await d.close();
    await a.close();
  });
}
