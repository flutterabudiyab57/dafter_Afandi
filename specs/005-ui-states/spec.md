# Feature Specification: UI States and Visual Polish

**Feature Branch**: `005-ui-states`

**Created**: 2026-10-21

**Status**: Draft

**Input**: User description: "Feature 005-ui-states: a professional UI states layer (success, error,
warning, info, empty, loading, saving, voided/archived) across every screen, implementing the design
handoff in docs/design/DESIGN-HANDOFF.md (design system
https://claude.ai/artifact/4CMWRYbhV2E9j14EiFToas). Use the handoff as the source of truth for scope,
shared widgets, screen-by-screen states, illustrations, new AppColors tones, ARB keys and phases.
Owner decisions listed in the handoff must be marked as clarifications, not assumed."

Every screen tells the owner clearly and the same way what just happened and what to do next. That
covers a save that worked, a save that failed, something that needs attention, a list with nothing
in it yet, a search with no results, data still loading, a save in progress, and a voided or
archived record. Each state gets one look, one wording style and, where it helps, an original
illustration, in light and dark themes, Arabic and English, at any text size.

Built on 001–004. The feature changes no data, no schema and no financial behavior, and adds no
package. The exact colors, sizes, illustration files, shared building blocks and per-screen state
table are in `docs/design/DESIGN-HANDOFF.md`. This spec states what the owner must see.

Out of scope:
- new screens or flows, including a full-screen success view after a sale;
- animations beyond the loading placeholder;
- changes to the app icon or splash;
- any change to wording that already exists, except where a key is reused.

## Clarifications

### Session 2026-10-21

- Q: Should 005 start now or after 004 is finished? → A: After 004 is finished (its phases 5–7).
  005 then covers every screen at once, including new purchase, purchase list, payments and voids.
- Q: How is the sale-saved moment shown? → A: As today. A short bottom message ("تم حفظ الفاتورة
  ١٢٤.") is followed by the invoice. No full-screen success view is added for it.
- Q: Does the owner approve the asset registration, the twelve new color tones and the 19 new texts
  as written in handoff sections 3, 4 and 7? → A: Yes, all three as written.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Know at once whether an action worked (Priority: P1)

The owner saves a product, a sale, a payment or a stock adjustment, archives or restores a record,
or voids an invoice. Each time a short message at the bottom says what happened, in a success tone
with an icon. Where the action can be undone (archive), the message offers "تراجع". When a save
fails, the screen keeps everything the owner typed and shows an error message with an icon. The
message says what went wrong and, where possible, what to do.

**Why this priority**: In a shop the owner looks away from the phone constantly. A clear "it is
saved" or "it was not saved" is the difference between trusting the app and keeping the paper
notebook.

**Independent Test**: Archive a product and confirm a success message with "تراجع" appears, and that
tapping it brings the product back. Then make a save fail and confirm an error message appears and
the form keeps its values.

**Acceptance Scenarios**:

1. **Given** the product list, **When** the owner archives "شاي", **Then** a success message names
   the action and offers "تراجع" for at least 10 seconds. Tapping it restores "شاي" to the list.
2. **Given** a new sale, **When** it is saved, **Then** the owner sees the confirmation that invoice
   N was saved as a short success message at the bottom, followed by the invoice, as today. No
   full-screen success view is shown.
3. **Given** any form, **When** saving fails, **Then** an error banner with an icon appears at the
   top of the form, the typed values stay, and the save button can be pressed again.
4. **Given** a form being saved, **Then** its save button shows a progress mark and the word "جارٍ
   الحفظ…" and cannot be pressed twice. When saving ends the button returns to normal.
5. **Given** an invoice, **When** the owner chooses to void it, **Then** a confirmation dialog in an
   error tone explains the effect and puts the destructive choice last. After voiding, a message
   confirms it and the invoice shows a "ملغاة" banner in the voided tone.

---

### User Story 2 - Empty, no-result and loading screens that guide the owner (Priority: P1)

On first use every list is empty: products, sales, customers, suppliers, purchases, categories,
reports and archives. Instead of a blank area, each shows an illustration that fits the topic, a
title, one helpful sentence and, where useful, the button that fills it, such as "إضافة منتج". A
search or filter that matches nothing shows a "no results" illustration and a "مسح البحث" action.
While a list is loading, placeholder rows of the real row height appear. They appear only if
loading takes longer than a moment, so a fast list never flickers.

**Why this priority**: A new owner's first minutes decide whether they keep using the app. Empty
screens are what they see first.

**Independent Test**: On a fresh install open each list and confirm its own illustration, title and
action. Then search products for "zzz" and confirm the no-results state and that "مسح البحث" brings
the full list back.

**Acceptance Scenarios**:

1. **Given** no products, **When** the owner opens Products, **Then** the empty-products
   illustration, the title, a sentence and "إضافة منتج" are shown. The action opens the product form.
2. **Given** products exist, **When** a search or filter matches none, **Then** the no-results
   state is shown with a "مسح البحث" action that clears the search and filter.
3. **Given** no customers, suppliers, purchases, sales, reports data or archived records, **When**
   the owner opens that list, **Then** each shows its own illustration and wording, never another
   list's.
4. **Given** a list that loads in under 300 ms, **Then** no loading placeholder is shown. **Given**
   one that takes longer, **Then** placeholder rows are shown until the data arrives.
5. **Given** the device's "remove animations" setting, **Then** the loading placeholders do not
   shimmer.

---

### User Story 3 - Warnings and marks that are readable without color (Priority: P1)

Things that need attention but lose nothing are shown in a warning tone with an icon and words.
Examples: low stock on the home screen, a credit sale with no customer, a paid amount larger than
the total, unsaved changes. Records carry small labeled marks for low stock, below zero, owes
(عليه), credit (له), voided and archived. Every state is told by icon and word as well as color.

**Why this priority**: Color alone fails in sunlight, for color-blind owners and in dark mode. A
debt or a below-zero stock mark that is missed costs money.

**Independent Test**: Make one product low and one below zero, then confirm the product list shows
two different labeled marks and the home screen shows a low-stock warning with "عرض الكل".

**Acceptance Scenarios**:

1. **Given** products below their low-stock level, **When** the owner opens Home, **Then** a warning
   banner states how many and offers "عرض الكل", which opens the filtered product list.
2. **Given** a product with stock below zero, **Then** its row shows a below-zero mark in the error
   tone with a word, distinct from the low-stock mark.
3. **Given** a new sale on credit with no customer, **When** the owner tries to save, **Then** a
   warning banner at the top says a customer is needed and offers "اختيار". The related field also
   shows the error.
4. **Given** a form with unsaved changes, **When** the owner goes back, **Then** a dialog asks
   "تجاهل التغييرات؟" with "متابعة التعديل" and "تجاهل". Only "تجاهل" leaves.
5. **Given** customers and suppliers with balances, **Then** amounts owed and amounts in credit carry
   distinct marks with words in both themes.

---

### User Story 4 - Whole-app moments look finished (Priority: P2)

The welcome screen opens with the app's welcome illustration. App start shows the logo and a
progress bar with "جارٍ فتح بياناتك…". If the data cannot be opened, a full-screen error view
explains it calmly. When the app version is too old for the data, a full-screen view says an update
is needed. The data-safety screen explains with an illustration and an info banner that data stays
on the phone. On iOS it also shows a warning banner that backup there is manual.

**Why this priority**: These screens are rare but are exactly when the owner is worried about their
data.

**Independent Test**: Force the startup error and the update-required condition in a test build.
Confirm each shows its illustration, title, explanation and action in both languages and themes.

**Acceptance Scenarios**:

1. **Given** the database cannot be opened at start, **Then** a full-screen view shows the
   data-error illustration, the existing explanation and its action, with nothing cut off at 200%
   text size.
2. **Given** data from a newer app version, **Then** a full-screen view shows the update illustration
   with the existing title and explanation.
3. **Given** the data-safety screen on iOS, **Then** an info banner and a warning banner are shown.
   On Android only the info banner is shown.

---

### User Story 5 - One consistent look in both themes (Priority: P2)

Buttons, fields, dialogs, bottom messages, chips, cards, the top bar and the bottom navigation share
one style everywhere: rounded buttons at least 48 dp tall, clear field focus and error outlines,
and rounded dialogs and cards. Light and dark themes both meet contrast rules for every text and
icon pair.

**Why this priority**: The owner asked for a professional look. Consistency is most of what reads
as professional.

**Independent Test**: Open every screen in light and dark theme at text scale 2.0 in Arabic and
English, and confirm there is no overflow, no unreadable pair and no off-style control.

**Acceptance Scenarios**:

1. **Given** any screen, **Then** every button is at least 48 dp tall and every text and icon pair
   meets 4.5:1 contrast (3:1 for large text and icons) in both themes.
2. **Given** a theme switch, **Then** illustrations switch to their matching light or dark version.
3. **Given** a screen reader, **Then** banners and bottom messages are announced when they appear,
   field errors are read with their field, and illustrations are skipped.

### Edge Cases

- **Several messages at once:** two actions in quick succession show the newest bottom message and
  do not stack them.
- **Undo after the screen is left:** "تراجع" still restores the record, or the message is dismissed
  with the screen; it never acts on the wrong record.
- **Very long product or customer names:** names inside messages and banners wrap and are never cut
  mid-word into an unreadable state.
- **Text scale 200%:** banners, dialogs, empty states and full-screen views scroll rather than
  overflow.
- **A list that becomes empty while open:** after the last item is archived, the list switches to
  its empty state at once.
- **Loading that fails:** the list shows an error state with "إعادة المحاولة" instead of loading
  forever.
- **A missing illustration file:** the empty or result state still shows its title, text and
  action, with no crash.
- **Unsaved-changes check:**
  - a form that was opened and not changed leaves without a question;
  - the new-purchase screen keeps its existing discard prompt (from 004) and only adopts the shared
    look.

## Requirements *(mandatory)*

### Functional Requirements

**Feedback tones**

- **FR-001**: The app MUST present four feedback tones, success, warning, error and info, each with
  its own color pair, filled icon and wording, in both themes.
- **FR-002**: Every state MUST be conveyed by an icon and words as well as color.
- **FR-003**: Success results of save, archive, restore, payment, adjustment and void MUST be
  confirmed with a short bottom message. The message lasts about 4 seconds, or about 10 seconds when
  it offers an action, and a newer message replaces an older one.
- **FR-004**: Archive actions MUST offer "تراجع" in their confirmation message, and undo MUST
  restore exactly the archived record.
- **FR-005**: A failed save MUST keep the user's input and show an error banner at the top of the
  form. Field-level problems MUST show under their field and be read with it by screen readers.
- **FR-006**: Conditions that block saving but lose nothing MUST be shown as a warning banner with
  an action where one exists. Examples: credit with no customer, paid amount above total.
- **FR-007**: Destructive confirmations (void, discard changes) MUST use one dialog style with the
  destructive choice last. The void dialog MUST keep its reason field.

**Empty, no-result and loading states**

- **FR-008**: Each list MUST show its own empty state: illustration, title, sentence, and an
  optional action. This covers products, categories, sales, customers, suppliers, purchases,
  reports, and archived products, customers and suppliers.
- **FR-009**: A search or filter with no matches MUST show a no-results state with an action that
  clears it.
- **FR-010**: Lists and summary cards MUST show loading placeholders only when loading exceeds
  300 ms. The placeholders MUST NOT animate when the device asks for reduced motion.
- **FR-011**: A list whose loading fails MUST show an error state with "إعادة المحاولة".
- **FR-012**: Every save button MUST show progress and "جارٍ الحفظ…" while saving and MUST ignore
  further taps until saving ends.
- **FR-013**: Forms with unsaved changes MUST ask before discarding them. Unchanged forms MUST NOT
  ask.

**Marks and whole-app moments**

- **FR-014**: Record rows MUST use one labeled-mark style for each status: low stock, below zero,
  owes, credit, voided, archived and paid. Existing marks MUST move to this style.
- **FR-015**: Start-up, startup error, update required, welcome and data safety MUST show the states
  described in User Story 4.

**Illustrations**

- **FR-016**: The app MUST ship the 19 original illustrations from `docs/design/assets/illustrations`
  in light and dark versions at 1x, 2x and 3x. The illustration MUST follow the active theme and be
  hidden from screen readers.
- **FR-017**: Illustrations MUST be shown from the bitmap exports.
- **FR-018**: The following MUST match the handoff exactly. The owner approved all three as written
  in handoff sections 3, 4 and 7.
  - The two illustration folders are registered as app assets.
  - The twelve new success, warning and info color values are used.
  - The 19 new texts are added in Arabic and English.

**Consistency and quality**

- **FR-019**: Buttons, fields, dialogs, bottom messages, chips, cards, the top bar and navigation MUST
  share one style set once for the whole app (handoff section 3.3). Screens MUST NOT style these
  one by one.
- **FR-020**: All new user-visible text MUST exist in both Arabic and English. Arabic MUST be MSA.
  Existing keys MUST be reused where one fits.
- **FR-021**: Every text and icon pair in both themes MUST meet WCAG AA. This MUST be checked by
  automated tests.
- **FR-022**: Every affected screen MUST render without overflow in Arabic and English at text
  scales 1.0 and 2.0 in both themes.
- **FR-023**: The feature MUST NOT change data, schema, financial rules or packages.
- **FR-024**: Implementation MUST start only after feature 004 is finished. It MUST cover the
  purchase screens that 004 delivers (new purchase, purchase list and details, supplier payments,
  purchase void) with the same states as the matching sale screens.

### Key Entities

- **Feedback tone**: success, warning, error or info. Each has a color pair per theme, an icon and a
  role.
- **Status mark**: a short labeled marker on a record row, such as low stock, below zero, owes,
  credit, voided, archived or paid.
- **Illustration**: one of 19 named scenes, each with a light and a dark version at three densities,
  tied to a screen state.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the screen and state pairs listed in handoff section 6 show their state in
  both themes, both languages and at text scale 2.0 with no overflow.
- **SC-002**: 100% of text and icon pairs in both themes pass WCAG AA contrast in automated tests
  (the design system's 96 of 96).
- **SC-003**: 0 states rely on color alone. Every success, warning, error, info and status mark has
  an icon or word.
- **SC-004**: 0 double saves when the save button is tapped repeatedly during a save.
- **SC-005**: A first-time owner can tell from each empty list what to do next without help. 5 of 5
  people asked should name the right first action.
- **SC-006**: Fast lists (under 300 ms) never flash a loading placeholder.
- **SC-007**: The existing test suite, the static analysis and the architecture rules stay green
  after every phase.

## Assumptions

- **Illustrations are bitmaps:** they are shown from the PNG exports. Showing SVG would need a new
  package, which the constitution does not allow without approval and which is not requested.
- **Error colors:** errors keep the theme's existing error colors. Existing colors are unchanged;
  only the three new tones are added.
- **Existing behavior stays:** the void reason field and the 004 purchase-discard prompt keep
  working; only their look changes.
- **Delivery:** the handoff's seven phases are the starting point for `tasks.md`, with a commit at
  each phase gate (decision B1 pattern) and no push.
- **Design source:** the design system artifact and the handoff are the visual source of truth.
  Values are taken from the handoff tables, never from screenshots.
