import 'dart:async';

import 'package:daftar_afandi/core/utils/arabic_normalize.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/digits.dart';
import 'package:daftar_afandi/core/utils/result.dart';
import 'package:daftar_afandi/features/customers/domain/ledger_entry.dart';
import 'package:daftar_afandi/features/customers/domain/payment.dart';
import 'package:daftar_afandi/features/products/domain/stock_entry.dart';
import 'package:daftar_afandi/features/products/presentation/cubits/product_picker_cubit.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_draft.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_errors.dart';
import 'package:daftar_afandi/features/purchases/domain/purchase_repository.dart';
import 'package:daftar_afandi/features/purchases/presentation/cubits/purchase_cubit.dart';
import 'package:daftar_afandi/features/purchases/presentation/cubits/purchases_list_cubit.dart';
import 'package:daftar_afandi/features/purchases/presentation/purchases_cubits.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_draft.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_entry.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_errors.dart';
import 'package:daftar_afandi/features/suppliers/domain/supplier_repository.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_details_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_form_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/supplier_payment_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/cubits/suppliers_list_cubit.dart';
import 'package:daftar_afandi/features/suppliers/presentation/suppliers_cubits.dart';

import 'fake_products.dart';

final class _Row {
  _Row({
    required this.id,
    required this.supplierId,
    required this.type,
    required this.amount,
    required this.at,
    required this.order,
    this.purchaseId,
    this.paymentNumber,
    this.method,
    this.note,
    this.reverses,
  });

  final String id;
  final String supplierId;
  final SupplierEntryType type;
  final int amount;
  final DateTime at;
  final int order;
  final String? purchaseId;
  final int? paymentNumber;
  final PaymentMethod? method;
  final String? note;
  final String? reverses;
}

/// In-memory suppliers, their ledger and purchases, on top of a
/// [FakeProductsStore], with the same rules as the real repositories.
/// The average cost is not tracked.
final class FakePurchasesStore {
  FakePurchasesStore([FakeProductsStore? products])
    : products = products ?? FakeProductsStore();

  final FakeProductsStore products;
  final Map<String, Supplier> _suppliers = {};
  final List<_Row> _ledger = [];
  final List<Purchase> _purchases = [];
  final StreamController<void> _changes = StreamController.broadcast();
  final List<String> writes = [];
  var _nextId = 1;
  var _nextPayment = 1;
  var _clock = DateTime.utc(2026, 10, 20, 10);

  /// "Today" for the purchase date rule.
  final Clock clock = FixedClock(DateTime.utc(2026, 10, 20, 10));

  late final FakeSupplierRepository suppliers = FakeSupplierRepository(this);
  late final FakePurchaseRepository purchases = FakePurchaseRepository(this);

  String _id(String prefix) => '$prefix${_nextId++}';

  DateTime _now() => _clock = _clock.add(const Duration(minutes: 1));

  void _changed() => _changes.add(null);

  Stream<T> _watch<T>(T Function() read) {
    StreamSubscription<void>? changes;
    late final StreamController<T> controller;
    controller = StreamController<T>(
      onListen: () {
        changes = _changes.stream.listen((_) => controller.add(read()));
        controller.add(read());
      },
      // Not returned: under fake async the broadcast cancel never completes.
      onCancel: () => unawaited(changes?.cancel()),
    );
    return controller.stream;
  }

  // ---- seeding (no write recorded) ----

  String seedSupplier(
    String name, {
    String? phone,
    int openingPiasters = 0,
    bool archived = false,
  }) {
    final id = _id('v');
    _suppliers[id] = Supplier(
      id: id,
      name: name,
      phone: phone,
      archived: archived,
    );
    if (openingPiasters != 0) {
      _addRow(id, SupplierEntryType.openingBalance, openingPiasters);
    }
    _changed();
    return id;
  }

  /// Saves [draft] directly (no checks), for seeding lists.
  String seedPurchase(PurchaseDraft draft) => _createPurchase(draft).id;

