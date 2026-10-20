import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';

import '../../features/settings/data/package_info_app_version_source.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/settings/domain/app_version.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/domain/shop_profile.dart';
import '../../features/settings/presentation/cubits/app_preferences_cubit.dart';
import '../../features/settings/presentation/cubits/shop_profile_form_cubit.dart';
import '../database/app_database.dart';
import '../database/daos/settings_dao.dart';
import '../database/transaction_runner.dart';
import '../utils/clock.dart';
import '../utils/id.dart';

final GetIt sl = GetIt.instance;

/// Registers the app's services on [executor]. Called only after the schema
/// guard has passed (contracts/startup-guard.md); nothing is registered
/// before that.
Future<void> configureDependencies({
  required QueryExecutor executor,
  AppVersionSource? versionSource,
}) async {
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
    ..registerLazySingleton<SettingsDao>(() => sl<AppDatabase>().settingsDao)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        sl<SettingsDao>(),
        sl<TransactionRunner>(),
        sl<Clock>(),
      ),
    )
    ..registerSingleton<AppVersionSource>(
      versionSource ?? const PackageInfoAppVersionSource(),
    )
    ..registerFactoryParam<AppPreferencesCubit, AppSettings, void>(
      (initial, _) => AppPreferencesCubit(sl<SettingsRepository>(), initial),
    )
    ..registerFactoryParam<
      ShopProfileFormCubit,
      ShopProfileFormMode,
      ShopProfile?
    >(
      (mode, initial) => ShopProfileFormCubit(
        sl<SettingsRepository>(),
        mode: mode,
        initial: initial,
      ),
    );
}

/// Unregisters everything and closes the database.
Future<void> resetDependencies() => sl.reset();
