import 'dart:io';

import 'package:daftar_afandi/core/database/schema_constants.dart';
import 'package:flutter_test/flutter_test.dart';

const String _res = 'android/app/src/main/res/xml';

final RegExp _include = RegExp(r'<include\s+([^>]*)/>');
final RegExp _exclude = RegExp(r'<exclude\b');

/// `(domain, path)` of every `<include>` in [xml], comments removed.
List<(String, String)> _includes(String xml) {
  final code = xml.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
  expect(_exclude.hasMatch(code), isFalse, reason: 'no excludes needed');
  return [
    for (final m in _include.allMatches(code))
      (
        RegExp(r'domain="([^"]*)"').firstMatch(m.group(1)!)!.group(1)!,
        RegExp(r'path="([^"]*)"').firstMatch(m.group(1)!)!.group(1)!,
      ),
  ];
}

void main() {
  test('Android 12+ rules back up only the database file (A1)', () {
    final xml = File('$_res/data_extraction_rules.xml').readAsStringSync();
    expect(
      xml,
      contains('<cloud-backup disableIfNoEncryptionCapabilities="false">'),
    );
    expect(xml, contains('<device-transfer>'));
    expect(_includes(xml), [
      ('file', kDatabaseFileName),
      ('file', kDatabaseFileName),
    ]);
    final code = xml.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
    expect(code, isNot(contains('-wal')));
  });

  test('Android 11 and lower rules back up only the database file', () {
    final xml = File('$_res/full_backup_content.xml').readAsStringSync();
    expect(_includes(xml), [('file', kDatabaseFileName)]);
  });

  test('the manifest turns backup on with both rule files', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:allowBackup="true"'));
    expect(
      manifest,
      contains('android:fullBackupContent="@xml/full_backup_content"'),
    );
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });

  test('portrait lock on Android and iOS (FR-019)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:screenOrientation="portrait"'));
    expect(
      manifest,
      contains('android.window.PROPERTY_COMPAT_ALLOW_RESTRICTED_RESIZABILITY'),
    );

    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final orientations = RegExp(r'<string>(UIInterfaceOrientation\w+)</string>')
        .allMatches(plist)
        .map((m) => m.group(1))
        .toSet();
    expect(orientations, {'UIInterfaceOrientationPortrait'});
    expect(
      plist,
      matches(RegExp(r'<key>UIRequiresFullScreen</key>\s*<true/>')),
    );
  });

  test('release signing never falls back to the debug key', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(gradle, contains('signingConfigs.getByName("release")'));
    expect(gradle, contains('key.properties is missing'));
    expect(File('android/key.properties.example').existsSync(), isTrue);
  });
}
