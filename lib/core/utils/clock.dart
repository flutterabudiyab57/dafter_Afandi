/// Time source, injectable so tests are deterministic. Always UTC.
library;

abstract interface class Clock {
  DateTime nowUtc();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

/// Returns the same instant every time. For tests.
final class FixedClock implements Clock {
  FixedClock(this._utc) {
    if (!_utc.isUtc) {
      throw ArgumentError.value(_utc, 'utc', 'must be a UTC DateTime');
    }
  }

  final DateTime _utc;

  @override
  DateTime nowUtc() => _utc;
}
