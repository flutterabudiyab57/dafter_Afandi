import '../../../core/utils/result.dart';
import 'adjustment.dart';
import 'product_draft.dart';
import 'product_errors.dart';
import 'stock_entry.dart';

/// Stock changes for one product (contracts/repositories-and-domain.md).
abstract interface class InventoryRepository {
  /// Records the opening stock and sets the average cost, in one transaction.
  /// Allowed only while the product has no history; otherwise
  /// `Err(OpeningNotAllowed())`.
  Future<Result<void, ProductSaveError>> setOpening(
    String productId,
    OpeningStock opening,
  );

  /// In one transaction: reads the stock, checks [request] against it and
  /// records one adjustment (or nothing, for `AlreadyMatches`). Never changes
  /// the average cost.
  Future<Result<AdjustmentResult, AdjustmentError>> adjust(
    String productId,
    AdjustmentRequest request,
  );

  /// Newest first; [before] continues from the previous page.
  Future<List<StockEntry>> history(
    String productId, {
    StockEntryCursor? before,
    int limit = 50,
  });

  /// Rebuilds the average cost by replaying the history (research R7), stores
  /// it and returns it. For maintenance and tests.
  Future<int> rebuildAverageCost(String productId);
}
