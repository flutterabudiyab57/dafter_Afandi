import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_draft.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:flutter_test/flutter_test.dart';

typedef R = Result<SupplierDraft, List<CustomerFieldError>>;

SupplierDraft ok(R r) =>
    (r as Ok<SupplierDraft, List<CustomerFieldError>>).value;

List<CustomerFieldError> errs(R r) =>
    (r as Err<SupplierDraft, List<CustomerFieldError>>).error;

void main() {
  group('SupplierDraft.create', () {
    test('trims and keeps the fields', () {
      final d = ok(
        SupplierDraft.create(
          name: '  شركة النور ',
          phone: '02 2345 6789',
          address: ' العتبة ',
          note: '',
        ),
      );
      expect(d.name, 'شركة النور');
      expect(d.phone, '0223456789');
      expect(d.address, 'العتبة');
      expect(d.note, isNull);
      expect(d.openingBalancePiasters, 0);
    });

    test('name: required, at most 100 code points', () {
      expect(errs(SupplierDraft.create(name: '   ')), [
        const CustomerFieldError(CustomerField.name, CustomerProblem.required),
      ]);
      expect(ok(SupplierDraft.create(name: 'ن' * 100)).name, hasLength(100));
      expect(errs(SupplierDraft.create(name: 'ن' * 101)), [
        const CustomerFieldError(
          CustomerField.name,
          CustomerProblem.tooLong,
          max: 100,
        ),
      ]);
    });

    test('phone: 7 to 15 digits', () {
      expect(errs(SupplierDraft.create(name: 'a', phone: '123456')), [
        const CustomerFieldError(CustomerField.phone, CustomerProblem.tooShort),
      ]);
      expect(errs(SupplierDraft.create(name: 'a', phone: 'abc1234')), [
        const CustomerFieldError(CustomerField.phone, CustomerProblem.invalid),
      ]);
    });

    test('address and note: at most 200 code points', () {
      expect(
        errs(
          SupplierDraft.create(name: 'a', address: 'x' * 201, note: 'y' * 201),
        ),
        [
          const CustomerFieldError(
            CustomerField.address,
            CustomerProblem.tooLong,
            max: 200,
          ),
          const CustomerFieldError(
            CustomerField.note,
            CustomerProblem.tooLong,
            max: 200,
          ),
        ],
      );
    });

    test('opening: owed by the shop is positive, in its favour negative', () {
      expect(
        ok(SupplierDraft.create(name: 'a', openingText: '1,000'))
            .openingBalancePiasters,
        100000,
      );
      expect(
        ok(
          SupplierDraft.create(
            name: 'a',
            openingText: '٥٠',
            openingInShopFavour: true,
          ),
        ).openingBalancePiasters,
        -5000,
      );
      expect(
        ok(SupplierDraft.create(name: 'a', openingText: '0'))
            .openingBalancePiasters,
        0,
      );
    });

    test('opening: at most 10,000,000 EGP and two decimals', () {
      expect(
        ok(SupplierDraft.create(name: 'a', openingText: '10000000'))
            .openingBalancePiasters,
        1000000000,
      );
      expect(
        errs(SupplierDraft.create(name: 'a', openingText: '10000000.01')),
        [
          const CustomerFieldError(
            CustomerField.opening,
            CustomerProblem.tooLarge,
            max: 1000000000,
          ),
        ],
      );
      expect(errs(SupplierDraft.create(name: 'a', openingText: '1.234')), [
        const CustomerFieldError(
          CustomerField.opening,
          CustomerProblem.invalid,
        ),
      ]);
    });

    test('returns every error at once', () {
      expect(
        errs(SupplierDraft.create(name: '', phone: '1', openingText: 'x')),
        hasLength(3),
      );
    });
  });

  test('a summary is owed when the balance is above 0', () {
    const s = Supplier(id: 's', name: 'n');
    expect(const SupplierSummary(supplier: s, balancePiasters: 1).owed, isTrue);
    expect(
      const SupplierSummary(supplier: s, balancePiasters: 0).owed,
      isFalse,
    );
    expect(
      const SupplierSummary(supplier: s, balancePiasters: -1).owed,
      isFalse,
    );
  });

  test('the query folds Arabic like names', () {
    expect(const SupplierQuery(text: 'أحمد').normalizedText, 'احمد');
    expect(
      const SupplierQuery().copyWith(owedOnly: true),
      const SupplierQuery(owedOnly: true),
    );
  });

  group('SupplierEntry.cancellable', () {
    SupplierEntry entry({
      SupplierEntryType type = SupplierEntryType.payment,
      int? paymentNumber = 1,
      bool reversed = false,
    }) => SupplierEntry(
      id: 'e',
      type: type,
      amountPiasters: -100,
      runningBalancePiasters: 0,
      at: DateTime.utc(2026),
      rowOrder: 7,
      paymentNumber: paymentNumber,
      reversed: reversed,
    );

    test('only a standalone payment not yet cancelled', () {
      expect(entry().cancellable, isTrue);
      expect(entry(paymentNumber: null).cancellable, isFalse);
      expect(entry(reversed: true).cancellable, isFalse);
      expect(entry(type: SupplierEntryType.purchase).cancellable, isFalse);
    });

    test('pages continue from its time and row order', () {
      expect(entry().cursor, LedgerCursor(at: DateTime.utc(2026), rowOrder: 7));
    });
  });
}
