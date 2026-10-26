import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:daftar_afandi/features/sales/presentation/cubits/sale_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_sales.dart';

void main() {
  late FakeSalesStore store;
  late String tea;
  late String flour;

  setUp(() {
    store = FakeSalesStore();
    tea = store.products.seedProduct(
      'شاي',
      pricePiasters: 1250,
      stockMilli: 10000,
      barcode: '111',
    );
    flour = store.products.seedProduct(
      'دقيق',
      unit: UnitType.kg,
      pricePiasters: 4000,
      stockMilli: 5000,
    );
  });

  SaleCubit sale() => FakeSalesCubits(store).sale();

  group('SaleCubit', () {
    test('barcode adds, again raises the quantity; save resets', () async {
      final c = sale();
      expect(await c.addByBarcode('١١١'), isTrue);
      expect(await c.addByBarcode('111'), isTrue);
      expect(await c.addByBarcode('999'), isFalse);
      expect(c.state.draft.lines.single.qtyMilli, 2000);
      await c.submit();
      expect(c.state.status, SaleStatus.saved);
      expect(c.state.saved!.number, 1);
      expect(store.products.stockOf(tea), 8000);
      c.startNew();
      expect(c.state.draft.isEmpty, isTrue);
      await c.close();
    });

    test('typed numbers: kg decimals, piece fraction, empty qty', () async {
      final c = sale();
      c
        ..addProduct(store.products.summary(flour)!)
        ..qtyChanged(flour, '٠٫٧٥٠');
      expect(c.state.draft.lines.single.qtyMilli, 750);
      expect(c.state.draft.total, 3000);
      c
        ..addProduct(store.products.summary(tea)!)
        ..qtyChanged(tea, '1.5');
      expect(c.state.inputError(SaleField.qty, tea), SaleInputProblem.notWhole);
      c.qtyChanged(tea, '');
      expect(c.state.inputError(SaleField.qty, tea), SaleInputProblem.required);
      c.qtyChanged(tea, '0');
      expect(c.state.inputError(SaleField.qty, tea), SaleInputProblem.required);
      await c.submit();
      expect(c.state.status, SaleStatus.editing, reason: 'blocked');
      c.qtyChanged(tea, '2');
      expect(c.state.inputErrors, isEmpty);
      c
        ..priceChanged(tea, '10')
        ..lineDiscountChanged(tea, '1')
        ..invoiceDiscountChanged('2');
      expect(c.state.draft.total, 3000 + 2000 - 100 - 200);
      await c.close();
    });

    test('credit without a customer is blocked; with one it saves', () async {
      final c = sale()
        ..addProduct(store.products.summary(tea)!)
        ..paidChanged('5');
      await c.submit();
      expect(c.state.errors, [const CreditNeedsCustomer()]);
      final k = store.seedCustomer('أحمد');
      c
        ..customerChanged(SaleCustomer(id: k, name: 'أحمد'))
        ..methodChanged(PaymentMethod.wallet);
      await c.submit();
      expect(c.state.status, SaleStatus.saved);
      expect(store.balanceOf(k), 1250 - 500);
      await c.close();
    });

    test('shortage asks; back keeps the sale; confirm saves', () async {
      final c = sale()
        ..addProduct(store.products.summary(tea)!)
        ..qtyChanged(tea, '12');
      await c.submit();
      expect(c.state.status, SaleStatus.confirmShortage);
      expect(c.state.shortages.single.stockMilli, 10000);
      c.cancelShortage();
      expect(c.state.status, SaleStatus.editing);
      expect(store.writes, isEmpty);
      await c.submit();
      await c.confirmShortage();
      expect(c.state.status, SaleStatus.saved);
      expect(store.products.stockOf(tea), -2000);
      await c.close();
    });

    test('an archived product is reported', () async {
      final c = sale()..addProduct(store.products.summary(tea)!);
      await store.products.products.archive(tea);
      await c.submit();
      expect(c.state.saveError, const ProductUnavailable('شاي'));
      await c.close();
    });

    test('a typed paid amount resets when the total changes', () async {
      final c = sale()
        ..addProduct(store.products.summary(tea)!)
        ..customerChanged(const SaleCustomer(id: 'k1', name: 'أحمد'))
        ..paidChanged('12.50');
      expect(c.state.draft.paidPiasters, 1250);
      expect(c.state.draft.remaining, 0);

      // A second tea raises the total; paid follows it instead of leaving
      // 12.50 owed on the customer's account.
      c.addProduct(store.products.summary(tea)!);
      expect(c.state.draft.total, 2500);
      expect(c.state.draft.paidPiasters, isNull);
      expect(c.state.draft.paid, 2500);
      expect(c.state.draft.remaining, 0);

      // A partial amount typed for the new total stays while the total
      // does not change.
      c
        ..paidChanged('10')
        ..methodChanged(PaymentMethod.wallet);
      expect(c.state.draft.paidPiasters, 1000);
      c.invoiceDiscountChanged('5');
      expect(c.state.draft.total, 2000);
      expect(c.state.draft.paidPiasters, isNull);
      await c.close();
    });
  });

  group('lists', () {
    test('SalesListCubit: newest first, unpaid filter, search', () async {
      final k = store.seedCustomer('أحمد');
      store
        ..seedSale(
          const SaleDraft().add(
            productId: 'x',
            name: 'x',
            unit: UnitType.piece,
            unitPricePiasters: 100,
          ),
        )
        ..seedSale(
          const SaleDraft()
              .add(
                productId: 'y',
                name: 'y',
                unit: UnitType.piece,
                unitPricePiasters: 100,
              )
              .withCustomer(SaleCustomer(id: k, name: 'أحمد'))
              .withPaid(0),
        );
      final c = FakeSalesCubits(store).salesList();
      await pumpEventQueue();
      expect(c.state.items.map((s) => s.number), [2, 1]);
      c.toggleUnpaid();
      await pumpEventQueue();
      expect(c.state.items.single.kind, SaleKind.credit);
      c
        ..toggleUnpaid()
        ..search('S-1');
      await pumpEventQueue();
      expect(c.state.items.single.number, 1);
      await c.close();
    });

    test('InvoiceCubit voids once', () async {
      final id = store.seedSale(
        const SaleDraft().add(
          productId: tea,
          name: 'شاي',
          unit: UnitType.piece,
          unitPricePiasters: 1250,
        ),
      );
      final c = FakeSalesCubits(store).invoice(id);
      await pumpEventQueue();
      expect(c.state.invoice!.summary.number, 1);
      expect(await c.voidSale('خطأ'), isNull);
      await pumpEventQueue();
      expect(c.state.invoice!.voidReason, 'خطأ');
      expect(store.products.stockOf(tea), 10000);
      expect(await c.voidSale('x'), const AlreadyVoided());
      await c.close();
    });

    test('ProductPickerCubit searches and finds an exact barcode', () async {
      final c = FakeSalesCubits(store).productPicker();
      await pumpEventQueue();
      expect(c.state.items, hasLength(2));
      c.search('دق');
      await pumpEventQueue();
      expect(c.state.items.single.product.name, 'دقيق');
      expect((await c.exact('111'))!.product.id, tea);
      await c.close();
    });
  });
}
