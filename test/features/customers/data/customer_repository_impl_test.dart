import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/customer.dart';
import 'package:daftar_afandi/features/customers/domain/customer_draft.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/customer_repository.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import '../../sales/data/sales_env.dart';

PaymentRequest pay(String amount, [PaymentMethod m = PaymentMethod.cash]) =>
    okValue<PaymentRequest, List<CustomerFieldError>>(
      PaymentRequest.create(amountText: amount, method: m),
    );

void main() {
  late SalesEnv env;
  setUp(() => env = SalesEnv());
  tearDown(() => env.dispose());

  Future<List<CustomerSummary>> list([
    CustomerQuery q = const CustomerQuery(),
  ]) => env.customers.watchActive(q).first;

  test('create with an opening balance owed, or in their favour', () async {
    final a = await env.addCustomer(
      'أحمد',
      phone: '01012345678',
      opening: '50',
    );
    final b = await env.addCustomer('بسمة', opening: '20', inFavour: true);
    final c = await env.addCustomer('Carl');
    expect((await env.customer(a)).balancePiasters, 5000);
    expect((await env.customer(b)).balancePiasters, -2000);
    expect((await env.customer(c)).balancePiasters, 0);
    expect(
      (await env.statement(a)).single.type,
      LedgerEntryType.openingBalance,
    );
    expect(await env.statement(c), isEmpty);
    expect((await list()).map((s) => s.customer.name), [
      'أحمد',
      'بسمة',
      'Carl',
    ]);
  });

  test('search by folded name and by phone digits; owes filter', () async {
    await env.addCustomer('أحمد', phone: '01012345678', opening: '10');
    await env.addCustomer('محمد', opening: '90');
    await env.addCustomer('علي', opening: '5', inFavour: true);
    String names(List<CustomerSummary> l) =>
        l.map((s) => s.customer.name).join(',');
    expect(names(await list(const CustomerQuery(text: 'احمد'))), 'أحمد');
    expect(names(await list(const CustomerQuery(text: '٠١٠١٢'))), 'أحمد');
    expect(names(await list(const CustomerQuery(owesOnly: true))), 'محمد,أحمد');
  });

  test('the total owing adds balances above 0, archived ones too', () async {
    final a = await env.addCustomer('أحمد', opening: '10');
    await env.addCustomer('محمد', opening: '90');
    await env.addCustomer('علي', opening: '5', inFavour: true);
    expect(await env.customers.watchTotalOwing().first, 10000);
    await env.customers.receivePayment(a, pay('4'));
    expect(await env.customers.watchTotalOwing().first, 9600);
    await env.customers.archive(a);
    expect(await env.customers.watchTotalOwing().first, 9600);
  });

  test(
    'purge: only archived customers with no history, after 7 days',
    () async {
      final bare = await env.addCustomer('بلا حركة');
      final owed = await env.addCustomer('عليه رصيد', opening: '10');
      final active = await env.addCustomer('نشط');
      await env.customers.archive(bare);
      await env.customers.archive(owed);
      final archived = await env.customers.watchArchived().first;
      final bareRow = archived.firstWhere((s) => s.customer.id == bare);
      expect(bareRow.hasHistory, isFalse);
      expect(bareRow.purgeAt, isNotNull);
      expect(archived.firstWhere((s) => s.customer.id == owed).purgeAt, isNull);

      expect(await env.customers.purgeArchived(), 0);
      env.products.clock.advance(const Duration(days: 7));
      expect(await env.customers.purgeArchived(), 1);
      expect(await env.customers.watchOne(bare).first, isNull);
      expect(await env.customers.watchOne(owed).first, isNotNull);
      expect(await env.customers.watchOne(active).first, isNotNull);
    },
  );

  test('a same name saves with a notice; edit keeps the balance', () async {
    await env.addCustomer('أحمد');
    final r = await env.customers.create(
      const CustomerDraft(name: 'احمد', openingBalancePiasters: 700),
    );
    final saved = okValue(r);
    expect(saved.nameExistsElsewhere, isTrue);
    await env.customers.update(
      saved.id,
      const CustomerDraft(name: 'أحمد الثاني', phone: '0123456789'),
    );
    final s = await env.customer(saved.id);
    expect(s.customer.name, 'أحمد الثاني');
    expect(s.customer.phone, '0123456789');
    expect(s.balancePiasters, 700);
    expect(
      await env.customers.update('nope', const CustomerDraft(name: 'x')),
      const Err<CustomerSaved, CustomerSaveError>(CustomerNotFound()),
    );
  });

  test('archive hides, restore brings back', () async {
    final id = await env.addCustomer('أحمد', opening: '5');
    await env.customers.archive(id);
    expect(await list(), isEmpty);
    expect(
      (await env.customers.watchArchived().first).single.balancePiasters,
      500,
    );
    expect((await env.customer(id)).customer.archived, isTrue);
    await env.customers.restore(id);
    expect(await list(), hasLength(1));
  });

  test('payments get receipt numbers 1, 2; cancel once', () async {
    final id = await env.addCustomer('أحمد', opening: '60');
    expect(
      okValue(
        await env.customers.receivePayment(id, pay('25', PaymentMethod.wallet)),
      ),
      1,
    );
    expect(okValue(await env.customers.receivePayment(id, pay('5'))), 2);
    expect((await env.customer(id)).balancePiasters, 3000);

    var rows = await env.statement(id);
    final first = rows.firstWhere((e) => e.receiptNumber == 1);
    expect(first.method, PaymentMethod.wallet);
    expect(first.cancellable, isTrue);
    expect(rows.first.runningBalancePiasters, 3000);
    expect(rows.last.runningBalancePiasters, 6000);

    expect(
      await env.customers.cancelPayment(first.id, 'خطأ'),
      const Ok<void, PaymentError>(null),
    );
    expect((await env.customer(id)).balancePiasters, 5500);
    expect(
      await env.customers.cancelPayment(first.id, 'خطأ'),
      const Err<void, PaymentError>(PaymentAlreadyCancelled()),
    );
    rows = await env.statement(id);
    expect(rows.first.type, LedgerEntryType.reversal);
    expect(rows.first.amountPiasters, 2500);
    expect(rows.first.note, 'خطأ');
    expect(rows.firstWhere((e) => e.id == first.id).reversed, isTrue);
    // The opening row is not a payment.
    expect(
      await env.customers.cancelPayment(rows.last.id, 'x'),
      const Err<void, PaymentError>(PaymentNotCancellable()),
    );
  });

  test('no payment for an archived or missing customer', () async {
    final id = await env.addCustomer('أحمد');
    await env.customers.archive(id);
    expect(
      await env.customers.receivePayment(id, pay('1')),
      const Err<int, PaymentError>(PaymentCustomerArchived()),
    );
    expect(
      await env.customers.receivePayment('nope', pay('1')),
      const Err<int, PaymentError>(PaymentCustomerNotFound()),
    );
  });

  test('the statement pages newest first without gaps', () async {
    final id = await env.addCustomer('أحمد', opening: '100');
    for (var i = 0; i < 7; i++) {
      await env.customers.receivePayment(id, pay('1'));
    }
    final all = await env.statement(id);
    final p1 = await env.customers.statement(id, limit: 3);
    final p2 = await env.customers.statement(
      id,
      before: p1.last.cursor,
      limit: 3,
    );
    final p3 = await env.customers.statement(
      id,
      before: p2.last.cursor,
      limit: 3,
    );
    expect([...p1, ...p2, ...p3], all);
    expect(all, hasLength(8));
  });
}
