/// Indexes and triggers that Drift's table DSL can't express (data-model.md,
/// research R5). Run in order by `onCreate`; a later migration re-creates
/// them from this same source.
library;

/// Every table, as of schema v2 (v3 added none).
const List<String> kAllTables = [
  'app_settings',
  'counters',
  'categories',
  'products',
  'customers',
  'suppliers',
  'expense_categories',
  'sales_invoices',
  'sale_items',
  'sale_returns',
  'sale_return_items',
  'purchase_invoices',
  'purchase_items',
  'stock_movements',
  'customer_ledger',
  'supplier_ledger',
  'expenses',
  'payment_parts',
];

/// Tables whose rows never change after insert.
const List<String> kImmutableTables = [
  'sale_items',
  'sale_returns',
  'sale_return_items',
  'purchase_items',
  'stock_movements',
  'customer_ledger',
  'supplier_ledger',
  'payment_parts',
];

/// The columns a void may change, on every voidable header.
const Set<String> kVoidColumns = {'voided_at', 'void_reason', 'updated_at'};

/// Voidable headers and the columns their void-only trigger freezes: every
/// column except [kVoidColumns]. `trigger_coverage_test.dart` fails if a
/// column is added to a table but not here.
const Map<String, List<String>> kVoidableFrozenColumns = {
  'sales_invoices': [
    'id',
    'number',
    'customer_id',
    'subtotal_piasters',
    'discount_piasters',
    'total_piasters',
    'paid_at_sale_piasters',
    'payment_method',
    'note',
    'created_at',
  ],
  'purchase_invoices': [
    'id',
    'number',
    'supplier_id',
    'supplier_ref',
    'invoice_date',
    'subtotal_piasters',
    'discount_piasters',
    'total_piasters',
    'paid_piasters',
    'payment_method',
    'note',
    'created_at',
  ],
  'expenses': [
    'id',
    'number',
    'expense_category_id',
    'amount_piasters',
    'spent_at',
    'note',
    'created_at',
  ],
};

const List<String> _indexes = [
  'CREATE UNIQUE INDEX ux_categories_search_key ON categories (search_key) WHERE archived_at IS NULL',
  'CREATE INDEX ix_products_category_id ON products (category_id)',
  'CREATE INDEX ix_products_search_key ON products (search_key)',
  'CREATE INDEX ix_products_archived_at ON products (archived_at)',
  'CREATE UNIQUE INDEX ux_products_barcode ON products (barcode) WHERE barcode IS NOT NULL AND archived_at IS NULL',
  'CREATE INDEX ix_customers_search_key ON customers (search_key)',
  'CREATE INDEX ix_customers_phone ON customers (phone)',
  'CREATE INDEX ix_suppliers_search_key ON suppliers (search_key)',
  'CREATE INDEX ix_suppliers_phone ON suppliers (phone)',
  'CREATE UNIQUE INDEX ux_expense_categories_search_key ON expense_categories (search_key) WHERE archived_at IS NULL',
  'CREATE INDEX ix_sales_invoices_created_at ON sales_invoices (created_at)',
  'CREATE INDEX ix_sales_invoices_customer_created ON sales_invoices (customer_id, created_at)',
  'CREATE INDEX ix_sales_invoices_voided_at ON sales_invoices (voided_at)',
  'CREATE INDEX ix_sale_items_sales_invoice_id ON sale_items (sales_invoice_id)',
  'CREATE INDEX ix_sale_items_product_id ON sale_items (product_id)',
  'CREATE INDEX ix_sale_returns_sales_invoice_id ON sale_returns (sales_invoice_id)',
  'CREATE INDEX ix_sale_returns_created_at ON sale_returns (created_at)',
  'CREATE INDEX ix_sale_return_items_sale_item_id ON sale_return_items (sale_item_id)',
  'CREATE INDEX ix_sale_return_items_sale_return_id ON sale_return_items (sale_return_id)',
  'CREATE INDEX ix_purchase_invoices_invoice_date ON purchase_invoices (invoice_date)',
  'CREATE INDEX ix_purchase_invoices_supplier_date ON purchase_invoices (supplier_id, invoice_date)',
  'CREATE INDEX ix_purchase_items_purchase_invoice_id ON purchase_items (purchase_invoice_id)',
  'CREATE INDEX ix_purchase_items_product_id ON purchase_items (product_id)',
  'CREATE INDEX ix_stock_movements_product_qty ON stock_movements (product_id, qty_delta_milli)',
  'CREATE INDEX ix_stock_movements_product_created ON stock_movements (product_id, created_at)',
  'CREATE INDEX ix_stock_movements_sale_item_id ON stock_movements (sale_item_id)',
  'CREATE INDEX ix_stock_movements_sale_return_item_id ON stock_movements (sale_return_item_id)',
  'CREATE INDEX ix_stock_movements_purchase_item_id ON stock_movements (purchase_item_id)',
  'CREATE INDEX ix_stock_movements_reverses_movement_id ON stock_movements (reverses_movement_id)',
  'CREATE INDEX ix_customer_ledger_customer_created ON customer_ledger (customer_id, created_at)',
  'CREATE INDEX ix_customer_ledger_sales_invoice_id ON customer_ledger (sales_invoice_id)',
  'CREATE INDEX ix_customer_ledger_sale_return_id ON customer_ledger (sale_return_id)',
  'CREATE UNIQUE INDEX ux_customer_ledger_receipt_number ON customer_ledger (receipt_number) WHERE receipt_number IS NOT NULL',
  'CREATE INDEX ix_supplier_ledger_supplier_created ON supplier_ledger (supplier_id, created_at)',
  'CREATE INDEX ix_supplier_ledger_purchase_invoice_id ON supplier_ledger (purchase_invoice_id)',
  'CREATE UNIQUE INDEX ux_supplier_ledger_payment_number ON supplier_ledger (payment_number) WHERE payment_number IS NOT NULL',
  'CREATE INDEX ix_expenses_spent_at ON expenses (spent_at)',
  'CREATE INDEX ix_expenses_expense_category_id ON expenses (expense_category_id)',
];

