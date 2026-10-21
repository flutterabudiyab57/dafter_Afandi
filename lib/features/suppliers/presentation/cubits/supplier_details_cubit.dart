import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/supplier.dart';
import '../../domain/supplier_entry.dart';
import '../../domain/supplier_errors.dart';
import '../../domain/supplier_repository.dart';

final class SupplierDetailsState extends Equatable {
  const SupplierDetailsState({this.summary, this.loaded = false});

  /// Null when the supplier does not exist.
  final SupplierSummary? summary;
  final bool loaded;

  @override
  List<Object?> get props => [summary, loaded];
}

/// One supplier with their live balance (US4), archive and restore.
class SupplierDetailsCubit extends Cubit<SupplierDetailsState> {
  SupplierDetailsCubit(this._repository, this.supplierId)
    : super(const SupplierDetailsState()) {
    _sub = _repository
        .watchOne(supplierId)
        .listen(
          (s) => emit(SupplierDetailsState(summary: s, loaded: true)),
          onError: addError,
        );
  }

  final SupplierRepository _repository;
  final String supplierId;
  late final StreamSubscription<SupplierSummary?> _sub;

  Future<void> archive() => _repository.archive(supplierId);

  Future<void> restore() => _repository.restore(supplierId);

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

final class SupplierStatementState extends Equatable {
  const SupplierStatementState({
    this.entries = const [],
    this.hasMore = false,
    this.loading = true,
  });

  /// Newest first.
  final List<SupplierEntry> entries;
  final bool hasMore;
  final bool loading;

  @override
  List<Object?> get props => [entries, hasMore, loading];
}

/// A supplier's statement in pages (FR-016, research R10), and cancelling a
/// payment from it (FR-017a).
class SupplierStatementCubit extends Cubit<SupplierStatementState> {
  SupplierStatementCubit(
    this._repository,
    this.supplierId, {
    this.pageSize = 50,
  }) : super(const SupplierStatementState()) {
    // The first value is the current state, which the caller loads; every
    // later one is a new account row, e.g. from a void on another screen.
    _sub = _repository
        .watchStatementChanges(supplierId)
        .skip(1)
        .listen((_) => load(), onError: addError);
  }

  final SupplierRepository _repository;
  final String supplierId;
  final int pageSize;
  late final StreamSubscription<void> _sub;

  /// Bumped by [load], so a page read before a reload is dropped.
  var _generation = 0;

  /// Loads the first page again.
  Future<void> load() async {
    final generation = ++_generation;
    emit(
      SupplierStatementState(entries: state.entries, hasMore: state.hasMore),
    );
    final page = await _repository.statement(supplierId, limit: pageSize);
    if (isClosed || generation != _generation) return;
    emit(
      SupplierStatementState(
        entries: page,
        hasMore: page.length == pageSize,
        loading: false,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.loading || !state.hasMore || state.entries.isEmpty) return;
    final generation = _generation;
    emit(SupplierStatementState(entries: state.entries, hasMore: true));
    final page = await _repository.statement(
      supplierId,
      before: state.entries.last.cursor,
      limit: pageSize,
    );
    if (isClosed || generation != _generation) return;
    emit(
      SupplierStatementState(
        entries: [...state.entries, ...page],
        hasMore: page.length == pageSize,
        loading: false,
      ),
    );
  }

  /// [reason] is already validated. Returns the refusal, if any.
  Future<SupplierPaymentError?> cancelPayment(
    String entryId,
    String reason,
  ) async => switch (await _repository.cancelPayment(entryId, reason)) {
    Ok() => null,
    Err(:final error) => error,
  };

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
