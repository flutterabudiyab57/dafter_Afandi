import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/expense.dart';
import '../../domain/expense_errors.dart';
import '../../domain/expense_repository.dart';

final class ExpenseCategoriesState extends Equatable {
  const ExpenseCategoriesState({
    this.active = const [],
    this.archived = const [],
    this.loaded = false,
    this.loadFailed = false,
  });

  final List<ExpenseCategory> active;
  final List<ExpenseCategory> archived;
  final bool loaded;

  /// A stream failed; [ExpenseCategoriesCubit.retry] tries again.
  final bool loadFailed;

  ExpenseCategoriesState copyWith({
    List<ExpenseCategory>? active,
    List<ExpenseCategory>? archived,
    bool? loaded,
    bool? loadFailed,
  }) => ExpenseCategoriesState(
    active: active ?? this.active,
    archived: archived ?? this.archived,
    loaded: loaded ?? this.loaded,
    loadFailed: loadFailed ?? this.loadFailed,
  );

  @override
  List<Object?> get props => [active, archived, loaded, loadFailed];
}

/// Expense categories: add, rename, archive, restore (US3-6, US3-7). Writes
/// return their error, if any, for the field or dialog that asked.
class ExpenseCategoriesCubit extends Cubit<ExpenseCategoriesState> {
  ExpenseCategoriesCubit(this._repository)
    : super(const ExpenseCategoriesState()) {
    _subscribe();
  }

  final ExpenseCategoryRepository _repository;
  StreamSubscription<List<ExpenseCategory>>? _activeSub;
  StreamSubscription<List<ExpenseCategory>>? _archivedSub;

  /// The four defaults, in the shop's language, the first time only
  /// (research R13).
  Future<void> ensureDefaults(List<String> names) =>
      _repository.ensureDefaults(names);

  Future<ExpenseCategoryError?> create(String name) async =>
      _errorOf(await _repository.create(name));

  Future<ExpenseCategoryError?> rename(String id, String name) async =>
      _errorOf(await _repository.rename(id, name));

  Future<void> archive(String id) => _repository.archive(id);

  Future<ExpenseCategoryError?> restore(String id) async =>
      _errorOf(await _repository.restore(id));

  static ExpenseCategoryError? _errorOf<T>(Result<T, ExpenseCategoryError> r) =>
      switch (r) {
        Ok() => null,
        Err(:final error) => error,
      };

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  void _subscribe() {
    unawaited(_activeSub?.cancel());
    unawaited(_archivedSub?.cancel());
    if (state.loadFailed) emit(state.copyWith(loadFailed: false));
    _activeSub = _repository.watchActive().listen(
      (list) => emit(state.copyWith(active: list, loaded: true)),
      onError: _failed,
    );
    _archivedSub = _repository.watchArchived().listen(
      (list) => emit(state.copyWith(archived: list)),
      onError: _failed,
    );
  }

  void _failed(Object error, StackTrace stack) {
    emit(state.copyWith(loaded: true, loadFailed: true));
    addError(error, stack);
  }

  @override
  Future<void> close() async {
    await _activeSub?.cancel();
    await _archivedSub?.cancel();
    return super.close();
  }
}
