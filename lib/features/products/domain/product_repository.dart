import 'package:equatable/equatable.dart';

import '../../../core/utils/result.dart';
import 'product.dart';
import 'product_draft.dart';
import 'product_errors.dart';
import 'product_query.dart';

/// Products and their derived stock (contracts/repositories-and-domain.md).
abstract interface class ProductRepository {
  /// Active products matching [query], in list order (research R4, R5).
  Stream<List<ProductSummary>> watchSummaries(ProductQuery query);

  /// The [limit] lowest low-stock products and the total count (FR-001a).
  Stream<LowStockSnapshot> watchLowStock({int limit = 5});

  /// One product, archived or not; null when it does not exist.
  Stream<ProductSummary?> watchSummary(String id);

  Stream<List<ProductSummary>> watchArchived();

  /// The active product with this barcode (folded like saved barcodes), or
  /// null (003 research R2).
  Future<ProductSummary?> activeByBarcode(String barcode);

  /// Saves a new product and, when `draft.opening` is set, its opening stock
  /// and average cost, all in one transaction.
  Future<Result<ProductSaved, ProductSaveError>> create(ProductDraft draft);

  /// Saves edits. Never changes stock or average cost; `draft.opening` is
  /// ignored.
  Future<Result<ProductSaved, ProductSaveError>> update(
    String id,
    ProductDraft draft,
  );

  Future<void> archive(String id);

  Future<Result<void, RestoreError>> restore(String id);
}

/// A saved product, and whether another active product has the same name
/// (research R14).
final class ProductSaved extends Equatable {
  const ProductSaved({required this.id, required this.nameExistsElsewhere});

  final String id;
  final bool nameExistsElsewhere;

  @override
  List<Object?> get props => [id, nameExistsElsewhere];
}
