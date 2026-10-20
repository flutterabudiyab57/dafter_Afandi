/// Source-scanning rules that enforce the constitution (research R14).
///
/// Plain Dart: no package beyond the SDK. Paths are repo-relative with `/`.
library;

import 'dart:io';

class SourceFile {
  const SourceFile(this.path, this.content);

  final String path;
  final String content;
}

class Violation {
  const Violation(this.rule, this.path, this.detail);

  final String rule;
  final String path;
  final String detail;

  @override
  String toString() => '[$rule] $path: $detail';
}

typedef Rule = Iterable<Violation> Function(SourceFile file, String code);

const String _packagePrefix = 'package:daftar_afandi/';

final RegExp _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);
final RegExp _featureLayer = RegExp(
  r'^lib/features/([^/]+)/(data|domain|presentation)/',
);

/// Removes `/* */` blocks and `//` comments (a `//` preceded by `:` is kept,
/// so URLs inside strings survive).
String stripComments(String source) {
  final withoutBlocks = source.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return withoutBlocks.replaceAllMapped(
    RegExp(r'(^|[^:])//.*$', multiLine: true),
    (m) => m.group(1)!,
  );
}

/// Import/export targets, with relative and self-package paths resolved to
/// repo-relative `lib/...` paths. Other packages stay as `package:...`.
List<String> resolvedImports(SourceFile file, String code) {
  return _directive.allMatches(code).map((m) {
    final target = m.group(1)!;
    if (target.startsWith(_packagePrefix)) {
      return 'lib/${target.substring(_packagePrefix.length)}';
    }
    if (target.contains(':')) return target;
    final dir = file.path.substring(0, file.path.lastIndexOf('/'));
    return _normalize('$dir/$target');
  }).toList();
}

String _normalize(String path) {
  final out = <String>[];
  for (final part in path.split('/')) {
    if (part == '.' || part.isEmpty) continue;
    if (part == '..') {
      if (out.isNotEmpty) out.removeLast();
    } else {
      out.add(part);
    }
  }
  return out.join('/');
}

({String feature, String layer})? _featureOf(String path) {
  final m = _featureLayer.firstMatch(path);
  return m == null ? null : (feature: m.group(1)!, layer: m.group(2)!);
}

Iterable<Violation> _matches(
  String rule,
  SourceFile file,
  String code,
  RegExp pattern,
) sync* {
  for (final m in pattern.allMatches(code)) {
    yield Violation(rule, file.path, m.group(0)!);
  }
}

Iterable<Violation> noMaterialOrCupertino(SourceFile file, String code) sync* {
  for (final target in resolvedImports(file, code)) {
    if (target == 'package:flutter/material.dart' ||
        target == 'package:flutter/cupertino.dart') {
      yield Violation('no-material-cupertino', file.path, target);
    }
  }
}

Iterable<Violation> layerDirection(SourceFile file, String code) sync* {
  final owner = _featureOf(file.path);
  if (owner == null || owner.layer == 'data') return;
  for (final target in resolvedImports(file, code)) {
    final other = _featureOf(target);
    final crossFeatureData =
        other != null &&
        other.layer == 'data' &&
        other.feature != owner.feature;
    if (target.startsWith('package:drift') ||
        target.startsWith('lib/core/database/') ||
        crossFeatureData) {
      yield Violation('layer-direction', file.path, target);
    }
  }
}

Iterable<Violation> domainIsPureDart(SourceFile file, String code) sync* {
  if (_featureOf(file.path)?.layer != 'domain') return;
  for (final target in resolvedImports(file, code)) {
    if (target.startsWith('package:flutter/')) {
      yield Violation('domain-pure-dart', file.path, target);
    }
  }
}

Iterable<Violation> noLegacyDelegates(SourceFile file, String code) => _matches(
  'no-legacy-delegates',
  file,
  code,
  RegExp(r'AppLocalizations\.localizationsDelegates'),
);

