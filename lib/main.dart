import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const DaftarAfandiApp());
}

/// Temporary root widget. Phase 4 replaces it with the bootstrap.
class DaftarAfandiApp extends StatelessWidget {
  const DaftarAfandiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold());
  }
}
