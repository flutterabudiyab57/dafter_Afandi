# Feature Specification: Purchases and Suppliers

**Feature Branch**: `004-purchases-suppliers`

**Created**: 2026-10-21

**Status**: Draft

**Input**: User description: "المرحلة 004: المشتريات والموردين."
Purchase invoices paid in cash, on credit, or partly paid, which bring stock in and update each
product's average cost, plus suppliers and their account (statement, balance and payments made),
built on schema v1, 002-products-stock and 003-sales-customers. Out of scope: purchase returns to
the supplier (decision Q18), sale returns, invoice sharing, expenses, reports, app lock, backup.

## Clarifications

### Session 2026-10-21

- Q: Can the owner add a product that is not in the list yet from the purchase screen? → A: Yes. A
  quick add (name, unit, selling price, optional barcode) creates the product without leaving the
  purchase, and adds it as a line; its stock and cost come from the purchase itself.
- Q: Can a purchase be voided when its goods were already sold, so stock would go below zero? →
  A: Yes, after a warning that names each product and the stock it will have, as with the sale
  shortage warning. Going back voids nothing.
- Q: Can the purchase screen update a product's selling price? → A: No. Selling prices change only
  from Products; a purchase changes only stock and average cost.
- Q: Which cost does a purchase line start with? → A: The unit cost of that product on its last
  saved, non-voided purchase; if it was never bought, its current average cost (0 for a new
  product).
- Q: Should the screen warn when a line's cost is at or above the product's selling price? → A:
  Yes, with a notice under that line; it does not block saving and needs no confirmation.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Record a purchase paid in cash (Priority: P1)

Goods arrive. The owner opens Purchases, starts a new purchase, and adds the products received by
typing part of a name or code, or the barcode. Each line shows the product, quantity, unit cost
and line total. The cost is prefilled from the last time the product was bought and is changed
when the supplier's paper invoice shows a different price. The owner can give a discount on a line or
on the whole invoice, may note the supplier's own invoice number and the date on it, picks how
the supplier was paid (cash, mobile wallet or InstaPay), and saves. The purchase gets the next
number, stock goes up, and each product's average cost takes the new cost into account.

**Why this priority**: Without purchases, stock only goes down and the average cost (and so the
profit on every sale) stays at whatever was typed as opening stock.

**Independent Test**: With "شاي" at 10 in stock and an average cost of 9.00, buy 10 more at 11.00
for cash, then confirm the purchase is listed with the next number, the stock is 20 and the
average cost is 10.00.

**Acceptance Scenarios**:

1. **Given** "شاي" with 10 in stock at an average cost of 9.00, **When** the owner buys 10 × "شاي"
   at 11.00 and saves a cash purchase, **Then** purchase number 1 is saved with total 110.00 EGP,
   the stock of "شاي" is 20, its average cost is 10.00, and the purchase screen is empty and ready
   for the next one.
2. **Given** a new purchase, **When** the owner scans or types a barcode that matches one active
   product, **Then** that product is added with quantity 1; adding it again raises the quantity of
   the existing line instead of adding a second line.
3. **Given** two lines of 100.00 and 300.00, **When** the owner gives an invoice discount of 40.00,
   **Then** the total is 360.00 and the discount lowers the cost that enters each product's
   average by 10.00 and 30.00 respectively.
4. **Given** a product sold by kilogram, **When** the owner enters 2.500 kg at 30.00 per kg, **Then**
   the line total is 75.00; a piece product rejects a fraction.
5. **Given** a product whose stock is zero or below zero, **When** a purchase of it is saved,
   **Then** its average cost becomes the cost of this purchase alone.
6. **Given** a purchase with no lines, **When** the owner tries to save, **Then** saving is
   blocked.
7. **Given** a purchase with lines, **When** the owner leaves the purchase screen, **Then** the
   app asks before discarding the lines.
8. **Given** the purchase form, **When** the owner sets the invoice date, **Then** today and past
   dates are accepted and future dates are not; the date defaults to today.
