import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../customers/domain/customer_errors.dart';
import '../../domain/supplier_draft.dart';
import '../../domain/supplier_repository.dart';

enum SupplierFormMode { create, edit }

enum SupplierFormStatus { loading, editing, saving, saved, failed, notFound }

final class SupplierFormState extends Equatable {
  const SupplierFormState({
    this.status = SupplierFormStatus.editing,
    this.name = '',
    this.phone = '',
    this.address = '',
    this.note = '',
    this.opening = '',
    this.openingInShopFavour = false,
    this.errors = const [],
    this.savedId,
    this.nameExistsElsewhere = false,
  });

  final SupplierFormStatus status;
  final String name;
  final String phone;
  final String address;
  final String note;
  final String opening;

  /// The opening balance is what the supplier owes the shop.
  final bool openingInShopFavour;
  final List<CustomerFieldError> errors;
  final String? savedId;
  final bool nameExistsElsewhere;

  SupplierFormState copyWith({
    SupplierFormStatus? status,
    String? name,
    String? phone,
    String? address,
    String? note,
    String? opening,
    bool? openingInShopFavour,
    List<CustomerFieldError>? errors,
    String? savedId,
    bool? nameExistsElsewhere,
  }) => SupplierFormState(
    status: status ?? this.status,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    note: note ?? this.note,
    opening: opening ?? this.opening,
    openingInShopFavour: openingInShopFavour ?? this.openingInShopFavour,
    errors: errors ?? this.errors,
    savedId: savedId ?? this.savedId,
    nameExistsElsewhere: nameExistsElsewhere ?? this.nameExistsElsewhere,
  );

  @override
  List<Object?> get props => [
    status,
    name,
    phone,
    address,
    note,
    opening,
    openingInShopFavour,
    errors,
    savedId,
    nameExistsElsewhere,
  ];
}

/// Adds or edits a supplier (FR-012, research R12). The opening balance is
/// only offered when adding.
class SupplierFormCubit extends Cubit<SupplierFormState> {
  SupplierFormCubit(
    this._repository, {
    required this.mode,
    this.supplierId,
    String initialName = '',
  }) : super(
         SupplierFormState(
           status: mode == SupplierFormMode.edit
               ? SupplierFormStatus.loading
               : SupplierFormStatus.editing,
           name: initialName,
         ),
       ) {
    if (mode == SupplierFormMode.edit) unawaited(_load());
  }

  final SupplierRepository _repository;
  final SupplierFormMode mode;
  final String? supplierId;

  Future<void> _load() async {
    final summary = await _repository.watchOne(supplierId!).first;
    if (isClosed) return;
    if (summary == null) {
      emit(state.copyWith(status: SupplierFormStatus.notFound));
      return;
    }
    final s = summary.supplier;
    emit(
      state.copyWith(
        status: SupplierFormStatus.editing,
        name: s.name,
        phone: s.phone ?? '',
        address: s.address ?? '',
        note: s.note ?? '',
      ),
    );
  }

  void nameChanged(String v) => _edit(state.copyWith(name: v));
  void phoneChanged(String v) => _edit(state.copyWith(phone: v));
  void addressChanged(String v) => _edit(state.copyWith(address: v));
  void noteChanged(String v) => _edit(state.copyWith(note: v));
  void openingChanged(String v) => _edit(state.copyWith(opening: v));
  void openingDirectionChanged({required bool inShopFavour}) =>
      _edit(state.copyWith(openingInShopFavour: inShopFavour));

  void _edit(SupplierFormState next) => emit(
    next.copyWith(
      errors: const [],
      status: state.status == SupplierFormStatus.failed
          ? SupplierFormStatus.editing
          : null,
    ),
  );

  Future<void> submit() async {
    final s = state.status;
    if (s != SupplierFormStatus.editing && s != SupplierFormStatus.failed) {
      return;
    }
    final built = SupplierDraft.create(
      name: state.name,
      phone: state.phone,
      address: state.address,
      note: state.note,
      openingText: mode == SupplierFormMode.create ? state.opening : '',
      openingInShopFavour: state.openingInShopFavour,
    );
    final SupplierDraft draft;
    switch (built) {
      case Err(:final error):
        emit(state.copyWith(errors: error));
        return;
      case Ok(:final value):
        draft = value;
    }
    emit(state.copyWith(status: SupplierFormStatus.saving));
    try {
      final result = mode == SupplierFormMode.create
          ? await _repository.create(draft)
          : await _repository.update(supplierId!, draft);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(
              status: SupplierFormStatus.saved,
              savedId: value.id,
              nameExistsElsewhere: value.nameExistsElsewhere,
            ),
          );
        case Err():
          emit(state.copyWith(status: SupplierFormStatus.notFound));
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) emit(state.copyWith(status: SupplierFormStatus.failed));
    }
  }
}
