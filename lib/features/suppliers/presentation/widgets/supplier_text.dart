import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/doc_number.dart';
import '../../../customers/domain/customer_errors.dart';
import '../../../customers/presentation/widgets/customer_text.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/supplier_entry.dart';
import '../../domain/supplier_errors.dart';

/// Supplier messages, labels and amounts in the active language and digit
/// style.
extension SupplierText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  /// The customer rules, with the supplier's own "name required".
  String supplierFieldError(CustomerFieldError e) =>
      e.field == CustomerField.name && e.problem == CustomerProblem.required
      ? _l10n.errorSupplierNameRequired
      : customerFieldError(e);

  String supplierPaymentError(SupplierPaymentError e) => switch (e) {
    PaymentSupplierNotFound() => _l10n.supplierNotFound,
    PaymentSupplierArchived() => _l10n.errorSupplierArchived,
    SupplierPaymentNotCancellable() => _l10n.supplierPaymentNotCancellable,
    SupplierPaymentAlreadyCancelled() => _l10n.paymentAlreadyCancelled,
    SupplierPaymentReasonInvalid() => _l10n.errorReasonRequired,
  };

  /// "Shop owes 60.00", "Owes the shop 20.00" or "No balance".
  String supplierBalance(int piasters) => piasters > 0
      ? _l10n.supplierBalanceOwed(money(piasters))
      : piasters < 0
      ? _l10n.supplierBalanceInShopFavour(money(-piasters))
      : _l10n.balanceZero;

  /// "P-000012" in the digit style, kept left-to-right.
  String purchaseNumber(int n) => docNumber(purchaseNumberPrefix, n);

  String supplierPaymentNumber(int n) =>
      docNumber(supplierPaymentNumberPrefix, n);

  /// The statement row's title.
  String supplierLedgerTitle(SupplierEntry e) => switch (e.type) {
    SupplierEntryType.openingBalance => _l10n.ledgerOpening,
    SupplierEntryType.purchase => _l10n.ledgerPurchase(
      purchaseNumber(e.purchaseNumber ?? 0),
    ),
    SupplierEntryType.payment =>
      e.paymentNumber == null
          ? _l10n.ledgerPayment
          : _l10n.ledgerPaymentReceipt(supplierPaymentNumber(e.paymentNumber!)),
    SupplierEntryType.purchaseVoid => _l10n.ledgerPurchaseVoid(
      purchaseNumber(e.purchaseNumber ?? 0),
    ),
    SupplierEntryType.reversal => _l10n.ledgerReversal,
  };
}
