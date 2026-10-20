import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/database/test_database.dart';
import 'products_env.dart';

/// Research R3: 2,000 products and 100,000 movements; one list query plus
/// one search must stay under 300 ms on the dev machine (SC-002 budget).
void main() {
  test('list and search with 2,000 products and 100,000 movements', () async {
    final env = ProductsEnv();
    addTearDown(env.dispose);

    await env.db.transaction(() async {
      for (var p = 0; p < 2000; p++) {
        await env.db.exec(
          'INSERT INTO products (id, name, search_key, unit_type, '
          'sale_price_piasters, low_stock_threshold_milli, created_at, '
          "updated_at) VALUES ('p$p', 'منتج $p', 'منتج $p', 'piece', 100, "
          '${p % 7 == 0 ? 5000 : 'NULL'}, 1, 1)',
        );
      }
      for (var m = 0; m < 100000; m++) {
        final p = m % 2000;
        await env.db.exec(
          'INSERT INTO stock_movements (id, product_id, movement_type, '
          'qty_delta_milli, unit_cost_piasters, adjustment_reason, '
          "created_at) VALUES ('m$m', 'p$p', 'ADJUSTMENT', "
          "${m.isEven ? 1000 : -500}, 50, 'count', $m)",
        );
      }
    });

    // Warm up the statement cache once, as the app does on first open.
    await env.list();

    final watch = Stopwatch()..start();
    final all = await env.list();
    final found = await env.list(const ProductQuery(text: 'منتج 19'));
    watch.stop();

    expect(all, hasLength(2000));
    expect(found.first.product.name, 'منتج 19');
    // p0 gets every 2000th movement, all even, so +1 unit each: 50 units.
    expect(all.first.stockMilli, 50 * 1000);
    // ignore: avoid_print
    print('list + search: ${watch.elapsedMilliseconds} ms');
    expect(watch.elapsedMilliseconds, lessThan(300));
  }, timeout: const Timeout(Duration(minutes: 3)));
}
