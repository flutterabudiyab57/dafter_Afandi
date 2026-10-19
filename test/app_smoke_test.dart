import 'package:daftar_afandi/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('app starts and shows a material_ui Scaffold', (tester) async {
    await tester.pumpWidget(const DaftarAfandiApp());

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
