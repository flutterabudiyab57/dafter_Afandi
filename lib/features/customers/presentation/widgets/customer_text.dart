import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/utils/doc_number.dart';
import '../../../../core/utils/phone.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/customer_errors.dart';
import '../../domain/ledger_entry.dart';
import '../../domain/payment.dart';

/// Customer and payment messages, labels and amounts in the active
/// language and digit style.
extension CustomerText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  String customerFieldError(CustomerFieldError e) => switch ((
    e.field,
    e.problem,
  )) {
    (CustomerField.name, CustomerProblem.required) =>
      _l10n.errorCustomerNameRequired,
    (CustomerField.name, _) => _l10n.errorNameTooLong(count(e.max ?? 0)),
    (CustomerField.phone, CustomerProblem.tooShort) => _l10n.errorPhoneTooShort(
      count(minPhoneDigits),
    ),
    (CustomerField.phone, CustomerProblem.tooLong) => _l10n.errorPhoneTooLong(
      count(maxPhoneDigits),
    ),
    (CustomerField.phone, _) => _l10n.errorPhoneInvalid,
    (CustomerField.reason, CustomerProblem.required) =>
      _l10n.errorReasonRequired,
    (CustomerField.reason, _) => _l10n.errorReasonTooLong(count(e.max ?? 0)),
    (CustomerField.address || CustomerField.note, _) => _l10n.errorCodeTooLong(
      count(e.max ?? 0),
    ),
    (CustomerField.opening || CustomerField.amount, CustomerProblem.required) =>
      _l10n.errorAmountRequired,
    (CustomerField.opening || CustomerField.amount, CustomerProblem.tooLarge) =>
      _l10n.errorPriceTooLarge(money(e.max ?? 0)),
    (CustomerField.opening || CustomerField.amount, _) =>
      _l10n.errorPriceInvalid,
  };

  String paymentError(PaymentError e) => switch (e) {
    PaymentCustomerNotFound() => _l10n.customerNotFound,
    PaymentCustomerArchived() => _l10n.errorCustomerArchived,
    PaymentNotCancellable() ||
    PaymentAlreadyCancelled() => _l10n.ledgerCancelled,
  };

  /// "Owes 60.00", "In credit 20.00" or "No balance".
  String balance(int piasters) => piasters > 0
      ? _l10n.balanceOwes(money(piasters))
      : piasters < 0
      ? _l10n.balanceInFavour(money(-piasters))
      : _l10n.balanceZero;

  String methodLabel(PaymentMethod m) => switch (m) {
    PaymentMethod.cash => _l10n.methodCash,
    PaymentMethod.wallet => _l10n.methodWallet,
    PaymentMethod.instapay => _l10n.methodInstapay,
    PaymentMethod.card => _l10n.methodCard,
  };

  /// "S-000012" in the digit style, kept left-to-right.
  String docNumber(String prefix, int n) =>
      ltrIsolate(digits(formatDocNumber(prefix, n)));

  String saleNumber(int n) => docNumber(saleNumberPrefix, n);

  String receiptNumber(int n) => docNumber(receiptNumberPrefix, n);

  /// The statement row's title.
  String ledgerTitle(LedgerEntry e) => switch (e.type) {
    LedgerEntryType.openingBalance => _l10n.ledgerOpening,
    LedgerEntryType.sale => _l10n.ledgerSale(saleNumber(e.invoiceNumber ?? 0)),
    LedgerEntryType.payment =>
      e.receiptNumber == null
          ? _l10n.ledgerPayment
          : _l10n.ledgerPaymentReceipt(receiptNumber(e.receiptNumber!)),
    LedgerEntryType.saleVoid => _l10n.ledgerSaleVoid(
      saleNumber(e.invoiceNumber ?? 0),
    ),
    LedgerEntryType.reversal => _l10n.ledgerReversal,
  };

  /// A signed amount: "+60.00" or "−25.00", kept left-to-right.
  String signedMoney(int piasters) {
    if (piasters == 0) return money(0);
    final sign = piasters > 0 ? '+' : '−';
    return ltrIsolate('$sign${money(piasters.abs())}');
  }
}
