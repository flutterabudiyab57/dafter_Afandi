import 'package:get_it/get_it.dart';

import '../../../core/utils/clock.dart';
import '../../reports/presentation/cubits/report_period_cubit.dart';
import '../domain/expense_repository.dart';
import 'cubits/expense_categories_cubit.dart';
import 'cubits/expense_cubit.dart';
import 'cubits/expense_form_cubit.dart';
import 'cubits/expenses_list_cubit.dart';

/// Builds every expenses cubit (006). The app uses [AppExpensesCubits];
/// widget tests pass a bundle built on fakes.
abstract class ExpensesCubits {
  /// The list for the period shared by the report screens.
  ExpensesListCubit expensesList(ReportPeriodCubit periods);

  ExpenseFormCubit expenseForm();

  ExpenseCubit expense(String id);

  ExpenseCategoriesCubit expenseCategories();
}

/// Cubits built on the repositories in [locator].
final class AppExpensesCubits implements ExpensesCubits {
  const AppExpensesCubits(this.locator);

  final GetIt locator;

  ExpenseRepository get _expenses => locator<ExpenseRepository>();

  ExpenseCategoryRepository get _categories =>
      locator<ExpenseCategoryRepository>();

  @override
  ExpensesListCubit expensesList(ReportPeriodCubit periods) =>
      ExpensesListCubit(_expenses, _categories, periods);

  @override
  ExpenseFormCubit expenseForm() =>
      ExpenseFormCubit(_expenses, _categories, locator<Clock>());

  @override
  ExpenseCubit expense(String id) => ExpenseCubit(_expenses, id);

  @override
  ExpenseCategoriesCubit expenseCategories() =>
      ExpenseCategoriesCubit(_categories);
}