Iterable<Violation> noFlutterLocalizationsWithMaterialUi(
  SourceFile file,
  String code,
) sync* {
  final targets = resolvedImports(file, code);
  final hasLocalizations = targets.any(
    (t) => t.startsWith('package:flutter_localizations/'),
  );
  final hasMaterialUi = targets.any(
    (t) => t.startsWith('package:material_ui/'),
  );
  if (hasLocalizations && hasMaterialUi) {
    yield Violation(
      'no-flutter-localizations-with-material-ui',
      file.path,
      'imports both flutter_localizations and material_ui',
    );
  }
}

Iterable<Violation> noDoubleInMoneyPaths(SourceFile file, String code) {
  final inScope =
      _featureOf(file.path)?.layer == 'domain' ||
      file.path == 'lib/core/utils/money.dart' ||
      file.path == 'lib/core/utils/quantity.dart';
  if (!inScope) return const [];
  return _matches('no-double', file, code, RegExp(r'\bdouble\b'));
}

Iterable<Violation> noNetwork(SourceFile file, String code) sync* {
  for (final target in resolvedImports(file, code)) {
    if (target.startsWith('package:http/') ||
        target.startsWith('package:dio/') ||
        target.startsWith('package:web_socket_channel/')) {
      yield Violation('no-network', file.path, target);
    }
  }
  yield* _matches(
    'no-network',
    file,
    code,
    RegExp(r'\b(?:HttpClient|Socket|RawSocket|WebSocket)\b'),
  );
}

Iterable<Violation> noScreenUtilSp(SourceFile file, String code) =>
    _matches('no-sp', file, code, RegExp(r'\.sp\b'));

Iterable<Violation> visualsOnlyInTheme(SourceFile file, String code) {
  if (file.path.startsWith('lib/core/theme/')) return const [];
  return _matches(
    'visuals-only-in-theme',
    file,
    code,
    RegExp(
      r'\bColor\(|\bTextStyle\(|EdgeInsets\.only\(|EdgeInsets\.fromLTRB\(|'
      r'Alignment\.(?:centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)\b|'
      r'TextAlign\.(?:left|right)\b',
    ),
  );
}

Iterable<Violation> noLiteralTextInPresentation(SourceFile file, String code) {
  if (!file.path.contains('/presentation/')) return const [];
  return _matches(
    'no-literal-text',
    file,
    code,
    RegExp(r'''\bText\(\s*(?:'[^']|"[^"])'''),
  );
}

/// No hard delete anywhere, and no update of the append-only stock ledger
/// (constitution III). The v1 triggers refuse both; this keeps code from
/// trying.
Iterable<Violation> noDeleteOrMovementUpdate(SourceFile file, String code) =>
    _matches(
      'no-delete',
      file,
      code,
      RegExp(
        r'\bdelete\(|\bdeleteWhere\b|\bDELETE\s+FROM\b|'
        r'\bUPDATE\s+stock_movements\b|\bupdate\(\s*stockMovements\s*\)',
        caseSensitive: false,
      ),
    );

const List<Rule> allRules = [
  noMaterialOrCupertino,
  layerDirection,
  domainIsPureDart,
  noLegacyDelegates,
  noFlutterLocalizationsWithMaterialUi,
  noDoubleInMoneyPaths,
  noNetwork,
  noScreenUtilSp,
  visualsOnlyInTheme,
  noLiteralTextInPresentation,
  noDeleteOrMovementUpdate,
];

List<Violation> check(SourceFile file, [List<Rule> rules = allRules]) {
  final code = stripComments(file.content);
  return [for (final rule in rules) ...rule(file, code)];
}

/// All hand-written Dart files under `lib/` (generated code is skipped).
List<SourceFile> libSources([String root = 'lib']) {
  final files = <SourceFile>[];
  for (final entity in Directory(root).listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll(r'\', '/');
    if (path.endsWith('.g.dart') || path.contains('lib/core/l10n/generated/')) {
      continue;
    }
    files.add(SourceFile(path, entity.readAsStringSync()));
  }
  return files;
}
