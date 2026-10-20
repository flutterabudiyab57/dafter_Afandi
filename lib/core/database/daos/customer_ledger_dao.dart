import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customer_ledger_table.dart';
import '../tables/sales_invoices_table.dart';

part 'customer_ledger_dao.g.dart';

/// One statement row with what the screen needs around it (003 research R9).
final class StatementRow {
  const StatementRow({
    required this.row,
    required this.rowOrder,
    required this.runningBalancePiasters,
    required this.invoiceNumber,
    required this.reversed,
  });

  final CustomerLedgerRow row;
  final int rowOrder;
  final int runningBalancePiasters;
  final int? invoiceNumber;

  /// A later row reverses this one.
  final bool reversed;
}

/// The append-only customer ledger: inserts and reads only.
@DriftAccessor(tables: [CustomerLedger, SalesInvoices])
class CustomerLedgerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerLedgerDaoMixin {
  CustomerLedgerDao(super.attachedDatabase);

  Future<void> insertEntry(CustomerLedgerCompanion row) =>
      into(customerLedger).insert(row);

  Future<CustomerLedgerRow?> byId(String id) =>
      (select(customerLedger)..where((l) => l.id.equals(id))).getSingleOrNull();

  Future<int> balanceOf(String customerId) async {
    final row = await customSelect(
      'SELECT COALESCE(SUM(amount_piasters), 0) AS s FROM customer_ledger '
      'WHERE customer_id = ?1',
      variables: [Variable<String>(customerId)],
      readsFrom: {customerLedger},
    ).getSingle();
    return row.read<int>('s');
  }

  /// Whether a row reverses [entryId].
  Future<bool> isReversed(String entryId) async {
    final row = await customSelect(
      'SELECT EXISTS(SELECT 1 FROM customer_ledger '
      'WHERE reverses_entry_id = ?1) AS e',
      variables: [Variable<String>(entryId)],
      readsFrom: {customerLedger},
    ).getSingle();
    return row.read<int>('e') != 0;
  }

  /// The rows a sale wrote, oldest first.
  Future<List<CustomerLedgerRow>> rowsForInvoice(String invoiceId) =>
      (select(customerLedger)
            ..where((l) => l.salesInvoiceId.equals(invoiceId))
            ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
          .get();

  /// Newest first with the running balance, strictly before
  /// ([beforeAtMillis], [beforeRowOrder]) when given.
  Future<List<StatementRow>> statementPage(
    String customerId, {
    int? beforeAtMillis,
    int? beforeRowOrder,
    required int limit,
  }) async {
    final hasCursor = beforeAtMillis != null && beforeRowOrder != null;
    final rows = await customSelect(
      'WITH s AS (SELECT l.*, l.rowid AS row_order, '
      'SUM(l.amount_piasters) OVER (ORDER BY l.created_at, l.rowid '
      'ROWS UNBOUNDED PRECEDING) AS running_balance, '
      'i.number AS invoice_number, '
      'EXISTS(SELECT 1 FROM customer_ledger r WHERE r.reverses_entry_id = l.id) '
      'AS is_reversed '
      'FROM customer_ledger l '
      'LEFT JOIN sales_invoices i ON i.id = l.sales_invoice_id '
      'WHERE l.customer_id = ?1) '
      'SELECT * FROM s '
      '${hasCursor ? 'WHERE (created_at < ?3 OR (created_at = ?3 AND row_order < ?4)) ' : ''}'
      'ORDER BY created_at DESC, row_order DESC LIMIT ?2',
      variables: [
        Variable<String>(customerId),
        Variable<int>(limit),
        if (hasCursor) ...[
          Variable<int>(beforeAtMillis),
          Variable<int>(beforeRowOrder),
        ],
      ],
      readsFrom: {customerLedger, salesInvoices},
    ).get();
    return [
      for (final r in rows)
        StatementRow(
          row: customerLedger.map(r.data),
          rowOrder: r.read<int>('row_order'),
          runningBalancePiasters: r.read<int>('running_balance'),
          invoiceNumber: r.readNullable<int>('invoice_number'),
          reversed: r.read<int>('is_reversed') != 0,
        ),
    ];
  }
}
