# Feature Specification: Products and Stock

**Feature Branch**: `002-products-stock`

**Created**: 2026-10-20

**Status**: Draft

**Input**: User description: "Feature "products-stock" (002): products and stock for Daftar Afandi.
Scope: product catalog and stock on hand, built on the 001-foundation schema v1 (products, units,
stock_movements, etc. per docs/research/M0-PHASE1-REPORT.md as amended by M0-DECISIONS.md). Out of
scope: sales, purchases, customers/suppliers, reports content."

## Clarifications

### Session 2026-10-20

- Q: Where does the product list open from, since none of the five sections is Products? → A: From
  a Products button on Home, together with a Home card listing low-stock products. The five
  sections stay unchanged.
- Q: How is a mistaken opening stock or opening cost fixed? → A: A confirmation step before saving
  shows quantity × cost = total. After saving, the quantity is fixed with a stock count; the cost
  is corrected only by later purchases. No other correction exists.
- Q: Is stock counted one product at a time, or on a screen for many products at once? → A: One
  product at a time, from the product's page. A multi-product count screen is deferred.
- Q: How is the product list sorted when no search is typed? → A: Alphabetically by name, Arabic
  order, with Latin-script names after Arabic ones; spelling variants are ordered as search treats
  them.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Add products with their opening stock (Priority: P1)

The shop owner builds the product list. For each product they enter a name, how it is sold (by
piece, kilogram, liter or meter) and its sale price. They may also enter a category, a barcode, a
code (SKU), a low-stock level, and how much they have on the shelf right now with what each unit
cost them. The product then appears in the product list with its stock on hand.

**Why this priority**: Every later feature (sales, purchases, reports) needs products to exist.
A shop cannot start using the app until its goods are in it.

**Independent Test**: Add a product sold by piece and one sold by kilogram, each with opening
stock, close and reopen the app, and confirm both appear with the right price, unit and stock.

**Acceptance Scenarios**:

1. **Given** the product list, **When** the owner adds a product with a name, unit and sale price
   and nothing else, **Then** it is saved and appears in the list with stock 0.
2. **Given** the add form, **When** the name is empty or only spaces, or the sale price is missing,
   **Then** saving is blocked and a message in the active language says what is missing.
3. **Given** the add form, **When** the owner enters an opening quantity of 12 pieces at a cost of
   7.50 EGP each, **Then** a confirmation shows 12 × 7.50 = 90.00 EGP, and after confirming the
   product shows 12 pieces on hand and an average cost of 7.50 EGP.
   Going back from the confirmation keeps the form as typed and saves nothing.
4. **Given** a product sold by piece, **When** the owner enters a fractional quantity (for example
   1.5), **Then** it is rejected with a message that pieces are whole numbers.
5. **Given** a product sold by kilogram, **When** the owner enters 2.375 kg, **Then** it is accepted
   and shown as 2.375 kg; a fourth decimal place cannot be entered.
6. **Given** the add form, **When** the owner enters an opening quantity without a unit cost,
   **Then** saving is blocked and a message says the cost is needed to calculate profit.
7. **Given** another active product already has barcode X, **When** the owner saves a product with
   barcode X, **Then** saving is blocked and the message names the product that has it.
8. **Given** Arabic or Latin digits, **When** the owner types prices and quantities, **Then** both
   digit styles are accepted and the values are shown in the chosen digit style.

---

### User Story 2 - Find a product quickly (Priority: P1)

The owner opens the product list and finds a product by typing part of its name, its code, or its
barcode (typed, or entered by a scanner that acts as a keyboard). They can narrow the list to one
category or to products that are low on stock. Each row shows the name, sale price, stock on hand
with its unit, and a clear mark when stock is low or below zero.

**Why this priority**: With hundreds of products, finding one fast is what makes the list usable,
and sales will reuse the same search.

**Independent Test**: With 2,000 products, search by a partial Arabic name written with a
different hamza or taa marbuta, by barcode, and by code, and confirm the right product appears.

**Acceptance Scenarios**:

1. **Given** a product named "أرز مصري", **When** the owner types "ارز", **Then** it appears in the
   results (spelling variants of alef, taa marbuta, alef maqsura, diacritics and tatweel are
   ignored).
2. **Given** a product with barcode 6221234567890, **When** the owner types or scans that barcode,
   **Then** that product appears first.