/// The payment parts parents: one method and one part number per parent.
const List<String> _paymentPartParents = [
  'sales_invoice_id',
  'purchase_invoice_id',
  'customer_ledger_id',
  'supplier_ledger_id',
  'expense_id',
];

/// Indexes added in schema v2 (006 data-model).
final List<String> _v2Indexes = [
  for (final parent in _paymentPartParents) ...[
    'CREATE UNIQUE INDEX ux_payment_parts_${parent}_method ON payment_parts '
        '($parent, method) WHERE $parent IS NOT NULL',
    'CREATE UNIQUE INDEX ux_payment_parts_${parent}_part_no ON payment_parts '
        '($parent, part_no) WHERE $parent IS NOT NULL',
  ],
  'CREATE INDEX ix_payment_parts_created_at ON payment_parts (created_at)',
  'CREATE INDEX ix_payment_parts_method_account ON payment_parts '
      '(method, account_ref, created_at) WHERE account_ref IS NOT NULL',
  'CREATE INDEX ix_stock_movements_type_created ON stock_movements '
      '(movement_type, created_at)',
];

String _noDelete(String table) =>
    'CREATE TRIGGER trg_${table}_no_delete BEFORE DELETE ON $table '
    "BEGIN SELECT RAISE(ABORT, 'no hard delete: $table'); END";

/// What makes a party's row history: any row naming it (constitution
/// 1.2.0). v3 lets such a party be deleted only when archived and without
/// any of these; the 7 days are the app's to check.
const Map<String, List<(String, String)>> kPurgeableHistory = {
  'customers': [
    ('customer_ledger', 'customer_id'),
    ('sales_invoices', 'customer_id'),
    ('sale_returns', 'customer_id'),
  ],
  'suppliers': [
    ('supplier_ledger', 'supplier_id'),
    ('purchase_invoices', 'supplier_id'),
  ],
};

/// True when the party [idRef] (e.g. `OLD.id`, `c.id`) has any history
/// row; [table] is a key of [kPurgeableHistory].
String partyHistorySql(String table, String idRef) => [
  for (final (t, column) in kPurgeableHistory[table]!)
    'EXISTS(SELECT 1 FROM $t WHERE $column = $idRef)',
].join(' OR ');

/// The no-delete trigger, with v3's one opening for a party with no
/// history, when [kPurgeableHistory] lists [table].
String _noDeleteFor(String table) {
  if (!kPurgeableHistory.containsKey(table)) return _noDelete(table);
  return 'CREATE TRIGGER trg_${table}_no_delete BEFORE DELETE ON $table '
      'WHEN OLD.archived_at IS NULL OR ${partyHistorySql(table, 'OLD.id')} '
      "BEGIN SELECT RAISE(ABORT, 'no hard delete: $table'); END";
}

String _immutable(String table) =>
    'CREATE TRIGGER trg_${table}_immutable BEFORE UPDATE ON $table '
    "BEGIN SELECT RAISE(ABORT, 'immutable: $table'); END";

String _voidOnly(String table, List<String> frozen) {
  final changed = frozen.map((c) => 'NEW.$c IS NOT OLD.$c').join(' OR ');
  return 'CREATE TRIGGER trg_${table}_void_only BEFORE UPDATE ON $table '
      'WHEN OLD.voided_at IS NOT NULL OR NEW.voided_at IS NULL '
      'OR NEW.void_reason IS NULL OR $changed '
      "BEGIN SELECT RAISE(ABORT, 'void only: $table'); END";
}

const String _saleReturnQtyCeiling =
    'CREATE TRIGGER trg_sale_return_items_qty_ceiling '
    'BEFORE INSERT ON sale_return_items '
    'WHEN NEW.qty_milli + COALESCE((SELECT SUM(qty_milli) FROM sale_return_items '
    'WHERE sale_item_id = NEW.sale_item_id), 0) > '
    '(SELECT qty_milli FROM sale_items WHERE id = NEW.sale_item_id) '
    "BEGIN SELECT RAISE(ABORT, 'return exceeds sold qty'); END";

/// What the v1 → v2 step runs after creating `payment_parts`: its indexes
/// and triggers, and the new stock movements index.
final List<String> kV2Sql = List.unmodifiable([
  ..._v2Indexes,
  _noDelete('payment_parts'),
  _immutable('payment_parts'),
]);

/// The v2 → v3 step: the party delete triggers, replaced.
final List<String> kV3Sql = List.unmodifiable([
  for (final table in kPurgeableHistory.keys) ...[
    'DROP TRIGGER IF EXISTS trg_${table}_no_delete',
    _noDeleteFor(table),
  ],
]);

/// All statements, in the order `onCreate` runs them.
final List<String> kSchemaSql = List.unmodifiable([
  ..._indexes,
  ..._v2Indexes,
  for (final table in kAllTables) _noDeleteFor(table),
  for (final table in kImmutableTables) _immutable(table),
  for (final MapEntry(key: table, value: frozen)
      in kVoidableFrozenColumns.entries)
    _voidOnly(table, frozen),
  _saleReturnQtyCeiling,
]);
