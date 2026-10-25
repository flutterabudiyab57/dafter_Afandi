import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/purchase.dart';
import '../../domain/purchase_errors.dart';
import '../../domain/purchase_repository.dart';

final class PurchasesListState extends Equatable {
  const PurchasesListState({
    this.query = const PurchaseQuery(),
    this.items = const [],
    this.limit = PurchasesListCubit.pageSize,
    this.loading = true,
    this.loadFailed = false,
  });

  final PurchaseQuery query;
  final List<PurchaseSummary> items;
  final int limit;
  final bool loading;

  /// The stream failed; [retry] tries again (research R7).
  final bool loadFailed;

  /// A full page came back, so there may be more.
  bool get hasMore => items.length >= limit;

  PurchasesListState copyWith({
    PurchaseQuery? query,
    List<PurchaseSummary>? items,
    int? limit,
    bool? loading,
    bool? loadFailed,
  }) => PurchasesListState(
    query: query ?? this.query,
    items: items ?? this.items,
    limit: limit ?? this.limit,
    loading: loading ?? this.loading,
    loadFailed: loadFailed ?? this.loadFailed,
  );

  @override
  List<Object?> get props => [query, items, limit, loading, loadFailed];
}

/// The purchase list (FR-010, research R16): search, unpaid filter, and
/// Show more.
class PurchasesListCubit extends Cubit<PurchasesListState> {
  PurchasesListCubit(
    this._repository, {
    String? supplierId,
    this.debounce = const Duration(milliseconds: 200),
  }) : super(PurchasesListState(query: PurchaseQuery(supplierId: supplierId))) {
    _subscribe();
  }

  static const int pageSize = 50;

  final PurchaseRepository _repository;
  final Duration debounce;
  StreamSubscription<List<PurchaseSummary>>? _sub;
  Timer? _timer;

  void search(String text) {
    emit(
      state.copyWith(
        query: state.query.copyWith(text: text),
        limit: pageSize,
      ),
    );
    _timer?.cancel();
    _timer = Timer(debounce, _subscribe);
  }

  /// Drops the search text and the filter.
  void clearSearch() {
    emit(
      state.copyWith(
        query: state.query.copyWith(text: '', unpaidOnly: false),
        limit: pageSize,
      ),
    );
    _subscribe();
  }

  void toggleUnpaid() {
    emit(
      state.copyWith(
        query: state.query.copyWith(unpaidOnly: !state.query.unpaidOnly),
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

  void _subscribe() {
    _timer?.cancel();
    unawaited(_sub?.cancel());
    emit(state.copyWith(loading: true, loadFailed: false));
    _sub = _repository
        .watchList(state.query, limit: state.limit)
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
    return super.close();
  }
}

final class PurchaseViewState extends Equatable {
  const PurchaseViewState({this.purchase, this.loaded = false});

  /// Null when the purchase does not exist.
  final Purchase? purchase;
  final bool loaded;

  @override
  List<Object?> get props => [purchase, loaded];
}

/// One purchase (FR-011) and voiding it (FR-009a).
class PurchaseViewCubit extends Cubit<PurchaseViewState> {
  PurchaseViewCubit(this._repository, this.purchaseId)
    : super(const PurchaseViewState()) {
    _sub = _repository
        .watchOne(purchaseId)
        .listen(
          (p) => emit(PurchaseViewState(purchase: p, loaded: true)),
          onError: addError,
        );
  }

  final PurchaseRepository _repository;
  final String purchaseId;
  late final StreamSubscription<Purchase?> _sub;

  /// [reason] is already validated. Returns the refusal, if any; a
  /// [VoidStockShortage] is asked about, then sent again with
  /// [acknowledgeShortage].
  Future<PurchaseVoidError?> voidPurchase(
    String reason, {
    bool acknowledgeShortage = false,
  }) async => switch (await _repository.voidPurchase(
    purchaseId,
    reason,
    acknowledgeShortage: acknowledgeShortage,
  )) {
    Ok() => null,
    Err(:final error) => error,
  };

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
