import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_errors.dart';
import 'package:daftar_afandi/features/purchases/presentation/cubits/purchase_cubit.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_purchases.dart';

void main() {
  late FakePurchasesStore store;
  late FakePurchasesCubits cubits;
  late String tea;
  late String flour;

  setUp(() {
    store = FakePurchasesStore();
    cubits = FakePurchasesCubits(store);
    tea = store.products.seedProduct(
      'شاي',
      pricePiasters: 1250,
      stockMilli: 10000,
      costPiasters: 900,
      barcode: '111',
    );
    flour = store.products.seedProduct(
      'دقيق',
      unit: UnitType.kg,
      pricePiasters: 4000,
      stockMilli: 5000,
      costPiasters: 3000,
    );
  });

  PurchaseDraft draftOf(String productId, int qtyMilli, int cost) {
    final p = store.products.summary(productId)!.product;
    return const PurchaseDraft()
        .add(
          productId: p.id,
          name: p.name,
          unit: p.unit,
          salePricePiasters: p.salePricePiasters,
          unitCostPiasters: cost,
        )
        .updateLine(p.id, qtyMilli: qtyMilli);
  }

  group('PurchaseCubit', () {
    test('cost: the last purchase, else the average cost', () async {
      final c = cubits.purchase();
      await c.addProduct(store.products.summary(tea)!);
      expect(c.state.draft.lines.single.unitCostPiasters, 900);

      store.seedPurchase(draftOf(tea, 1000, 1100));
      final d = cubits.purchase();
      await d.addProduct(store.products.summary(tea)!);
      expect(d.state.draft.lines.single.unitCostPiasters, 1100);
      // Again: one more unit, the typed cost is kept.
      d.costChanged(tea, '11.50');
      await d.addProduct(store.products.summary(tea)!);
      expect(d.state.draft.lines.single.qtyMilli, 2000);
      expect(d.state.draft.lines.single.unitCostPiasters, 1150);
      await c.close();
      await d.close();
    });

    test('typed numbers: kg decimals, piece fraction, empty qty', () async {
      final c = cubits.purchase();
      await c.addProduct(store.products.summary(tea)!);
      await c.addProduct(store.products.summary(flour)!);
      c.qtyChanged(flour, '٢٫٥');
      expect(c.state.draft.lineOf(flour)!.qtyMilli, 2500);
      c.qtyChanged(tea, '1.5');
      expect(
        c.state.inputError(PurchaseField.qty, tea),
        PurchaseInputProblem.notWhole,
      );
      c.qtyChanged(tea, '');
      expect(
        c.state.inputError(PurchaseField.qty, tea),
        PurchaseInputProblem.required,
      );
      c.costChanged(tea, 'abc');
      expect(
        c.state.inputError(PurchaseField.cost, tea),
        PurchaseInputProblem.invalid,
      );
      // Save does nothing while a field cannot be read.
      await c.submit();
      expect(store.writes, isEmpty);

      c
        ..qtyChanged(tea, '3')
        ..costChanged(tea, '0')
        ..lineDiscountChanged(tea, '');
      expect(c.state.inputErrors, isEmpty);
      expect(c.state.draft.lineOf(tea)!.unitCostPiasters, 0);
      c.remove(flour);
      expect(c.state.draft.lines, hasLength(1));
      await c.close();
    });

    test('credit without a supplier is blocked; with one it saves', () async {
      final v = store.seedSupplier('النور');
      final c = cubits.purchase();
      await c.addProduct(store.products.summary(tea)!);
      c
        ..qtyChanged(tea, '10')
        ..costChanged(tea, '11')
        ..paidChanged('0');
      await c.submit();
      expect(c.state.errors, [const CreditNeedsSupplier()]);
      expect(store.writes, isEmpty);

      c
        ..supplierChanged(PurchaseSupplier(id: v, name: 'النور'))
        ..supplierRefChanged('INV-1')
        ..invoiceDateChanged(DateTime(2026, 10, 1))
        ..noteChanged(' n ')
        ..methodChanged(PaymentMethod.card);
      expect(c.state.errors, isEmpty);
      await c.submit();
      expect(c.state.status, PurchaseStatus.saved);
      expect(c.state.saved!.number, 1);
      expect(c.hasUnsavedLines, isFalse);
      final p = store.purchase(c.state.saved!.id)!;
      expect(p.summary.kind, PurchaseKind.credit);
      expect(p.summary.supplierRef, 'INV-1');
      expect(p.summary.invoiceDate, DateTime(2026, 10, 1));
      expect(p.note, 'n');
      expect(store.balanceOf(v), 11000);
      expect(store.products.stockOf(tea), 20000);

      c.startNew();
      expect(c.state, const PurchaseState());
      await c.close();
    });

    test('a future invoice date is blocked', () async {
      final c = cubits.purchase();
      await c.addProduct(store.products.summary(tea)!);
      c.invoiceDateChanged(DateTime(2026, 10, 21));
      await c.submit();
      expect(c.state.errors, [const PurchaseDateInFuture()]);
      c.invoiceDateChanged(null);
      await c.submit();
      expect(c.state.status, PurchaseStatus.saved);
      await c.close();
    });

    test('an archived product or supplier is reported', () async {
      final v = store.seedSupplier('النور', archived: true);
      final c = cubits.purchase();
      await c.addProduct(store.products.summary(tea)!);
      c.supplierChanged(PurchaseSupplier(id: v, name: 'النور'));
      await c.submit();
      expect(c.state.status, PurchaseStatus.editing);
      expect(c.state.saveError, const SupplierUnavailable());
      // Any edit clears the refusal.
      c.supplierChanged(null);
      expect(c.state.saveError, isNull);
      await c.close();

      final archived = store.products.seedProduct('سكر', archived: true);
      final d = cubits.purchase();
      await d.addProduct(store.products.summary(archived)!);
      await d.submit();
      expect(d.state.saveError, const PurchaseProductUnavailable('سكر'));
      await d.close();
    });

    test('a typed paid amount resets when the total changes', () async {
      final v = store.seedSupplier('النور');
      final c = cubits.purchase();
      await c.addProduct(store.products.summary(tea)!);
      c
        ..supplierChanged(PurchaseSupplier(id: v, name: 'النور'))
        ..costChanged(tea, '10')
        ..paidChanged('4');
      expect(c.state.draft.paid, 400);
      // Same total: the typed amount stays.
      c.methodChanged(PaymentMethod.wallet);
      expect(c.state.draft.paidPiasters, 400);
      c.qtyChanged(tea, '2');
      expect(c.state.draft.paidPiasters, isNull);
      expect(c.state.draft.paid, 2000);
      c
        ..paidChanged('5')
        ..invoiceDiscountChanged('1');
      expect(c.state.draft.paidPiasters, isNull);
      c
        ..paidChanged('x')
        ..paidChanged('');
      expect(c.state.inputErrors, isEmpty);
      await c.close();
    });

    test('unsaved lines guard leaving', () async {
      final c = cubits.purchase();
      expect(c.hasUnsavedLines, isFalse);
      await c.addProduct(store.products.summary(tea)!);
      expect(c.hasUnsavedLines, isTrue);
      await c.close();
    });
  });

  group('lists', () {
    test('PurchasesListCubit: date order, unpaid, search, supplier', () async {
      final v = store.seedSupplier('شركة النور');
      final nour = PurchaseSupplier(id: v, name: 'شركة النور');
      store
        ..seedPurchase(draftOf(tea, 1000, 1000))
        ..seedPurchase(
          draftOf(tea, 1000, 1000)
              .withSupplier(nour)
              .withPaid(0)
              .withSupplierRef('INV-77')
              .withInvoiceDate(DateTime(2026, 10, 1)),
        )
        ..seedPurchase(draftOf(tea, 1000, 1000).withSupplier(nour));
      final c = cubits.purchasesList();
      await pumpEventQueue();
      expect(c.state.items.map((p) => p.number), [3, 1, 2]);
      expect(c.state.hasMore, isFalse);
      c.toggleUnpaid();
      await pumpEventQueue();
      expect(c.state.items.map((p) => p.number), [2]);
      c
        ..toggleUnpaid()
        ..search('inv-77');
      await pumpEventQueue();
      expect(c.state.items.map((p) => p.number), [2]);
      c.search('P-3');
      await pumpEventQueue();
      expect(c.state.items.map((p) => p.number), [3]);
      await c.close();

      final mine = cubits.purchasesList(supplierId: v);
      await pumpEventQueue();
      expect(mine.state.items.map((p) => p.number), [3, 2]);
      await mine.close();
    });

    test('PurchasesListCubit: show more grows the page', () async {
      for (var i = 0; i < 51; i++) {
        store.seedPurchase(draftOf(tea, 1000, 100));
      }
      final c = cubits.purchasesList();
      await pumpEventQueue();
      expect(c.state.items, hasLength(50));
      expect(c.state.hasMore, isTrue);
      c.showMore();
      await pumpEventQueue();
      expect(c.state.items, hasLength(51));
      expect(c.state.hasMore, isFalse);
      await c.close();
    });

    test('PurchaseViewCubit: shortage asks first, then voids once', () async {
      final v = store.seedSupplier('النور');
      final id = store.seedPurchase(
        draftOf(
          tea,
          15000,
          1000,
        ).withSupplier(PurchaseSupplier(id: v, name: 'النور')).withPaid(5000),
      );
      // 25 in stock; sell 20, so voiding 15 leaves −10.
      store.products.seedEntry(tea, StockEntryType.sale, -20000);
      final c = cubits.purchaseView(id);
      await pumpEventQueue();
      expect(c.state.purchase!.summary.number, 1);

      final refused = await c.voidPurchase('خطأ');
      expect(refused, isA<VoidStockShortage>());
      expect(
        (refused! as VoidStockShortage).items.single.stockAfterMilli,
        -10000,
      );
      expect(store.writes, isEmpty);

      expect(await c.voidPurchase('خطأ', acknowledgeShortage: true), isNull);
      await pumpEventQueue();
      expect(c.state.purchase!.summary.voided, isTrue);
      expect(c.state.purchase!.voidReason, 'خطأ');
      expect(store.products.stockOf(tea), -10000);
      expect(store.balanceOf(v), 0);
      expect(store.statementOf(v).first.type, SupplierEntryType.reversal);
      expect(await c.voidPurchase('x'), const PurchaseAlreadyVoided());
      await c.close();
    });

    test('supplier picker and product picker', () async {
      store.seedSupplier('النور');
      final s = cubits.supplierPicker();
      await pumpEventQueue();
      expect(s.state.items.single.supplier.name, 'النور');
      await s.close();

      final p = cubits.productPicker();
      await pumpEventQueue();
      expect(p.state.items, hasLength(2));
      expect((await p.exact('111'))!.product.id, tea);
      await p.close();
    });
  });
}
