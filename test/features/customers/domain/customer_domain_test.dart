import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/customer.dart';
import 'package:daftar_afandi/features/customers/domain/customer_draft.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:flutter_test/flutter_test.dart';

CustomerDraft ok(Result<CustomerDraft, List<CustomerFieldError>> r) =>
    (r as Ok<CustomerDraft, List<CustomerFieldError>>).value;

List<CustomerFieldError> errs(Result<Object?, List<CustomerFieldError>> r) =>
    (r as Err<Object?, List<CustomerFieldError>>).error;

void main() {
  group('CustomerDraft.create', () {
    test('name is trimmed and 1–100 code points', () {
      expect(ok(CustomerDraft.create(name: '  أحمد  ')).name, 'أحمد');
      expect(errs(CustomerDraft.create(name: '   ')), [
        const CustomerFieldError(CustomerField.name, CustomerProblem.required),
      ]);
      expect(ok(CustomerDraft.create(name: '😀' * 100)).name.runes.length, 100);
      expect(errs(CustomerDraft.create(name: 'ب' * 101)), [
        const CustomerFieldError(
          CustomerField.name,
          CustomerProblem.tooLong,
          max: 100,
        ),
      ]);
    });

    test('phone uses the shop phone rule; Arabic digits fold', () {
      expect(
        ok(CustomerDraft.create(name: 'م', phone: '٠١٠ ١٢٣٤-٥٦٧٨')).phone,
        '01012345678',
      );
      expect(ok(CustomerDraft.create(name: 'م')).phone, isNull);
      expect(
        errs(CustomerDraft.create(name: 'م', phone: '12ab')).single.problem,
        CustomerProblem.invalid,
      );
      expect(
        errs(CustomerDraft.create(name: 'م', phone: '123')).single.problem,
        CustomerProblem.tooShort,
      );
      expect(
        errs(CustomerDraft.create(name: 'م', phone: '1' * 16)).single.problem,
        CustomerProblem.tooLong,
      );
    });

    test('address and note: empty is null, 200 max', () {
      final d = ok(CustomerDraft.create(name: 'م', address: '  ', note: 'x'));
      expect(d.address, isNull);
      expect(d.note, 'x');
      expect(
        ok(CustomerDraft.create(name: 'م', address: 'a' * 200)).address,
        hasLength(200),
      );
      expect(errs(CustomerDraft.create(name: 'م', note: 'a' * 201)), [
        const CustomerFieldError(
          CustomerField.note,
          CustomerProblem.tooLong,
          max: 200,
        ),
      ]);
    });

    test('opening balance: signed by direction, empty or 0 means none', () {
      expect(
        ok(CustomerDraft.create(name: 'م', openingText: '50'))
            .openingBalancePiasters,
        5000,
      );
      expect(
        ok(
          CustomerDraft.create(
            name: 'م',
            openingText: '٢٠٫٥٠',
            openingInFavour: true,
          ),
        ).openingBalancePiasters,
        -2050,
      );
      expect(ok(CustomerDraft.create(name: 'م')).openingBalancePiasters, 0);
      expect(
        ok(CustomerDraft.create(name: 'م', openingText: '0'))
            .openingBalancePiasters,
        0,
      );
      expect(
        errs(CustomerDraft.create(name: 'م', openingText: '1.234')).single,
        const CustomerFieldError(
          CustomerField.opening,
          CustomerProblem.invalid,
        ),
      );
      expect(
        ok(CustomerDraft.create(name: 'م', openingText: '10000000'))
            .openingBalancePiasters,
        maxAmountPiasters,
      );
      expect(
        errs(CustomerDraft.create(name: 'م', openingText: '10000000.01'))
            .single
            .problem,
        CustomerProblem.tooLarge,
      );
    });

    test('collects every error at once', () {
      expect(
        errs(CustomerDraft.create(name: '', phone: '1', openingText: 'x'))
            .map((e) => e.field),
        [CustomerField.name, CustomerField.phone, CustomerField.opening],
      );
    });
  });

  group('PaymentRequest.create', () {
    test('amount above 0, 2 decimals, at most 10M', () {
      final r = PaymentRequest.create(
        amountText: '25',
        method: PaymentMethod.wallet,
        note: '  ',
      );
      expect(
        (r as Ok<PaymentRequest, List<CustomerFieldError>>).value,
        const PaymentRequest(
          amountPiasters: 2500,
          method: PaymentMethod.wallet,
        ),
      );
      for (final bad in ['', '0', '0.00', '1.234', '-5', 'abc']) {
        expect(
          errs(
            PaymentRequest.create(amountText: bad, method: PaymentMethod.cash),
          ).single.field,
          CustomerField.amount,
          reason: bad,
        );
      }
      expect(
        errs(
          PaymentRequest.create(
            amountText: '10000000.01',
            method: PaymentMethod.cash,
          ),
        ).single.problem,
        CustomerProblem.tooLarge,
      );
    });

    test('card is stored but not offered', () {
      expect(offeredPaymentMethods, isNot(contains(PaymentMethod.card)));
    });
  });

  test('validateReason: trimmed, 1–200', () {
    expect(
      validateReason('  خطأ  '),
      const Ok<String, CustomerFieldError>('خطأ'),
    );
    expect(validateReason('  '), isA<Err<String, CustomerFieldError>>());
    expect(validateReason('a' * 200), isA<Ok<String, CustomerFieldError>>());
    expect(
      validateReason('a' * 201),
      const Err<String, CustomerFieldError>(
        CustomerFieldError(
          CustomerField.reason,
          CustomerProblem.tooLong,
          max: 200,
        ),
      ),
    );
  });

  test(
    'a ledger row is cancellable only as an uncancelled receipt payment',
    () {
      LedgerEntry entry({
        LedgerEntryType type = LedgerEntryType.payment,
        int? receipt = 1,
        bool reversed = false,
      }) => LedgerEntry(
        id: 'e',
        type: type,
        amountPiasters: -100,
        runningBalancePiasters: 0,
        at: DateTime.utc(2026),
        rowOrder: 1,
        receiptNumber: receipt,
        reversed: reversed,
      );
      expect(entry().cancellable, isTrue);
      expect(entry(receipt: null).cancellable, isFalse);
      expect(entry(reversed: true).cancellable, isFalse);
      expect(entry(type: LedgerEntryType.sale).cancellable, isFalse);
    },
  );

  test('CustomerQuery folds Arabic spelling', () {
    expect(const CustomerQuery(text: 'أحمد').normalizedText, 'احمد');
    expect(
      const CustomerSummary(
        customer: Customer(id: 'c', name: 'n'),
        balancePiasters: 1,
      ).owes,
      isTrue,
    );
  });
}
