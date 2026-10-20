import 'package:daftar_afandi/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('ar: material_ui localizations are Arabic, RTL', (tester) async {
    await tester.pumpWidget(const App(locale: Locale('ar')));
    await tester.pumpAndSettle();

    // material_ui's own MaterialApp type, not flutter/material's.
    expect(find.byType(MaterialApp), findsOneWidget);

    final context = tester.element(find.byType(Scaffold));
    final material = MaterialLocalizations.of(context);
    expect(
      material.okButtonLabel,
      isNot(const DefaultMaterialLocalizations().okButtonLabel),
    );
    expect(material.okButtonLabel, contains(RegExp('[؀-ۿ]')));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.text('دفتر أفندي'), findsOneWidget);
  });

  testWidgets('en: English localizations, LTR', (tester) async {
    await tester.pumpWidget(const App(locale: Locale('en')));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    expect(MaterialLocalizations.of(context).okButtonLabel, 'OK');
    expect(Directionality.of(context), TextDirection.ltr);
    expect(find.text('Daftar Afandi'), findsOneWidget);
  });
}
