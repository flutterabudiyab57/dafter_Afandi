import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_draft.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_errors.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 10, 20);

  Result<ExpenseDraft, List<ExpenseFieldError>> make({
    String? categoryId = 'rent',
    String amount = '100',
    DateTime? spentOn,
    List<PaymentPartInput>? parts,
    String note = '',
  }) => parts == null
      ? ExpenseDraft.create(
          categoryId: categoryId,
          amountText: amount,
          spentOn: spentOn ?? today,
          today: today,
          note: note,
        )
      : ExpenseDraft.create(
          categoryId: categoryId,
          amountText: amount,
          spentOn: spentOn ?? today,
          today: today,
          parts: parts,
          note: note,
        );

  List<ExpenseFieldError> errors(
    Result<ExpenseDraft, List<ExpenseFieldError>> r,
  ) => switch (r) {
    Ok() => const [],
    Err(:final error) => error,
  };

  ExpenseDraft draft(Result<ExpenseDraft, List<ExpenseFieldError>> r) =>
      (r as Ok<ExpenseDraft, List<ExpenseFieldError>>).value;

  test('defaults to one cash part for the whole amount', () {
    final d = draft(make(amount: '١٬٥٠٠٫٥'));
    expect(d.amountPiasters, 150050);
    expect(d.split, PaymentSplit.single(PaymentMethod.cash, 150050));
    expect(d.note, isNull);
  });

  test('a category is required (US3-2)', () {
    expect(errors(make(categoryId: null)), [const ExpenseCategoryRequired()]);
  });

  group('amount', () {
    test('empty, zero, more than two decimals and too large are refused '
        '(US3-2)', () {
      expect(errors(make(amount: ' ')), [const ExpenseAmountRequired()]);
      expect(errors(make(amount: '0')), [const ExpenseAmountInvalid()]);
      expect(errors(make(amount: '1.234')), [const ExpenseAmountInvalid()]);
      expect(errors(make(amount: 'abc')), [const ExpenseAmountInvalid()]);
      expect(errors(make(amount: '10000000.01')), [
        const ExpenseAmountTooLarge(),
      ]);
    });

    test('the limits are allowed', () {
      expect(draft(make(amount: '0.01')).amountPiasters, 1);
      expect(draft(make(amount: '10000000')).amountPiasters, 1000000000);
    });
  });

  test('today is allowed and tomorrow refused; the time is dropped', () {
    expect(draft(make(spentOn: DateTime(2026, 10, 20, 23, 59))).spentOn, today);
    expect(draft(make(spentOn: DateTime(2025))).spentOn, DateTime(2025));
    expect(errors(make(spentOn: DateTime(2026, 10, 21))), [
      const ExpenseDateInFuture(),
    ]);
  });

  test('the note is trimmed, up to 200 code points', () {
    expect(draft(make(note: '  ورق  ')).note, 'ورق');
    expect(draft(make(note: 'ن' * 200)).note, hasLength(200));
    expect(errors(make(note: 'ن' * 201)), [const ExpenseNoteTooLong()]);
  });

  test('a wallet part keeps the owner account; split errors are kept', () {
    final d = draft(
      make(
        parts: const [
          PaymentPartInput(
            method: PaymentMethod.wallet,
            accountText: '01001234567',
          ),
        ],
      ),
    );
    expect(d.split.first.method, PaymentMethod.wallet);
    expect(d.split.first.accountRef, '01001234567');

    expect(
      errors(
        make(
          parts: const [
            PaymentPartInput(method: PaymentMethod.cash, accountText: '0100'),
          ],
        ),
      ),
      [const ExpenseSplitInvalid(AccountNotAllowed(0))],
    );
  });

  test('every error is collected at once', () {
    expect(
      errors(
        make(
          categoryId: null,
          amount: '',
          spentOn: DateTime(2027),
          note: 'ن' * 201,
        ),
      ),
      [
        const ExpenseCategoryRequired(),
        const ExpenseAmountRequired(),
        const ExpenseDateInFuture(),
        const ExpenseNoteTooLong(),
      ],
    );
  });

  test('category names are 1 to 50 code points, trimmed', () {
    expect(
      validateExpenseCategoryName('  '),
      const ExpenseCategoryNameRequired(),
    );
    expect(
      validateExpenseCategoryName('ن' * 51),
      const ExpenseCategoryNameTooLong(),
    );
    expect(validateExpenseCategoryName(' ${'ن' * 50} '), isNull);
  });
}
