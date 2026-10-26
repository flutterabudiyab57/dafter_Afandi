import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_errors.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_details_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_form_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_payment_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_purchases.dart';

void main() {
  late FakePurchasesStore store;
  late FakeSuppliersCubits cubits;

  setUp(() {
    store = FakePurchasesStore();
    cubits = FakeSuppliersCubits(store);
  });

  test('list: search, owed filter, quick add', () async {
    store
      ..seedSupplier('شركة النور', phone: '0101', openingPiasters: 100)
      ..seedSupplier('مخازن الأمل', openingPiasters: 900)
      ..seedSupplier('Zeta', openingPiasters: -50);
    final c = cubits.suppliersList();
    await pumpEventQueue();
    expect(c.state.items, hasLength(3));
    c.toggleOwed();
    await pumpEventQueue();
    expect(c.state.items.map((s) => s.supplier.name), [
      'مخازن الأمل',
      'شركة النور',
    ]);
    c
      ..toggleOwed()
      ..search('الامل');
    await pumpEventQueue();
    expect(c.state.items.single.supplier.name, 'مخازن الأمل');
    c.search('الفجر');
    await pumpEventQueue();
    expect(c.state.items, isEmpty);
    final added = await c.quickAdd();
    expect(added!.supplier.name, 'الفجر');
    expect(store.writes, ['supplier الفجر']);
    c.search('   ');
    expect(await c.quickAdd(), isNull);
    await c.close();
  });

  test('form: errors, opening in the shop favour, notice, edit', () async {
    store.seedSupplier('أحمد');
    final f = cubits.supplierForm(mode: SupplierFormMode.create);
    await f.submit();
    expect(f.state.errors.single.field, CustomerField.name);
    f
      ..nameChanged('احمد')
      ..openingChanged('20')
      ..openingDirectionChanged(inShopFavour: true);
    expect(f.state.errors, isEmpty);
    await f.submit();
    expect(f.state.status, SupplierFormStatus.saved);
    expect(f.state.nameExistsElsewhere, isTrue);
    expect(store.balanceOf(f.state.savedId!), -2000);
    await f.close();

    final e = cubits.supplierForm(
      mode: SupplierFormMode.edit,
      supplierId: f.state.savedId,
    );
    expect(e.state.status, SupplierFormStatus.loading);
    await pumpEventQueue();
    expect(e.state.name, 'احمد');
    e
      ..nameChanged('أحمد للتوريدات')
      // Ignored when editing.
      ..openingChanged('500');
    await e.submit();
    expect(store.supplier(f.state.savedId!)!.supplier.name, 'أحمد للتوريدات');
    expect(store.balanceOf(f.state.savedId!), -2000);
    await e.close();

    final missing = cubits.supplierForm(
      mode: SupplierFormMode.edit,
      supplierId: 'nope',
    );
    await pumpEventQueue();
    expect(missing.state.status, SupplierFormStatus.notFound);
    await missing.close();
  });

  test('form: the name from the picker search', () async {
    final f = cubits.supplierForm(
      mode: SupplierFormMode.create,
      initialName: 'الفجر',
    );
    expect(f.state.name, 'الفجر');
    await f.close();
  });

  test('payment: a notice when paying more than the shop owes', () async {
    final v = store.seedSupplier('النور', openingPiasters: 6000);
    final p = cubits.payment(v);
    await pumpEventQueue();
    expect(p.state.status, SupplierPaymentStatus.editing);
    expect(p.state.supplierName, 'النور');
    expect(p.state.balancePiasters, 6000);

    await p.submit();
    expect(p.state.errors.single.field, CustomerField.amount);
    p.amountChanged('80');
    expect(p.state.errors, isEmpty);
    await p.submit();
    expect(p.state.status, SupplierPaymentStatus.confirmOverpay);
    expect(p.state.supplierOwesAfterPiasters, 2000);
    p.cancelOverpay();
    expect(p.state.status, SupplierPaymentStatus.editing);
    expect(p.state.pending, isNull);
    expect(store.writes, isEmpty);

    await p.submit();
    await p.confirmOverpay();
    expect(p.state.status, SupplierPaymentStatus.saved);
    expect(p.state.paymentNumber, 1);
    expect(store.balanceOf(v), -2000);
    await p.close();
  });

  test('payment: saves at once within the balance, with the method', () async {
    final v = store.seedSupplier('النور', openingPiasters: 6000);
    final p = cubits.payment(v);
    await pumpEventQueue();
    p
      ..amountChanged('25')
      ..methodChanged(PaymentMethod.wallet)
      ..noteChanged('دفعة');
    await p.submit();
    expect(p.state.status, SupplierPaymentStatus.saved);
    final row = store.statementOf(v).first;
    expect(row.method, PaymentMethod.wallet);
    expect(row.note, 'دفعة');
    expect(store.balanceOf(v), 3500);
    await p.close();
  });

  test('payment: an archived supplier cannot be paid', () async {
    final v = store.seedSupplier('النور', archived: true);
    final p = cubits.payment(v);
    await pumpEventQueue();
    expect(p.state.status, SupplierPaymentStatus.notFound);
    await p.close();
  });

  test('statement pages, reloads on new rows, cancels once', () async {
    final v = store.seedSupplier('النور', openingPiasters: 100);
    final s = cubits.statement(v);
    await s.load();
    expect(s.state.loading, isFalse);
    expect(s.state.entries.single.type, SupplierEntryType.openingBalance);

    // A payment from another screen reloads the statement.
    await store.suppliers.pay(
      v,
      const PaymentRequest(amountPiasters: 50, method: PaymentMethod.cash),
    );
    await pumpEventQueue();
    expect(s.state.entries.map((e) => e.type), [
      SupplierEntryType.payment,
      SupplierEntryType.openingBalance,
    ]);

    final pay = s.state.entries.first;
    expect(await s.cancelPayment(pay.id, 'خطأ'), isNull);
    expect(
      await s.cancelPayment(pay.id, 'خطأ'),
      const SupplierPaymentAlreadyCancelled(),
    );
    await pumpEventQueue();
    expect(s.state.entries.first.type, SupplierEntryType.reversal);
    expect(s.state.entries[1].reversed, isTrue);
    await s.close();
  });

  test('statement: more pages after the first', () async {
    final v = store.seedSupplier('النور', openingPiasters: 100);
    for (var i = 0; i < 4; i++) {
      await store.suppliers.pay(
        v,
        const PaymentRequest(amountPiasters: 1, method: PaymentMethod.cash),
      );
    }
    final s = SupplierStatementCubit(store.suppliers, v, pageSize: 2);
    await s.load();
    expect(s.state.hasMore, isTrue);
    expect(s.state.entries.map((e) => e.paymentNumber), [4, 3]);
    await s.loadMore();
    await s.loadMore();
    expect(s.state.entries, hasLength(5));
    expect(s.state.hasMore, isFalse);
    await s.close();
  });

  test('details archive and restore; archived list', () async {
    final v = store.seedSupplier('النور');
    final d = cubits.supplierDetails(v);
    final a = cubits.archivedSuppliers();
    await pumpEventQueue();
    expect(d.state.summary!.supplier.name, 'النور');
    expect(a.state.items, isEmpty);
    await d.archive();
    await pumpEventQueue();
    expect(d.state.summary!.supplier.archived, isTrue);
    expect(a.state.items.single.supplier.id, v);
    await a.restore(v);
    await pumpEventQueue();
    expect(d.state.summary!.supplier.archived, isFalse);
    expect(a.state.items, isEmpty);
    await d.close();
    await a.close();

    final missing = cubits.supplierDetails('nope');
    await pumpEventQueue();
    expect(missing.state.loaded, isTrue);
    expect(missing.state.summary, isNull);
    await missing.close();
  });
}
