import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/expenses/domain/expense.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_errors.dart';
import 'package:daftar_afandi/features/payments/data/payment_parts_writer.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/reports/data/reports_repository_impl.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../products/data/products_env.dart';
import 'expenses_env.dart';

final _later = FixedClock(DateTime.utc(2026, 11, 15, 10));

ReportPeriod _range(DateTime from, DateTime to) =>
    okValue<ReportPeriod, PeriodInvalid>(ReportPeriod.custom(from, to, _later));

final _october = _range(DateTime(2026, 10), DateTime(2026, 10, 31));

/// Fails while [fail] is set, after the number and the expense row were
/// written.
final class _FailingParts extends PaymentPartsWriter {
  _FailingParts(super.dao, super.ids);

  bool fail = true;

  @override
  Future<void> write(
    PaymentParent parent,
    PaymentSplit split, {
    required int paidPiasters,
    required DateTime at,
  }) {
    if (fail) throw StateError('disk full');
    return super.write(parent, split, paidPiasters: paidPiasters, at: at);
  }
}

void main() {
  late ExpensesEnv env;
  late String rent;

  setUp(() async {
    env = ExpensesEnv();
    rent = await env.addCategory('إيجار');
  });
  tearDown(() => env.dispose());

  ExpenseQuery query({String? categoryId}) =>
      ExpenseQuery(period: _october, categoryId: categoryId);

  group('record', () {
    test('numbers E-1, E-2 in order, newest first, with the method '
        '(US3-1)', () async {
      final first = await env.record(
        rent,
        '1500',
        method: PaymentMethod.wallet,
      );
      final second = await env.record(rent, '20');
      expect([first.number, second.number], [1, 2]);

      final list = await env.expenses.watchList(query()).first;
      expect(list.map((e) => e.number), [2, 1]);
      final saved = list.last;
      expect(saved.amountPiasters, 150000);
      expect(saved.category.name, 'إيجار');
      expect(saved.parts, [
        const PaymentPart(method: PaymentMethod.wallet, amountPiasters: 150000),
      ]);
      expect(saved.spentOn, ExpensesEnv.today);
      expect(saved.isVoided, isFalse);
    });

    test('keeps the owner account number on a wallet part', () async {
      final saved = okValue<ExpenseSaved, ExpenseSaveError>(
        await env.expenses.create(
          env.draft(
            rent,
            '50',
            method: PaymentMethod.wallet,
            account: '01001234567',
            note: '  أكتوبر  ',
          ),
        ),
      );
      final e = (await env.expenses.watchOne(saved.id).first)!;
      expect(e.parts.single.accountRef, '01001234567');
      expect(e.note, 'أكتوبر');
    });

    test('a failed write rolls back and burns no number', () async {
      late _FailingParts parts;
      final failing = ExpensesEnv(
        parts: (db) =>
            parts = _FailingParts(db.paymentPartsDao, const UuidV7Generator()),
      );
      addTearDown(failing.dispose);
      final category = await failing.addCategory('كهرباء');
      await expectLater(
        failing.expenses.create(failing.draft(category, '10')),
        throwsStateError,
      );
      expect(await failing.expenses.watchList(query()).first, isEmpty);

      parts.fail = false;
      expect((await failing.record(category, '10')).number, 1);
    });

    test('a date after today is refused', () async {
      // Valid on a form whose clock was a day ahead; the repository checks
      // its own today.
      final tomorrow = DateTime(2026, 10, 21);
      expect(
        await env.expenses.create(
          env.draft(rent, '10', spentOn: tomorrow, formToday: tomorrow),
        ),
        const Err<ExpenseSaved, ExpenseSaveError>(
          ExpenseInvalid([ExpenseDateInFuture()]),
        ),
      );
    });

    test('an archived category is refused', () async {
      await env.categories.archive(rent);
      expect(
        await env.expenses.create(env.draft(rent, '10')),
        const Err<ExpenseSaved, ExpenseSaveError>(
          ExpenseInvalid([ExpenseCategoryArchived()]),
        ),
      );
    });
  });

  group('void', () {
    test('once, with its reason; excluded from the total and the profit '
        '(US3-3, US3-4)', () async {
      final reports = ReportsRepositoryImpl(env.products.db.reportsDao, _later);
      final kept = await env.record(rent, '100');
      final wrong = await env.record(rent, '40');
      expect(await env.expenses.watchTotal(query()).first, 14000);
      expect(
        (await reports.watchProfit(_october).first).expensesPiasters,
        14000,
      );

      expect(
        await env.expenses.voidExpense(wrong.id, '  مكرر '),
        const Ok<void, ExpenseVoidError>(null),
      );
      final voided = (await env.expenses.watchOne(wrong.id).first)!;
      expect(voided.isVoided, isTrue);
      expect(voided.voidReason, 'مكرر');
      expect(await env.expenses.watchTotal(query()).first, 10000);
      expect(
        (await reports.watchProfit(_october).first).expensesPiasters,
        10000,
      );
      expect((await env.expenses.watchList(query()).first).map((e) => e.id), [
        wrong.id,
        kept.id,
      ]);

      expect(
        await env.expenses.voidExpense(wrong.id, 'مرة أخرى'),
        const Err<void, ExpenseVoidError>(ExpenseAlreadyVoided()),
      );
    });

    test('needs a reason and an existing expense', () async {
      final saved = await env.record(rent, '10');
      expect(
        await env.expenses.voidExpense(saved.id, '   '),
        const Err<void, ExpenseVoidError>(ExpenseVoidReasonInvalid()),
      );
      expect(
        await env.expenses.voidExpense('nope', 'خطأ'),
        const Err<void, ExpenseVoidError>(ExpenseNotFound()),
      );
    });
  });

  test(
    'the period and category filter the list and the total (US3-5)',
    () async {
      final power = await env.addCategory('كهرباء');
      await env.record(rent, '100');
      await env.record(power, '30');
      await env.record(power, '7', spentOn: DateTime(2026, 9, 30));

      final powerOnly = query(categoryId: power);
      expect(
        (await env.expenses.watchList(powerOnly).first).map(
          (e) => e.amountPiasters,
        ),
        [3000],
      );
      expect(await env.expenses.watchTotal(powerOnly).first, 3000);
      expect(await env.expenses.watchTotal(query()).first, 13000);
    },
  );

  group('categories', () {
    test('defaults are inserted once, and never again after all are '
        'archived (research R13)', () async {
      final fresh = ExpensesEnv();
      addTearDown(fresh.dispose);
      const names = ['إيجار', 'كهرباء', 'رواتب', 'أخرى'];
      await fresh.categories.ensureDefaults(names);
      await fresh.categories.ensureDefaults(names);
      final active = await fresh.categories.watchActive().first;
      expect(active.map((c) => c.name).toSet(), names.toSet());

      for (final c in active) {
        await fresh.categories.archive(c.id);
      }
      await fresh.categories.ensureDefaults(names);
      expect(await fresh.categories.watchActive().first, isEmpty);
      expect(await fresh.categories.watchArchived().first, hasLength(4));
    });

    test('a taken name is refused ignoring case, letter forms and spaces '
        '(US3-7)', () async {
      await env.addCategory('Internet');
      for (final name in ['  internet ', 'INTERNET', 'ايجار', 'إيجـار']) {
        expect(
          errValue<String, ExpenseCategoryError>(
            await env.categories.create(name),
          ),
          isA<ExpenseCategoryNameTaken>(),
          reason: name,
        );
      }
    });

    test('names are 1 to 50 code points', () async {
      expect(
        await env.categories.create('  '),
        const Err<String, ExpenseCategoryError>(ExpenseCategoryNameRequired()),
      );
      expect(
        await env.categories.create('ن' * 51),
        const Err<String, ExpenseCategoryError>(ExpenseCategoryNameTooLong()),
      );
      expect(await env.categories.create('ن' * 50), isA<Ok<String, Object>>());
    });

    test('rename, archive and restore; past expenses keep the name '
        '(US3-6)', () async {
      final internet = await env.addCategory('Internet');
      expect(
        await env.categories.rename(internet, 'إنترنت'),
        const Ok<void, ExpenseCategoryError>(null),
      );
      final saved = await env.record(internet, '200');
      await env.categories.archive(internet);

      final e = (await env.expenses.watchOne(saved.id).first)!;
      expect(e.category.name, 'إنترنت');
      expect(e.category.archived, isTrue);
      expect(
        (await env.categories.watchActive().first).map((c) => c.id),
        isNot(contains(internet)),
      );

      // Restoring is refused while an active one has its name.
      final clash = await env.addCategory('انترنت');
      expect(
        await env.categories.restore(internet),
        const Err<void, ExpenseCategoryError>(
          ExpenseCategoryNameTaken('انترنت'),
        ),
      );
      await env.categories.archive(clash);
      expect(
        await env.categories.restore(internet),
        const Ok<void, ExpenseCategoryError>(null),
      );
      expect(
        (await env.categories.watchActive().first).map((c) => c.id),
        contains(internet),
      );
    });

    test('renaming to another active name is refused', () async {
      final a = await env.addCategory('نظافة');
      expect(
        await env.categories.rename(a, 'إيجار'),
        const Err<void, ExpenseCategoryError>(
          ExpenseCategoryNameTaken('إيجار'),
        ),
      );
      // Its own name with other spacing is fine.
      expect(
        await env.categories.rename(a, ' نظافة '),
        const Ok<void, ExpenseCategoryError>(null),
      );
    });
  });
}
