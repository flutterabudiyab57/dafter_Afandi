# Feature Specification: Sales and Customers

**Feature Branch**: `003-sales-customers`

**Created**: 2026-10-20

**Status**: Draft

**Input**: User description: "المرحلة 003: المبيعات (فاتورة بيع كاش وآجل + العملاء ودفترهم)."
Sales invoices paid in cash, on credit, or partly paid, plus customers and their account
(statement and balance), built on schema v1 and on 002-products-stock. Out of scope: returns (voids are in scope, see Clarifications),
invoice sharing (image/PDF), purchases, suppliers, expenses, reports, app lock, backup.

## Clarifications

### Session 2026-10-20

- Q: How is a saved invoice or payment that was entered by mistake corrected in 003? → A: A whole
  invoice can be voided with a written reason: its stock comes back at the cost recorded on the
  sale, and the customer's account is restored. A standalone customer payment can be cancelled
  with a reason by a reversing row. Nothing is edited or deleted; numbers stay used and the
  document shows as voided or cancelled.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ring up a cash sale (Priority: P1)

The owner opens Sales, starts a new sale, and adds products by typing part of a name or code, or
the barcode. Each line shows the product, quantity, unit price and line total. The price comes
from the product and can be changed for this sale. The owner can give a discount on a line or on
the whole invoice, picks how the customer paid (cash, mobile wallet or InstaPay), and saves. The
invoice gets the next number, stock goes down, and the invoice can be opened later.

**Why this priority**: Selling is the reason the app exists. A walk-in cash sale is the most common
transaction in a small shop.

**Independent Test**: With two products in stock, sell 2 of one and 0.750 kg of the other for cash,
then confirm the invoice is listed with the next number and the right total, and that both stocks
went down.

**Acceptance Scenarios**:

1. **Given** products with stock, **When** the owner adds 2 × "شاي" at 12.50 and saves a cash
   sale, **Then** invoice number 1 is saved with total 25.00 EGP, the stock of "شاي" drops by 2,
   and the sale screen is empty and ready for the next sale.
2. **Given** a new sale, **When** the owner scans or types a barcode that matches one active
   product, **Then** that product is added with quantity 1; adding it again raises the quantity of
   the existing line instead of adding a second line.
3. **Given** a line of 3 × 10.00, **When** the owner gives a line discount of 2.00 and an invoice
   discount of 3.00, **Then** the line total is 28.00, the subtotal 28.00 and the total 25.00.
   A discount larger than its line, or an invoice discount larger than the subtotal, is rejected.
4. **Given** a product sold by kilogram, **When** the owner enters 0.750 kg at 40.00 per kg,
   **Then** the line total is 30.00; a piece product rejects a fraction.
5. **Given** a sale whose quantity is more than the stock on hand, **When** the owner saves,
   **Then** a warning names each short product with its stock; confirming saves the sale and the
   stock goes below zero, and going back saves nothing.
6. **Given** a sale with no lines, **When** the owner tries to save, **Then** saving is blocked.
7. **Given** a sale with lines, **When** the owner leaves the sale screen, **Then** the app asks
   before discarding the lines.

---

### User Story 2 - Sell on credit or partly paid to a named customer (Priority: P1)

The owner picks a customer for the sale (searching by name or phone, or adding a new one on the
spot) and enters how much was paid now: all of it, part of it, or nothing. What is not paid is
added to the customer's balance.

**Why this priority**: Selling on credit ("شكك") to regular customers is central to Egyptian
neighbourhood shops, and tracking who owes what is the main pain the app removes.

**Independent Test**: Sell 100.00 to a customer, paying 40.00 now, then open the customer and
confirm the balance is 60.00 and the statement lists the sale and the payment.

**Acceptance Scenarios**:

1. **Given** a sale of 100.00 with customer "أحمد", **When** the owner sets paid now to 40.00 and
   saves, **Then** the invoice shows paid 40.00 and remaining 60.00, and Ahmed's balance rises by
   60.00.
2. **Given** a sale with no customer, **When** the owner sets paid now below the total, **Then**
   saving is blocked with a message that credit needs a named customer.
3. **Given** a cash sale (paid in full) with a named customer, **When** it is saved, **Then** the
   customer's statement shows the sale and the matching payment, and the balance is unchanged.
4. **Given** the customer picker, **When** the owner types a name that does not exist, **Then**
   they can add that customer (name, optional phone) without leaving the sale.
5. **Given** paid now, **When** it is more than the total, **Then** it is rejected.

---

### User Story 3 - See past invoices (Priority: P1)

The owner opens the list of invoices, newest first, and opens one to see its number, date and
time, customer, lines, discounts, total, amount paid, remaining amount and payment method.

