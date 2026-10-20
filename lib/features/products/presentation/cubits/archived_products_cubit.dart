import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/product.dart';
import '../../domain/product_errors.dart';
import '../../domain/product_repository.dart';

final class ArchivedProductsState extends Equatable {
  const ArchivedProductsState({this.items = const [], this.loaded = false});

  final List<ProductSummary> items;
  final bool loaded;

  @override
  List<Object?> get props => [items, loaded];
}

/// Archived products, each with Restore (FR-012).
class ArchivedProductsCubit extends Cubit<ArchivedProductsState> {
  ArchivedProductsCubit(this._repository)
    : super(const ArchivedProductsState()) {
    _subscription = _repository.watchArchived().listen(
      (items) => emit(ArchivedProductsState(items: items, loaded: true)),
      onError: addError,
    );
  }

  final ProductRepository _repository;
  late final StreamSubscription<List<ProductSummary>> _subscription;

  /// Returns the error to show, or null when the product is restored.
  Future<RestoreError?> restore(String id) async =>
      switch (await _repository.restore(id)) {
        Ok() => null,
        Err(:final error) => error,
      };

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
