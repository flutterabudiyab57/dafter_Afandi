import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/customer.dart';
import '../../domain/customer_draft.dart';
import '../../domain/customer_errors.dart';
import '../../domain/customer_repository.dart';

final class CustomersListState extends Equatable {
  const CustomersListState({
    this.query = const CustomerQuery(),
    this.items = const [],
    this.loading = true,
  });

  final CustomerQuery query;
  final List<CustomerSummary> items;

  /// True until the first result for the current query arrives.
  final bool loading;

  CustomersListState copyWith({
    CustomerQuery? query,
    List<CustomerSummary>? items,
    bool? loading,
  }) => CustomersListState(
    query: query ?? this.query,
    items: items ?? this.items,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [query, items, loading];
}

/// The customer list and the sale's customer picker (FR-014). Typing waits
/// [debounce] after the last keystroke before it queries.
class CustomersListCubit extends Cubit<CustomersListState> {
  CustomersListCubit(
    this._repository, {
    this.debounce = const Duration(milliseconds: 200),
  }) : super(const CustomersListState()) {
    _subscribe();
  }

  final CustomerRepository _repository;
  final Duration debounce;
  StreamSubscription<List<CustomerSummary>>? _sub;
  Timer? _timer;

  void search(String text) {
    emit(state.copyWith(query: state.query.copyWith(text: text)));
    _timer?.cancel();
    _timer = Timer(debounce, _subscribe);
  }

  void toggleOwes() {
    emit(
      state.copyWith(
        query: state.query.copyWith(owesOnly: !state.query.owesOnly),
      ),
    );
    _subscribe();
  }

  /// Adds a customer named like the search text, for the picker (US2-4).
  /// Returns it, or null when the name is not valid.
  Future<CustomerSummary?> quickAdd() async {
    final draft = CustomerDraft.create(name: state.query.text);
    if (draft case Ok(:final value)) {
      final saved = await _repository.create(value);
      if (saved case Ok(value: CustomerSaved(:final id))) {
        return CustomerSummary(
          customer: Customer(id: id, name: value.name),
          balancePiasters: 0,
        );
      }
    }
    return null;
  }

  void _subscribe() {
    _timer?.cancel();
    unawaited(_sub?.cancel());
    emit(state.copyWith(loading: true));
    _sub = _repository
        .watchActive(state.query)
        .listen(
          (items) => emit(state.copyWith(items: items, loading: false)),
          onError: addError,
        );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _sub?.cancel();
    return super.close();
  }
}

final class ArchivedCustomersState extends Equatable {
  const ArchivedCustomersState({this.items = const [], this.loaded = false});

  final List<CustomerSummary> items;
  final bool loaded;

  @override
  List<Object?> get props => [items, loaded];
}

/// Archived customers, each with Restore (FR-017).
class ArchivedCustomersCubit extends Cubit<ArchivedCustomersState> {
  ArchivedCustomersCubit(this._repository)
    : super(const ArchivedCustomersState()) {
    _sub = _repository.watchArchived().listen(
      (items) => emit(ArchivedCustomersState(items: items, loaded: true)),
      onError: addError,
    );
  }

  final CustomerRepository _repository;
  late final StreamSubscription<List<CustomerSummary>> _sub;

  Future<void> restore(String id) => _repository.restore(id);

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

/// The error for [field] among [errors], if any.
CustomerFieldError? errorFor(
  List<CustomerFieldError> errors,
  CustomerField field,
) {
  for (final e in errors) {
    if (e.field == field) return e;
  }
  return null;
}
