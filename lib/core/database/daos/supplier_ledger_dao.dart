import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/purchase_invoices_table.dart';
import '../tables/supplier_ledger_table.dart';

part 'supplier_ledger_dao.g.dart';

/// One supplier statement row with what the screen needs around it (004
/// research R10).
final class SupplierStatementRow {
  const SupplierStatementRow({
    required this.row,
    required this.rowOrder,
    required this.runningBalancePiasters,
    required this.purchaseNumber,
    required this.reversed,
  });

  final SupplierLedgerRow row;
  final int rowOrder;
  final int runningBalancePiasters;
  final int? purchaseNumber;

  /// A later row reverses this one.
  final bool reversed;
}

/// The append-only supplier ledger: inserts and reads only.
@DriftAccessor(tables: [SupplierLedger, PurchaseInvoices])
class SupplierLedgerDao extends DatabaseAccessor<AppDatabase>
    with _$SupplierLedgerDaoMixin {
  SupplierLedgerDao(super.attachedDatabase);

  Future<void> insertEntry(SupplierLedgerCompanion row) =>
      into(supplierLedger).insert(row);

  Future<SupplierLedgerRow?> byId(String id) =>
      (select(supplierLedger)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<int> balanceOf(String supplierId) async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(amount_piasters), 0) AS s FROM supplier_ledger '
      'WHERE supplier_id = ?1',
      variables: [Variable<String>(supplierId)],
      readsFrom: {supplierLedger},
    ).getSingle();
    return row.read<int>('s');
  }

  /// How many rows [supplierId] has. The ledger is append-only, so a new
  /// value means the statement changed, even when the balance did not.
  Stream<int> watchCountOf(String supplierId) => customSelect(
    'SELECT COUNT(*) AS n FROM supplier_ledger WHERE supplier_id = ?1',
    variables: [Variable<String>(supplierId)],
    readsFrom: {supplierLedger},
  ).watchSingle().map((row) => row.read<int>('n'));

  /// Whether a row reverses [entryId].
  Future<bool> isReversed(String entryId) async {
    final row = await customSelect(
      'SELECT EXISTS(SELECT 1 FROM supplier_ledger '
      'WHERE reverses_entry_id = ?1) AS e',
      variables: [Variable<String>(entryId)],
      readsFrom: {supplierLedger},
    ).getSingle();
    return row.read<int>('e') != 0;
  }

  /// The rows a purchase wrote, oldest first.
  Future<List<SupplierLedgerRow>> rowsForPurchase(String invoiceId) =>
      (select(supplierLedger)
            ..where((l) => l.purchaseInvoiceId.equals(invoiceId))
            ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
          .get();

  /// Newest first with the running balance, strictly before
  /// ([beforeAtMillis], [beforeRowOrder]) when given.
  Future<List<SupplierStatementRow>> statementPage(
    String supplierId, {
    int? beforeAtMillis,
    int? beforeRowOrder,
    required int limit,
  }) async {
    final hasCursor = beforeAtMillis != null && beforeRowOrder != null;
    final rows = await customSelect(
      'WITH s AS (SELECT l.*, l.rowid AS row_order, '
      'SUM(l.amount_piasters) OVER (ORDER BY l.created_at, l.rowid '
      'ROWS UNBOUNDED PRECEDING) AS running_balance, '
      'i.number AS purchase_number, '
      'EXISTS(SELECT 1 FROM supplier_ledger r WHERE r.reverses_entry_id = l.id) '
      'AS is_reversed '
      'FROM supplier_ledger l '
      'LEFT JOIN purchase_invoices i ON i.id = l.purchase_invoice_id '
      'WHERE l.supplier_id = ?1) '
      'SELECT * FROM s '
      '${hasCursor ? 'WHERE (created_at < ?3 OR (created_at = ?3 AND row_order < ?4)) ' : ''}'
      'ORDER BY created_at DESC, row_order DESC LIMIT ?2',
      variables: [
        Variable<String>(supplierId),
        Variable<int>(limit),
        if (hasCursor) ...[
          Variable<int>(beforeAtMillis),
          Variable<int>(beforeRowOrder),
        ],
      ],
      readsFrom: {supplierLedger, purchaseInvoices},
    ).get();
    return [
      for (final r in rows)
        SupplierStatementRow(
          row: supplierLedger.map(r.data),
          rowOrder: r.read<int>('row_order'),
          runningBalancePiasters: r.read<int>('running_balance'),
          purchaseNumber: r.readNullable<int>('purchase_number'),
          reversed: r.read<int>('is_reversed') != 0,
        ),
    ];
  }
}
