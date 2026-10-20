import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/widgets/digit_style_scope.dart';
import '../../domain/product_errors.dart';
import 'unit_label.dart';

/// Messages for products errors, in the active language and digit style.
/// Limits are formatted before they reach the ARB string.
extension ProductErrorText on BuildContext {
  AppLocalizations get _l10n => AppLocalizations.of(this);

  String _limitMilli(int milli) =>
      digits(formatScaledDecimal(milli, scale: 3, minDecimals: 0));

  String fieldError(ProductFieldError error) => switch (error) {
    NameRequired() => _l10n.errorNameRequired,
    NameTooLong(:final max) => _l10n.errorNameTooLong(count(max)),
    PriceRequired() => _l10n.errorPriceRequired,
    PriceInvalid() => _l10n.errorPriceInvalid,
    PriceTooLarge(:final maxPiasters) => _l10n.errorPriceTooLarge(
      money(maxPiasters),
    ),
    QuantityRequired() => _l10n.errorQuantityRequired,
    QuantityInvalid() => _l10n.errorQuantityInvalid,
    QuantityNotWhole() => _l10n.errorQuantityNotWhole,
    QuantityTooLarge(:final maxMilli) => _l10n.errorQuantityTooLarge(
      _limitMilli(maxMilli),
    ),
    OpeningCostRequired() => _l10n.errorOpeningCostRequired,
    BarcodeTooLong(:final max) => _l10n.errorCodeTooLong(count(max)),
    SkuTooLong(:final max) => _l10n.errorCodeTooLong(count(max)),
  };

  /// Null for errors that have no message of their own (they are handled
  /// by the screen, e.g. a missing product).
  String? saveError(ProductSaveError error) => switch (error) {
    BarcodeTaken(:final otherProductName) => _l10n.errorBarcodeTaken(
      otherProductName,
    ),
    UnitLocked() => _l10n.productUnitLockedNote,
    OpeningNotAllowed() || ProductNotFound() => null,
  };

  String restoreError(RestoreError error) => switch (error) {
    RestoreBarcodeTaken(:final otherProductName) =>
      _l10n.errorRestoreBarcodeTaken(otherProductName),
  };

  String categoryError(CategoryError error) => switch (error) {
    CategoryNameRequired() => _l10n.errorCategoryNameRequired,
    CategoryNameTooLong(:final max) => _l10n.errorCategoryNameTooLong(
      count(max),
    ),
    CategoryDuplicate() => _l10n.errorCategoryDuplicate,
  };

  /// [unit] formats the on-hand quantity of [ExceedsStock].
  String adjustmentError(AdjustmentError error, UnitType unit) =>
      switch (error) {
        AdjustmentQuantityRequired() => _l10n.errorQuantityRequired,
        AdjustmentQuantityInvalid() => _l10n.errorQuantityInvalid,
        AdjustmentQuantityNotWhole() => _l10n.errorQuantityNotWhole,
        AdjustmentQuantityTooLarge(:final maxMilli) =>
          _l10n.errorQuantityTooLarge(_limitMilli(maxMilli)),
        AdjustmentNoteRequired() => _l10n.adjustNoteRequired,
        AdjustmentNoteTooLong(:final max) => _l10n.errorNoteTooLong(count(max)),
        ExceedsStock(:final onHandMilli) => _l10n.adjustExceedsStock(
          quantity(onHandMilli, unit),
        ),
        AlreadyMatches() => _l10n.adjustAlreadyMatches,
      };
}
