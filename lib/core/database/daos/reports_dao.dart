import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customer_ledger_table.dart';
import '../tables/customers_table.dart';
import '../tables/enums.dart';
import '../tables/expenses_table.dart';
import '../tables/payment_parts_table.dart';
import '../tables/sale_items_table.dart';
import '../tables/sale_return_items_table.dart';
import '../tables/sale_returns_table.dart';
import '../tables/sales_invoices_table.dart';
import '../tables/stock_movements_table.dart';
import '../tables/supplier_ledger_table.dart';
import '../tables/suppliers_table.dart';

part 'reports_dao.g.dart';

/// Net sales and how many sales, for a period.
final class SalesTotalsRow {
  const SalesTotalsRow({required this.netPiasters, required this.count});

  final int netPiasters;
  final int count;
}

/// A product's sales in a period, net of returns.
final class TopSellerRow {
  const TopSellerRow({
    required this.productId,
    required this.name,
    required this.unit,
    required this.qtyMilli,
    required this.netPiasters,
  });

  final String productId;
  final String name;
  final UnitType unit;
  final int qtyMilli;
  final int netPiasters;
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

/// The sums behind a profit report.
final class ProfitTotalsRow {
  const ProfitTotalsRow({
    required this.salesPiasters,
    required this.salesCount,
    required this.saleCostPiasters,
    required this.linesWithoutCost,
    required this.returnCount,
    required this.returnsPiasters,
    required this.returnedCostPiasters,
    required this.expensesPiasters,
  });

  final int salesPiasters;
  final int salesCount;
  final int saleCostPiasters;
  final int linesWithoutCost;
  final int returnCount;
  final int returnsPiasters;
  final int returnedCostPiasters;
  final int expensesPiasters;
}

/// One stock adjustment, as recorded.
final class AdjustmentValueRow {
  const AdjustmentValueRow({
    required this.qtyDeltaMilli,
    required this.unitCostPiasters,
    required this.reason,
  });

