import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/demo_seed.dart';
import '../../domain/product.dart';
import '../../domain/product_errors.dart';
import '../../domain/product_repository.dart';

final class ArchivedProductsState extends Equatable {
  const ArchivedProductsState({
    this.items = const [],
    this.loaded = false,
    this.loadFailed = false,
  });

  final List<ProductSummary> items;
  final bool loaded;

  /// The stream failed; the cubit's `retry` tries again (research R7).
  final bool loadFailed;

  @override
  List<Object?> get props => [items, loaded, loadFailed];
}

/// Archived products, each with Restore (FR-012).
class ArchivedProductsCubit extends Cubit<ArchivedProductsState> {
  ArchivedProductsCubit(this._repository)
    : super(const ArchivedProductsState()) {
    _subscribe();
  }

  final ProductRepository _repository;
  StreamSubscription<List<ProductSummary>>? _subscription;

  /// Returns the error to show, or null when the product is restored.
  Future<RestoreError?> restore(String id) async =>
      switch (await _repository.restore(id)) {
        Ok() => null,
        Err(:final error) => error,
      };

  /// Debug builds only (decision B2): adds demo products, returns how many.
  Future<int> seedDemo({int count = 2000}) =>
      seedDemoProducts(_repository, count: count);

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  void _subscribe() {
    unawaited(_subscription?.cancel());
    if (state.loadFailed) emit(ArchivedProductsState(items: state.items));
    _subscription = _repository.watchArchived().listen(
      (items) => emit(ArchivedProductsState(items: items, loaded: true)),
      onError: (Object error, StackTrace stack) {
        emit(
          ArchivedProductsState(
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
    await _subscription?.cancel();
    return super.close();
  }
}
