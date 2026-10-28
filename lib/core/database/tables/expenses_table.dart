import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'expense_categories_table.dart';

/// Expenses. Voidable once; every other column is frozen by
/// `trg_expenses_void_only`. The method is in its payment parts (Q23, 006).
@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  IntColumn get number => integer().unique()();
  TextColumn get expenseCategoryId =>
      text().references(ExpenseCategories, #id, onDelete: KeyAction.restrict)();
  IntColumn get amountPiasters => integer()();
  IntColumn get spentAt => integer().map(const UtcMillisConverter())();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();
  IntColumn get updatedAt => integer().map(const UtcMillisConverter())();
  IntColumn get voidedAt =>
      integer().map(const UtcMillisConverter()).nullable()();
  TextColumn get voidReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  // The void pairing CHECK mirrors the sales and purchase headers.
  @override
  List<String> get customConstraints => [
    'CHECK (amount_piasters > 0)',
    'CHECK ((voided_at IS NULL) = (void_reason IS NULL))',
  ];
}
