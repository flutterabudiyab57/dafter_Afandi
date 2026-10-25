import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/database/connection.dart';
import 'core/database/schema_errors.dart';
import 'core/database/schema_guard.dart';
import 'core/di/service_locator.dart';
import 'core/theme/font_license.dart';
import 'core/widgets/starting_app.dart';
import 'core/widgets/startup_error_app.dart';
import 'core/widgets/update_required_app.dart';
import 'features/customers/presentation/customers_cubits.dart';
import 'features/products/presentation/products_cubits.dart';
import 'features/purchases/presentation/purchases_cubits.dart';
import 'features/sales/presentation/sales_cubits.dart';
import 'features/settings/domain/app_settings.dart';
import 'features/settings/domain/app_version.dart';
import 'features/settings/domain/settings_repository.dart';
import 'features/settings/presentation/cubits/app_preferences_cubit.dart';
import 'features/settings/presentation/cubits/shop_profile_form_cubit.dart';
import 'features/suppliers/presentation/suppliers_cubits.dart';

/// Starts the app (contracts/startup-guard.md). The schema guard runs before
/// any database object or DI registration exists, so a newer or foreign file
/// is never opened (FR-018).
Future<void> bootstrap({
  required void Function(Widget) runAppFn,
  SchemaGuard? guard,
  Future<Directory> Function()? supportDir,
  QueryExecutor Function(Directory)? executorFactory,
  AppVersionSource? versionSource,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  registerFontLicenses();
  // Replaced below by the app or a blocking app (research R12).
  runAppFn(const StartingApp());

  final Directory dir;
  final SchemaInspection inspection;
  try {
    dir = await (supportDir ?? getApplicationSupportDirectory)();
    inspection = await (guard ?? const FileSchemaGuard()).inspect(
      databasePathIn(dir),
    );
  } on Object {
    runAppFn(const StartupErrorApp());
    return;
  }

  switch (inspection) {
    case SchemaTooNew():
      runAppFn(const UpdateRequiredApp(kind: UpdateRequiredKind.tooNew));
      return;
    case SchemaUnrecognized():
      runAppFn(const UpdateRequiredApp(kind: UpdateRequiredKind.unrecognized));
      return;
    case SchemaFresh() || SchemaOk():
      break;
  }

  final AppSettings settings;
  final AppVersion version;
  try {
    await configureDependencies(
      executor: (executorFactory ?? openAppDatabaseExecutor)(dir),
      versionSource: versionSource,
    );
    // The first query opens the file and runs onCreate or onUpgrade.
    settings = await sl<SettingsRepository>().load();
    // Read once and passed down (T081).
    version = await sl<AppVersionSource>().read();
  } on SchemaTooNewException {
    await _releaseDatabase();
    runAppFn(const UpdateRequiredApp(kind: UpdateRequiredKind.tooNew));
    return;
  } on Object {
    await _releaseDatabase();
    runAppFn(const StartupErrorApp());
    return;
  }

  runAppFn(
    App(
      preferences: sl<AppPreferencesCubit>(param1: settings),
      appVersion: version,
      shopProfileForm: (mode, initial) =>
          sl<ShopProfileFormCubit>(param1: mode, param2: initial),
      products: sl<ProductsCubits>(),
      customers: sl<CustomersCubits>(),
      sales: sl<SalesCubits>(),
      suppliers: sl<SuppliersCubits>(),
      purchases: sl<PurchasesCubits>(),
    ),
  );
}

Future<void> _releaseDatabase() async {
  try {
    await resetDependencies();
  } on Object {
    // Closing a database that failed to open can throw too; the error screen
    // is shown either way.
  }
}
