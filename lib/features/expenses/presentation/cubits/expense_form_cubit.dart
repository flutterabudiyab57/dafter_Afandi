import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/clock.dart';
import '../../../../core/utils/result.dart';
import '../../../payments/domain/payment_method.dart';
import '../../../payments/domain/payment_split.dart';
import '../../domain/expense.dart';
import '../../domain/expense_draft.dart';
import '../../domain/expense_errors.dart';
import '../../domain/expense_repository.dart';

enum ExpenseFormStatus { editing, saving, saved, failed }

final class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    required this.spentOn,
    this.status = ExpenseFormStatus.editing,
    this.categories = const [],
    this.categoryId,
    this.amount = '',
    this.payment = const [PaymentPartInput(method: PaymentMethod.cash)],
    this.note = '',
    this.errors = const [],
    this.saveError,
    this.saved,
  });

  final ExpenseFormStatus status;

  /// Active categories to pick from.
  final List<ExpenseCategory> categories;
  final String? categoryId;
  final String amount;

  /// How it was paid, as typed: one part, or up to three (FR-022).
  final List<PaymentPartInput> payment;

  PaymentMethod get method => payment.first.method;

  /// Local midnight; today to start.
  final DateTime spentOn;
  final String note;

  /// Rules the form breaks, shown after Save.
  final List<ExpenseFieldError> errors;

  /// A refusal from saving other than broken rules.
  final ExpenseSaveError? saveError;

  /// Set when [status] is `saved`.
  final ExpenseSaved? saved;

  ExpenseFormState copyWith({
    ExpenseFormStatus? status,
    List<ExpenseCategory>? categories,
    String? Function()? categoryId,
    String? amount,
    List<PaymentPartInput>? payment,
    DateTime? spentOn,
    String? note,
    List<ExpenseFieldError>? errors,
    ExpenseSaveError? Function()? saveError,
    ExpenseSaved? Function()? saved,
  }) => ExpenseFormState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    categoryId: categoryId == null ? this.categoryId : categoryId(),
    amount: amount ?? this.amount,
    payment: payment ?? this.payment,
    spentOn: spentOn ?? this.spentOn,
    note: note ?? this.note,
    errors: errors ?? this.errors,
    saveError: saveError == null ? this.saveError : saveError(),
    saved: saved == null ? this.saved : saved(),
  );

  @override
  List<Object?> get props => [
    status,
    categories,
    categoryId,
    amount,
    payment,
    spentOn,
    note,
    errors,
    saveError,
    saved,
  ];
}

/// The new expense form (US3-1, US3-2), paid in one part or split (US6).
class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  ExpenseFormCubit(this._expenses, this._categories, this._clock)
    : super(ExpenseFormState(spentOn: _localToday(_clock))) {
    _baseline = _fields(state);
    _sub = _categories.watchActive().listen(
      (list) => emit(state.copyWith(categories: list)),
      onError: addError,
    );
  }

  final ExpenseRepository _expenses;
  final ExpenseCategoryRepository _categories;
  final Clock _clock;
  late final Object _baseline;
  late final StreamSubscription<List<ExpenseCategory>> _sub;

  static DateTime _localToday(Clock clock) {
    final local = clock.nowUtc().toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// The local date: the latest day the form allows.
  DateTime get today => _localToday(_clock);

  static Object _fields(ExpenseFormState s) =>
      (s.categoryId, s.amount, s.payment, s.spentOn, s.note);

  /// True when a field differs from when the form opened, until saved.
  bool get hasUnsavedChanges =>
      state.status != ExpenseFormStatus.saved && _fields(state) != _baseline;

  /// The four defaults, in the shop's language, the first time only
  /// (research R13).
  Future<void> ensureDefaults(List<String> names) =>
      _categories.ensureDefaults(names);

  void categoryChanged(String id) =>
      _edit(state.copyWith(categoryId: () => id));
  void amountChanged(String v) => _edit(state.copyWith(amount: v));
  void methodChanged(PaymentMethod m) =>
      _edit(state.copyWith(payment: [PaymentPartInput(method: m)]));

  /// The payment parts as typed (US6).
  void paymentChanged(List<PaymentPartInput> parts) {
    if (parts != state.payment) _edit(state.copyWith(payment: parts));
  }

  void dateChanged(DateTime d) =>
      _edit(state.copyWith(spentOn: DateTime(d.year, d.month, d.day)));
  void noteChanged(String v) => _edit(state.copyWith(note: v));

  void _edit(ExpenseFormState next) => emit(
    next.copyWith(
      errors: const [],
      saveError: () => null,
      status: state.status == ExpenseFormStatus.failed
          ? ExpenseFormStatus.editing
          : null,
    ),
  );

  /// Validates and saves.
  Future<void> submit() async {
    final s = state.status;
    if (s != ExpenseFormStatus.editing && s != ExpenseFormStatus.failed) {
      return;
    }
    final ExpenseDraft draft;
    switch (ExpenseDraft.create(
      categoryId: state.categoryId,
      amountText: state.amount,
      spentOn: state.spentOn,
      today: today,
      parts: state.payment,
      note: state.note,
    )) {
      case Ok(:final value):
        draft = value;
      case Err(:final error):
        emit(state.copyWith(errors: error));
        return;
    }
    emit(state.copyWith(status: ExpenseFormStatus.saving));
    try {
      final result = await _expenses.create(draft);
      if (isClosed) return;
      switch (result) {
        case Ok(:final value):
          emit(
            state.copyWith(status: ExpenseFormStatus.saved, saved: () => value),
          );
        case Err(error: ExpenseInvalid(errors: final list)):
          emit(state.copyWith(status: ExpenseFormStatus.editing, errors: list));
        case Err(:final error):
          emit(
            state.copyWith(
              status: ExpenseFormStatus.editing,
              saveError: () => error,
            ),
          );
      }
    } on Object catch (e, st) {
      addError(e, st);
      if (!isClosed) emit(state.copyWith(status: ExpenseFormStatus.failed));
    }
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