**Why this priority**: The owner must be able to check what was sold and answer a customer's
question about a past sale.

**Independent Test**: Save three sales, open the invoice list, and confirm all three appear newest
first with number, time, customer and total; open one and confirm every line.

**Acceptance Scenarios**:

1. **Given** saved invoices, **When** the owner opens the list, **Then** each row shows the
   number (for example S-000012), date and time, customer or "walk-in customer", total, and a mark
   for credit or partly paid.
2. **Given** the list, **When** the owner searches by invoice number or customer name, **Then**
   only matching invoices are shown.
3. **Given** an invoice, **When** the owner opens it, **Then** each line shows the product name
   as it was at the time of sale, quantity with unit, unit price, line discount and line total,
   even if the product was later renamed or archived.
4. **Given** an invoice, **Then** it is titled as a sales invoice and is never called a tax invoice
   or tax receipt.

---

### User Story 4 - Keep customers and their accounts (Priority: P2)

The owner keeps a list of customers with name, phone, address and note. Each customer shows their
balance (what they owe the shop, or the shop owes them). A customer who already owed money before
the app was used can be given an opening balance. The owner opens a customer's statement to see
every sale, payment and balance change, with a running balance.

**Why this priority**: Needed to manage credit, but sales already work without it for walk-ins.

**Independent Test**: Add a customer with an opening balance of 50.00, sell them 30.00 on credit,
and confirm the list shows 80.00 and the statement shows both rows with the running balance.

**Acceptance Scenarios**:

1. **Given** the customer list, **When** the owner adds "محمد" with phone 01012345678, **Then** he
   appears in the list with balance 0.00.
