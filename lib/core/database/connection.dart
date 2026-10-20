import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'schema_constants.dart';

/// `<directory>/daftar_afandi.sqlite`: the file the schema guard inspects.
String databasePathIn(Directory directory) =>
    '${directory.path}${Platform.pathSeparator}$kDatabaseFileName';

/// The production connection to [databasePathIn] (research R4, Q20), on a
/// background isolate. drift_flutter keeps SQLite's default rollback journal
/// (research R3, approval A1).
QueryExecutor openAppDatabaseExecutor(Directory directory) => driftDatabase(
  name: 'daftar_afandi',
  native: DriftNativeOptions(
    databasePath: () async => databasePathIn(directory),
  ),
);
