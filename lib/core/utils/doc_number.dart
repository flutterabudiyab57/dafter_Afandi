/// Document numbers as shown to the user (decision Q22): a prefix per type
/// and at least six digits, e.g. `S-000012`. Stored numbers stay plain
/// integers; the screen applies the digit style.
library;

/// Sales invoices.
const String saleNumberPrefix = 'S-';

/// Customer receipts.
const String receiptNumberPrefix = 'RC-';

/// Purchase invoices (004 research R4).
const String purchaseNumberPrefix = 'P-';

/// Standalone payments to suppliers.
const String supplierPaymentNumberPrefix = 'PY-';

/// Shop expenses (006).
const String expenseNumberPrefix = 'E-';

String formatDocNumber(String prefix, int number) =>
    '$prefix${number.toString().padLeft(6, '0')}';
