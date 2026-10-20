import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_products.dart';

void main() {
  late FakeProductsStore store;

  setUp(() => store = FakeProductsStore());

  ProductFormCubit create({String initialName = ''}) {
    final cubit = ProductFormCubit(
      store.products,
      store.categories,
      mode: ProductFormMode.create,
      initialName: initialName,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  ProductFormCubit edit(String id) {
    final cubit = ProductFormCubit(
      store.products,
      store.categories,
      mode: ProductFormMode.edit,
      productId: id,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  group('create', () {
    test('starts with the name from the empty-search action', () {
      expect(create(initialName: 'زيت').state.name, 'زيت');
    });

    test('shows every field error on submit and saves nothing', () async {
      final cubit = create()..openingQtyChanged('1.5');
      await cubit.submit();
      expect(cubit.state.status, ProductFormStatus.editing);
      expect(cubit.state.errorFor(ProductField.name), const NameRequired());
      expect(cubit.state.errorFor(ProductField.price), const PriceRequired());
      expect(
        cubit.state.errorFor(ProductField.openingQty),
        const QuantityNotWhole(ProductField.openingQty),
      );
      expect(store.writes, isEmpty);
    });

    test('editing a field clears the errors', () async {
      final cubit = create();
      await cubit.submit();
      cubit.nameChanged('ش');
      expect(cubit.state.fieldErrors, isEmpty);
    });

    test('without opening stock it saves straight away', () async {
      final cubit = create()
        ..nameChanged('شاي')
        ..priceChanged('5');
      await cubit.submit();
      expect(cubit.state.status, ProductFormStatus.saved);
      expect(cubit.state.savedId, isNotNull);
      expect(store.writes, ['create شاي']);
    });

    test('with opening stock it asks first; Back keeps the fields', () async {
      final cubit = create()
        ..nameChanged('أرز')
        ..priceChanged('25')
        ..openingQtyChanged('12')
        ..openingCostChanged('7.50');
      await cubit.submit();
      expect(cubit.state.status, ProductFormStatus.confirmOpening);
      expect(cubit.state.pendingOpening!.totalPiasters, 9000);
      expect(store.writes, isEmpty);

      cubit.cancelConfirm();
      expect(cubit.state.status, ProductFormStatus.editing);
      expect(cubit.state.pendingOpening, isNull);
      expect(cubit.state.openingQty, '12');
      expect(cubit.state.openingCost, '7.50');
      expect(store.writes, isEmpty);
    });

    test('confirming saves the product with its opening stock', () async {
      final cubit = create()
        ..nameChanged('أرز')
        ..priceChanged('25')
        ..openingQtyChanged('12')
        ..openingCostChanged('7.50');
      await cubit.submit();
      await cubit.confirm();
      expect(cubit.state.status, ProductFormStatus.saved);
      final id = cubit.state.savedId!;
      expect(store.stockOf(id), 12000);
      expect(store.summary(id)!.product.avgCostPiasters, 750);
    });

    test('a taken barcode is shown and nothing is saved', () async {
      store.seedProduct('أرز', barcode: '622');
      final cubit = create()
        ..nameChanged('شاي')
        ..priceChanged('5')
        ..barcodeChanged('٦٢٢');
      await cubit.submit();
      expect(cubit.state.status, ProductFormStatus.editing);
      expect(cubit.state.saveError, const BarcodeTaken('أرز'));
      cubit.barcodeChanged('623');
      expect(cubit.state.saveError, isNull);
    });

    test('flags a duplicate name after saving', () async {
      store.seedProduct('شاي');
      final cubit = create()
        ..nameChanged('شاى')
        ..priceChanged('5');
      await cubit.submit();
      expect(cubit.state.nameExistsElsewhere, isTrue);
    });

    test('an unexpected failure keeps the fields and allows a retry', () async {
      store.failNextWrite = StateError('disk full');
      final cubit = create()
        ..nameChanged('شاي')
        ..priceChanged('5');
      final errors = <Object>[];
      cubit.stream.listen((_) {}, onError: errors.add);
      await cubit.submit();
      expect(cubit.state.status, ProductFormStatus.failed);
      expect(cubit.state.name, 'شاي');
      await cubit.submit();
      expect(cubit.state.status, ProductFormStatus.saved);
    });

    test('lists active categories and saves the one picked', () async {
      final drinks = store.seedCategory('مشروبات');
      final cubit = create();
      await pumpEventQueue();
      expect(cubit.state.categories.single.id, drinks);
      cubit
        ..nameChanged('شاي')
        ..priceChanged('5')
        ..categoryChanged(drinks);
      await cubit.submit();
      expect(store.summary(cubit.state.savedId!)!.product.categoryId, drinks);
    });
  });

  group('edit', () {
    test('loads the product into the fields', () async {
      final id = store.seedProduct(
        'دقيق',
        unit: UnitType.kg,
        pricePiasters: 1250,
        lowStockMilli: 2500,
        barcode: '1',
        sku: 'F',
      );
      final cubit = edit(id);
      expect(cubit.state.status, ProductFormStatus.loading);
      await pumpEventQueue();
      expect(cubit.state.status, ProductFormStatus.editing);
      expect(cubit.state.name, 'دقيق');
      expect(cubit.state.unit, UnitType.kg);
      expect(cubit.state.price, '12.5');
      expect(cubit.state.lowStock, '2.5');
      expect(cubit.state.barcode, '1');
      expect(cubit.state.unitLocked, isFalse);
    });

    test('the unit is locked once the product has history', () async {
      final id = store.seedProduct('أرز', stockMilli: 1000);
      final cubit = edit(id);
      await pumpEventQueue();
      expect(cubit.state.unitLocked, isTrue);
      cubit.unitChanged(UnitType.kg);
      expect(cubit.state.unit, UnitType.piece);
    });

    test('saves without asking about opening stock', () async {
      final id = store.seedProduct('أرز', stockMilli: 1000);
      final cubit = edit(id);
      await pumpEventQueue();
      cubit.priceChanged('30');
      await cubit.submit();
      expect(cubit.state.status, ProductFormStatus.saved);
      expect(store.summary(id)!.product.salePricePiasters, 3000);
      expect(store.stockOf(id), 1000);
    });

    test('a missing product is not found', () async {
      final cubit = edit('nope');
      await pumpEventQueue();
      expect(cubit.state.status, ProductFormStatus.notFound);
    });
  });
}
