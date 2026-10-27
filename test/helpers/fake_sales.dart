import 'dart:async';

import 'package:daftar_afandi/core/utils/arabic_normalize.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/customer.dart';
import 'package:daftar_afandi/features/customers/domain/customer_draft.dart';
import 'package:daftar_afandi/features/customers/domain/customer_errors.dart';
import 'package:daftar_afandi/features/customers/domain/customer_repository.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/customer_details_cubit.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/customer_form_cubit.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/customers_list_cubit.dart';
import 'package:daftar_afandi/features/customers/presentation/cubits/payment_cubit.dart';
import 'package:daftar_afandi/features/customers/presentation/customers_cubits.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_picker_cubit.dart';
import 'package:daftar_afandi/features/sales/domain/sale.dart';
import 'package:daftar_afandi/features/sales/domain/sale_draft.dart';
import 'package:daftar_afandi/features/sales/domain/sale_errors.dart';
import 'package:daftar_afandi/features/sales/domain/sales_repository.dart';
import 'package:daftar_afandi/features/sales/presentation/cubits/sale_cubit.dart';
import 'package:daftar_afandi/features/sales/presentation/cubits/sales_list_cubit.dart';
import 'package:daftar_afandi/features/sales/presentation/sales_cubits.dart';

import 'fake_products.dart';

final class _Row {
  _Row({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.at,
    required this.order,
    this.invoiceId,
    this.receipt,
    this.method,
    this.note,
    this.reverses,
  });

  final String id;
  final String customerId;
  final LedgerEntryType type;
  final int amount;
  final DateTime at;
  final int order;
  final String? invoiceId;
  final int? receipt;
  final PaymentMethod? method;
  final String? note;
  final String? reverses;
}

final class _StoredSale {
  _StoredSale(this.invoice);

  SaleInvoice invoice;
}

/// In-memory customers, their ledger and sales, on top of a
/// [FakeProductsStore], with the same rules as the real repositories.
final class FakeSalesStore {
  FakeSalesStore([FakeProductsStore? products])
    : products = products ?? FakeProductsStore();

  final FakeProductsStore products;
  final Map<String, Customer> _customers = {};
  final List<_Row> _ledger = [];
  final List<_StoredSale> _sales = [];
  final StreamController<void> _changes = StreamController.broadcast();
  final List<String> writes = [];
  var _nextId = 1;
  var _nextReceipt = 1;
  var _clock = DateTime.utc(2026, 10, 20, 10);

  late final FakeCustomerRepository customers = FakeCustomerRepository(this);
  late final FakeSalesRepository sales = FakeSalesRepository(this);

  String _id(String prefix) => '$prefix${_nextId++}';

  DateTime _now() => _clock = _clock.add(const Duration(minutes: 1));

  void _changed() => _changes.add(null);

  /// When set, the next watch stream fails with it (then it is cleared).
  Object? failNextWatch;

  /// When set, the next paged read (history, statement) throws it (then it
  /// is cleared).
  Object? failNextRead;

  void _read() {
    final failure = failNextRead;
    if (failure != null) {
      failNextRead = null;
      throw failure;
    }
  }

