import 'dart:io';
import 'dart:typed_data';

import 'package:daftar_afandi/core/database/schema_constants.dart';
import 'package:daftar_afandi/core/database/schema_guard.dart';
import 'package:flutter_test/flutter_test.dart';

const List<int> _magic = [
  0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, //
  0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00,
];

/// A 4096-byte file with an SQLite-like header.
Uint8List _header({
  int userVersion = 0,
  int applicationId = kAppApplicationId,
  List<int> magic = _magic,
}) {
  final bytes = Uint8List(4096);
  bytes.setRange(0, magic.length, magic);
  ByteData.sublistView(bytes)
    ..setInt32(60, userVersion)
    ..setInt32(68, applicationId);
  return bytes;
}

void main() {
  late Directory dir;
  late String path;
  const guard = FileSchemaGuard();

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('daftar_guard_test_');
    path = '${dir.path}${Platform.pathSeparator}$kDatabaseFileName';
  });
  tearDown(() => dir.delete(recursive: true));

  List<String> listing() =>
      dir.listSync().map((e) => e.uri.pathSegments.last).toList()..sort();

  /// Writes [bytes], inspects, and checks that nothing on disk changed.
  Future<SchemaInspection> inspectFile(List<int> bytes) async {
    final file = File(path)..writeAsBytesSync(bytes, flush: true);
    final modified = file.lastModifiedSync();
    final before = listing();

    final result = await guard.inspect(path);

    expect(file.readAsBytesSync(), bytes);
    expect(file.lengthSync(), bytes.length);
    expect(file.lastModifiedSync(), modified);
    expect(listing(), before, reason: 'no -journal, -wal or -shm sibling');
    return result;
  }

  test('absent file → fresh, and nothing is created', () async {
    expect(await guard.inspect(path), isA<SchemaFresh>());
    expect(listing(), isEmpty);
  });

  test('0 bytes → fresh', () async {
    expect(await inspectFile(const []), isA<SchemaFresh>());
  });

  test('50 bytes → unrecognized header', () async {
    final result = await inspectFile(_header().sublist(0, 50));
    expect(result, isA<SchemaUnrecognized>());
    expect((result as SchemaUnrecognized).reason, 'header');
  });

  test('bad magic → unrecognized header', () async {
    final magic = [..._magic]..[15] = 0x20;
    final result = await inspectFile(_header(magic: magic));
    expect((result as SchemaUnrecognized).reason, 'header');
  });

  test('foreign application id → unrecognized applicationId', () async {
    final result = await inspectFile(_header(applicationId: 0x12345678));
    expect((result as SchemaUnrecognized).reason, 'applicationId');
  });

  test(
    'application id 0 with version 3 → unrecognized applicationId',
    () async {
      final result = await inspectFile(
        _header(applicationId: 0, userVersion: 3),
      );
      expect((result as SchemaUnrecognized).reason, 'applicationId');
    },
  );

  test('application id 0 with version 0 → ok (a bare SQLite file)', () async {
    final result = await inspectFile(_header(applicationId: 0));
    expect((result as SchemaOk).userVersion, 0);
  });

  for (final version in [0, 1]) {
    test('version $version → ok', () async {
      final result = await inspectFile(_header(userVersion: version));
      expect((result as SchemaOk).userVersion, version);
    });
  }

  test('version 2 → too new', () async {
    final result = await inspectFile(_header(userVersion: 2));
    expect((result as SchemaTooNew).userVersion, 2);
  });

  test('exactly 100 bytes is enough', () async {
    final result = await inspectFile(_header(userVersion: 1).sublist(0, 100));
    expect(result, isA<SchemaOk>());
  });
}
