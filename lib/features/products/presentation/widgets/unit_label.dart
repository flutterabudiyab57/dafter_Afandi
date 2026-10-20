import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/app_locale_code.dart';
import '../../../../core/utils/digits.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/widgets/digit_style_scope.dart';

/// The short unit label shown after a quantity, e.g. "قطعة" or "kg"
/// (research R18). No plural forms.
String unitShort(AppLocalizations l10n, UnitType unit) => switch (unit) {
  UnitType.piece => l10n.unitPieceShort,
  UnitType.kg => l10n.unitKgShort,
  UnitType.liter => l10n.unitLiterShort,
  UnitType.meter => l10n.unitMeterShort,
};

/// The full unit name, for the form's unit options.
String unitFull(AppLocalizations l10n, UnitType unit) => switch (unit) {
  UnitType.piece => l10n.unitPiece,
  UnitType.kg => l10n.unitKg,
  UnitType.liter => l10n.unitLiter,
  UnitType.meter => l10n.unitMeter,
};

/// Money and quantities in the active language and digit style (FR-019).
/// Formatting goes only through `core/utils` (constitution).
extension ProductFormatting on BuildContext {
  AppLocaleCode get _localeCode =>
      Localizations.localeOf(this).languageCode == 'ar'
      ? AppLocaleCode.ar
      : AppLocaleCode.en;

  /// E.g. "٧٫٥٠ ج.م" or "EGP 7.50".
  String money(int piasters) => formatPiasters(
    piasters,
    locale: _localeCode,
    digits: DigitStyleScope.of(this),
  );

  /// A plain number in the digit style, e.g. "٢٠٠" for limits in messages.
  String count(int value) => digits('$value');

  /// E.g. "١٢ قطعة" or "2.375 kg". A negative number is kept left-to-right
  /// so its minus sign stays in front.
  String quantity(int milli, UnitType unit) {
    final number = formatQuantityMilli(
      milli,
      unit,
      locale: _localeCode,
      digits: DigitStyleScope.of(this),
    );
    final shown = milli < 0 ? ltrIsolate(number) : number;
    return '$shown ${unitShort(AppLocalizations.of(this), unit)}';
  }

  /// Like [quantity] but with a "+" on additions, for history rows.
  String signedQuantity(int milli, UnitType unit) {
    if (milli <= 0) return quantity(milli, unit);
    final number = formatQuantityMilli(
      milli,
      unit,
      locale: _localeCode,
      digits: DigitStyleScope.of(this),
    );
    return '${ltrIsolate('+$number')} ${unitShort(AppLocalizations.of(this), unit)}';
  }

  /// A UTC time as local "2026/10/20 14:05", kept left-to-right.
  String dateTime(DateTime utc) {
    final t = utc.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return ltrIsolate(
      digits(
        '${t.year}/${two(t.month)}/${two(t.day)} ${two(t.hour)}:${two(t.minute)}',
      ),
    );
  }
}
