import '../../../core/utils/result.dart';
import 'category.dart';
import 'product_errors.dart';

/// Product categories (contracts/repositories-and-domain.md).
abstract interface class CategoryRepository {
  /// Active categories in display order, with their product counts.
  Stream<List<Category>> watchActive();

  Future<Result<Category, CategoryError>> create(String name);

  Future<Result<void, CategoryError>> rename(String id, String name);

  /// Keeps the category's products; they then show as having no category.
  Future<void> archive(String id);

  /// Swaps with the neighbour in [direction], in one transaction.
  Future<void> move(String id, MoveDirection direction);
}
