# Quickstart: Purchases and Suppliers

## Automated

```bash
flutter analyze
flutter test
flutter test test/features/purchases
flutter test test/features/suppliers
flutter test test/features/products/data
```

Expected: analyze clean, all tests green, including the supplier balance, stock and
average-cost-replay property tests ([research R8](research.md)) and the P- / PY- number sequence
tests.

## On a phone (debug build)

```bash
flutter build apk --debug
```

Start from products seeded as in 002 ("شاي" with stock 10 at cost 9.00, selling at 12.50). Then:

1. Purchases → New purchase → add "شاي", qty 10, cost 11.00 → save cash. The list shows
   P-000001; "شاي" now has stock 20 and average cost 10.00.
2. New purchase → "شاي" starts at cost 11.00 (last purchase). Change it to 13.00 → a notice says
   the cost is at or above the selling price; it still saves.
3. New purchase → search "بن يمني" → Add as a new product (kg, price 400.00) → qty 2.500, cost
   300.00. Pick or add supplier "شركة النور" → paid 200.00 → save. Parties → Suppliers →
   شركة النور shows 550.00 owed.
4. شركة النور → Pay 120.00 by InstaPay → balance 430.00, statement shows PY-000001.
5. Cancel that payment with a reason → balance 550.00, row marked cancelled.
6. Open P-000003 → Void with a reason → stock of "بن يمني" back to 0, balance 0.00, purchase
   marked voided.
7. Sell 15 × "شاي", then void P-000001 → a warning shows the stock will go below zero → confirm
   → the average cost equals what it would be without P-000001.
8. Switch to English and 200% text; repeat 1 and 4; nothing is cut off.
9. Close and reopen the app; everything is still there.

Data shapes and write lists: [data-model.md](data-model.md). Screens: [contracts/](contracts/).
