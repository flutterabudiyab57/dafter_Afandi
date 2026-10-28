import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/report_types.dart';
import '../../domain/reports_repository.dart';

final class BalancesState extends Equatable {
  const BalancesState({
    this.customers,
    this.suppliers,
    this.loadFailed = false,
  });

  /// Customers who owe the shop, largest first; null while loading.
  final List<BalanceRow>? customers;

  /// Suppliers the shop owes, largest first; null while loading.
  final List<BalanceRow>? suppliers;

  /// A stream failed; [BalancesCubit.retry] tries again.
  final bool loadFailed;

  static int total(List<BalanceRow> rows) =>
      rows.fold(0, (sum, r) => sum + r.balancePiasters);

  BalancesState copyWith({
    List<BalanceRow>? customers,
    List<BalanceRow>? suppliers,
    bool? loadFailed,
  }) => BalancesState(
    customers: customers ?? this.customers,
    suppliers: suppliers ?? this.suppliers,
    loadFailed: loadFailed ?? this.loadFailed,
  );

  @override
  List<Object?> get props => [customers, suppliers, loadFailed];
}

/// Who owes the shop and whom the shop owes, as of now (US5, FR-015).
class BalancesCubit extends Cubit<BalancesState> {
  BalancesCubit(this._repository) : super(const BalancesState()) {
    _subscribe();
  }

  final ReportsRepository _repository;
  StreamSubscription<List<BalanceRow>>? _customers;
  StreamSubscription<List<BalanceRow>>? _suppliers;

  void retry() => _subscribe();

  void _subscribe() {
    unawaited(_customers?.cancel());
    unawaited(_suppliers?.cancel());
    if (state.loadFailed) emit(const BalancesState());
    _customers = _repository.watchCustomersOwing().listen(
      (rows) => emit(state.copyWith(customers: rows)),
      onError: _failed,
    );
    _suppliers = _repository.watchSuppliersOwed().listen(
      (rows) => emit(state.copyWith(suppliers: rows)),
      onError: _failed,
    );
  }

  void _failed(Object error, StackTrace stack) {
    if (isClosed) return;
    emit(state.copyWith(loadFailed: true));
    addError(error, stack);
  }

  @override
  Future<void> close() async {
    await _customers?.cancel();
    await _suppliers?.cancel();
    return super.close();
  }
}