3. **Given** a category filter, **When** the owner picks "Drinks", **Then** only active products in
   that category are listed.
4. **Given** a product with a low-stock level of 5 and 3 on hand, **When** the list is shown,
   **Then** the row carries a low-stock mark, and the low-stock filter includes it.
5. **Given** no product matches, **When** the search runs, **Then** the list shows an empty state
   that offers to add a new product with the typed name.
6. **Given** the shop has no products yet, **When** the list opens, **Then** it shows an empty
   state that explains how to add the first product.
7. **Given** Home, **When** the owner taps Products, **Then** the product list opens.
8. **Given** 7 products at or below their low-stock level, **When** Home is shown, **Then** the
   low-stock card lists the 5 lowest with their stock, says 7 in total, and opens the list
   filtered to low stock when tapped.
9. **Given** no product is low on stock, **When** Home is shown, **Then** the card says stock is
   fine.

---

### User Story 3 - Edit and archive products (Priority: P2)

The owner opens a product to see its details (unit, price, average cost, stock on hand,
category, barcode, code, low-stock level) and edits what changed, for example a new price.
A product the shop no longer sells can be archived: it leaves the list and search, but its history
stays, and it can be restored later.

**Why this priority**: Prices change often; a catalog that cannot be corrected is not usable.
Archiving keeps old records honest without deleting anything.

**Independent Test**: Change a product's price, archive it, confirm it is gone from the list and
search, then restore it and confirm it is back with its stock unchanged.

**Acceptance Scenarios**:

1. **Given** a product, **When** the owner changes its sale price and saves, **Then** the new price
   is shown everywhere and kept after a restart.
2. **Given** a product that already has stock movements, **When** the owner opens edit, **Then** the
   unit cannot be changed, and a short note explains why.
3. **Given** a product, **When** the owner archives it, **Then** it disappears from the list,
   search and filters, and its stock history is kept.
4. **Given** the archived products view, **When** the owner restores a product, **Then** it returns
   to the list with its stock and history unchanged.
5. **Given** an archived product with barcode X and an active product now using barcode X, **When**
   the owner restores the archived one, **Then** the restore is blocked with a message naming the
   active product.
6. **Given** a product, **When** the owner looks for a way to delete it, **Then** there is none;
   archive is the only way to remove it from use.

---

### User Story 4 - Correct stock and see its history (Priority: P2)

When goods are damaged, lost, or the shelf count does not match the app, the owner records a stock
adjustment for one product. They choose the reason (damaged, stock count, other). For a stock
count they enter the quantity actually on the shelf and the app records the difference. For
damaged or other they enter the quantity to remove or add, and for "other" a short note is
required. Each product has a history listing every change to its stock, newest first, with date,
type, quantity, and reason.

**Why this priority**: Stock that cannot be corrected drifts from reality, and losses must be
recorded for the profit report (it shows inventory losses as a separate line).

**Independent Test**: For a product with 10 on hand, record a count of 8, then damage of 1, and
confirm stock is 7 and the history shows opening, count and damage entries with their reasons.

**Acceptance Scenarios**:

1. **Given** 10 on hand, **When** the owner records a stock count of 8, **Then** stock becomes 8 and
   the history shows a count adjustment of −2.
2. **Given** a stock count equal to the current stock, **When** the owner saves, **Then** nothing
   is recorded and a message says the stock already matches.
3. **Given** 3 on hand, **When** the owner records damage of 5, **Then** saving is blocked with a
   message that only 3 are on hand.
4. **Given** the "other" reason, **When** the note is empty, **Then** saving is blocked and a
   message says a note is required.
5. **Given** a saved adjustment, **When** the owner views the history, **Then** the entry cannot be
   edited or deleted; a mistake is fixed by recording another adjustment.
6. **Given** an adjustment, **When** it is saved, **Then** the product's average cost does not
   change.
7. **Given** a product whose stock was never set, **When** the owner opens it, **Then** they can set
   its opening stock and cost once, and it is recorded as opening stock, not as an adjustment.

---

### User Story 5 - Organize products into categories (Priority: P3)

The owner creates categories (for example Drinks, Cleaning, Rice and Pasta), renames them, changes
their order, and archives ones no longer needed. Products can be assigned to one category or
none.

