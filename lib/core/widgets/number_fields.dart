import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/digits.dart';

/// Accepts only what can become a number with at most [maxDecimals]
/// fraction digits: Latin, Arabic-Indic or Persian digits, `,` `٬`
/// grouping and one `.` or `٫` (002 research R12). Any other edit is
/// ignored, so a fourth decimal of a quantity cannot be typed.
final class DecimalInputFormatter extends TextInputFormatter {
  const DecimalInputFormatter(this.maxDecimals);

  final int maxDecimals;

  static final RegExp _allowed = RegExp(r'^[0-9,]*([.][0-9]*)?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = normalizeDigits(newValue.text)
        .replaceAll('٫', '.')
        .replaceAll('٬', ',');
    if (!_allowed.hasMatch(text)) return oldValue;
    final dot = text.indexOf('.');
    if (dot >= 0 && text.length - dot - 1 > maxDecimals) return oldValue;
    if (dot >= 0 && maxDecimals == 0) return oldValue;
    return newValue;
  }
}

/// A money field: up to 2 decimals, both digit sets (FR-002).
class MoneyField extends StatelessWidget {
  const MoneyField({
    required this.controller,
    required this.label,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? helperText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => _NumberField(
    controller: controller,
    label: label,
    maxDecimals: 2,
    onChanged: onChanged,
    errorText: errorText,
    helperText: helperText,
    textInputAction: textInputAction,
  );
}

/// A quantity field: up to 3 decimals for every unit, so a fraction typed
/// for a piece product reaches validation and gets its message (US1-4).
class QuantityField extends StatelessWidget {
  const QuantityField({
    required this.controller,
    required this.label,
    this.onChanged,
    this.errorText,
    this.helperText,
    this.textInputAction = TextInputAction.next,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? helperText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => _NumberField(
    controller: controller,
    label: label,
    maxDecimals: 3,
    onChanged: onChanged,
    errorText: errorText,
    helperText: helperText,
    textInputAction: textInputAction,
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.maxDecimals,
    required this.onChanged,
    required this.errorText,
    required this.helperText,
    required this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final int maxDecimals;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String? helperText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textInputAction: textInputAction,
    // Numbers read left to right in both languages.
    textDirection: TextDirection.ltr,
    inputFormatters: [DecimalInputFormatter(maxDecimals)],
    decoration: InputDecoration(
      labelText: label,
      errorText: errorText,
      errorMaxLines: 3,
      helperText: helperText,
      helperMaxLines: 3,
    ),
  );
}
