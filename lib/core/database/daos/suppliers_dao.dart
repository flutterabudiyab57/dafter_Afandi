import 'package:drift/drift.dart';

import '../app_database.dart';
import '../schema_sql.dart';
import '../tables/supplier_ledger_table.dart';
import '../tables/suppliers_table.dart';

part 'suppliers_dao.g.dart';

/// A supplier with their derived balance (004 research R10).
final class SupplierBalanceRow {
  const SupplierBalanceRow(
    this.supplier,
    this.balancePiasters, {
    required this.hasHistory,
  });

  final SupplierRow supplier;

  /// `SUM(amount_piasters)` of the supplier's ledger; 0 without rows.
  final int balancePiasters;

  /// Any ledger row, invoice or return names them (constitution 1.2.0).
  final bool hasHistory;
}

/// Suppliers. Never deletes but [purgeArchived] (constitution 1.2.0).
@DriftAccessor(tables: [Suppliers, SupplierLedger])
class SuppliersDao extends DatabaseAccessor<AppDatabase>
    with _$SuppliersDaoMixin {
  SuppliersDao(super.attachedDatabase);

  static final String _base =
      '''
SELECT s.*,
  ${partyHistorySql('suppliers', 's.id')} AS has_history,
  COALESCE((SELECT SUM(l.amount_piasters) FROM supplier_ledger l
            WHERE l.supplier_id = s.id), 0) AS balance_piasters
FROM suppliers s''';

  /// Arabic names first, then the rest, alphabetical (002 research R5).
  static const String _listOrder =
      '(unicode(search_key) < 1536) ASC, search_key ASC, name ASC, id ASC';

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    suppliers,
    supplierLedger,
  };

  /// Active suppliers. [normalizedQuery] is folded with `arabicNormalize`;
  /// [phoneQuery] holds only Latin digits (empty: no phone match).
  Stream<List<SupplierBalanceRow>> watchActive({
    required String normalizedQuery,
    required String phoneQuery,
    required bool owedOnly,
  }) {
    final where = <String>['archived_at IS NULL'];
    if (normalizedQuery.isNotEmpty) {
      where.add(
        "(instr(search_key, ?1) > 0 OR (?2 != '' AND instr(phone, ?2) > 0))",
      );
    }
    if (owedOnly) where.add('balance_piasters > 0');
    final order = owedOnly ? 'balance_piasters DESC, $_listOrder' : _listOrder;
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

  Stream<SupplierBalanceRow?> watchOne(String id) => customSelect(
    'SELECT * FROM ($_base) WHERE id = ?1',
    variables: [Variable<String>(id)],
    readsFrom: _reads,
  ).watchSingleOrNull().map((row) => row == null ? null : _read(row));

  Stream<List<SupplierBalanceRow>> watchArchived() => customSelect(
    'SELECT * FROM ($_base) WHERE archived_at IS NOT NULL ORDER BY $_listOrder',
    readsFrom: _reads,
  ).watch().map((rows) => rows.map(_read).toList());

  /// What the shop owes all suppliers, active or archived: the sum of
  /// the balances above 0.
  Stream<int> watchTotalOwed() => customSelect(
    'SELECT COALESCE(SUM(balance_piasters), 0) AS total FROM ($_base) '
    'WHERE balance_piasters > 0',
    readsFrom: _reads,
  ).watchSingle().map((row) => row.read<int>('total'));

  /// Deletes the archived suppliers with no history archived at or before
  /// [cutoff] (constitution 1.2.0); the v3 trigger refuses any other.
  /// Returns how many went.
  Future<int> purgeArchived(DateTime cutoff) => customUpdate(
    'DELETE FROM suppliers WHERE archived_at IS NOT NULL AND archived_at <= ?1 '
    "AND NOT (${partyHistorySql('suppliers', 'suppliers.id')})",
    variables: [Variable<int>(cutoff.millisecondsSinceEpoch)],
    updates: {suppliers},
    updateKind: UpdateKind.delete,
  );

  Future<SupplierRow?> byId(String id) =>
      (select(suppliers)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Whether an active supplier other than [exceptId] has [searchKey].
  Future<bool> activeNameExists(String searchKey, {required String exceptId}) =>
      (select(suppliers)..where(
            (s) =>
                s.searchKey.equals(searchKey) &
                s.archivedAt.isNull() &
                s.id.equals(exceptId).not(),
          ))
          .get()
          .then((rows) => rows.isNotEmpty);

  Future<void> insertSupplier(SuppliersCompanion row) =>
      into(suppliers).insert(row);

  /// Writes [changes] to supplier [id]. Throws [StateError] unless exactly
  /// one row was updated.
  Future<void> updateSupplier(String id, SuppliersCompanion changes) async {
    final count = await (update(
      suppliers,
    )..where((s) => s.id.equals(id))).write(changes);
    if (count != 1) {
      throw StateError('suppliers update affected $count rows, expected 1');
    }
  }

  /// Archives ([at] set) or restores ([at] null) supplier [id].
  Future<void> setArchivedAt(String id, DateTime? at, DateTime now) =>
      updateSupplier(
        id,
        SuppliersCompanion(archivedAt: Value(at), updatedAt: Value(now)),
      );

  SupplierBalanceRow _read(QueryRow row) => SupplierBalanceRow(
    suppliers.map(row.data),
    row.read<int>('balance_piasters'),
    hasHistory: row.read<int>('has_history') != 0,
  );
}
