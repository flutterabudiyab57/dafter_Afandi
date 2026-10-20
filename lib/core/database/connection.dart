import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// The production connection: `<application support>/daftar_afandi.sqlite`
/// (research R4, Q20), on a background isolate. drift_flutter keeps SQLite's
/// default rollback journal (research R3, approval A1).
QueryExecutor openAppDatabaseExecutor() => driftDatabase(
  name: 'daftar_afandi',
  native: const DriftNativeOptions(
    databaseDirectory: getApplicationSupportDirectory,
  ),
);
