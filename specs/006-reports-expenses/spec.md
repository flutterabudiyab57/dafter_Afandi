# Feature Specification: Reports, Home Dashboard and Expenses

**Feature Branch**: `006-reports-expenses`

**Created**: 2026-10-26

**Status**: Draft

**Input**: User description: "006 reports, home dashboard, expenses, and in-app low-stock alerts.
Reports: profit report for a period (today, this week, this month, custom range) using netProfit =
grossProfit - inventoryLosses - expenses (inventory losses as a separate line), sales totals and cash
received by payment method, top-selling products, customers who owe the shop and suppliers the shop
owes. Home dashboard: today's sales, cash collected today, a "running low" card with the count of
products at or below their low-stock threshold that opens the low-stock list, and top customers who
owe. Expenses: record shop expenses (rent, electricity, salaries, other) with amount in piasters,
category, date, note and payment method; list, archive (no hard delete); expenses feed the profit
report. In-app low-stock alert: after a sale drops a product to or below its threshold, show a short
message naming it. No push notifications, no new packages. Offline only, Arabic-first RTL with
English, EGP only, no tax."

Added by the owner on 2026-10-26: "When wallet or InstaPay is picked, show an optional field for the
account number. Also let the owner take one payment in two methods, for example part cash and part
wallet."

## Clarifications

### Session 2026-10-26

- Q: Do stock gains from a count reduce inventory losses, get ignored, or get their own line? →
  A: They reduce inventory losses. The line shows the net, with the breakdown by reason.
- Q: Does an expense record how it was paid? → A: Yes. This amends decision Q23 and changes the
  schema (v1 to v2).
- Owner request: wallet and InstaPay payments take an optional account number, and one payment can
  be split across methods (User Story 6).
- Q: Whose account number is it? → A: The owner's own account the money arrived in or left from,
  so they can check who sent what and when, or what they sent to whom.

The owner can see how the shop is doing without adding anything up by hand. Opening the app shows
today at a glance: what was sold, what money came in, what is running out, and who owes the most.
The Reports tab shows the real profit for a period, after the cost of goods, damaged or lost stock
and the shop's running costs. The owner records rent, electricity, salaries and other costs as
expenses so the profit is honest. When a sale takes a product down to its low-stock level, the app
says so on the spot.

Built on 001–005. The expenses and expense categories tables already exist in the schema (001) and
are used here for the first time. Every number in this feature is derived from records that are
already saved; nothing is cached. This feature changes the schema (v1 to v2): expenses get a
payment method, and every payment can be split across methods with an optional account number.

Out of scope:
- push or scheduled notifications (installments and due-date reminders come in a later feature);
- sale returns and purchase returns screens (returns that exist are counted, but no screen to make
  them is added here);
- exporting, printing or sharing a report (PDF is not approved);
- charts beyond simple bars or totals;
- budgets, recurring expenses and expense attachments or photos;
- a "money paid out" report by payment method (expenses and supplier payments record their method
  now, so the report can be added later without changing the data);
- searching by account number, and checking that an account number is real;
- backup and restore (007).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - See today at a glance on the home screen (Priority: P1)

The owner opens the app in the morning or during the day. The home screen shows today's sales total
and how many sales there were, the money collected today, a "running low" card with the number of
products at or below their low-stock level, and the customers who owe the shop the most. Tapping a
card opens the matching list.

**Why this priority**: The home screen is the first thing the owner sees every time. Today it only
has two shortcuts, so it gives no value on its own.

**Independent Test**: Seed products, sales, customer payments and low-stock products, open the app,
and check each card's number and where each card leads.

**Acceptance Scenarios**:

1. **Given** three sales today totalling 450 EGP and one voided sale of 100 EGP, **When** the owner
   opens the home screen, **Then** today's sales show 450 EGP from 3 sales.
2. **Given** a cash sale of 200 EGP today and a 300 EGP payment received from a customer today,
   **When** the owner opens the home screen, **Then** money collected today shows 500 EGP.
3. **Given** two products at or below their low-stock level and one product below zero, **When**
   the owner opens the home screen, **Then** the running-low card shows 3 and tapping it opens the
   product list filtered to running-low products.
4. **Given** five customers who owe the shop, **When** the owner opens the home screen, **Then** the
   three who owe the most are shown with their balances, largest first, and tapping one opens that
   customer.
5. **Given** a new shop with no records, **When** the owner opens the home screen, **Then** each card
   shows zero or an empty message and still opens its list.
6. **Given** the home screen is open, **When** a sale is saved, **Then** the cards show the new
   numbers on return without restarting the app.

---