  _Row _addRow(
    String supplierId,
    SupplierEntryType type,
    int amount, {
    String? purchaseId,
    int? paymentNumber,
    PaymentMethod? method,
    String? note,
    String? reverses,
  }) {
    final row = _Row(
      id: _id('e'),
      supplierId: supplierId,
      type: type,
      amount: amount,
      at: _now(),
      order: _ledger.length + 1,
      purchaseId: purchaseId,
      paymentNumber: paymentNumber,
      method: method,
      note: note,
      reverses: reverses,
    );
    _ledger.add(row);
    return row;
  }

  // ---- reads ----

  int balanceOf(String id) =>
      _ledger.where((r) => r.supplierId == id).fold(0, (s, r) => s + r.amount);

  SupplierSummary? supplier(String id) {
    final s = _suppliers[id];
    return s == null
        ? null
        : SupplierSummary(supplier: s, balancePiasters: balanceOf(id));
  }

  List<SupplierSummary> activeSuppliers([
    SupplierQuery q = const SupplierQuery(),
  ]) {
    final key = q.normalizedText;
    // Only the digits, in Latin, as the real repository matches phones.
    final phone = normalizeDigits(q.text).replaceAll(RegExp('[^0-9]'), '');
    final list = [
      for (final s in _suppliers.values)
        if (!s.archived &&
            (key.isEmpty ||
                arabicNormalize(s.name).contains(key) ||
                (phone.isNotEmpty && (s.phone ?? '').contains(phone))))
          supplier(s.id)!,
    ];
    if (q.owedOnly) {
      list
        ..removeWhere((s) => s.balancePiasters <= 0)
        ..sort((a, b) => b.balancePiasters.compareTo(a.balancePiasters));
    } else {
      list.sort(
        (a, b) =>
            arabicNormalize(a.supplier.name)
                .compareTo(arabicNormalize(b.supplier.name)),
      );
    }
    return list;
  }

  List<SupplierEntry> statementOf(String id) {
    var running = 0;
    final entries = <SupplierEntry>[];
    for (final r in _ledger.where((r) => r.supplierId == id)) {
      running += r.amount;
      entries.add(
        SupplierEntry(
          id: r.id,
          type: r.type,
          amountPiasters: r.amount,
          runningBalancePiasters: running,
          at: r.at,
          rowOrder: r.order,
          purchaseId: r.purchaseId,
          purchaseNumber: r.purchaseId == null
              ? null
              : purchase(r.purchaseId!)?.summary.number,
          paymentNumber: r.paymentNumber,
          method: r.method,
          note: r.note,
          reversed: _ledger.any((x) => x.reverses == r.id),
        ),
      );
    }
    return entries.reversed.toList();
  }

  Purchase? purchase(String id) {
    for (final p in _purchases) {
      if (p.summary.id == id) return p;
    }
    return null;
  }

  List<PurchaseSummary> purchaseList(PurchaseQuery q) {
    final number = q.number;
    final key = arabicNormalize(q.text);
    bool matches(PurchaseSummary s) => number != null
        ? '${s.number}'.startsWith('$number')
        : key.isEmpty ||
              arabicNormalize(s.supplierName ?? '').contains(key) ||
              (s.supplierRef ?? '').toLowerCase().contains(key);
    return [
      for (final p in _purchases)
        if (matches(p.summary) &&
            (!q.unpaidOnly ||
                (p.summary.remainingPiasters > 0 && !p.summary.voided)) &&
            (q.supplierId == null || p.summary.supplierId == q.supplierId))
          p.summary,
    ]..sort((a, b) {
      final byDate = b.invoiceDate.compareTo(a.invoiceDate);
      return byDate != 0 ? byDate : b.number - a.number;
    });
  }

