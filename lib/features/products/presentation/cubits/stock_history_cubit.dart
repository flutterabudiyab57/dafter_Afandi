import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/inventory_repository.dart';
import '../../domain/stock_entry.dart';

final class StockHistoryState extends Equatable {
  const StockHistoryState({
    this.entries = const [],
    this.hasMore = false,
    this.loading = true,
  });

  /// Newest first.
  final List<StockEntry> entries;
  final bool hasMore;
  final bool loading;

  @override
  List<Object?> get props => [entries, hasMore, loading];
}

/// A product's stock history in pages of [pageSize] (FR-016, research R15).
class StockHistoryCubit extends Cubit<StockHistoryState> {
  StockHistoryCubit(this._inventory, this.productId, {this.pageSize = 50})
    : super(const StockHistoryState());

  final InventoryRepository _inventory;
  final String productId;
  final int pageSize;

  /// Loads the first page again, e.g. after the stock changed.
  Future<void> load() async {
    emit(StockHistoryState(entries: state.entries, hasMore: state.hasMore));
    final page = await _inventory.history(productId, limit: pageSize);
    if (isClosed) return;
    emit(
      StockHistoryState(
        entries: page,
        hasMore: page.length == pageSize,
        loading: false,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore || state.entries.isEmpty) return;
    emit(StockHistoryState(entries: state.entries, hasMore: true));
    final page = await _inventory.history(
      productId,
      before: state.entries.last.cursor,
      limit: pageSize,
    );
    if (isClosed) return;
    emit(
      StockHistoryState(
        entries: [...state.entries, ...page],
        hasMore: page.length == pageSize,
        loading: false,
      ),
    );
  }
}
