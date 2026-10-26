import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/category.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'products_env.dart';

void main() {
  late ProductsEnv env;

  setUp(() => env = ProductsEnv());
  tearDown(() => env.dispose());

  Future<List<String>> names() async => [
    for (final c in await env.categories.watchActive().first) c.name,
  ];

  Future<String> add(String name) async =>
      okValue(await env.categories.create(name)).id;

  group('create', () {
    test('trims, appends at the end, counts products', () async {
      final drinks = await add('  مشروبات ');
      await add('منظفات');
      await env.addProduct('شاي', categoryId: drinks);
      final all = await env.categories.watchActive().first;
      expect(all.map((c) => c.name), ['مشروبات', 'منظفات']);
      expect(all.map((c) => c.sortOrder), [0, 1]);
      expect(all.first.productCount, 1);
    });

    test('a folded duplicate of an active category is blocked', () async {
      await add('مشروبات');
      expect(
        await env.categories.create('مشروبات'),
        const Err<Category, CategoryError>(CategoryDuplicate()),
      );
      await add('أرز ومكرونة');
      expect(
        await env.categories.create('ارز ومكرونه'),
        const Err<Category, CategoryError>(CategoryDuplicate()),
      );
    });

    test('an archived name can be used again', () async {
      final old = await add('مشروبات');
      await env.categories.archive(old);
      expect(
        await env.categories.create('مشروبات'),
        isA<Ok<Category, CategoryError>>(),
      );
    });

    test('name rules', () async {
      expect(
        await env.categories.create(' '),
        const Err<Category, CategoryError>(CategoryNameRequired()),
      );
      expect(
        await env.categories.create('ب' * 41),
        const Err<Category, CategoryError>(CategoryNameTooLong(40)),
      );
    });
  });

  group('rename', () {
    test('shows on products; renaming to itself is fine', () async {
      final id = await add('مشروبات');
      final tea = await env.addProduct('شاي', categoryId: id);
      expect(
        await env.categories.rename(id, 'مشروبات ساخنة'),
        const Ok<void, CategoryError>(null),
      );
      expect((await env.summary(tea)).product.categoryName, 'مشروبات ساخنة');
      expect(
        await env.categories.rename(id, 'مشروبات ساخنة'),
        const Ok<void, CategoryError>(null),
      );
    });

    test('to another active name is a duplicate', () async {
      await add('مشروبات');
      final cleaning = await add('منظفات');
      expect(
        await env.categories.rename(cleaning, 'مشروبات'),
        const Err<void, CategoryError>(CategoryDuplicate()),
      );
      expect(await names(), ['مشروبات', 'منظفات']);
    });
  });

  group('move (research R16)', () {
    test('up and down swap neighbours; the ends do nothing', () async {
      final a = await add('أ');
      await add('ب');
      final c = await add('ج');

      await env.categories.move(c, MoveDirection.up);
      expect(await names(), ['أ', 'ج', 'ب']);
      await env.categories.move(a, MoveDirection.down);
      expect(await names(), ['ج', 'أ', 'ب']);
      await env.categories.move(c, MoveDirection.up);
      expect(await names(), ['ج', 'أ', 'ب']);
      final all = await env.categories.watchActive().first;
      expect(all.map((x) => x.sortOrder), [0, 1, 2]);
    });

    test('ignores archived categories when renumbering', () async {
      final a = await add('أ');
      final b = await add('ب');
      await add('ج');
      await env.categories.archive(b);
      await env.categories.move(a, MoveDirection.down);
      expect(await names(), ['ج', 'أ']);
    });
  });

  test('archive keeps its products', () async {
    final id = await add('مشروبات');
    final tea = await env.addProduct('شاي', categoryId: id);
    await env.categories.archive(id);
    expect(await names(), isEmpty);
    final s = await env.summary(tea);
    expect(s.product.archived, isFalse);
    expect(s.product.categoryId, isNull);
  });
}
