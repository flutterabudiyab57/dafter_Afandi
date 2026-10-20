import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/opening_stock_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_details_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/stock_adjustment_cubit.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/stock_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_products.dart';

void main() {
  late FakeProductsStore store;

  setUp(() => store = FakeProductsStore());

  group('ProductDetailsCubit', () {
    test('follows the product and archives it', () async {
      final id = store.seedProduct('أرز', stockMilli: 3000);
      final cubit = ProductDetailsCubit(store.products, id);
      addTearDown(cubit.close);
      expect(cubit.state.loaded, isFalse);
      await pumpEventQueue();
      expect(cubit.state.summary!.stockMilli, 3000);

      await cubit.archive();
      await pumpEventQueue();
      expect(cubit.state.summary!.product.archived, isTrue);
    });

    test('a restore conflict is a one-shot message', () async {
      final id = store.seedProduct('قديم', barcode: '1', archived: true);
      store.seedProduct('جديد', barcode: '1');
      final cubit = ProductDetailsCubit(store.products, id);
      addTearDown(cubit.close);
      await pumpEventQueue();
      await cubit.restore();
      expect(cubit.state.restoreError, const RestoreBarcodeTaken('جديد'));
      cubit.clearMessage();
      expect(cubit.state.restoreError, isNull);
      expect(cubit.state.summary!.product.archived, isTrue);
    });

    test('a missing product is loaded as null', () async {
      final cubit = ProductDetailsCubit(store.products, 'nope');
      addTearDown(cubit.close);
      await pumpEventQueue();
      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.summary, isNull);
    });
  });

  group('StockHistoryCubit', () {
    test('pages newest first and reloads', () async {
      final id = store.seedProduct('أرز', stockMilli: 10000);
      for (var i = 1; i <= 3; i++) {
        store.seedEntry(
          id,
          StockEntryType.adjustment,
          -i * 1000,
          reason: AdjustmentKind.damage,
        );
      }
      final cubit = StockHistoryCubit(store.inventory, id, pageSize: 2);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.entries.map((e) => e.qtyDeltaMilli), [-3000, -2000]);
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      expect(cubit.state.entries.map((e) => e.qtyDeltaMilli), [
        -3000,
        -2000,
        -1000,
        10000,
      ]);
      await cubit.loadMore();
      expect(cubit.state.hasMore, isFalse);

      store.seedEntry(id, StockEntryType.sale, -500);
      await cubit.load();
      expect(cubit.state.entries.first.type, StockEntryType.sale);
      expect(cubit.state.entries, hasLength(2));
    });
  });

  group('OpeningStockCubit', () {
    test('a product with history is not allowed', () async {
      final id = store.seedProduct('أرز', stockMilli: 1000);
      final cubit = OpeningStockCubit(store.products, store.inventory, id);
      addTearDown(cubit.close);
      await pumpEventQueue();
      expect(cubit.state.status, OpeningStockStatus.notAllowed);
    });

    test('needs a quantity and a cost, confirms, then saves once', () async {
      final id = store.seedProduct('دقيق', unit: UnitType.kg);
      final cubit = OpeningStockCubit(store.products, store.inventory, id);
      addTearDown(cubit.close);
      await pumpEventQueue();
      expect(cubit.state.status, OpeningStockStatus.editing);
      expect(cubit.state.unit, UnitType.kg);

      cubit.submit();
      expect(
        cubit.state.errorFor(ProductField.openingQty),
        const QuantityRequired(ProductField.openingQty),
      );
      cubit
        ..qtyChanged('2.5')
        ..submit();
      expect(
        cubit.state.errorFor(ProductField.openingCost),
        const OpeningCostRequired(),
      );

      cubit
        ..costChanged('40')
        ..submit();
      expect(cubit.state.status, OpeningStockStatus.confirm);
      expect(cubit.state.pending!.totalPiasters, 10000);
      cubit.cancelConfirm();
      expect(store.writes, isEmpty);

      cubit.submit();
      await cubit.confirm();
      expect(cubit.state.status, OpeningStockStatus.saved);
      expect(store.stockOf(id), 2500);
      expect(store.summary(id)!.product.avgCostPiasters, 4000);
    });
  });

  group('StockAdjustmentCubit', () {
    late String id;

    setUp(() => id = store.seedProduct('أرز', stockMilli: 10000));

    Future<StockAdjustmentCubit> build() async {
      final cubit = StockAdjustmentCubit(store.products, store.inventory, id);
      addTearDown(cubit.close);
      await pumpEventQueue();
      return cubit;
    }

    test('shows the stock on hand and records a count', () async {
      final cubit = await build();
      expect(cubit.state.status, StockAdjustmentStatus.editing);
      expect(cubit.state.kind, AdjustmentKind.count);
      expect(cubit.state.onHandMilli, 10000);

      cubit.qtyChanged('8');
      await cubit.submit();
      expect(cubit.state.status, StockAdjustmentStatus.saved);
      expect(cubit.state.newStockMilli, 8000);
      await pumpEventQueue();
      expect(cubit.state.onHandMilli, 8000);
    });

    test('a count equal to the stock is info, not an error', () async {
      final cubit = await build();
      cubit.qtyChanged('10');
      await cubit.submit();
      expect(cubit.state.status, StockAdjustmentStatus.alreadyMatches);
      expect(cubit.state.errors, isEmpty);
      expect(store.writes, isEmpty);
      cubit.qtyChanged('9');
      expect(cubit.state.status, StockAdjustmentStatus.editing);
    });

    test('damage above the stock is blocked with the stock on hand', () async {
      final cubit = await build();
      cubit
        ..kindChanged(AdjustmentKind.damage)
        ..qtyChanged('11');
      await cubit.submit();
      expect(cubit.state.qtyError, const ExceedsStock(10000));
      expect(store.writes, isEmpty);
    });

    test('other needs a note and a direction', () async {
      final cubit = await build();
      cubit
        ..kindChanged(AdjustmentKind.other)
        ..qtyChanged('1');
      await cubit.submit();
      expect(cubit.state.noteError, const AdjustmentNoteRequired());

      cubit
        ..directionChanged(add: true)
        ..noteChanged('وجدت');
      await cubit.submit();
      expect(cubit.state.newStockMilli, 11000);
    });

    test('quantity errors sit on the quantity field', () async {
      final cubit = await build();
      cubit
        ..kindChanged(AdjustmentKind.damage)
        ..qtyChanged('0.5');
      await cubit.submit();
      expect(cubit.state.qtyError, const AdjustmentQuantityNotWhole());
      expect(cubit.state.noteError, isNull);
    });

    test('an unexpected failure can be retried', () async {
      final cubit = await build();
      cubit.stream.listen((_) {}, onError: (Object _) {});
      store.failNextWrite = StateError('disk full');
      cubit.qtyChanged('9');
      await cubit.submit();
      expect(cubit.state.status, StockAdjustmentStatus.failed);
      await cubit.submit();
      expect(cubit.state.status, StockAdjustmentStatus.saved);
    });
  });
}
