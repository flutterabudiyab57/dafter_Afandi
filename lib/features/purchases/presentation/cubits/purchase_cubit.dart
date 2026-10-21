import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/clock.dart';
import '../../../../core/utils/result.dart';
import '../../../customers/domain/payment.dart';
import '../../../products/domain/product.dart';
import '../../../products/domain/product_repository.dart';
import '../../../products/domain/quantity_input.dart';
import '../../domain/purchase.dart';
import '../../domain/purchase_draft.dart';
import '../../domain/purchase_errors.dart';
import '../../domain/purchase_repository.dart';

enum PurchaseStatus {
  editing,
  saving,

  /// [PurchaseState.saved] holds the new purchase; the screen shows it, then
  /// calls [PurchaseCubit.startNew].
  saved,
  failed,
}

/// A number field on the purchase screen.
enum PurchaseField { qty, cost, discount, invoiceDiscount, paid }

/// What is wrong with what was typed in a field.
enum PurchaseInputProblem { required, invalid, notWhole, tooLarge }

final class PurchaseState extends Equatable {
  const PurchaseState({
    this.draft = const PurchaseDraft(),
    this.status = PurchaseStatus.editing,
    this.inputErrors = const {},
    this.errors = const [],
    this.saveError,
    this.saved,
  });

  final PurchaseDraft draft;
  final PurchaseStatus status;

  /// Typed text that could not be read, by [inputKey].
  final Map<String, PurchaseInputProblem> inputErrors;

  /// Rules the draft breaks, shown after Save.
  final List<PurchaseError> errors;

  /// A refusal from saving other than broken rules.
  final PurchaseSaveError? saveError;
  final PurchaseSaved? saved;

  /// The key of a field: per line for qty, cost and discount.
  static String inputKey(PurchaseField field, [String? productId]) =>
      productId == null ? field.name : '${field.name}:$productId';

  PurchaseInputProblem? inputError(PurchaseField field, [String? productId]) =>
      inputErrors[inputKey(field, productId)];

  PurchaseState copyWith({
    PurchaseDraft? draft,
    PurchaseStatus? status,
    Map<String, PurchaseInputProblem>? inputErrors,
    List<PurchaseError>? errors,
    PurchaseSaveError? Function()? saveError,
    PurchaseSaved? Function()? saved,
  }) => PurchaseState(
    draft: draft ?? this.draft,
    status: status ?? this.status,
    inputErrors: inputErrors ?? this.inputErrors,
    errors: errors ?? this.errors,
    saveError: saveError == null ? this.saveError : saveError(),
    saved: saved == null ? this.saved : saved(),
  );

  @override
  List<Object?> get props => [
    draft,
    status,
    inputErrors,
    errors,
    saveError,
    saved,
  ];
}

