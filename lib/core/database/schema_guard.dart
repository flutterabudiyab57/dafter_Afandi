/// Reads the SQLite header before Drift touches the file (FR-018,
/// contracts/startup-guard.md). Pure `dart:io`: no package imports, so no
/// database object can exist while it runs.
library;

import 'dart:io';
import 'dart:typed_data';

import 'schema_constants.dart';

sealed class SchemaInspection {
  const SchemaInspection();
}

/// No file, or an empty one: Drift creates schema v1.
final class SchemaFresh extends SchemaInspection {
  const SchemaFresh();
}

/// A file this app made, at `0..kSchemaVersion`.
final class SchemaOk extends SchemaInspection {
  const SchemaOk(this.userVersion);

  final int userVersion;
}

/// A file made by a newer app version. It must never be opened.
final class SchemaTooNew extends SchemaInspection {
  const SchemaTooNew(this.userVersion);

  final int userVersion;
}

/// Not an SQLite file, or one made by another app.
final class SchemaUnrecognized extends SchemaInspection {
  const SchemaUnrecognized(this.reason);

  /// `header` or `applicationId`.
  final String reason;
}

abstract interface class SchemaGuard {
  /// Reads at most the first 100 bytes via a read-only handle. Never writes,
  /// never creates files.
  Future<SchemaInspection> inspect(String databasePath);
}

final class FileSchemaGuard implements SchemaGuard {
  const FileSchemaGuard();

  static const int _headerLength = 100;
  static const int _userVersionOffset = 60;
  static const int _applicationIdOffset = 68;
  static const List<int> _magic = [
    0x53, 0x51, 0x4c, 0x69, 0x74, 0x65, 0x20, 0x66, // "SQLite f"
    0x6f, 0x72, 0x6d, 0x61, 0x74, 0x20, 0x33, 0x00, // "ormat 3\0"
  ];

  @override
  Future<SchemaInspection> inspect(String databasePath) async {
    final file = File(databasePath);
    if (!await file.exists()) return const SchemaFresh();

    final handle = await file.open(); // FileMode.read
    final Uint8List header;
    final int length;
    try {
      length = await handle.length();
      header = await handle.read(_headerLength);
    } finally {
      await handle.close();
    }
    return decide(header, length);
  }

  /// The decision table from the contract, on the bytes read.
  static SchemaInspection decide(Uint8List header, int fileLength) {
    if (fileLength == 0) return const SchemaFresh();
    if (header.length < _headerLength) {
      return const SchemaUnrecognized('header');
    }
    for (var i = 0; i < _magic.length; i++) {
      if (header[i] != _magic[i]) return const SchemaUnrecognized('header');
    }

    final data = ByteData.sublistView(header);
    final userVersion = data.getInt32(_userVersionOffset); // big-endian
    final applicationId = data.getInt32(_applicationIdOffset);

    if (applicationId != 0 && applicationId != kAppApplicationId) {
      return const SchemaUnrecognized('applicationId');
    }
    if (applicationId == 0 && userVersion != 0) {
      return const SchemaUnrecognized('applicationId');
    }
    if (userVersion > kSchemaVersion) return SchemaTooNew(userVersion);
    return SchemaOk(userVersion);
  }
}