  PurchaseSaved _createPurchase(PurchaseDraft draft) {
    final id = _id('u');
    final number = _purchases.length + 1;
    final at = _now();
    final s = draft.supplier;
    for (final l in draft.lines) {
      products.seedEntry(l.productId, StockEntryType.purchase, l.qtyMilli);
    }
    final local = clock.nowUtc().toLocal();
    _purchases.add(
      Purchase(
        summary: PurchaseSummary(
          id: id,
          number: number,
          invoiceDate:
              draft.invoiceDate ?? DateTime(local.year, local.month, local.day),
          at: at,
          totalPiasters: draft.total,
          paidPiasters: draft.paid,
          supplierId: s?.id,
          supplierName: s == null ? null : _suppliers[s.id]?.name,
          supplierRef: draft.supplierRef,
        ),
        subtotalPiasters: draft.subtotal,
        invoiceDiscountPiasters: draft.invoiceDiscountPiasters,
        method: draft.method,
        items: [
          for (final (i, l) in draft.lines.indexed)
            PurchaseItem(
              lineNo: i + 1,
              productId: l.productId,
              name: l.name,
              unit: l.unit,
              qtyMilli: l.qtyMilli,
              unitCostPiasters: l.unitCostPiasters,
              lineDiscountPiasters: l.lineDiscountPiasters,
              lineTotalPiasters: l.lineTotal,
            ),
        ],
        note: draft.note,
      ),
    );
    if (s != null) {
      if (draft.total > 0) {
        _addRow(s.id, SupplierEntryType.purchase, draft.total, purchaseId: id);
      }
      if (draft.paid > 0) {
        _addRow(
          s.id,
          SupplierEntryType.payment,
          -draft.paid,
          purchaseId: id,
          method: draft.method,
        );
      }
    }
    _changed();
    return PurchaseSaved(id: id, number: number);
  }
}

final class FakeSupplierRepository implements SupplierRepository {
  FakeSupplierRepository(this._s);

  final FakePurchasesStore _s;

  @override
  Stream<List<SupplierSummary>> watchActive(SupplierQuery query) =>
      _s._watch(() => _s.activeSuppliers(query));

  @override
  Stream<SupplierSummary?> watchOne(String id) =>
      _s._watch(() => _s.supplier(id));

  @override
  Stream<List<SupplierSummary>> watchArchived() => _s._watch(
    () => [
      for (final s in _s._suppliers.values)
        if (s.archived) _s.supplier(s.id)!,
    ],
  );

  bool _sameName(String name, String exceptId) => _s._suppliers.values.any(
    (s) =>
        s.id != exceptId &&
        !s.archived &&
        arabicNormalize(s.name) == arabicNormalize(name),
  );

  @override
  Future<Result<SupplierSaved, SupplierSaveError>> create(
    SupplierDraft draft,
  ) async {
    _s.writes.add('supplier ${draft.name}');
    final id = _s._id('v');
    _s._suppliers[id] = Supplier(
      id: id,
      name: draft.name,
      phone: draft.phone,
      address: draft.address,
      note: draft.note,
    );
    if (draft.openingBalancePiasters != 0) {
      _s._addRow(
        id,
        SupplierEntryType.openingBalance,
        draft.openingBalancePiasters,
      );
    }
    _s._changed();
    return Ok(
      SupplierSaved(id: id, nameExistsElsewhere: _sameName(draft.name, id)),
    );
  }

  @override
  Future<Result<SupplierSaved, SupplierSaveError>> update(
    String id,
    SupplierDraft draft,
  ) async {
    final old = _s._suppliers[id];
    if (old == null) return const Err(SupplierNotFound());
    _s.writes.add('update $id');
    _s._suppliers[id] = Supplier(
      id: id,
      name: draft.name,
      phone: draft.phone,
      address: draft.address,
      note: draft.note,
      archived: old.archived,
    );
    _s._changed();
    return Ok(
      SupplierSaved(id: id, nameExistsElsewhere: _sameName(draft.name, id)),
    );
  }

