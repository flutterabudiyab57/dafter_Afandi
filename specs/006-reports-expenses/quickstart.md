# Quickstart: Reports, Home Dashboard and Expenses

## Automated

```bash
flutter analyze
flutter test
flutter test test/drift
flutter test test/features/reports
flutter test test/features/expenses
flutter test test/features/payments
```

Expected: analyze clean and all tests green, including:
- the v1 → v2 migration test and the upgrade data test: balances, stock and statements unchanged,
  one part per old payment (SC-009, FR-041);
- the profit property test: for random sales, returns, voids, adjustments and expenses, every line
  equals a hand sum to the piaster (SC-004);
- the parts property test: Σ parts = amount paid for every parent;
- the performance test: 20,000 sales and 2,000 expenses, each report under 2 s (SC-005).

## On a phone (debug build)

```bash
flutter build apk --debug
```

Install over a build from 005 that already has data, to check the upgrade. Then:

1. Open the app. The earlier balances, invoices and statements are as before; old payments show
   one method and no account number.
2. Home shows today's sales and count, money collected, the running-low count and the top 3 who
   owe. Tap each card; each opens its list.
3. New sale of 500.00 → Split payment → 300.00 cash, 200.00 wallet → the account field offers
   nothing yet → type `01012345678` → save. The invoice shows both parts.
4. New sale → wallet → the account field offers `01012345678` → tap it → save.
5. Sell enough "شاي" to reach its low-stock level → the saved message says it is running low →
   tap it → the running-low list opens.
6. Reports → this month: net sales, cost of goods, gross profit, inventory losses, expenses, net
   profit. Add a damage adjustment and a count adjustment that adds stock; the losses line shows the
   net.
7. Reports → Expenses → New → rent 1,500.00 by InstaPay to your address → save as E-1. Profit
   drops by 1,500.00. Void it with a reason → it stays listed, marked voided, profit goes back.
8. Reports → Money collected for today: cash and wallet match steps 3 and 4.
9. Reports → Top sellers and Balances: order and totals match the data.
10. Custom range with the end before the start → refused with a reason.
11. English and 200% text, light and dark: repeat 2, 3 and 6; nothing is cut off.

Data shapes and write lists: [data-model.md](data-model.md). Screens and interfaces:
[contracts/](contracts/).