**Why this priority**: Helpful for browsing large catalogs, but the app works without categories.

**Independent Test**: Create two categories, assign products, reorder and rename them, archive one,
and confirm its products remain, shown as having no category in filters.

**Acceptance Scenarios**:

1. **Given** a category named "مشروبات" exists, **When** the owner adds "مشروبات" again (including
   spelling variants that search treats as equal), **Then** it is blocked as a duplicate.
2. **Given** a category, **When** the owner renames it, **Then** every product in it shows the new
   name.
3. **Given** a category with products, **When** the owner archives it, **Then** it no longer
   appears in pickers or filters; its products stay and are listed under "no category".
4. **Given** several categories, **When** the owner changes their order, **Then** the new order is
   used in the category filter and picker.

### Edge Cases

- A product sold by piece with a stock count of 2.5: rejected; piece quantities are whole.
- Sale price 0 (free item or price not set yet): allowed, and the row shows the price as 0.
- Price or cost above 10,000,000 EGP, more than two decimal places, or quantity above 1,000,000
  units: rejected with a message giving the limit.
- Two products with the same name: allowed (for example two sizes), and the second save shows a
  notice that a product with this name exists.
- Stock already below zero (possible later, when sales are recorded without stock): the row shows
  a below-zero mark; a stock count can bring it back to the counted quantity.
- A stock count that would raise stock (goods found): recorded as a positive count adjustment at
  the current average cost.
- Opening stock is offered only while the product has no stock history; afterwards the field is
  gone and changes go through adjustments.
- A wrong opening cost (for example 75 instead of 7.50): it cannot be corrected directly; the
  average cost moves toward the right value as purchases are recorded. The confirmation step is the
  guard against this mistake.
- The app is closed in the middle of saving a product with opening stock: either the product and
  its opening stock are both saved, or neither is.
- A barcode with spaces before or after: the spaces are removed before saving and searching.
- Very long names in Arabic or English, and 200% text size: rows and details wrap and stay
  readable; nothing is cut off without a way to see it in full.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The owner MUST be able to open the product list from a Products button on Home. The
  five navigation sections stay as they are.
- **FR-001a**: Home MUST show a low-stock card listing up to 5 active products that are low on stock
  (as defined in FR-008, lowest stock first) with their stock on hand, plus the total count and a way to
  open the product list filtered to low stock. With none low, the card says stock is fine. Tapping
  a product opens its details.
- **FR-002**: Users MUST be able to add a product with: name (required, 1–100 characters after
  trimming), unit (required: piece, kilogram, liter or meter), sale price per unit (required,
  0 to 10,000,000 EGP, at most two decimal places), and optionally a category, barcode (up to 64
  characters), code (up to 64 characters), and low-stock level.
- **FR-003**: Quantities MUST be whole numbers for piece products and allow up to three decimal
  places for kilogram, liter and meter products, between 0 and 1,000,000 units.
- **FR-004**: Users MUST be able to enter an opening quantity and its cost per unit when adding a
  product, or later while the product has no stock history. A cost is required whenever the
  opening quantity is above zero. Before an opening stock above zero is saved, a confirmation MUST
  show the quantity, the cost per unit, and their total. The product and its opening stock MUST be
  saved together or not at all. Saved opening stock cannot be edited or corrected directly.
- **FR-005**: The system MUST reject a barcode that another active product already uses, naming
  that product. Two products MAY share a name; saving the second shows a notice.
- **FR-006**: Stock on hand MUST always equal the total of the product's recorded stock changes;
  it is never typed in directly.
- **FR-007**: The system MUST keep an average cost per unit for each product, set from the opening
  stock (and, in later features, from purchases and returns). Adjustments MUST NOT change it.
- **FR-008**: The product list MUST show for each product its name, sale price, stock on hand with
  its unit, and marks for low stock and below-zero stock. A product is low on stock when its stock
  is at or below its low-stock level, or below zero; the list filter and the Home card use this
  same rule. The list MUST be sorted alphabetically by name (Arabic order, Latin-script names after
  Arabic ones, spelling variants ordered as search treats them); filters keep this order.
- **FR-009**: Users MUST be able to search active products by part of the name, code, or barcode.
  Name search MUST ignore Arabic diacritics and tatweel, treat أ إ آ as ا, ة as ه, ى as ي, and treat
  Arabic and Latin digits as the same. An exact barcode match MUST be listed first; the other
  results follow the list's alphabetical order.