9. **Given** the product search on a purchase finds nothing for "بن يمني", **When** the owner
   chooses to add it, enters unit kg and selling price 400.00, and saves the quick add, **Then**
   the product exists in Products with no stock and is added to the purchase as a line; once the
   purchase is saved its stock and average cost come from that line. Leaving the purchase without
   saving keeps the new product, with no stock.
10. **Given** "شاي" sells at 12.50 and was last bought at 11.00, **When** the owner adds it to a
    purchase, **Then** the cost starts at 11.00; changing it to 13.00 shows a notice under the line
    that the cost is at or above the selling price, and the purchase can still be saved.

---

### User Story 2 - Buy on credit or partly paid from a named supplier (Priority: P1)

The owner picks the supplier for the purchase (searching by name or phone, or adding a new one on
the spot) and enters how much was paid now: all of it, part of it, or nothing. What is not paid is
added to what the shop owes that supplier.

**Why this priority**: Wholesalers commonly deliver on credit and are paid later; knowing what the
shop owes each supplier is the main reason owners keep a paper notebook today.

**Independent Test**: Buy 500.00 from a supplier, paying 200.00 now, then open the supplier and
confirm the shop owes 300.00 and the statement lists the purchase and the payment.

**Acceptance Scenarios**:

1. **Given** a purchase of 500.00 from supplier "شركة النور", **When** the owner sets paid now to
   200.00 and saves, **Then** the purchase shows paid 200.00 and remaining 300.00, and the amount
   the shop owes the supplier rises by 300.00.
2. **Given** a purchase with no supplier, **When** the owner sets paid now below the total,
   **Then** saving is blocked with a message that credit needs a named supplier.
3. **Given** a purchase paid in full with a named supplier, **When** it is saved, **Then** the
   supplier's statement shows the purchase and the matching payment, and the balance is unchanged.
4. **Given** the supplier picker, **When** the owner types a name that does not exist, **Then**
   they can add that supplier (name, optional phone) without leaving the purchase.
5. **Given** paid now, **When** it is more than the total, **Then** it is rejected.

---

### User Story 3 - See past purchases (Priority: P1)

The owner opens the list of purchases, newest first, and opens one to see its number, invoice
date, supplier and supplier's invoice number, lines, discounts, total, amount paid, remaining
amount and payment method.

**Why this priority**: The owner must be able to check what was bought, from whom and at what
cost, and match it against the supplier's paper invoice.

**Independent Test**: Save three purchases, open the purchase list, and confirm all three appear
newest first with number, date, supplier and total; open one and confirm every line.

**Acceptance Scenarios**:

1. **Given** saved purchases, **When** the owner opens the list, **Then** each row shows the number
   (for example P-000007), invoice date, supplier or "no supplier", total, and a mark for credit
   or partly paid.
2. **Given** the list, **When** the owner searches by purchase number, supplier name or the
   supplier's invoice number, **Then** only matching purchases are shown.
3. **Given** a purchase, **When** the owner opens it, **Then** each line shows the product name as
   it was at the time of purchase, quantity with unit, unit cost, line discount and line total,
   even if the product was later renamed or archived.
4. **Given** a purchase, **Then** it is titled as a purchase invoice and is never called a tax
   invoice or tax receipt.

---

### User Story 4 - Keep suppliers and their accounts (Priority: P2)

The owner keeps a list of suppliers with name, phone, address and note, next to customers in the
Parties section. Each supplier shows their balance (what the shop owes them, or what they owe the
shop). A supplier the shop already owed before the app was used can be given an opening balance.
The owner opens a supplier's statement to see every purchase, payment and balance change, with a
running balance.

**Why this priority**: Needed to manage what the shop owes, but cash purchases already work
without it.

**Independent Test**: Add a supplier with an opening balance of 1,000.00 owed by the shop, buy
400.00 on credit, and confirm the list shows 1,400.00 and the statement shows both rows with the
running balance.

