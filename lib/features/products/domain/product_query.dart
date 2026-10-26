import 'package:equatable/equatable.dart';

import '../../../core/utils/arabic_normalize.dart';

/// Which categories the product list shows.
sealed class CategoryFilter extends Equatable {
  const CategoryFilter();

  @override
  List<Object?> get props => [];
}

final class AllCategories extends CategoryFilter {
  const AllCategories();
}

/// Products with no category, or whose category is archived (research R17).
final class NoCategory extends CategoryFilter {
  const NoCategory();
}

final class InCategory extends CategoryFilter {
  const InCategory(this.categoryId);

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

/// The product list's search and filters (FR-009, FR-010).
final class ProductQuery extends Equatable {
  const ProductQuery({
    this.text = '',
    this.categoryFilter = const AllCategories(),
    this.lowOnly = false,
  });

  /// As typed.
  final String text;
  final CategoryFilter categoryFilter;
  final bool lowOnly;

  /// The search text folded like `searchKey` (research R4); empty means no
  /// search.
  String get normalizedText => arabicNormalize(text);

  ProductQuery copyWith({
    String? text,
    CategoryFilter? categoryFilter,
    bool? lowOnly,
  }) => ProductQuery(
    text: text ?? this.text,
    categoryFilter: categoryFilter ?? this.categoryFilter,
    lowOnly: lowOnly ?? this.lowOnly,
  );

  @override
  List<Object?> get props => [text, categoryFilter, lowOnly];
}
