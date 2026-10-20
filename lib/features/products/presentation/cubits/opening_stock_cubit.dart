import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/result.dart';
import '../../domain/inventory_repository.dart';
import '../../domain/product_draft.dart';
import '../../domain/product_errors.dart';
import '../../domain/product_repository.dart';

enum OpeningStockStatus {
  loading,
  editing,
  confirm,
  saving,
  saved,

  /// The product already has history, or does not exist.
  notAllowed,
  failed,
}

final class OpeningStockState extends Equatable {
  const OpeningStockState({
    this.status = OpeningStockStatus.loading,
    this.unit = UnitType.piece,
    this.qty = '',
    this.cost = '',
    this.errors = const [],
    this.pending,
  });

  final OpeningStockStatus status;
  final UnitType unit;
  final String qty;
  final String cost;
  final List<ProductFieldError> errors;
  final OpeningStock? pending;

  ProductFieldError? errorFor(ProductField field) {
    for (final e in errors) {
      if (e.field == field) return e;
    }
    return null;
  }

  OpeningStockState copyWith({
    OpeningStockStatus? status,
    UnitType? unit,
    String? qty,
    String? cost,
    List<ProductFieldError>? errors,
    OpeningStock? Function()? pending,
  }) => OpeningStockState(
    status: status ?? this.status,
    unit: unit ?? this.unit,
    qty: qty ?? this.qty,
    cost: cost ?? this.cost,
    errors: errors ?? this.errors,
    pending: pending == null ? this.pending : pending(),
  );

  @override
  List<Object?> get props => [status, unit, qty, cost, errors, pending];
}

/// Sets the opening stock of a product that has no history yet (US4-7),
/// with the same confirmation as the add form (research R13).
class OpeningStockCubit extends Cubit<OpeningStockState> {
  OpeningStockCubit(this._products, this._inventory, this.productId)
    : super(const OpeningStockState()) {
    unawaited(_load());
  }

  final ProductRepository _products;
  final InventoryRepository _inventory;
  final String productId;

  Future<void> _load() async {
    final summary = await _products.watchSummary(productId).first;
    if (isClosed) return;
    if (summary == null || summary.hasHistory) {
      emit(state.copyWith(status: OpeningStockStatus.notAllowed));
      return;
    }
    emit(
      state.copyWith(
        status: OpeningStockStatus.editing,
        unit: summary.product.unit,
      ),
    );
  }

  void qtyChanged(String v) => _edit(state.copyWith(qty: v));
  void costChanged(String v) => _edit(state.copyWith(cost: v));

  void _edit(OpeningStockState next) => emit(
    next.copyWith(
      errors: const [],
      status: state.status == OpeningStockStatus.failed
          ? OpeningStockStatus.editing
          : null,
    ),
  );

  /// Validates and asks for confirmation. A quantity is required here.
  void submit() {
    if (state.status != OpeningStockStatus.editing &&
        state.status != OpeningStockStatus.failed) {
      return;
    }
    switch (OpeningStock.read(
      qtyText: state.qty,
      costText: state.cost,
      unit: state.unit,
    )) {
      case Err(:final error):
        emit(state.copyWith(errors: error));
      case Ok(value: null):
        emit(
          state.copyWith(
            errors: const [QuantityRequired(ProductField.openingQty)],
          ),
        );
      case Ok(value: final OpeningStock opening):
        emit(
          state.copyWith(
            status: OpeningStockStatus.confirm,
            pending: () => opening,
          ),
        );
    }
  }

  void cancelConfirm() {
    if (state.status != OpeningStockStatus.confirm) return;
    emit(
      state.copyWith(status: OpeningStockStatus.editing, pending: () => null),
    );
  }

  Future<void> confirm() async {
    final opening = state.pending;
    if (state.status != OpeningStockStatus.confirm || opening == null) return;
    emit(state.copyWith(status: OpeningStockStatus.saving));
    try {
      final result = await _inventory.setOpening(productId, opening);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: result is Ok
              ? OpeningStockStatus.saved
              : OpeningStockStatus.notAllowed,
          pending: () => null,
        ),
      );
    } on Object catch (e, s) {
      addError(e, s);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: OpeningStockStatus.failed,
            pending: () => null,
          ),
        );
      }
    }
  }
}
