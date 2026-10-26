import 'package:daftar_afandi/features/products/domain/demo_seed.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'products_env.dart';

void main() {
  test('demo seed saves every product through the real repository', () async {
    final env = ProductsEnv();
    addTearDown(env.dispose);
    final added = await seedDemoProducts(env.productRepo, count: 120);
    expect(added, 120);
    final items = await env.productRepo
        .watchSummaries(const ProductQuery())
        .first;
    expect(items, hasLength(120));
    expect(items.where((s) => s.hasHistory), hasLength(30));
    expect(items.where((s) => s.isLow), isNotEmpty);
  });
}
