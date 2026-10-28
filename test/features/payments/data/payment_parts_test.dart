import 'dart:math';

import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/payments/data/payment_parts_writer.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_errors.dart';
import 'package:daftar_afandi/features/sales/data/sales_repository_impl.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import '../../purchases/data/purchases_env.dart';
import '../../sales/data/sales_env.dart' show one;

/// Claims one piaster more than was paid, so the check refuses it.
final class _OffByOneWriter extends PaymentPartsWriter {
  const _OffByOneWriter(super.dao, super.ids);

  @override
  Future<void> write(
    PaymentParent parent,
    PaymentSplit split, {
    required int paidPiasters,
    required DateTime at,
  }) => super.write(parent, split, paidPiasters: paidPiasters + 1, at: at);
}

void main() {
  late PurchasesEnv env;
  late String tea;

  setUp(() async {
    env = PurchasesEnv();
    tea = await env.products.addProduct(
      'شاي',
      price: '12.50',
      openingQty: '100',
      openingCost: '9',
    );
  });
  tearDown(() => env.dispose());

  PaymentPartsWriter parts() => env.sales.parts;

  Future<String> sell(SaleDraft d) async => okValue<SaleSaved, SaleSaveError>(
    await env.sales.sales.create(d, acknowledgeShortage: true),
  ).id;

  PaymentRequest request(String amount, PaymentMethod method) =>
      okValue<PaymentRequest, List<CustomerFieldError>>(
        PaymentRequest.create(amountText: amount, method: method),
      );

  test('a paid sale has one part in its method; credit has none', () async {
    final cash = await sell(
      (await env.sales.draftFor({tea: 2 * one}))
          .withMethod(PaymentMethod.wallet),
    );
    expect(await parts().partsOf(SaleParent(cash)), [
      const PaymentPart(method: PaymentMethod.wallet, amountPiasters: 2500),
    ]);
    final invoice = await env.sales.sales.watchOne(cash).first;
    expect(invoice!.method, PaymentMethod.wallet);

    final mona = await env.sales.addCustomer('منى');
    final credit = await sell(
      (await env.sales.draftFor({
        tea: one,
      }, customer: SaleCustomer(id: mona, name: 'منى'))).withPaid(0),
    );
    expect(await parts().partsOf(SaleParent(credit)), isEmpty);

    final partial = await sell(
      (await env.sales.draftFor({
        tea: 4 * one,
      }, customer: SaleCustomer(id: mona, name: 'منى'))).withPaid(2000),
    );
    expect(await parts().partsOf(SaleParent(partial)), [
      const PaymentPart(method: PaymentMethod.cash, amountPiasters: 2000),
    ]);
  });

  test('a receipt and a supplier payment have their own part', () async {
    final mona = await env.sales.addCustomer('منى', opening: '100');
    await env.sales.customers.receivePayment(
      mona,
      request('25', PaymentMethod.instapay),
    );
    final receipt = (await env.sales.statement(mona))
        .firstWhere((e) => e.type == LedgerEntryType.payment);
    expect(await parts().partsOf(ReceiptParent(receipt.id)), [
      const PaymentPart(method: PaymentMethod.instapay, amountPiasters: 2500),
    ]);

    final nour = await env.addSupplier('النور', opening: '100');
    await env.suppliers.pay(nour, request('40', PaymentMethod.wallet));
    final payment = (await env.statement(nour))
        .firstWhere((e) => e.type == SupplierEntryType.payment);
    expect(await parts().partsOf(SupplierPaymentParent(payment.id)), [
      const PaymentPart(method: PaymentMethod.wallet, amountPiasters: 4000),
    ]);
  });

  test(
    'a purchase paid now has one part; its ledger payment has none',
    () async {
      final nour = await env.addSupplier('النور');
      final d = (await env.draftFor({
        tea: (10 * one, 900),
      }, supplier: PurchaseSupplier(id: nour, name: 'النور'))).withPaid(5000);
      final saved = okValue<PurchaseSaved, PurchaseSaveError>(
        await env.purchases.create(d),
      );
      expect(await parts().partsOf(PurchaseParent(saved.id)), [
        const PaymentPart(method: PaymentMethod.cash, amountPiasters: 5000),
      ]);
      for (final e in await env.statement(nour)) {
        expect(await parts().partsOf(SupplierPaymentParent(e.id)), isEmpty);
      }
    },
  );

  test('parts that do not add up roll back the whole sale', () async {
    final db = env.products.db;
    final broken = SalesRepositoryImpl(
      db.salesDao,
      db.productsDao,
      db.stockMovementsDao,
      db.customersDao,
      db.customerLedgerDao,
      db.countersDao,
      DriftTransactionRunner(db),
      env.products.ids,
      env.products.clock,
      _OffByOneWriter(db.paymentPartsDao, env.products.ids),
    );
    final stock = await env.stock(tea);
    await expectLater(
      broken.create(await env.sales.draftFor({tea: one})),
      throwsA(isA<PaymentPartsMismatch>()),
    );
    expect(await env.stock(tea), stock);
    final count = await db
        .customSelect('SELECT COUNT(*) AS n FROM sales_invoices')
        .getSingle();
    expect(count.read<int>('n'), 0);
    // The number was not used up.
    final next = await sell(await env.sales.draftFor({tea: one}));
    final invoice = await env.sales.sales.watchOne(next).first;
    expect(invoice!.summary.number, 1);
  });

  test('property: parts add up to what was paid, for every parent', () async {
    final rnd = Random(6);
    final mona = await env.sales.addCustomer('منى');
    final nour = await env.addSupplier('النور');
    final methods = offeredPaymentMethods;
    for (var i = 0; i < 60; i++) {
      final method = methods[rnd.nextInt(methods.length)];
      switch (rnd.nextInt(4)) {
        case 0:
          final d = (await env.sales.draftFor({
            tea: (1 + rnd.nextInt(5)) * one,
          }, customer: SaleCustomer(id: mona, name: 'منى'))).withMethod(method);
          await sell(d.withPaid(rnd.nextInt(d.total + 1)));
        case 1:
          await env.sales.customers.receivePayment(
            mona,
            request('${1 + rnd.nextInt(50)}', method),
          );
        case 2:
          final d = (await env.draftFor(
            {tea: ((1 + rnd.nextInt(5)) * one, 900)},
            supplier: PurchaseSupplier(id: nour, name: 'النور'),
          )).withMethod(method);
          await env.purchases.create(d.withPaid(rnd.nextInt(d.total + 1)));
        case 3:
          await env.suppliers.pay(
            nour,
            request('${1 + rnd.nextInt(50)}', method),
          );
      }
    }

    final mismatches = await env.products.db.customSelect('''
      SELECT 'sale' AS kind, s.id FROM sales_invoices s
        LEFT JOIN payment_parts p ON p.sales_invoice_id = s.id
        GROUP BY s.id HAVING COALESCE(SUM(p.amount_piasters), 0) != s.paid_at_sale_piasters
      UNION ALL
      SELECT 'purchase', u.id FROM purchase_invoices u
        LEFT JOIN payment_parts p ON p.purchase_invoice_id = u.id
        GROUP BY u.id HAVING COALESCE(SUM(p.amount_piasters), 0) != u.paid_piasters
      UNION ALL
      SELECT 'receipt', l.id FROM customer_ledger l
        LEFT JOIN payment_parts p ON p.customer_ledger_id = l.id
        GROUP BY l.id HAVING COALESCE(SUM(p.amount_piasters), 0) !=
          CASE WHEN l.receipt_number IS NULL THEN 0 ELSE -l.amount_piasters END
      UNION ALL
      SELECT 'payment', l.id FROM supplier_ledger l
        LEFT JOIN payment_parts p ON p.supplier_ledger_id = l.id
        GROUP BY l.id HAVING COALESCE(SUM(p.amount_piasters), 0) !=
          CASE WHEN l.payment_number IS NULL THEN 0 ELSE -l.amount_piasters END
      ''').get();
    expect(mismatches.map((r) => r.data), isEmpty);
    final methodsMatch = await env.products.db.customSelect('''
      SELECT COUNT(*) AS n FROM payment_parts p
        JOIN sales_invoices s ON s.id = p.sales_invoice_id
        WHERE p.part_no = 1 AND p.method != s.payment_method
      ''').getSingle();
    expect(methodsMatch.read<int>('n'), 0);
  });
}
