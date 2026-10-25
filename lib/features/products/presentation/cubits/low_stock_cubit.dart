import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/product.dart';
import '../../domain/product_repository.dart';

final class LowStockState extends Equatable {
  const LowStockState({this.snapshot, this.loadFailed = false});

  /// Null while loading.
  final LowStockSnapshot? snapshot;

  /// The stream failed; [LowStockCubit.retry] tries again (research R7).
  final bool loadFailed;

  @override
  List<Object?> get props => [snapshot, loadFailed];
}

/// The Home low-stock card (FR-001a).
class LowStockCubit extends Cubit<LowStockState> {
  LowStockCubit(this._repository, {this.limit = 5})
    : super(const LowStockState()) {
    _subscribe();
  }

  final ProductRepository _repository;
  final int limit;
  StreamSubscription<LowStockSnapshot>? _subscription;

  /// Subscribes again after a failed load.
  void retry() => _subscribe();

  void _subscribe() {
    unawaited(_subscription?.cancel());
    if (state.loadFailed) emit(LowStockState(snapshot: state.snapshot));
    _subscription = _repository
        .watchLowStock(limit: limit)
        .listen(
          (snapshot) => emit(LowStockState(snapshot: snapshot)),
          onError: (Object error, StackTrace stack) {
            emit(LowStockState(snapshot: state.snapshot, loadFailed: true));
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
