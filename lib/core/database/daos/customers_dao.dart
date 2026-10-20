import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customer_ledger_table.dart';
import '../tables/customers_table.dart';

part 'customers_dao.g.dart';

/// A customer with their derived balance (003 research R8).
final class CustomerBalanceRow {
  const CustomerBalanceRow(this.customer, this.balancePiasters);

  final CustomerRow customer;

  /// `SUM(amount_piasters)` of the customer's ledger; 0 without rows.
  final int balancePiasters;
}

/// Customers. Never deletes (constitution III).
@DriftAccessor(tables: [Customers, CustomerLedger])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.attachedDatabase);

  static const String _base = '''
SELECT c.*,
  COALESCE((SELECT SUM(l.amount_piasters) FROM customer_ledger l
            WHERE l.customer_id = c.id), 0) AS balance_piasters
FROM customers c''';

  /// Arabic names first, then the rest, alphabetical (002 research R5).
  static const String _listOrder =
      '(unicode(search_key) < 1536) ASC, search_key ASC, name ASC, id ASC';

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    customers,
    customerLedger,
  };

  /// Active customers. [normalizedQuery] is folded with `arabicNormalize`;
  /// [phoneQuery] holds only Latin digits (empty: no phone match).
  Stream<List<CustomerBalanceRow>> watchActive({
    required String normalizedQuery,
    required String phoneQuery,
    required bool owesOnly,
  }) {
    final where = <String>['archived_at IS NULL'];
    if (normalizedQuery.isNotEmpty) {
      where.add(
        "(instr(search_key, ?1) > 0 OR (?2 != '' AND instr(phone, ?2) > 0))",
      );
    }
    if (owesOnly) where.add('balance_piasters > 0');
    final order = owesOnly ? 'balance_piasters DESC, $_listOrder' : _listOrder;
    return customSelect(
      'SELECT * FROM ($_base) WHERE ${where.join(' AND ')} ORDER BY $order',
      // SQLite refuses variables the statement does not use.
      variables: [
        if (normalizedQuery.isNotEmpty) ...[
          Variable<String>(normalizedQuery),
          Variable<String>(phoneQuery),
        ],
      ],
      readsFrom: _reads,
    ).watch().map((rows) => rows.map(_read).toList());
  }

  Stream<CustomerBalanceRow?> watchOne(String id) => customSelect(
    'SELECT * FROM ($_base) WHERE id = ?1',
    variables: [Variable<String>(id)],
    readsFrom: _reads,
  ).watchSingleOrNull().map((row) => row == null ? null : _read(row));

  Stream<List<CustomerBalanceRow>> watchArchived() => customSelect(
    'SELECT * FROM ($_base) WHERE archived_at IS NOT NULL ORDER BY $_listOrder',
    readsFrom: _reads,
  ).watch().map((rows) => rows.map(_read).toList());

  Future<CustomerRow?> byId(String id) =>
      (select(customers)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Whether an active customer other than [exceptId] has [searchKey].
  Future<bool> activeNameExists(String searchKey, {required String exceptId}) =>
      (select(customers)..where(
            (c) =>
                c.searchKey.equals(searchKey) &
                c.archivedAt.isNull() &
                c.id.equals(exceptId).not(),
          ))
          .get()
          .then((rows) => rows.isNotEmpty);

  Future<void> insertCustomer(CustomersCompanion row) =>
      into(customers).insert(row);

  /// Writes [changes] to customer [id]. Throws [StateError] unless exactly
  /// one row was updated.
  Future<void> updateCustomer(String id, CustomersCompanion changes) async {
    final count = await (update(
      customers,
    )..where((c) => c.id.equals(id))).write(changes);
    if (count != 1) {
      throw StateError('customers update affected $count rows, expected 1');
    }
  }

  /// Archives ([at] set) or restores ([at] null) customer [id].
  Future<void> setArchivedAt(String id, DateTime? at, DateTime now) =>
      updateCustomer(
        id,
        CustomersCompanion(archivedAt: Value(at), updatedAt: Value(now)),
      );

  CustomerBalanceRow _read(QueryRow row) => CustomerBalanceRow(
    customers.map(row.data),
    row.read<int>('balance_piasters'),
  );
}