  Stream<T> _watch<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        final failure = failNextWatch;
        if (failure != null) {
          failNextWatch = null;
          controller.addError(failure);
          return;
        }
        changes = _changes.stream.listen((_) => controller.add(read()));
        controller.add(read());
      },
      // Not returned: under fake async the broadcast cancel never completes.
      onCancel: () => unawaited(changes?.cancel()),
    );
    return controller.stream;
  }

  // ---- seeding (no write recorded) ----

  String seedCustomer(
    String name, {
    String? phone,
    int openingPiasters = 0,
    bool archived = false,
  }) {
    final id = _id('k');
    _customers[id] = Customer(
      id: id,
      name: name,
      phone: phone,
      archived: archived,
    );
    if (openingPiasters != 0) {
      _addRow(id, LedgerEntryType.openingBalance, openingPiasters);
    }
    _changed();
    return id;
  }

  _Row _addRow(
    String customerId,
    LedgerEntryType type,
    int amount, {
    String? invoiceId,
    int? receipt,
    PaymentMethod? method,
    String? note,
    String? reverses,
  }) {
    final row = _Row(
      id: _id('l'),
      customerId: customerId,
      type: type,
      amount: amount,
      at: _now(),
      order: _ledger.length + 1,
      invoiceId: invoiceId,
      receipt: receipt,
      method: method,
      note: note,
      reverses: reverses,
    );
    _ledger.add(row);
    return row;
  }

  // ---- reads ----

  int balanceOf(String id) =>
      _ledger.where((r) => r.customerId == id).fold(0, (s, r) => s + r.amount);

  /// When each archived customer was archived, for the purge date.
  final Map<String, DateTime> _archivedAt = {};

  bool hasHistory(String id) =>
      _ledger.any((r) => r.customerId == id) ||
      _sales.any((s) => s.invoice.summary.customerId == id);

  CustomerSummary? customer(String id) {
    final c = _customers[id];
    if (c == null) return null;
    final history = hasHistory(id);
    final archivedAt = _archivedAt[id];
    return CustomerSummary(
      customer: c,
      balancePiasters: balanceOf(id),
      hasHistory: history,
      purgeAt: history || archivedAt == null
          ? null
          : archivedAt.add(kArchivePurgeAfter),
    );
  }

  List<CustomerSummary> activeCustomers([
    CustomerQuery q = const CustomerQuery(),
  ]) {
    final key = q.normalizedText;
    final list = [
      for (final c in _customers.values)
        if (!c.archived &&
            (key.isEmpty ||
                arabicNormalize(c.name).contains(key) ||
                (c.phone ?? '').contains(q.text)))
          customer(c.id)!,
    ];
    if (q.owesOnly) {
      list
        ..removeWhere((s) => s.balancePiasters <= 0)
        ..sort((a, b) => b.balancePiasters.compareTo(a.balancePiasters));
    } else {
      list.sort(
        (a, b) =>
            arabicNormalize(a.customer.name)
                .compareTo(arabicNormalize(b.customer.name)),
      );
    }
    return list;
  }

  List<LedgerEntry> statementOf(String id) {
    var running = 0;
    final rows = _ledger.where((r) => r.customerId == id).toList();
    final entries = <LedgerEntry>[];
    for (final r in rows) {
      running += r.amount;
      entries.add(
        LedgerEntry(
          id: r.id,
          type: r.type,
          amountPiasters: r.amount,
          runningBalancePiasters: running,
          at: r.at,
          rowOrder: r.order,
          invoiceId: r.invoiceId,
          invoiceNumber: r.invoiceId == null
              ? null
              : invoice(r.invoiceId!)?.summary.number,
          receiptNumber: r.receipt,
          method: r.method,
          note: r.note,
          reversed: _ledger.any((x) => x.reverses == r.id),
        ),
      );
    }
    return entries.reversed.toList();
  }

  SaleInvoice? invoice(String id) {
    for (final s in _sales) {
      if (s.invoice.summary.id == id) return s.invoice;
    }
    return null;
  }

  List<SaleSummary> salesList(SaleQuery q) {
    final number = q.number;
    final key = arabicNormalize(q.text);
    return [
      for (final s in _sales.reversed)
        if ((number != null
                ? '${s.invoice.summary.number}'.startsWith('$number')
                : key.isEmpty ||
                      arabicNormalize(s.invoice.summary.customerName ?? '')
                          .contains(key)) &&
            (!q.unpaidOnly ||
                (s.invoice.summary.remainingPiasters > 0 &&
                    !s.invoice.summary.voided)) &&
            (q.customerId == null ||
                s.invoice.summary.customerId == q.customerId))
          s.invoice.summary,
    ];
  }

  /// Saves [draft] directly (no shortage check), for seeding lists.
  String seedSale(SaleDraft draft) {
    final r = _createSale(draft);
    return r.id;
  }

  SaleSaved _createSale(SaleDraft draft) {
    final id = _id('s');
    final number = _sales.length + 1;
    final at = _now();
    final c = draft.customer;
    for (final l in draft.lines) {
      products.seedEntry(l.productId, StockEntryType.sale, -l.qtyMilli);
    }
    _sales.add(
      _StoredSale(
        SaleInvoice(
          summary: SaleSummary(
            id: id,
            number: number,
            at: at,
            totalPiasters: draft.total,
            paidPiasters: draft.paid,
            customerId: c?.id,
            customerName: c == null ? null : _customers[c.id]?.name,
          ),
          subtotalPiasters: draft.subtotal,
          invoiceDiscountPiasters: draft.invoiceDiscountPiasters,
          method: draft.method,
          items: [
            for (final (i, l) in draft.lines.indexed)
              SaleItem(
                lineNo: i + 1,
                productId: l.productId,
                name: l.name,
                unit: l.unit,
                qtyMilli: l.qtyMilli,
                unitPricePiasters: l.unitPricePiasters,
                lineDiscountPiasters: l.lineDiscountPiasters,
                lineTotalPiasters: l.lineTotal,
              ),
          ],
          note: draft.note,
        ),
      ),
    );
    if (c != null) {
      if (draft.total > 0) {
        _addRow(c.id, LedgerEntryType.sale, draft.total, invoiceId: id);
      }
      if (draft.paid > 0) {
        _addRow(
          c.id,
          LedgerEntryType.payment,
          -draft.paid,
          invoiceId: id,
          method: draft.method,
        );
      }
    }
    _changed();
    return SaleSaved(id: id, number: number);
  }
}

