import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/categories_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_products.dart';

void main() {
  late FakeProductsStore store;

  setUp(() => store = FakeProductsStore());

  List<String> names(CategoriesCubit c) =>
      c.state.categories.map((x) => x.name).toList();

  blocTest<CategoriesCubit, CategoriesState>(
    'loads the active categories',
    setUp: () => store
      ..seedCategory('مشروبات')
      ..seedCategory('منظفات'),
    build: () => CategoriesCubit(store.categories),
    wait: Duration.zero,
    verify: (c) {
      expect(c.state.loaded, isTrue);
      expect(names(c), ['مشروبات', 'منظفات']);
    },
  );

  test('create returns the error for the field, or null', () async {
    final cubit = CategoriesCubit(store.categories);
    addTearDown(cubit.close);
    expect(await cubit.create('مشروبات'), isNull);
    expect(await cubit.create('مشروبات'), const CategoryDuplicate());
    expect(await cubit.create(' '), const CategoryNameRequired());
    expect(await cubit.create('ب' * 41), const CategoryNameTooLong(40));
    await pumpEventQueue();
    expect(names(cubit), ['مشروبات']);
  });

  test('rename, move and archive', () async {
    final a = store.seedCategory('أ');
    final b = store.seedCategory('ب');
    final cubit = CategoriesCubit(store.categories);
    addTearDown(cubit.close);

    expect(await cubit.rename(b, 'أ'), const CategoryDuplicate());
    expect(await cubit.rename(b, 'بب'), isNull);
    await cubit.moveUp(b);
    await pumpEventQueue();
    expect(names(cubit), ['بب', 'أ']);
    await cubit.moveDown(b);
    await cubit.archive(a);
    await pumpEventQueue();
    expect(names(cubit), ['بب']);
  });
}
