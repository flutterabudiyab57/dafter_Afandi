import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SystemClock returns UTC now', () {
    const Clock clock = SystemClock();
    final before = DateTime.now().toUtc();
    final now = clock.nowUtc();
    final after = DateTime.now().toUtc();

    expect(now.isUtc, isTrue);
    expect(now.isBefore(before), isFalse);
    expect(now.isAfter(after), isFalse);
  });

  test('FixedClock always returns the given instant', () {
    final instant = DateTime.utc(2026, 10, 19, 12, 30);
    final Clock clock = FixedClock(instant);

    expect(clock.nowUtc(), instant);
    expect(clock.nowUtc(), instant);
    expect(clock.nowUtc().isUtc, isTrue);
  });

  test('FixedClock rejects a local time', () {
    expect(() => FixedClock(DateTime(2026, 10, 19)), throwsArgumentError);
  });
}