/// The new-purchase screen (US1, US2). Number fields report their text; the
/// cubit reads it and keeps the draft in integers.
class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit(this._purchases, this._products, this._clock)
    : super(const PurchaseState());

  final PurchaseRepository _purchases;
  final ProductRepository _products;
  final Clock _clock;

  /// The local date, for the "no future date" rule.
  DateTime get today {
    final local = _clock.nowUtc().toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Adds a product, its cost prefilled from its last purchase, else its
  /// average cost (research R14). A product already on the purchase gets
  /// one more unit.
  Future<void> addProduct(ProductSummary s) async {
    final p = s.product;
    final cost = state.draft.lineOf(p.id) != null
        ? 0
        : await _purchases.lastUnitCost(p.id) ?? p.avgCostPiasters;
    if (isClosed) return;
    _update(
      state.draft.add(
        productId: p.id,
        name: p.name,
        unit: p.unit,
        salePricePiasters: p.salePricePiasters,
        unitCostPiasters: cost,
      ),
      // The quantity field shows the new value, so its old error goes.
      clear: [PurchaseState.inputKey(PurchaseField.qty, p.id)],
    );
  }

  /// Adds the active product with this exact barcode; false when none.
  Future<bool> addByBarcode(String code) async {
    final s = await _products.activeByBarcode(code);
    if (s == null || isClosed) return false;
    await addProduct(s);
    return true;
  }

  void remove(String productId) => _update(
    state.draft.remove(productId),
    clear: [
      for (final f in [
        PurchaseField.qty,
        PurchaseField.cost,
        PurchaseField.discount,
      ])
        PurchaseState.inputKey(f, productId),
    ],
  );

  void qtyChanged(String productId, String text) {
    final line = state.draft.lineOf(productId);
    if (line == null) return;
    _read(
      PurchaseState.inputKey(PurchaseField.qty, productId),
      readQuantity(text, line.unit),
      (v) => v == 0 ? null : state.draft.updateLine(productId, qtyMilli: v),
    );
  }

  void costChanged(String productId, String text) => _read(
    PurchaseState.inputKey(PurchaseField.cost, productId),
    readMoney(text),
    (v) => state.draft.updateLine(productId, unitCostPiasters: v),
  );

  void lineDiscountChanged(String productId, String text) => _read(
    PurchaseState.inputKey(PurchaseField.discount, productId),
    readMoney(text),
    (v) => state.draft.updateLine(productId, lineDiscountPiasters: v),
    emptyAs: 0,
  );

  void invoiceDiscountChanged(String text) => _read(
    PurchaseState.inputKey(PurchaseField.invoiceDiscount),
    readMoney(text),
    state.draft.withInvoiceDiscount,
    emptyAs: 0,
  );

  /// Empty pays the whole total.
  void paidChanged(String text) {
    final key = PurchaseState.inputKey(PurchaseField.paid);
    if (text.trim().isEmpty) {
      _update(state.draft.withPaid(null), clear: [key]);
      return;
    }
    _read(key, readMoney(text), state.draft.withPaid);
  }

  void methodChanged(PaymentMethod method) =>
      _update(state.draft.withMethod(method));

  void supplierChanged(PurchaseSupplier? supplier) =>
      _update(state.draft.withSupplier(supplier));

  void supplierRefChanged(String text) =>
      _update(state.draft.withSupplierRef(text));

  /// Null goes back to today.
  void invoiceDateChanged(DateTime? date) =>
      _update(state.draft.withInvoiceDate(date));

  void noteChanged(String text) => _update(state.draft.withNote(text));

  /// Applies a typed number: a value updates the draft through [apply]
  /// (null from [apply] means "required"); empty uses [emptyAs] when given;
  /// a problem is kept for the field.
  void _read(
    String key,
    NumberInput input,
    PurchaseDraft? Function(int value) apply, {
    int? emptyAs,
  }) {
    int? value;
    PurchaseInputProblem? problem;
    switch (input) {
      case NumberEmpty():
        if (emptyAs == null) {
          problem = PurchaseInputProblem.required;
        } else {
          value = emptyAs;
        }
      case NumberValue(value: final v):
        value = v;
      case NumberProblem(:final kind):
        problem = switch (kind) {
          NumberProblemKind.invalid => PurchaseInputProblem.invalid,
          NumberProblemKind.notWhole => PurchaseInputProblem.notWhole,
          NumberProblemKind.tooLarge => PurchaseInputProblem.tooLarge,
        };
    }
    final next = value == null ? null : apply(value);
    if (next == null) {
      emit(
        state.copyWith(
          inputErrors: {
            ...state.inputErrors,
            key: problem ?? PurchaseInputProblem.required,
          },
          status: _editingStatus,
        ),
      );
      return;
    }
    _update(next, clear: [key]);
  }

  PurchaseStatus? get _editingStatus =>
      state.status == PurchaseStatus.failed ? PurchaseStatus.editing : null;

  void _update(PurchaseDraft edited, {List<String> clear = const []}) {
    var draft = edited;
    // A typed "paid now" belongs to the total it was typed for. When the
    // total changes it goes back to "pay all", so an edit never turns a
    // cash purchase into credit without the owner typing a new amount.
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

  /// Validates and saves.
  Future<void> submit() async {
    final s = state.status;
    if (s != PurchaseStatus.editing && s != PurchaseStatus.failed) return;
    if (state.inputErrors.isNotEmpty) return;
    final errors = state.draft.validate(today: today);
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors));
      return;
    }
    emit(state.copyWith(status: PurchaseStatus.saving));
    try {
      final result = await _purchases.create(state.draft);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(status: PurchaseStatus.saved, saved: () => value),
          );
        case Err(error: PurchaseInvalid(errors: final list)):
          emit(state.copyWith(status: PurchaseStatus.editing, errors: list));
        case Err(:final error):
          emit(
            state.copyWith(
              status: PurchaseStatus.editing,
              saveError: () => error,
            ),
          );
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) emit(state.copyWith(status: PurchaseStatus.failed));
    }
  }

  /// An empty purchase, after the saved one was shown.
  void startNew() => emit(const PurchaseState());

  /// Whether leaving would lose lines (research R17).
  bool get hasUnsavedLines =>
      !state.draft.isEmpty && state.status != PurchaseStatus.saved;
}
