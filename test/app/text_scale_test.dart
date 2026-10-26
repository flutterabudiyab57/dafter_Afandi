import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('the system text scale reaches screens unchanged (FR-016)', (
    tester,
  ) async {
    await pumpApp(tester, FakeSettingsRepository(), textScale: 2);

    final context = tester.element(find.byType(Scaffold));
    expect(MediaQuery.textScalerOf(context).scale(10), 20);
  });
}
