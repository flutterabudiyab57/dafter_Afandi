import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/counters_dao.dart';
import '../../../core/database/daos/products_dao.dart';
import '../../../core/database/daos/purchases_dao.dart';
import '../../../core/database/daos/stock_movements_dao.dart';
import '../../../core/database/daos/supplier_ledger_dao.dart';
import '../../../core/database/daos/suppliers_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/arabic_normalize.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/digits.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/quantity.dart';
import '../../../core/utils/result.dart';
import '../../customers/data/customer_mappers.dart';
import '../../customers/domain/payment.dart';
import '../../products/data/inventory_repository_impl.dart'
    show replayedAverageCost;
import '../domain/purchase.dart';
import '../domain/purchase_draft.dart';
import '../domain/purchase_errors.dart';
import '../domain/purchase_repository.dart';

final class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(
    this._purchases,
    this._products,
    this._movements,
    this._suppliers,
    this._ledger,
    this._counters,
    this._tx,
    this._ids,
    this._clock,
  );

  final PurchasesDao _purchases;
  final ProductsDao _products;
  final StockMovementsDao _movements;
  final SuppliersDao _suppliers;
  final SupplierLedgerDao _ledger;
  final CountersDao _counters;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;

  /// Reads first, then W1 number, W2 header, per line W3 item, W4 PURCHASE
  /// movement and W5 average cost, then W6 PURCHASE and W7 PAYMENT_MADE rows
  /// for a supplier (research R7).
  @override
  Future<Result<PurchaseSaved, PurchaseSaveError>> create(
    PurchaseDraft draft,
  ) => _tx.run(() async {
    final now = _clock.nowUtc();
    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    final invalid = draft.validate(today: today);
    if (invalid.isNotEmpty) return Err(PurchaseInvalid(invalid));

    final products = <String, ProductRow>{};
    for (final line in draft.lines) {
      final p = await _products.byId(line.productId);
      if (p == null || p.archivedAt != null) {
        return Err(PurchaseProductUnavailable(line.name));
      }
      // The unit can change while the purchase is open (no history yet).
      if (!p.unitType.allowsFraction && line.qtyMilli % milliPerUnit != 0) {
        return Err(PurchaseInvalid([PurchaseQuantityInvalid(line.productId)]));
      }
      products[p.id] = p;
    }
    final supplier = draft.supplier;
    if (supplier != null) {
      final s = await _suppliers.byId(supplier.id);
      if (s == null || s.archivedAt != null) {
        return const Err(SupplierUnavailable());
      }
    }

    final number = await _counters.take(db.DocType.PURCHASE, now);
    final invoiceId = _ids.newId();
    final ref = draft.supplierRef;
    await _purchases.insertInvoice(
      PurchaseInvoicesCompanion.insert(
        id: invoiceId,
        number: number,
        supplierId: Value(supplier?.id),
        // Latin digits, so the list search finds it however it was typed.
        supplierRef: Value(ref == null ? null : normalizeDigits(ref)),
        invoiceDate: (draft.invoiceDate ?? today).toUtc(),
        subtotalPiasters: draft.subtotal,
        discountPiasters: Value(draft.invoiceDiscountPiasters),
        totalPiasters: draft.total,
        paidPiasters: draft.paid,
        paymentMethod: Value(CustomerMappers.toDb(draft.method)),
        note: Value(draft.note),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final shares = draft.shares;
    final netCosts = draft.netLineCosts;
    for (final (i, line) in draft.lines.indexed) {
      final p = products[line.productId]!;
      final stock = await _movements.stockOf(p.id);
      final before = (await _products.byId(p.id))!.avgCostPiasters;
      final after = weightedAverageCost(
        stockMilli: stock,
        avgCostPiasters: before,
        inQtyMilli: line.qtyMilli,
        inTotalCostPiasters: netCosts[i],
      );
      final itemId = _ids.newId();
      await _purchases.insertItem(
        PurchaseItemsCompanion.insert(
          id: itemId,
          purchaseInvoiceId: invoiceId,
          lineNo: i + 1,
          productId: p.id,
          productNameSnapshot: p.name,
          qtyMilli: line.qtyMilli,
          unitCostPiasters: line.unitCostPiasters,
          discountPiasters: Value(line.lineDiscountPiasters),
          lineTotalPiasters: line.lineTotal,
          invoiceDiscountSharePiasters: shares[i],
          netLineCostPiasters: netCosts[i],
          avgCostBeforePiasters: before,
          avgCostAfterPiasters: after,
          createdAt: now,
        ),
      );
      await _movements.insertMovement(
        StockMovementsCompanion.insert(
          id: _ids.newId(),
          productId: p.id,
          movementType: db.MovementType.PURCHASE,
          qtyDeltaMilli: line.qtyMilli,
          unitCostPiasters: roundHalfUpDiv(
            netCosts[i] * milliPerUnit,
            line.qtyMilli,
          ),
          purchaseItemId: Value(itemId),
          createdAt: now,
        ),
      );
      await _products.setAvgCost(p.id, after, now);
    }
    if (supplier != null) {
      if (draft.total > 0) {
        await _ledger.insertEntry(
          SupplierLedgerCompanion.insert(
            id: _ids.newId(),
            supplierId: supplier.id,
            entryType: db.SupplierEntryType.PURCHASE,
            amountPiasters: draft.total,
            purchaseInvoiceId: Value(invoiceId),
            createdAt: now,
          ),
        );
      }
      if (draft.paid > 0) {
        await _ledger.insertEntry(
          SupplierLedgerCompanion.insert(
            id: _ids.newId(),
            supplierId: supplier.id,
            entryType: db.SupplierEntryType.PAYMENT_MADE,
            amountPiasters: -draft.paid,
            purchaseInvoiceId: Value(invoiceId),
            paymentMethod: Value(CustomerMappers.toDb(draft.method)),
            createdAt: now,
          ),
        );
      }
    }
    return Ok(PurchaseSaved(id: invoiceId, number: number));
  });

  @override
  Stream<List<PurchaseSummary>> watchList(
    PurchaseQuery query, {
    int limit = 50,
  }) => _purchases
      .watchList(
        number: query.number,
        normalizedText: arabicNormalize(query.text),
        unpaidOnly: query.unpaidOnly,
        supplierId: query.supplierId,
        limit: limit,
      )
      .map((rows) => rows.map(_summary).toList());

  @override
  Stream<Purchase?> watchOne(String id) =>
      _purchases.watchOne(id).asyncMap((row) async {
        if (row == null) return null;
        final i = row.invoice;
        final items = <PurchaseItem>[];
        for (final p in await _purchases.items(id)) {
          final product = await _products.byId(p.productId);
          if (product == null) throw StateError('no product ${p.productId}');
          items.add(
            PurchaseItem(
              lineNo: p.lineNo,
              productId: p.productId,
              name: p.productNameSnapshot,
              unit: product.unitType,
              qtyMilli: p.qtyMilli,
              unitCostPiasters: p.unitCostPiasters,
              lineDiscountPiasters: p.discountPiasters,
              lineTotalPiasters: p.lineTotalPiasters,
            ),
          );
        }
        return Purchase(
          summary: _summary(row),
          subtotalPiasters: i.subtotalPiasters,
          invoiceDiscountPiasters: i.discountPiasters,
          method: CustomerMappers.method(i.paymentMethod),
          note: i.note,
          voidedAt: i.voidedAt,
          voidReason: i.voidReason,
          items: items,
        );
      });

  @override
  Future<int?> lastUnitCost(String productId) =>
      _purchases.lastUnitCost(productId);

  /// Reads and the shortage check first, then V1 void fields, per line V2
  /// PURCHASE_VOID, per product V3 the replayed average cost, and with a
  /// supplier V4 PURCHASE_VOID and V5 REVERSAL rows (research R9).
  @override
  Future<Result<void, PurchaseVoidError>> voidPurchase(
    String id,
    String reason, {
    bool acknowledgeShortage = false,
  }) => _tx.run(() async {
    final String trimmed;
    switch (validateReason(reason)) {
      case Ok(:final value):
        trimmed = value;
      case Err():
        return const Err(PurchaseVoidReasonInvalid());
    }
    final invoice = await _purchases.byId(id);
    if (invoice == null) return const Err(PurchaseNotFound());
    if (invoice.voidedAt != null) return const Err(PurchaseAlreadyVoided());

    final items = await _purchases.items(id);
    final voidedQty = <String, int>{};
    for (final item in items) {
      voidedQty.update(
        item.productId,
        (q) => q + item.qtyMilli,
        ifAbsent: () => item.qtyMilli,
      );
    }
    final shortages = <VoidShortage>[];
    for (final MapEntry(key: productId, value: qty) in voidedQty.entries) {
      final after = await _movements.stockOf(productId) - qty;
      if (after < 0) {
        final p = await _products.byId(productId);
        if (p == null) throw StateError('no product $productId');
        shortages.add(
          VoidShortage(
            productId: productId,
            name: p.name,
            unit: p.unitType,
            stockAfterMilli: after,
          ),
        );
      }
    }
    if (shortages.isNotEmpty && !acknowledgeShortage) {
      return Err(VoidStockShortage(shortages));
    }

    final now = _clock.nowUtc();
    await _purchases.setVoided(id, trimmed, now);
    for (final item in items) {
      final purchase = await _movements.purchaseMovementOf(item.id);
      if (purchase == null) {
        throw StateError('no PURCHASE movement for ${item.id}');
      }
      await _movements.insertMovement(
        StockMovementsCompanion.insert(
          id: _ids.newId(),
          productId: item.productId,
          movementType: db.MovementType.PURCHASE_VOID,
          qtyDeltaMilli: -item.qtyMilli,
          unitCostPiasters: purchase.unitCostPiasters,
          purchaseItemId: Value(item.id),
          reversesMovementId: Value(purchase.id),
          createdAt: now,
        ),
      );
    }
    for (final productId in voidedQty.keys) {
      await _products.setAvgCost(
        productId,
        await replayedAverageCost(_movements, productId),
        now,
      );
    }

    final supplierId = invoice.supplierId;
    if (supplierId != null) {
      for (final row in await _ledger.rowsForPurchase(id)) {
        final type = switch (row.entryType) {
          db.SupplierEntryType.PURCHASE => db.SupplierEntryType.PURCHASE_VOID,
          db.SupplierEntryType.PAYMENT_MADE => db.SupplierEntryType.REVERSAL,
          _ => null,
        };
        if (type == null) continue;
        await _ledger.insertEntry(
          SupplierLedgerCompanion.insert(
            id: _ids.newId(),
            supplierId: supplierId,
            entryType: type,
            amountPiasters: -row.amountPiasters,
            purchaseInvoiceId: Value(id),
            reversesEntryId: Value(row.id),
            note: Value(trimmed),
            createdAt: now,
          ),
        );
      }
    }
    return const Ok(null);
  });

  PurchaseSummary _summary(PurchaseListRow row) {
    final i = row.invoice;
    final date = i.invoiceDate.toLocal();
    return PurchaseSummary(
      id: i.id,
      number: i.number,
      invoiceDate: DateTime(date.year, date.month, date.day),
      at: i.createdAt,
      totalPiasters: i.totalPiasters,
      paidPiasters: i.paidPiasters,
      supplierId: i.supplierId,
      supplierName: row.supplierName,
      supplierRef: i.supplierRef,
      voided: i.voidedAt != null,
    );
  }
}
