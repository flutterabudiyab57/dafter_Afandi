import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/product.dart';
import '../../domain/product_repository.dart';

/// The Home low-stock card (FR-001a). The state is null while loading.
class LowStockCubit extends Cubit<LowStockSnapshot?> {
  LowStockCubit(this._repository, {this.limit = 5}) : super(null) {
    _subscription = _repository
        .watchLowStock(limit: limit)
        .listen(emit, onError: addError);
  }

  final ProductRepository _repository;
  final int limit;
  late final StreamSubscription<LowStockSnapshot> _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
