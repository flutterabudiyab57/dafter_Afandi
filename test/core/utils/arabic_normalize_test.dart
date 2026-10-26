import 'package:daftar_afandi/core/utils/arabic_normalize.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('arabicNormalize', () {
    test('removes tashkeel', () {
      expect(arabicNormalize('مُحَمَّد'), 'محمد');
      expect(arabicNormalize('سُكَّرٌ'), 'سكر');
      expect(arabicNormalize('هٰذا'), 'هذا'); // U+0670
    });

    test('removes tatweel', () {
      expect(arabicNormalize('كـــتاب'), 'كتاب');
    });

    test('folds alef variants', () {
      expect(arabicNormalize('أحمد'), 'احمد');
      expect(arabicNormalize('إسلام'), 'اسلام');
      expect(arabicNormalize('آمال'), 'امال');
    });

    test('folds ta marbuta and alef maqsura', () {
      expect(arabicNormalize('مدرسة'), 'مدرسه');
      expect(arabicNormalize('مصطفى'), 'مصطفي');
    });

    test('maps digits to Latin', () {
      expect(arabicNormalize('٣ كيلو'), '3 كيلو');
      expect(arabicNormalize('۴ لتر'), '4 لتر');
    });

    test('lowercases Latin in mixed scripts', () {
      expect(arabicNormalize('Pepsi ١ لتر'), 'pepsi 1 لتر');
      expect(arabicNormalize('شاي LIPTON'), 'شاي lipton');
    });

    test('collapses whitespace and trims', () {
      expect(arabicNormalize('  شاي   العروسة  '), 'شاي العروسه');
      expect(arabicNormalize('سكر\t\nأبيض'), 'سكر ابيض');
      expect(arabicNormalize('   '), '');
    });

    test('is idempotent', () {
      for (final s in [
        'مُحَمَّد',
        'كـــتاب',
        'أإآ ة ى',
        '  Pepsi ١ لتـر  ',
        'Coca-Cola ٫ 2',
        '',
      ]) {
        final once = arabicNormalize(s);
        expect(arabicNormalize(once), once, reason: s);
      }
    });
  });
}
