import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_draft.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_errors.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import '../../purchases/data/purchases_env.dart';
import '../../sales/data/sales_env.dart' show one;

PaymentRequest payment(String amount, {String note = ''}) =>
    okValue<PaymentRequest, List<CustomerFieldError>>(
      PaymentRequest.create(
        amountText: amount,
        method: PaymentMethod.wallet,
        note: note,
      ),
    );

SupplierDraft draft(String name, {String phone = ''}) =>
    okValue<SupplierDraft, List<CustomerFieldError>>(
      SupplierDraft.create(name: name, phone: phone),
    );

void main() {
  late PurchasesEnv env;

  setUp(() => env = PurchasesEnv());
  tearDown(() => env.dispose());

  Future<List<String>> names(SupplierQuery q) async =>
      (await env.suppliers.watchActive(q).first)
          .map((s) => s.supplier.name)
          .toList();

  test('create, update, archive and restore', () async {
    final id = await env.addSupplier('شركة النور', phone: '0223456789');
    var s = await env.supplier(id);
    expect(s.supplier.name, 'شركة النور');
    expect(s.supplier.phone, '0223456789');
    expect(s.balancePiasters, 0);
    expect(await env.statement(id), isEmpty);

    final saved = okValue<SupplierSaved, SupplierSaveError>(
      await env.suppliers.update(id, draft('النور للتوريدات')),
    );
    expect(saved.nameExistsElsewhere, isFalse);
    s = await env.supplier(id);
    expect(s.supplier.name, 'النور للتوريدات');
    expect(s.supplier.phone, isNull);

    expect(
      errValue<SupplierSaved, SupplierSaveError>(
        await env.suppliers.update('missing', draft('x')),
      ),
      const SupplierNotFound(),
    );

    await env.suppliers.archive(id);
    expect(await names(const SupplierQuery()), isEmpty);
    expect((await env.suppliers.watchArchived().first).single.supplier.id, id);
    expect((await env.supplier(id)).supplier.archived, isTrue);
    await env.suppliers.restore(id);
    expect(await names(const SupplierQuery()), ['النور للتوريدات']);
  });

  test('a same-name notice among active suppliers only', () async {
    final first = await env.addSupplier('أحمد');
    final second = okValue<SupplierSaved, SupplierSaveError>(
      await env.suppliers.create(draft('احمد')),
    );
    expect(second.nameExistsElsewhere, isTrue);
    await env.suppliers.archive(first);
    final edited = okValue<SupplierSaved, SupplierSaveError>(
      await env.suppliers.update(second.id, draft('احمد')),
    );
    expect(edited.nameExistsElsewhere, isFalse);
  });

  test('opening balance: owed by the shop +, in its favour −', () async {
    final owed = await env.addSupplier('a', opening: '150');
    final favour = await env.addSupplier(
      'b',
      opening: '20',
      inShopFavour: true,
    );
    expect((await env.supplier(owed)).balancePiasters, 15000);
    expect((await env.supplier(favour)).balancePiasters, -2000);
    final row = (await env.statement(owed)).single;
    expect(row.type, SupplierEntryType.openingBalance);
    expect(row.runningBalancePiasters, 15000);
  });

  test('search by name or phone; owed filter highest first', () async {
    await env.addSupplier('شركة النور', phone: '01001234567', opening: '10');
    await env.addSupplier('مخازن الأمل', opening: '30');
    await env.addSupplier('Zeta', opening: '5', inShopFavour: true);
    expect(await names(const SupplierQuery()), [
      'شركة النور',
      'مخازن الأمل',
      'Zeta',
    ]);
    expect(await names(const SupplierQuery(text: 'الامل')), ['مخازن الأمل']);
    expect(await names(const SupplierQuery(text: '٠١٠٠١')), ['شركة النور']);
    expect(await names(const SupplierQuery(owedOnly: true)), [
      'مخازن الأمل',
      'شركة النور',
    ]);
  });

  test('pay: PY numbers in order, balance down, the row details', () async {
    final id = await env.addSupplier('a', opening: '100');
    expect(
      okValue<int, SupplierPaymentError>(
        await env.suppliers.pay(id, payment('30', note: 'دفعة')),
      ),
      1,
    );
    expect(
      okValue<int, SupplierPaymentError>(
        await env.suppliers.pay(id, payment('80')),
      ),
      2,
    );
    expect((await env.supplier(id)).balancePiasters, -1000);
    final rows = await env.statement(id);
    expect(rows.map((e) => e.runningBalancePiasters), [-1000, 7000, 10000]);
    final paid = rows[1];
    expect(paid.type, SupplierEntryType.payment);
    expect(paid.amountPiasters, -3000);
    expect(paid.paymentNumber, 1);
    expect(paid.method, PaymentMethod.wallet);
    expect(paid.note, 'دفعة');
    expect(paid.cancellable, isTrue);
  });

  test('pay: unknown or archived supplier', () async {
    expect(
      errValue<int, SupplierPaymentError>(
        await env.suppliers.pay('missing', payment('1')),
      ),
      const PaymentSupplierNotFound(),
    );
    final id = await env.addSupplier('a');
    await env.suppliers.archive(id);
    expect(
      errValue<int, SupplierPaymentError>(
        await env.suppliers.pay(id, payment('1')),
      ),
      const PaymentSupplierArchived(),
    );
    expect(await env.statement(id), isEmpty);
  });

  test('cancel: once, with a trimmed reason, standalone only', () async {
    final id = await env.addSupplier('a');
    await env.suppliers.pay(id, payment('40'));
    final paid = (await env.statement(id)).single;

    for (final bad in ['', '   ', 'x' * (maxReasonLength + 1)]) {
      expect(
        errValue<void, SupplierPaymentError>(
          await env.suppliers.cancelPayment(paid.id, bad),
        ),
        const SupplierPaymentReasonInvalid(),
      );
    }
    expect(
      await env.suppliers.cancelPayment(paid.id, '  خطأ  '),
      isA<Ok<void, SupplierPaymentError>>(),
    );
    final rows = await env.statement(id);
    expect(rows.first.type, SupplierEntryType.reversal);
    expect(rows.first.amountPiasters, 4000);
    expect(rows.first.note, 'خطأ');
    expect(rows.last.reversed, isTrue);
    expect(rows.last.cancellable, isFalse);
    expect((await env.supplier(id)).balancePiasters, 0);
    expect(
      errValue<void, SupplierPaymentError>(
        await env.suppliers.cancelPayment(paid.id, 'again'),
      ),
      const SupplierPaymentAlreadyCancelled(),
    );

    // A payment made with a purchase is undone by voiding the purchase.
    final tea = await env.products.addProduct('شاي');
    await env.purchases.create(
      await env.draftFor({
        tea: (one, 1000),
      }, supplier: PurchaseSupplier(id: id, name: 'a')),
    );
    final withPurchase = (await env.statement(id))
        .firstWhere((e) => e.type == SupplierEntryType.payment);
    expect(withPurchase.paymentNumber, isNull);
    expect(withPurchase.cancellable, isFalse);
    expect(
      errValue<void, SupplierPaymentError>(
        await env.suppliers.cancelPayment(withPurchase.id, 'r'),
      ),
      const SupplierPaymentNotCancellable(),
    );
  });

  test('statement pages continue from the cursor', () async {
    final id = await env.addSupplier('a', opening: '1');
    for (var i = 0; i < 4; i++) {
      await env.suppliers.pay(id, payment('1'));
    }
    final first = await env.suppliers.statement(id, limit: 2);
    final rest = await env.suppliers.statement(
      id,
      before: first.last.cursor,
      limit: 10,
    );
    expect(first.map((e) => e.paymentNumber), [4, 3]);
    expect(rest.map((e) => e.paymentNumber), [2, 1, null]);
    expect(rest.last.runningBalancePiasters, 100);
  });

  test('statement changes fire for every new row', () async {
    final id = await env.addSupplier('a');
    final events = <void>[];
    final sub = env.suppliers.watchStatementChanges(id).listen(events.add);
    await pumpEventQueue();
    await env.suppliers.pay(id, payment('5'));
    await pumpEventQueue();
    await sub.cancel();
    expect(events, hasLength(2));
  });
}
