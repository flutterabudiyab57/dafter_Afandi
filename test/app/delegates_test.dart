import 'package:daftar_afandi/app.dart';
import 'package:daftar_afandi/features/settings/domain/app_version.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('ar: material_ui localizations are Arabic, RTL', (tester) async {
    await tester.pumpWidget(
      const App(locale: Locale('ar'), appVersion: kTestVersion),
    );
    await tester.pumpAndSettle();

    // material_ui's own MaterialApp type, not flutter/material's.
    expect(find.byType(MaterialApp), findsOneWidget);

    final context = tester.element(find.byType(Scaffold));
    final material = MaterialLocalizations.of(context);
    expect(
      material.okButtonLabel,
      isNot(const DefaultMaterialLocalizations().okButtonLabel),
    );
    // Arabic block, U+0600 to U+06FF.
    expect(material.okButtonLabel, contains(RegExp(r'[\u0600-\u06FF]')));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('دفتر أفندي'), findsOneWidget);
  });

  testWidgets('en: English localizations, LTR', (tester) async {
    await tester.pumpWidget(
      const App(locale: Locale('en'), appVersion: kTestVersion),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    expect(MaterialLocalizations.of(context).okButtonLabel, 'OK');
    expect(Directionality.of(context), TextDirection.ltr);
    expect(find.text('Daftar Afandi'), findsOneWidget);
  });
}

const AppVersion kTestVersion = AppVersion(name: '1.0.0', build: '1');
