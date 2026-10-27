import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../payments/domain/payment_split.dart';
import '../../domain/customer.dart';
import '../../domain/customer_errors.dart';
import '../../domain/customer_repository.dart';
import '../../domain/payment.dart';

enum PaymentStatus {
  loading,
  editing,

  /// The payment is more than the balance; waiting for the owner to accept
  /// the resulting credit (FR-016).
  confirmCredit,
  saving,
  saved,
  failed,
  notFound,
}

final class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentStatus.loading,
    this.customerName = '',
    this.balancePiasters = 0,
    this.amount = '',
    this.payment = const [PaymentPartInput(method: PaymentMethod.cash)],
    this.paymentErrors = const [],
    this.note = '',
    this.errors = const [],
    this.pending,
    this.receiptNumber,
    this.refusal,
  });

  final PaymentStatus status;
  final String customerName;
  final int balancePiasters;
  final String amount;

  /// How it is paid, as typed: one part, or up to three (FR-036).
  final List<PaymentPartInput> payment;

  /// Why the parts were refused; shown on the payment field.
  final List<PaymentSplitError> paymentErrors;

  PaymentMethod get method => payment.first.method;
  final String note;
  final List<CustomerFieldError> errors;

  /// The validated payment while [status] is `confirmCredit` or `saving`.
  final PaymentRequest? pending;

  /// Set when [status] is `saved`.
  final int? receiptNumber;
  final PaymentError? refusal;

  /// The customer's credit after [pending] would be saved.
  int get creditAfterPiasters =>
      (pending?.amountPiasters ?? 0) - balancePiasters;

  PaymentState copyWith({
    PaymentStatus? status,
    String? customerName,
    int? balancePiasters,
    String? amount,
    List<PaymentPartInput>? payment,
    List<PaymentSplitError>? paymentErrors,
    String? note,
    List<CustomerFieldError>? errors,
    PaymentRequest? Function()? pending,
    int? receiptNumber,
    PaymentError? Function()? refusal,
  }) => PaymentState(
    status: status ?? this.status,
    customerName: customerName ?? this.customerName,
    balancePiasters: balancePiasters ?? this.balancePiasters,
    amount: amount ?? this.amount,
    payment: payment ?? this.payment,
    paymentErrors: paymentErrors ?? this.paymentErrors,
    note: note ?? this.note,
    errors: errors ?? this.errors,
    pending: pending == null ? this.pending : pending(),
    receiptNumber: receiptNumber ?? this.receiptNumber,
    refusal: refusal == null ? this.refusal : refusal(),
  );

  @override
  List<Object?> get props => [
    status,
    customerName,
    balancePiasters,
    amount,
    payment,
    note,
    errors,
    paymentErrors,
    pending,
    receiptNumber,
    refusal,
  ];
}

/// Receives a payment from a customer (US5). The balance is watched so the
/// credit notice uses the current value.
class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._repository, this.customerId)
    : super(const PaymentState()) {
    _sub = _repository
        .watchOne(customerId)
        .listen(_onCustomer, onError: addError);
  }

  /// The field values when the form became editable (research R9).
  Object? _baseline;

  /// True when a field differs from when the form became editable, until
  /// it is saved (research R9).
  bool get hasUnsavedChanges =>
      state.status != PaymentStatus.saved &&
      _baseline != null &&
      _fields(state) != _baseline;

  static Object _fields(PaymentState s) => (s.amount, s.payment, s.note);

  @override
  void onChange(Change<PaymentState> change) {
    super.onChange(change);
    // The fields never change while loading, so the state before the
    // first change is the form as it opened.
    _baseline ??= _fields(change.currentState);
  }

  final CustomerRepository _repository;
  final String customerId;
  late final StreamSubscription<CustomerSummary?> _sub;

  void _onCustomer(CustomerSummary? s) {
    if (s == null || s.customer.archived) {
      emit(state.copyWith(status: PaymentStatus.notFound));
      return;
    }
    emit(
      state.copyWith(
        status: state.status == PaymentStatus.loading
            ? PaymentStatus.editing
            : null,
        customerName: s.customer.name,
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

  void _edit(PaymentState next) => emit(
    next.copyWith(
      errors: const [],
      paymentErrors: const [],
      refusal: () => null,
      status: state.status == PaymentStatus.failed
          ? PaymentStatus.editing
          : null,
    ),
  );

  /// Validates; asks first when the payment is more than the balance.
  Future<void> submit() async {
    final s = state.status;
    if (s != PaymentStatus.editing && s != PaymentStatus.failed) return;
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
              status: PaymentStatus.confirmCredit,
              pending: () => value,
            ),
          );
        } else {
          await _save(value);
        }
    }
  }

  Future<void> confirmCredit() async {
    final p = state.pending;
    if (state.status != PaymentStatus.confirmCredit || p == null) return;
    await _save(p);
  }

  void cancelCredit() {
    if (state.status != PaymentStatus.confirmCredit) return;
    emit(state.copyWith(status: PaymentStatus.editing, pending: () => null));
  }

  Future<void> _save(PaymentRequest request) async {
    emit(state.copyWith(status: PaymentStatus.saving, pending: () => request));
    try {
      final result = await _repository.receivePayment(customerId, request);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(status: PaymentStatus.saved, receiptNumber: value),
          );
        case Err(:final error):
          emit(
            state.copyWith(
              status: PaymentStatus.editing,
              refusal: () => error,
              pending: () => null,
            ),
          );
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) {
        emit(state.copyWith(status: PaymentStatus.failed, pending: () => null));
      }
    }
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
