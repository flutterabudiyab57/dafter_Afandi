import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/supplier.dart';
import '../../domain/supplier_draft.dart';
import '../../domain/supplier_repository.dart';

final class SuppliersListState extends Equatable {
  const SuppliersListState({
    this.query = const SupplierQuery(),
    this.items = const [],
    this.loading = true,
    this.loadFailed = false,
    this.totalOwedPiasters,
  });

  final SupplierQuery query;
  final List<SupplierSummary> items;

  /// True until the first result for the current query arrives.
  final bool loading;

  /// The stream failed; [retry] tries again (research R7).
  final bool loadFailed;

  /// What the shop owes all suppliers; null until it loads.
  final int? totalOwedPiasters;

  SuppliersListState copyWith({
    SupplierQuery? query,
    List<SupplierSummary>? items,
    bool? loading,
    bool? loadFailed,
    int? totalOwedPiasters,
  }) => SuppliersListState(
    query: query ?? this.query,
    items: items ?? this.items,
    loading: loading ?? this.loading,
    loadFailed: loadFailed ?? this.loadFailed,
    totalOwedPiasters: totalOwedPiasters ?? this.totalOwedPiasters,
  );

  @override
  List<Object?> get props => [
    query,
    items,
    loading,
    loadFailed,
    totalOwedPiasters,
  ];
}

/// The supplier list and the purchase's supplier picker (FR-015). Typing
/// waits [debounce] after the last keystroke before it queries.
class SuppliersListCubit extends Cubit<SuppliersListState> {
  SuppliersListCubit(
    this._repository, {
    this.debounce = const Duration(milliseconds: 200),
  }) : super(const SuppliersListState()) {
    _subscribe();
    // Everyone, whatever the search. A failed total is just not shown.
    _totalSub = _repository.watchTotalOwed().listen(
      (total) => emit(state.copyWith(totalOwedPiasters: total)),
      onError: addError,
    );
  }

  final SupplierRepository _repository;
  final Duration debounce;
  StreamSubscription<List<SupplierSummary>>? _sub;
  StreamSubscription<int>? _totalSub;
  Timer? _timer;

  void search(String text) {
    emit(state.copyWith(query: state.query.copyWith(text: text)));
    _timer?.cancel();
    _timer = Timer(debounce, _subscribe);
  }

  /// Drops the search text and the filter.
  void clearSearch() {
    emit(
      state.copyWith(query: state.query.copyWith(text: '', owedOnly: false)),
    );
    _subscribe();
  }

  void toggleOwed() {
    emit(
      state.copyWith(
        query: state.query.copyWith(owedOnly: !state.query.owedOnly),
      ),
    );
    _subscribe();
  }

  /// Adds a supplier named like the search text, for the picker (US2).
  /// Returns it, or null when the name is not valid.
  /// The supplier with [id], e.g. one just added from the full form.
  Future<SupplierSummary?> byId(String id) => _repository.watchOne(id).first;

  Future<SupplierSummary?> quickAdd() async {
    final draft = SupplierDraft.create(name: state.query.text);
    if (draft case Ok(:final value)) {
      final saved = await _repository.create(value);
      if (saved case Ok(value: SupplierSaved(:final id))) {
        return SupplierSummary(
          supplier: Supplier(id: id, name: value.name),
          balancePiasters: 0,
        );
      }
    }
    return null;
  }

  void _subscribe() {
    _timer?.cancel();
    unawaited(_sub?.cancel());
    emit(state.copyWith(loading: true, loadFailed: false));
    _sub = _repository
        .watchActive(state.query)
        .listen(
          (items) => emit(state.copyWith(items: items, loading: false)),
          onError: _failed,
        );
  }

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  void _failed(Object error, StackTrace stack) {
    emit(state.copyWith(loading: false, loadFailed: true));
    addError(error, stack);
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _sub?.cancel();
    await _totalSub?.cancel();
    return super.close();
  }
}

final class ArchivedSuppliersState extends Equatable {
  const ArchivedSuppliersState({
    this.items = const [],
    this.loaded = false,
    this.loadFailed = false,
  });

  final List<SupplierSummary> items;
  final bool loaded;

  /// The stream failed; the cubit's `retry` tries again (research R7).
  final bool loadFailed;

  @override
  List<Object?> get props => [items, loaded, loadFailed];
}

/// Archived suppliers, each with Restore (FR-013).
class ArchivedSuppliersCubit extends Cubit<ArchivedSuppliersState> {
  ArchivedSuppliersCubit(this._repository)
    : super(const ArchivedSuppliersState()) {
    _subscribe();
  }

  final SupplierRepository _repository;
  StreamSubscription<List<SupplierSummary>>? _sub;

  Future<void> restore(String id) => _repository.restore(id);

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  void _subscribe() {
    unawaited(_sub?.cancel());
    if (state.loadFailed) emit(ArchivedSuppliersState(items: state.items));
    _sub = _repository.watchArchived().listen(
      (items) => emit(ArchivedSuppliersState(items: items, loaded: true)),
      onError: (Object error, StackTrace stack) {
        emit(
          ArchivedSuppliersState(
            items: state.items,
            loaded: true,
            loadFailed: true,
          ),
        );
        addError(error, stack);
      },
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