  void _setArchived(String id, {required bool archived}) {
    final s = _s._suppliers[id]!;
    _s._suppliers[id] = Supplier(
      id: id,
      name: s.name,
      phone: s.phone,
      address: s.address,
      note: s.note,
      archived: archived,
    );
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
  Future<List<SupplierEntry>> statement(
    String supplierId, {
    LedgerCursor? before,
    int limit = 50,
  }) async {
    final all = _s.statementOf(supplierId);
    final start = before == null
        ? 0
        : all.indexWhere((e) => e.rowOrder == before.rowOrder) + 1;
    return all.skip(start).take(limit).toList();
  }

  @override
  Stream<void> watchStatementChanges(String supplierId) => _s
      ._watch(() => _s._ledger.where((r) => r.supplierId == supplierId).length)
      .distinct();

  @override
  Future<Result<int, SupplierPaymentError>> pay(
    String supplierId,
    PaymentRequest request,
  ) async {
    final s = _s._suppliers[supplierId];
    if (s == null) return const Err(PaymentSupplierNotFound());
    if (s.archived) return const Err(PaymentSupplierArchived());
    final number = _s._nextPayment++;
    _s.writes.add('pay $supplierId ${request.amountPiasters}');
    _s._addRow(
      supplierId,
      SupplierEntryType.payment,
      -request.amountPiasters,
      paymentNumber: number,
      method: request.method,
      note: request.note,
    );
    _s._changed();
    return Ok(number);
  }

  @override
  Future<Result<void, SupplierPaymentError>> cancelPayment(
    String entryId,
    String reason,
  ) async {
    if (validateReason(reason) is Err) {
      return const Err(SupplierPaymentReasonInvalid());
    }
    final row = _s._ledger.where((r) => r.id == entryId).firstOrNull;
    if (row == null ||
        row.type != SupplierEntryType.payment ||
        row.paymentNumber == null) {
      return const Err(SupplierPaymentNotCancellable());
    }
    if (_s._ledger.any((r) => r.reverses == entryId)) {
      return const Err(SupplierPaymentAlreadyCancelled());
    }
    _s.writes.add('cancel $entryId');
    _s._addRow(
      row.supplierId,
      SupplierEntryType.reversal,
      -row.amount,
      note: reason.trim(),
      reverses: entryId,
    );
    _s._changed();
    return const Ok(null);
  }
}

final class FakePurchaseRepository implements PurchaseRepository {
  FakePurchaseRepository(this._s);

  final FakePurchasesStore _s;

  @override
  Future<Result<PurchaseSaved, PurchaseSaveError>> create(
    PurchaseDraft draft,
  ) async {
    final local = _s.clock.nowUtc().toLocal();
    final invalid = draft.validate(
      today: DateTime(local.year, local.month, local.day),
    );
    if (invalid.isNotEmpty) return Err(PurchaseInvalid(invalid));
    for (final l in draft.lines) {
      final p = _s.products.summary(l.productId);
      if (p == null || p.product.archived) {
        return Err(PurchaseProductUnavailable(l.name));
      }
    }
    final s = draft.supplier;
    if (s != null) {
      final stored = _s._suppliers[s.id];
      if (stored == null || stored.archived) {
        return const Err(SupplierUnavailable());
      }
    }
    _s.writes.add('purchase ${draft.total}');
    return Ok(_s._createPurchase(draft));
  }

  @override
  Stream<List<PurchaseSummary>> watchList(
    PurchaseQuery query, {
    int limit = 50,
  }) => _s._watch(() => _s.purchaseList(query).take(limit).toList());

  @override
  Stream<Purchase?> watchOne(String id) => _s._watch(() => _s.purchase(id));

  @override
  Future<int?> lastUnitCost(String productId) async {
    for (final p in _s._purchases.reversed) {
      if (p.summary.voided) continue;
      for (final i in p.items) {
        if (i.productId == productId) return i.unitCostPiasters;
      }
    }
    return null;
  }

