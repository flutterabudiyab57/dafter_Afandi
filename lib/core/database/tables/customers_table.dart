import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';

/// Customers. Balances come from `customer_ledger`. No credit limit (Q12).
@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get searchKey => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();
  IntColumn get updatedAt => integer().map(const UtcMillisConverter())();
  IntColumn get archivedAt =>
      integer().map(const UtcMillisConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
