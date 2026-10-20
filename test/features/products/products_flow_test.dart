import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/features/products/data/product_repository_impl.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/database/test_database.dart';
import 'data/products_env.dart';

ProductRepositoryImpl _repo(AppDatabase db) => ProductRepositoryImpl(
  db.productsDao,
  db.stockMovementsDao,
  DriftTransactionRunner(db),
  const UuidV7Generator(),
  const SystemClock(),
);

/// SC-006: a product saved with opening stock is still there after the
/// database file is closed and opened again, as on an app restart.
void main() {
  test('products and opening stock survive a reopen', () async {
    final temp = await TempDatabase.open();
    addTearDown(() => temp.dir.delete(recursive: true));

    final first = _repo(temp.db);
    final saved = okValue(
      await first.create(
        draftOf(
          'دقيق',
          unit: UnitType.kg,
          price: '20',
          openingQty: '2.375',
          openingCost: '40',
        ),
      ),
    );
    await first.create(draftOf('شاي', price: '5'));
    await temp.db.close();

    final reopened = TempDatabase.openAt(temp.file);
    addTearDown(reopened.close);
    final items = await _repo(reopened)
        .watchSummaries(const ProductQuery())
        .first;
    expect(items.map((s) => s.product.name), ['دقيق', 'شاي']);
    final flour = items.firstWhere((s) => s.product.id == saved.id);
    expect(flour.stockMilli, 2375);
    expect(flour.product.avgCostPiasters, 4000);
    expect(flour.product.unit, UnitType.kg);
    expect(flour.hasHistory, isTrue);
  });
}
