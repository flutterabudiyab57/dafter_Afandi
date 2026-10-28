import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/expenses/domain/expense.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_draft.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_errors.dart';
import 'package:daftar_afandi/features/payments/data/account_suggestions_repository_impl.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_errors.dart';
import 'package:daftar_afandi/features/reports/data/reports_repository_impl.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../expenses/data/expenses_env.dart';
import '../../products/data/products_env.dart';
import '../../purchases/data/purchases_env.dart';
import '../../sales/data/sales_env.dart' show one;

/// 300 cash, 200 wallet to 01012345678 and, when [instapay] is given, that
/// much by InstaPay to shop@instapay.
List<PaymentPartInput> _parts({String cash = '300', String instapay = ''}) => [
  PaymentPartInput(method: PaymentMethod.cash, amountText: cash),
  const PaymentPartInput(
    method: PaymentMethod.wallet,
    amountText: '200',
    accountText: '٠١٠١٢٣٤٥٦٧٨',
  ),
  if (instapay.isNotEmpty)
    PaymentPartInput(
      method: PaymentMethod.instapay,
      amountText: instapay,
      accountText: ' shop@instapay ',
    ),
];

const _three = [
  PaymentPart(method: PaymentMethod.cash, amountPiasters: 30000),
  PaymentPart(
    method: PaymentMethod.wallet,
    amountPiasters: 20000,
    accountRef: '01012345678',
  ),
  PaymentPart(
    method: PaymentMethod.instapay,
    amountPiasters: 10000,
    accountRef: 'shop@instapay',
  ),
];

PaymentSplit _split(int total, List<PaymentPartInput> inputs) =>
    okValue<PaymentSplit, List<PaymentSplitError>>(
      PaymentSplit.create(totalPiasters: total, inputs: inputs),
    );

