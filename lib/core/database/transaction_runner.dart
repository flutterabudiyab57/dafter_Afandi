import 'app_database.dart';

/// Runs a unit of work in one database transaction (constitution: every
/// financial operation is one transaction). Repositories depend on this
/// interface, not on Drift.
abstract interface class TransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}

final class DriftTransactionRunner implements TransactionRunner {
  const DriftTransactionRunner(this._db);

  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) => _db.transaction(action);
}
