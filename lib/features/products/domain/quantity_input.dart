import '../../../core/utils/decimal_text.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/quantity.dart';
import 'product_errors.dart';

/// The outcome of reading one number field typed by the user.
sealed class NumberInput {
  const NumberInput();
}

/// The field is empty (only whitespace).
final class NumberEmpty extends NumberInput {
  const NumberEmpty();
}

final class NumberValue extends NumberInput {
  const NumberValue(this.value);

  final int value;
}

final class NumberProblem extends NumberInput {
  const NumberProblem(this.kind);

  final NumberProblemKind kind;
}

enum NumberProblemKind { invalid, notWhole, tooLarge }

/// Reads a quantity in milli-units for [unit] (research R8): 0 to
/// [maxQuantityMilli], whole for pieces, at most 3 decimals otherwise.
NumberInput readQuantity(String text, UnitType unit) {
  if (text.trim().isEmpty) return const NumberEmpty();
  // Parse with 3 decimals for every unit, so "1.5 pieces" is told apart from
  // text that is not a number at all.
  final milli = parseScaledDecimal(text, scale: 3, maxDecimals: 3);
  if (milli == null) return const NumberProblem(NumberProblemKind.invalid);
  if (!unit.allowsFraction && milli % milliPerUnit != 0) {
    return const NumberProblem(NumberProblemKind.notWhole);
  }
  if (milli > maxQuantityMilli) {
    return const NumberProblem(NumberProblemKind.tooLarge);
  }
  return NumberValue(milli);
}

/// Reads an amount in piasters: 0 to [maxPricePiasters], at most 2 decimals.
NumberInput readMoney(String text) {
  if (text.trim().isEmpty) return const NumberEmpty();
  final piasters = tryParsePiasters(text);
  if (piasters == null) return const NumberProblem(NumberProblemKind.invalid);
  if (piasters > maxPricePiasters) {
    return const NumberProblem(NumberProblemKind.tooLarge);
  }
  return NumberValue(piasters);
}
