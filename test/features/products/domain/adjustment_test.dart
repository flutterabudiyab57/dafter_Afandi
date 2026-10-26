import 'package:daftar_afandi/core/utils/quantity.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/products/domain/adjustment.dart';
import 'package:daftar_afandi/features/products/domain/product_errors.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:flutter_test/flutter_test.dart';

typedef R = Result<AdjustmentRequest, List<AdjustmentError>>;

AdjustmentRequest ok(R r) =>
    (r as Ok<AdjustmentRequest, List<AdjustmentError>>).value;

List<AdjustmentError> errs(R r) =>
    (r as Err<AdjustmentRequest, List<AdjustmentError>>).error;

void main() {
  const piece = UnitType.piece;

  group('damage', () {
    test('removes a positive quantity; the note is optional', () {
      final r = ok(AdjustmentRequest.damage(qtyText: '2', unit: piece));
      expect(r.kind, AdjustmentKind.damage);
      expect(r.amountMilli, 2000);
      expect(r.note, isNull);
      expect(r.deltaAgainst(10000), const Ok<int, AdjustmentError>(-2000));
    });

    test('empty or zero quantity is required', () {
      expect(errs(AdjustmentRequest.damage(qtyText: '', unit: piece)), [
        const AdjustmentQuantityRequired(),
      ]);
      expect(errs(AdjustmentRequest.damage(qtyText: '0', unit: piece)), [
        const AdjustmentQuantityRequired(),
      ]);
    });

    test('may remove exactly the stock on hand, not one milli more', () {
      final kg = ok(AdjustmentRequest.damage(qtyText: '3', unit: UnitType.kg));
      expect(kg.deltaAgainst(3000), const Ok<int, AdjustmentError>(-3000));
      expect(
        kg.deltaAgainst(2999),
        const Err<int, AdjustmentError>(ExceedsStock(2999)),
      );
    });

    test('nothing can be removed from zero or negative stock', () {
      final r = ok(AdjustmentRequest.damage(qtyText: '1', unit: piece));
      expect(
        r.deltaAgainst(0),
        const Err<int, AdjustmentError>(ExceedsStock(0)),
      );
      expect(
        r.deltaAgainst(-2000),
        const Err<int, AdjustmentError>(ExceedsStock(-2000)),
      );
    });
  });

  group('count', () {
    test('records counted minus on hand', () {
      final r = ok(AdjustmentRequest.count(countedText: '8', unit: piece));
      expect(r.deltaAgainst(10000), const Ok<int, AdjustmentError>(-2000));
      expect(r.deltaAgainst(5000), const Ok<int, AdjustmentError>(3000));
    });

    test('brings negative stock back to the counted quantity', () {
      final r = ok(AdjustmentRequest.count(countedText: '0', unit: piece));
      expect(r.deltaAgainst(-4000), const Ok<int, AdjustmentError>(4000));
    });

    test('equal to the stock records nothing', () {
      final r = ok(AdjustmentRequest.count(countedText: '9', unit: piece));
      expect(
        r.deltaAgainst(9000),
        const Err<int, AdjustmentError>(AlreadyMatches()),
      );
    });

    test('zero is allowed, empty is not, negative is invalid', () {
      expect(
        ok(AdjustmentRequest.count(countedText: '0', unit: piece)).amountMilli,
        0,
      );
      expect(errs(AdjustmentRequest.count(countedText: ' ', unit: piece)), [
        const AdjustmentQuantityRequired(),
      ]);
      expect(errs(AdjustmentRequest.count(countedText: '-1', unit: piece)), [
        const AdjustmentQuantityInvalid(),
      ]);
    });
  });

  group('other', () {
    test('adds or removes and needs a note', () {
      final add = ok(
        AdjustmentRequest.other(
          qtyText: '1',
          unit: piece,
          add: true,
          note: ' found ',
        ),
      );
      expect(add.note, 'found');
      expect(add.deltaAgainst(0), const Ok<int, AdjustmentError>(1000));

      final remove = ok(
        AdjustmentRequest.other(
          qtyText: '1',
          unit: piece,
          add: false,
          note: 'gift',
        ),
      );
      expect(remove.deltaAgainst(1000), const Ok<int, AdjustmentError>(-1000));
      expect(
        remove.deltaAgainst(0),
        const Err<int, AdjustmentError>(ExceedsStock(0)),
      );
    });

    test('an empty note is required', () {
      expect(
        errs(
          AdjustmentRequest.other(
            qtyText: '1',
            unit: piece,
            add: true,
            note: '  ',
          ),
        ),
        [const AdjustmentNoteRequired()],
      );
    });
  });

  group('limits', () {
    test('a fraction of a piece is not whole', () {
      expect(errs(AdjustmentRequest.damage(qtyText: '2.5', unit: piece)), [
        const AdjustmentQuantityNotWhole(),
      ]);
      expect(
        ok(AdjustmentRequest.count(countedText: '2.5', unit: UnitType.liter))
            .amountMilli,
        2500,
      );
    });

    test('more than 1,000,000 units is too large', () {
      expect(
        ok(AdjustmentRequest.damage(qtyText: '1000000', unit: piece))
            .amountMilli,
        maxQuantityMilli,
      );
      expect(errs(AdjustmentRequest.damage(qtyText: '1000001', unit: piece)), [
        const AdjustmentQuantityTooLarge(maxQuantityMilli),
      ]);
    });

    test('the note is 1–200 code points', () {
      expect(
        ok(AdjustmentRequest.damage(qtyText: '1', unit: piece, note: 'ن' * 200))
            .note,
        hasLength(200),
      );
      expect(
        errs(
          AdjustmentRequest.damage(qtyText: '1', unit: piece, note: 'ن' * 201),
        ),
        [const AdjustmentNoteTooLong(200)],
      );
    });

    test('collects quantity and note errors together', () {
      expect(
        errs(
          AdjustmentRequest.other(
            qtyText: 'x',
            unit: piece,
            add: false,
            note: '',
          ),
        ),
        [const AdjustmentQuantityInvalid(), const AdjustmentNoteRequired()],
      );
    });
  });
}