2. **Given** a new customer, **When** the owner enters an opening balance of 50.00 owed by the
   customer (or 20.00 the shop owes them), **Then** the balance shows 50.00 owed (or 20.00 in the
   customer's favour) and the statement starts with an opening balance row.
3. **Given** customers, **When** the owner searches by part of the name (with the same Arabic
   spelling rules as products) or part of the phone number, **Then** matching customers are listed.
4. **Given** the list, **When** the owner filters to customers who owe money, **Then** only those
   are listed, highest balance first.
5. **Given** a customer's statement, **Then** rows are newest first with date and time, type
   (opening balance, sale with its invoice number, payment with its receipt number), amount and
   running balance; tapping a sale row opens the invoice.
6. **Given** a customer, **When** the owner edits the name or phone, **Then** old invoices still
   open and the statement is unchanged.
7. **Given** a customer, **When** the owner archives them, **Then** they leave the list and the
   customer picker but their invoices and statement stay; they can be restored. A customer with a
   non-zero balance can be archived only after a confirmation that shows the balance.

---

### User Story 5 - Receive a payment from a customer (Priority: P2)

A customer comes to pay part or all of what they owe. The owner opens the customer, records the
amount, the method (cash, wallet, InstaPay) and an optional note. The payment gets a receipt
number and lowers the balance.

**Why this priority**: Without it, credit balances only grow and the ledger is useless.

**Independent Test**: A customer owing 60.00 pays 25.00 by wallet; the balance becomes 35.00 and
the statement shows a payment with receipt number 1 and the method.

**Acceptance Scenarios**:

1. **Given** a customer owing 60.00, **When** the owner records 25.00 by wallet, **Then** the
   balance is 35.00 and the statement shows the payment with its receipt number (for example
   RC-000001) and method.
2. **Given** the payment form, **When** the amount is empty, zero, or has more than two decimals,
   **Then** saving is blocked with a message.
3. **Given** a customer owing 60.00, **When** the owner records 80.00, **Then** a notice says the
   customer will have 20.00 in credit, and confirming saves it.

---

### User Story 6 - Void a wrong invoice or cancel a wrong payment (Priority: P2)

The owner saved an invoice by mistake (wrong customer, wrong products) or recorded a payment that
did not happen. They open it, choose Void (or Cancel for a payment), write the reason, and
confirm. The document stays in the lists, marked voided or cancelled, and its effects are undone.

**Why this priority**: Mistakes at the counter are common, and without a correction path the
stock and balances would stay wrong until returns arrive in a later feature.

**Independent Test**: Sell 3 pieces on credit to a customer for 30.00, void the invoice with a
reason, and confirm stock is back, the balance is back, and the invoice shows as voided with its
reason.

**Acceptance Scenarios**:

1. **Given** a saved invoice, **When** the owner voids it with the reason "خطأ في العميل",
   **Then** it shows as voided with the reason and time, each product's stock goes back up by the
   quantity sold, and the invoice stays in the list with a voided mark.
2. **Given** a voided credit invoice of 100.00 with 40.00 paid at sale, **Then** the customer's
   statement shows the reversal of the sale and of the 40.00 payment, and the balance is as before
   the sale.
3. **Given** the void form, **When** the reason is empty or only spaces, **Then** voiding is
   blocked.
4. **Given** a voided invoice, **Then** it cannot be voided again, and it does not count in the
   unpaid filter.
5. **Given** a standalone payment of 25.00, **When** the owner cancels it with a reason, **Then**
   the statement shows a reversal row of +25.00, the balance goes back up by 25.00, and the
   payment shows as cancelled; it cannot be cancelled twice.
6. **Given** a payment made at the time of a sale, **Then** it cannot be cancelled on its own;
   only voiding the invoice undoes it.

### Edge Cases

- The same product added twice by search: the existing line's quantity goes up; a product can be
  on the invoice only once.
- A unit price of 0 (a free item): allowed.
- A product archived while it is on an unsaved sale: saving is blocked and names the product.
- A customer archived while picked on an unsaved sale: saving is blocked with a message.
- Very large amounts: unit price up to 10,000,000 EGP and quantity up to 1,000,000 units, as in
  002; totals can be larger and are still exact.
- Rounding: a line total is quantity × price rounded to the nearest piaster, half up; an invoice
  discount is spread over the lines so the line shares add up exactly to the discount.
- Selling below cost: allowed, without a warning.
- The app is closed in the middle of saving a sale: the invoice, its lines, the stock changes and
  the customer's account rows are all saved, or none are. No invoice number is skipped or used
  twice.
- Two sales saved in quick succession get consecutive numbers.
- A sale with a named customer whose balance is already in their favour: allowed; the credit is
  not applied automatically to the sale.
- Long product or customer names at 200% text size: they wrap and stay readable.
- Voiding an invoice whose product was archived since: allowed; the stock still comes back.
- Voiding an invoice whose customer was archived since: allowed; their account is still restored.
- The returned stock blends into the product's average cost at the cost recorded on the sale
  (decision Q9).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Sales section MUST offer New sale and the invoice list. The Customers part of
  the Parties section MUST offer the customer list. The five sections stay as they are.
- **FR-002**: A sale MUST have at least one line. Each line has one active product, a quantity
  (whole for piece products, up to three decimals otherwise, above 0, at most 1,000,000 units),
  a unit price (prefilled from the product, editable, 0 to 10,000,000 EGP, at most two decimals),
  and an optional line discount (0 up to the line's amount before discount).
- **FR-003**: Products MUST be added by search (part of name, code or barcode, same rules as the
  002 product search) or by an exact barcode. Adding a product already on the sale MUST raise its
  quantity instead of adding a line.
- **FR-004**: Line total = quantity × unit price rounded half up to the piaster, minus the line
  discount. Subtotal = sum of line totals. An optional invoice discount (0 up to the subtotal)
  gives total = subtotal − invoice discount. The invoice discount MUST be shared over the lines so
  the shares add up to it exactly.
- **FR-005**: Paid now MUST be between 0 and the total, and defaults to the total. If it is below
  the total, a named, active customer is required. The payment method (cash, mobile wallet,
  InstaPay) applies to the amount paid now; it defaults to cash.
- **FR-006**: When any line needs more than the product's stock on hand (lines for the same product
  counted together), saving MUST first warn and name each short product with its stock; the owner
  may confirm and save, and stock then goes below zero.
- **FR-007**: Saving a sale MUST, all together or not at all: give the invoice the next number in
  an unbroken sequence; store the invoice and its lines with each product's name, unit and current
  average cost as they are at that moment; lower each product's stock by its quantity; and, with a
  named customer, add the total to the customer's account and the amount paid now as a payment.
- **FR-008**: Saved invoices MUST NOT be edited or deleted. Their numbers are never reused.
- **FR-008a**: Users MUST be able to void a saved invoice once, with a reason (1–200 characters
  after trimming). Voiding MUST, all together or not at all: mark the invoice voided with the
  reason and time; put each line's quantity back into stock at the cost recorded on that line,
  updating the product's average cost as for any stock coming in; and, with a named customer,
  add rows that reverse the sale and the amount paid at sale, so the balance returns to what it
  was before the sale. Voided invoices stay listed with a voided mark and reason.
- **FR-009**: The invoice list MUST show invoices newest first with number, date and time,
  customer (or walk-in), total, and a mark when not fully paid. It MUST be searchable by number and
  customer name, and filterable to credit or partly paid invoices.
- **FR-010**: The invoice view MUST show number, date and time, customer, each line (name, quantity
  with unit, unit price, line discount, line total), subtotal, invoice discount, total, paid now,
  remaining and payment method. It MUST be titled as a sales invoice and never as a tax document.
- **FR-011**: Users MUST be able to add and edit customers: name (required, 1–100 characters after
  trimming), phone (optional, the same rule as the shop phone: 7–15 digits with an optional leading +,
  spaces and dashes ignored), address and
  note (optional, up to 200 characters). Two customers MAY share a name; saving the second shows a
  notice.
- **FR-012**: A new customer MAY get an opening balance, owed by the customer or in their favour,
  0 to 10,000,000 EGP, at most two decimals. It is recorded once, as the first statement row, and
  cannot be edited afterwards.
- **FR-013**: A customer's balance MUST always equal the sum of their account rows; it is never
  typed in directly. Positive means the customer owes the shop.
- **FR-014**: The customer list MUST show name, phone and balance, sorted by name (same Arabic
  order as products), searchable by name (same spelling rules as products) and by phone, and
  filterable to customers who owe money (highest balance first).
- **FR-015**: The customer statement MUST list every account row newest first with date and time,
  type, document number where there is one, signed amount and running balance; a sale row opens its
  invoice. The customer page also lists the customer's invoices.
- **FR-016**: Users MUST be able to record a payment from a customer: amount (above 0, up to
  10,000,000 EGP, at most two decimals), method, optional note. It gets the next receipt number
  in its own unbroken sequence. A payment larger than the balance MUST show a notice of the
  resulting credit before saving.
- **FR-016a**: Users MUST be able to cancel a standalone payment once, with a reason (1–200
  characters after trimming), by adding a reversing row of the same amount; the payment then shows
  as cancelled. A payment made with a sale cannot be cancelled on its own.
- **FR-017**: Users MUST be able to archive and restore customers. Archived customers MUST NOT
  appear in the list, search or customer picker, and are listed in an archived customers view.
  Archiving a customer with a non-zero balance requires a confirmation that shows it. Nothing is
  ever deleted.
- **FR-018**: Document numbers MUST be shown with a prefix in the user interface only: S- for
  sales invoices and RC- for receipts, padded to six digits (for example S-000012).
- **FR-019**: All new screens and messages MUST be available in Arabic (right-to-left) and English,
  follow the chosen digit style, accept Arabic and Latin digits in every number field, stay fully
  usable at 200% text size, and give spoken labels to every interactive element, as in 001 and
  002. Money is shown with "ج.م" in Arabic and "EGP" in English; quantities with their unit.

### Key Entities *(include if feature involves data)*

- **Sales invoice**: a numbered, permanent record of one sale: date and time, optional customer,
  subtotal, invoice discount, total, amount paid now, payment method, optional note.
- **Invoice line**: one product on an invoice: the product's name and unit as they were, quantity,
  unit price, line discount, line total, its share of the invoice discount, and the product's
  average cost at that moment (for profit later).
- **Customer**: a person or business who buys from the shop: name, phone, address, note. Active or
  archived.
- **Account row**: one permanent entry in a customer's account: opening balance, sale, or payment
  received (with receipt number and method), with a signed amount and time. The balance is the sum
  of the rows. Reversal rows (for a voided invoice or a cancelled payment) undo an earlier row and
  point to it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An owner rings up a 3-line cash sale, starting from the Sales section, in under 30
  seconds.
- **SC-002**: With 2,000 products, results for a product search on the sale screen appear within
  1 second of typing, on a mid-range phone.
- **SC-003**: For every customer, the shown balance equals the sum of their statement rows, in
  100% of automated checks after random sequences of sales and payments.
- **SC-004**: For every invoice, the total equals the lines minus the discounts to the piaster, and
  stock after the sale equals stock before minus the quantities sold, in 100% of automated checks.
- **SC-005**: Invoice and receipt numbers have no gaps and no repeats, including after the app is
  closed while saving.
- **SC-006**: Every new screen is fully usable in Arabic RTL and English LTR, at 100% and 200% text
  size, with no cut-off text or controls.
- **SC-007**: Every invoice, customer and payment is still there after closing and reopening the
  app.

## Assumptions

- The sale date is always the moment of saving; back-dated sales are not supported.
- Discounts are amounts in EGP, not percentages.
- The stock policy is "warn" (decision in the M0 report); a "block" setting is not offered here.
- A cash sale to a named customer writes both a sale row and a payment row so it appears on the
  statement (decision Q17).
- Card payments are not offered in the user interface (decision Q23: cash, wallet, InstaPay).
- A customer's credit in their favour is not applied to new sales automatically.
- There is no credit limit (decision Q12).
- Held or parked sales are not supported; one sale is open at a time.
- Partial corrections (returning some lines) come with returns in a later feature; voiding is
  whole-invoice only.
- Returns come in a later feature. Invoice sharing (image and text, decision Q6) comes in a later
  feature.
- Customers live under the Parties section, which suppliers will join in a later feature.
- No schema change is needed: everything fits the existing v1 tables.
