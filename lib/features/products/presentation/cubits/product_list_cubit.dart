import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/category.dart';
import '../../domain/category_repository.dart';
import '../../domain/product.dart';
import '../../domain/product_query.dart';
import '../../domain/product_repository.dart';

final class ProductListState extends Equatable {
  const ProductListState({
    this.query = const ProductQuery(),
    this.items = const [],
    this.categories = const [],
    this.loading = true,
  });

  final ProductQuery query;
  final List<ProductSummary> items;

  /// Active categories, for the filter chips.
  final List<Category> categories;

  /// True until the first result for the current query arrives.
  final bool loading;

  ProductListState copyWith({
    ProductQuery? query,
    List<ProductSummary>? items,
    List<Category>? categories,
    bool? loading,
  }) => ProductListState(
    query: query ?? this.query,
    items: items ?? this.items,
    categories: categories ?? this.categories,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [query, items, categories, loading];
}

/// The product list with search and filters (FR-008–FR-010). Typing waits
/// [debounce] after the last keystroke before it queries (research R4).
class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit(
    this._products,
    this._categories, {
    ProductQuery initialQuery = const ProductQuery(),
    this.debounce = const Duration(milliseconds: 200),
  }) : super(ProductListState(query: initialQuery)) {
    _categoriesSub = _categories.watchActive().listen(
      (list) => emit(state.copyWith(categories: list)),
      onError: addError,
    );
    _subscribe();
  }

  final ProductRepository _products;
  final CategoryRepository _categories;
  final Duration debounce;

  StreamSubscription<List<ProductSummary>>? _itemsSub;
  late final StreamSubscription<List<Category>> _categoriesSub;
  Timer? _timer;

  /// Shows [text] at once and queries after [debounce].
  void search(String text) {
    emit(state.copyWith(query: state.query.copyWith(text: text)));
    _timer?.cancel();
    _timer = Timer(debounce, _subscribe);
  }

  void setCategory(CategoryFilter filter) {
    emit(state.copyWith(query: state.query.copyWith(categoryFilter: filter)));
    _subscribe();
  }

  void toggleLow() {
    emit(
      state.copyWith(
        query: state.query.copyWith(lowOnly: !state.query.lowOnly),
      ),
    );
    _subscribe();
  }

  void _subscribe() {
    _timer?.cancel();
    final query = state.query;
    unawaited(_itemsSub?.cancel());
    emit(state.copyWith(loading: true));
    _itemsSub = _products
        .watchSummaries(query)
        .listen(
          (items) => emit(state.copyWith(items: items, loading: false)),
          onError: addError,
        );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _itemsSub?.cancel();
    await _categoriesSub.cancel();
    return super.close();
  }
}
