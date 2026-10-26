/// Value domains stored as `TEXT` via `textEnum` (data-model.md). The stored
/// text is the enum value's `name`, so values must never be renamed.
///
/// Each enum column also has a `CHECK (col IN (…))` written by hand in its
/// table; `constraints_test.dart` checks that the lists match these enums.
// ignore_for_file: constant_identifier_names
library;

export '../../utils/quantity.dart' show UnitType;

enum LocaleCode { ar, en }

enum DigitStylePreference { follow, arabic, latin }

enum NegativeStockPolicy { warn, block }

enum PaymentMethod { cash, wallet, instapay, card }

enum DocType {
  SALE,
  SALE_RETURN,
  PURCHASE,
  EXPENSE,
  CUSTOMER_RECEIPT,
  SUPPLIER_PAYMENT,
}

enum MovementType {
  OPENING,
  PURCHASE,
  PURCHASE_VOID,
  SALE,
  SALE_RETURN,
  SALE_VOID,
  ADJUSTMENT,
}

enum AdjustmentReason { damage, count, other }

enum CustomerEntryType {
  OPENING_BALANCE,
  SALE,
  PAYMENT_RECEIVED,
  SALE_RETURN,
  REFUND_PAID,
  SALE_VOID,
  ADJUSTMENT,
  REVERSAL,
}

enum SupplierEntryType {
  OPENING_BALANCE,
  PURCHASE,
  PAYMENT_MADE,
  PURCHASE_VOID,
  ADJUSTMENT,
  REVERSAL,
}
