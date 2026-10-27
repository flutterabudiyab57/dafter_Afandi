import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../../products/domain/product_errors.dart';
import '../../../products/presentation/widgets/unit_label.dart';
import '../../domain/sale.dart';
import '../../domain/sale_errors.dart';
import '../cubits/sale_cubit.dart';

/// Sale messages in the active language and digit style.
extension SaleText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  /// The running-low part of the saved message (FR-028): up to two names
  /// with what is left, then how many more. Null when nothing is low.
  String? lowStockMessage(List<LowStockItem> items) {
    if (items.isEmpty) return null;
    String left(LowStockItem i) => quantity(i.stockMilli, i.unit);
    if (items.length == 1) {
      return _l10n.saleLowStockOne(items.single.name, left(items.single));
    }
    final first = _l10n.saleLowStockItem(items[0].name, left(items[0]));
    final second = _l10n.saleLowStockItem(items[1].name, left(items[1]));
    final more = items.length - 2;
    return more == 0
        ? _l10n.saleLowStockTwo(first, second)
        : _l10n.saleLowStockTwoMore(first, second, more, count(more));
  }

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

  String voidError(VoidError e) => switch (e) {
    InvoiceNotFound() => _l10n.invoiceNotFound,
    AlreadyVoided() => _l10n.invoiceAlreadyVoided,
    VoidReasonInvalid() => _l10n.errorReasonRequired,
  };

  String? saveError(SaleSaveError e) => switch (e) {
    ProductUnavailable(:final name) => _l10n.errorProductUnavailable(name),
    CustomerUnavailable() => _l10n.errorCustomerUnavailable,
    SaleInvalid() || StockShortage() => null,
  };
}
