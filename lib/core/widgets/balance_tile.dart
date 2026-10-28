import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';
import '../utils/digits.dart';
import 'status_badge.dart';

/// A customer or supplier row: name, phone and balance. Above
/// [_stackScale] the balance moves under the phone: a list tile clips its
/// trailing widget to the tile's height, and it would squeeze the phone.
class BalanceTile extends StatelessWidget {
  const BalanceTile({
    required this.name,
    required this.phone,
    required this.balancePiasters,
    required this.balanceText,
    required this.onTap,
    super.key,
  });

  final String name;
  final String? phone;

  /// Positive: owes; negative: in credit; zero: plain text, no badge.
  final int balancePiasters;
  final String balanceText;
  final VoidCallback onTap;

  static const double _stackScale = 1.3;

  @override
  Widget build(BuildContext context) {
    final b = balancePiasters;
    final balance = b == 0
        ? Text(balanceText, textAlign: TextAlign.end)
        : StatusBadge(
            label: balanceText,
            tone: b > 0 ? BadgeTone.owes : BadgeTone.credit,
          );
    final phoneText = phone == null ? null : Text(ltrIsolate(phone!));
    final stacked = MediaQuery.textScalerOf(context).scale(1) > _stackScale;
    return ListTile(
      title: Text(name),
      subtitle: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.tokens.spaceXs,
              children: [?phoneText, balance],
            )
          : phoneText,
      trailing: stacked
          ? null
          : ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.4,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                widthFactor: 1,
                child: balance,
              ),
            ),
      onTap: onTap,
    );
  }
}