- **FR-010**: Users MUST be able to filter the list by one category, by "no category", and by low
  stock, and combine a filter with a search.
- **FR-011**: Users MUST be able to edit any product field except the unit once the product has
  stock history. Edits MUST NOT change stock or average cost.
- **FR-012**: Users MUST be able to archive and restore products. Archived products MUST NOT
  appear in the list, search, or filters, and MUST be listed in an archived products view. Nothing
  is ever deleted.
- **FR-013**: Users MUST be able to record a stock adjustment with a reason: damaged (removes
  stock), stock count (sets stock to the counted quantity), or other (adds or removes; a note of
  1–200 characters is required). An optional note is allowed for the other reasons.
- **FR-014**: A damaged or other adjustment MUST NOT remove more than is on hand. A stock count
  MUST NOT be negative. A count equal to the current stock MUST record nothing.
- **FR-015**: Stock changes MUST be permanent: they cannot be edited or deleted, only offset by a
  new adjustment.
- **FR-016**: Each product MUST have a stock history showing every change, newest first, with its
  date and time, type (opening, adjustment and its reason; later also sale, purchase, return,
  void), signed quantity, and note.
- **FR-017**: Users MUST be able to create, rename, reorder, and archive categories (name 1–40
  characters). Two active categories MUST NOT have names that search treats as equal. Archiving a
  category MUST keep its products and show them as having no category in filters and pickers.
- **FR-018**: All new screens and messages MUST be available in Arabic (right-to-left) and English
  (left-to-right), follow the chosen digit style, and stay fully usable at 200% system text size,
  with spoken labels for every interactive element, as in 001-foundation.
- **FR-019**: Money MUST be shown in EGP with the currency label "ج.م" in Arabic and "EGP" in
  English; quantities MUST be shown with their unit.

### Key Entities *(include if feature involves data)*

- **Product**: something the shop sells. Name, unit (piece, kilogram, liter, meter), sale price
  per unit, average cost per unit (kept by the app), optional category, barcode, code, and
  low-stock level. Active or archived.
- **Category**: a named group of products with a display order. Active or archived.
- **Stock change**: one permanent entry in a product's stock history: type (opening, adjustment;
  later sale, purchase, return, void), signed quantity, cost per unit at that moment, reason and
  note for adjustments, and when it happened. Stock on hand is the total of these entries.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An owner adds a new product with opening stock in under 30 seconds.
- **SC-002**: With 2,000 products, search results update within 1 second of typing, on a
  low-end Android phone (2 GB RAM).
- **SC-003**: For every product, stock on hand equals the total of its stock history, in 100% of
  checked cases, including after app restarts and interrupted saves.
- **SC-004**: An owner records a stock count for a product in under 20 seconds from the product
  list.
- **SC-005**: Every new screen is fully usable in Arabic RTL and English LTR, at 100% and 200%
  system text size, with no clipped or overlapping text.
- **SC-006**: Every product, category and stock change entered is still there after closing and
  reopening the app.

## Assumptions

- Barcodes are typed or come from a scanner that acts as a keyboard. Scanning with the phone camera
  is out of scope (it would need a new package, which needs approval).
- One unit per product: piece, kilogram, liter or meter. Cartons and packs with conversion are
  planned for v1.1 (decision Q11).
- Product photos are out of scope.
- Stock decreases from sales and increases from purchases arrive with the sales and purchases
  features; this feature only records opening stock and adjustments, but the history already shows
  every type.
- The negative-stock setting (warn or block when selling more than is on hand) belongs to the
  sales feature and is not shown here.
- An adjustment that adds stock uses the product's current average cost; adjustments never change
  the average cost.
- Stock counts are recorded one product at a time from the product's page. A screen for counting
  many products in one go is deferred to a later feature.
- Inventory losses in the profit report are derived from adjustments; the report itself is out of
  scope.
- Low-stock marks show in the product list and the Home low-stock card only; no notifications.
- The product's code (SKU) is not required to be unique.
- Sales, purchases, customers and suppliers, expenses, report content, app lock, export/restore,
  and invoice sharing are out of scope.
- The stored data already supports products, categories and stock changes (schema v1 from
  001-foundation); no change to stored data is expected.
