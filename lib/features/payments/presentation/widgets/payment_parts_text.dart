import 'package:material_ui/material_ui.dart';

import '../../../customers/presentation/widgets/customer_text.dart';
import '../../domain/payment_method.dart';
import '../../domain/payment_split.dart';
import 'payment_text.dart';

/// How a payment was made, on details screens and statements (FR-039):
/// each part with its method, its amount when split, and its account
/// number. A record from before 006 has no parts and shows [method] alone.
class PaymentPartsText extends StatelessWidget {
  const PaymentPartsText({required this.parts, this.method, super.key});

  final List<PaymentPart> parts;
  final PaymentMethod? method;

  @override
  Widget build(BuildContext context) {
    final method = this.method;
    if (parts.isEmpty) {
      return method == null
          ? const SizedBox.shrink()
          : Text(context.methodLabel(method));
    }
    final split = parts.length > 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in parts) ...[
          Text(
            split ? context.paymentPartLine(p) : context.methodLabel(p.method),
          ),
          if (context.paymentPartAccount(p) case final account?) Text(account),
        ],
      ],
    );
  }
}
