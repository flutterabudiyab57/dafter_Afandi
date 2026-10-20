import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/result.dart';
import '../../../customers/domain/payment.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_repository.dart';
import '../../../products/domain/quantity_input.dart';
import '../../domain/sale.dart';
import '../../domain/sale_draft.dart';
import '../../domain/sale_errors.dart';
import '../../domain/sales_repository.dart';

enum SaleStatus {
  editing,

  /// Stock is short; waiting for the owner to confirm (FR-006).
  confirmShortage,
  saving,

  /// [SaleState.saved] holds the new invoice; the screen shows it, then
  /// calls [SaleCubit.startNew].
  saved,
  failed,
}

/// A number field on the sale screen.
enum SaleField { qty, price, discount, invoiceDiscount, paid }

/// What is wrong with what was typed in a field.
enum SaleInputProblem { required, invalid, notWhole, tooLarge }

final class SaleState extends Equatable {
  const SaleState({
    this.draft = const SaleDraft(),
    this.status = SaleStatus.editing,
    this.inputErrors = const {},
    this.errors = const [],
    this.saveError,
    this.shortages = const [],
    this.saved,
  });

  final SaleDraft draft;
  final SaleStatus status;

  /// Typed text that could not be read, by [inputKey].
  final Map<String, SaleInputProblem> inputErrors;

  /// Rules the draft breaks, shown after Save.
  final List<SaleError> errors;

  /// A refusal from saving other than a shortage.
  final SaleSaveError? saveError;
  final List<Shortage> shortages;
  final SaleSaved? saved;

  /// The key of a field: per line for qty, price and discount.
  static String inputKey(SaleField field, [String? productId]) =>
      productId == null ? field.name : '${field.name}:$productId';

  SaleInputProblem? inputError(SaleField field, [String? productId]) =>
      inputErrors[inputKey(field, productId)];

  SaleState copyWith({
    SaleDraft? draft,
    SaleStatus? status,
    Map<String, SaleInputProblem>? inputErrors,
    List<SaleError>? errors,
    SaleSaveError? Function()? saveError,
    List<Shortage>? shortages,
    SaleSaved? Function()? saved,
  }) => SaleState(
    draft: draft ?? this.draft,
    status: status ?? this.status,
    inputErrors: inputErrors ?? this.inputErrors,
    errors: errors ?? this.errors,
    saveError: saveError == null ? this.saveError : saveError(),
    shortages: shortages ?? this.shortages,
    saved: saved == null ? this.saved : saved(),
  );

  @override
  List<Object?> get props => [
    draft,
    status,
    inputErrors,
    errors,
    saveError,
    shortages,
    saved,
  ];
}

/// The new-sale screen (US1, US2). Number fields report their text; the
/// cubit reads it and keeps the draft in integers.
class SaleCubit extends Cubit<SaleState> {
  SaleCubit(this._sales, this._products) : super(const SaleState());

  final SalesRepository _sales;
  final ProductRepository _products;

  void addProduct(ProductSummary s) => _update(
    state.draft.add(
      productId: s.product.id,
      name: s.product.name,
      unit: s.product.unit,
      unitPricePiasters: s.product.salePricePiasters,
    ),
    // The quantity field shows the new value, so its old error goes.
    clear: [SaleState.inputKey(SaleField.qty, s.product.id)],
  );

  /// Adds the active product with this exact barcode; false when none.
  Future<bool> addByBarcode(String code) async {
    final s = await _products.activeByBarcode(code);
    if (s == null || isClosed) return false;
    addProduct(s);
    return true;
  }

  void remove(String productId) => _update(
    state.draft.remove(productId),
    clear: [
      for (final f in [SaleField.qty, SaleField.price, SaleField.discount])
        SaleState.inputKey(f, productId),
    ],
  );

  void qtyChanged(String productId, String text) {
    final line = state.draft.lineOf(productId);
    if (line == null) return;
    _read(
      SaleState.inputKey(SaleField.qty, productId),
      readQuantity(text, line.unit),
      (v) => v == 0 ? null : state.draft.updateLine(productId, qtyMilli: v),
    );
  }

  void priceChanged(String productId, String text) => _read(
    SaleState.inputKey(SaleField.price, productId),
    readMoney(text),
    (v) => state.draft.updateLine(productId, unitPricePiasters: v),
  );

  void lineDiscountChanged(String productId, String text) => _read(
    SaleState.inputKey(SaleField.discount, productId),
    readMoney(text),
    (v) => state.draft.updateLine(productId, lineDiscountPiasters: v),
    emptyAs: 0,
  );

