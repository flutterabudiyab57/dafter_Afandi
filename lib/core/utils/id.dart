/// Primary keys: lowercase canonical UUID v7 text (constitution III).
library;

import 'dart:math';
import 'dart:typed_data';

import 'package:uuid/data.dart';
import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String newId();
}

/// UUID v7 ids that sort in creation order, even within one millisecond.
///
/// uuid 4.6.0 fills the 74 bits after the timestamp randomly, so two ids made
/// in the same millisecond can sort either way. This generator uses the
/// 12-bit `rand_a` field as a counter (RFC 9562 §6.2, method 1): it starts
/// at a random value below 2048 each millisecond and increments per id; if it
/// runs out, the timestamp moves forward by 1 ms. The timestamp also never
/// goes backwards when the device clock does.
final class UuidV7Generator implements IdGenerator {
  const UuidV7Generator();

  static const Uuid _uuid = Uuid();
  static final Random _random = Random.secure();
  static const int _counterMax = 0xFFF;

  static int _lastMillis = -1;
  static int _counter = 0;

  @override
  String newId() {
    var millis = DateTime.timestamp().millisecondsSinceEpoch;
    if (millis > _lastMillis) {
      _counter = _random.nextInt(0x800);
    } else {
      millis = _lastMillis;
      _counter += 1;
      if (_counter > _counterMax) {
        millis += 1;
        _counter = _random.nextInt(0x800);
      }
    }
    _lastMillis = millis;

    final bytes = Uint8List(10);
    bytes[0] = (_counter >> 8) & 0x0F; // version nibble is set by uuid
    bytes[1] = _counter & 0xFF;
    for (var i = 2; i < bytes.length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return _uuid.v7(config: V7Options(millis, bytes)).toLowerCase();
  }
}
