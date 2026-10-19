/// Search-key normalization (data-model.md, `searchKey`).
library;

import 'digits.dart';

final RegExp _tashkeelAndTatweel = RegExp('[\u064B-\u0652\u0670\u0640]');
final RegExp _alefVariants = RegExp('[أإآ]'); // أ إ آ
final RegExp _whitespace = RegExp(r'\s+');

/// Removes tashkeel and tatweel, folds أإآ→ا, ة→ه, ى→ي, maps digits to Latin,
/// lowercases Latin letters, collapses whitespace and trims.
String arabicNormalize(String input) {
  final folded = input
      .replaceAll(_tashkeelAndTatweel, '')
      .replaceAll(_alefVariants, 'ا') // ا
      .replaceAll('ة', 'ه') // ة → ه
      .replaceAll('ى', 'ي'); // ى → ي
  return normalizeDigits(folded)
      .toLowerCase()
      .replaceAll(_whitespace, ' ')
      .trim();
}
