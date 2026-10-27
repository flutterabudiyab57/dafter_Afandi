import 'dart:async';

import 'package:daftar_afandi/core/utils/arabic_normalize.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/expenses/domain/expense.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_draft.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_errors.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_repository.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expense_categories_cubit.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expense_cubit.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expense_form_cubit.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expenses_list_cubit.dart';
import 'package:daftar_afandi/features/expenses/presentation/expenses_cubits.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/report_period_cubit.dart';

/// The fakes' "now": 2026-10-26 10:00 UTC, as for the reports fake.
final FixedClock kExpensesClock = FixedClock(DateTime.utc(2026, 10, 26, 10));

/// An in-memory [ExpenseRepository] and [ExpenseCategoryRepository] with
/// the real rules: E- numbers, void once, unique active names, defaults
/// only into an empty list.
final class FakeExpensesStore implements ExpenseRepository {
  FakeExpensesStore({Clock? clock}) : _clock = clock ?? kExpensesClock;

  /// The categories half, on the same data.
  late final FakeExpenseCategories categoryRepo = FakeExpenseCategories._(this);

  final Clock _clock;
  final List<ExpenseCategory> _categories = [];
  final List<Expense> _expenses = [];
  final StreamController<void> _changes = StreamController.broadcast();
  var _nextId = 0;

  /// When set, the next subscription fails with it.
  Object? failNextWatch;

  /// When set, the next create fails with it.
  Object? failNextCreate;

  List<Expense> get expenses => List.unmodifiable(_expenses);

  List<ExpenseCategory> get categories => List.unmodifiable(_categories);

  /// Adds a category directly; returns its id.
  String addCategory(String name, {bool archived = false}) {
    final id = 'c${++_nextId}';
    _categories.add(ExpenseCategory(id: id, name: name, archived: archived));
    _changes.add(null);
    return id;
  }

  /// Adds a saved expense directly; returns it.
  Expense addExpense(Expense e) {
    _expenses.add(e);
    _changes.add(null);
    return e;
  }

  Stream<T> _watch<T>(T Function() read) async* {
    if (failNextWatch case final error?) {
      failNextWatch = null;
      throw error;
    }
    yield read();
    yield* _changes.stream.map((_) => read());
  }

  bool _matches(Expense e, ExpenseQuery q) {
    final day = DateTime(e.spentOn.year, e.spentOn.month, e.spentOn.day);
    return !day.isBefore(q.period.from) &&
        !day.isAfter(q.period.to) &&
        (q.categoryId == null || e.category.id == q.categoryId);
  }

  @override
  Stream<List<Expense>> watchList(ExpenseQuery query, {int limit = 50}) =>
      _watch(() {
        final list = _expenses.where((e) => _matches(e, query)).toList()
          ..sort((a, b) {
            final byDay = b.spentOn.compareTo(a.spentOn);
            return byDay != 0 ? byDay : b.number.compareTo(a.number);
          });
        return list.take(limit).toList();
      });

  @override
  Stream<int> watchTotal(ExpenseQuery query) => _watch(
    () => _expenses
        .where((e) => !e.isVoided && _matches(e, query))
        .fold(0, (sum, e) => sum + e.amountPiasters),
  );

  @override
  Stream<Expense?> watchOne(String id) =>
      _watch(() => _expenses.where((e) => e.id == id).firstOrNull);

  @override
  Future<Result<ExpenseSaved, ExpenseSaveError>> create(
    ExpenseDraft draft,
  ) async {
    if (failNextCreate case final error?) {
      failNextCreate = null;
      throw error;
    }
    final category = _categories
        .where((c) => c.id == draft.categoryId)
        .firstOrNull;
    if (category == null) return const Err(ExpenseCategoryUnavailable());
    if (category.archived) {
      return const Err(ExpenseInvalid([ExpenseCategoryArchived()]));
    }
    final number = _expenses.length + 1;
    final e = Expense(
      id: 'e$number',
      number: number,
      category: category,
      amountPiasters: draft.amountPiasters,
      parts: draft.split.parts,
      spentOn: draft.spentOn,
      createdAt: _clock.nowUtc(),
      note: draft.note,
    );
    addExpense(e);
    return Ok(ExpenseSaved(id: e.id, number: number));
  }