### User Story 2 - Know the real profit for a period (Priority: P1)

The owner opens Reports and picks today, this week, this month or a custom date range. The profit
report shows net sales, cost of goods sold, gross profit, inventory losses on a separate line,
expenses, and net profit. Each line can be explained by the records behind it.

**Why this priority**: Profit is the main question an owner asks of an accounting app. Today the
Reports tab is an empty placeholder.

**Independent Test**: Seed sales with known costs, a voided sale, stock adjustments and expenses
across two periods, and check every line of the report for each period.

**Acceptance Scenarios**:

1. **Given** sales this month of 10,000 EGP with a recorded cost of 7,000 EGP, **When** the owner
   views this month, **Then** net sales show 10,000, cost of goods 7,000 and gross profit 3,000.
2. **Given** that month also has a damage adjustment worth 200 EGP at cost and expenses of 1,500
   EGP, **When** the owner views this month, **Then** inventory losses show 200, expenses 1,500 and
   net profit 1,300.
3. **Given** a sale made last month and voided this month, **When** the owner views each month,
   **Then** the sale is excluded from both, because a voided sale never counts.
4. **Given** a sale return made this month for a sale from last month, **When** the owner views
   this month, **Then** the return reduces this month's net sales and cost of goods, and last month
   is unchanged.
5. **Given** a period with no records, **When** the owner views it, **Then** every line shows zero
   and a short message says there is nothing in this period.
6. **Given** costs higher than sales, **When** the owner views the period, **Then** the net profit
   is shown as a loss, clearly marked, not as a positive number.
7. **Given** a custom range whose end is before its start, **When** the owner tries to apply it,
   **Then** the app refuses and says why.

---

### User Story 3 - Record and review shop expenses (Priority: P1)

The owner records an expense: picks a category (rent, electricity, salaries, other, or one they
added), enters the amount, how it was paid (cash by default), the date (today by default) and an
optional note, and saves. The expense
gets a number (E-1, E-2…) and appears in the expenses list for its period. A wrong expense is
voided with a reason, never deleted or edited.

**Why this priority**: Without expenses the net profit in User Story 2 is wrong.

**Independent Test**: Add expenses in several categories and dates, void one, and check the list,
the totals and the profit report.

**Acceptance Scenarios**:

1. **Given** the expense form, **When** the owner saves 1,500 EGP for rent today paid by wallet,
   **Then** it is saved as the next E- number with its payment method and appears at the top of
   this month's list.
2. **Given** an amount of zero, an empty amount or no category, **When** the owner saves, **Then**
   the app refuses and says which field is wrong.
3. **Given** a saved expense, **When** the owner voids it with a reason, **Then** it stays in the
   list marked voided, with its reason, and no longer counts in totals or the profit report.
4. **Given** a voided expense, **When** the owner opens it, **Then** there is no way to edit or
   void it again.
5. **Given** the expenses list, **When** the owner picks a period and a category, **Then** the list
   and its total show only matching expenses that are not voided in the total.
6. **Given** the category list, **When** the owner adds "Internet", renames it or archives it,
   **Then** new expenses can use it while active, and past expenses keep showing its name after it
   is archived.
7. **Given** a category name that already exists among active categories (ignoring letter case,
   Arabic letter forms and extra spaces), **When** the owner adds it, **Then** the app refuses.

---

### User Story 4 - Told at once when a sale makes stock run low (Priority: P2)

When the owner saves a sale that takes one or more products to or below their low-stock level, or
below zero, the confirmation message names them, for example "Tea is running low (2 left)".

**Why this priority**: It turns the low-stock threshold the owner already sets into a timely
reminder, with no notification permission.

**Independent Test**: Set a threshold on a product, sell enough to cross it, and check the message;
sell a product that stays above its threshold and check that no message appears.

**Acceptance Scenarios**:

1. **Given** tea with 5 left and a low-stock level of 3, **When** a sale of 2 is saved, **Then** the
   message says tea is running low with 3 left.
2. **Given** tea was already running low before the sale, **When** another sale of tea is saved,
   **Then** the message still names it, so the owner is reminded on every sale.
3. **Given** a sale that takes three products low, **When** it is saved, **Then** the message names
   the first two and says "and 1 more", and tapping it opens the running-low list.
4. **Given** a product with no low-stock level that stays at or above zero, **When** a sale is
   saved, **Then** no low-stock message appears for it.

---

### User Story 5 - See who owes and the best-selling products (Priority: P2)

From Reports the owner opens three more views: money collected by payment method for the period,
the top-selling products for the period by quantity and by sales value, and the balances list:
customers who owe the shop and suppliers the shop owes, largest first, with the total of each.