  void invoiceDiscountChanged(String text) => _read(
    SaleState.inputKey(SaleField.invoiceDiscount),
    readMoney(text),
    state.draft.withInvoiceDiscount,
    emptyAs: 0,
  );

  /// Empty pays the whole total.
  void paidChanged(String text) {
    final key = SaleState.inputKey(SaleField.paid);
    if (text.trim().isEmpty) {
      _update(state.draft.withPaid(null), clear: [key]);
      return;
    }
    _read(key, readMoney(text), state.draft.withPaid);
  }

  void methodChanged(PaymentMethod method) =>
      _update(state.draft.withMethod(method));

  void customerChanged(SaleCustomer? customer) =>
      _update(state.draft.withCustomer(customer));

  /// Applies a typed number: a value updates the draft through [apply]
  /// (null from [apply] means "required"); empty uses [emptyAs] when given;
  /// a problem is kept for the field.
  void _read(
    String key,
    NumberInput input,
    SaleDraft? Function(int value) apply, {
    int? emptyAs,
  }) {
    int? value;
    SaleInputProblem? problem;
    switch (input) {
      case NumberEmpty():
        if (emptyAs == null) {
          problem = SaleInputProblem.required;
        } else {
          value = emptyAs;
        }
      case NumberValue(value: final v):
        value = v;
      case NumberProblem(:final kind):
        problem = switch (kind) {
          NumberProblemKind.invalid => SaleInputProblem.invalid,
          NumberProblemKind.notWhole => SaleInputProblem.notWhole,
          NumberProblemKind.tooLarge => SaleInputProblem.tooLarge,
        };
    }
    final next = value == null ? null : apply(value);
    if (next == null) {
      emit(
        state.copyWith(
          inputErrors: {
            ...state.inputErrors,
            key: problem ?? SaleInputProblem.required,
          },
          status: _editingStatus,
        ),
      );
      return;
    }
    _update(next, clear: [key]);
  }

  SaleStatus? get _editingStatus =>
      state.status == SaleStatus.failed ? SaleStatus.editing : null;

  void _update(SaleDraft edited, {List<String> clear = const []}) {
    var draft = edited;
    // A typed "paid now" belongs to the total it was typed for. When the
    // total changes it goes back to "pay all", so an edit never turns a
    // cash sale into credit without the owner typing a new amount.
    if (state.draft.paidPiasters != null &&
        draft.paidPiasters != null &&
        draft.total != state.draft.total) {
      draft = draft.withPaid(null);
    }
    final inputErrors = {...state.inputErrors}
      ..removeWhere((k, _) => clear.contains(k));
    emit(
      state.copyWith(
        draft: draft,
        inputErrors: inputErrors,
        errors: const [],
        saveError: () => null,
        status: _editingStatus,
      ),
    );
  }

  /// Validates and saves; a shortage asks first.
  Future<void> submit() async {
    final s = state.status;
    if (s != SaleStatus.editing && s != SaleStatus.failed) return;
    if (state.inputErrors.isNotEmpty) return;
    final errors = state.draft.validate();
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }
    await _save(acknowledgeShortage: false);
  }

  Future<void> confirmShortage() async {
    if (state.status != SaleStatus.confirmShortage) return;
    await _save(acknowledgeShortage: true);
  }

  void cancelShortage() {
    if (state.status != SaleStatus.confirmShortage) return;
    emit(state.copyWith(status: SaleStatus.editing, shortages: const []));
  }

  Future<void> _save({required bool acknowledgeShortage}) async {
    emit(state.copyWith(status: SaleStatus.saving));
    try {
      final result = await _sales.create(
        state.draft,
        acknowledgeShortage: acknowledgeShortage,
      );
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(
              status: SaleStatus.saved,
              saved: () => value,
              shortages: const [],
            ),
          );
        case Err(error: StockShortage(:final items)):
          emit(
            state.copyWith(
              status: SaleStatus.confirmShortage,
              shortages: items,
            ),
          );
        case Err(error: SaleInvalid(errors: final list)):
          emit(state.copyWith(status: SaleStatus.editing, errors: list));
        case Err(:final error):
          emit(
            state.copyWith(
              status: SaleStatus.editing,
              saveError: () => error,
              shortages: const [],
            ),
          );
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) emit(state.copyWith(status: SaleStatus.failed));
    }
  }

  /// An empty sale, after the saved one was shown.
  void startNew() => emit(const SaleState());

  /// Whether leaving would lose lines (research R18).
  bool get hasUnsavedLines =>
      !state.draft.isEmpty && state.status != SaleStatus.saved;

  /// For tests and the leave dialog.
  UnitType? unitOf(String productId) => state.draft.lineOf(productId)?.unit;
}
