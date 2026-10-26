import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/payment_parts_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/utils/id.dart';
import '../domain/payment_method.dart';
import '../domain/payment_split.dart';

/// The record a payment's parts belong to (006 research R2).
sealed class PaymentParent {
  const PaymentParent(this.id);

  final String id;
}

/// Paid at sale time.
final class SaleParent extends PaymentParent {
  const SaleParent(super.id);
}

/// Paid at purchase time.
final class PurchaseParent extends PaymentParent {
  const PurchaseParent(super.id);
}

/// A customer receipt: its `PAYMENT_RECEIVED` ledger row.
final class ReceiptParent extends PaymentParent {
  const ReceiptParent(super.id);
}

/// A supplier payment: its `PAYMENT_MADE` ledger row.
final class SupplierPaymentParent extends PaymentParent {
  const SupplierPaymentParent(super.id);
}

final class ExpenseParent extends PaymentParent {
  const ExpenseParent(super.id);
}

/// The parts do not add up to what was paid. Thrown inside the caller's
/// transaction, so every write of the operation rolls back.
final class PaymentPartsMismatch extends StateError {
  PaymentPartsMismatch(int parts, int paid)
    : super('payment parts add up to $parts, paid $paid');
}

/// Writes and reads payment parts. Repository impls call it inside their
/// own transaction; it is the one place that checks parts add up (R5).
class PaymentPartsWriter {
  const PaymentPartsWriter(this._dao, this._ids);

  final PaymentPartsDao _dao;
  final IdGenerator _ids;

  /// Writes [split] as parts 1..n of [parent]. Nothing is written when
  /// nothing was paid.
  Future<void> write(
    PaymentParent parent,
    PaymentSplit split, {
    required int paidPiasters,
    required DateTime at,
  }) async {
    if (split.total != paidPiasters) {
      throw PaymentPartsMismatch(split.total, paidPiasters);
    }
    for (final (i, part) in split.parts.indexed) {
      Value<String?> of(bool match) => Value(match ? parent.id : null);
      await _dao.insertPart(
        PaymentPartsCompanion.insert(
          id: _ids.newId(),
          salesInvoiceId: of(parent is SaleParent),
          purchaseInvoiceId: of(parent is PurchaseParent),
          customerLedgerId: of(parent is ReceiptParent),
          supplierLedgerId: of(parent is SupplierPaymentParent),
          expenseId: of(parent is ExpenseParent),
          partNo: i + 1,
          method: PaymentMappers.toDb(part.method),
          amountPiasters: part.amountPiasters,
          accountRef: Value(part.accountRef),
          createdAt: at,
        ),
      );
    }
  }

  Future<List<PaymentPart>> partsOf(PaymentParent parent) async {
    final rows = await switch (parent) {
      SaleParent(:final id) => _dao.partsOfSale(id),
      PurchaseParent(:final id) => _dao.partsOfPurchase(id),
      ReceiptParent(:final id) => _dao.partsOfLedgerEntry(id),
      SupplierPaymentParent(:final id) => _dao.partsOfSupplierEntry(id),
      ExpenseParent(:final id) => _dao.partsOfExpense(id),
    };
    return [for (final r in rows) PaymentMappers.part(r)];
  }
}

/// Row ↔ entity mapping for payments (constitution IV).
abstract final class PaymentMappers {
  static PaymentPart part(PaymentPartRow r) => PaymentPart(
    method: method(r.method),
    amountPiasters: r.amountPiasters,
    accountRef: r.accountRef,
  );

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
