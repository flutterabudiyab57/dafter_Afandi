import 'dart:math';

import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/daos/sales_dao.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import 'sales_env.dart';

/// Fails on the second line, after the header and first line are written.
final class _FailingSalesDao extends SalesDao {
  _FailingSalesDao(super.db);

  var _items = 0;

  @override
  Future<void> insertItem(SaleItemsCompanion row) {
    if (++_items == 2) throw StateError('boom');
    return super.insertItem(row);
  }
}

void main() {
  late SalesEnv env;
  late String tea;
  late String flour;

  setUp(() async {
    env = SalesEnv();
    tea = await env.products.addProduct(
      'شاي',
      price: '12.50',
      openingQty: '10',
      openingCost: '9',
    );
    flour = await env.products.addProduct(
      'دقيق',
      unit: UnitType.kg,
      price: '40',
      openingQty: '5',
      openingCost: '30',
    );
  });
  tearDown(() => env.dispose());

  Future<int> stock(String id) async =>
      (await env.products.summary(id)).stockMilli;

  test('walk-in cash sale: number 1, lines, stock down, no ledger', () async {
    final draft = await env.draftFor({tea: 2 * one, flour: 750});
    final saved = okValue(await env.sales.create(draft));
    expect(saved.number, 1);
    expect(await stock(tea), 8000);
    expect(await stock(flour), 4250);

    final inv = (await env.sales.watchOne(saved.id).first)!;
    expect(inv.summary.totalPiasters, 2500 + 3000);
    expect(inv.summary.kind, SaleKind.cash);
    expect(inv.items.map((i) => i.name), ['شاي', 'دقيق']);
    expect(inv.items.last.qtyMilli, 750);
    expect(inv.items.last.lineTotalPiasters, 3000);
    expect(inv.method, PaymentMethod.cash);

    final two = okValue(await env.sales.create(draft));
    expect(two.number, 2);
  });

  test('partial sale to a customer: SALE and PAYMENT rows', () async {
    final c = await env.addCustomer('أحمد');
    final draft = (await env.draftFor(
      {tea: 8 * one},
      customer: SaleCustomer(id: c, name: 'أحمد'),
    )).withPaid(4000).withMethod(PaymentMethod.wallet);
    okValue(await env.sales.create(draft));
    expect((await env.customer(c)).balancePiasters, 10000 - 4000);
    final rows = await env.statement(c);
    expect(rows.map((r) => r.type), [
      LedgerEntryType.payment,
      LedgerEntryType.sale,
    ]);
    expect(rows.first.method, PaymentMethod.wallet);
    expect(rows.first.invoiceNumber, 1);
    expect(rows.first.receiptNumber, isNull);
    expect(rows.first.cancellable, isFalse);
  });

  test(
    'cash sale with a customer nets to zero but shows on the statement',
    () async {
      final c = await env.addCustomer('أحمد');
      okValue(
        await env.sales.create(
          await env.draftFor({
            tea: one,
          }, customer: SaleCustomer(id: c, name: 'أحمد')),
        ),
      );
      expect((await env.customer(c)).balancePiasters, 0);
      expect(await env.statement(c), hasLength(2));
    },
  );

  test('credit needs a customer; invalid drafts write nothing', () async {
    final draft = (await env.draftFor({tea: one})).withPaid(0);
    expect(
      await env.sales.create(draft),
      const Err<SaleSaved, SaleSaveError>(SaleInvalid([CreditNeedsCustomer()])),
    );
    expect(await stock(tea), 10000);
  });

  test('shortage needs acknowledgement; then stock goes below zero', () async {
    final draft = await env.draftFor({tea: 12 * one});
    final r = await env.sales.create(draft);
    expect(errValue(r), isA<StockShortage>());
    final s = (errValue(r) as StockShortage).items.single;
    expect([s.name, s.stockMilli, s.needMilli], ['شاي', 10000, 12000]);
    expect(await stock(tea), 10000);
    // No number was used.
    okValue(await env.sales.create(draft, acknowledgeShortage: true));
    expect(await stock(tea), -2000);
    expect(
      (await env.sales.watchList(const SaleQuery()).first).single.number,
      1,
    );
  });

  test('archived product or customer blocks the sale', () async {
    final c = await env.addCustomer('أحمد');
    final draft = await env.draftFor({
      tea: one,
    }, customer: SaleCustomer(id: c, name: 'أحمد'));
    await env.customers.archive(c);
    expect(
      await env.sales.create(draft),
      const Err<SaleSaved, SaleSaveError>(CustomerUnavailable()),
    );
    await env.products.productRepo.archive(tea);
    expect(
      await env.sales.create(draft),
      const Err<SaleSaved, SaleSaveError>(ProductUnavailable('شاي')),
    );
  });

  test(
    'a failure mid-way rolls everything back; no number is burned',
    () async {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      addTearDown(
        () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
      );
      final failing = SalesEnv(
        salesDao: (e) => _FailingSalesDao(e.products.db),
      );
      addTearDown(failing.dispose);
      final a = await failing.products.addProduct(
        'أ',
        openingQty: '5',
        openingCost: '1',
      );
      final b = await failing.products.addProduct(
        'ب',
        openingQty: '5',
        openingCost: '1',
      );
      final draft = await failing.draftFor({a: one, b: one});
      await expectLater(failing.sales.create(draft), throwsStateError);
      expect((await failing.products.summary(a)).stockMilli, 5000);
      expect(await failing.sales.watchList(const SaleQuery()).first, isEmpty);
      // The next sale (now with one line) gets number 1.
      final ok = okValue(
        await failing.sales.create(await failing.draftFor({a: one})),
      );
      expect(ok.number, 1);
    },
  );

  test('invoice discount shares and snapshots are stored', () async {
    final draft = (await env.draftFor({tea: 3 * one, flour: one}))
        .updateLine(tea, lineDiscountPiasters: 50)
        .withInvoiceDiscount(1000);
    final saved = okValue(await env.sales.create(draft));
    final items = await env.products.db.salesDao.items(saved.id);
    expect(
      items.map((i) => i.invoiceDiscountSharePiasters).fold(0, (a, b) => a + b),
      1000,
    );
    expect(items.first.unitCostPiasters, 900);
    expect(items.first.lineCostPiasters, 2700);
    await env.products.productRepo.update(
      tea,
      draftOf('شاي فاخر', price: '20'),
    );
    final inv = (await env.sales.watchOne(saved.id).first)!;
    expect(inv.items.first.name, 'شاي');
    expect(inv.items.first.unitPricePiasters, 1250);
    expect(inv.subtotalPiasters, 3750 - 50 + 4000);
    expect(inv.summary.totalPiasters, inv.subtotalPiasters - 1000);
  });

  test('void: stock back at the sale cost, balance restored, once', () async {
    final c = await env.addCustomer('أحمد', opening: '5');
    final draft = (await env.draftFor({
      tea: 3 * one,
    }, customer: SaleCustomer(id: c, name: 'أحمد'))).withPaid(1000);
    final saved = okValue(await env.sales.create(draft));
    expect((await env.customer(c)).balancePiasters, 500 + 3750 - 1000);

    expect(
      await env.sales.voidSale(saved.id, 'خطأ في العميل'),
      const Ok<void, VoidError>(null),
    );
    expect(await stock(tea), 10000);
    expect((await env.products.summary(tea)).product.avgCostPiasters, 900);
    expect((await env.customer(c)).balancePiasters, 500);
    final rows = await env.statement(c);
    expect(rows.take(2).map((r) => r.type).toSet(), {
      LedgerEntryType.saleVoid,
      LedgerEntryType.reversal,
    });

    final inv = (await env.sales.watchOne(saved.id).first)!;
    expect(inv.summary.voided, isTrue);
    expect(inv.voidReason, 'خطأ في العميل');
    expect(
      await env.sales.voidSale(saved.id, 'x'),
      const Err<void, VoidError>(AlreadyVoided()),
    );
    expect(
      await env.sales.voidSale('nope', 'x'),
      const Err<void, VoidError>(InvoiceNotFound()),
    );
    expect(
      await env.sales.watchList(const SaleQuery(unpaidOnly: true)).first,
      isEmpty,
    );
  });

  test('the void blends the sale cost into a changed average', () async {
    final saved = okValue(
      await env.sales.create(await env.draftFor({tea: 4 * one})),
    );
    // The stored average after the void must match a full replay.
    await env.sales.voidSale(saved.id, 'r');
    final avg = (await env.products.summary(tea)).product.avgCostPiasters;
    expect(await env.products.inventory.rebuildAverageCost(tea), avg);
  });

  test(
    'list: search by number and customer name, unpaid filter, limit',
    () async {
      final c = await env.addCustomer('أحمد');
      await env.sales.create(await env.draftFor({tea: one}));
      await env.sales.create(
        (await env.draftFor({
          tea: one,
        }, customer: SaleCustomer(id: c, name: 'أحمد'))).withPaid(0),
      );
      Future<List<int>> numbers(SaleQuery q, {int limit = 50}) async =>
          (await env.sales.watchList(q, limit: limit).first)
              .map((s) => s.number)
              .toList();
      expect(await numbers(const SaleQuery()), [2, 1]);
      expect(await numbers(const SaleQuery(text: 'S-000001')), [1]);
      expect(await numbers(const SaleQuery(text: 'احمد')), [2]);
      expect(await numbers(const SaleQuery(unpaidOnly: true)), [2]);
      expect(await numbers(SaleQuery(customerId: c)), [2]);
      expect(await numbers(const SaleQuery(), limit: 1), [2]);
      final row = (await env.sales.watchList(const SaleQuery()).first).first;
      expect(row.customerName, 'أحمد');
      expect(row.kind, SaleKind.credit);
    },
  );

  test(
    'property: balances = ledger sums, stock = movements, avg = replay',
    () async {
      final random = Random(7);
      final customers = [
        for (var i = 0; i < 3; i++) await env.addCustomer('c$i', opening: '$i'),
      ];
      final sales = <String>[];
      for (var step = 0; step < 60; step++) {
        final roll = random.nextInt(10);
        if (roll < 6) {
          final c = random.nextBool() ? null : customers[random.nextInt(3)];
          var d = await env.draftFor({
            tea: (1 + random.nextInt(3)) * one,
            if (random.nextBool()) flour: 1 + random.nextInt(2000),
          }, customer: c == null ? null : SaleCustomer(id: c, name: c));
          if (c != null) d = d.withPaid(random.nextInt(d.total + 1));
          final r = await env.sales.create(d, acknowledgeShortage: true);
          sales.add(okValue(r).id);
        } else if (roll < 8 && sales.isNotEmpty) {
          await env.sales.voidSale(sales[random.nextInt(sales.length)], 'r');
        } else {
          final c = customers[random.nextInt(3)];
          final r = await env.customers.receivePayment(
            c,
            okValue<PaymentRequest, List<CustomerFieldError>>(
              PaymentRequest.create(
                amountText: '${1 + random.nextInt(20)}',
                method: PaymentMethod.cash,
              ),
            ),
          );
          if (random.nextBool()) {
            final rows = await env.statement(c);
            final p = rows.where((e) => e.cancellable).firstOrNull;
            if (p != null && r is Ok) {
              await env.customers.cancelPayment(p.id, 'r');
            }
          }
        }
      }
      for (final c in customers) {
        final rows = await env.statement(c);
        final sum = rows.fold(0, (s, e) => s + e.amountPiasters);
        expect((await env.customer(c)).balancePiasters, sum);
        expect(rows.isEmpty ? 0 : rows.first.runningBalancePiasters, sum);
      }
      for (final p in [tea, flour]) {
        final stored = (await env.products.summary(p)).product.avgCostPiasters;
        expect(await env.products.inventory.rebuildAverageCost(p), stored);
        final history = await env.products.inventory.history(p, limit: 10000);
        expect(history.fold(0, (s, e) => s + e.qtyDeltaMilli), await stock(p));
      }
    },
  );
}
