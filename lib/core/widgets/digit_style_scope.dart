import 'package:material_ui/material_ui.dart';

import '../utils/digits.dart';

/// The effective digit style for everything below (research R9).
class DigitStyleScope extends InheritedWidget {
  const DigitStyleScope({required this.style, required super.child, super.key});

  final DigitStyle style;

  /// Latin when there is no scope above [context].
  static DigitStyle of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DigitStyleScope>()?.style ??
      DigitStyle.latin;

  @override
  bool updateShouldNotify(DigitStyleScope oldWidget) =>
      style != oldWidget.style;
}

extension DigitStyleContext on BuildContext {
  /// [latin] in the current digit style. Never use it on the shop name or
  /// the app version (FR-011).
  String digits(String latin) =>
      applyDigitStyle(latin, DigitStyleScope.of(this));
}
