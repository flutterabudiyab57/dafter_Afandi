import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customers_table.dart';
import '../tables/sale_items_table.dart';
import '../tables/sales_invoices_table.dart';

part 'sales_dao.g.dart';

/// An invoice header with its customer's current name.
final class SaleListRow {
  const SaleListRow(this.invoice, this.customerName);

  final SalesInvoiceRow invoice;
  final String? customerName;
}

/// Sales invoices and their lines. Inserts, reads, and the void fields only
/// (the void-only trigger refuses anything else).
@DriftAccessor(tables: [SalesInvoices, SaleItems, Customers])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.attachedDatabase);

  static const String _base = '''
SELECT i.*, c.name AS customer_name
FROM sales_invoices i LEFT JOIN customers c ON c.id = i.customer_id''';

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    salesInvoices,
    customers,
  };

  /// Newest first (003 research R16). [number] matches the number or its
  /// leading digits; otherwise [normalizedText] matches the customer name.
  Stream<List<SaleListRow>> watchList({
    int? number,
    required String normalizedText,
    required bool unpaidOnly,
    String? customerId,
    required int limit,
  }) {
    final where = <String>['1'];
    final variables = <Variable<Object>>[Variable<int>(limit)];
    if (number != null) {
      variables.add(Variable<String>('$number'));
      where.add("CAST(i.number AS TEXT) LIKE ?${variables.length} || '%'");
    } else if (normalizedText.isNotEmpty) {
      variables.add(Variable<String>(normalizedText));
      where.add('instr(c.search_key, ?${variables.length}) > 0');
    }
    if (unpaidOnly) {
      where.add(
        'i.paid_at_sale_piasters < i.total_piasters AND i.voided_at IS NULL',
      );
    }
    if (customerId != null) {
      variables.add(Variable<String>(customerId));
      where.add('i.customer_id = ?${variables.length}');
    }
    return customSelect(
      '$_base WHERE ${where.join(' AND ')} '
      'ORDER BY i.created_at DESC, i.number DESC LIMIT ?1',
      variables: variables,
      readsFrom: _reads,
    ).watch().map((rows) => rows.map(_read).toList());
  }

  Stream<SaleListRow?> watchOne(String id) => customSelect(
    '$_base WHERE i.id = ?1',
    variables: [Variable<String>(id)],
    readsFrom: _reads,
  ).watchSingleOrNull().map((row) => row == null ? null : _read(row));

  Future<SalesInvoiceRow?> byId(String id) =>
      (select(salesInvoices)..where((i) => i.id.equals(id))).getSingleOrNull();

  /// Lines in order.
  Future<List<SaleItemRow>> items(String invoiceId) =>
      (select(saleItems)
            ..where((s) => s.salesInvoiceId.equals(invoiceId))
            ..orderBy([(s) => OrderingTerm.asc(s.lineNo)]))
          .get();

  Stream<List<SaleItemRow>> watchItems(String invoiceId) =>
      (select(saleItems)
            ..where((s) => s.salesInvoiceId.equals(invoiceId))
            ..orderBy([(s) => OrderingTerm.asc(s.lineNo)]))
          .watch();

  Future<void> insertInvoice(SalesInvoicesCompanion row) =>
      into(salesInvoices).insert(row);

  Future<void> insertItem(SaleItemsCompanion row) =>
      into(saleItems).insert(row);

  /// The one allowed update: marking the invoice voided.
  Future<void> setVoided(String id, String reason, DateTime now) async {
    final count = await (update(salesInvoices)..where((i) => i.id.equals(id)))
        .write(
          SalesInvoicesCompanion(
            voidedAt: Value(now),
            voidReason: Value(reason),
            updatedAt: Value(now),
          ),
        );
    if (count != 1) {
      throw StateError('sales_invoices void affected $count rows, expected 1');
    }
  }

  SaleListRow _read(QueryRow row) => SaleListRow(
    salesInvoices.map(row.data),
    row.readNullable<String>('customer_name'),
  );
}
