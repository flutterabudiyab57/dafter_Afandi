import 'package:daftar_afandi/core/l10n/generated/app_localizations.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/widgets/status_badge.dart';
import 'package:daftar_afandi/features/expenses/domain/expense.dart';
import 'package:daftar_afandi/features/payments/domain/payment_method.dart';
import 'package:daftar_afandi/features/payments/domain/payment_split.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/fake_expenses.dart';
import '../../../helpers/pump_app.dart';

void main() {
  for (final locale in AppLocale.values) {
    final l10n = lookupAppLocalizations(Locale(locale.name));
    final ar = locale == AppLocale.ar;
    String digits(String latin) => ar
        ? latin
              .replaceAllMapped(
                RegExp('[0-9]'),
                (m) => String.fromCharCode(0x0660 + int.parse(m[0]!)),
              )
              .replaceAll('.', '٫')
              .replaceAll(',', '٬')
        : latin;

    for (final textScale in [1.0, 2.0]) {
      group('${locale.name} ×$textScale', () {
        late FakeExpensesStore store;

        setUp(() => store = FakeExpensesStore());

        Future<void> open(WidgetTester tester, String path) async {
          final repo = FakeSettingsRepository(kOnboardedSettings);
          if (!ar) await repo.setLocale(AppLocale.en);
          await pumpApp(
            tester,
            repo,
            textScale: textScale,
            expenses: FakeExpensesCubits(store),
          );
          await goTo(tester, path);
          expect(tester.takeException(), isNull);
        }

        Future<void> tapVisible(WidgetTester tester, Finder f) async {
          await tester.ensureVisible(f);
          await tester.tap(f);
          await tester.pumpAndSettle();
        }

        Expense seed(
          String categoryId,
          String categoryName,
          int number,
          int piasters, {
          DateTime? spentOn,
        }) => store.addExpense(
          Expense(
            id: 'e$number',
            number: number,
            category: ExpenseCategory(id: categoryId, name: categoryName),
            amountPiasters: piasters,
            parts: [PaymentSplit.single(PaymentMethod.cash, piasters).first],
            spentOn: spentOn ?? DateTime(2026, 10, 25),
            createdAt: DateTime.utc(2026, 10, 25, 9),
          ),
        );

        Finder amountField() =>
            find.widgetWithText(TextField, l10n.paymentAmountLabel);

        testWidgets('the form starts with the four default categories, '
            'and saves 1,500 rent by wallet (US3-1)', (tester) async {
          await open(tester, RoutePaths.expenseNew);
          for (final name in [
            l10n.expenseCategoryRent,
            l10n.expenseCategoryElectricity,
            l10n.expenseCategorySalaries,
            l10n.expenseCategoryOther,
          ]) {
            expect(find.widgetWithText(ChoiceChip, name), findsOneWidget);
          }

          await tapVisible(
            tester,
            find.widgetWithText(ChoiceChip, l10n.expenseCategoryRent),
          );
          await tester.enterText(amountField(), '1500');
          await tapVisible(
            tester,
            find.widgetWithText(ChoiceChip, l10n.methodWallet),
          );
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );

          final saved = store.expenses.single;
          expect(saved.number, 1);
          expect(saved.amountPiasters, 150000);
          expect(saved.category.name, l10n.expenseCategoryRent);
          expect(saved.method, PaymentMethod.wallet);
          expect(saved.spentOn, DateTime(2026, 10, 26));
          // Back on this month's list, at the top.
          expect(currentPath(tester), RoutePaths.expenses);
          // The saved message and the row.
          expect(find.textContaining(digits('E-000001')), findsNWidgets(2));
          expect(
            find.descendant(
              of: find.byType(SnackBar),
              matching: find.textContaining(digits('E-000001')),
            ),
            findsOneWidget,
          );
          // The row and the total.
          expect(find.textContaining(digits('1,500.00')), findsNWidgets(2));
        });

        testWidgets('a missing category, an empty or zero amount are '
            'refused, by field (US3-2)', (tester) async {
          await open(tester, RoutePaths.expenseNew);
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(find.text(l10n.errorExpenseCategoryRequired), findsOneWidget);
          expect(find.text(l10n.errorAmountRequired), findsOneWidget);

          await tester.enterText(amountField(), '0');
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.saveAction),
          );
          expect(find.text(l10n.errorExpenseAmountInvalid), findsOneWidget);
          expect(store.expenses, isEmpty);
        });

        testWidgets('void with a reason: marked, out of the total, and no '
            'second void (US3-3, US3-4)', (tester) async {
          final rent = store.addCategory('إيجار');
          seed(rent, 'إيجار', 1, 10000);
          final wrong = seed(rent, 'إيجار', 2, 4000);
          await open(tester, RoutePaths.expense(wrong.id));

          await tapVisible(tester, find.text(l10n.expenseVoidAction));
          await tester.enterText(
            find.widgetWithText(TextField, l10n.reasonLabel),
            'مكرر',
          );
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.expenseVoidAction),
          );
          await tester.pumpAndSettle();
          expect(store.expenses.last.isVoided, isTrue);
          expect(find.textContaining('مكرر'), findsOneWidget);
          expect(find.text(l10n.expenseVoidAction), findsNothing);

          await tapBack(tester);
          expect(currentPath(tester), RoutePaths.expenses);
          expect(
            find.widgetWithText(StatusBadge, l10n.saleVoidedBadge),
            findsOneWidget,
          );
          // The kept row and the total, which leaves out the voided 40.
          expect(find.textContaining(digits('100.00')), findsNWidgets(2));
          expect(find.textContaining(digits('140.00')), findsNothing);
        });

        testWidgets('a category filter narrows the list and the total '
            '(US3-5)', (tester) async {
          final rent = store.addCategory('إيجار');
          final power = store.addCategory('كهرباء');
          seed(rent, 'إيجار', 1, 10000);
          seed(power, 'كهرباء', 2, 3000);
          // Last month: outside the shared period (this month).
          seed(power, 'كهرباء', 3, 700, spentOn: DateTime(2026, 9, 30));
          await open(tester, RoutePaths.expenses);
          expect(find.textContaining(digits('130.00')), findsOneWidget);

          await tapVisible(tester, find.widgetWithText(ChoiceChip, 'كهرباء'));
          expect(find.textContaining(digits('E-000001')), findsNothing);
          expect(find.textContaining(digits('E-000002')), findsOneWidget);
          expect(find.textContaining(digits('E-000003')), findsNothing);
          expect(find.textContaining(digits('30.00')), findsNWidgets(2));

          await tapVisible(tester, find.text(l10n.reportPeriodLastMonth));
          expect(find.textContaining(digits('E-000003')), findsOneWidget);
          expect(find.textContaining(digits('7.00')), findsNWidgets(2));
        });

        testWidgets('an empty period shows the empty state with Record', (
          tester,
        ) async {
          await open(tester, RoutePaths.expenses);
          expect(find.text(l10n.expensesEmptyTitle), findsOneWidget);
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.expenseNewAction),
          );
          expect(currentPath(tester), RoutePaths.expenseNew);
        });

        testWidgets('categories: add, rename, archive and restore; an '
            'archived one keeps its name on old expenses (US3-6)', (
          tester,
        ) async {
          await open(tester, RoutePaths.expenseCategories);
          expect(find.text(l10n.expenseCategoryRent), findsOneWidget);

          await tester.enterText(
            find.widgetWithText(TextField, l10n.categoryAddHint),
            'Internet',
          );
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.categoryAddAction),
          );
          expect(find.text('Internet'), findsOneWidget);

          // A row is its name and, below it, its buttons.
          Finder rowOf(String name) => find
              .ancestor(of: find.text(name), matching: find.byType(Column))
              .first;
          final row = rowOf('Internet');
          await tapVisible(
            tester,
            find.descendant(
              of: row,
              matching: find.byTooltip(l10n.categoryRename),
            ),
          );
          await tester.enterText(
            find.widgetWithText(TextField, l10n.categoryNameLabel),
            'إنترنت',
          );
          await tester.tap(find.widgetWithText(FilledButton, l10n.saveAction));
          await tester.pumpAndSettle();
          expect(find.text('إنترنت'), findsOneWidget);

          final internet = store.categories.firstWhere(
            (c) => c.name == 'إنترنت',
          );
          seed(internet.id, 'إنترنت', 1, 20000);
          await tapVisible(
            tester,
            find.descendant(
              of: rowOf('إنترنت'),
              matching: find.byTooltip(l10n.expenseCategoryArchive),
            ),
          );
          await tester.tap(
            find.widgetWithText(FilledButton, l10n.expenseCategoryArchive),
          );
          await tester.pumpAndSettle();
          expect(find.text(l10n.expenseCategoriesArchived), findsOneWidget);
          expect(
            store.categories.firstWhere((c) => c.id == internet.id).archived,
            isTrue,
          );
          expect(store.expenses.single.category.name, 'إنترنت');

          await tapVisible(tester, find.text(l10n.expenseCategoryRestore));
          expect(find.text(l10n.expenseCategoriesArchived), findsNothing);
        });

        testWidgets('a taken name is refused ignoring letter forms (US3-7)', (
          tester,
        ) async {
          store.addCategory('إيجار');
          await open(tester, RoutePaths.expenseCategories);
          await tester.enterText(
            find.widgetWithText(TextField, l10n.categoryAddHint),
            '  ايجار ',
          );
          await tapVisible(
            tester,
            find.widgetWithText(FilledButton, l10n.categoryAddAction),
          );
          expect(
            find.text(l10n.errorExpenseCategoryNameTaken('إيجار')),
            findsOneWidget,
          );
          expect(store.categories, hasLength(1));
        });

        testWidgets('Home opens the form; Reports links to the list', (
          tester,
        ) async {
          await open(tester, RoutePaths.home);
          await tapVisible(tester, find.text(l10n.expenseNewAction));
          expect(currentPath(tester), RoutePaths.expenseNew);

          await goTo(tester, RoutePaths.reports);
          await tapVisible(
            tester,
            find.widgetWithText(OutlinedButton, l10n.expensesTitle),
          );
          expect(currentPath(tester), RoutePaths.expenses);
        });
      });
    }
  }
}
