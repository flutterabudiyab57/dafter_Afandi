import 'package:equatable/equatable.dart';

import '../../../core/utils/quantity.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/text_length.dart';
import 'product_errors.dart';
import 'quantity_input.dart';
import 'stock_entry.dart';

/// A validated stock adjustment for one product (data-model.md).
///
/// [amountMilli] is the quantity to remove or add, or for a count the
/// quantity counted on the shelf.
final class AdjustmentRequest extends Equatable {
  const AdjustmentRequest._(this.kind, this.amountMilli, this.add, this.note);

  final AdjustmentKind kind;
  final int amountMilli;

  /// For [AdjustmentKind.other]: true adds stock, false removes it.
  final bool add;
  final String? note;

  /// Removes a damaged quantity (> 0). The note is optional.
  static Result<AdjustmentRequest, List<AdjustmentError>> damage({
    required String qtyText,
    required UnitType unit,
    String note = '',
  }) => _build(AdjustmentKind.damage, qtyText, unit, false, note);

  /// Sets stock to the counted quantity (≥ 0). The note is optional.
  static Result<AdjustmentRequest, List<AdjustmentError>> count({
    required String countedText,
    required UnitType unit,
    String note = '',
  }) => _build(AdjustmentKind.count, countedText, unit, false, note);

  /// Adds or removes a quantity (> 0). The note is required.
  static Result<AdjustmentRequest, List<AdjustmentError>> other({
    required String qtyText,
    required UnitType unit,
    required bool add,
    required String note,
  }) => _build(AdjustmentKind.other, qtyText, unit, add, note);

  static Result<AdjustmentRequest, List<AdjustmentError>> _build(
    AdjustmentKind kind,
    String text,
    UnitType unit,
    bool add,
    String rawNote,
  ) {
    final errors = <AdjustmentError>[];
    final zeroAllowed = kind == AdjustmentKind.count;

    int? amount;
    switch (readQuantity(text, unit)) {
      case NumberEmpty():
        errors.add(const AdjustmentQuantityRequired());
      case NumberValue(:final value):
        if (value == 0 && !zeroAllowed) {
          errors.add(const AdjustmentQuantityRequired());
        } else {
          amount = value;
        }
      case NumberProblem(kind: NumberProblemKind.invalid):
        errors.add(const AdjustmentQuantityInvalid());
      case NumberProblem(kind: NumberProblemKind.notWhole):
        errors.add(const AdjustmentQuantityNotWhole());
      case NumberProblem(kind: NumberProblemKind.tooLarge):
        errors.add(const AdjustmentQuantityTooLarge(maxQuantityMilli));
    }

    final note = rawNote.trim();
    final noteLength = codePointLength(note);
    if (noteLength == 0 && kind == AdjustmentKind.other) {
      errors.add(const AdjustmentNoteRequired());
    } else if (noteLength > maxNoteLength) {
      errors.add(const AdjustmentNoteTooLong(maxNoteLength));
    }

    if (errors.isNotEmpty) return Err(errors);
    return Ok(
      AdjustmentRequest._(kind, amount!, add, note.isEmpty ? null : note),
    );
  }

  /// The signed change to record against [onHandMilli] (FR-013, FR-014):
  /// a removal may not exceed the stock on hand, and a count equal to it
  /// records nothing.
  Result<int, AdjustmentError> deltaAgainst(int onHandMilli) {
    final int delta = switch (kind) {
      AdjustmentKind.count => amountMilli - onHandMilli,
      AdjustmentKind.damage => -amountMilli,
      AdjustmentKind.other => add ? amountMilli : -amountMilli,
    };
    if (delta == 0) return const Err(AlreadyMatches());
    if (kind != AdjustmentKind.count &&
        delta < 0 &&
        amountMilli > onHandMilli) {
      return Err(ExceedsStock(onHandMilli));
    }
    return Ok(delta);
  }

  @override
  List<Object?> get props => [kind, amountMilli, add, note];
}

/// What an adjustment did.
final class AdjustmentResult extends Equatable {
  const AdjustmentResult({
    required this.deltaMilli,
    required this.newStockMilli,
  });

  final int deltaMilli;
  final int newStockMilli;

  @override
  List<Object?> get props => [deltaMilli, newStockMilli];
}
