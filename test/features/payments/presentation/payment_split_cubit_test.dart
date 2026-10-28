import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/payments/presentation/cubits/payment_split_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_payments.dart';

const _cash = PaymentMethod.cash;
const _wallet = PaymentMethod.wallet;
const _instapay = PaymentMethod.instapay;

void main() {
  late FakeAccountSuggestions accounts;

  setUp(
    () => accounts = FakeAccountSuggestions({
      _wallet: ['01012345678', '01198765432'],
    }),
  );

  PaymentSplitCubit build() => PaymentSplitCubit(accounts)..totalChanged(50000);

  List<String> amounts(PaymentSplitCubit c) => [
    for (final p in c.state.parts) p.amountText,
  ];

  test('starts as one cash part taking the whole total', () {
    final c = build();
    expect(c.state.parts, const [PaymentPartInput(method: _cash)]);
    expect(c.state.isSplit, isFalse);
    expect(c.state.differencePiasters, isNull);
    expect(c.state.canSplit, isTrue);
  });

  test('split: part 1 follows the rest until typed in (US6-3)', () async {
    final c = build()..split();
    await Future<void>.delayed(Duration.zero);
    expect(c.state.parts.map((p) => p.method), [_cash, _wallet]);
    expect(amounts(c), ['500', '']);
    expect(c.state.differencePiasters, 0);
    // Suggestions for the new wallet part were loaded.
    expect(c.state.suggestions[_wallet], ['01012345678', '01198765432']);

    c.amountChanged(1, '200');
    expect(amounts(c), ['300', '200']);
    expect(c.state.differencePiasters, 0);

    // The total changes: part 1 still follows.
    c.totalChanged(60000);
    expect(amounts(c), ['400', '200']);

    // Typed in part 1: it stays, and the difference shows.
    c
      ..amountChanged(0, '100')
      ..amountChanged(1, '300');
    expect(amounts(c), ['100', '300']);
    expect(c.state.differencePiasters, -20000);
    c.amountChanged(1, '700');
    expect(c.state.differencePiasters, 20000);
  });

  test('up to three parts, one per method', () {
    final c = build()
      ..split()
      ..split();
    expect(c.state.parts.map((p) => p.method), [_cash, _wallet, _instapay]);
    expect(c.state.canSplit, isFalse);
    c.split();
    expect(c.state.parts, hasLength(3));
  });

  test('removePart gives its amount back to part 1', () {
    final c = build()
      ..split()
      ..split()
      ..amountChanged(0, '200')
      ..amountChanged(1, '200')
      ..amountChanged(2, '100')
      ..removePart(2);
    expect(amounts(c), ['300', '200']);
    // Back to one part: it takes the whole total again.
    c.removePart(1);
    expect(c.state.parts, const [PaymentPartInput(method: _cash)]);
    // Part 1 cannot be removed.
    c.removePart(0);
    expect(c.state.parts, hasLength(1));
  });

  test('cash drops the account number; wallet keeps it', () async {
    final c = build()
      ..methodChanged(0, _wallet)
      ..accountChanged(0, '01012345678');
    expect(c.state.parts.single.accountText, '01012345678');
    c.methodChanged(0, _instapay);
    expect(c.state.parts.single.accountText, '01012345678');
    c.methodChanged(0, _cash);
    expect(c.state.parts.single.accountText, '');
  });

  test('suggestions are per method, none for cash', () async {
    final c = build()..methodChanged(0, _instapay);
    await Future<void>.delayed(Duration.zero);
    expect(c.state.suggestions[_instapay], isEmpty);
    expect(c.state.suggestions.containsKey(_cash), isFalse);
  });

  blocTest<PaymentSplitCubit, PaymentSplitState>(
    'reset: one cash part again, total kept',
    build: build,
    act: (c) => c
      ..split()
      ..reset(),
    verify: (c) {
      expect(c.state.parts, const [PaymentPartInput(method: _cash)]);
      expect(c.state.totalPiasters, 50000);
      expect(c.state.autoFirst, isFalse);
    },
  );

  test('the typed parts validate against the total (US6-5, 6)', () {
    final c = build()
      ..split()
      ..amountChanged(0, '400')
      ..amountChanged(1, '200');
    final r = PaymentSplit.create(totalPiasters: 50000, inputs: c.state.parts);
    expect((r as Err<PaymentSplit, List<PaymentSplitError>>).error, const [
      SumMismatch(10000),
    ]);
  });
}
