import 'package:equatable/equatable.dart';

import '../../payments/domain/payment_method.dart';
import '../../payments/domain/payment_split.dart';
import '../../reports/domain/report_period.dart';

/// A category name, in code points (data-model "ExpenseCategory").
const int maxExpenseCategoryNameLength = 50;

/// The most one expense may be: 10,000,000 EGP.
const int maxExpensePiasters = 1000000000;

/// An expense note, in code points.
const int maxExpenseNoteLength = 200;

/// A kind of shop expense: rent, electricity, or one the owner added.
final class ExpenseCategory extends Equatable {
  const ExpenseCategory({
    required this.id,
    required this.name,
    this.archived = false,
  });

  final String id;
  final String name;
  final bool archived;

  @override
  List<Object?> get props => [id, name, archived];
}

/// A saved expense (data-model "Expense"). Voided once, never edited.
final class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.number,
    required this.category,
    required this.amountPiasters,
    required this.parts,
    required this.spentOn,
    required this.createdAt,
    this.note,
    this.voidedAt,
    this.voidReason,
  });

  final String id;

  /// Shown as E-n.
  final int number;

  /// Its name stays after the category is archived.
  final ExpenseCategory category;
  final int amountPiasters;

  /// How it was paid; part 1 first.
  final List<PaymentPart> parts;

  /// Local midnight of the day it was spent.
  final DateTime spentOn;
  final DateTime createdAt;
  final String? note;
  final DateTime? voidedAt;
  final String? voidReason;

  bool get isVoided => voidedAt != null;

  /// Part 1's method, as the list shows it.
  PaymentMethod get method => parts.first.method;

  @override
  List<Object?> get props => [
    id,
    number,
    category,
    amountPiasters,
    parts,
    spentOn,
    createdAt,
    note,
    voidedAt,
    voidReason,
  ];
}

/// A newly saved expense.
final class ExpenseSaved extends Equatable {
  const ExpenseSaved({required this.id, required this.number});

  final String id;
  final int number;

  @override
  List<Object?> get props => [id, number];
}

/// Which expenses a list shows: a period, and one category or all.
final class ExpenseQuery extends Equatable {
  const ExpenseQuery({required this.period, this.categoryId});

  final ReportPeriod period;
  final String? categoryId;

  ExpenseQuery copyWith({
    ReportPeriod? period,
    String? Function()? categoryId,
  }) => ExpenseQuery(
    period: period ?? this.period,
    categoryId: categoryId == null ? this.categoryId : categoryId(),
  );

  @override
  List<Object?> get props => [period, categoryId];
}
