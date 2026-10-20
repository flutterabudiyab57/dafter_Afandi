import '../../../core/utils/result.dart';
import 'sale.dart';
import 'sale_draft.dart';
import 'sale_errors.dart';

/// Sales invoices (contracts/repositories-and-screens.md).
abstract interface class SalesRepository {
  /// Saves the sale in one transaction (research R10). Without
  /// [acknowledgeShortage], a stock shortage returns [StockShortage] and
  /// writes nothing.
  Future<Result<SaleSaved, SaleSaveError>> create(
    SaleDraft draft, {
    bool acknowledgeShortage = false,
  });

  /// Invoices matching [query], newest first, at most [limit].
  Stream<List<SaleSummary>> watchList(SaleQuery query, {int limit = 50});

  /// One invoice; null when it does not exist.
  Stream<SaleInvoice?> watchOne(String id);

  /// Voids a whole invoice in one transaction (research R11). [reason] is
  /// already validated.
  Future<Result<void, VoidError>> voidSale(String id, String reason);
}
