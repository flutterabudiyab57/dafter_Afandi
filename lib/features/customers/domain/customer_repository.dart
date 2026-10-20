import 'package:equatable/equatable.dart';

import '../../../core/utils/result.dart';
import 'customer.dart';
import 'customer_draft.dart';
import 'customer_errors.dart';
import 'ledger_entry.dart';
import 'payment.dart';

/// Customers and their accounts (contracts/repositories-and-screens.md).
abstract interface class CustomerRepository {
  /// Active customers matching [query], in list order (research R8).
  Stream<List<CustomerSummary>> watchActive(CustomerQuery query);

  /// One customer, archived or not; null when it does not exist.
  Stream<CustomerSummary?> watchOne(String id);

  Stream<List<CustomerSummary>> watchArchived();

  /// Saves a new customer and, when set, its opening balance, in one
  /// transaction.
  Future<Result<CustomerSaved, CustomerSaveError>> create(CustomerDraft draft);

  /// Saves edits; the opening balance is ignored.
  Future<Result<CustomerSaved, CustomerSaveError>> update(
    String id,
    CustomerDraft draft,
  );

  Future<void> archive(String id);

  Future<void> restore(String id);

  /// Statement rows, newest first, in pages (research R9).
  Future<List<LedgerEntry>> statement(
    String customerId, {
    LedgerCursor? before,
    int limit = 50,
  });

  /// Records a payment and returns its receipt number.
  Future<Result<int, PaymentError>> receivePayment(
    String customerId,
    PaymentRequest request,
  );

  /// Cancels a standalone payment with a reversing row.
  Future<Result<void, PaymentError>> cancelPayment(
    String entryId,
    String reason,
  );
}

/// A saved customer, and whether another active customer has the same name.
final class CustomerSaved extends Equatable {
  const CustomerSaved({required this.id, required this.nameExistsElsewhere});

  final String id;
  final bool nameExistsElsewhere;

  @override
  List<Object?> get props => [id, nameExistsElsewhere];
}
