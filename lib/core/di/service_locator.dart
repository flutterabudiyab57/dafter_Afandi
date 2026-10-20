import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';

import '../database/app_database.dart';
import '../database/daos/settings_dao.dart';
import '../database/transaction_runner.dart';
import '../utils/clock.dart';
import '../utils/id.dart';

final GetIt sl = GetIt.instance;

/// Registers the app's services on [executor]. Called only after the schema
/// guard has passed (contracts/startup-guard.md); nothing is registered
/// before that.
Future<void> configureDependencies({required QueryExecutor executor}) async {
  sl
    ..registerSingleton<Clock>(const SystemClock())
    ..registerSingleton<IdGenerator>(const UuidV7Generator())
    ..registerSingleton<AppDatabase>(
      AppDatabase(executor, sl<IdGenerator>(), sl<Clock>()),
      dispose: (db) => db.close(),
    )
    ..registerLazySingleton<TransactionRunner>(
      () => DriftTransactionRunner(sl<AppDatabase>()),
    )
    ..registerLazySingleton<SettingsDao>(() => sl<AppDatabase>().settingsDao);
}

/// Unregisters everything and closes the database.
Future<void> resetDependencies() => sl.reset();
