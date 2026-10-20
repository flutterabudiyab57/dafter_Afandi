import 'dart:io';
import 'dart:typed_data';

import 'package:daftar_afandi/app.dart';
import 'package:daftar_afandi/bootstrap.dart';
import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/connection.dart';
import 'package:daftar_afandi/core/database/schema_constants.dart';
import 'package:daftar_afandi/core/di/service_locator.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/core/widgets/startup_error_app.dart';
import 'package:daftar_afandi/core/widgets/update_required_app.dart';
import 'package:daftar_afandi/features/settings/domain/app_version.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File dbFile;
  late List<Widget> shown;
  late int executorCalls;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('daftar_bootstrap_test_');
    dbFile = File(databasePathIn(dir));
    shown = [];
    executorCalls = 0;
  });
  tearDown(() async {
    await resetDependencies();
    await dir.delete(recursive: true);
  });

  QueryExecutor executorFactory(Directory d) {
    executorCalls++;
    return NativeDatabase(File(databasePathIn(d)));
  }

  Future<void> run() => bootstrap(
    runAppFn: shown.add,
    supportDir: () async => dir,
    executorFactory: executorFactory,
    versionSource: const _FixedVersion(),
  );

  /// A real v1 file made by AppDatabase, then closed.
  Future<void> createV1File() async {
    final db = AppDatabase(
      NativeDatabase(dbFile),
      const UuidV7Generator(),
      FixedClock(DateTime.utc(2026, 10, 20)),
    );
    await db.customSelect('SELECT 1').get();
    await db.close();
  }

  void patchInt32(int offset, int value) {
    final bytes = dbFile.readAsBytesSync();
    ByteData.sublistView(bytes).setInt32(offset, value);
    dbFile.writeAsBytesSync(bytes, flush: true);
  }

  Matcher updateRequired(UpdateRequiredKind kind) =>
      isA<UpdateRequiredApp>().having((a) => a.kind, 'kind', kind);

  test('fresh: app path, and the DB is created in the support dir', () async {
    await run();

    expect(
      shown.single,
      isA<App>()
          .having((a) => a.locale, 'locale', const Locale('ar'))
          .having((a) => a.appVersion.display, 'version', '1.0.0 (1)'),
    );
    expect(executorCalls, 1);
    expect(dbFile.existsSync(), isTrue);
    expect(dbFile.path.endsWith(kDatabaseFileName), isTrue);
    expect(sl.isRegistered<AppDatabase>(), isTrue);
  });

  test('a real v1 file: app path', () async {
    await createV1File();
    await run();

    expect(shown.single, isA<App>());
    expect(executorCalls, 1);
  });

  test(
    'user_version patched to 99: blocked, never opened, bytes unchanged',
    () async {
      await createV1File();
      patchInt32(60, 99);
      final before = dbFile.readAsBytesSync();
      final siblings = dir.listSync().length;

      await run();

      expect(shown.single, updateRequired(UpdateRequiredKind.tooNew));
      expect(executorCalls, 0);
      expect(sl.isRegistered<AppDatabase>(), isFalse);
      expect(dbFile.readAsBytesSync(), before);
      expect(dir.listSync(), hasLength(siblings));
    },
  );

  test('a foreign application id: blocked as unrecognized', () async {
    await createV1File();
    patchInt32(68, 0x12345678);
    final before = dbFile.readAsBytesSync();

    await run();

    expect(shown.single, updateRequired(UpdateRequiredKind.unrecognized));
    expect(executorCalls, 0);
    expect(dbFile.readAsBytesSync(), before);
  });

  test(
    'an executor that fails to open: startup error, nothing left registered',
    () async {
      await bootstrap(
        runAppFn: shown.add,
        supportDir: () async => dir,
        executorFactory: (_) => NativeDatabase.memory(
          setup: (_) => throw StateError('disk I/O error'),
        ),
      );

      expect(shown.single, isA<StartupErrorApp>());
      expect(sl.isRegistered<AppDatabase>(), isFalse);
    },
  );

  test('a support dir that cannot be resolved: startup error', () async {
    await bootstrap(
      runAppFn: shown.add,
      supportDir: () async => throw const FileSystemException('no dir'),
      executorFactory: executorFactory,
    );

    expect(shown.single, isA<StartupErrorApp>());
    expect(executorCalls, 0);
  });

  testWidgets('UpdateRequiredApp shows the Arabic title and body, RTL', (
    tester,
  ) async {
    await tester.pumpWidget(
      const UpdateRequiredApp(kind: UpdateRequiredKind.tooNew),
    );
    await tester.pumpAndSettle();

    expect(find.text('يلزم تحديث التطبيق'), findsOneWidget);
    expect(find.textContaining('بإصدار أحدث'), findsOneWidget);
    expect(find.byType(ButtonStyleButton), findsNothing);
    final context = tester.element(find.byType(Scaffold));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('UpdateRequiredApp unrecognized and StartupErrorApp bodies', (
    tester,
  ) async {
    await tester.pumpWidget(
      const UpdateRequiredApp(kind: UpdateRequiredKind.unrecognized),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('غير معروف'), findsOneWidget);

    await tester.pumpWidget(const StartupErrorApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('تعذّر فتح بياناتك'), findsOneWidget);
  });
}

final class _FixedVersion implements AppVersionSource {
  const _FixedVersion();

  @override
  Future<AppVersion> read() async =>
      const AppVersion(name: '1.0.0', build: '1');
}
