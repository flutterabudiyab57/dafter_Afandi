import 'package:equatable/equatable.dart';

import '../../../core/utils/text_length.dart';
import 'product_errors.dart';

/// A named group of products (data-model.md).
final class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.productCount = 0,
  });

  final String id;
  final String name;
  final int sortOrder;

  /// Active products in this category.
  final int productCount;

  @override
  List<Object?> get props => [id, name, sortOrder, productCount];
}

enum MoveDirection { up, down }

/// The name's error, or null when it is valid: trimmed, 1–40 code points.
/// Duplicates are checked by the repository.
CategoryError? validateCategoryName(String raw) {
  final length = codePointLength(raw.trim());
  if (length == 0) return const CategoryNameRequired();
  if (length > maxCategoryNameLength) {
    return const CategoryNameTooLong(maxCategoryNameLength);
  }
  return null;
}
