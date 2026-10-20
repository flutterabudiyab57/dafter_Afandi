import 'package:daftar_afandi/core/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

final RegExp _uuidV7 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  const IdGenerator generator = UuidV7Generator();

  test('ids are lowercase canonical UUID v7', () {
    final id = generator.newId();
    expect(id, matches(_uuidV7));
    expect(id, id.toLowerCase());
  });

  test('the timestamp is the current time', () {
    final before = DateTime.timestamp().millisecondsSinceEpoch;
    final id = generator.newId();
    final after = DateTime.timestamp().millisecondsSinceEpoch;
    final millis = int.parse(
      id.replaceAll('-', '').substring(0, 12),
      radix: 16,
    );
    // The counter may push the timestamp a few ms ahead of the clock.
    expect(millis, inInclusiveRange(before, after + 5));
  });

  test('1,000 ids are unique and in creation order', () {
    final ids = [for (var i = 0; i < 1000; i++) generator.newId()];
    for (final id in ids) {
      expect(id, matches(_uuidV7));
    }
    expect(ids.toSet().length, ids.length);
    for (var i = 1; i < ids.length; i++) {
      expect(
        ids[i].compareTo(ids[i - 1]) > 0,
        isTrue,
        reason: '${ids[i - 1]} then ${ids[i]}',
      );
    }
  });
}
