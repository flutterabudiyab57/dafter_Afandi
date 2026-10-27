import 'package:drift/drift.dart';

import '../utils/clock.dart';
import '../utils/id.dart';
import 'app_database.steps.dart';
import 'converters/utc_millis_converter.dart';
import 'daos/categories_dao.dart';
import 'daos/counters_dao.dart';
import 'daos/customer_ledger_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/expense_categories_dao.dart';
import 'daos/expenses_dao.dart';
import 'daos/payment_parts_dao.dart';
import 'daos/products_dao.dart';
import 'daos/purchases_dao.dart';
import 'daos/reports_dao.dart';
import 'daos/sales_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/stock_movements_dao.dart';
import 'daos/supplier_ledger_dao.dart';
import 'daos/suppliers_dao.dart';
import 'schema_constants.dart';
import 'schema_errors.dart';
import 'schema_sql.dart';
import 'tables/app_settings_table.dart';
import 'tables/categories_table.dart';
import 'tables/counters_table.dart';
import 'tables/customer_ledger_table.dart';
import 'tables/customers_table.dart';
import 'tables/enums.dart';
import 'tables/expense_categories_table.dart';
import 'tables/expenses_table.dart';
import 'tables/payment_parts_table.dart';
import 'tables/products_table.dart';
import 'tables/purchase_invoices_table.dart';
import 'tables/purchase_items_table.dart';
import 'tables/sale_items_table.dart';
import 'tables/sale_return_items_table.dart';
import 'tables/sale_returns_table.dart';
import 'tables/sales_invoices_table.dart';
import 'tables/stock_movements_table.dart';
import 'tables/supplier_ledger_table.dart';
import 'tables/suppliers_table.dart';

part 'app_database.g.dart';

/// Schema v2: every table the MVP needs (data-model.md, FR-014), plus
/// payment parts (006).
@DriftDatabase(
  tables: [
    AppSettings,
    Counters,
    Categories,
    Products,
    Customers,
    Suppliers,
    ExpenseCategories,
    SalesInvoices,
    SaleItems,
    SaleReturns,
    SaleReturnItems,
    PurchaseInvoices,
    PurchaseItems,
    StockMovements,
    CustomerLedger,
    SupplierLedger,
    Expenses,
    PaymentParts,
  ],
  daos: [
    SettingsDao,
    ProductsDao,
    CategoriesDao,
    StockMovementsDao,
    CountersDao,
    CustomersDao,
    CustomerLedgerDao,
    SalesDao,
    SuppliersDao,
    SupplierLedgerDao,
    PurchasesDao,
    PaymentPartsDao,
    ReportsDao,
    ExpensesDao,
    ExpenseCategoriesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor, this._ids, this._clock);

  final IdGenerator _ids;
  final Clock _clock;

  // A class field, not the top-level const directly: drift_dev's
  // make-migrations can only read the version from a field or a literal.
  static const int currentSchemaVersion = kSchemaVersion;

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: _create,
    onUpgrade: (m, from, to) async {
      if (from > to) throw SchemaTooNewException(from, to);
      // One transaction, as in _create: a crash leaves the old schema and
      // data whole, never half upgraded.
      await transaction(() async {
        await stepByStep(from1To2: _from1To2, from2To3: _from2To3)(m, from, to);
        await customStatement('PRAGMA user_version = $to');
      });
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Builds a new file in one transaction (risk K4): Drift 2.35.1 runs
  /// `onCreate` without one and writes `user_version` only after it returns.
  /// `user_version` is set inside the transaction too, so a crash leaves
  /// either an empty file or a complete v1 schema, never a half-built one.
  Future<void> _create(Migrator m) => transaction(() async {
    await customStatement('PRAGMA application_id = $kAppApplicationId');
    await m.createAll();
    for (final statement in kSchemaSql) {
      await customStatement(statement);
    }

    final now = _clock.nowUtc();
    for (final docType in DocType.values) {
      await into(counters).insert(
        CountersCompanion.insert(
          id: _ids.newId(),
          docType: docType,
          nextValue: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    await into(appSettings).insert(
      AppSettingsCompanion.insert(
        id: _ids.newId(),
        deviceId: _ids.newId(),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await customStatement('PRAGMA user_version = $kSchemaVersion');
  });

  /// v1 → v2 (006 research R4): payment parts, then one part per payment
  /// already saved, so every reader can rely on parts. Plain SQL, so the
  /// step does not change when the tables in code do.
  Future<void> _from1To2(Migrator m, Schema2 schema) async {
    await m.createTable(schema.paymentParts);
    for (final statement in kV2Sql) {
      await customStatement(statement);
    }
    for (final (parent, select) in _v1Payments) {
      final rows = await customSelect(select).get();
      for (final r in rows) {
        await customStatement(
          'INSERT INTO payment_parts (id, $parent, part_no, method, '
          'amount_piasters, account_ref, created_at) '
          'VALUES (?, ?, 1, ?, ?, NULL, ?)',
          [
            _ids.newId(),
            r.read<String>('id'),
            r.read<String>('method'),
            r.read<int>('amount'),
            r.read<int>('created_at'),
          ],
        );
      }
    }
  }

  /// v2 → v3 (constitution 1.2.0): the customer and supplier delete
  /// triggers let a party with no history go once it is archived.
  Future<void> _from2To3(Migrator m, Schema3 schema) async {
    for (final statement in kV3Sql) {
      await customStatement(statement);
    }
  }

  /// Each v1 payment and the parent column its part goes in. Ledger payment
  /// rows store the amount negative; those a sale or purchase wrote have no
  /// receipt or payment number and take the invoice's part instead.
  static const List<(String, String)> _v1Payments = [
    (
      'sales_invoice_id',
      'SELECT id, payment_method AS method, paid_at_sale_piasters AS amount, '
          'created_at FROM sales_invoices WHERE paid_at_sale_piasters > 0',
    ),
    (
      'purchase_invoice_id',
      'SELECT id, payment_method AS method, paid_piasters AS amount, '
          'created_at FROM purchase_invoices WHERE paid_piasters > 0',
    ),
    (
      'customer_ledger_id',
      'SELECT id, payment_method AS method, -amount_piasters AS amount, '
          "created_at FROM customer_ledger WHERE entry_type = 'PAYMENT_RECEIVED' "
          'AND receipt_number IS NOT NULL',
    ),
    (
      'supplier_ledger_id',
      'SELECT id, payment_method AS method, -amount_piasters AS amount, '
          "created_at FROM supplier_ledger WHERE entry_type = 'PAYMENT_MADE' "
          'AND payment_number IS NOT NULL',
    ),
    (
      'expense_id',
      "SELECT id, 'cash' AS method, amount_piasters AS amount, created_at "
          'FROM expenses',
    ),
  ];
}
