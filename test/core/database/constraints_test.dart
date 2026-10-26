import 'package:daftar_afandi/core/database/tables/enums.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

final Matcher _rejected = throwsA(isA<SqliteException>());

/// Every enum column and the Dart enum its hand-written CHECK must match.
final Map<(String, String), List<Enum>> _enumColumns = {
  ('app_settings', 'locale_code'): LocaleCode.values,
  ('app_settings', 'digit_style'): DigitStylePreference.values,
  ('app_settings', 'negative_stock_policy'): NegativeStockPolicy.values,
  ('counters', 'doc_type'): DocType.values,
  ('products', 'unit_type'): UnitType.values,
  ('sale_items', 'unit_type_snapshot'): UnitType.values,
  ('sales_invoices', 'payment_method'): PaymentMethod.values,
  ('sale_returns', 'payment_method'): PaymentMethod.values,
  ('purchase_invoices', 'payment_method'): PaymentMethod.values,
  ('stock_movements', 'movement_type'): MovementType.values,
  ('stock_movements', 'adjustment_reason'): AdjustmentReason.values,
  ('customer_ledger', 'entry_type'): CustomerEntryType.values,
  ('customer_ledger', 'payment_method'): PaymentMethod.values,
  ('supplier_ledger', 'entry_type'): SupplierEntryType.values,
  ('supplier_ledger', 'payment_method'): PaymentMethod.values,
  ('payment_parts', 'method'): PaymentMethod.values,
};

