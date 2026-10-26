import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/purchase_invoices_table.dart';
import '../tables/purchase_items_table.dart';
import '../tables/suppliers_table.dart';

part 'purchases_dao.g.dart';

/// A purchase header with its supplier's current name.
final class PurchaseListRow {
  const PurchaseListRow(this.invoice, this.supplierName);

  final PurchaseInvoiceRow invoice;
  final String? supplierName;
}

/// Purchase invoices and their lines. Inserts, reads, and the void fields
/// only (the void-only trigger refuses anything else).
@DriftAccessor(tables: [PurchaseInvoices, PurchaseItems, Suppliers])
class PurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$PurchasesDaoMixin {
  PurchasesDao(super.attachedDatabase);

  static const String _base = '''
SELECT i.*, s.name AS supplier_name
FROM purchase_invoices i LEFT JOIN suppliers s ON s.id = i.supplier_id''';

  Set<ResultSetImplementation<dynamic, dynamic>> get _reads => {
    purchaseInvoices,
    suppliers,
  };

  /// Newest invoice date first (004 research R16). [number] matches the
  /// number or its leading digits; otherwise [normalizedText] matches the
  /// supplier name or the supplier's invoice number.
  Stream<List<PurchaseListRow>> watchList({
    int? number,
    required String normalizedText,
    required bool unpaidOnly,
    String? supplierId,
    required int limit,
  }) {
    final where = <String>['1'];
    final variables = <Variable<Object>>[Variable<int>(limit)];
    if (number != null) {
      variables.add(Variable<String>('$number'));
      where.add("CAST(i.number AS TEXT) LIKE ?${variables.length} || '%'");
    } else if (normalizedText.isNotEmpty) {
      variables.add(Variable<String>(normalizedText));
      final v = '?${variables.length}';
      where.add(
        '(instr(s.search_key, $v) > 0 OR '
        'instr(lower(i.supplier_ref), $v) > 0)',
      );
    }
    if (unpaidOnly) {
      where.add('i.paid_piasters < i.total_piasters AND i.voided_at IS NULL');
    }
    if (supplierId != null) {
      variables.add(Variable<String>(supplierId));
      where.add('i.supplier_id = ?${variables.length}');
    }
    return customSelect(
      '$_base WHERE ${where.join(' AND ')} '
      'ORDER BY i.invoice_date DESC, i.number DESC LIMIT ?1',
      variables: variables,
      readsFrom: _reads,
    ).watch().map((rows) => rows.map(_read).toList());
  }

  Stream<PurchaseListRow?> watchOne(String id) => customSelect(
    '$_base WHERE i.id = ?1',
    variables: [Variable<String>(id)],
    readsFrom: _reads,
  ).watchSingleOrNull().map((row) => row == null ? null : _read(row));

  Future<PurchaseInvoiceRow?> byId(String id) => (select(
    purchaseInvoices,
  )..where((i) => i.id.equals(id))).getSingleOrNull();

  /// Lines in order.
  Future<List<PurchaseItemRow>> items(String invoiceId) =>
      (select(purchaseItems)
            ..where((p) => p.purchaseInvoiceId.equals(invoiceId))
            ..orderBy([(p) => OrderingTerm.asc(p.lineNo)]))
          .get();

  /// The unit cost on [productId]'s newest line of a purchase that is not
  /// voided, in save order (004 research R14).
  Future<int?> lastUnitCost(String productId) async {
    final row = await customSelect(
      'SELECT p.unit_cost_piasters AS c FROM purchase_items p '
      'JOIN purchase_invoices i ON i.id = p.purchase_invoice_id '
      'WHERE p.product_id = ?1 AND i.voided_at IS NULL '
      'ORDER BY p.created_at DESC, p.rowid DESC LIMIT 1',
      variables: [Variable<String>(productId)],
      readsFrom: {purchaseItems, purchaseInvoices},
    ).getSingleOrNull();
    return row?.read<int>('c');
  }

  Future<void> insertInvoice(PurchaseInvoicesCompanion row) =>
      into(purchaseInvoices).insert(row);

  Future<void> insertItem(PurchaseItemsCompanion row) =>
      into(purchaseItems).insert(row);

  /// The one allowed update: marking the purchase voided.
  Future<void> setVoided(String id, String reason, DateTime now) async {
    final count =
        await (update(purchaseInvoices)..where((i) => i.id.equals(id))).write(
          PurchaseInvoicesCompanion(
            voidedAt: Value(now),
            voidReason: Value(reason),
            updatedAt: Value(now),
          ),
        );
    if (count != 1) {
      throw StateError(
        'purchase_invoices void affected $count rows, expected 1',
      );
    }
  }

  PurchaseListRow _read(QueryRow row) => PurchaseListRow(
    purchaseInvoices.map(row.data),
    row.readNullable<String>('supplier_name'),
  );
}
