import 'package:daftar_afandi/features/products/domain/average_cost_replay.dart';
import 'package:flutter_test/flutter_test.dart';

ReplayMovement inbound(int qtyMilli, int costPiasters) =>
    ReplayMovement(qtyDeltaMilli: qtyMilli, inboundCostPiasters: costPiasters);

ReplayMovement out(int qtyMilli) => ReplayMovement(qtyDeltaMilli: -qtyMilli);

void main() {
  test('no movements: cost 0', () {
    expect(replayAverageCost(const []), 0);
  });

  test('two inbound batches blend by quantity', () {
    // 10 at 9.00, then 10 at 11.00 → 10.00.
    expect(
      replayAverageCost([inbound(10000, 9000), inbound(10000, 11000)]),
      1000,
    );
  });

  test('outbound movements change stock, never the average', () {
    expect(replayAverageCost([inbound(10000, 9000), out(4000)]), 900);
    // 6 left at 9.00, then 6 at 12.00 → 10.50.
    expect(
      replayAverageCost([inbound(10000, 9000), out(4000), inbound(6000, 7200)]),
      1050,
    );
  });

  test('an inbound batch into zero or negative stock sets its own cost', () {
    expect(
      replayAverageCost([inbound(2000, 1800), out(2000), inbound(1000, 1300)]),
      1300,
    );
    expect(
      replayAverageCost([inbound(2000, 1800), out(5000), inbound(1000, 1300)]),
      1300,
    );
  });

  test('an inbound row without a cost changes stock only', () {
    // A count adjustment adds 10 at no cost: the average stays 9.00 and the
    // next batch blends with 20 in stock.
    expect(
      replayAverageCost([
        inbound(10000, 9000),
        const ReplayMovement(qtyDeltaMilli: 10000),
        inbound(20000, 24000),
      ]),
      1050,
    );
  });

  test('the total cost is used, so per-unit rounding does not compound', () {
    // Each batch enters with its total, not a rounded unit cost: 3 for
    // 10.00 twice is 6 for 20.00, which is 3.33 a unit.
    expect(replayAverageCost([inbound(3000, 1000)]), 333);
    expect(replayAverageCost([inbound(3000, 1000), inbound(3000, 1000)]), 333);
    expect(replayAverageCost([inbound(1000, 1), inbound(2000, 1)]), 1);
  });

  test('a free batch lowers the average', () {
    expect(replayAverageCost([inbound(1000, 1000), inbound(1000, 0)]), 500);
  });
}