**Why this priority**: These answer the next questions after profit: where the money came from,
what sells, and who has to pay whom.

**Independent Test**: Seed sales in several payment methods, customer payments and supplier
balances, and check each view's rows, order and totals.

**Acceptance Scenarios**:

1. **Given** sales and customer payments in cash, wallet and InstaPay this week, **When** the owner
   views money collected for this week, **Then** each method shows its total and the grand total is
   their sum.
2. **Given** ten products sold this month, **When** the owner views top sellers, **Then** the top
   ten show in order by sales value, and the owner can switch to order by quantity.
3. **Given** customers with positive, zero and credit balances, **When** the owner views who owes,
   **Then** only customers who owe the shop are listed, largest first, with their total.
4. **Given** suppliers the shop owes, **When** the owner views what the shop owes, **Then** they are
   listed largest first with the total, and tapping one opens that supplier.
5. **Given** a sale paid 300 EGP cash and 200 EGP wallet, **When** the owner views money collected,
   **Then** 300 counts under cash and 200 under wallet.

---

### User Story 6 - Record the account number and split a payment (Priority: P2)

Wherever the owner picks how money was paid (a sale, a customer payment, a purchase, a supplier
payment or an expense), picking wallet or InstaPay shows an optional field for the owner's own
account the money arrived in or left from, such as the shop's wallet phone number or InstaPay
address. The field offers the owner's accounts used before, so the number is picked, not retyped.
The owner can also split one payment across methods, for example 300 EGP cash and 200 EGP by
wallet, and each part keeps its own method and account.

**Why this priority**: Customers in Egypt often pay part cash and part by wallet, and an owner with
more than one wallet needs to check later who sent what, when, and to which of their accounts, or
what they sent to whom and from which account. Without
it the money-collected report puts the whole payment under one method.

**Independent Test**: Save a sale, a customer payment, a purchase, a supplier payment and an
expense each split across two methods with an account number, and check the details screens, the
statements and the money-collected report.

**Acceptance Scenarios**:

1. **Given** the payment method is cash, **When** the owner looks at the form, **Then** no account
   number field is shown.
2. **Given** the owner picks wallet or InstaPay, **When** the form updates, **Then** an optional
   account number field appears; saving without it is allowed.
3. **Given** a sale of 500 EGP, **When** the owner splits the payment into 300 cash and 200 wallet
   received on their number 01012345678, **Then** the sale is saved with both parts and its details
   show each part with its method and number.
4. **Given** the owner used wallet 01012345678 before, **When** they pick wallet again, **Then** that
   number is offered and one tap fills it.
5. **Given** split parts that add up to more than the amount being paid, **When** the owner saves,
   **Then** the app refuses and says the parts must add up to the amount.
6. **Given** a split with a part of zero, or the same method twice, **When** the owner saves,
   **Then** the app refuses and says which part is wrong.
7. **Given** sales and payments saved before this feature, **When** the owner opens them, **Then**
   each shows its one method as before, with no account number.
8. **Given** a split sale is voided, **When** the owner views money collected, **Then** none of its
   parts count.

---

### Edge Cases

- A sale is made at 11:58 PM and the owner views "today" just after midnight: the sale counts in
  the day it was saved, by the phone's local date.
- The phone's time zone changes: periods follow the phone's current local calendar; saved times do
  not change.
- A product sold at a price below its cost: gross profit for that line is negative and the total
  reflects it.
- A product whose cost was zero when sold (no purchases or opening cost yet): its cost of goods is
  zero and the report says some products had no cost when sold.
- An archived product or customer still appears in reports for periods where it has records.
- A stock count adjustment that adds stock: it reduces inventory losses (FR-012). If gains are
  larger than losses in a period, the line shows a net gain and net profit goes up.
- A sale on credit with nothing paid now: there is no payment, so no method or split is asked for.
- A sale partly paid at sale time and the rest on credit: only the paid part is split across
  methods; the rest goes on the customer's account as before.
- An account number typed with Arabic digits: it is saved with Latin digits, like other numbers.
- Very large numbers (a year of a busy shop) are summed exactly to the piaster, with no rounding.
- Reports in Arabic and English at 200% text size: every line and number stays readable without
  clipping.
- An expense dated in the future: refused; expenses can be dated today or earlier.

## Requirements *(mandatory)*

### Functional Requirements

**Periods**

- **FR-001**: Reports MUST offer these periods: today, yesterday, this week, this month, last month
  and a custom range of two dates. The week starts on Saturday.
- **FR-002**: A period MUST include every record saved from the start of its first day to the end
  of its last day in the phone's local time.

**Profit report**

