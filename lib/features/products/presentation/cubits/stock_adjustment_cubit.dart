import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/result.dart';
import '../../domain/adjustment.dart';
import '../../domain/inventory_repository.dart';
import '../../domain/product.dart';
import '../../domain/product_errors.dart';
import '../../domain/product_repository.dart';
import '../../domain/stock_entry.dart';

enum StockAdjustmentStatus {
  loading,
  editing,
  saving,
  saved,

  /// A count equal to the stock: nothing was recorded (info, not an error).
  alreadyMatches,
  notFound,
  failed,
}

final class StockAdjustmentState extends Equatable {
  const StockAdjustmentState({
    this.status = StockAdjustmentStatus.loading,
    this.kind = AdjustmentKind.count,
    this.add = false,
    this.qty = '',
    this.note = '',
    this.unit = UnitType.piece,
    this.onHandMilli = 0,
    this.errors = const [],
    this.newStockMilli,
  });

  final StockAdjustmentStatus status;
  final AdjustmentKind kind;

  /// For [AdjustmentKind.other]: adds when true, removes when false.
  final bool add;

  /// The quantity to remove or add, or the counted quantity for a count.
  final String qty;
  final String note;
  final UnitType unit;
  final int onHandMilli;
  final List<AdjustmentError> errors;

  /// Set when [status] is `saved`.
  final int? newStockMilli;

  /// The quantity field's error, if any.
  AdjustmentError? get qtyError => errors
      .where(
        (e) =>
            e is AdjustmentQuantityRequired ||
            e is AdjustmentQuantityInvalid ||
            e is AdjustmentQuantityNotWhole ||
            e is AdjustmentQuantityTooLarge ||
            e is ExceedsStock,
      )
      .firstOrNull;

  /// The note field's error, if any.
  AdjustmentError? get noteError => errors
      .where((e) => e is AdjustmentNoteRequired || e is AdjustmentNoteTooLong)
      .firstOrNull;

  StockAdjustmentState copyWith({
    StockAdjustmentStatus? status,
    AdjustmentKind? kind,
    bool? add,
    String? qty,
    String? note,
    UnitType? unit,
    int? onHandMilli,
    List<AdjustmentError>? errors,
    int? Function()? newStockMilli,
  }) => StockAdjustmentState(
    status: status ?? this.status,
    kind: kind ?? this.kind,
    add: add ?? this.add,
    qty: qty ?? this.qty,
    note: note ?? this.note,
    unit: unit ?? this.unit,
    onHandMilli: onHandMilli ?? this.onHandMilli,
    errors: errors ?? this.errors,
    newStockMilli: newStockMilli == null ? this.newStockMilli : newStockMilli(),
  );

  @override
  List<Object?> get props => [
    status,
    kind,
    add,
    qty,
    note,
    unit,
    onHandMilli,
    errors,
    newStockMilli,
  ];
}

/// Records one stock adjustment (FR-013–FR-015, US4). The stock on hand is
/// watched so the screen always shows the current value.
class StockAdjustmentCubit extends Cubit<StockAdjustmentState> {
  StockAdjustmentCubit(this._products, this._inventory, this.productId)
    : super(const StockAdjustmentState()) {
    _subscription = _products
        .watchSummary(productId)
        .listen(_onSummary, onError: addError);
  }

  /// The field values when the form became editable (research R9).
  Object? _baseline;

  /// True when a field differs from when the form became editable, until
  /// it is saved (research R9).
  bool get hasUnsavedChanges =>
      state.status != StockAdjustmentStatus.saved &&
      _baseline != null &&
      _fields(state) != _baseline;

  static Object _fields(StockAdjustmentState s) =>
      (s.kind, s.add, s.qty, s.note);

  @override
  void onChange(Change<StockAdjustmentState> change) {
    super.onChange(change);
    // The fields never change while loading, so the state before the
    // first change is the form as it opened.
    _baseline ??= _fields(change.currentState);
  }

  final ProductRepository _products;
  final InventoryRepository _inventory;
  final String productId;
  late final StreamSubscription<ProductSummary?> _subscription;

  void _onSummary(ProductSummary? summary) {
    if (summary == null) {
      emit(state.copyWith(status: StockAdjustmentStatus.notFound));
      return;
    }
    emit(
      state.copyWith(
        status: state.status == StockAdjustmentStatus.loading
            ? StockAdjustmentStatus.editing
            : null,
        unit: summary.product.unit,
        onHandMilli: summary.stockMilli,
      ),
    );
  }

  void kindChanged(AdjustmentKind kind) => _edit(state.copyWith(kind: kind));
  void directionChanged({required bool add}) => _edit(state.copyWith(add: add));
  void qtyChanged(String v) => _edit(state.copyWith(qty: v));
  void noteChanged(String v) => _edit(state.copyWith(note: v));

  void _edit(StockAdjustmentState next) {
    final s = state.status;
    emit(
      next.copyWith(
        errors: const [],
        status:
            s == StockAdjustmentStatus.alreadyMatches ||
                s == StockAdjustmentStatus.failed
            ? StockAdjustmentStatus.editing
            : null,
      ),
    );
  }

  Future<void> submit() async {
    final s = state.status;
    if (s != StockAdjustmentStatus.editing &&
        s != StockAdjustmentStatus.alreadyMatches &&
        s != StockAdjustmentStatus.failed) {
      return;
    }
    final built = switch (state.kind) {
      AdjustmentKind.damage => AdjustmentRequest.damage(
        qtyText: state.qty,
        unit: state.unit,
        note: state.note,
      ),
      AdjustmentKind.count => AdjustmentRequest.count(
        countedText: state.qty,
        unit: state.unit,
        note: state.note,
      ),
      AdjustmentKind.other => AdjustmentRequest.other(
        qtyText: state.qty,
        unit: state.unit,
        add: state.add,
        note: state.note,
      ),
    };
    final AdjustmentRequest request;
    switch (built) {
      case Err(:final error):
        emit(
          state.copyWith(errors: error, status: StockAdjustmentStatus.editing),
        );
        return;
      case Ok(:final value):
        request = value;
    }

    emit(state.copyWith(status: StockAdjustmentStatus.saving));
    try {
      final result = await _inventory.adjust(productId, request);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(
              status: StockAdjustmentStatus.saved,
              newStockMilli: () => value.newStockMilli,
            ),
          );
        case Err(error: AlreadyMatches()):
          emit(state.copyWith(status: StockAdjustmentStatus.alreadyMatches));
        case Err(:final error):
          emit(
            state.copyWith(
              status: StockAdjustmentStatus.editing,
              errors: [error],
            ),
          );
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) {
        emit(state.copyWith(status: StockAdjustmentStatus.failed));
      }
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
