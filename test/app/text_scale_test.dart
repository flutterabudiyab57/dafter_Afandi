import 'package:daftar_afandi/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the system text scale reaches screens unchanged (FR-016)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: App(locale: Locale('ar')),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    expect(MediaQuery.textScalerOf(context), const TextScaler.linear(2));
  });
}
