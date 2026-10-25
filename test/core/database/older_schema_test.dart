// Older data is upgraded automatically (US5). With only schema v1 the oldest
// file a phone can hold is version 0: the file left behind when the very
// first open stopped part-way (risk K4).
// TODO(v2): from schema v2 on, the generated stepByStep migration tests in
// test/drift/ cover US5-3 (each older version upgrades to the newest).
import 'dart:io';
import 'dart:typed_data';

import 'package:daftar_afandi/app.dart';
import 'package:daftar_afandi/bootstrap.dart';
import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/connection.dart';
import 'package:daftar_afandi/core/database/schema_constants.dart';
import 'package:daftar_afandi/core/database/schema_guard.dart';
import 'package:daftar_afandi/core/di/service_locator.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/features/settings/domain/app_version.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FailingIds implements IdGenerator {
  var _n = 0;

  @override
  String newId() {
    if (++_n > 3) throw StateError('power cut');
    return 'id$_n';
  }
}

final class _Version implements AppVersionSource {
  @override
  Future<AppVersion> read() async =>
      const AppVersion(name: '1.0.0', build: '1');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('daftar_older_test_');
    file = File(databasePathIn(dir));
  });
  tearDown(() async {
    await resetDependencies();
    await dir.delete(recursive: true);
  });

  int headerInt(int offset) =>
      ByteData.sublistView(file.readAsBytesSync()).getInt32(offset);

  test('the file left by a failed first open is completed to v1', () async {
    // The first open fails inside onCreate; its transaction rolls back.
    final broken = AppDatabase(
      NativeDatabase(file),
      _FailingIds(),
      FixedClock(DateTime.utc(2026, 10, 20)),
    );
    await expectLater(broken.customSelect('SELECT 1').get(), throwsStateError);
    await broken.close();

    // Nothing was committed, so the guard lets it through as fresh (an
    // empty file) or as version 0, never as unrecognized.
    final inspection = await const FileSchemaGuard().inspect(file.path);
    expect(
      inspection,
      anyOf(
        isA<SchemaFresh>(),
        isA<SchemaOk>().having((s) => s.userVersion, 'userVersion', 0),
      ),
    );

    final shown = <Object>[];
    await bootstrap(
      runAppFn: shown.add,
      supportDir: () async => dir,
      executorFactory: (d) => NativeDatabase(File(databasePathIn(d))),
      versionSource: _Version(),
    );

    expect(shown.last, isA<App>());
    final db = sl<AppDatabase>();
    final tables = await db
        .customSelect(
          "SELECT COUNT(*) AS n FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .getSingle();
    expect(tables.read<int>('n'), 17);
    await resetDependencies();
    expect(headerInt(60), kSchemaVersion);
    expect(headerInt(68), kAppApplicationId);
  });

  for (var version = 0; version <= kSchemaVersion; version++) {
    test('SchemaOk($version) is let through to open', () {
      final header = Uint8List(100)
        ..setRange(0, 16, 'SQLite format 3\u0000'.codeUnits);
      ByteData.sublistView(header)
        ..setInt32(60, version)
        ..setInt32(68, version == 0 ? 0 : kAppApplicationId);
      final result = FileSchemaGuard.decide(header, 4096);
      expect(result, isA<SchemaOk>());
      expect((result as SchemaOk).userVersion, version);
    });
  }
}
