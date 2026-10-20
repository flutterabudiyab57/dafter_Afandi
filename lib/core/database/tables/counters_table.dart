import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'enums.dart';

/// One row per document type. Numbers are allocated inside the document's
/// transaction and never reused (data-model.md, counters).
@DataClassName('CounterRow')
class Counters extends Table {
  TextColumn get id => text()();
  TextColumn get docType => textEnum<DocType>().unique()();
  IntColumn get nextValue => integer()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();
  IntColumn get updatedAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (next_value >= 1)',
    "CHECK (doc_type IN ('SALE', 'SALE_RETURN', 'PURCHASE', 'EXPENSE', 'CUSTOMER_RECEIPT', 'SUPPLIER_PAYMENT'))",
  ];
}
