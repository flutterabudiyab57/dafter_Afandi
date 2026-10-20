import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('ar: material_ui localizations are Arabic, RTL', (tester) async {
    await pumpApp(tester, FakeSettingsRepository());

    // material_ui's own MaterialApp type, not flutter/material's.
    expect(find.byType(MaterialApp), findsOneWidget);

    final context = tester.element(find.byType(Scaffold));
    final material = MaterialLocalizations.of(context);
    expect(
      material.okButtonLabel,
      isNot(const DefaultMaterialLocalizations().okButtonLabel),
    );
    // Arabic block, U+0600 to U+06FF.
    expect(material.okButtonLabel, contains(RegExp(r'[؀-ۿ]')));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('en: English localizations, LTR', (tester) async {
    final repo = FakeSettingsRepository();
    await repo.setLocale(AppLocale.en);
    await pumpApp(tester, repo);

    final context = tester.element(find.byType(Scaffold));
    expect(MaterialLocalizations.of(context).okButtonLabel, 'OK');
    expect(Directionality.of(context), TextDirection.ltr);
  });
}