final class FakeCustomerRepository implements CustomerRepository {
  FakeCustomerRepository(this._s);

  final FakeSalesStore _s;

  /// The fake keeps no archive dates; purging is tested on the database.
  @override
  Future<int> purgeArchived() async => 0;

  @override
  Stream<List<CustomerSummary>> watchActive(CustomerQuery query) =>
      _s._watch(() => _s.activeCustomers(query));

  @override
  Stream<CustomerSummary?> watchOne(String id) =>
      _s._watch(() => _s.customer(id));

  @override
  Stream<int> watchTotalOwing() => _s._watch(
    () => _s._customers.keys
        .map(_s.balanceOf)
        .where((b) => b > 0)
        .fold(0, (sum, b) => sum + b),
  );

  @override
  Stream<List<CustomerSummary>> watchArchived() => _s._watch(
    () => [
      for (final c in _s._customers.values)
        if (c.archived) _s.customer(c.id)!,
    ],
  );

  bool _sameName(String name, String exceptId) => _s._customers.values.any(
    (c) =>
        c.id != exceptId &&
        !c.archived &&
        arabicNormalize(c.name) == arabicNormalize(name),
  );

  @override
  Future<Result<CustomerSaved, CustomerSaveError>> create(
    CustomerDraft draft,
  ) async {
    _s.writes.add('customer ${draft.name}');
    final id = _s._id('k');
    _s._customers[id] = Customer(
      id: id,
      name: draft.name,
      phone: draft.phone,
      address: draft.address,
      note: draft.note,
    );
    if (draft.openingBalancePiasters != 0) {
      _s._addRow(
        id,
        LedgerEntryType.openingBalance,
        draft.openingBalancePiasters,
      );
    }
    _s._changed();
    return Ok(
      CustomerSaved(id: id, nameExistsElsewhere: _sameName(draft.name, id)),
    );
  }

  @override
  Future<Result<CustomerSaved, CustomerSaveError>> update(
    String id,
    CustomerDraft draft,
  ) async {
    final old = _s._customers[id];
    if (old == null) return const Err(CustomerNotFound());
    _s.writes.add('update $id');
    _s._customers[id] = Customer(
      id: id,
      name: draft.name,
      phone: draft.phone,
      address: draft.address,
      note: draft.note,
      archived: old.archived,
    );
    _s._changed();
    return Ok(
      CustomerSaved(id: id, nameExistsElsewhere: _sameName(draft.name, id)),
    );
  }

