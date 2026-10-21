import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/counters_dao.dart';
import '../../../core/database/daos/supplier_ledger_dao.dart';
import '../../../core/database/daos/suppliers_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/arabic_normalize.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/result.dart';
import '../../customers/data/customer_mappers.dart';
import '../../customers/data/customer_repository_impl.dart'
    show CustomerRepositoryImpl;
import '../../customers/domain/ledger_entry.dart';
import '../../customers/domain/payment.dart';
import '../domain/supplier.dart';
import '../domain/supplier_draft.dart';
import '../domain/supplier_entry.dart';
import '../domain/supplier_errors.dart';
import '../domain/supplier_repository.dart';
import 'supplier_mappers.dart';

final class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(
    this._suppliers,
    this._ledger,
    this._counters,
    this._tx,
    this._ids,
    this._clock,
  );

  final SuppliersDao _suppliers;
  final SupplierLedgerDao _ledger;
  final CountersDao _counters;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Stream<List<SupplierSummary>> watchActive(SupplierQuery query) => _suppliers
      .watchActive(
        normalizedQuery: query.normalizedText,
        phoneQuery: CustomerRepositoryImpl.phoneDigits(query.text),
        owedOnly: query.owedOnly,
      )
      .map((rows) => rows.map(SupplierMappers.summary).toList());

  @override
  Stream<SupplierSummary?> watchOne(String id) => _suppliers
      .watchOne(id)
      .map((row) => row == null ? null : SupplierMappers.summary(row));

  @override
  Stream<List<SupplierSummary>> watchArchived() => _suppliers
      .watchArchived()
      .map((rows) => rows.map(SupplierMappers.summary).toList());

  /// C1 supplier; C2 OPENING_BALANCE when the draft has one.
  @override
  Future<Result<SupplierSaved, SupplierSaveError>> create(
    SupplierDraft draft,
  ) => _tx.run(() async {
    final id = _ids.newId();
    final now = _clock.nowUtc();
    final key = arabicNormalize(draft.name);
    await _suppliers.insertSupplier(
      SuppliersCompanion.insert(
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
        SupplierLedgerCompanion.insert(
          id: _ids.newId(),
          supplierId: id,
          entryType: db.SupplierEntryType.OPENING_BALANCE,
          amountPiasters: draft.openingBalancePiasters,
          createdAt: now,
        ),
      );
    }
    return Ok(
      SupplierSaved(
        id: id,
        nameExistsElsewhere: await _suppliers.activeNameExists(
          key,
          exceptId: id,
        ),
      ),
    );
  });

  @override
  Future<Result<SupplierSaved, SupplierSaveError>> update(
    String id,
    SupplierDraft draft,
  ) => _tx.run(() async {
    if (await _suppliers.byId(id) == null) {
      return const Err(SupplierNotFound());
    }
    final key = arabicNormalize(draft.name);
    await _suppliers.updateSupplier(
      id,
      SuppliersCompanion(
        name: Value(draft.name),
        searchKey: Value(key),
        phone: Value(draft.phone),
        address: Value(draft.address),
        note: Value(draft.note),
        updatedAt: Value(_clock.nowUtc()),
      ),
    );
    return Ok(
      SupplierSaved(
        id: id,
        nameExistsElsewhere: await _suppliers.activeNameExists(
          key,
          exceptId: id,
        ),
      ),
    );
  });

  @override
  Future<void> archive(String id) => _tx.run(() async {
    final now = _clock.nowUtc();
    await _suppliers.setArchivedAt(id, now, now);
  });

  @override
  Future<void> restore(String id) =>
      _tx.run(() => _suppliers.setArchivedAt(id, null, _clock.nowUtc()));

  @override
  Future<List<SupplierEntry>> statement(
    String supplierId, {
    LedgerCursor? before,
    int limit = 50,
  }) async {
    final rows = await _ledger.statementPage(
      supplierId,
      beforeAtMillis: before?.at.millisecondsSinceEpoch,
      beforeRowOrder: before?.rowOrder,
      limit: limit,
    );
    return rows.map(SupplierMappers.entry).toList();
  }

  @override
  Stream<void> watchStatementChanges(String supplierId) =>
      _ledger.watchCountOf(supplierId).distinct();

  /// R1 supplier active; P1 SUPPLIER_PAYMENT number; P2 PAYMENT_MADE.
  @override
  Future<Result<int, SupplierPaymentError>> pay(
    String supplierId,
    PaymentRequest request,
  ) => _tx.run(() async {
    final supplier = await _suppliers.byId(supplierId);
    if (supplier == null) return const Err(PaymentSupplierNotFound());
    if (supplier.archivedAt != null) {
      return const Err(PaymentSupplierArchived());
    }
    final now = _clock.nowUtc();
    final number = await _counters.take(db.DocType.SUPPLIER_PAYMENT, now);
    await _ledger.insertEntry(
      SupplierLedgerCompanion.insert(
        id: _ids.newId(),
        supplierId: supplierId,
        entryType: db.SupplierEntryType.PAYMENT_MADE,
        amountPiasters: -request.amountPiasters,
        paymentNumber: Value(number),
        paymentMethod: Value(CustomerMappers.toDb(request.method)),
        note: Value(request.note),
        createdAt: now,
      ),
    );
    return Ok(number);
  });

  /// R1 a standalone payment not yet reversed; X1 REVERSAL of the same
  /// amount.
  @override
  Future<Result<void, SupplierPaymentError>> cancelPayment(
    String entryId,
    String reason,
  ) => _tx.run(() async {
    final String trimmed;
    switch (validateReason(reason)) {
      case Ok(:final value):
        trimmed = value;
      case Err():
        return const Err(SupplierPaymentReasonInvalid());
    }
    final row = await _ledger.byId(entryId);
    if (row == null ||
        row.entryType != db.SupplierEntryType.PAYMENT_MADE ||
        row.paymentNumber == null) {
      return const Err(SupplierPaymentNotCancellable());
    }
    if (await _ledger.isReversed(entryId)) {
      return const Err(SupplierPaymentAlreadyCancelled());
    }
    await _ledger.insertEntry(
      SupplierLedgerCompanion.insert(
        id: _ids.newId(),
        supplierId: row.supplierId,
        entryType: db.SupplierEntryType.REVERSAL,
        amountPiasters: -row.amountPiasters,
        reversesEntryId: Value(entryId),
        note: Value(trimmed),
        createdAt: _clock.nowUtc(),
      ),
    );
    return const Ok(null);
  });
}
