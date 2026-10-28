import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../../products/domain/product_errors.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/purchase_errors.dart';
import '../cubits/purchase_cubit.dart';

/// Purchase messages in the active language and digit style.
extension PurchaseText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  /// A typed number that could not be read, by field.
  String purchaseInputProblem(PurchaseField field, PurchaseInputProblem p) {
    final quantity = field == PurchaseField.qty;
    return switch (p) {
      PurchaseInputProblem.required =>
        quantity ? _l10n.errorQuantityRequired : _l10n.errorPriceRequired,
      PurchaseInputProblem.notWhole => _l10n.errorQuantityNotWhole,
      PurchaseInputProblem.invalid =>
        quantity ? _l10n.errorQuantityInvalid : _l10n.errorPriceInvalid,
      PurchaseInputProblem.tooLarge =>
        quantity
            ? _l10n.errorQuantityTooLarge(
                digits(
                  formatScaledDecimal(
                    maxQuantityMilli,
                    scale: 3,
                    minDecimals: 0,
                  ),
                ),
              )
            : _l10n.errorPriceTooLarge(money(maxPricePiasters)),
    };
  }

  /// A rule the purchase breaks, or null for rules shown on their line or
  /// field.
  String? purchaseError(PurchaseError e) => switch (e) {
    PurchaseNoLines() => _l10n.errorSaleNoLines,
    PurchasePaidTooLarge() => _l10n.errorPaidTooLarge,
    CreditNeedsSupplier() => _l10n.errorCreditNeedsSupplier,
    PurchaseDateInFuture() => _l10n.errorPurchaseDateInFuture,
    PurchaseNoteTooLong() => _l10n.errorNoteTooLong(
      count(maxPurchaseNoteLength),
    ),
    // The parts' own errors show on the payment field.
    PurchasePaymentInvalid() => _l10n.errorPaymentDetails,
    PurchaseInvoiceDiscountTooLarge() ||
    PurchaseQuantityInvalid() ||
    PurchaseCostInvalid() ||
    PurchaseLineDiscountTooLarge() ||
    SupplierRefTooLong() ||
    PurchaseDuplicateLine() => null,
  };

  String? purchaseSaveError(PurchaseSaveError e) => switch (e) {
    PurchaseProductUnavailable(:final name) =>
      _l10n.errorPurchaseProductUnavailable(name),
    SupplierUnavailable() => _l10n.errorSupplierUnavailable,
    PurchaseInvalid() => null,
  };

  /// A refusal to void, other than the shortage, which is asked about.
  String? purchaseVoidError(PurchaseVoidError e) => switch (e) {
    PurchaseNotFound() => _l10n.purchaseNotFound,
    PurchaseAlreadyVoided() => _l10n.purchaseAlreadyVoided,
    PurchaseVoidReasonInvalid() => _l10n.errorReasonRequired,
    VoidStockShortage() => null,
  };
}
