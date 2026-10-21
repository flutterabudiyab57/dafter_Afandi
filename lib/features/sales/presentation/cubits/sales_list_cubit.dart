import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/sale.dart';
import '../../domain/sale_errors.dart';
import '../../domain/sales_repository.dart';

final class SalesListState extends Equatable {
  const SalesListState({
    this.query = const SaleQuery(),
    this.items = const [],
    this.limit = SalesListCubit.pageSize,
    this.loading = true,
  });

  final SaleQuery query;
  final List<SaleSummary> items;
  final int limit;
  final bool loading;

  /// A full page came back, so there may be more.
  bool get hasMore => items.length >= limit;

  SalesListState copyWith({
    SaleQuery? query,
    List<SaleSummary>? items,
    int? limit,
    bool? loading,
  }) => SalesListState(
    query: query ?? this.query,
    items: items ?? this.items,
    limit: limit ?? this.limit,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [query, items, limit, loading];
}

/// The invoice list (FR-009): search, unpaid filter, and Show more.
class SalesListCubit extends Cubit<SalesListState> {
  SalesListCubit(
    this._repository, {
    String? customerId,
    this.debounce = const Duration(milliseconds: 200),
  }) : super(SalesListState(query: SaleQuery(customerId: customerId))) {
    _subscribe();
  }

  static const int pageSize = 50;

  final SalesRepository _repository;
  final Duration debounce;
  StreamSubscription<List<SaleSummary>>? _sub;
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
    emit(state.copyWith(loading: true));
    _sub = _repository
        .watchList(state.query, limit: state.limit)
        .listen(
          (items) => emit(state.copyWith(items: items, loading: false)),
          onError: addError,
        );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}

final class InvoiceState extends Equatable {
  const InvoiceState({this.invoice, this.loaded = false});

  /// Null when the invoice does not exist.
  final SaleInvoice? invoice;
  final bool loaded;

  @override
  List<Object?> get props => [invoice, loaded];
}

/// One invoice (FR-010) and voiding it (FR-008a).
class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit(this._repository, this.invoiceId) : super(const InvoiceState()) {
    _sub = _repository
        .watchOne(invoiceId)
        .listen(
          (i) => emit(InvoiceState(invoice: i, loaded: true)),
          onError: addError,
        );
  }

  final SalesRepository _repository;
  final String invoiceId;
  late final StreamSubscription<SaleInvoice?> _sub;

  /// [reason] is already validated. Returns the refusal, if any.
  Future<VoidError?> voidSale(String reason) async =>
      switch (await _repository.voidSale(invoiceId, reason)) {
        Ok() => null,
        Err(:final error) => error,
      };

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