- **FR-003**: Net sales MUST be the sum of saved, non-voided sale invoice totals in the period,
  minus the value of sale returns made in the period.
- **FR-004**: Cost of goods sold MUST be the sum of the cost recorded on each sale line at the time
  of sale, minus the cost of returned items in the period. Current product costs MUST NOT be used.
- **FR-005**: Gross profit MUST equal net sales minus cost of goods sold.
- **FR-006**: Inventory losses MUST be shown on their own line, valued at the cost recorded on each
  stock adjustment in the period, grouped by reason (damage, count, other).
- **FR-007**: Expenses MUST be the sum of non-voided expenses dated in the period.
- **FR-008**: Net profit MUST equal gross profit minus inventory losses minus expenses. A negative
  net profit MUST be shown as a loss.
- **FR-009**: Voided sales, voided expenses and voided purchases MUST NOT count in any report.
- **FR-010**: Returns MUST count in the period they are made, not in the period of the original
  sale.
- **FR-011**: Opening stock and purchases MUST NOT count as costs in the profit report; only the
  cost of what was sold counts.
- **FR-012**: A stock adjustment that adds stock (a count found more than recorded) MUST reduce
  inventory losses, valued at its recorded cost. The inventory losses line shows the net of losses
  and gains, and each reason in its breakdown shows its own net. A net gain MUST be shown as a gain,
  and it raises net profit.

**Money collected**

- **FR-013**: Money collected for a period MUST be the amount paid on non-voided sales at the time
  of sale plus payments received from customers, minus refunds paid, grouped by payment method
  (cash, wallet, InstaPay), with a grand total. A split payment MUST count each part under its own
  method.

**Top sellers and balances**

- **FR-014**: Top sellers MUST list up to 10 products for the period by net sales value, with a
  switch to order by quantity sold. Quantities MUST be shown in each product's unit.
- **FR-015**: Who owes MUST list customers whose balance is owed to the shop, largest first, with
  the total; what the shop owes MUST list suppliers the shop owes, largest first, with the total.
  These lists show balances as of now, not for a period.

**Home dashboard**

- **FR-016**: The home screen MUST show today's net sales and the number of non-voided sales today.
- **FR-017**: The home screen MUST show money collected today, as defined in FR-013.
- **FR-018**: The home screen MUST show the number of active products that are below zero or at or
  below their low-stock level, and tapping it MUST open the product list with the running-low
  filter on.
- **FR-019**: The home screen MUST show the three customers who owe the most, with their balances;
  tapping one opens that customer, and a "see all" link opens the who-owes list.
- **FR-020**: The home screen MUST keep the existing shortcuts and add one to record an expense.
- **FR-021**: Every number on the home screen and in reports MUST update when records change,
  without restarting the app.

**Expenses**

- **FR-022**: The owner MUST be able to record an expense with a category, an amount greater than
  zero, how it was paid (cash by default; wallet or InstaPay, split allowed, as in FR-033 to
  FR-039), a date (today by default, never in the future) and an optional note.
- **FR-023**: Each saved expense MUST get the next expense number, shown as E-<number>.
- **FR-024**: A saved expense MUST NOT be edited or deleted. The owner MUST be able to void it once,
  with a required reason; a voided expense stays visible and marked.
- **FR-025**: The expenses list MUST filter by period and category, show the newest first, and show
  the total of non-voided expenses shown.
- **FR-026**: Expense categories MUST start with rent, electricity, salaries and other, in the
  shop's language. The owner MUST be able to add, rename and archive categories; names are unique
  among active categories, compared the same way as product search.
- **FR-027**: An archived category MUST NOT be offered for new expenses and MUST still show on past
  expenses.

**Low-stock alert**

- **FR-028**: After a sale is saved, if any product on it is below zero or at or below its
  low-stock level, the confirmation MUST name up to two of them with their remaining quantity and
  say how many more, and MUST offer to open the running-low list.
- **FR-029**: The low-stock alert MUST appear only inside the app, right after saving. No system
  notification is sent.

**Across the feature**

- **FR-030**: Every amount MUST be exact to the piaster and formatted as the rest of the app, with
  Arabic or Latin digits by the owner's setting.
- **FR-031**: Every new screen MUST work in Arabic (RTL) and English, in light and dark themes, at
  text sizes up to 200%, with the loading, empty and failed-to-load states from 005.
- **FR-032**: Recording or voiding an expense MUST save completely or not at all.

**Account number and split payments**

- **FR-033**: Every place that asks how money was paid MUST work the same way: sale (the amount
  paid at sale time), customer payment, purchase (the amount paid), supplier payment and expense.
  Refunds on returns keep one method, because returns have no screen yet.