  void _setArchived(String id, {required bool archived}) {
    final c = _s._customers[id]!;
    _s._customers[id] = Customer(
      id: id,
      name: c.name,
      phone: c.phone,
      address: c.address,
      note: c.note,
      archived: archived,
    );
    if (archived) {
      _s._archivedAt[id] = _s._now();
    } else {
      _s._archivedAt.remove(id);
    }
    _s._changed();
  }

  @override
  Future<void> archive(String id) async {
    _s.writes.add('archive $id');
    _setArchived(id, archived: true);
  }

  @override
  Future<void> restore(String id) async {
    _s.writes.add('restore $id');
    _setArchived(id, archived: false);
  }

  @override
  Future<List<LedgerEntry>> statement(
    String customerId, {
    LedgerCursor? before,
    int limit = 50,
  }) async {
    _s._read();
    final all = _s.statementOf(customerId);
    final start = before == null
        ? 0
        : all.indexWhere((e) => e.rowOrder == before.rowOrder) + 1;
    return all.skip(start).take(limit).toList();
  }

  @override
  Stream<void> watchStatementChanges(String customerId) => _s
      ._watch(() => _s._ledger.where((r) => r.customerId == customerId).length)
      .distinct();

  @override
  Future<Result<int, PaymentError>> receivePayment(
    String customerId,
    PaymentRequest request,
  ) async {
    final c = _s._customers[customerId];
    if (c == null) return const Err(PaymentCustomerNotFound());
    if (c.archived) return const Err(PaymentCustomerArchived());
    final number = _s._nextReceipt++;
    _s.writes.add('payment $customerId ${request.amountPiasters}');
    _s._addRow(
      customerId,
      LedgerEntryType.payment,
      -request.amountPiasters,
      receipt: number,
      method: request.method,
      note: request.note,
    );
    _s._changed();
    return Ok(number);
  }

  @override
  Future<Result<void, PaymentError>> cancelPayment(
    String entryId,
    String reason,
  ) async {
    if (validateReason(reason) is Err) return const Err(PaymentReasonInvalid());
    final row = _s._ledger.where((r) => r.id == entryId).firstOrNull;
    if (row == null ||
        row.type != LedgerEntryType.payment ||
        row.receipt == null) {
      return const Err(PaymentNotCancellable());
    }
    if (_s._ledger.any((r) => r.reverses == entryId)) {
      return const Err(PaymentAlreadyCancelled());
    }
    _s.writes.add('cancel $entryId');
    _s._addRow(
      row.customerId,
      LedgerEntryType.reversal,
      -row.amount,
      note: reason,
      reverses: entryId,
    );
    _s._changed();
    return const Ok(null);
  }
}

final class FakeSalesRepository implements SalesRepository {
  FakeSalesRepository(this._s);

  final FakeSalesStore _s;

  @override
  Future<Result<SaleSaved, SaleSaveError>> create(
    SaleDraft draft, {
    bool acknowledgeShortage = false,
  }) async {
    final invalid = draft.validate();
    if (invalid.isNotEmpty) return Err(SaleInvalid(invalid));
    final shortages = <Shortage>[];
    for (final l in draft.lines) {
      final p = _s.products.summary(l.productId);
      if (p == null || p.product.archived) {
        return Err(ProductUnavailable(l.name));
      }
      if (l.qtyMilli > p.stockMilli) {
        shortages.add(
          Shortage(
            productId: l.productId,
            name: p.product.name,
            unit: p.product.unit,
            stockMilli: p.stockMilli,
            needMilli: l.qtyMilli,
          ),
        );
      }
    }
    final c = draft.customer;
    if (c != null) {
      final stored = _s._customers[c.id];
      if (stored == null || stored.archived) {
        return const Err(CustomerUnavailable());
      }
    }
    if (shortages.isNotEmpty && !acknowledgeShortage) {
      return Err(StockShortage(shortages));
    }
    _s.writes.add('sale ${draft.total}');
    return Ok(_s._createSale(draft));
  }

  @override
  Stream<List<SaleSummary>> watchList(SaleQuery query, {int limit = 50}) =>
      _s._watch(() => _s.salesList(query).take(limit).toList());

