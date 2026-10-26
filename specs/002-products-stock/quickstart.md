# Quickstart: Products and Stock

This guide proves that 002 works. Behaviour is defined in the [spec](spec.md), the types in
[data-model.md](data-model.md), and the interfaces in [contracts/](contracts/).

## Prerequisites

- 001-foundation is complete; the app opens on Home after first run.
- Flutter 3.47.7. No new packages (research R2).
- An Android phone or emulator for the manual part.

## Automated checks

```bash
flutter analyze
```

```bash
flutter test
```

Both must pass with no issues. The new tests cover:
- domain limits;
- repository rules (contracts/repositories-and-domain.md), including the property test and the
  performance test;
- cubits, screens, routes and ARB parity;
- 200% text and RTL/LTR on every new screen.

## Manual scenarios (phone, Arabic first, then repeat in English)

| # | Steps | Expected |
|---|---|---|
| 1 | Home → Products on a fresh install | Empty state with "add your first product"; Home card says "add products to track stock" |
| 2 | Add "أرز مصري", piece, price 25, opening 12 at 7.50 | Confirmation shows 12 × 7.50 = 90.00; after confirming, the list shows 12 pieces |
| 3 | Add a kg product with opening 2.375 at 40 | Accepted; typing a 4th decimal does nothing |
| 4 | Type 1.5 as opening quantity for a piece product | Error: pieces are whole numbers |
| 5 | Add a product with the barcode from #2's product | Blocked, naming the other product |
| 6 | Search "ارز", then search the barcode typed in Arabic digits | Both find the product; the exact barcode is first |
| 7 | Add products named "Zeta", "باذنجان", "أرز", "تفاح" | List order: أرز, باذنجان, تفاح, Zeta |
| 8 | Set the low-stock level of #2 to 15 | Low mark on the row; Home card lists it; tapping the card opens the list filtered to low |
| 9 | Details of #2 → Adjust → Stock count 10 | Stock 10; history shows −2 (count); average cost unchanged |
| 10 | Adjust → Damaged 11 | Blocked: only 10 on hand |
| 11 | Adjust → Other, Remove 1, empty note | Blocked: note required; with a note it saves, stock 9 |
| 12 | Adjust → Stock count 9 | "Stock already matches"; nothing in history |
| 13 | Edit #2: change the price; try to change the unit | Price saved; unit disabled with a note |
| 14 | Add a product without opening, open details → Set opening stock | Allowed once; afterwards the action is gone |
| 15 | Archive #2 | Gone from list, search, Home card; in Archived; restore brings it back with stock 9 and history |
| 16 | Categories: add "مشروبات", then "مشروبات" again; reorder; archive one with products | Duplicate blocked; order used in filters; its products appear under "No category" |
| 17 | Force-stop the app during or after each save, reopen | Everything saved is still there; no half-saved product |
| 18 | System text size 200%, dark mode, both languages | Every new screen readable and usable; nothing clipped |
| 19 | With about 2,000 products (debug seed, not shipped), type in search | Results update within 1 second (SC-002) |

Scenario 19 needs a debug-only seed path. It is added in a test helper or behind `kDebugMode`, and
it never runs in release.

iOS: same scenarios on a Mac before release (not checkable on this Windows machine).
