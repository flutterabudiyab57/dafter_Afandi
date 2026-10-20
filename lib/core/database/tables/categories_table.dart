import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';

/// Product categories. Mutable master; archived, never deleted.
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get searchKey => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();
  IntColumn get updatedAt => integer().map(const UtcMillisConverter())();
  IntColumn get archivedAt =>
      integer().map(const UtcMillisConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
