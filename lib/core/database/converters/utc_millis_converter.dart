import 'package:drift/drift.dart';

/// Stores a UTC [DateTime] as epoch milliseconds (data-model.md, conventions).
///
/// Writing a local [DateTime] throws [ArgumentError], so a time zone can never
/// slip into the file.
final class UtcMillisConverter extends TypeConverter<DateTime, int> {
  const UtcMillisConverter();

  @override
  DateTime fromSql(int fromDb) =>
      DateTime.fromMillisecondsSinceEpoch(fromDb, isUtc: true);

  @override
  int toSql(DateTime value) {
    if (!value.isUtc) {
      throw ArgumentError.value(value, 'value', 'must be a UTC DateTime');
    }
    return value.millisecondsSinceEpoch;
  }
}