  final int qtyDeltaMilli;
  final int unitCostPiasters;
  final AdjustmentReason reason;
}

/// Read-only report queries (006 research R8, R9, R11). Times are UTC epoch
/// ms, `[start, end)`.
@DriftAccessor(
  tables: [
    SalesInvoices,
    SaleItems,
    SaleReturns,
    SaleReturnItems,
    PaymentParts,
    CustomerLedger,
    Customers,
    SupplierLedger,
    Suppliers,
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
      saleReturnItems,
      paymentParts,
      customerLedger,
      customers,
      supplierLedger,
      suppliers,
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

  /// Suppliers, active or archived, whose balance is above 0 (the shop
  /// owes them), largest first.
  Future<List<PartyBalanceRow>> suppliersOwed() async {
    final rows = await customSelect(
      'SELECT * FROM (SELECT s.id, s.name, s.archived_at, '
      ' COALESCE((SELECT SUM(l.amount_piasters) FROM supplier_ledger l '
      '  WHERE l.supplier_id = s.id), 0) AS balance FROM suppliers s) '
      'WHERE balance > 0 ORDER BY balance DESC, name ASC, id ASC',
      readsFrom: {suppliers, supplierLedger},
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

  /// Up to [limit] products sold in the period: lines of sales not voided
  /// (after the invoice discount share) minus returns made in the period.
  /// [byQuantity] orders by quantity, else by value; the name is the one on
  /// the product's latest sale line.
  Future<List<TopSellerRow>> topSellers(
    DateTime start,
    DateTime end, {
    required bool byQuantity,
    int limit = 10,
  }) async {
    final order = byQuantity ? 'qty DESC, net DESC' : 'net DESC, qty DESC';
    final rows = await customSelect(
      'SELECT t.pid, t.qty, t.net, '
      ' (SELECT i.product_name_snapshot FROM sale_items i '
      '  JOIN sales_invoices s ON s.id = i.sales_invoice_id '
      '  WHERE i.product_id = t.pid '
      '  ORDER BY s.created_at DESC, s.number DESC LIMIT 1) AS name, '
      ' (SELECT i.unit_type_snapshot FROM sale_items i '
      '  JOIN sales_invoices s ON s.id = i.sales_invoice_id '
      '  WHERE i.product_id = t.pid '
      '  ORDER BY s.created_at DESC, s.number DESC LIMIT 1) AS unit '
      'FROM (SELECT pid, SUM(qty) AS qty, SUM(net) AS net FROM ('
      ' SELECT i.product_id AS pid, i.qty_milli AS qty, '
      '  i.line_total_piasters - i.invoice_discount_share_piasters AS net '
      ' FROM sale_items i JOIN sales_invoices s ON s.id = i.sales_invoice_id '
      ' WHERE s.voided_at IS NULL AND s.created_at >= ?1 AND s.created_at < ?2'
      ' UNION ALL'
      ' SELECT product_id, -qty_milli, -refund_piasters FROM sale_return_items'
      ' WHERE created_at >= ?1 AND created_at < ?2'
      ') GROUP BY pid HAVING SUM(qty) > 0) t '
      'ORDER BY $order, name ASC, t.pid ASC LIMIT ?3',
      variables: [..._range(start, end), Variable<int>(limit)],
      readsFrom: {saleItems, salesInvoices, saleReturnItems},
    ).get();
    return [
      for (final r in rows)
        TopSellerRow(
          productId: r.read<String>('pid'),
          name: r.read<String>('name'),
          unit: UnitType.values.byName(r.read<String>('unit')),
          qtyMilli: r.read<int>('qty'),
          netPiasters: r.read<int>('net'),
        ),
    ];
  }

  /// The sums behind the profit report (research R9): sales not voided
  /// and their recorded line costs, returns, and expenses not voided.
  Future<ProfitTotalsRow> profitTotals(DateTime start, DateTime end) async {
    final row = await customSelect(
      'SELECT '
      '(SELECT COALESCE(SUM(total_piasters), 0) FROM sales_invoices '
      ' WHERE voided_at IS NULL AND created_at >= ?1 AND created_at < ?2) '
      ' AS sales, '
      '(SELECT COUNT(*) FROM sales_invoices '
      ' WHERE voided_at IS NULL AND created_at >= ?1 AND created_at < ?2) '
      ' AS n, '
      '(SELECT COALESCE(SUM(i.line_cost_piasters), 0) FROM sale_items i '
      ' JOIN sales_invoices s ON s.id = i.sales_invoice_id '
      ' WHERE s.voided_at IS NULL AND s.created_at >= ?1 AND s.created_at < ?2) '
      ' AS cost, '
      '(SELECT COUNT(*) FROM sale_items i '
      ' JOIN sales_invoices s ON s.id = i.sales_invoice_id '
      ' WHERE s.voided_at IS NULL AND s.created_at >= ?1 AND s.created_at < ?2 '
      ' AND i.unit_cost_piasters = 0) AS no_cost, '
      '(SELECT COUNT(*) FROM sale_returns '
      ' WHERE created_at >= ?1 AND created_at < ?2) AS return_count, '
      '(SELECT COALESCE(SUM(total_refund_piasters), 0) FROM sale_returns '
      ' WHERE created_at >= ?1 AND created_at < ?2) AS returns, '
      '(SELECT COALESCE(SUM(total_cost_piasters), 0) FROM sale_returns '
      ' WHERE created_at >= ?1 AND created_at < ?2) AS returned_cost, '
      '(SELECT COALESCE(SUM(amount_piasters), 0) FROM expenses '
      ' WHERE voided_at IS NULL AND spent_at >= ?1 AND spent_at < ?2) '
      ' AS expenses',
      variables: _range(start, end),
      readsFrom: {salesInvoices, saleItems, saleReturns, expenses},
    ).getSingle();
    return ProfitTotalsRow(
      salesPiasters: row.read<int>('sales'),
      salesCount: row.read<int>('n'),
      saleCostPiasters: row.read<int>('cost'),
      linesWithoutCost: row.read<int>('no_cost'),
      returnCount: row.read<int>('return_count'),
      returnsPiasters: row.read<int>('returns'),
      returnedCostPiasters: row.read<int>('returned_cost'),
      expensesPiasters: row.read<int>('expenses'),
    );
  }

  /// Stock adjustments made in the period, as rows: they are few, and each
  /// is valued in Dart with the money helpers.
  Future<List<AdjustmentValueRow>> adjustments(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await customSelect(
      'SELECT qty_delta_milli, unit_cost_piasters, adjustment_reason '
      "FROM stock_movements WHERE movement_type = 'ADJUSTMENT' "
      'AND created_at >= ?1 AND created_at < ?2',
      variables: _range(start, end),
      readsFrom: {stockMovements},
    ).get();
    return [
      for (final r in rows)
        AdjustmentValueRow(
          qtyDeltaMilli: r.read<int>('qty_delta_milli'),
          unitCostPiasters: r.read<int>('unit_cost_piasters'),
          reason: AdjustmentReason.values.byName(
            r.read<String>('adjustment_reason'),
          ),
        ),
    ];
  }

  static List<Variable<Object>> _range(DateTime start, DateTime end) => [
    Variable<int>(start.millisecondsSinceEpoch),
    Variable<int>(end.millisecondsSinceEpoch),
  ];
}
