import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _arb(String name) =>
    jsonDecode(File('lib/core/l10n/arb/$name').readAsStringSync())
        as Map<String, Object?>;

Map<String, String> _messages(Map<String, Object?> arb) => {
  for (final e in arb.entries)
    if (!e.key.startsWith('@')) e.key: e.value! as String,
};

void main() {
  final ar = _arb('app_ar.arb');
  final en = _arb('app_en.arb');
  final arMessages = _messages(ar);
  final enMessages = _messages(en);

  test('ar and en have the same keys and no empty values', () {
    expect(enMessages.keys.toSet(), arMessages.keys.toSet());
    for (final m in [arMessages, enMessages]) {
      for (final e in m.entries) {
        expect(e.value.trim(), isNotEmpty, reason: e.key);
      }
    }
  });

  test('every ar message has a description (ar is the template)', () {
    for (final key in arMessages.keys) {
      final meta = ar['@$key'] as Map<String, Object?>?;
      expect(meta?['description'], isA<String>(), reason: key);
    }
  });

  test('placeholders match between ar and en', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    Set<String> names(String s) =>
        placeholder.allMatches(s).map((m) => m.group(1)!).toSet();
    for (final key in arMessages.keys) {
      expect(names(enMessages[key]!), names(arMessages[key]!), reason: key);
    }
  });

  test('no string calls the invoice a tax document (FR-017)', () {
    const banned = [
      'tax receipt',
      'tax invoice',
      'فاتورة ضريبية',
      'إيصال ضريبي',
    ];
    for (final text in [...arMessages.values, ...enMessages.values]) {
      for (final word in banned) {
        expect(text.toLowerCase(), isNot(contains(word)), reason: text);
      }
    }
  });
}
