import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/product.dart';
import '../../domain/product_query.dart';
import '../../domain/product_repository.dart';
import '../../domain/stock_summary.dart';

final class StockSummaryState extends Equatable {
  const StockSummaryState({this.summary, this.loadFailed = false});

  /// Null while loading.
  final StockSummary? summary;

  /// The stream failed; [StockSummaryCubit.retry] tries again.
  final bool loadFailed;

  @override
  List<Object?> get props => [summary, loadFailed];
}

/// The stock's value and quantities by category, over all active products.
class StockSummaryCubit extends Cubit<StockSummaryState> {
  StockSummaryCubit(this._repository) : super(const StockSummaryState()) {
    _subscribe();
  }

  final ProductRepository _repository;
  StreamSubscription<List<ProductSummary>>? _subscription;

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  void _subscribe() {
    unawaited(_subscription?.cancel());
    if (state.loadFailed) emit(StockSummaryState(summary: state.summary));
    _subscription = _repository
        .watchSummaries(const ProductQuery())
        .listen(
          (items) => emit(StockSummaryState(summary: StockSummary.of(items))),
          onError: (Object error, StackTrace stack) {
            emit(StockSummaryState(summary: state.summary, loadFailed: true));
            addError(error, stack);
          },
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
