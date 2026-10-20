import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/decimal_text.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/utils/result.dart';
import '../../domain/category.dart';
import '../../domain/category_repository.dart';
import '../../domain/product_draft.dart';
import '../../domain/product_errors.dart';
import '../../domain/product_repository.dart';

enum ProductFormMode { create, edit }

enum ProductFormStatus {
  /// Edit mode, until the product is read.
  loading,
  editing,

  /// Waiting for the owner to confirm the opening stock (research R13).
  confirmOpening,
  saving,
  saved,

  /// An unexpected write failure; the fields are kept.
  failed,

  /// Edit mode, and the product does not exist.
  notFound,
}

final class ProductFormState extends Equatable {
  const ProductFormState({
    this.status = ProductFormStatus.editing,
    this.name = '',
    this.unit = UnitType.piece,
    this.price = '',
    this.categoryId,
    this.barcode = '',
    this.sku = '',
    this.lowStock = '',
    this.openingQty = '',
    this.openingCost = '',
    this.fieldErrors = const [],
    this.saveError,
    this.unitLocked = false,
    this.categories = const [],
    this.pendingOpening,
    this.savedId,
    this.nameExistsElsewhere = false,
  });

  final ProductFormStatus status;
  final String name;
  final UnitType unit;
  final String price;
  final String? categoryId;
  final String barcode;
  final String sku;
  final String lowStock;
  final String openingQty;
  final String openingCost;
  final List<ProductFieldError> fieldErrors;

  /// A repository refusal: the barcode is taken or the unit is locked.
  final ProductSaveError? saveError;

  /// The product has stock history, so its unit cannot change.
  final bool unitLocked;
  final List<Category> categories;

  /// Shown on the confirmation while [status] is `confirmOpening`.
  final OpeningStock? pendingOpening;
  final String? savedId;
  final bool nameExistsElsewhere;

  /// The first error for [field], if any.
  ProductFieldError? errorFor(ProductField field) {
    for (final e in fieldErrors) {
      if (e.field == field) return e;
    }
    return null;
  }

  ProductFormState copyWith({
    ProductFormStatus? status,
    String? name,
    UnitType? unit,
    String? price,
    String? Function()? categoryId,
    String? barcode,
    String? sku,
    String? lowStock,
    String? openingQty,
    String? openingCost,
    List<ProductFieldError>? fieldErrors,
    ProductSaveError? Function()? saveError,
    bool? unitLocked,
    List<Category>? categories,
    OpeningStock? Function()? pendingOpening,
    String? savedId,
    bool? nameExistsElsewhere,
  }) => ProductFormState(
    status: status ?? this.status,
    name: name ?? this.name,
    unit: unit ?? this.unit,
    price: price ?? this.price,
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    barcode: barcode ?? this.barcode,
    sku: sku ?? this.sku,
    lowStock: lowStock ?? this.lowStock,
    openingQty: openingQty ?? this.openingQty,
    openingCost: openingCost ?? this.openingCost,
    fieldErrors: fieldErrors ?? this.fieldErrors,
    saveError: saveError == null ? this.saveError : saveError(),
    unitLocked: unitLocked ?? this.unitLocked,
    categories: categories ?? this.categories,
    pendingOpening: pendingOpening == null
        ? this.pendingOpening
        : pendingOpening(),
    savedId: savedId ?? this.savedId,
    nameExistsElsewhere: nameExistsElsewhere ?? this.nameExistsElsewhere,
  );

  @override
  List<Object?> get props => [
    status,
    name,
    unit,
    price,
    categoryId,
    barcode,
    sku,
    lowStock,
    openingQty,
    openingCost,
    fieldErrors,
    saveError,
    unitLocked,
    categories,
    pendingOpening,
    savedId,
    nameExistsElsewhere,
  ];
}

