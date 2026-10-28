import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';

/// A label and an amount, wrapping under each other when they do not fit.
class ReportLine extends StatelessWidget {
  const ReportLine(this.label, this.amount, {this.strong = false, super.key});

  final String label;
  final String amount;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong ? Theme.of(context).textTheme.titleMedium : null;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: context.tokens.spaceSm,
      children: [
        Text(label, style: style),
        Text(amount, style: style),
      ],
    );
  }
}
