import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/customer.dart';
import '../../domain/customer_errors.dart';
import '../../domain/customer_repository.dart';
import '../../domain/ledger_entry.dart';

final class CustomerDetailsState extends Equatable {
  const CustomerDetailsState({this.summary, this.loaded = false});

  /// Null when the customer does not exist.
  final CustomerSummary? summary;
  final bool loaded;

  @override
  List<Object?> get props => [summary, loaded];
}

/// One customer with their live balance (US4), archive and restore.
class CustomerDetailsCubit extends Cubit<CustomerDetailsState> {
  CustomerDetailsCubit(this._repository, this.customerId)
    : super(const CustomerDetailsState()) {
    _sub = _repository
        .watchOne(customerId)
        .listen(
          (s) => emit(CustomerDetailsState(summary: s, loaded: true)),
          onError: addError,
        );
  }

  final CustomerRepository _repository;
  final String customerId;
  late final StreamSubscription<CustomerSummary?> _sub;

  Future<void> archive() => _repository.archive(customerId);

  Future<void> restore() => _repository.restore(customerId);

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

final class StatementState extends Equatable {
  const StatementState({
    this.entries = const [],
    this.hasMore = false,
    this.loading = true,
  });

  /// Newest first.
  final List<LedgerEntry> entries;
  final bool hasMore;
  final bool loading;

  @override
  List<Object?> get props => [entries, hasMore, loading];
}

/// A customer's statement in pages (FR-015, research R9), and cancelling a
/// payment from it (FR-016a).
class StatementCubit extends Cubit<StatementState> {
  StatementCubit(this._repository, this.customerId, {this.pageSize = 50})
    : super(const StatementState()) {
    // The first value is the current state, which the caller loads; every
    // later one is a new account row, e.g. from a void on another screen.
    _sub = _repository
        .watchStatementChanges(customerId)
        .skip(1)
        .listen((_) => load(), onError: addError);
  }

  final CustomerRepository _repository;
  final String customerId;
  final int pageSize;
  late final StreamSubscription<void> _sub;

  /// Bumped by [load], so a page read before a reload is dropped.
  var _generation = 0;

  /// Loads the first page again.
  Future<void> load() async {
    final generation = ++_generation;
    emit(StatementState(entries: state.entries, hasMore: state.hasMore));
    final page = await _repository.statement(customerId, limit: pageSize);
    if (isClosed || generation != _generation) return;
    emit(
      StatementState(
        entries: page,
        hasMore: page.length == pageSize,
        loading: false,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore || state.entries.isEmpty) return;
    final generation = _generation;
    emit(StatementState(entries: state.entries, hasMore: true));
    final page = await _repository.statement(
      customerId,
      before: state.entries.last.cursor,
      limit: pageSize,
    );
    if (isClosed || generation != _generation) return;
    emit(
      StatementState(
        entries: [...state.entries, ...page],
        hasMore: page.length == pageSize,
        loading: false,
      ),
    );
  }

  /// [reason] is already validated. Returns the refusal, if any.
  Future<PaymentError?> cancelPayment(String entryId, String reason) async {
    final result = await _repository.cancelPayment(entryId, reason);
    return switch (result) {
      Ok() => null,
      Err(:final error) => error,
    };
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
