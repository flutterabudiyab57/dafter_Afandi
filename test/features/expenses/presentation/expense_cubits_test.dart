import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/features/expenses/domain/expense.dart';
import 'package:daftar_afandi/features/expenses/domain/expense_errors.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expense_categories_cubit.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expense_cubit.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expense_form_cubit.dart';
import 'package:daftar_afandi/features/expenses/presentation/cubits/expenses_list_cubit.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/reports/domain/report_period.dart';
import 'package:daftar_afandi/features/reports/presentation/cubits/report_period_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_expenses.dart';

/// Lets the fake's streams deliver.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeExpensesStore store;
  late String rent;

  setUp(() {
    store = FakeExpensesStore();
    rent = store.addCategory('إيجار');
  });

  Expense seed(int number, int piasters, {String? categoryId, DateTime? on}) {
    final id = categoryId ?? rent;
    return store.addExpense(
      Expense(
        id: 'e$number',
        number: number,
        category: store.categories.firstWhere((c) => c.id == id),
        amountPiasters: piasters,
        parts: [PaymentSplit.single(PaymentMethod.cash, piasters).first],
        spentOn: on ?? DateTime(2026, 10, 25),
        createdAt: DateTime.utc(2026, 10, 25),
      ),
    );
  }

  group('ExpenseFormCubit', () {
    ExpenseFormCubit form() =>
        ExpenseFormCubit(store, store.categoryRepo, kExpensesClock);

    test('opens on today, cash, with the active categories', () async {
      final cubit = form();
      addTearDown(cubit.close);
      await settle();
      final local = kExpensesClock.nowUtc().toLocal();
      expect(cubit.state.spentOn, DateTime(local.year, local.month, local.day));
      expect(cubit.state.method, PaymentMethod.cash);
      expect(cubit.state.categories.map((c) => c.id), [rent]);
      expect(cubit.hasUnsavedChanges, isFalse);
    });

    test('saves one part in the chosen method', () async {
      final cubit = form();
      addTearDown(cubit.close);
      cubit
        ..categoryChanged(rent)
        ..amountChanged('١٥٠٠')
        ..methodChanged(PaymentMethod.instapay)
        ..noteChanged(' أكتوبر ');
      expect(cubit.hasUnsavedChanges, isTrue);
      await cubit.submit();
      expect(cubit.state.status, ExpenseFormStatus.saved);
      expect(cubit.state.saved!.number, 1);
      expect(cubit.hasUnsavedChanges, isFalse);
      final saved = store.expenses.single;
      expect(saved.parts, [
        const PaymentPart(
          method: PaymentMethod.instapay,
          amountPiasters: 150000,
        ),
      ]);
      expect(saved.note, 'أكتوبر');
    });

    test(
      'shows the broken rules and saves nothing; an edit clears them',
      () async {
        final cubit = form();
        addTearDown(cubit.close);
        await cubit.submit();
        expect(cubit.state.errors, [
          const ExpenseCategoryRequired(),
          const ExpenseAmountRequired(),
        ]);
        expect(store.expenses, isEmpty);
        cubit.amountChanged('5');
        expect(cubit.state.errors, isEmpty);
      },
    );

    test('a category archived meanwhile comes back as its rule', () async {
      final cubit = form();
      addTearDown(cubit.close);
      cubit
        ..categoryChanged(rent)
        ..amountChanged('5');
      await store.categoryRepo.archive(rent);
      await cubit.submit();
      expect(cubit.state.status, ExpenseFormStatus.editing);
      expect(cubit.state.errors, [const ExpenseCategoryArchived()]);
    });

    test('a failed save keeps the form and reports failed', () async {
      final cubit = form();
      addTearDown(cubit.close);
      cubit
        ..categoryChanged(rent)
        ..amountChanged('5');
      store.failNextCreate = StateError('disk');
      await cubit.submit();
      expect(cubit.state.status, ExpenseFormStatus.failed);
      expect(cubit.state.amount, '5');
    });
  });

  group('ExpensesListCubit', () {
    test('follows the shared period and the category filter', () async {
      final power = store.addCategory('كهرباء');
      seed(1, 10000);
      seed(2, 3000, categoryId: power);
      seed(3, 700, categoryId: power, on: DateTime(2026, 9, 30));
      final periods = ReportPeriodCubit(kExpensesClock);
      final cubit = ExpensesListCubit(store, store.categoryRepo, periods);
      addTearDown(cubit.close);
      addTearDown(periods.close);
      await settle();
      expect(cubit.state.query.period.kind, ReportPeriodKind.thisMonth);
      expect(cubit.state.items.map((e) => e.number), [2, 1]);
      expect(cubit.state.totalPiasters, 13000);
      expect(cubit.state.categories, hasLength(2));

      cubit.filterCategory(power);
      await settle();
      expect(cubit.state.items.map((e) => e.number), [2]);
      expect(cubit.state.totalPiasters, 3000);

      periods.choose(ReportPeriodKind.lastMonth);
      await settle();
      expect(cubit.state.query.categoryId, power);
      expect(cubit.state.items.map((e) => e.number), [3]);
      expect(cubit.state.totalPiasters, 700);
    });

    test('a voided expense stays listed but leaves the total', () async {
      seed(1, 10000);
      final wrong = seed(2, 4000);
      final periods = ReportPeriodCubit(kExpensesClock);
      final cubit = ExpensesListCubit(store, store.categoryRepo, periods);
      addTearDown(cubit.close);
      addTearDown(periods.close);
      await store.voidExpense(wrong.id, 'مكرر');
      await settle();
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.totalPiasters, 10000);
    });

    test('a failed load offers retry', () async {
      store.failNextWatch = StateError('db');
      final periods = ReportPeriodCubit(kExpensesClock);
      final cubit = ExpensesListCubit(store, store.categoryRepo, periods);
      addTearDown(cubit.close);
      addTearDown(periods.close);
      await settle();
      expect(cubit.state.loadFailed, isTrue);
      cubit.retry();
      await settle();
      expect(cubit.state.loadFailed, isFalse);
      expect(cubit.state.loading, isFalse);
    });
  });

  group('ExpenseCubit', () {
    test('voids once', () async {
      final e = seed(1, 10000);
      final cubit = ExpenseCubit(store, e.id);
      addTearDown(cubit.close);
      expect(await cubit.voidExpense('مكرر'), isNull);
      await settle();
      expect(cubit.state.expense!.isVoided, isTrue);
      expect(await cubit.voidExpense('مرة أخرى'), const ExpenseAlreadyVoided());
    });

    test('a missing expense loads as null', () async {
      final cubit = ExpenseCubit(store, 'nope');
      addTearDown(cubit.close);
      await settle();
      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.expense, isNull);
    });
  });

  group('ExpenseCategoriesCubit', () {
    test('returns each refusal and lists archived ones apart', () async {
      final cubit = ExpenseCategoriesCubit(store.categoryRepo);
      addTearDown(cubit.close);
      expect(
        await cubit.create('ايجار'),
        const ExpenseCategoryNameTaken('إيجار'),
      );
      expect(await cubit.create(''), const ExpenseCategoryNameRequired());
      expect(await cubit.create('نظافة'), isNull);
      await cubit.archive(rent);
      await settle();
      expect(cubit.state.active.map((c) => c.name), ['نظافة']);
      expect(cubit.state.archived.map((c) => c.name), ['إيجار']);
      expect(await cubit.restore(rent), isNull);
    });

    test('defaults only into an empty list', () async {
      final empty = FakeExpensesStore();
      final cubit = ExpenseCategoriesCubit(empty.categoryRepo);
      addTearDown(cubit.close);
      await cubit.ensureDefaults(['أ', 'ب']);
      await cubit.ensureDefaults(['ج']);
      expect(empty.categories.map((c) => c.name), ['أ', 'ب']);
    });
  });

  test('the clock fixes "today" for the form', () {
    final late = FixedClock(DateTime.utc(2026, 12, 31, 12));
    final cubit = ExpenseFormCubit(store, store.categoryRepo, late);
    addTearDown(cubit.close);
    final local = late.nowUtc().toLocal();
    expect(cubit.today, DateTime(local.year, local.month, local.day));
  });
}
