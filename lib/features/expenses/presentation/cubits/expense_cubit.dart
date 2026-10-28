import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/expense.dart';
import '../../domain/expense_errors.dart';
import '../../domain/expense_repository.dart';

final class ExpenseState extends Equatable {
  const ExpenseState({
    this.expense,
    this.loaded = false,
    this.loadFailed = false,
  });

  /// Null when the expense does not exist.
  final Expense? expense;
  final bool loaded;

  /// The stream failed; [ExpenseCubit.retry] tries again.
  final bool loadFailed;

  @override
  List<Object?> get props => [expense, loaded, loadFailed];
}

/// One expense and voiding it (US3-3, US3-4).
class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit(this._repository, this.expenseId) : super(const ExpenseState()) {
    _subscribe();
  }

  final ExpenseRepository _repository;
  final String expenseId;
  StreamSubscription<Expense?>? _sub;

  void _subscribe() {
    unawaited(_sub?.cancel());
    _sub = _repository
        .watchOne(expenseId)
        .listen(
          (e) => emit(ExpenseState(expense: e, loaded: true)),
          onError: (Object error, StackTrace stack) {
            emit(const ExpenseState(loadFailed: true));
            addError(error, stack);
          },
        );
  }

  /// Subscribes again after a failed load.
  void retry() {
    emit(const ExpenseState());
    _subscribe();
  }

  /// [reason] is already validated. Returns the refusal, if any.
  Future<ExpenseVoidError?> voidExpense(String reason) async =>
      switch (await _repository.voidExpense(expenseId, reason)) {
        Ok() => null,
        Err(:final error) => error,
      };

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
