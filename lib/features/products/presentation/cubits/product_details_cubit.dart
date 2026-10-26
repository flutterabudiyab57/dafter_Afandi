import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/product.dart';
import '../../domain/product_errors.dart';
import '../../domain/product_repository.dart';

final class ProductDetailsState extends Equatable {
  const ProductDetailsState({
    this.loaded = false,
    this.summary,
    this.restoreError,
    this.loadFailed = false,
  });

  /// False until the first read; then [summary] is null only when the
  /// product does not exist.
  final bool loaded;
  final ProductSummary? summary;

  /// One-shot: shown once, then cleared with `clearMessage`.
  final RestoreError? restoreError;

  /// The stream failed; `retry` tries again (research R7).
  final bool loadFailed;

  @override
  List<Object?> get props => [loaded, summary, restoreError, loadFailed];
}

/// One product, kept current by a watch query (FR-012, US3).
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository, this.productId)
    : super(const ProductDetailsState()) {
    _subscribe();
  }

  final ProductRepository _repository;
  final String productId;
  StreamSubscription<ProductSummary?>? _subscription;

  void _subscribe() {
    unawaited(_subscription?.cancel());
    _subscription = _repository
        .watchSummary(productId)
        .listen(
          (summary) => emit(
            ProductDetailsState(
              loaded: true,
              summary: summary,
              restoreError: state.restoreError,
            ),
          ),
          onError: _failed,
        );
  }

  /// Subscribes again after a failed load.
  void retry() {
    emit(const ProductDetailsState());
    _subscribe();
  }

  void _failed(Object error, StackTrace stack) {
    emit(const ProductDetailsState(loadFailed: true));
    addError(error, stack);
  }

  Future<void> archive() => _repository.archive(productId);

  /// Null when restored. While open, a refusal also becomes
  /// [ProductDetailsState.restoreError].
  Future<RestoreError?> restore() async {
    final result = await _repository.restore(productId);
    if (result case Err(:final error)) {
      if (!isClosed) {
        emit(
          ProductDetailsState(
            loaded: state.loaded,
            summary: state.summary,
            restoreError: error,
          ),
        );
      }
      return error;
    }
    return null;
  }

  void clearMessage() =>
      emit(ProductDetailsState(loaded: state.loaded, summary: state.summary));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
