import 'dart:math';

import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/daos/purchases_dao.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/adjustment.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_errors.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/database/test_database.dart';
import '../../products/data/products_env.dart';
import '../../sales/data/sales_env.dart' show one;
import 'purchases_env.dart';

/// Fails on the second line, after the header and first line are written.
final class _FailingPurchasesDao extends PurchasesDao {
  _FailingPurchasesDao(super.db);

  var _items = 0;

  @override
  Future<void> insertItem(PurchaseItemsCompanion row) {
    if (++_items == 2) throw StateError('boom');
    return super.insertItem(row);
  }
}

void main() {
  late PurchasesEnv env;
  late String tea;
  late String flour;

  Future<void> setUpEnv([PurchasesEnv? custom]) async {
    env = custom ?? PurchasesEnv();
    // Sells at 12.50; 10 in stock at 9.00.
    tea = await env.products.addProduct(
      'شاي',
      price: '12.50',
      openingQty: '10',
      openingCost: '9',
    );
    // Sells at 40.00 a kg; 5 kg at 30.00.
    flour = await env.products.addProduct(
      'دقيق',
      unit: UnitType.kg,
      price: '40',
      openingQty: '5',
      openingCost: '30',
    );
  }

  setUp(setUpEnv);
  tearDown(() => env.dispose());

  Future<PurchaseSaved> buy(PurchaseDraft d) async =>
      okValue<PurchaseSaved, PurchaseSaveError>(await env.purchases.create(d));

  Future<Purchase> purchase(String id) async =>
      (await env.purchases.watchOne(id).first)!;

  Future<int> replay(String id) =>
      env.products.inventory.rebuildAverageCost(id);

  test('cash purchase with no supplier: number, lines, stock, cost', () async {
    final saved = await buy(await env.draftFor({tea: (10 * one, 1100)}));
    expect(saved.number, 1);
    expect(await env.stock(tea), 20 * one);
    // 10 at 9.00 and 10 at 11.00.
    expect(await env.avgCost(tea), 1000);

    final p = await purchase(saved.id);
    expect(p.summary.totalPiasters, 11000);
    expect(p.summary.kind, PurchaseKind.cash);
    expect(p.summary.supplierName, isNull);
    expect(p.method, PaymentMethod.cash);
    expect(p.items.single.name, 'شاي');
    expect(p.items.single.unit, UnitType.piece);
    expect(p.items.single.lineTotalPiasters, 11000);

    final item = (await env.products.db.purchasesDao.items(saved.id)).single;
    expect(item.avgCostBeforePiasters, 900);
    expect(item.avgCostAfterPiasters, 1000);
    expect(item.netLineCostPiasters, 11000);
    final last = (await env.products.inventory.history(tea)).first;
    expect(last.type, StockEntryType.purchase);
    expect(last.qtyDeltaMilli, 10 * one);
    expect(last.unitCostPiasters, 1100);
    expect(
      await env.products.db.rows('SELECT * FROM supplier_ledger'),
      isEmpty,
    );
    expect(await replay(tea), 1000);
  });

  test('with a supplier: cash, partial and credit rows', () async {
    final s = await env.addSupplier('شركة النور');
    final nour = PurchaseSupplier(id: s, name: 'شركة النور');
    final d = await env.draftFor({tea: (one, 1000)}, supplier: nour);

    await buy(d.withMethod(PaymentMethod.instapay));
    expect((await env.supplier(s)).balancePiasters, 0);
    await buy(d.withPaid(400));
    expect((await env.supplier(s)).balancePiasters, 600);
    final credit = await buy(d.withPaid(0));
    expect((await env.supplier(s)).balancePiasters, 1600);
    expect((await purchase(credit.id)).summary.kind, PurchaseKind.credit);

    final rows = await env.statement(s);
    expect(rows.map((e) => (e.type, e.amountPiasters, e.purchaseNumber)), [
      (SupplierEntryType.purchase, 1000, 3),
      (SupplierEntryType.payment, -400, 2),
      (SupplierEntryType.purchase, 1000, 2),
      (SupplierEntryType.payment, -1000, 1),
      (SupplierEntryType.purchase, 1000, 1),
    ]);
    expect(rows.last.purchaseId, isNotNull);
    expect(rows[3].method, PaymentMethod.instapay);
    expect(rows[3].paymentNumber, isNull);
  });

  test("the invoice discount enters each line's cost by its share", () async {
    // 100.00 of tea and 300.00 of flour, less 40.00: 90.00 and 270.00.
    final saved = await buy(
      (await env.draftFor({tea: (10 * one, 1000), flour: (one, 30000)}))
          .withInvoiceDiscount(4000),
    );
    final items = await env.products.db.purchasesDao.items(saved.id);
    expect(items.map((i) => i.invoiceDiscountSharePiasters), [1000, 3000]);
    expect(items.map((i) => i.netLineCostPiasters), [9000, 27000]);
    expect(await env.avgCost(tea), 900);
    // 5 kg at 30.00 and 1 kg for 270.00 → 70.00.
    expect(await env.avgCost(flour), 7000);
    expect(
      (await env.products.inventory.history(tea)).first.unitCostPiasters,
      900,
    );
    expect(await replay(flour), 7000);
  });

  test('into zero or negative stock the line sets its own cost', () async {
    final fresh = await env.products.addProduct('سكر');
    await buy(await env.draftFor({fresh: (3 * one, 500)}));
    expect(await env.avgCost(fresh), 500);

    await env.sales.sales.create(
      await env.sales.draftFor({tea: 12 * one}),
      acknowledgeShortage: true,
    );
    expect(await env.stock(tea), -2 * one);
    await buy(await env.draftFor({tea: (5 * one, 1300)}));
    expect(await env.avgCost(tea), 1300);
    expect(await replay(tea), 1300);
  });

  test('the same product bought twice blends in save order', () async {
    await buy(await env.draftFor({tea: (10 * one, 1100)}));
    await buy(await env.draftFor({tea: (20 * one, 1300)}));
    // 20 at 10.00 and 20 at 13.00.
    expect(await env.avgCost(tea), 1150);
    expect(await replay(tea), 1150);
  });

  test('blocked purchases write nothing and take no number', () async {
    final s = await env.addSupplier('a');
    final d = await env.draftFor({tea: (one, 1000)});

    expect(
      errValue<PurchaseSaved, PurchaseSaveError>(
        await env.purchases.create(d.withPaid(0)),
      ),
      const PurchaseInvalid([CreditNeedsSupplier()]),
    );
    expect(
      errValue<PurchaseSaved, PurchaseSaveError>(
        await env.purchases.create(d.withInvoiceDate(DateTime(2026, 12, 1))),
      ),
      const PurchaseInvalid([PurchaseDateInFuture()]),
    );
    await env.suppliers.archive(s);
    expect(
      errValue<PurchaseSaved, PurchaseSaveError>(
        await env.purchases.create(
          d.withSupplier(PurchaseSupplier(id: s, name: 'a')),
        ),
      ),
      const SupplierUnavailable(),
    );
    await env.products.productRepo.archive(tea);
    expect(
      errValue<PurchaseSaved, PurchaseSaveError>(await env.purchases.create(d)),
      const PurchaseProductUnavailable('شاي'),
    );

    expect(await env.purchases.watchList(const PurchaseQuery()).first, isEmpty);
    expect(await env.stock(tea), 10 * one);
    expect((await buy(await env.draftFor({flour: (one, 100)}))).number, 1);
  });

  test('a failure mid-way rolls back the number and every write', () async {
    await env.dispose();
    await setUpEnv(
      PurchasesEnv(purchasesDao: (e) => _FailingPurchasesDao(e.products.db)),
    );
    final d = await env.draftFor({tea: (one, 1000), flour: (one, 1000)});
    await expectLater(env.purchases.create(d), throwsStateError);
    expect(await env.stock(tea), 10 * one);
    expect(await env.avgCost(tea), 900);
    expect(await env.products.db.rows('SELECT * FROM purchase_items'), isEmpty);
    expect((await buy(await env.draftFor({tea: (one, 1000)}))).number, 1);
    expect((await buy(await env.draftFor({tea: (one, 1000)}))).number, 2);
  });

  test('lastUnitCost: the newest purchase line that is not voided', () async {
    expect(await env.purchases.lastUnitCost(tea), isNull);
    final first = await buy(await env.draftFor({tea: (one, 1100)}));
    final second = await buy(
      await env.draftFor({tea: (one, 1200), flour: (one, 100)}),
    );
    expect(await env.purchases.lastUnitCost(tea), 1200);
    await env.purchases.voidPurchase(second.id, 'r');
    expect(await env.purchases.lastUnitCost(tea), 1100);
    await env.purchases.voidPurchase(first.id, 'r');
    expect(await env.purchases.lastUnitCost(tea), isNull);
  });

  test('void: stock, cost and balance as if never bought, once', () async {
    final s = await env.addSupplier('شركة النور');
    final first = await buy(
      (await env.draftFor({
        tea: (10 * one, 1100),
      }, supplier: PurchaseSupplier(id: s, name: 'n'))).withPaid(4000),
    );
    await buy(await env.draftFor({tea: (10 * one, 1200)}));
    expect(await env.avgCost(tea), 1067);
    expect((await env.supplier(s)).balancePiasters, 7000);

    expect(
      errValue<void, PurchaseVoidError>(
        await env.purchases.voidPurchase(first.id, '  '),
      ),
      const PurchaseVoidReasonInvalid(),
    );
    expect(
      errValue<void, PurchaseVoidError>(
        await env.purchases.voidPurchase('missing', 'r'),
      ),
      const PurchaseNotFound(),
    );
    expect(
      await env.purchases.voidPurchase(first.id, '  خطأ  '),
      isA<Ok<void, PurchaseVoidError>>(),
    );

    expect(await env.stock(tea), 20 * one);
    // 10 at 9.00 and 10 at 12.00, without the voided 10 at 11.00.
    expect(await env.avgCost(tea), 1050);
    expect(await replay(tea), 1050);
    final history = await env.products.inventory.history(tea);
    expect(history.first.type, StockEntryType.purchaseVoid);
    expect(history.first.qtyDeltaMilli, -10 * one);
    expect(history.first.unitCostPiasters, 1100);

    expect((await env.supplier(s)).balancePiasters, 0);
    final rows = await env.statement(s);
    expect(rows.take(2).map((e) => (e.type, e.amountPiasters, e.note)), [
      (SupplierEntryType.reversal, 4000, 'خطأ'),
      (SupplierEntryType.purchaseVoid, -11000, 'خطأ'),
    ]);
    expect(rows.skip(2).every((e) => e.reversed), isTrue);

    final p = await purchase(first.id);
    expect(p.summary.voided, isTrue);
    expect(p.voidReason, 'خطأ');
    expect(p.voidedAt, isNotNull);
    expect(
      errValue<void, PurchaseVoidError>(
        await env.purchases.voidPurchase(first.id, 'again'),
      ),
      const PurchaseAlreadyVoided(),
    );
  });

  test('a void that takes stock below zero needs acknowledgement', () async {
    final sugar = await env.products.addProduct('سكر');
    final saved = await buy(await env.draftFor({sugar: (5 * one, 500)}));
    await env.sales.sales.create(await env.sales.draftFor({sugar: 4 * one}));

    expect(
      errValue<void, PurchaseVoidError>(
        await env.purchases.voidPurchase(saved.id, 'r'),
      ),
      VoidStockShortage([
        VoidShortage(
          productId: sugar,
          name: 'سكر',
          unit: UnitType.piece,
          stockAfterMilli: -4 * one,
        ),
      ]),
    );
    expect(await env.stock(sugar), one);
    expect((await purchase(saved.id)).summary.voided, isFalse);

    await env.purchases.voidPurchase(saved.id, 'r', acknowledgeShortage: true);
    expect(await env.stock(sugar), -4 * one);
    expect(await env.avgCost(sugar), await replay(sugar));
  });

  test('an archived product or supplier does not block a void', () async {
    final s = await env.addSupplier('a');
    final saved = await buy(
      (await env.draftFor({
        flour: (one, 3000),
      }, supplier: PurchaseSupplier(id: s, name: 'a'))).withPaid(0),
    );
    await env.products.productRepo.archive(flour);
    await env.suppliers.archive(s);
    expect(
      await env.purchases.voidPurchase(saved.id, 'r'),
      isA<Ok<void, PurchaseVoidError>>(),
    );
    expect((await env.supplier(s)).balancePiasters, 0);
  });

  test('list: number, supplier, their invoice number, filters', () async {
    final s = await env.addSupplier('شركة النور');
    final nour = PurchaseSupplier(id: s, name: 'شركة النور');
    final d = await env.draftFor({tea: (one, 1000)});
    await buy(d);
    await buy(
      d
          .withSupplier(nour)
          .withSupplierRef('INV-٧٧')
          .withPaid(0)
          .withInvoiceDate(DateTime(2026, 10, 1)),
    );
    await buy(d.withSupplier(nour));

    Future<List<int>> numbers(PurchaseQuery q, {int limit = 50}) async =>
        (await env.purchases.watchList(q, limit: limit).first)
            .map((p) => p.number)
            .toList();
    // Newest invoice date first, then the newest number.
    expect(await numbers(const PurchaseQuery()), [3, 1, 2]);
    expect(await numbers(const PurchaseQuery(text: 'P-000002')), [2]);
    expect(await numbers(const PurchaseQuery(text: 'النور')), [3, 2]);
    expect(await numbers(const PurchaseQuery(text: 'inv-77')), [2]);
    expect(await numbers(const PurchaseQuery(unpaidOnly: true)), [2]);
    expect(await numbers(PurchaseQuery(supplierId: s)), [3, 2]);
    expect(await numbers(const PurchaseQuery(), limit: 1), [3]);

    final row =
        (await env.purchases.watchList(const PurchaseQuery(text: '2')).first)
            .single;
    expect(row.supplierName, 'شركة النور');
    expect(row.supplierRef, 'INV-77');
    expect(row.invoiceDate, DateTime(2026, 10, 1));
    expect(row.kind, PurchaseKind.credit);
  });

  test(
    'property: balance = ledger sum, stock = movements, cost = replay',
    () async {
      final random = Random(11);
      final suppliers = [
        for (var i = 0; i < 3; i++)
          await env.addSupplier('s$i', opening: '${i + 1}'),
      ];
      final purchases = <String>[];
      final sales = <String>[];
      for (var step = 0; step < 80; step++) {
        final roll = random.nextInt(12);
        if (roll < 4) {
          final s = random.nextBool()
              ? null
              : suppliers[random.nextInt(suppliers.length)];
          var d = await env.draftFor({
            tea: ((1 + random.nextInt(5)) * one, random.nextInt(2000)),
            if (random.nextBool())
              flour: (1 + random.nextInt(3000), random.nextInt(50000)),
          }, supplier: s == null ? null : PurchaseSupplier(id: s, name: s));
          d = d.withInvoiceDiscount(random.nextInt(d.subtotal + 1));
          if (s != null) d = d.withPaid(random.nextInt(d.total + 1));
          purchases.add((await buy(d)).id);
        } else if (roll < 6) {
          final r = await env.sales.sales.create(
            await env.sales.draftFor({tea: (1 + random.nextInt(4)) * one}),
            acknowledgeShortage: true,
          );
          sales.add(okValue(r).id);
        } else if (roll < 7 && purchases.isNotEmpty) {
          await env.purchases.voidPurchase(
            purchases[random.nextInt(purchases.length)],
            'r',
            acknowledgeShortage: true,
          );
        } else if (roll < 8 && sales.isNotEmpty) {
          await env.sales.sales.voidSale(
            sales[random.nextInt(sales.length)],
            'r',
          );
        } else if (roll < 10) {
          final s = suppliers[random.nextInt(suppliers.length)];
          await env.suppliers.pay(
            s,
            okValue<PaymentRequest, List<CustomerFieldError>>(
              PaymentRequest.create(
                amountText: '${1 + random.nextInt(30)}',
                method: PaymentMethod.cash,
              ),
            ),
          );
          if (random.nextBool()) {
            final p = (await env.statement(s))
                .where((e) => e.cancellable)
                .firstOrNull;
            if (p != null) await env.suppliers.cancelPayment(p.id, 'r');
          }
        } else {
          final product = random.nextBool() ? tea : flour;
          final unit = product == tea ? UnitType.piece : UnitType.kg;
          await env.products.inventory.adjust(
            product,
            okValue<AdjustmentRequest, List<AdjustmentError>>(
              AdjustmentRequest.other(
                qtyText: '${1 + random.nextInt(3)}',
                unit: unit,
                add: random.nextBool(),
                note: 'n',
              ),
            ),
          );
        }
      }
      expect(purchases, isNotEmpty);
      for (final s in suppliers) {
        final rows = await env.statement(s);
        final sum = rows.fold(0, (a, e) => a + e.amountPiasters);
        expect((await env.supplier(s)).balancePiasters, sum);
        expect(rows.first.runningBalancePiasters, sum);
      }
      for (final p in [tea, flour]) {
        final stored = await env.avgCost(p);
        expect(await replay(p), stored, reason: p);
        final history = await env.products.inventory.history(p, limit: 10000);
        expect(
          history.fold(0, (a, e) => a + e.qtyDeltaMilli),
          await env.stock(p),
        );
      }
    },
  );
}
