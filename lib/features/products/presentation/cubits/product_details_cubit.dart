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
  });

  /// False until the first read; then [summary] is null only when the
  /// product does not exist.
  final bool loaded;
  final ProductSummary? summary;

  /// One-shot: shown once, then cleared with `clearMessage`.
  final RestoreError? restoreError;

  @override
  List<Object?> get props => [loaded, summary, restoreError];
}

/// One product, kept current by a watch query (FR-012, US3).
class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  ProductDetailsCubit(this._repository, this.productId)
    : super(const ProductDetailsState()) {
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
          onError: addError,
        );
  }

  final ProductRepository _repository;
  final String productId;
  late final StreamSubscription<ProductSummary?> _subscription;

  Future<void> archive() => _repository.archive(productId);

  /// True when restored; a conflict becomes [ProductDetailsState.restoreError].
  Future<bool> restore() async {
    final result = await _repository.restore(productId);
    if (result case Err(:final error)) {
      if (isClosed) return false;
      emit(
        ProductDetailsState(
          loaded: state.loaded,
          summary: state.summary,
          restoreError: error,
        ),
      );
      return false;
    }
    return true;
  }

  void clearMessage() =>
      emit(ProductDetailsState(loaded: state.loaded, summary: state.summary));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
