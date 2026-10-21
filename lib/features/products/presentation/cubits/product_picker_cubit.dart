import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/product.dart';
import '../../domain/product_query.dart';
import '../../domain/product_repository.dart';

final class ProductPickerState extends Equatable {
  const ProductPickerState({
    this.text = '',
    this.items = const [],
    this.loading = true,
  });

  final String text;
  final List<ProductSummary> items;
  final bool loading;

  @override
  List<Object?> get props => [text, items, loading];
}

/// Picks a product by search, for a sale or a purchase (003 FR-003, 004
/// research R13).
class ProductPickerCubit extends Cubit<ProductPickerState> {
  ProductPickerCubit(
    this._products, {
    this.debounce = const Duration(milliseconds: 200),
  }) : super(const ProductPickerState()) {
    _subscribe();
  }

  final ProductRepository _products;
  final Duration debounce;
  StreamSubscription<List<ProductSummary>>? _sub;
  Timer? _timer;

  void search(String text) {
    emit(ProductPickerState(text: text, items: state.items));
    _timer?.cancel();
    _timer = Timer(debounce, _subscribe);
  }

  /// The active product whose barcode is exactly [text], for Enter.
  Future<ProductSummary?> exact(String text) => _products.activeByBarcode(text);

  /// A product just added by quick add, to return it as picked.
  Future<ProductSummary?> byId(String id) => _products.watchSummary(id).first;

  void _subscribe() {
    _timer?.cancel();
    unawaited(_sub?.cancel());
    final text = state.text;
    _sub = _products
        .watchSummaries(ProductQuery(text: text))
        .listen(
          (items) => emit(
            ProductPickerState(text: text, items: items, loading: false),
          ),
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
