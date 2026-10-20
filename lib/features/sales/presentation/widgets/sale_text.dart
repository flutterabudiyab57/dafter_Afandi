import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../../products/domain/product_errors.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/sale_errors.dart';
import '../cubits/sale_cubit.dart';

/// Sale messages in the active language and digit style.
extension SaleText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  /// A typed number that could not be read, by field.
  String inputProblem(SaleField field, SaleInputProblem p) {
    final quantity = field == SaleField.qty;
    return switch (p) {
      SaleInputProblem.required =>
        quantity ? _l10n.errorQuantityRequired : _l10n.errorPriceRequired,
      SaleInputProblem.notWhole => _l10n.errorQuantityNotWhole,
      SaleInputProblem.invalid =>
        quantity ? _l10n.errorQuantityInvalid : _l10n.errorPriceInvalid,
      SaleInputProblem.tooLarge =>
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

  /// A rule the sale breaks, or null for line rules shown on their line.
  String? saleError(SaleError e) => switch (e) {
    NoLines() => _l10n.errorSaleNoLines,
    CreditNeedsCustomer() => _l10n.errorCreditNeedsCustomer,
    PaidTooLarge() => _l10n.errorPaidTooLarge,
    InvoiceDiscountTooLarge() => _l10n.errorInvoiceDiscountTooLarge,
    LineDiscountTooLarge() => _l10n.errorLineDiscountTooLarge,
    LineQuantityInvalid() => _l10n.errorQuantityInvalid,
    LinePriceInvalid() => _l10n.errorPriceInvalid,
    DuplicateLine() => null,
  };

  String? saveError(SaleSaveError e) => switch (e) {
    ProductUnavailable(:final name) => _l10n.errorProductUnavailable(name),
    CustomerUnavailable() => _l10n.errorCustomerUnavailable,
    SaleInvalid() || StockShortage() => null,
  };
}