  @override
  Stream<SaleInvoice?> watchOne(String id) => _s._watch(() => _s.invoice(id));

  @override
  Future<Result<void, VoidError>> voidSale(String id, String reason) async {
    if (validateReason(reason) is Err) return const Err(VoidReasonInvalid());
    final stored = _s._sales
        .where((x) => x.invoice.summary.id == id)
        .firstOrNull;
    if (stored == null) return const Err(InvoiceNotFound());
    final inv = stored.invoice;
    if (inv.summary.voided) return const Err(AlreadyVoided());
    _s.writes.add('void $id');
    final at = _s._now();
    for (final item in inv.items) {
      _s.products.seedEntry(
        item.productId,
        StockEntryType.saleVoid,
        item.qtyMilli,
      );
    }
    final cid = inv.summary.customerId;
    if (cid != null) {
      for (final r in [..._s._ledger.where((r) => r.invoiceId == id)]) {
        _s._addRow(
          cid,
          r.type == LedgerEntryType.sale
              ? LedgerEntryType.saleVoid
              : LedgerEntryType.reversal,
          -r.amount,
          invoiceId: id,
          note: reason,
          reverses: r.id,
        );
      }
    }
    final s = inv.summary;
    stored.invoice = SaleInvoice(
      summary: SaleSummary(
        id: s.id,
        number: s.number,
        at: s.at,
        totalPiasters: s.totalPiasters,
        paidPiasters: s.paidPiasters,
        customerId: s.customerId,
        customerName: s.customerName,
        voided: true,
      ),
      subtotalPiasters: inv.subtotalPiasters,
      invoiceDiscountPiasters: inv.invoiceDiscountPiasters,
      method: inv.method,
      items: inv.items,
      note: inv.note,
      voidedAt: at,
      voidReason: reason,
    );
    _s._changed();
    return const Ok(null);
  }
}

/// Real customers cubits on a [FakeSalesStore].
final class FakeCustomersCubits implements CustomersCubits {
  FakeCustomersCubits([FakeSalesStore? store])
    : store = store ?? FakeSalesStore();

  final FakeSalesStore store;

  @override
  CustomersListCubit customersList() =>
      CustomersListCubit(store.customers, debounce: Duration.zero);

  @override
  CustomerFormCubit customerForm({
    required CustomerFormMode mode,
    String? customerId,
    String initialName = '',
  }) => CustomerFormCubit(
    store.customers,
    mode: mode,
    customerId: customerId,
    initialName: initialName,
  );

  @override
  CustomerDetailsCubit customerDetails(String customerId) =>
      CustomerDetailsCubit(store.customers, customerId);

  @override
  StatementCubit statement(String customerId) =>
      StatementCubit(store.customers, customerId);

  @override
  PaymentCubit payment(String customerId) =>
      PaymentCubit(store.customers, customerId);

  @override
  ArchivedCustomersCubit archivedCustomers() =>
      ArchivedCustomersCubit(store.customers);
}

/// Real sales cubits on a [FakeSalesStore].
final class FakeSalesCubits implements SalesCubits {
  FakeSalesCubits([FakeSalesStore? store]) : store = store ?? FakeSalesStore();

  final FakeSalesStore store;

  @override
  SaleCubit sale() => SaleCubit(store.sales, store.products.products);

  @override
  ProductPickerCubit productPicker() =>
      ProductPickerCubit(store.products.products, debounce: Duration.zero);

  @override
  CustomersListCubit customerPicker() =>
      CustomersListCubit(store.customers, debounce: Duration.zero);

  @override
  CustomerFormCubit newCustomer(String name) => CustomerFormCubit(
    store.customers,
    mode: CustomerFormMode.create,
    initialName: name,
  );

  @override
  SalesListCubit salesList({String? customerId}) => SalesListCubit(
    store.sales,
    customerId: customerId,
    debounce: Duration.zero,
  );

  @override
  InvoiceCubit invoice(String invoiceId) =>
      InvoiceCubit(store.sales, invoiceId);
}