  @override
  Future<Result<void, PurchaseVoidError>> voidPurchase(
    String id,
    String reason, {
    bool acknowledgeShortage = false,
  }) async {
    if (validateReason(reason) is Err) {
      return const Err(PurchaseVoidReasonInvalid());
    }
    final index = _s._purchases.indexWhere((p) => p.summary.id == id);
    if (index < 0) return const Err(PurchaseNotFound());
    final p = _s._purchases[index];
    if (p.summary.voided) return const Err(PurchaseAlreadyVoided());
    final shortages = [
      for (final i in p.items)
        if (_s.products.stockOf(i.productId) - i.qtyMilli < 0)
          VoidShortage(
            productId: i.productId,
            name: i.name,
            unit: i.unit,
            stockAfterMilli: _s.products.stockOf(i.productId) - i.qtyMilli,
          ),
    ];
    if (shortages.isNotEmpty && !acknowledgeShortage) {
      return Err(VoidStockShortage(shortages));
    }
    final trimmed = reason.trim();
    _s.writes.add('void $id');
    final at = _s._now();
    for (final i in p.items) {
      _s.products.seedEntry(
        i.productId,
        StockEntryType.purchaseVoid,
        -i.qtyMilli,
      );
    }
    final sid = p.summary.supplierId;
    if (sid != null) {
      for (final r in [..._s._ledger.where((r) => r.purchaseId == id)]) {
        _s._addRow(
          sid,
          r.type == SupplierEntryType.purchase
              ? SupplierEntryType.purchaseVoid
              : SupplierEntryType.reversal,
          -r.amount,
          purchaseId: id,
          note: trimmed,
          reverses: r.id,
        );
      }
    }
    final s = p.summary;
    _s._purchases[index] = Purchase(
      summary: PurchaseSummary(
        id: s.id,
        number: s.number,
        invoiceDate: s.invoiceDate,
        at: s.at,
        totalPiasters: s.totalPiasters,
        paidPiasters: s.paidPiasters,
        supplierId: s.supplierId,
        supplierName: s.supplierName,
        supplierRef: s.supplierRef,
        voided: true,
      ),
      subtotalPiasters: p.subtotalPiasters,
      invoiceDiscountPiasters: p.invoiceDiscountPiasters,
      method: p.method,
      items: p.items,
      note: p.note,
      voidedAt: at,
      voidReason: trimmed,
    );
    _s._changed();
    return const Ok(null);
  }
}

/// Real suppliers cubits on a [FakePurchasesStore].
final class FakeSuppliersCubits implements SuppliersCubits {
  FakeSuppliersCubits([FakePurchasesStore? store])
    : store = store ?? FakePurchasesStore();

  final FakePurchasesStore store;

  @override
  SuppliersListCubit suppliersList() =>
      SuppliersListCubit(store.suppliers, debounce: Duration.zero);

  @override
  SupplierFormCubit supplierForm({
    required SupplierFormMode mode,
    String? supplierId,
    String initialName = '',
  }) => SupplierFormCubit(
    store.suppliers,
    mode: mode,
    supplierId: supplierId,
    initialName: initialName,
  );

  @override
  SupplierDetailsCubit supplierDetails(String supplierId) =>
      SupplierDetailsCubit(store.suppliers, supplierId);

  @override
  SupplierStatementCubit statement(String supplierId) =>
      SupplierStatementCubit(store.suppliers, supplierId);

  @override
  SupplierPaymentCubit payment(String supplierId) =>
      SupplierPaymentCubit(store.suppliers, supplierId);

  @override
  ArchivedSuppliersCubit archivedSuppliers() =>
      ArchivedSuppliersCubit(store.suppliers);
}

/// Real purchases cubits on a [FakePurchasesStore].
final class FakePurchasesCubits implements PurchasesCubits {
  FakePurchasesCubits([FakePurchasesStore? store])
    : store = store ?? FakePurchasesStore();

  final FakePurchasesStore store;

  @override
  PurchaseCubit purchase() => PurchaseCubit(store.purchases, store.clock);

  @override
  ProductPickerCubit productPicker() =>
      ProductPickerCubit(store.products.products, debounce: Duration.zero);

  @override
  SuppliersListCubit supplierPicker() =>
      SuppliersListCubit(store.suppliers, debounce: Duration.zero);

  @override
  PurchasesListCubit purchasesList({String? supplierId}) => PurchasesListCubit(
    store.purchases,
    supplierId: supplierId,
    debounce: Duration.zero,
  );

  @override
  PurchaseViewCubit purchaseView(String purchaseId) =>
      PurchaseViewCubit(store.purchases, purchaseId);
}
