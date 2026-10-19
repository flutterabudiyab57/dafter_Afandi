import 'package:daftar_afandi/core/utils/text_length.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Latin and empty', () {
    expect(codePointLength(''), 0);
    expect(codePointLength('abc'), 3);
  });

  test('Arabic counts each letter and mark', () {
    expect(codePointLength('محمد'), 4);
    expect(codePointLength('مُحَمَّد'), 8);
    expect(codePointLength('دفتر أفندي'), 10);
  });

  test('emoji count as code points, not UTF-16 units', () {
    expect('😀'.length, 2);
    expect(codePointLength('😀'), 1);
    expect(codePointLength('👍🏽'), 2); // thumbs up + skin tone modifier
    expect(codePointLength('محل 😀'), 5);
  });
}
