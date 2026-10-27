import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reports/domain/report_period.dart';
import '../../../reports/presentation/cubits/report_period_cubit.dart';
import '../../domain/expense.dart';
import '../../domain/expense_repository.dart';

final class ExpensesListState extends Equatable {
  const ExpensesListState({
    required this.query,
    this.items = const [],
    this.totalPiasters = 0,
    this.categories = const [],
    this.limit = ExpensesListCubit.pageSize,
    this.loading = true,
    this.loadFailed = false,
  });

  final ExpenseQuery query;

  /// Newest first; voided ones included and marked.
  final List<Expense> items;

  /// The expenses matching [query] that are not voided.
  final int totalPiasters;

  /// Active categories, for the filter.
  final List<ExpenseCategory> categories;
  final int limit;
  final bool loading;

  /// A stream failed; [ExpensesListCubit.retry] tries again.
  final bool loadFailed;

  /// A full page came back, so there may be more.
  bool get hasMore => items.length >= limit;

  ExpensesListState copyWith({
    ExpenseQuery? query,
    List<Expense>? items,
    int? totalPiasters,
    List<ExpenseCategory>? categories,
    int? limit,
    bool? loading,
    bool? loadFailed,
  }) => ExpensesListState(
    query: query ?? this.query,
    items: items ?? this.items,
    totalPiasters: totalPiasters ?? this.totalPiasters,
    categories: categories ?? this.categories,
    limit: limit ?? this.limit,
    loading: loading ?? this.loading,
    loadFailed: loadFailed ?? this.loadFailed,
  );

  @override
  List<Object?> get props => [
    query,
    items,
    totalPiasters,
    categories,
    limit,
    loading,
    loadFailed,
  ];
}

/// The expenses list (US3-5): the shared report period, a category filter,
/// the total and Show more.
class ExpensesListCubit extends Cubit<ExpensesListState> {
  ExpensesListCubit(this._expenses, this._categories, ReportPeriodCubit periods)
    : super(ExpensesListState(query: ExpenseQuery(period: periods.state))) {
    _periodSub = periods.stream.listen((period) {
      emit(
        state.copyWith(
          query: state.query.copyWith(period: period),
          limit: pageSize,
        ),
      );
      _subscribe();
    });
    _categoriesSub = _categories.watchActive().listen(
      (list) => emit(state.copyWith(categories: list)),
      onError: _failed,
    );
    _subscribe();
  }

  static const int pageSize = 50;

  final ExpenseRepository _expenses;
  final ExpenseCategoryRepository _categories;
  late final StreamSubscription<ReportPeriod> _periodSub;
  late final StreamSubscription<List<ExpenseCategory>> _categoriesSub;
  StreamSubscription<List<Expense>>? _listSub;
  StreamSubscription<int>? _totalSub;

  /// Null shows every category.
  void filterCategory(String? categoryId) {
    if (categoryId == state.query.categoryId) return;
    emit(
      state.copyWith(
        query: state.query.copyWith(categoryId: () => categoryId),
        limit: pageSize,
      ),
    );
    _subscribe();
  }

  void showMore() {
    if (!state.hasMore || state.loading) return;
    emit(state.copyWith(limit: state.limit + pageSize));
    _subscribe();
  }

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  void _subscribe() {
    unawaited(_listSub?.cancel());
    unawaited(_totalSub?.cancel());
    emit(state.copyWith(loading: true, loadFailed: false));
    _listSub = _expenses
        .watchList(state.query, limit: state.limit)
        .listen(
          (items) => emit(state.copyWith(items: items, loading: false)),
          onError: _failed,
        );
    _totalSub = _expenses
        .watchTotal(state.query)
        .listen(
          (total) => emit(state.copyWith(totalPiasters: total)),
          onError: _failed,
        );
  }

  void _failed(Object error, StackTrace stack) {
    emit(state.copyWith(loading: false, loadFailed: true));
    addError(error, stack);
  }

  @override
  Future<void> close() async {
    await _periodSub.cancel();
    await _categoriesSub.cancel();
    await _listSub?.cancel();
    await _totalSub?.cancel();
    return super.close();
  }
}
