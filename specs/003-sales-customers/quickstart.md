# Quickstart: Sales and Customers

## Automated

```bash
flutter analyze
flutter test
flutter test test/features/sales
flutter test test/features/customers
```

Expected: analyze clean, all tests green, including the balance and stock property tests and the
number-sequence test.

## On a phone (debug build)

```bash
flutter build apk --debug
```

Seed products from the archived-products overflow menu (002 B2), then:

1. Sales → New sale → add 2 products, one by kg (0.750). Save cash. The list shows S-000001.
2. New sale → pick or add customer "أحمد" → total 100, paid 40 → save. Parties → أحمد shows 60.00.
3. أحمد → Receive payment 25 by wallet → balance 35.00, statement shows RC-000001.
4. Cancel that payment with a reason → balance 60.00, row marked cancelled.
5. Open S-000002 → Void with a reason → stock back, balance 0.00, invoice marked voided.
6. Sell more than the stock of a product → warning names it → confirm → stock below zero.
7. Switch to English and 200% text; repeat 1 and 3; nothing is cut off.
8. Close and reopen the app; everything is still there.
