import 'package:drift/drift.dart';

import '../utils/clock.dart';
import '../utils/id.dart';
import 'converters/utc_millis_converter.dart';
import 'daos/categories_dao.dart';
import 'daos/counters_dao.dart';
import 'daos/customer_ledger_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/products_dao.dart';
import 'daos/purchases_dao.dart';
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

/// Schema v1: every table the MVP needs (data-model.md, FR-014).
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
      // v1 is the first schema; make-migrations adds stepByStep with v2.
      throw StateError('no migration from schema $from to $to');
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
}
