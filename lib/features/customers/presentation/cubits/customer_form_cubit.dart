import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/customer_draft.dart';
import '../../domain/customer_errors.dart';
import '../../domain/customer_repository.dart';

enum CustomerFormMode { create, edit }

enum CustomerFormStatus { loading, editing, saving, saved, failed, notFound }

final class CustomerFormState extends Equatable {
  const CustomerFormState({
    this.status = CustomerFormStatus.editing,
    this.name = '',
    this.phone = '',
    this.address = '',
    this.note = '',
    this.opening = '',
    this.openingInFavour = false,
    this.errors = const [],
    this.savedId,
    this.nameExistsElsewhere = false,
  });

  final CustomerFormStatus status;
  final String name;
  final String phone;
  final String address;
  final String note;
  final String opening;

  /// The opening balance is what the shop owes the customer.
  final bool openingInFavour;
  final List<CustomerFieldError> errors;
  final String? savedId;
  final bool nameExistsElsewhere;

  CustomerFormState copyWith({
    CustomerFormStatus? status,
    String? name,
    String? phone,
    String? address,
    String? note,
    String? opening,
    bool? openingInFavour,
    List<CustomerFieldError>? errors,
    String? savedId,
    bool? nameExistsElsewhere,
  }) => CustomerFormState(
    status: status ?? this.status,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    note: note ?? this.note,
    opening: opening ?? this.opening,
    openingInFavour: openingInFavour ?? this.openingInFavour,
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
    openingInFavour,
    errors,
    savedId,
    nameExistsElsewhere,
  ];
}

/// Adds or edits a customer (FR-011, FR-012). The opening balance is only
/// offered when adding.
class CustomerFormCubit extends Cubit<CustomerFormState> {
  CustomerFormCubit(
    this._repository, {
    required this.mode,
    this.customerId,
    String initialName = '',
  }) : super(
         CustomerFormState(
           status: mode == CustomerFormMode.edit
               ? CustomerFormStatus.loading
               : CustomerFormStatus.editing,
           name: initialName,
         ),
       ) {
    if (mode == CustomerFormMode.edit) unawaited(_load());
  }

  /// The field values when the form became editable (research R9).
  Object? _baseline;

  /// True when a field differs from when the form became editable, until
  /// it is saved (research R9).
  bool get hasUnsavedChanges =>
      state.status != CustomerFormStatus.saved &&
      _baseline != null &&
      _fields(state) != _baseline;

  static Object _fields(CustomerFormState s) =>
      (s.name, s.phone, s.address, s.note, s.opening, s.openingInFavour);

  @override
  void onChange(Change<CustomerFormState> change) {
    super.onChange(change);
    // Create mode opens editable; edit mode once the record is read.
    if (_baseline != null) return;
    if (change.currentState.status != CustomerFormStatus.loading) {
      _baseline = _fields(change.currentState);
    } else if (change.nextState.status != CustomerFormStatus.loading) {
      _baseline = _fields(change.nextState);
    }
  }

  final CustomerRepository _repository;
  final CustomerFormMode mode;
  final String? customerId;

  Future<void> _load() async {
    final summary = await _repository.watchOne(customerId!).first;
    if (isClosed) return;
    if (summary == null) {
      emit(state.copyWith(status: CustomerFormStatus.notFound));
      return;
    }
    final c = summary.customer;
    emit(
      state.copyWith(
        status: CustomerFormStatus.editing,
        name: c.name,
        phone: c.phone ?? '',
        address: c.address ?? '',
        note: c.note ?? '',
      ),
    );
  }

  void nameChanged(String v) => _edit(state.copyWith(name: v));
  void phoneChanged(String v) => _edit(state.copyWith(phone: v));
  void addressChanged(String v) => _edit(state.copyWith(address: v));
  void noteChanged(String v) => _edit(state.copyWith(note: v));
  void openingChanged(String v) => _edit(state.copyWith(opening: v));
  void openingDirectionChanged({required bool inFavour}) =>
      _edit(state.copyWith(openingInFavour: inFavour));

  void _edit(CustomerFormState next) => emit(
    next.copyWith(
      errors: const [],
      status: state.status == CustomerFormStatus.failed
          ? CustomerFormStatus.editing
          : null,
    ),
  );

  Future<void> submit() async {
    final s = state.status;
    if (s != CustomerFormStatus.editing && s != CustomerFormStatus.failed) {
      return;
    }
    final built = CustomerDraft.create(
      name: state.name,
      phone: state.phone,
      address: state.address,
      note: state.note,
      openingText: mode == CustomerFormMode.create ? state.opening : '',
      openingInFavour: state.openingInFavour,
    );
    final CustomerDraft draft;
    switch (built) {
      case Err(:final error):
        emit(state.copyWith(errors: error));
        return;
      case Ok(:final value):
        draft = value;
    }
    emit(state.copyWith(status: CustomerFormStatus.saving));
    try {
      final result = mode == CustomerFormMode.create
          ? await _repository.create(draft)
          : await _repository.update(customerId!, draft);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(
              status: CustomerFormStatus.saved,
              savedId: value.id,
              nameExistsElsewhere: value.nameExistsElsewhere,
            ),
          );
        case Err():
          emit(state.copyWith(status: CustomerFormStatus.notFound));
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) emit(state.copyWith(status: CustomerFormStatus.failed));
    }
  }
}
