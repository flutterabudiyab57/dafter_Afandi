import '../../../core/database/daos/customer_ledger_dao.dart';
import '../../../core/database/daos/customers_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../domain/customer.dart';
import '../domain/ledger_entry.dart';
import '../domain/payment.dart';

/// Row ↔ entity mapping for customers (constitution IV).
abstract final class CustomerMappers {
  static CustomerSummary summary(CustomerBalanceRow row) => CustomerSummary(
    customer: Customer(
      id: row.customer.id,
      name: row.customer.name,
      phone: row.customer.phone,
      address: row.customer.address,
      note: row.customer.note,
      archived: row.customer.archivedAt != null,
    ),
    balancePiasters: row.balancePiasters,
  );

  static LedgerEntry entry(StatementRow s) {
    final r = s.row;
    return LedgerEntry(
      id: r.id,
      type: entryType(r.entryType),
      amountPiasters: r.amountPiasters,
      runningBalancePiasters: s.runningBalancePiasters,
      at: r.createdAt,
      rowOrder: s.rowOrder,
      invoiceId: r.salesInvoiceId,
      invoiceNumber: s.invoiceNumber,
      receiptNumber: r.receiptNumber,
      method: r.paymentMethod == null ? null : method(r.paymentMethod!),
      note: r.note,
      reversed: s.reversed,
    );
  }

  /// Types later features write (returns, refunds, adjustments) show as
  /// their nearest kind until those features add their own labels.
  static LedgerEntryType entryType(db.CustomerEntryType t) => switch (t) {
    db.CustomerEntryType.OPENING_BALANCE => LedgerEntryType.openingBalance,
    db.CustomerEntryType.SALE => LedgerEntryType.sale,
    db.CustomerEntryType.PAYMENT_RECEIVED => LedgerEntryType.payment,
    db.CustomerEntryType.SALE_VOID => LedgerEntryType.saleVoid,
    db.CustomerEntryType.REVERSAL ||
    db.CustomerEntryType.SALE_RETURN ||
    db.CustomerEntryType.REFUND_PAID ||
    db.CustomerEntryType.ADJUSTMENT => LedgerEntryType.reversal,
  };

  static PaymentMethod method(db.PaymentMethod m) => switch (m) {
    db.PaymentMethod.cash => PaymentMethod.cash,
    db.PaymentMethod.wallet => PaymentMethod.wallet,
    db.PaymentMethod.instapay => PaymentMethod.instapay,
    db.PaymentMethod.card => PaymentMethod.card,
  };

  static db.PaymentMethod toDb(PaymentMethod m) => switch (m) {
    PaymentMethod.cash => db.PaymentMethod.cash,
    PaymentMethod.wallet => db.PaymentMethod.wallet,
    PaymentMethod.instapay => db.PaymentMethod.instapay,
    PaymentMethod.card => db.PaymentMethod.card,
  };
}
