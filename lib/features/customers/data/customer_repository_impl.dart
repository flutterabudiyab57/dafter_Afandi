import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/counters_dao.dart';
import '../../../core/database/daos/customer_ledger_dao.dart';
import '../../../core/database/daos/customers_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/arabic_normalize.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/digits.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/result.dart';
import '../../payments/data/payment_parts_writer.dart';
import '../domain/customer.dart';
import '../domain/customer_draft.dart';
import '../domain/customer_errors.dart';
import '../domain/customer_repository.dart';
import '../domain/ledger_entry.dart';
import '../domain/payment.dart';
import 'customer_mappers.dart';

final class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(
    this._customers,
    this._ledger,
    this._counters,
    this._tx,
    this._ids,
    this._clock,
    this._parts,
  );

  final CustomersDao _customers;
  final CustomerLedgerDao _ledger;
  final CountersDao _counters;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;
  final PaymentPartsWriter _parts;

  /// Only the digits of [text], for the phone match; empty when it has none.
  static String phoneDigits(String text) =>
      normalizeDigits(text).replaceAll(RegExp('[^0-9]'), '');

  @override
  Stream<List<CustomerSummary>> watchActive(CustomerQuery query) => _customers
      .watchActive(
        normalizedQuery: query.normalizedText,
        phoneQuery: phoneDigits(query.text),
        owesOnly: query.owesOnly,
      )
      .map((rows) => rows.map(CustomerMappers.summary).toList());

  @override
  Stream<CustomerSummary?> watchOne(String id) => _customers
      .watchOne(id)
      .map((row) => row == null ? null : CustomerMappers.summary(row));

  @override
  Stream<int> watchTotalOwing() => _customers.watchTotalOwing();

  @override
  Stream<List<CustomerSummary>> watchArchived() => _customers
      .watchArchived()
      .map((rows) => rows.map(CustomerMappers.summary).toList());

  /// W1 customer; W2 OPENING_BALANCE when the draft has one.
  @override
  Future<Result<CustomerSaved, CustomerSaveError>> create(
    CustomerDraft draft,
  ) => _tx.run(() async {
    final id = _ids.newId();
    final now = _clock.nowUtc();
    final key = arabicNormalize(draft.name);
    await _customers.insertCustomer(
      CustomersCompanion.insert(
        id: id,
        name: draft.name,
        searchKey: key,
        phone: Value(draft.phone),
        address: Value(draft.address),
        note: Value(draft.note),
        createdAt: now,
        updatedAt: now,
      ),
    );
    if (draft.openingBalancePiasters != 0) {
      await _ledger.insertEntry(
        CustomerLedgerCompanion.insert(
          id: _ids.newId(),
          customerId: id,
          entryType: db.CustomerEntryType.OPENING_BALANCE,
          amountPiasters: draft.openingBalancePiasters,
          createdAt: now,
        ),
      );
    }
    return Ok(
      CustomerSaved(
        id: id,
        nameExistsElsewhere: await _customers.activeNameExists(
          key,
          exceptId: id,
        ),
      ),
    );
  });

  @override
  Future<Result<CustomerSaved, CustomerSaveError>> update(
    String id,
    CustomerDraft draft,
  ) => _tx.run(() async {
    if (await _customers.byId(id) == null) {
      return const Err(CustomerNotFound());
    }
    final key = arabicNormalize(draft.name);
    await _customers.updateCustomer(
      id,
      CustomersCompanion(
        name: Value(draft.name),
        searchKey: Value(key),
        phone: Value(draft.phone),
        address: Value(draft.address),
        note: Value(draft.note),
        updatedAt: Value(_clock.nowUtc()),
      ),
    );
    return Ok(
      CustomerSaved(
        id: id,
        nameExistsElsewhere: await _customers.activeNameExists(
          key,
          exceptId: id,
        ),
      ),
    );
  });

  @override
  Future<void> archive(String id) => _tx.run(() async {
    final now = _clock.nowUtc();
    await _customers.setArchivedAt(id, now, now);
  });

  @override
  Future<void> restore(String id) =>
      _tx.run(() => _customers.setArchivedAt(id, null, _clock.nowUtc()));

  @override
  Future<int> purgeArchived() =>
      _customers.purgeArchived(_clock.nowUtc().subtract(kArchivePurgeAfter));

  @override
  Future<List<LedgerEntry>> statement(
    String customerId, {
    LedgerCursor? before,
    int limit = 50,
  }) async {
    final rows = await _ledger.statementPage(
      customerId,
      beforeAtMillis: before?.at.millisecondsSinceEpoch,
      beforeRowOrder: before?.rowOrder,
      limit: limit,
    );
    return rows.map(CustomerMappers.entry).toList();
  }

  @override
  Stream<void> watchStatementChanges(String customerId) =>
      _ledger.watchCountOf(customerId).distinct();

  /// R1 customer active; W1 CUSTOMER_RECEIPT number; W2 PAYMENT_RECEIVED;
  /// W3 its payment parts (006).
  @override
  Future<Result<int, PaymentError>> receivePayment(
    String customerId,
    PaymentRequest request,
  ) => _tx.run(() async {
    final customer = await _customers.byId(customerId);
    if (customer == null) return const Err(PaymentCustomerNotFound());
    if (customer.archivedAt != null) {
      return const Err(PaymentCustomerArchived());
    }
    final now = _clock.nowUtc();
    final number = await _counters.take(db.DocType.CUSTOMER_RECEIPT, now);
    final entryId = _ids.newId();
    await _ledger.insertEntry(
      CustomerLedgerCompanion.insert(
        id: entryId,
        customerId: customerId,
        entryType: db.CustomerEntryType.PAYMENT_RECEIVED,
        amountPiasters: -request.amountPiasters,
        receiptNumber: Value(number),
        paymentMethod: Value(CustomerMappers.toDb(request.method)),
        note: Value(request.note),
        createdAt: now,
      ),
    );
    await _parts.write(
      ReceiptParent(entryId),
      request.split,
      paidPiasters: request.amountPiasters,
      at: now,
    );
    return Ok(number);
  });

  /// R1 a receipt payment not yet reversed; W1 REVERSAL of the same amount.
  @override
  Future<Result<void, PaymentError>> cancelPayment(
    String entryId,
    String reason,
  ) => _tx.run(() async {
    final String trimmed;
    switch (validateReason(reason)) {
      case Ok(:final value):
        trimmed = value;
      case Err():
        return const Err(PaymentReasonInvalid());
    }
    final row = await _ledger.byId(entryId);
    if (row == null ||
        row.entryType != db.CustomerEntryType.PAYMENT_RECEIVED ||
        row.receiptNumber == null) {
      return const Err(PaymentNotCancellable());
    }
    if (await _ledger.isReversed(entryId)) {
      return const Err(PaymentAlreadyCancelled());
    }
    await _ledger.insertEntry(
      CustomerLedgerCompanion.insert(
        id: _ids.newId(),
        customerId: row.customerId,
        entryType: db.CustomerEntryType.REVERSAL,
        amountPiasters: -row.amountPiasters,
        reversesEntryId: Value(entryId),
        note: Value(trimmed),
        createdAt: _clock.nowUtc(),
      ),
    );
    return const Ok(null);
  });
}
