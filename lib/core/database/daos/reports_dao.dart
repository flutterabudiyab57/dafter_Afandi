import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customer_ledger_table.dart';
import '../tables/customers_table.dart';
import '../tables/enums.dart';
import '../tables/expenses_table.dart';
import '../tables/payment_parts_table.dart';
import '../tables/sale_items_table.dart';
import '../tables/sale_returns_table.dart';
import '../tables/sales_invoices_table.dart';
import '../tables/stock_movements_table.dart';
import '../tables/supplier_ledger_table.dart';

part 'reports_dao.g.dart';

/// Net sales and how many sales, for a period.
final class SalesTotalsRow {
  const SalesTotalsRow({required this.netPiasters, required this.count});

  final int netPiasters;
  final int count;
}

/// A party and what it owes or is owed.
final class PartyBalanceRow {
  const PartyBalanceRow({
    required this.id,
    required this.name,
    required this.balancePiasters,
    required this.archived,
  });

  final String id;
  final String name;
  final int balancePiasters;
  final bool archived;
}

/// Read-only report queries (006 research R8, R9, R11). Times are UTC epoch
/// ms, `[start, end)`.
@DriftAccessor(
  tables: [
    SalesInvoices,
    SaleItems,
    SaleReturns,
    PaymentParts,
    CustomerLedger,
    Customers,
    SupplierLedger,
    StockMovements,
    Expenses,
  ],
)
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(super.attachedDatabase);

  /// Emits once now and again after any write to a table the reports read.
  Stream<void> watchChanges() => customSelect(
    'SELECT 1',
    readsFrom: {
      salesInvoices,
      saleItems,
      saleReturns,
      paymentParts,
      customerLedger,
      customers,
      supplierLedger,
      stockMovements,
      expenses,
    },
  ).watch().map((_) {});

  /// Sales not voided, minus returns made in the period.
  Future<SalesTotalsRow> salesTotals(DateTime start, DateTime end) async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COALESCE(SUM(total_piasters), 0) FROM sales_invoices '
      ' WHERE voided_at IS NULL AND created_at >= ?1 AND created_at < ?2) - '
      '(SELECT COALESCE(SUM(total_refund_piasters), 0) FROM sale_returns '
      ' WHERE created_at >= ?1 AND created_at < ?2) AS net, '
      '(SELECT COUNT(*) FROM sales_invoices '
      ' WHERE voided_at IS NULL AND created_at >= ?1 AND created_at < ?2) AS n',
      variables: _range(start, end),
      readsFrom: {salesInvoices, saleReturns},
    ).getSingle();
    return SalesTotalsRow(
      netPiasters: row.read<int>('net'),
      count: row.read<int>('n'),
    );
  }

  /// Money in by method: parts of sales not voided, parts of receipts not
  /// cancelled, minus refunds paid on returns (one method each).
  Future<Map<PaymentMethod, int>> collected(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await customSelect(
      'SELECT method, SUM(amount) AS amount FROM ('
      ' SELECT p.method AS method, p.amount_piasters AS amount '
      ' FROM payment_parts p JOIN sales_invoices s ON s.id = p.sales_invoice_id'
      ' WHERE s.voided_at IS NULL AND p.created_at >= ?1 AND p.created_at < ?2'
      ' UNION ALL'
      ' SELECT p.method, p.amount_piasters FROM payment_parts p'
      ' WHERE p.customer_ledger_id IS NOT NULL'
      ' AND p.created_at >= ?1 AND p.created_at < ?2'
      ' AND NOT EXISTS (SELECT 1 FROM customer_ledger r'
      '  WHERE r.reverses_entry_id = p.customer_ledger_id)'
      ' UNION ALL'
      ' SELECT payment_method, -refund_paid_piasters FROM sale_returns'
      ' WHERE refund_paid_piasters > 0 AND created_at >= ?1 AND created_at < ?2'
      ') GROUP BY method',
      variables: _range(start, end),
      readsFrom: {paymentParts, salesInvoices, customerLedger, saleReturns},
    ).get();
    return {
      for (final r in rows)
        PaymentMethod.values.byName(r.read<String>('method')): r.read<int>(
          'amount',
        ),
    };
  }

  /// Customers, active or archived, whose balance is above 0, largest
  /// first.
  Future<List<PartyBalanceRow>> customersOwing({int? limit}) async {
    final rows = await customSelect(
      'SELECT * FROM (SELECT c.id, c.name, c.archived_at, '
      ' COALESCE((SELECT SUM(l.amount_piasters) FROM customer_ledger l '
      '  WHERE l.customer_id = c.id), 0) AS balance FROM customers c) '
      'WHERE balance > 0 ORDER BY balance DESC, name ASC, id ASC'
      '${limit == null ? '' : ' LIMIT ?1'}',
      variables: [if (limit != null) Variable<int>(limit)],
      readsFrom: {customers, customerLedger},
    ).get();
    return [
      for (final r in rows)
        PartyBalanceRow(
          id: r.read<String>('id'),
          name: r.read<String>('name'),
          balancePiasters: r.read<int>('balance'),
          archived: r.readNullable<int>('archived_at') != null,
        ),
    ];
  }

  static List<Variable<Object>> _range(DateTime start, DateTime end) => [
    Variable<int>(start.millisecondsSinceEpoch),
    Variable<int>(end.millisecondsSinceEpoch),
  ];
}
