import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/account_ref.dart';
import '../../../../core/utils/digits.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/payment_split.dart';

/// Payment messages in the active language and digit style.
extension PaymentText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  String paymentSplitError(PaymentSplitError e) => switch (e) {
    PartAmountInvalid() => _l10n.errorPartAmountInvalid,
    PartAmountZero() => _l10n.errorPartAmountZero,
    MethodRepeated() => _l10n.errorPaymentMethodRepeated,
    AccountInvalid() => _l10n.errorAccountInvalid,
    AccountTooLong() => _l10n.errorAccountTooLong(count(maxAccountRefLength)),
    AccountNotAllowed() => _l10n.errorAccountNotAllowed,
    TooManyParts() => _l10n.errorTooManyParts,
    SumMismatch(:final differencePiasters) =>
      differencePiasters > 0
          ? _l10n.errorPartsOver(money(differencePiasters))
          : _l10n.errorPartsShort(money(-differencePiasters)),
  };

  /// "Wallet: EGP 200.00".
  String paymentPartLine(PaymentPart p) =>
      _l10n.paymentPartLine(methodLabel(p.method), money(p.amountPiasters));

  /// "Your account: 01012345678", kept left-to-right; null without one.
  String? paymentPartAccount(PaymentPart p) => switch (p.accountRef) {
    final a? => _l10n.paymentPartAccount(ltrIsolate(a)),
    null => null,
  };
}
