import '../../../core/database/daos/supplier_ledger_dao.dart';
import '../../../core/database/daos/suppliers_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../customers/data/customer_mappers.dart';
import '../../customers/domain/customer.dart' show kArchivePurgeAfter;
import '../domain/supplier.dart';
import '../domain/supplier_entry.dart';

/// Row ↔ entity mapping for suppliers (constitution IV).
abstract final class SupplierMappers {
  static SupplierSummary summary(SupplierBalanceRow row) => SupplierSummary(
    supplier: Supplier(
      id: row.supplier.id,
      name: row.supplier.name,
      phone: row.supplier.phone,
      address: row.supplier.address,
      note: row.supplier.note,
      archived: row.supplier.archivedAt != null,
    ),
    balancePiasters: row.balancePiasters,
    hasHistory: row.hasHistory,
    purgeAt: row.hasHistory
        ? null
        : row.supplier.archivedAt?.add(kArchivePurgeAfter),
  );

  static SupplierEntry entry(SupplierStatementRow s) {
    final r = s.row;
    return SupplierEntry(
      id: r.id,
      type: entryType(r.entryType),
      amountPiasters: r.amountPiasters,
      runningBalancePiasters: s.runningBalancePiasters,
      at: r.createdAt,
      rowOrder: s.rowOrder,
      purchaseId: r.purchaseInvoiceId,
      purchaseNumber: s.purchaseNumber,
      paymentNumber: r.paymentNumber,
      method: r.paymentMethod == null
          ? null
          : CustomerMappers.method(r.paymentMethod!),
      note: r.note,
      reversed: s.reversed,
    );
  }

  /// Adjustments are written by a later feature; until then they show as a
  /// reversal.
  static SupplierEntryType entryType(db.SupplierEntryType t) => switch (t) {
    db.SupplierEntryType.OPENING_BALANCE => SupplierEntryType.openingBalance,
    db.SupplierEntryType.PURCHASE => SupplierEntryType.purchase,
    db.SupplierEntryType.PAYMENT_MADE => SupplierEntryType.payment,
    db.SupplierEntryType.PURCHASE_VOID => SupplierEntryType.purchaseVoid,
    db.SupplierEntryType.REVERSAL ||
    db.SupplierEntryType.ADJUSTMENT => SupplierEntryType.reversal,
  };
}