void main() {
  group('on the sales and purchases database', () {
    late PurchasesEnv env;
    late String pen;

    setUp(() async {
      env = PurchasesEnv();
      // 50.00 each.
      pen = await env.products.addProduct(
        'قلم',
        price: '50',
        openingQty: '100',
        openingCost: '30',
      );
    });
    tearDown(() => env.dispose());

    Future<SaleDraft> sale600({SaleCustomer? customer}) async =>
        (await env.sales.draftFor({
          pen: 12 * one,
        }, customer: customer)).withPayment(_parts(instapay: '100'));

    test('a 3-part sale: header method is part 1; invoice and statement '
        'show every part (US6-3)', () async {
      final c = await env.sales.addCustomer('منى');
      final saved = okValue<SaleSaved, SaleSaveError>(
        await env.sales.sales.create(
          await sale600(
            customer: SaleCustomer(id: c, name: 'منى'),
          ),
        ),
      );
      final invoice = (await env.sales.sales.watchOne(saved.id).first)!;
      expect(invoice.method, PaymentMethod.cash);
      expect(invoice.parts, _three);

      final payment = (await env.sales.statement(c))
          .firstWhere((e) => e.type == LedgerEntryType.payment);
      expect(payment.parts, _three);
    });

    test('parts that do not add up are refused and nothing is written '
        '(US6-5, 6)', () async {
      final over = (await sale600()).withPayment(_parts(cash: '500'));
      final r = await env.sales.sales.create(over);
      expect(
        errValue(r),
        const SaleInvalid([
          SalePaymentInvalid([SumMismatch(10000)]),
        ]),
      );
      final zero = (await sale600()).withPayment([
        const PaymentPartInput(method: PaymentMethod.cash, amountText: '0'),
        const PaymentPartInput(method: PaymentMethod.cash, amountText: '600'),
      ]);
      expect(
        errValue(await env.sales.sales.create(zero)),
        const SaleInvalid([
          SalePaymentInvalid([PartAmountZero(0), MethodRepeated(1)]),
        ]),
      );
      expect(await env.stock(pen), 100 * one);
    });

    test('a customer receipt in 3 parts', () async {
      final c = await env.sales.addCustomer('منى', opening: '600');
      final request = okValue<PaymentRequest, List<CustomerFieldError>>(
        PaymentRequest.create(amountText: '600', method: PaymentMethod.cash),
      ).withSplit(_split(60000, _parts(instapay: '100')));
      okValue<int, PaymentError>(
        await env.sales.customers.receivePayment(c, request),
      );
      final row = (await env.sales.statement(c)).first;
      expect(row.method, PaymentMethod.cash);
      expect(row.parts, _three);
      expect((await env.sales.customer(c)).balancePiasters, 0);
    });

    test('a purchase and a supplier payment in 3 parts', () async {
      final s = await env.addSupplier('النور', opening: '600');
      final draft = (await env.draftFor(
        {pen: (20 * one, 3000)},
        supplier: PurchaseSupplier(id: s, name: 'النور'),
      )).withPayment(_parts(instapay: '100'));
      final saved = okValue<PurchaseSaved, PurchaseSaveError>(
        await env.purchases.create(draft),
      );
      expect((await env.purchases.watchOne(saved.id).first)!.parts, _three);

      final request = okValue<PaymentRequest, List<CustomerFieldError>>(
        PaymentRequest.create(amountText: '600', method: PaymentMethod.cash),
      ).withSplit(_split(60000, _parts(instapay: '100')));
      okValue<int, SupplierPaymentError>(await env.suppliers.pay(s, request));

      final rows = (await env.statement(s))
          .where((e) => e.type == SupplierEntryType.payment)
          .toList();
      expect(rows, hasLength(2));
      expect(rows.map((e) => e.parts), everyElement(_three));
    });

    test('money collected counts each part under its method; a voided '
        'split sale counts nothing (US5-5, US6-8)', () async {
      final clock = FixedClock(DateTime.utc(2026, 10, 20, 10));
      final reports = ReportsRepositoryImpl(env.products.db.reportsDao, clock);
      final split = okValue<SaleSaved, SaleSaveError>(
        await env.sales.sales.create(
          (await env.sales.draftFor({pen: 10 * one})).withPayment(_parts()),
        ),
      );
      final today = ReportPeriod.of(ReportPeriodKind.today, clock);
      var c = await reports.watchCollected(today).first;
      expect(c.of(PaymentMethod.cash), 30000);
      expect(c.of(PaymentMethod.wallet), 20000);

      await env.sales.sales.voidSale(split.id, 'خطأ');
      c = await reports.watchCollected(today).first;
      expect(c.totalPiasters, 0);
    });

    test('account suggestions: per method, most recent first, at most 5, '
        'none for cash', () async {
      final c = await env.sales.addCustomer('منى', opening: '10000');
      Future<void> receive(PaymentMethod m, String account) async {
        final request =
            okValue<PaymentRequest, List<CustomerFieldError>>(
              PaymentRequest.create(amountText: '1', method: m),
            ).withSplit(
              _split(100, [PaymentPartInput(method: m, accountText: account)]),
            );
        okValue<int, PaymentError>(
          await env.sales.customers.receivePayment(c, request),
        );
      }

      for (var i = 1; i <= 6; i++) {
        await receive(PaymentMethod.wallet, '0100000000$i');
      }
      // Used again: it moves to the front, once.
      await receive(PaymentMethod.wallet, '01000000002');
      await receive(PaymentMethod.instapay, 'me@ipa');
      await receive(PaymentMethod.cash, '');

      final repo = AccountSuggestionsRepositoryImpl(
        env.products.db.paymentPartsDao,
      );
      final wallet = await repo.suggestions(PaymentMethod.wallet);
      expect(wallet.map((s) => s.accountRef), [
        '01000000002',
        '01000000006',
        '01000000005',
        '01000000004',
        '01000000003',
      ]);
      expect(
        (await repo.suggestions(PaymentMethod.instapay)).single.accountRef,
        'me@ipa',
      );
      expect(await repo.suggestions(PaymentMethod.cash), isEmpty);
    });
  });

  test('an expense in 3 parts', () async {
    final env = ExpensesEnv();
    addTearDown(env.dispose);
    final rent = await env.addCategory('إيجار');
    final draft = okValue<ExpenseDraft, List<ExpenseFieldError>>(
      ExpenseDraft.create(
        categoryId: rent,
        amountText: '600',
        spentOn: ExpensesEnv.today,
        today: ExpensesEnv.today,
        parts: _parts(instapay: '100'),
      ),
    );
    final saved = okValue<ExpenseSaved, ExpenseSaveError>(
      await env.expenses.create(draft),
    );
    expect((await env.expenses.watchOne(saved.id).first)!.parts, _three);
  });
}