- **FR-034**: When a part's method is wallet or InstaPay, the form MUST show an optional field for
  the owner's own account number. Cash MUST NOT show the field. The field MUST offer the account
  numbers already used with that method, most recent first, and still accept a new one.
- **FR-035**: An account number MUST accept up to 40 characters of digits, Latin letters and the
  symbols @ . _ - (so an InstaPay address fits). Arabic digits MUST be saved as Latin digits.
  Spaces at the ends MUST be removed, and an empty field saves no number.
- **FR-036**: The owner MUST be able to split one payment into up to three parts, one per method
  (cash, wallet, InstaPay). Each part MUST be greater than zero, and no method MUST appear twice.
- **FR-037**: The parts MUST add up exactly to the amount being paid. If they do not, the app MUST
  refuse to save and show the difference.
- **FR-038**: A payment that is not split MUST stay as fast to enter as today: one method, cash by
  default, with the amount filled in.
- **FR-039**: Details screens, receipts on screen and customer and supplier statements MUST show
  each part with its method and, when present, its account number.
- **FR-040**: A payment and its parts MUST save together, completely or not at all, and MUST NOT
  be edited afterwards; voiding the record voids all its parts.
- **FR-041**: Every sale, purchase and payment saved before this feature MUST read as one part with
  its existing method and no account number, with no change to any amount or balance.

### Key Entities

- **Expense**: money the shop spent that is not stock. Number, category, amount, how it was paid,
  date spent, optional note, void time and reason. Already in the schema; gains its payment method
  here. Immutable except for its void.
- **Payment part**: one piece of money paid in one method: the amount, the method (cash, wallet,
  InstaPay) and an optional account number. A sale, purchase, customer payment, supplier payment or
  expense has one to three parts that add up to the amount paid. Immutable.
- **Expense category**: a named group of expenses (rent, electricity…). Can be added, renamed and
  archived; never deleted. Already in the schema.
- **Report period**: a start and end date picked by the owner. Not saved.
- **Profit summary**: net sales, cost of goods sold, gross profit, inventory losses by reason,
  expenses, net profit for a period. Always derived from saved records, never stored.
- **Money collected summary**: totals by payment method for a period. Derived, never stored.
- **Top seller**: product name, quantity sold and net sales value for a period. Derived.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The owner can see today's sales, money collected, running-low count and top debtors
  within 2 seconds of opening the app, with no taps.
- **SC-002**: The owner can see net profit for this month in 2 taps or fewer from the home screen.
- **SC-003**: The owner can record an expense in under 30 seconds.
- **SC-004**: For a seeded set of records, every report line matches a hand calculation exactly, to
  the piaster, in 100% of test cases.
- **SC-005**: A year of a busy shop (about 20,000 sales and 2,000 expenses) shows any report within
  2 seconds on a mid-range phone.
- **SC-006**: Every sale that crosses a low-stock level shows the alert; no sale that does not
  cross it shows one.
- **SC-007**: Every new screen passes the existing checks for RTL, 200% text, both themes and
  spoken labels.
- **SC-008**: A payment that is not split takes no more taps than before this feature.
- **SC-009**: After the upgrade, every balance, statement and invoice total from before it is
  unchanged, in 100% of test cases.

## Assumptions

- Expenses are voided, not archived, because saved financial records are immutable (constitution
  III). The expenses table already supports voiding.
- The four default expense categories are created once, in the shop's language when the expenses
  feature is first used; they behave like any other category after that.
- The week starts on Saturday, as is usual in Egypt.
- "Money collected" counts money that came in only; supplier payments and expenses are money out
  and are not part of it in this feature.
- Customer balances and supplier balances already exist from 003 and 004 and are reused as they are.
- The running-low rule is the one the product list already uses: below zero, or at or below the
  product's low-stock level when one is set.
- Sale returns have no screen yet; the reports count any that exist so they stay correct when the
  returns screen is added.
- No new package is needed. If the custom date range needs a date picker, the one built into the
  UI toolkit is used.
- The schema moves from v1 to v2 with a step-by-step upgrade of the owner's existing data. Decision
  Q23 (payment method on sales, purchases, returns and payment rows, not expenses) is amended by the
  owner on 2026-10-26: expenses get a payment method, and payments can be split with an account
  number.
- The account number is the owner's own wallet number or InstaPay address that the money arrived
  in or left from (owner's answer, 2026-10-26). Who paid or was paid is already on the record (the
  customer, supplier or expense category). It is not a secret and is stored like a note.
- Card stays in the data as before but is not offered in the app, as decided in Q23.