  @override
  Future<Result<void, ExpenseVoidError>> voidExpense(
    String id,
    String reason,
  ) async {
    final i = _expenses.indexWhere((e) => e.id == id);
    if (i < 0) return const Err(ExpenseNotFound());
    final e = _expenses[i];
    if (e.isVoided) return const Err(ExpenseAlreadyVoided());
    _expenses[i] = Expense(
      id: e.id,
      number: e.number,
      category: e.category,
      amountPiasters: e.amountPiasters,
      parts: e.parts,
      spentOn: e.spentOn,
      createdAt: e.createdAt,
      note: e.note,
      voidedAt: _clock.nowUtc(),
      voidReason: reason.trim(),
    );
    _changes.add(null);
    return const Ok(null);
  }
}

/// The [ExpenseCategoryRepository] half of a [FakeExpensesStore].
final class FakeExpenseCategories implements ExpenseCategoryRepository {
  FakeExpenseCategories._(this._s);

  final FakeExpensesStore _s;

  List<ExpenseCategory> _sorted({required bool archived}) =>
      _s._categories.where((c) => c.archived == archived).toList()..sort(
        (a, b) => arabicNormalize(a.name).compareTo(arabicNormalize(b.name)),
      );

  @override
  Stream<List<ExpenseCategory>> watchActive() =>
      _s._watch(() => _sorted(archived: false));

  @override
  Stream<List<ExpenseCategory>> watchArchived() =>
      _s._watch(() => _sorted(archived: true));

  @override
  Future<void> ensureDefaults(List<String> names) async {
    if (_s._categories.isNotEmpty) return;
    names.forEach(_s.addCategory);
  }

  ExpenseCategory? _activeNamed(String name, {String? exceptId}) {
    final key = arabicNormalize(name);
    return _s._categories
        .where(
          (c) =>
              !c.archived && c.id != exceptId && arabicNormalize(c.name) == key,
        )
        .firstOrNull;
  }

  @override
  Future<Result<String, ExpenseCategoryError>> create(String name) async {
    if (validateExpenseCategoryName(name) case final error?) return Err(error);
    if (_activeNamed(name) case final taken?) {
      return Err(ExpenseCategoryNameTaken(taken.name));
    }
    return Ok(_s.addCategory(name.trim()));
  }

  @override
  Future<Result<void, ExpenseCategoryError>> rename(
    String id,
    String name,
  ) async {
    if (validateExpenseCategoryName(name) case final error?) return Err(error);
    final i = _s._categories.indexWhere((c) => c.id == id);
    if (i < 0) return const Err(ExpenseCategoryNotFound());
    if (_activeNamed(name, exceptId: id) case final taken?) {
      return Err(ExpenseCategoryNameTaken(taken.name));
    }
    _set(i, name: name.trim());
    return const Ok(null);
  }

  @override
  Future<void> archive(String id) async =>
      _set(_s._categories.indexWhere((c) => c.id == id), archived: true);

  @override
  Future<Result<void, ExpenseCategoryError>> restore(String id) async {
    final i = _s._categories.indexWhere((c) => c.id == id);
    if (i < 0) return const Err(ExpenseCategoryNotFound());
    if (_activeNamed(_s._categories[i].name, exceptId: id) case final taken?) {
      return Err(ExpenseCategoryNameTaken(taken.name));
    }
    _set(i, archived: false);
    return const Ok(null);
  }

  void _set(int i, {String? name, bool? archived}) {
    final c = _s._categories[i];
    _s._categories[i] = ExpenseCategory(
      id: c.id,
      name: name ?? c.name,
      archived: archived ?? c.archived,
    );
    _s._changes.add(null);
  }
}

final class FakeExpensesCubits implements ExpensesCubits {
  FakeExpensesCubits([FakeExpensesStore? store, Clock? clock])
    : store = store ?? FakeExpensesStore(clock: clock),
      clock = clock ?? kExpensesClock;

  final FakeExpensesStore store;
  final Clock clock;

  @override
  ExpensesListCubit expensesList(ReportPeriodCubit periods) =>
      ExpensesListCubit(store, store.categoryRepo, periods);

  @override
  ExpenseFormCubit expenseForm() =>
      ExpenseFormCubit(store, store.categoryRepo, clock);

  @override
  ExpenseCubit expense(String id) => ExpenseCubit(store, id);

  @override
  ExpenseCategoriesCubit expenseCategories() =>
      ExpenseCategoriesCubit(store.categoryRepo);
}
