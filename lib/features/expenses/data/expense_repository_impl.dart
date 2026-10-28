import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/counters_dao.dart';
import '../../../core/database/daos/expense_categories_dao.dart';
import '../../../core/database/daos/expenses_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/result.dart';
import '../../customers/domain/payment.dart' show validateReason;
import '../../payments/data/payment_parts_writer.dart';
import '../../payments/domain/payment_split.dart';
import '../domain/expense.dart';
import '../domain/expense_draft.dart';
import '../domain/expense_errors.dart';
import '../domain/expense_repository.dart';

final class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl(
    this._expenses,
    this._categories,
    this._counters,
    this._tx,
    this._ids,
    this._clock,
    this._parts,
  );

  final ExpensesDao _expenses;
  final ExpenseCategoriesDao _categories;
  final CountersDao _counters;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;
  final PaymentPartsWriter _parts;

  @override
  Stream<List<Expense>> watchList(ExpenseQuery query, {int limit = 50}) {
    final range = query.period.range();
    return _expenses
        .watchList(
          startUtc: range.startUtc,
          endUtc: range.endUtc,
          categoryId: query.categoryId,
          limit: limit,
        )
        .asyncMap((rows) async {
          final parts = await _parts.partsOfExpenses([
            for (final r in rows) r.expense.id,
          ]);
          return [for (final r in rows) _expense(r, parts[r.expense.id])];
        });
  }

  @override
  Stream<int> watchTotal(ExpenseQuery query) {
    final range = query.period.range();
    return _expenses.watchTotal(
      startUtc: range.startUtc,
      endUtc: range.endUtc,
      categoryId: query.categoryId,
    );
  }

  @override
  Stream<Expense?> watchOne(String id) =>
      _expenses.watchOne(id).asyncMap((row) async {
        if (row == null) return null;
        return _expense(row, await _parts.partsOf(ExpenseParent(id)));
      });

  /// Reads first, then W1 `EXPENSE` number, W2 the expense at the start of
  /// its local day, W3 its payment parts (data-model "Writes").
  @override
  Future<Result<ExpenseSaved, ExpenseSaveError>> create(ExpenseDraft draft) =>
      _tx.run(() async {
        final now = _clock.nowUtc();
        final local = now.toLocal();
        final today = DateTime(local.year, local.month, local.day);
        if (draft.spentOn.isAfter(today)) {
          return const Err(ExpenseInvalid([ExpenseDateInFuture()]));
        }
        final category = await _categories.byId(draft.categoryId);
        if (category == null) return const Err(ExpenseCategoryUnavailable());
        if (category.archivedAt != null) {
          return const Err(ExpenseInvalid([ExpenseCategoryArchived()]));
        }

        final number = await _counters.take(db.DocType.EXPENSE, now);
        final id = _ids.newId();
        await _expenses.insertExpense(
          ExpensesCompanion.insert(
            id: id,
            number: number,
            expenseCategoryId: category.id,
            amountPiasters: draft.amountPiasters,
            spentAt: draft.spentOn.toUtc(),
            note: Value(draft.note),
            createdAt: now,
            updatedAt: now,
          ),
        );
        await _parts.write(
          ExpenseParent(id),
          draft.split,
          paidPiasters: draft.amountPiasters,
          at: now,
        );
        return Ok(ExpenseSaved(id: id, number: number));
      });

  @override
  Future<Result<void, ExpenseVoidError>> voidExpense(
    String id,
    String reason,
  ) => _tx.run(() async {
    final String trimmed;
    switch (validateReason(reason)) {
      case Ok(:final value):
        trimmed = value;
      case Err():
        return const Err(ExpenseVoidReasonInvalid());
    }
    final row = await _expenses.byId(id);
    if (row == null) return const Err(ExpenseNotFound());
    if (row.voidedAt != null) return const Err(ExpenseAlreadyVoided());
    await _expenses.setVoided(id, trimmed, _clock.nowUtc());
    return const Ok(null);
  });

  static Expense _expense(ExpenseWithCategoryRow r, List<PaymentPart>? parts) {
    final e = r.expense;
    // Every expense is saved with at least one part.
    if (parts == null || parts.isEmpty) {
      throw StateError('expense ${e.id} has no payment parts');
    }
    return Expense(
      id: e.id,
      number: e.number,
      category: ExpenseCategoryMappers.category(r.category),
      amountPiasters: e.amountPiasters,
      parts: parts,
      spentOn: e.spentAt.toLocal(),
      createdAt: e.createdAt,
      note: e.note,
      voidedAt: e.voidedAt,
      voidReason: e.voidReason,
    );
  }
}

/// Row ↔ entity mapping for expense categories (constitution IV).
abstract final class ExpenseCategoryMappers {
  static ExpenseCategory category(ExpenseCategoryRow r) =>
      ExpenseCategory(id: r.id, name: r.name, archived: r.archivedAt != null);
}
