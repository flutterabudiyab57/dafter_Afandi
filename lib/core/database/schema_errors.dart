/// Thrown by `AppDatabase`'s `onUpgrade` when the file's schema is newer than
/// this app (FR-018, defence in depth behind the startup guard). It is thrown
/// before any migration statement runs.
final class SchemaTooNewException implements Exception {
  const SchemaTooNewException(this.fileVersion, this.appVersion);

  /// The schema version stored in the file.
  final int fileVersion;

  /// The schema version this app supports (`kSchemaVersion`).
  final int appVersion;

  @override
  String toString() =>
      'SchemaTooNewException: file schema $fileVersion > app schema $appVersion';
}