/// Adds or edits a product (FR-002–FR-005, FR-011). Errors show only after
/// a submit; editing a field clears them.
class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit(
    this._products,
    this._categories, {
    required this.mode,
    this.productId,
    String initialName = '',
  }) : assert(mode == ProductFormMode.create || productId != null),
       super(
         ProductFormState(
           name: initialName,
           status: mode == ProductFormMode.edit
               ? ProductFormStatus.loading
               : ProductFormStatus.editing,
         ),
       ) {
    _categoriesSub = _categories.watchActive().listen(
      (list) => emit(state.copyWith(categories: list)),
      onError: addError,
    );
    if (mode == ProductFormMode.edit) unawaited(_load());
  }

  final ProductRepository _products;
  final CategoryRepository _categories;
  final ProductFormMode mode;
  final String? productId;
  late final StreamSubscription<List<Category>> _categoriesSub;

  Future<void> _load() async {
    final summary = await _products.watchSummary(productId!).first;
    if (isClosed) return;
    if (summary == null) {
      emit(state.copyWith(status: ProductFormStatus.notFound));
      return;
    }
    final p = summary.product;
    emit(
      state.copyWith(
        status: ProductFormStatus.editing,
        name: p.name,
        unit: p.unit,
        price: _money(p.salePricePiasters),
        categoryId: () => p.categoryId,
        barcode: p.barcode ?? '',
        sku: p.sku ?? '',
        lowStock: p.lowStockThresholdMilli == null
            ? ''
            : _quantity(p.lowStockThresholdMilli!),
        unitLocked: summary.hasHistory,
      ),
    );
  }

  void nameChanged(String v) => _edit(state.copyWith(name: v));
  void priceChanged(String v) => _edit(state.copyWith(price: v));
  void barcodeChanged(String v) => _edit(state.copyWith(barcode: v));
  void skuChanged(String v) => _edit(state.copyWith(sku: v));
  void lowStockChanged(String v) => _edit(state.copyWith(lowStock: v));
  void openingQtyChanged(String v) => _edit(state.copyWith(openingQty: v));
  void openingCostChanged(String v) => _edit(state.copyWith(openingCost: v));

  void categoryChanged(String? id) =>
      _edit(state.copyWith(categoryId: () => id));

  void unitChanged(UnitType unit) {
    if (state.unitLocked) return;
    _edit(state.copyWith(unit: unit));
  }

  void _edit(ProductFormState next) => emit(
    next.copyWith(
      fieldErrors: const [],
      saveError: () => null,
      status: state.status == ProductFormStatus.failed
          ? ProductFormStatus.editing
          : null,
    ),
  );

  /// Validates. With an opening stock above zero it asks for confirmation;
  /// otherwise it saves.
  Future<void> submit() async {
    if (state.status != ProductFormStatus.editing &&
        state.status != ProductFormStatus.failed) {
      return;
    }
    final create = mode == ProductFormMode.create;
    final result = ProductDraft.create(
      name: state.name,
      unit: state.unit,
      priceText: state.price,
      categoryId: state.categoryId,
      barcode: state.barcode,
      sku: state.sku,
      lowStockText: state.lowStock,
      openingQtyText: create ? state.openingQty : '',
      openingCostText: create ? state.openingCost : '',
    );
    switch (result) {
      case Err(:final error):
        emit(
          state.copyWith(fieldErrors: error, status: ProductFormStatus.editing),
        );
      case Ok(value: final draft):
        if (draft.opening != null) {
          _pending = draft;
          emit(
            state.copyWith(
              status: ProductFormStatus.confirmOpening,
              pendingOpening: () => draft.opening,
            ),
          );
        } else {
          await _save(draft);
        }
    }
  }

  ProductDraft? _pending;

  Future<void> confirm() async {
    final draft = _pending;
    if (state.status != ProductFormStatus.confirmOpening || draft == null) {
      return;
    }
    await _save(draft);
  }

  /// Back from the confirmation: nothing is saved, the fields are kept.
  void cancelConfirm() {
    if (state.status != ProductFormStatus.confirmOpening) return;
    _pending = null;
    emit(
      state.copyWith(
        status: ProductFormStatus.editing,
        pendingOpening: () => null,
      ),
    );
  }

  Future<void> _save(ProductDraft draft) async {
    emit(state.copyWith(status: ProductFormStatus.saving));
    try {
      final result = mode == ProductFormMode.create
          ? await _products.create(draft)
          : await _products.update(productId!, draft);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(
              status: ProductFormStatus.saved,
              savedId: value.id,
              nameExistsElsewhere: value.nameExistsElsewhere,
              pendingOpening: () => null,
            ),
          );
        case Err(:final error):
          emit(
            state.copyWith(
              status: ProductFormStatus.editing,
              saveError: () => error,
              pendingOpening: () => null,
            ),
          );
      }
    } on Object catch (e, s) {
      addError(e, s);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: ProductFormStatus.failed,
            pendingOpening: () => null,
          ),
        );
      }
    } finally {
      _pending = null;
    }
  }

  static String _money(int piasters) =>
      formatScaledDecimal(piasters, scale: 2, minDecimals: 0);

  static String _quantity(int milli) =>
      formatScaledDecimal(milli, scale: 3, minDecimals: 0);

  @override
  Future<void> close() async {
    await _categoriesSub.cancel();
    return super.close();
  }
}
