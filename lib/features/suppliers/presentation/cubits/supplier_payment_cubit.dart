import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../customers/domain/customer_errors.dart';
import '../../../customers/domain/payment.dart';
import '../../../payments/domain/payment_split.dart';
import '../../domain/supplier.dart';
import '../../domain/supplier_errors.dart';
import '../../domain/supplier_repository.dart';

enum SupplierPaymentStatus {
  loading,
  editing,

  /// The payment is more than the shop owes; waiting for the owner to accept
  /// that the supplier will then owe the shop (research R11).
  confirmOverpay,
  saving,
  saved,
  failed,
  notFound,
}

final class SupplierPaymentState extends Equatable {
  const SupplierPaymentState({
    this.status = SupplierPaymentStatus.loading,
    this.supplierName = '',
    this.balancePiasters = 0,
    this.amount = '',
    this.payment = const [PaymentPartInput(method: PaymentMethod.cash)],
    this.paymentErrors = const [],
    this.note = '',
    this.errors = const [],
    this.pending,
    this.paymentNumber,
    this.refusal,
  });

  final SupplierPaymentStatus status;
  final String supplierName;

  /// What the shop owes the supplier now.
  final int balancePiasters;
  final String amount;

  /// How it is paid, as typed: one part, or up to three (FR-036).
  final List<PaymentPartInput> payment;

  /// Why the parts were refused; shown on the payment field.
  final List<PaymentSplitError> paymentErrors;

  PaymentMethod get method => payment.first.method;
  final String note;
  final List<CustomerFieldError> errors;

  /// The validated payment while [status] is `confirmOverpay` or `saving`.
  final PaymentRequest? pending;

  /// Set when [status] is `saved`.
  final int? paymentNumber;
  final SupplierPaymentError? refusal;

  /// What the supplier will owe the shop after [pending] is saved.
  int get supplierOwesAfterPiasters =>
      (pending?.amountPiasters ?? 0) - balancePiasters;

  SupplierPaymentState copyWith({
    SupplierPaymentStatus? status,
    String? supplierName,
    int? balancePiasters,
    String? amount,
    List<PaymentPartInput>? payment,
    List<PaymentSplitError>? paymentErrors,
    String? note,
    List<CustomerFieldError>? errors,
    PaymentRequest? Function()? pending,
    int? paymentNumber,
    SupplierPaymentError? Function()? refusal,
  }) => SupplierPaymentState(
    status: status ?? this.status,
    supplierName: supplierName ?? this.supplierName,
    balancePiasters: balancePiasters ?? this.balancePiasters,
    amount: amount ?? this.amount,
    payment: payment ?? this.payment,
    paymentErrors: paymentErrors ?? this.paymentErrors,
    note: note ?? this.note,
    errors: errors ?? this.errors,
    pending: pending == null ? this.pending : pending(),
    paymentNumber: paymentNumber ?? this.paymentNumber,
    refusal: refusal == null ? this.refusal : refusal(),
  );

  @override
  List<Object?> get props => [
    status,
    supplierName,
    balancePiasters,
    amount,
    payment,
    note,
    errors,
    paymentErrors,
    pending,
    paymentNumber,
    refusal,
  ];
}

/// Pays a supplier (US5). The balance is watched so the notice uses the
/// current value.
class SupplierPaymentCubit extends Cubit<SupplierPaymentState> {
  SupplierPaymentCubit(this._repository, this.supplierId)
    : super(const SupplierPaymentState()) {
    _sub = _repository
        .watchOne(supplierId)
        .listen(_onSupplier, onError: addError);
  }

  /// The field values when the form became editable (research R9).
  Object? _baseline;

  /// True when a field differs from when the form became editable, until
  /// it is saved (research R9).
  bool get hasUnsavedChanges =>
      state.status != SupplierPaymentStatus.saved &&
      _baseline != null &&
      _fields(state) != _baseline;

  static Object _fields(SupplierPaymentState s) =>
      (s.amount, s.payment, s.note);

  @override
  void onChange(Change<SupplierPaymentState> change) {
    super.onChange(change);
    // The fields never change while loading, so the state before the
    // first change is the form as it opened.
    _baseline ??= _fields(change.currentState);
  }

  final SupplierRepository _repository;
  final String supplierId;
  late final StreamSubscription<SupplierSummary?> _sub;

  void _onSupplier(SupplierSummary? s) {
    if (s == null || s.supplier.archived) {
      emit(state.copyWith(status: SupplierPaymentStatus.notFound));
      return;
    }
    emit(
      state.copyWith(
        status: state.status == SupplierPaymentStatus.loading
            ? SupplierPaymentStatus.editing
            : null,
        supplierName: s.supplier.name,
        balancePiasters: s.balancePiasters,
      ),
    );
  }

  void amountChanged(String v) => _edit(state.copyWith(amount: v));
  void methodChanged(PaymentMethod m) =>
      _edit(state.copyWith(payment: [PaymentPartInput(method: m)]));

  /// The payment parts as typed (US6).
  void paymentChanged(List<PaymentPartInput> parts) {
    if (parts != state.payment) _edit(state.copyWith(payment: parts));
  }

  void noteChanged(String v) => _edit(state.copyWith(note: v));

  void _edit(SupplierPaymentState next) => emit(
    next.copyWith(
      errors: const [],
      paymentErrors: const [],
      refusal: () => null,
      status: state.status == SupplierPaymentStatus.failed
          ? SupplierPaymentStatus.editing
          : null,
    ),
  );

  /// Validates; asks first when the payment is more than the shop owes.
  Future<void> submit() async {
    final s = state.status;
    if (s != SupplierPaymentStatus.editing &&
        s != SupplierPaymentStatus.failed) {
      return;
    }
    switch (PaymentRequest.create(
      amountText: state.amount,
      method: state.method,
      note: state.note,
    )) {
      case Err(:final error):
        emit(state.copyWith(errors: error));
      case Ok(value: final request):
        final PaymentRequest value;
        switch (PaymentSplit.create(
          totalPiasters: request.amountPiasters,
          inputs: state.payment,
        )) {
          case Err(:final error):
            emit(state.copyWith(paymentErrors: error));
            return;
          case Ok(value: final split):
            value = split.isEmpty ? request : request.withSplit(split);
        }
        if (value.amountPiasters > state.balancePiasters) {
          emit(
            state.copyWith(
              status: SupplierPaymentStatus.confirmOverpay,
              pending: () => value,
            ),
          );
        } else {
          await _save(value);
        }
    }
  }

  Future<void> confirmOverpay() async {
    final p = state.pending;
    if (state.status != SupplierPaymentStatus.confirmOverpay || p == null) {
      return;
    }
    await _save(p);
  }

  void cancelOverpay() {
    if (state.status != SupplierPaymentStatus.confirmOverpay) return;
    emit(
      state.copyWith(
        status: SupplierPaymentStatus.editing,
        pending: () => null,
      ),
    );
  }

  Future<void> _save(PaymentRequest request) async {
    emit(
      state.copyWith(
        status: SupplierPaymentStatus.saving,
        pending: () => request,
      ),
    );
    try {
      final result = await _repository.pay(supplierId, request);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(
              status: SupplierPaymentStatus.saved,
              paymentNumber: value,
            ),
          );
        case Err(:final error):
          emit(
            state.copyWith(
              status: SupplierPaymentStatus.editing,
              refusal: () => error,
              pending: () => null,
            ),
          );
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SupplierPaymentStatus.failed,
            pending: () => null,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
