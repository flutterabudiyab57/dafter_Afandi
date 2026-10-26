import '../../../core/utils/result.dart';
import 'purchase.dart';
import 'purchase_draft.dart';
import 'purchase_errors.dart';

/// Purchase invoices (contracts/repositories-and-screens.md).
abstract interface class PurchaseRepository {
  /// Saves the purchase in one transaction (research R7).
  Future<Result<PurchaseSaved, PurchaseSaveError>> create(PurchaseDraft draft);

  /// Purchases matching [query], newest invoice date first, at most
  /// [limit].
  Stream<List<PurchaseSummary>> watchList(
    PurchaseQuery query, {
    int limit = 50,
  });

  /// One purchase; null when it does not exist.
  Stream<Purchase?> watchOne(String id);

  /// The unit cost on [productId]'s newest purchase line that is not voided,
  /// or null when it was never bought (research R14).
  Future<int?> lastUnitCost(String productId);

  /// Voids a whole purchase in one transaction (research R9). Without
  /// [acknowledgeShortage], stock going below zero returns
  /// [VoidStockShortage] and writes nothing.
  Future<Result<void, PurchaseVoidError>> voidPurchase(
    String id,
    String reason, {
    bool acknowledgeShortage = false,
  });
}