**Acceptance Scenarios**:

1. **Given** the Parties section, **When** the owner switches to suppliers and adds "شركة النور"
   with phone 0223456789, **Then** it appears in the supplier list with balance 0.00.
2. **Given** a new supplier, **When** the owner enters an opening balance of 1,000.00 owed by the
   shop (or 50.00 the supplier owes the shop), **Then** the balance shows 1,000.00 owed to the
   supplier (or 50.00 in the shop's favour) and the statement starts with an opening balance row.
3. **Given** suppliers, **When** the owner searches by part of the name (with the same Arabic
   spelling rules as products) or part of the phone number, **Then** matching suppliers are
   listed.
4. **Given** the list, **When** the owner filters to suppliers the shop owes, **Then** only those
   are listed, highest balance first.
5. **Given** a supplier's statement, **Then** rows are newest first with date and time, type
   (opening balance, purchase with its number, payment with its payment number), amount and
   running balance; tapping a purchase row opens the purchase.
6. **Given** a supplier, **When** the owner edits the name or phone, **Then** old purchases still
   open and the statement is unchanged.
7. **Given** a supplier, **When** the owner archives them, **Then** they leave the list and the
   supplier picker but their purchases and statement stay; they can be restored. A supplier with a
   non-zero balance can be archived only after a confirmation that shows the balance.

---

### User Story 5 - Pay a supplier (Priority: P2)

The owner pays a supplier part or all of what the shop owes. They open the supplier, record the
amount, the method (cash, wallet, InstaPay) and an optional note. The payment gets a payment
number and lowers what the shop owes.

**Why this priority**: Without it, supplier balances only grow and the account is useless.

**Independent Test**: The shop owes a supplier 300.00 and pays 120.00 by InstaPay; the balance
becomes 180.00 and the statement shows a payment with payment number 1 and the method.

**Acceptance Scenarios**:

1. **Given** the shop owes a supplier 300.00, **When** the owner records 120.00 by InstaPay,
   **Then** the balance is 180.00 and the statement shows the payment with its number (for
   example PY-000001) and method.
2. **Given** the payment form, **When** the amount is empty, zero, or has more than two decimals,
   **Then** saving is blocked with a message.
3. **Given** the shop owes a supplier 300.00, **When** the owner records 350.00, **Then** a notice
   says the supplier will owe the shop 50.00, and confirming saves it.

---

### User Story 6 - Void a wrong purchase or cancel a wrong supplier payment (Priority: P2)

The owner saved a purchase by mistake (wrong supplier, wrong quantities or costs) or recorded a
payment that did not happen. They open it, choose Void (or Cancel for a payment), write the
reason, and confirm. The document stays in the lists, marked voided or cancelled, and its effects
are undone, including on the average cost of its products.

**Why this priority**: A wrong cost typed on a purchase silently distorts the profit of every
later sale of that product; without a correction path it stays wrong forever, since purchase
returns are not in this release (decision Q18).

**Independent Test**: Buy 10 pieces on credit from a supplier for 100.00, void the purchase with a
reason, and confirm the stock, the average cost and the supplier balance are all back to what they
were before, and the purchase shows as voided with its reason.

**Acceptance Scenarios**:

1. **Given** a saved purchase, **When** the owner voids it with the reason "سعر خطأ", **Then** it
   shows as voided with the reason and time, each product's stock goes back down by the quantity
   bought, and the purchase stays in the list with a voided mark.
2. **Given** a product bought twice (first at 8.00, then at 12.00) and the first purchase voided,
   **Then** the product's average cost is the same as if the first purchase had never been
   recorded.
3. **Given** a voided credit purchase of 500.00 with 200.00 paid at purchase, **Then** the
   supplier's statement shows the reversal of the purchase and of the 200.00 payment, and the
   balance is as before the purchase.
4. **Given** the void form, **When** the reason is empty or only spaces, **Then** voiding is
   blocked.
5. **Given** a voided purchase, **Then** it cannot be voided again, and it does not count in the
   unpaid filter.
6. **Given** a purchase whose products have since been sold so that voiding would take their stock
   below zero, **When** the owner voids it, **Then** a warning names each such product and the
   stock it will have; confirming voids the purchase and the stock goes below zero, and going back
   voids nothing.
7. **Given** a standalone supplier payment of 120.00, **When** the owner cancels it with a reason,
   **Then** the statement shows a reversal row, the balance goes back up by 120.00, and the
   payment shows as cancelled; it cannot be cancelled twice.
8. **Given** a payment made at the time of a purchase, **Then** it cannot be cancelled on its own;
   only voiding the purchase undoes it.

### Edge Cases

- The same product added twice by search: the existing line's quantity goes up; a product can be
  on the purchase only once.
- A unit cost of 0 (free goods from the supplier): allowed; it lowers the average cost.
- A product archived while it is on an unsaved purchase: saving is blocked and names the product.
- A supplier archived while picked on an unsaved purchase: saving is blocked with a message.
- Very large amounts: unit cost up to 10,000,000 EGP and quantity up to 1,000,000 units, as in
  002 and 003; totals can be larger and are still exact.
- Rounding: a line total is quantity × cost rounded to the nearest piaster, half up; an invoice
  discount is spread over the lines so the line shares add up exactly to the discount; the average
  cost is rounded to the nearest piaster per unit.
- Buying into negative stock (the shop sold goods it had not recorded): the new average cost is
  the cost of this purchase alone; units already sold are not re-costed (M0 report, known
  limitation).
- The app is closed in the middle of saving or voiding a purchase: the purchase, its lines, the
  stock changes, the average costs and the supplier's account rows are all saved, or none are. No
  purchase or payment number is skipped or used twice.
- Two purchases saved in quick succession get consecutive numbers.
- A purchase dated in the past is listed by its invoice date, but its effect on the average cost
  follows the order in which purchases were saved, not their invoice dates.
- Voiding a purchase whose product was archived since: allowed; the stock and average cost are
  still corrected.
- Voiding a purchase whose supplier was archived since: allowed; their account is still restored.
- A supplier and a customer with the same name: allowed; they are separate parties.
- Long product or supplier names at 200% text size: they wrap and stay readable.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Purchases section MUST offer New purchase and the purchase list. The Parties
  section MUST offer both customers (from 003) and suppliers, with a clear way to switch between
  them. The five sections stay as they are.
- **FR-002**: A purchase MUST have at least one line. Each line has one active product, a quantity
  (whole for piece products, up to three decimals otherwise, above 0, at most 1,000,000 units),
  a unit cost (editable, 0 to 10,000,000 EGP, at most two decimals), and an optional line
  discount (0 up to the line's amount before discount). The unit cost MUST be prefilled with the
  unit cost on the product's last saved, non-voided purchase line; for a product never bought, with
  its current average cost.
- **FR-002a**: When a line's unit cost after its line discount is at or above the product's
  current selling price, the line MUST show a notice saying so. The notice does not block saving
  and asks for no confirmation; nothing about the product changes.
- **FR-003**: Products MUST be added by search (part of name, code or barcode, same rules as the
  002 product search) or by an exact barcode. Adding a product already on the purchase MUST raise
  its quantity instead of adding a line.
- **FR-003a**: When the product search finds no match, users MUST be able to add a new product
  from the purchase screen without leaving it: name, unit and selling price (same rules as 002),
  optional barcode. The product is created at once with no stock and no opening stock, and is
  added to the purchase as a line. A barcode already used by another product is rejected, as in
  002.
- **FR-004**: Line total = quantity × unit cost rounded half up to the piaster, minus the line
  discount. Subtotal = sum of line totals. An optional invoice discount (0 up to the subtotal)
  gives total = subtotal − invoice discount. The invoice discount MUST be shared over the lines so
  the shares add up to it exactly; each line's cost after its share is what enters the average.
- **FR-005**: A purchase MAY record the supplier's own invoice number (up to 50 characters) and
  MUST record an invoice date (today by default, never in the future) and MAY have a note (up to
  200 characters).
- **FR-006**: Paid now MUST be between 0 and the total, and defaults to the total. If it is below
  the total, a named, active supplier is required. The payment method (cash, mobile wallet,
  InstaPay) applies to the amount paid now; it defaults to cash.
- **FR-007**: Saving a purchase MUST, all together or not at all: give the purchase the next number
  in an unbroken sequence; store the purchase and its lines with each product's name and unit as
  they are at that moment; raise each product's stock by its quantity; update each product's
  average cost from its stock and average cost before the line and the line's cost after
  discounts (if the stock before is zero or below, the line's own unit cost becomes the average);
  record the average cost before and after each line; and, with a named supplier, add the total to
  the supplier's account and the amount paid now as a payment.
- **FR-008**: Saving a purchase MUST NOT change any product's selling price; selling prices change
  only from Products.
- **FR-009**: Saved purchases MUST NOT be edited or deleted. Their numbers are never reused.
- **FR-009a**: Users MUST be able to void a saved purchase once, with a reason (1–200 characters
  after trimming). Voiding MUST, all together or not at all: mark the purchase voided with the
  reason and time; take each line's quantity back out of stock; rebuild the average cost of each
  affected product as if the voided purchase had never been recorded, keeping every other
  movement in the order it was saved; and, with a named supplier, add rows that reverse the
  purchase and the amount paid at purchase, so the balance returns to what it was before. Voided
  purchases stay listed with a voided mark and reason. When voiding would take any product's stock
  below zero, the void MUST first warn and name each such product with the stock it will have;
  the owner may confirm and void, or go back and change nothing.
- **FR-010**: The purchase list MUST show purchases newest first (by invoice date, then by number)
  with number, invoice date, supplier (or "no supplier"), total, and a mark when not fully paid.
  It MUST be searchable by number, supplier name and the supplier's invoice number, and filterable
  to credit or partly paid purchases.
- **FR-011**: The purchase view MUST show number, invoice date, time saved, supplier, supplier's
  invoice number, each line (name, quantity with unit, unit cost, line discount, line total),
  subtotal, invoice discount, total, paid now, remaining, payment method when something was paid,
  and note. It MUST be titled as a purchase invoice and never as a tax document.
- **FR-012**: Users MUST be able to add and edit suppliers with the same fields and rules as
  customers in 003: name (required, 1–100 characters after trimming), phone (optional, 7–15
  digits with an optional leading +, spaces and dashes ignored), address and note (optional, up to
  200 characters). Two suppliers MAY share a name; saving the second shows a notice.
- **FR-013**: A new supplier MAY get an opening balance, owed by the shop or in the shop's favour,
  0 to 10,000,000 EGP, at most two decimals. It is recorded once, as the first statement row, and
  cannot be edited afterwards.
- **FR-014**: A supplier's balance MUST always equal the sum of their account rows; it is never
  typed in directly. Positive means the shop owes the supplier.
- **FR-015**: The supplier list MUST show name, phone and balance, sorted by name (same Arabic
  order as products), searchable by name (same spelling rules as products) and by phone, and
  filterable to suppliers the shop owes (highest balance first).
- **FR-016**: The supplier statement MUST list every account row newest first with date and time,
  type, document number where there is one, signed amount and running balance; a purchase row
  opens its purchase. The supplier page also lists the supplier's purchases.
- **FR-017**: Users MUST be able to record a payment to a supplier: amount (above 0, up to
  10,000,000 EGP, at most two decimals), method, optional note. It gets the next payment number
  in its own unbroken sequence. A payment larger than the balance MUST show a notice of the
  resulting amount the supplier will owe the shop before saving.
- **FR-017a**: Users MUST be able to cancel a standalone supplier payment once, with a reason
  (1–200 characters after trimming), by adding a reversing row of the same amount; the payment
  then shows as cancelled. A payment made with a purchase cannot be cancelled on its own.
- **FR-018**: Users MUST be able to archive and restore suppliers. Archived suppliers MUST NOT
  appear in the list, search or supplier picker, and are listed in an archived suppliers view.
  Archiving a supplier with a non-zero balance requires a confirmation that shows it. Nothing is
  ever deleted.
- **FR-019**: Document numbers MUST be shown with a prefix in the user interface only: P- for
  purchases and PY- for supplier payments, padded to six digits (for example P-000007).
- **FR-020**: All new screens and messages MUST be available in Arabic (right-to-left) and English,
  follow the chosen digit style, accept Arabic and Latin digits in every number field, stay fully
  usable at 200% text size, and give spoken labels to every interactive element, as in 001–003.
  Money is shown with "ج.م" in Arabic and "EGP" in English; quantities with their unit.

### Key Entities *(include if feature involves data)*

- **Purchase invoice**: a numbered, permanent record of one delivery from a supplier: invoice
  date, time saved, optional supplier and the supplier's own invoice number, subtotal, invoice
  discount, total, amount paid now, payment method, optional note. Voidable once.
- **Purchase line**: one product on a purchase: the product's name and unit as they were,
  quantity, unit cost, line discount, line total, its share of the invoice discount, the net cost
  that entered the average, and the product's average cost before and after the line.
- **Supplier**: a person or business the shop buys from: name, phone, address, note. Active or
  archived.
- **Supplier account row**: one permanent entry in a supplier's account: opening balance, purchase,
  or payment made (with payment number and method), with a signed amount and time. The balance is
  the sum of the rows. Reversal rows (for a voided purchase or a cancelled payment) undo an earlier
  row and point to it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An owner records a 5-line purchase from a named supplier, starting from the
  Purchases section, in under 90 seconds.
- **SC-002**: With 2,000 products, results for a product search on the purchase screen appear
  within 1 second of typing, on a mid-range phone.
- **SC-003**: For every supplier, the shown balance equals the sum of their statement rows, in 100%
  of automated checks after random sequences of purchases, payments, voids and cancellations.
- **SC-004**: For every product, the stored average cost equals the cost rebuilt from its full
  history of stock movements, in 100% of automated checks after random sequences of purchases,
  sales, voids and adjustments.
- **SC-005**: For every purchase, the total equals the lines minus the discounts to the piaster,
  and stock after the purchase equals stock before plus the quantities bought, in 100% of
  automated checks.
- **SC-006**: Purchase and supplier payment numbers have no gaps and no repeats, including after
  the app is closed while saving.
- **SC-007**: Every new screen is fully usable in Arabic RTL and English LTR, at 100% and 200% text
  size, with no cut-off text or controls.
- **SC-008**: Every purchase, supplier and payment is still there after closing and reopening the
  app.

## Assumptions

- The invoice date is the business date written on the supplier's invoice; the time saved is
  always the moment of saving. Average cost follows the order of saving (M0 report, risk R7).
- Discounts are amounts in EGP, not percentages.
- A purchase without a supplier must be paid in full (the same rule as walk-in sales).
- A purchase paid in full with a named supplier writes both a purchase row and a payment row so it
  appears on the statement (mirrors decision Q17 for sales).
- Card payments are not offered in the user interface (decision Q23: cash, wallet, InstaPay).
- A supplier's balance in the shop's favour is not applied to new purchases automatically.
- There is no credit limit for suppliers (decision Q12).
- Purchase returns to the supplier are not in this release (decision Q18); voiding is
  whole-purchase only.
- Voiding a purchase rebuilds the average cost by replay (decision Q18).
- Customers and suppliers are separate lists; one party cannot be both.
- No schema change is needed: suppliers, the supplier account, purchases and purchase lines
  already exist in the v1 tables, with the P- and PY- number sequences.
