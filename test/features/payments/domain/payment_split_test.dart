import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:flutter_test/flutter_test.dart';

const _cash = PaymentMethod.cash;
const _wallet = PaymentMethod.wallet;
const _instapay = PaymentMethod.instapay;

Result<PaymentSplit, List<PaymentSplitError>> _create(
  int total,
  List<PaymentPartInput> inputs,
) => PaymentSplit.create(totalPiasters: total, inputs: inputs);

List<PaymentSplitError> _errors(
  Result<PaymentSplit, List<PaymentSplitError>> r,
) => switch (r) {
  Err(:final error) => error,
  Ok() => fail('expected errors'),
};

PaymentSplit _ok(Result<PaymentSplit, List<PaymentSplitError>> r) =>
    switch (r) {
      Ok(:final value) => value,
      Err(:final error) => fail('unexpected $error'),
    };

void main() {
  test('one part with no amount takes the whole total', () {
    final split = _ok(_create(50000, [const PaymentPartInput(method: _cash)]));
    expect(split.parts, [
      const PaymentPart(method: _cash, amountPiasters: 50000),
    ]);
    expect(split.first.method, _cash);
  });

  test('a total of 0 is nothing paid', () {
    expect(_ok(_create(0, [const PaymentPartInput(method: _cash)])).isEmpty,
        isTrue);
    expect(PaymentSplit.single(_cash, 0).isEmpty, isTrue);
  });

  test('300 cash and 200 wallet of 500, with the owner account', () {
    final split = _ok(
      _create(50000, [
        const PaymentPartInput(method: _cash, amountText: '300'),
        const PaymentPartInput(
          method: _wallet,
          amountText: '200',
          accountText: ' 01012345678 ',
        ),
      ]),
    );
    expect(split.total, 50000);
    expect(split.parts.last.accountRef, '01012345678');
  });

  test('over or under by one piaster says by how much', () {
    final inputs = [
      const PaymentPartInput(method: _cash, amountText: '300.01'),
      const PaymentPartInput(method: _wallet, amountText: '200'),
    ];
    expect(_errors(_create(50000, inputs)), [const SumMismatch(1)]);
    expect(_errors(_create(50002, inputs)), [const SumMismatch(-1)]);
  });

  test('a zero part and the same method twice', () {
    expect(
      _errors(
        _create(50000, [
          const PaymentPartInput(method: _cash, amountText: '500'),
          const PaymentPartInput(method: _cash, amountText: '0'),
        ]),
      ),
      [const MethodRepeated(1), const PartAmountZero(1)],
    );
  });

  test('four parts are refused, and card is not offered', () {
    expect(
      _errors(
        _create(400, [
          for (final m in [_cash, _wallet, _instapay, _cash])
            PaymentPartInput(method: m, amountText: '1'),
        ]),
      ),
      [const TooManyParts(4)],
    );
    expect(
      _errors(_create(100, [const PaymentPartInput(method: PaymentMethod.card)])),
      [const MethodRepeated(0)],
    );
  });

  test('an account number on cash, too long, or with bad characters', () {
    expect(
      _errors(
        _create(30000, [
          const PaymentPartInput(
            method: _cash,
            amountText: '100',
            accountText: '010',
          ),
          PaymentPartInput(
            method: _wallet,
            amountText: '100',
            accountText: '1' * 41,
          ),
          const PaymentPartInput(
            method: _instapay,
            amountText: '100',
            accountText: 'حسابي',
          ),
        ]),
      ),
      [
        const AccountNotAllowed(0),
        const AccountTooLong(1),
        const AccountInvalid(2),
      ],
    );
  });

  test('Arabic digits in amounts and accounts', () {
    final split = _ok(
      _create(50000, [
        const PaymentPartInput(method: _cash, amountText: '٣٠٠'),
        const PaymentPartInput(
          method: _instapay,
          amountText: '٢٠٠٫٠٠',
          accountText: '٠١٠٢',
        ),
      ]),
    );
    expect(split.parts.map((p) => p.amountPiasters), [30000, 20000]);
    expect(split.parts.last.accountRef, '0102');
  });

  test('every error is collected at once', () {
    expect(
      _errors(
        _create(100, [
          const PaymentPartInput(method: _cash, amountText: 'x'),
          const PaymentPartInput(
            method: _wallet,
            amountText: '0',
            accountText: '#',
          ),
        ]),
      ),
      [
        const PartAmountInvalid(0),
        const PartAmountZero(1),
        const AccountInvalid(1),
      ],
    );
  });

  test('single drops an account on cash', () {
    expect(
      PaymentSplit.single(_cash, 100, accountRef: '010').first.accountRef,
      isNull,
    );
  });
}
