import 'dart:math';

import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/adjustment.dart';
import 'package:daftar_afandi/features/products/domain/product_draft.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/database/test_database.dart';
import 'products_env.dart';

AdjustmentRequest damage(String qty, [UnitType unit = UnitType.piece]) =>
    okValue(AdjustmentRequest.damage(qtyText: qty, unit: unit));

AdjustmentRequest count(String counted, [UnitType unit = UnitType.piece]) =>
    okValue(AdjustmentRequest.count(countedText: counted, unit: unit));

AdjustmentRequest other(String qty, {required bool add, String note = 'n'}) =>
    okValue(
      AdjustmentRequest.other(
        qtyText: qty,
        unit: UnitType.piece,
        add: add,
        note: note,
      ),
    );

void main() {
  late ProductsEnv env;

  setUp(() => env = ProductsEnv());
  tearDown(() => env.dispose());

  Future<int> stock(String id) async => (await env.summary(id)).stockMilli;
  Future<int> avg(String id) async =>
      (await env.summary(id)).product.avgCostPiasters;
  Future<Object?> movementCount() =>
      env.db.scalar('SELECT COUNT(*) FROM stock_movements');

  group('setOpening', () {
    test('once, while the product has no history', () async {
      final id = await env.addProduct('أرز');
      const opening = OpeningStock(qtyMilli: 4000, unitCostPiasters: 125);
      expect(
        await env.inventory.setOpening(id, opening),
        const Ok<void, ProductSaveError>(null),
      );
      expect(await stock(id), 4000);
      expect(await avg(id), 125);
      expect(
        await env.inventory.setOpening(id, opening),
        const Err<void, ProductSaveError>(OpeningNotAllowed()),
      );
      expect(await stock(id), 4000);
    });

    test('a product with opening at create cannot set it again', () async {
      final id = await env.addProduct('أرز', openingQty: '1', openingCost: '1');
      expect(
        await env.inventory.setOpening(
          id,
          const OpeningStock(qtyMilli: 1000, unitCostPiasters: 1),
        ),
        const Err<void, ProductSaveError>(OpeningNotAllowed()),
      );
    });
  });

  group('adjust (FR-013, FR-014)', () {
    late String id;

    setUp(() async {
      id = await env.addProduct('أرز', openingQty: '10', openingCost: '7.50');
    });

    test('count down records the difference at the average cost', () async {
      final result = await env.inventory.adjust(id, count('8'));
      expect(
        okValue(result),
        const AdjustmentResult(deltaMilli: -2000, newStockMilli: 8000),
      );
      expect(await stock(id), 8000);
      final rows = await env.db.rows(
        "SELECT qty_delta_milli, unit_cost_piasters, adjustment_reason "
        "FROM stock_movements WHERE movement_type = 'ADJUSTMENT'",
      );
      expect(rows, [
        {
          'qty_delta_milli': -2000,
          'unit_cost_piasters': 750,
          'adjustment_reason': 'count',
        },
      ]);
    });

    test('count up adds stock at the current average cost', () async {
      expect(
        okValue(await env.inventory.adjust(id, count('13'))).deltaMilli,
        3000,
      );
      expect(await stock(id), 13000);
      expect(await avg(id), 750);
    });

    test('count equal to the stock writes nothing', () async {
      final before = await movementCount();
      expect(
        await env.inventory.adjust(id, count('10')),
        const Err<AdjustmentResult, AdjustmentError>(AlreadyMatches()),
      );
      expect(await movementCount(), before);
    });

    test('damage may remove exactly the stock, not one milli more', () async {
      final kg = await env.addProduct(
        'دقيق',
        unit: UnitType.kg,
        openingQty: '2.5',
        openingCost: '20',
      );
      expect(
        await env.inventory.adjust(kg, damage('2.501', UnitType.kg)),
        const Err<AdjustmentResult, AdjustmentError>(ExceedsStock(2500)),
      );
      expect(
        okValue(await env.inventory.adjust(kg, damage('2.5', UnitType.kg)))
            .newStockMilli,
        0,
      );
    });

    test('other adds and removes, keeping the note', () async {
      okValue(
        await env.inventory.adjust(id, other('2', add: true, note: 'وجدت')),
      );
      okValue(await env.inventory.adjust(id, other('5', add: false)));
      expect(await stock(id), 7000);
      expect(
        await env.inventory.adjust(id, other('8', add: false)),
        const Err<AdjustmentResult, AdjustmentError>(ExceedsStock(7000)),
      );
      final notes = await env.db.rows(
        "SELECT note FROM stock_movements WHERE movement_type = 'ADJUSTMENT' "
        'ORDER BY rowid',
      );
      expect(notes.map((r) => r['note']), ['وجدت', 'n']);
    });

    test('adjustments never change the average cost (FR-007)', () async {
      for (final r in [count('3'), damage('1'), other('9', add: true)]) {
        okValue(await env.inventory.adjust(id, r));
        expect(await avg(id), 750);
      }
    });

    test('a saved adjustment cannot be changed or deleted', () async {
      okValue(await env.inventory.adjust(id, damage('1')));
      await expectLater(
        env.db.exec('UPDATE stock_movements SET qty_delta_milli = 1'),
        throwsA(anything),
      );
      await expectLater(
        env.db.exec('DELETE FROM stock_movements'),
        throwsA(anything),
      );
    });
  });

  group('history (FR-016)', () {
    test('newest first, in pages, with type, reason and note', () async {
      final id = await env.addProduct(
        'أرز',
        openingQty: '20',
        openingCost: '1',
      );
      for (var i = 0; i < 5; i++) {
        okValue(await env.inventory.adjust(id, damage('1')));
      }
      okValue(await env.inventory.adjust(id, other('3', add: true, note: 'x')));

      final first = await env.inventory.history(id, limit: 4);
      expect(first.map((e) => e.qtyDeltaMilli), [3000, -1000, -1000, -1000]);
      expect(first.first.type, StockEntryType.adjustment);
      expect(first.first.reason, AdjustmentKind.other);
      expect(first.first.note, 'x');

      final second = await env.inventory.history(
        id,
        before: first.last.cursor,
        limit: 4,
      );
      expect(second.map((e) => e.qtyDeltaMilli), [-1000, -1000, 20000]);
      expect(second.last.type, StockEntryType.opening);
      expect(second.last.reason, isNull);
      expect(second.last.at.isUtc, isTrue);
    });

    test('entries with the same time are ordered by insertion', () async {
      final id = await env.addProduct('أرز');
      for (final (i, qty) in [1000, 2000, 3000].indexed) {
        await env.db.exec(
          'INSERT INTO stock_movements (id, product_id, movement_type, '
          'qty_delta_milli, unit_cost_piasters, adjustment_reason, created_at) '
          "VALUES ('m$i', '$id', 'ADJUSTMENT', $qty, 0, 'other', 5)",
        );
      }
      final all = await env.inventory.history(id, limit: 2);
      expect(all.map((e) => e.qtyDeltaMilli), [3000, 2000]);
      final rest = await env.inventory.history(id, before: all.last.cursor);
      expect(rest.map((e) => e.qtyDeltaMilli), [1000]);
    });
  });

  test('property: stock is the sum of movements and the average cost equals '
      'replay (research R7)', () async {
    final random = Random(20261020);
    for (var run = 0; run < 200; run++) {
      final unit = random.nextBool() ? UnitType.piece : UnitType.kg;
      final step = unit == UnitType.piece ? 1000 : 1;
      final id = await env.addProduct('p$run', unit: unit);
      final cost = random.nextInt(100000);
      final openingQty = (1 + random.nextInt(500)) * step;
      okValue(
        await env.inventory.setOpening(
          id,
          OpeningStock(qtyMilli: openingQty, unitCostPiasters: cost),
        ),
      );
      final expectedAvg = await avg(id);
      var expectedStock = openingQty;

      for (var i = 0; i < 1 + random.nextInt(6); i++) {
        final qty = (1 + random.nextInt(300)) * step;
        final text = formatMilli(qty);
        final request = switch (random.nextInt(3)) {
          0 => okValue(AdjustmentRequest.damage(qtyText: text, unit: unit)),
          1 => okValue(AdjustmentRequest.count(countedText: text, unit: unit)),
          _ => okValue(
            AdjustmentRequest.other(
              qtyText: text,
              unit: unit,
              add: random.nextBool(),
              note: 'r',
            ),
          ),
        };
        final result = await env.inventory.adjust(id, request);
        if (result case Ok(:final value)) {
          expectedStock = value.newStockMilli;
        }
      }

      final sum = await env.db.scalar(
        'SELECT COALESCE(SUM(qty_delta_milli), 0) FROM stock_movements '
        "WHERE product_id = '$id'",
      );
      expect(await stock(id), sum, reason: 'run $run');
      expect(await stock(id), expectedStock, reason: 'run $run');
      expect(await avg(id), expectedAvg, reason: 'run $run');
      expect(
        await env.inventory.rebuildAverageCost(id),
        expectedAvg,
        reason: 'run $run',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}

/// Milli-units as typed text, e.g. 2375 → "2.375".
String formatMilli(int milli) {
  final whole = milli ~/ 1000;
  final fraction = milli % 1000;
  return fraction == 0
      ? '$whole'
      : '$whole.${fraction.toString().padLeft(3, '0')}';
}
