/// Document numbers as shown to the user (decision Q22): a prefix per type
/// and at least six digits, e.g. `S-000012`. Stored numbers stay plain
/// integers; the screen applies the digit style.
library;

/// Sales invoices.
const String saleNumberPrefix = 'S-';

/// Customer receipts.
const String receiptNumberPrefix = 'RC-';

String formatDocNumber(String prefix, int number) =>
    '$prefix${number.toString().padLeft(6, '0')}';
