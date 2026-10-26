import 'package:daftar_afandi/features/products/domain/category.dart';
import 'package:daftar_afandi/features/products/domain/product.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/product_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateCategoryName', () {
    test('trimmed, 1–40 code points', () {
      expect(validateCategoryName(' مشروبات '), isNull);
      expect(validateCategoryName('ا'), isNull);
      expect(validateCategoryName('ب' * 40), isNull);
    });

    test('empty is required, 41 is too long', () {
      expect(validateCategoryName('  '), const CategoryNameRequired());
      expect(validateCategoryName('ب' * 41), const CategoryNameTooLong(40));
    });
  });

  group('isLowStock (FR-008)', () {
    test('at or below the level is low', () {
      expect(isLowStock(5000, 5000), isTrue);
      expect(isLowStock(3000, 5000), isTrue);
      expect(isLowStock(5001, 5000), isFalse);
    });

    test('below zero is low even without a level', () {
      expect(isLowStock(-1, null), isTrue);
      expect(isLowStock(0, null), isFalse);
    });

    test('a level of 0 marks zero stock', () {
      expect(isLowStock(0, 0), isTrue);
    });
  });

  test('ProductQuery folds the search text like searchKey', () {
    const q = ProductQuery(text: ' أرز  ٥ ');
    expect(q.normalizedText, 'ارز 5');
    expect(const ProductQuery().normalizedText, isEmpty);
    expect(
      q.copyWith(lowOnly: true),
      const ProductQuery(text: ' أرز  ٥ ', lowOnly: true),
    );
  });
}
