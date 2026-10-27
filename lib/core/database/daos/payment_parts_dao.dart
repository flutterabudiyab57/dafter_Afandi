import 'package:drift/drift.dart';

import '../app_database.dart';
import '../converters/utc_millis_converter.dart';
import '../tables/enums.dart';
import '../tables/payment_parts_table.dart';

part 'payment_parts_dao.g.dart';

/// An account number the owner used before, with when it was last used.
final class AccountSuggestionRow {
  const AccountSuggestionRow({
    required this.accountRef,
    required this.lastUsedAt,
  });

  final String accountRef;
  final DateTime lastUsedAt;
}

/// Payment parts (006 data-model): inserts and reads only; triggers refuse
/// updates and deletes.
@DriftAccessor(tables: [PaymentParts])
class PaymentPartsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentPartsDaoMixin {
  PaymentPartsDao(super.attachedDatabase);

  Future<void> insertPart(PaymentPartsCompanion row) =>
      into(paymentParts).insert(row);

  Future<List<PaymentPartRow>> partsOfSale(String salesInvoiceId) =>
      _partsWhere((p) => p.salesInvoiceId.equals(salesInvoiceId));

  Future<List<PaymentPartRow>> partsOfPurchase(String purchaseInvoiceId) =>
      _partsWhere((p) => p.purchaseInvoiceId.equals(purchaseInvoiceId));

  Future<List<PaymentPartRow>> partsOfLedgerEntry(String customerLedgerId) =>
      _partsWhere((p) => p.customerLedgerId.equals(customerLedgerId));

  Future<List<PaymentPartRow>> partsOfSupplierEntry(String supplierLedgerId) =>
      _partsWhere((p) => p.supplierLedgerId.equals(supplierLedgerId));

  Future<List<PaymentPartRow>> partsOfExpense(String expenseId) =>
      _partsWhere((p) => p.expenseId.equals(expenseId));

  /// The parts of every expense in [expenseIds], by expense then part.
  Future<List<PaymentPartRow>> partsOfExpenses(List<String> expenseIds) =>
      (select(paymentParts)
            ..where((p) => p.expenseId.isIn(expenseIds))
            ..orderBy([
              (p) => OrderingTerm.asc(p.expenseId),
              (p) => OrderingTerm.asc(p.partNo),
            ]))
          .get();

  Future<List<PaymentPartRow>> _partsWhere(
    Expression<bool> Function(PaymentParts p) filter,
  ) =>
      (select(paymentParts)
            ..where(filter)
            ..orderBy([(p) => OrderingTerm.asc(p.partNo)]))
          .get();

  /// The distinct account numbers used with [method], most recent first.
  Future<List<AccountSuggestionRow>> suggestions(
    PaymentMethod method, {
    int limit = 5,
  }) async {
    final rows = await customSelect(
      'SELECT account_ref, MAX(created_at) AS last_used FROM payment_parts '
      'WHERE method = ?1 AND account_ref IS NOT NULL '
      'GROUP BY account_ref ORDER BY last_used DESC, account_ref LIMIT ?2',
      variables: [Variable<String>(method.name), Variable<int>(limit)],
      readsFrom: {paymentParts},
    ).get();
    return [
      for (final r in rows)
        AccountSuggestionRow(
          accountRef: r.read<String>('account_ref'),
          lastUsedAt: const UtcMillisConverter().fromSql(
            r.read<int>('last_used'),
          ),
        ),
    ];
  }
}
