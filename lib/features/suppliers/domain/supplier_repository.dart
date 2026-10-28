import 'package:equatable/equatable.dart';

import '../../../core/utils/result.dart';
import '../../customers/domain/customer.dart' show kArchivePurgeAfter;
import '../../customers/domain/ledger_entry.dart';
import '../../customers/domain/payment.dart';
import 'supplier.dart';
import 'supplier_draft.dart';
import 'supplier_entry.dart';
import 'supplier_errors.dart';

/// Suppliers and their accounts (contracts/repositories-and-screens.md).
abstract interface class SupplierRepository {
  /// Active suppliers matching [query], in list order (research R10).
  Stream<List<SupplierSummary>> watchActive(SupplierQuery query);

  /// One supplier, archived or not; null when it does not exist.
  Stream<SupplierSummary?> watchOne(String id);

  Stream<List<SupplierSummary>> watchArchived();

  /// What the shop owes all suppliers, active or archived: the sum of
  /// the balances above 0.
  Stream<int> watchTotalOwed();

  /// Saves a new supplier and, when set, its opening balance, in one
  /// transaction.
  Future<Result<SupplierSaved, SupplierSaveError>> create(SupplierDraft draft);

  /// Saves edits; the opening balance is ignored.
  Future<Result<SupplierSaved, SupplierSaveError>> update(
    String id,
    SupplierDraft draft,
  );

  Future<void> archive(String id);

  Future<void> restore(String id);

  /// Removes for good the suppliers archived [kArchivePurgeAfter] ago or
  /// more with no history (constitution 1.2.0). Returns how many went.
  Future<int> purgeArchived();

  /// Statement rows, newest first, in pages (research R10).
  Future<List<SupplierEntry>> statement(
    String supplierId, {
    LedgerCursor? before,
    int limit = 50,
  });

  /// Emits whenever [supplierId]'s account rows change, including changes
  /// that leave the balance as it was.
  Stream<void> watchStatementChanges(String supplierId);

  /// Records a payment to the supplier and returns its payment number
  /// (research R11).
  Future<Result<int, SupplierPaymentError>> pay(
    String supplierId,
    PaymentRequest request,
  );

  /// Cancels a standalone payment with a reversing row.
  Future<Result<void, SupplierPaymentError>> cancelPayment(
    String entryId,
    String reason,
  );
}

/// A saved supplier, and whether another active supplier has the same name.
final class SupplierSaved extends Equatable {
  const SupplierSaved({required this.id, required this.nameExistsElsewhere});

  final String id;
  final bool nameExistsElsewhere;

  @override
  List<Object?> get props => [id, nameExistsElsewhere];
}
