import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/counters_dao.dart';
import '../../../core/database/daos/customer_ledger_dao.dart';
import '../../../core/database/daos/customers_dao.dart';
import '../../../core/database/daos/products_dao.dart';
import '../../../core/database/daos/sales_dao.dart';
import '../../../core/database/daos/stock_movements_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/arabic_normalize.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/id.dart';
import '../../../core/utils/money.dart';
import '../../../core/utils/quantity.dart';
import '../../../core/utils/result.dart';
import '../../customers/data/customer_mappers.dart';
import '../../customers/domain/payment.dart';
import '../domain/sale.dart';
import '../domain/sale_draft.dart';
import '../domain/sale_errors.dart';
import '../domain/sales_repository.dart';

final class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(
    this._sales,
    this._products,
    this._movements,
    this._customers,
    this._ledger,
    this._counters,
    this._tx,
    this._ids,
    this._clock,
  );

  final SalesDao _sales;
  final ProductsDao _products;
  final StockMovementsDao _movements;
  final CustomersDao _customers;
  final CustomerLedgerDao _ledger;
  final CountersDao _counters;
  final TransactionRunner _tx;
  final IdGenerator _ids;
  final Clock _clock;

  /// Reads first, then W1 number, W2 header, W3 lines, W4 SALE movements,
  /// W5 SALE and W6 PAYMENT_RECEIVED rows for a named customer (research
  /// R10).
  @override
  Future<Result<SaleSaved, SaleSaveError>> create(
    SaleDraft draft, {
    bool acknowledgeShortage = false,
  }) => _tx.run(() async {
    final invalid = draft.validate();
    if (invalid.isNotEmpty) return Err(SaleInvalid(invalid));

    final products = <String, ProductRow>{};
    final shortages = <Shortage>[];
    for (final line in draft.lines) {
      final p = await _products.byId(line.productId);
      if (p == null || p.archivedAt != null) {
        return Err(ProductUnavailable(line.name));
      }
      // The unit can change while the sale is open (no history yet).
      if (!p.unitType.allowsFraction && line.qtyMilli % milliPerUnit != 0) {
        return Err(SaleInvalid([LineQuantityInvalid(line.productId)]));
      }
      products[p.id] = p;
      final stock = await _movements.stockOf(p.id);
      if (line.qtyMilli > stock) {
        shortages.add(
          Shortage(
            productId: p.id,
            name: p.name,
            unit: p.unitType,
            stockMilli: stock,
            needMilli: line.qtyMilli,
          ),
        );
      }
    }
    final customer = draft.customer;
    if (customer != null) {
      final c = await _customers.byId(customer.id);
      if (c == null || c.archivedAt != null) {
        return const Err(CustomerUnavailable());
      }
    }
    if (shortages.isNotEmpty && !acknowledgeShortage) {
      return Err(StockShortage(shortages));
    }

    final now = _clock.nowUtc();
    final number = await _counters.take(db.DocType.SALE, now);
    final invoiceId = _ids.newId();
    await _sales.insertInvoice(
      SalesInvoicesCompanion.insert(
        id: invoiceId,
        number: number,
        customerId: Value(customer?.id),
        subtotalPiasters: draft.subtotal,
        discountPiasters: Value(draft.invoiceDiscountPiasters),
        totalPiasters: draft.total,
        paidAtSalePiasters: draft.paid,
        paymentMethod: Value(CustomerMappers.toDb(draft.method)),
        note: Value(draft.note),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final shares = draft.shares;
    for (final (i, line) in draft.lines.indexed) {
      final p = products[line.productId]!;
      final itemId = _ids.newId();
      await _sales.insertItem(
        SaleItemsCompanion.insert(
          id: itemId,
          salesInvoiceId: invoiceId,
          lineNo: i + 1,
          productId: p.id,
          productNameSnapshot: p.name,
          unitTypeSnapshot: p.unitType,
          qtyMilli: line.qtyMilli,
          unitPricePiasters: line.unitPricePiasters,
          discountPiasters: line.lineDiscountPiasters,
          lineTotalPiasters: line.lineTotal,
          invoiceDiscountSharePiasters: shares[i],
          unitCostPiasters: p.avgCostPiasters,
          lineCostPiasters: lineTotalPiasters(line.qtyMilli, p.avgCostPiasters),
        ),
      );
      await _movements.insertMovement(
        StockMovementsCompanion.insert(
          id: _ids.newId(),
          productId: p.id,
          movementType: db.MovementType.SALE,
          qtyDeltaMilli: -line.qtyMilli,
          unitCostPiasters: p.avgCostPiasters,
          saleItemId: Value(itemId),
          createdAt: now,
        ),
      );
    }
    if (customer != null) {
      if (draft.total > 0) {
        await _ledger.insertEntry(
          CustomerLedgerCompanion.insert(
            id: _ids.newId(),
            customerId: customer.id,
            entryType: db.CustomerEntryType.SALE,
            amountPiasters: draft.total,
            salesInvoiceId: Value(invoiceId),
            createdAt: now,
          ),
        );
      }
      if (draft.paid > 0) {
        await _ledger.insertEntry(
          CustomerLedgerCompanion.insert(
            id: _ids.newId(),
            customerId: customer.id,
            entryType: db.CustomerEntryType.PAYMENT_RECEIVED,
            amountPiasters: -draft.paid,
            salesInvoiceId: Value(invoiceId),
            paymentMethod: Value(CustomerMappers.toDb(draft.method)),
            createdAt: now,
          ),
        );
      }
    }
    return Ok(SaleSaved(id: invoiceId, number: number));
  });

  @override
  Stream<List<SaleSummary>> watchList(SaleQuery query, {int limit = 50}) =>
      _sales
          .watchList(
            number: query.number,
            normalizedText: arabicNormalize(query.text),
            unpaidOnly: query.unpaidOnly,
            customerId: query.customerId,
            limit: limit,
          )
          .map((rows) => rows.map(_summary).toList());

  @override
  Stream<SaleInvoice?> watchOne(String id) =>
      _sales.watchOne(id).asyncMap((row) async {
        if (row == null) return null;
        final i = row.invoice;
        final items = await _sales.items(id);
        return SaleInvoice(
          summary: _summary(row),
          subtotalPiasters: i.subtotalPiasters,
          invoiceDiscountPiasters: i.discountPiasters,
          method: CustomerMappers.method(i.paymentMethod),
          note: i.note,
          voidedAt: i.voidedAt,
          voidReason: i.voidReason,
          items: [
            for (final s in items)
              SaleItem(
                lineNo: s.lineNo,
                productId: s.productId,
                name: s.productNameSnapshot,
                unit: s.unitTypeSnapshot,
                qtyMilli: s.qtyMilli,
                unitPricePiasters: s.unitPricePiasters,
                lineDiscountPiasters: s.discountPiasters,
                lineTotalPiasters: s.lineTotalPiasters,
              ),
          ],
        );
      });

  /// R1 not voided; V1 void fields; per line V2 SALE_VOID and V3 average
  /// cost; with a customer V4 SALE_VOID and V5 REVERSAL rows (research R11).
  @override
  Future<Result<void, VoidError>> voidSale(String id, String reason) =>
      _tx.run(() async {
        final String trimmed;
        switch (validateReason(reason)) {
          case Ok(:final value):
            trimmed = value;
          case Err():
            return const Err(VoidReasonInvalid());
        }
        final invoice = await _sales.byId(id);
        if (invoice == null) return const Err(InvoiceNotFound());
        if (invoice.voidedAt != null) return const Err(AlreadyVoided());
        final now = _clock.nowUtc();
        await _sales.setVoided(id, trimmed, now);

        for (final item in await _sales.items(id)) {
          final sale = await _movements.saleMovementOf(item.id);
          if (sale == null) throw StateError('no SALE movement for ${item.id}');
          final product = await _products.byId(item.productId);
          if (product == null) throw StateError('no product ${item.productId}');
          final stockBefore = await _movements.stockOf(item.productId);
          await _movements.insertMovement(
            StockMovementsCompanion.insert(
              id: _ids.newId(),
              productId: item.productId,
              movementType: db.MovementType.SALE_VOID,
              qtyDeltaMilli: item.qtyMilli,
              unitCostPiasters: item.unitCostPiasters,
              saleItemId: Value(item.id),
              reversesMovementId: Value(sale.id),
              createdAt: now,
            ),
          );
          await _products.setAvgCost(
            item.productId,
            weightedAverageCost(
              stockMilli: stockBefore,
              avgCostPiasters: product.avgCostPiasters,
              inQtyMilli: item.qtyMilli,
              inTotalCostPiasters: lineTotalPiasters(
                item.qtyMilli,
                item.unitCostPiasters,
              ),
            ),
            now,
          );
        }

        final customerId = invoice.customerId;
        if (customerId != null) {
          for (final row in await _ledger.rowsForInvoice(id)) {
            final type = switch (row.entryType) {
              db.CustomerEntryType.SALE => db.CustomerEntryType.SALE_VOID,
              db.CustomerEntryType.PAYMENT_RECEIVED =>
                db.CustomerEntryType.REVERSAL,
              _ => null,
            };
            if (type == null) continue;
            await _ledger.insertEntry(
              CustomerLedgerCompanion.insert(
                id: _ids.newId(),
                customerId: customerId,
                entryType: type,
                amountPiasters: -row.amountPiasters,
                salesInvoiceId: Value(id),
                reversesEntryId: Value(row.id),
                note: Value(trimmed),
                createdAt: now,
              ),
            );
          }
        }
        return const Ok(null);
      });

  SaleSummary _summary(SaleListRow row) {
    final i = row.invoice;
    return SaleSummary(
      id: i.id,
      number: i.number,
      at: i.createdAt,
      totalPiasters: i.totalPiasters,
      paidPiasters: i.paidAtSalePiasters,
      customerId: i.customerId,
      customerName: row.customerName,
      voided: i.voidedAt != null,
    );
  }
}
