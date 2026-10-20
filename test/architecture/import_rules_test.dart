import 'package:flutter_test/flutter_test.dart';

import 'import_rules.dart';

List<String> _rulesHit(String path, String content, Rule rule) =>
    check(SourceFile(path, content), [rule]).map((v) => v.rule).toList();

void main() {
  group('repository sources', () {
    test('lib/ has no rule violations', () {
      final violations = [for (final f in libSources()) ...check(f)];
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('no-material-cupertino', () {
    test('flags legacy material and cupertino imports', () {
      expect(
        _rulesHit(
          'lib/a.dart',
          "import 'package:flutter/material.dart';",
          noMaterialOrCupertino,
        ),
        ['no-material-cupertino'],
      );
      expect(
        _rulesHit(
          'lib/a.dart',
          "import 'package:flutter/cupertino.dart';",
          noMaterialOrCupertino,
        ),
        ['no-material-cupertino'],
      );
    });

    test('allows material_ui and widgets', () {
      expect(
        _rulesHit(
          'lib/a.dart',
          "import 'package:material_ui/material_ui.dart';\n"
              "import 'package:flutter/widgets.dart';",
          noMaterialOrCupertino,
        ),
        isEmpty,
      );
    });
  });

  group('layer-direction', () {
    const screen = 'lib/features/sales/presentation/sales_screen.dart';

    test('flags drift, core/database and another feature data/', () {
      for (final import in [
        "import 'package:drift/drift.dart';",
        "import 'package:daftar_afandi/core/database/app_database.dart';",
        "import '../../../core/database/daos/settings_dao.dart';",
        "import 'package:daftar_afandi/features/settings/data/settings_repository_impl.dart';",
      ]) {
        expect(_rulesHit(screen, import, layerDirection), [
          'layer-direction',
        ], reason: import);
      }
    });

    test('allows domain imports and the same feature data from data/', () {
      expect(
        _rulesHit(
          screen,
          "import 'package:daftar_afandi/features/settings/domain/app_settings.dart';",
          layerDirection,
        ),
        isEmpty,
      );
      expect(
        _rulesHit(
          'lib/features/settings/data/settings_repository_impl.dart',
          "import 'package:daftar_afandi/core/database/daos/settings_dao.dart';",
          layerDirection,
        ),
        isEmpty,
      );
    });
  });

  group('domain-pure-dart', () {
    test('flags flutter imports in domain', () {
      expect(
        _rulesHit(
          'lib/features/settings/domain/x.dart',
          "import 'package:flutter/foundation.dart';",
          domainIsPureDart,
        ),
        ['domain-pure-dart'],
      );
    });

    test('allows flutter imports outside domain', () {
      expect(
        _rulesHit(
          'lib/features/settings/presentation/x.dart',
          "import 'package:flutter/foundation.dart';",
          domainIsPureDart,
        ),
        isEmpty,
      );
    });
  });

  group('no-legacy-delegates', () {
    test('flags AppLocalizations.localizationsDelegates', () {
      expect(
        _rulesHit(
          'lib/app.dart',
          'final d = AppLocalizations.localizationsDelegates;',
          noLegacyDelegates,
        ),
        ['no-legacy-delegates'],
      );
    });

    test('allows the material_ui delegate list', () {
      expect(
        _rulesHit(
          'lib/app.dart',
          'final d = [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates];',
          noLegacyDelegates,
        ),
        isEmpty,
      );
    });
  });

  group('no-flutter-localizations-with-material-ui', () {
    test('flags both imports in one file', () {
      expect(
        _rulesHit(
          'lib/app.dart',
          "import 'package:flutter_localizations/flutter_localizations.dart';\n"
              "import 'package:material_ui/material_ui.dart';",
          noFlutterLocalizationsWithMaterialUi,
        ),
        ['no-flutter-localizations-with-material-ui'],
      );
    });

    test('allows either alone', () {
      expect(
        _rulesHit(
          'lib/app.dart',
          "import 'package:material_ui/material_ui.dart';",
          noFlutterLocalizationsWithMaterialUi,
        ),
        isEmpty,
      );
    });
  });

  group('no-double', () {
    test('flags double in domain and money/quantity utils', () {
      for (final path in [
        'lib/features/sales/domain/line.dart',
        'lib/core/utils/money.dart',
        'lib/core/utils/quantity.dart',
      ]) {
        expect(_rulesHit(path, 'double price = 1;', noDoubleInMoneyPaths), [
          'no-double',
        ], reason: path);
      }
    });

    test('ignores comments and other paths', () {
      expect(
        _rulesHit(
          'lib/core/utils/money.dart',
          '// never use double here',
          noDoubleInMoneyPaths,
        ),
        isEmpty,
      );
      expect(
        _rulesHit(
          'lib/core/theme/app_spacing.dart',
          'const double md = 16;',
          noDoubleInMoneyPaths,
        ),
        isEmpty,
      );
    });
  });

  group('no-network', () {
    test('flags network packages and dart:io sockets', () {
      for (final source in [
        "import 'package:http/http.dart';",
        "import 'package:dio/dio.dart';",
        'final c = HttpClient();',
        'Socket.connect(host, 80);',
        'WebSocket.connect(url);',
      ]) {
        expect(
          _rulesHit('lib/a.dart', source, noNetwork),
          isNotEmpty,
          reason: source,
        );
      }
    });

    test('allows unrelated identifiers', () {
      expect(
        _rulesHit('lib/a.dart', 'final socketCount = 0;', noNetwork),
        isEmpty,
      );
    });
  });

  group('no-sp', () {
    test('flags .sp', () {
      expect(_rulesHit('lib/a.dart', 'final s = 14.sp;', noScreenUtilSp), [
        'no-sp',
      ]);
    });

    test('allows .spacing and .w', () {
      expect(
        _rulesHit(
          'lib/a.dart',
          'final a = t.spacing; final b = 4.w;',
          noScreenUtilSp,
        ),
        isEmpty,
      );
    });
  });

  group('visuals-only-in-theme', () {
    test('flags raw visuals outside lib/core/theme', () {
      for (final source in [
        'const c = Color(0xFF000000);',
        'const s = TextStyle(fontSize: 12);',
        'const p = EdgeInsets.only(left: 4);',
        'const p = EdgeInsets.fromLTRB(1, 2, 3, 4);',
        'const a = Alignment.centerLeft;',
        'const t = TextAlign.right;',
      ]) {
        expect(
          _rulesHit(
            'lib/features/home/presentation/home_screen.dart',
            source,
            visualsOnlyInTheme,
          ),
          ['visuals-only-in-theme'],
          reason: source,
        );
      }
    });

    test('allows them in lib/core/theme and allows directional APIs', () {
      expect(
        _rulesHit(
          'lib/core/theme/app_colors.dart',
          'const c = Color(0xFF326CE9);',
          visualsOnlyInTheme,
        ),
        isEmpty,
      );
      expect(
        _rulesHit(
          'lib/features/home/presentation/home_screen.dart',
          'const a = AlignmentDirectional.centerStart; const t = TextAlign.start;',
          visualsOnlyInTheme,
        ),
        isEmpty,
      );
    });
  });

  group('no-literal-text', () {
    test('flags literal strings in presentation Text widgets', () {
      expect(
        _rulesHit(
          'lib/features/home/presentation/home_screen.dart',
          "Text('Home')",
          noLiteralTextInPresentation,
        ),
        ['no-literal-text'],
      );
      expect(
        _rulesHit(
          'lib/features/home/presentation/home_screen.dart',
          'Text("Home")',
          noLiteralTextInPresentation,
        ),
        ['no-literal-text'],
      );
    });

    test('allows localized text and literals outside presentation', () {
      expect(
        _rulesHit(
          'lib/features/home/presentation/home_screen.dart',
          'Text(l10n.navHome)',
          noLiteralTextInPresentation,
        ),
        isEmpty,
      );
      expect(
        _rulesHit(
          'lib/core/widgets/x.dart',
          "Text('x')",
          noLiteralTextInPresentation,
        ),
        isEmpty,
      );
    });
  });

  group('stripComments', () {
    test('keeps URLs inside strings', () {
      expect(
        stripComments("final u = 'https://pub.dev'; // note"),
        "final u = 'https://pub.dev'; ",
      );
    });
  });
}