void main() {
  late TempDatabase t;

  setUp(() async {
    t = await TempDatabase.open();
    await insertFixtures(t.db);
  });
  tearDown(() => t.dispose());

  Future<void> exec(String sql, [List<Object?> args = const []]) =>
      t.db.exec(sql, args);

  test('each enum CHECK lists exactly the Dart enum values', () async {
    for (final MapEntry(key: (table, column), value: values)
        in _enumColumns.entries) {
      final sql = await t.db.scalar(
        "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = ?",
        [table],
      ) as String;
      final m = RegExp('\\b$column IN \\(([^)]*)\\)').firstMatch(sql);
      expect(m, isNotNull, reason: '$table.$column has no IN check');
      final listed = m!
          .group(1)!
          .split(',')
          .map((s) => s.trim().replaceAll("'", ''))
          .toList();
      expect(
        listed,
        values.map((v) => v.name).toList(),
        reason: '$table.$column',
      );
    }
  });

  group('app_settings', () {
    Future<void> set(String assignments, [List<Object?> args = const []]) =>
        exec('UPDATE app_settings SET $assignments', args);

    test('onboarded without a name is rejected', () async {
      await expectLater(set('onboarding_completed_at = 1'), _rejected);
      await expectLater(
        set("shop_name = '   ', onboarding_completed_at = 1"),
        _rejected,
      );
    });

    test('name length is 1–60 code points once onboarded', () async {
      await expectLater(
        set('shop_name = ?, onboarding_completed_at = 1', ['م' * 61]),
        _rejected,
      );
      await set('shop_name = ?, onboarding_completed_at = 1', ['م' * 60]);
      await set('shop_name = ?', ['  دفتر  ']);
    });

    test('a shop name may be NULL before onboarding', () async {
      await set("shop_name = NULL, shop_phone = '0123456'");
    });

    test('phone: optional leading +, then 7–15 Latin digits', () async {
      for (final bad in [
        'abc',
        '0100abc4567',
        '0100 123456',
        '+20-100123456',
        '12+3456789',
        '++201001234',
        '012345', // 6 digits
        '+2010012345678901', // 16 digits
        '٠١٠٠١٢٣٤٥٦٧',
      ]) {
        await expectLater(set('shop_phone = ?', [bad]), _rejected, reason: bad);
      }
      for (final good in ['0123456', '+201001234567', '201001234567890']) {
        await set('shop_phone = ?', [good]);
      }
    });

    test('unknown enum value is rejected', () async {
      await expectLater(set("locale_code = 'fr'"), _rejected);
      await expectLater(set("digit_style = 'roman'"), _rejected);
    });
  });

  group('stock_movements per-type rule', () {
    var n = 0;
    Future<void> move(
      String type,
      int qty, {
      String? sale,
      String? ret,
      String? purchase,
      String? reverses,
      String? reason,
    }) {
      n += 1;
      return exec(
        'INSERT INTO stock_movements (id, product_id, movement_type, qty_delta_milli, '
        'unit_cost_piasters, sale_item_id, sale_return_item_id, purchase_item_id, '
        'reverses_movement_id, adjustment_reason, created_at) '
        "VALUES (?, 'p1', ?, ?, 500, ?, ?, ?, ?, ?, 1)",
        ['m$n', type, qty, sale, ret, purchase, reverses, reason],
      );
    }

    test('valid rows for every type', () async {
      await move('OPENING', 1000);
      await move('PURCHASE', 1000, purchase: 'pit1');
      await move('PURCHASE_VOID', -1000, purchase: 'pit1', reverses: 'sm1');
      await move('SALE', -1000, sale: 'sit1');
      await move('SALE_RETURN', 1000, ret: 'sri1');
      await move('SALE_VOID', 1000, sale: 'sit1', reverses: 'm4');
      await move('ADJUSTMENT', -1000, reason: 'damage');
      await move('ADJUSTMENT', 1000, reason: 'count');
    });

    test('zero quantity is rejected', () async {
      await expectLater(move('ADJUSTMENT', 0, reason: 'other'), _rejected);
    });

    test('wrong sign is rejected', () async {
      await expectLater(move('OPENING', -1000), _rejected);
      await expectLater(move('PURCHASE', -1000, purchase: 'pit1'), _rejected);
      await expectLater(
        move('PURCHASE_VOID', 1000, purchase: 'pit1', reverses: 'sm1'),
        _rejected,
      );
      await expectLater(move('SALE', 1000, sale: 'sit1'), _rejected);
      await expectLater(move('SALE_RETURN', -1000, ret: 'sri1'), _rejected);
      await expectLater(
        move('SALE_VOID', -1000, sale: 'sit1', reverses: 'sm1'),
        _rejected,
      );
    });

    test('missing required source is rejected', () async {
      await expectLater(move('PURCHASE', 1000), _rejected);
      await expectLater(
        move('PURCHASE_VOID', -1000, purchase: 'pit1'),
        _rejected,
      );
      await expectLater(move('SALE', -1000), _rejected);
      await expectLater(move('SALE_RETURN', 1000), _rejected);
      await expectLater(move('SALE_VOID', 1000, sale: 'sit1'), _rejected);
      await expectLater(move('ADJUSTMENT', 1000), _rejected);
    });

    test('an extra source is rejected', () async {
      await expectLater(move('OPENING', 1000, purchase: 'pit1'), _rejected);
      await expectLater(
        move('SALE', -1000, sale: 'sit1', purchase: 'pit1'),
        _rejected,
      );
      await expectLater(
        move('ADJUSTMENT', 1000, reason: 'count', sale: 'sit1'),
        _rejected,
      );
    });

    test(
      'adjustment reason only on ADJUSTMENT, and only known values',
      () async {
        await expectLater(move('OPENING', 1000, reason: 'count'), _rejected);
        await expectLater(move('ADJUSTMENT', 1000, reason: 'theft'), _rejected);
      },
    );

    test('unknown type is rejected', () async {
      await expectLater(move('GIFT', 1000), _rejected);
    });
  });

  group('ledger payment method', () {
    Future<void> customer(String id, String type, String? method) => exec(
      'INSERT INTO customer_ledger (id, customer_id, entry_type, amount_piasters, '
      "payment_method, created_at) VALUES (?, 'cu1', ?, -100, ?, 1)",
      [id, type, method],
    );
    Future<void> supplier(String id, String type, String? method) => exec(
      'INSERT INTO supplier_ledger (id, supplier_id, entry_type, amount_piasters, '
      "payment_method, created_at) VALUES (?, 'su1', ?, -100, ?, 1)",
      [id, type, method],
    );

    test(
      'customer: required exactly on PAYMENT_RECEIVED and REFUND_PAID',
      () async {
        await customer('a', 'PAYMENT_RECEIVED', 'wallet');
        await customer('b', 'REFUND_PAID', 'cash');
        await customer('c', 'ADJUSTMENT', null);
        await expectLater(customer('d', 'PAYMENT_RECEIVED', null), _rejected);
        await expectLater(customer('e', 'REFUND_PAID', null), _rejected);
        await expectLater(customer('f', 'SALE', 'cash'), _rejected);
        await expectLater(customer('g', 'OPENING_BALANCE', 'cash'), _rejected);
        await expectLater(
          customer('h', 'PAYMENT_RECEIVED', 'cheque'),
          _rejected,
        );
      },
    );

    test('supplier: required exactly on PAYMENT_MADE', () async {
      await supplier('a', 'PAYMENT_MADE', 'instapay');
      await supplier('b', 'REVERSAL', null);
      await expectLater(supplier('c', 'PAYMENT_MADE', null), _rejected);
      await expectLater(supplier('d', 'PURCHASE', 'cash'), _rejected);
    });

    test('zero amount is rejected', () async {
      await expectLater(
        exec(
          'INSERT INTO customer_ledger (id, customer_id, entry_type, amount_piasters, '
          "created_at) VALUES ('z', 'cu1', 'ADJUSTMENT', 0, 1)",
        ),
        _rejected,
      );
    });

    test('receipt and payment numbers are unique when set', () async {
      await expectLater(
        exec(
          'INSERT INTO customer_ledger (id, customer_id, entry_type, amount_piasters, '
          "receipt_number, payment_method, created_at) "
          "VALUES ('dup', 'cu1', 'PAYMENT_RECEIVED', -1, 1, 'cash', 1)",
        ),
        _rejected,
      );
    });
  });

  group('sales and purchase header money', () {
    var n = 10;
    Future<void> sale({
      required int subtotal,
      required int discount,
      required int total,
      required int paid,
      String? customer,
    }) {
      n += 1;
      return exec(
        'INSERT INTO sales_invoices (id, number, customer_id, subtotal_piasters, '
        'discount_piasters, total_piasters, paid_at_sale_piasters, created_at, '
        'updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, 1, 1)',
        ['s$n', n, customer, subtotal, discount, total, paid],
      );
    }

    Future<void> purchase({
      required int subtotal,
      required int discount,
      required int total,
      required int paid,
      String? supplier,
    }) {
      n += 1;
      return exec(
        'INSERT INTO purchase_invoices (id, number, supplier_id, invoice_date, '
        'subtotal_piasters, discount_piasters, total_piasters, paid_piasters, '
        'created_at, updated_at) VALUES (?, ?, ?, 1, ?, ?, ?, ?, 1, 1)',
        ['p$n', n, supplier, subtotal, discount, total, paid],
      );
    }

    test('sales', () async {
      await sale(subtotal: 1000, discount: 100, total: 900, paid: 900);
      await sale(
        subtotal: 1000,
        discount: 0,
        total: 1000,
        paid: 0,
        customer: 'cu1',
      );
      await expectLater(
        sale(subtotal: 1000, discount: -1, total: 1001, paid: 1001),
        _rejected,
      );
      await expectLater(
        sale(
          subtotal: 1000,
          discount: 1001,
          total: -1,
          paid: 0,
          customer: 'cu1',
        ),
        _rejected,
      );
      await expectLater(
        sale(subtotal: 1000, discount: 100, total: 1000, paid: 1000),
        _rejected,
      );
      await expectLater(
        sale(subtotal: 1000, discount: 0, total: 1000, paid: 1001),
        _rejected,
      );
      await expectLater(
        sale(
          subtotal: 1000,
          discount: 0,
          total: 1000,
          paid: -1,
          customer: 'cu1',
        ),
        _rejected,
      );
      await expectLater(
        sale(subtotal: 1000, discount: 0, total: 1000, paid: 500),
        _rejected,
      );
    });

    test('purchases', () async {
      await purchase(subtotal: 1000, discount: 100, total: 900, paid: 900);
      await purchase(
        subtotal: 1000,
        discount: 0,
        total: 1000,
        paid: 0,
        supplier: 'su1',
      );
      await expectLater(
        purchase(
          subtotal: 1000,
          discount: 1001,
          total: -1,
          paid: 0,
          supplier: 'su1',
        ),
        _rejected,
      );
      await expectLater(
        purchase(subtotal: 1000, discount: 0, total: 999, paid: 999),
        _rejected,
      );
      await expectLater(
        purchase(subtotal: 1000, discount: 0, total: 1000, paid: 1001),
        _rejected,
      );
      await expectLater(
        purchase(subtotal: 1000, discount: 0, total: 1000, paid: 500),
        _rejected,
      );
    });

    test('void reason and void time come together', () async {
      await expectLater(
        exec(
          'INSERT INTO sales_invoices (id, number, subtotal_piasters, total_piasters, '
          "paid_at_sale_piasters, created_at, updated_at, voided_at) "
          "VALUES ('v', 77, 0, 0, 0, 1, 1, 5)",
        ),
        _rejected,
      );
    });

    test('sale line discount is at most the gross amount', () async {
      Future<void> line(int lineNo, int discount) => exec(
        'INSERT INTO sale_items (id, sales_invoice_id, line_no, product_id, '
        'product_name_snapshot, unit_type_snapshot, qty_milli, unit_price_piasters, '
        'discount_piasters, line_total_piasters, invoice_discount_share_piasters, '
        "unit_cost_piasters, line_cost_piasters) VALUES (?, 'si1', ?, 'p1', 'Rice', "
        "'kg', 1500, 333, ?, 0, 0, 0, 0)",
        ['line$lineNo', lineNo, discount],
      );
      // 1.5 kg x 3.33 = 4.995 → 5.00 (half up).
      await line(2, 500);
      await expectLater(line(3, 501), _rejected);
      await expectLater(line(4, -1), _rejected);
    });
  });

  test('expenses amount must be positive', () async {
    for (final amount in [0, -100]) {
      await expectLater(
        exec(
          'INSERT INTO expenses (id, number, expense_category_id, amount_piasters, '
          "spent_at, created_at, updated_at) VALUES (?, ?, 'ec1', ?, 1, 1, 1)",
          ['x$amount', 100 - amount, amount],
        ),
        _rejected,
      );
    }
  });

  group('payment_parts', () {
    Future<void> part(
      String id, {
      String parents = "sales_invoice_id",
      String parentValues = "'si1'",
      int partNo = 2,
      String method = 'wallet',
      int amount = 100,
      String? account,
    }) => exec(
      'INSERT INTO payment_parts (id, $parents, part_no, method, '
      'amount_piasters, account_ref, created_at) '
      'VALUES (?, $parentValues, ?, ?, ?, ?, 1)',
      [id, partNo, method, amount, account],
    );

    test('a valid part with the owner account', () async {
      await part('ok', account: 'shop@instapay');
    });

    test('exactly one parent', () async {
      await expectLater(
        part(
          'two',
          parents: 'sales_invoice_id, expense_id',
          parentValues: "'si1', 'e1'",
        ),
        _rejected,
      );
      await expectLater(
        exec(
          'INSERT INTO payment_parts (id, part_no, method, amount_piasters, '
          "created_at) VALUES ('none', 1, 'cash', 1, 1)",
        ),
        _rejected,
      );
    });

    test('amount above 0 and part number 1 to 3', () async {
      await expectLater(part('zero', amount: 0), _rejected);
      await expectLater(part('four', partNo: 4), _rejected);
    });

    test('no account on cash; 1 to 40 characters', () async {
      await expectLater(
        part('cash', method: 'cash', account: '010'),
        _rejected,
      );
      await expectLater(part('empty', account: ''), _rejected);
      await expectLater(part('long', account: '1' * 41), _rejected);
      await part('forty', account: '1' * 40);
    });

    test('one method and one part number per parent', () async {
      await expectLater(part('samemethod', method: 'cash'), _rejected);
      await expectLater(part('samepart', partNo: 1), _rejected);
    });
  });

  test('foreign keys are enforced', () async {
    await expectLater(
      exec(
        'INSERT INTO products (id, category_id, name, search_key, unit_type, '
        "sale_price_piasters, created_at, updated_at) VALUES ('p9', 'missing', "
        "'x', 'x', 'piece', 0, 1, 1)",
      ),
      _rejected,
    );
  });
}
