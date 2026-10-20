import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import 'core/database/connection.dart';
import 'core/database/daos/settings_dao.dart';
import 'core/database/schema_errors.dart';
import 'core/database/schema_guard.dart';
import 'core/di/service_locator.dart';
import 'core/widgets/startup_error_app.dart';
import 'core/widgets/update_required_app.dart';

/// Starts the app (contracts/startup-guard.md). The schema guard runs before
/// any database object or DI registration exists, so a newer or foreign file
/// is never opened (FR-018).
Future<void> bootstrap({
  required void Function(Widget) runAppFn,
  SchemaGuard? guard,
  Future<Directory> Function()? supportDir,
  QueryExecutor Function(Directory)? executorFactory,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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

  try {
    await configureDependencies(
      executor: (executorFactory ?? openAppDatabaseExecutor)(dir),
    );
    // The first query opens the file and runs onCreate or onUpgrade.
    await sl<SettingsDao>().getSingleton();
  } on SchemaTooNewException {
    await _releaseDatabase();
    runAppFn(const UpdateRequiredApp(kind: UpdateRequiredKind.tooNew));
    return;
  } on Object {
    await _releaseDatabase();
    runAppFn(const StartupErrorApp());
    return;
  }

  runAppFn(const _PlaceholderApp());
}

Future<void> _releaseDatabase() async {
  try {
    await resetDependencies();
  } on Object {
    // Closing a database that failed to open can throw too; the error screen
    // is shown either way.
  }
}

/// Temporary root until Phase 5 adds `App`.
class _PlaceholderApp extends StatelessWidget {
  const _PlaceholderApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold());
  }
}
