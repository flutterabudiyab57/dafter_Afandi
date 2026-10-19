# Feature Specification: Foundation

**Feature Branch**: `001-foundation`

**Created**: 2026-10-19

**Status**: Draft

**Input**: User description: "Feature "foundation": the first runnable version of Daftar Afandi
(دفتر أفندي), an app for small Egyptian shop owners. Opens in Arabic RTL with name and logo,
English available from settings. First run: short welcome, shop name (required) and phone
(optional). A screen explaining where data lives and how it is backed up on Android vs iPhone.
Five-section main navigation (Home, Sales, Customers & Suppliers, Purchases, Reports) with
explanatory placeholders. Settings: shop name/phone, language, digit style. Must already support
every later feature's stored records. Data survives restarts and, on Android, uninstall plus
reinstall on the same Google account. Out of scope: products, sales, customers, purchases,
expenses, report content, app lock, manual export/restore, invoice sharing."

## Clarifications

### Session 2026-10-19

- Q: Are the first-run and validation defaults in Assumptions accepted? → A: Yes, as written:
  data-and-backup screen is the last first-run step and reachable from settings; first run cannot
  be skipped and restarts from the welcome if interrupted; shop name 1–60 characters; phone 7–15
  digits with optional leading "+", Arabic or Latin digits; a chosen digit style persists across
  language switches.
- Q: Which language does first launch use, and can it be changed before settings? → A: Arabic on
  first launch regardless of device language, and the welcome screen has a visible Arabic / English
  switch.
- Q: What happens if restored data comes from a newer app version? → A: The app refuses to open that
  data, keeps it untouched, and shows a clear message. It never tries to read or migrate a newer
  data format.
- Q: Which screens and orientations must the first release support? → A: Phones only, portrait
  only; tablets run the phone layout in portrait.
- Q: What screen-reader support is required in the first release? → A: Every interactive element
  and the logo has a spoken label in Arabic and English; no formal screen-reader test pass.
- Q: Must the app support a dark appearance, and how is it chosen? → A: Light and dark, following
  the phone's setting automatically; no in-app choice.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First run and shop setup (Priority: P1)

A shop owner installs the app and opens it for the first time. The app appears in Arabic,
right-to-left, showing the app name "دفتر أفندي" and the logo. A short welcome explains what the
app is for and offers a visible Arabic / English switch. The owner enters the shop name (required) and, optionally, the shop phone, then sees a
short explanation of where their data is kept and how it is backed up. They finish and land on the
Home section. From then on, opening the app goes straight to Home.

**Why this priority**: Nothing else in the app works without a shop profile; this is the first thing
every user sees.

**Independent Test**: Install fresh, complete first run, close the app fully, reopen it: Home
appears directly and the shop name and phone are unchanged in settings.

**Acceptance Scenarios**:

1. **Given** a fresh install, **When** the app opens, **Then** it shows the welcome in Arabic,
   laid out right-to-left, with the app name and logo, even if the phone's language is English.
2. **Given** the welcome screen, **When** the owner taps English on the language switch, **Then**
   the welcome and all following first-run steps change to English, left-to-right, immediately,
   and English stays the app language after first run.
3. **Given** the shop details step, **When** the shop name is empty or only spaces, **Then** the
   owner cannot continue and sees a message, in the active language, saying the name is required.
4. **Given** the shop details step, **When** the owner enters a name and leaves the phone empty,
   **Then** they can continue.
5. **Given** the owner finished first run, **When** they close and reopen the app, **Then** the
   app opens on Home, and first run does not appear again.
6. **Given** the owner closes the app before finishing first run, **When** they reopen it,
   **Then** first run starts again from the welcome, in the language last chosen on the welcome.

---

### User Story 2 - Understanding where data lives (Priority: P1)

During first run, and later from settings, the owner reads a plain-language screen: their data is
stored only on this phone; on Android it is backed up automatically to their Google account if phone
backup is turned on; on iPhone they must export backups themselves, and that export will arrive in a
later update.

**Why this priority**: Losing a shop's records is the biggest risk for an offline app; the owner
must know this before entering any real data.

**Independent Test**: Open the screen on an Android phone and an iPhone and confirm each shows the
message that applies to that phone, in both languages.

**Acceptance Scenarios**:

1. **Given** an Android phone, **When** the screen is shown, **Then** it says data is stored only on
   this phone and is backed up automatically to the Google account if phone backup is enabled.
2. **Given** an iPhone, **When** the screen is shown, **Then** it says data is stored only on this
   phone and that the owner must export backups manually, with export coming in a later update.
3. **Given** first run is complete, **When** the owner opens settings, **Then** they can open this
   screen again.

---

### User Story 3 - Moving around the app (Priority: P2)

After setup, the owner sees main navigation with five sections: Home, Sales, Customers & Suppliers,
Purchases, Reports. Each section opens to a placeholder that explains, in a sentence or two, what
will appear there in a later update.

**Why this priority**: It gives the app its final shape so later features slot in without
changing how the owner navigates.

**Independent Test**: Tap each of the five sections in both languages and confirm each shows its
own title and explanation.

**Acceptance Scenarios**:

1. **Given** Home is shown, **When** the owner selects any of the five sections, **Then** that
   section opens and is visibly marked as the current one.
2. **Given** any section, **When** it opens, **Then** it shows a placeholder explaining what will
   appear there later, and no fake or sample data.
3. **Given** Arabic is active, **When** navigation is shown, **Then** sections run right-to-left
   with Home at the start (right) side.

---

### User Story 4 - Settings: shop details, language, digits (Priority: P2)

From settings the owner can edit the shop name and phone, switch between Arabic and English, and
choose the digit style (Arabic-Indic ٠١٢٣ or Latin 0123). By default the digit style follows the
language. Settings also shows the installed app version, which cannot be edited.

**Why this priority**: Shop details appear on future invoices, and some owners prefer English or
Latin digits.

**Independent Test**: Change each setting, close and reopen the app, and confirm each change is kept
and applied everywhere.

**Acceptance Scenarios**:

1. **Given** settings, **When** the owner changes the shop name or phone and saves, **Then** the new
   values are kept after the app restarts.
2. **Given** settings, **When** the owner clears the shop name, **Then** saving is blocked with a
   message that the name is required, and the previous name is kept.
3. **Given** Arabic is active, **When** the owner switches to English, **Then** the whole app
   changes to English, left-to-right, immediately and without a restart, and the app name shows as
   "Daftar Afandi".
4. **Given** the digit style has never been changed, **When** the language is Arabic, **Then**
   numbers show in Arabic-Indic digits; **When** it is English, **Then** they show in Latin digits.
5. **Given** the owner explicitly chose a digit style, **When** they switch language, **Then** their
   chosen digit style stays.
6. **Given** the owner chose a digit style, **When** they choose "follow language" again, **Then**
   the default behavior returns.
7. **Given** settings, **When** it opens, **Then** it shows the installed app version in Latin
   digits (for example "1.0.0 (1)") whatever the digit style, and the owner cannot edit it.
8. **Given** the shop name contains digits typed by the owner (for example "محل 23"), **When** the
   digit style is changed, **Then** the shop name still shows exactly as typed, while the shop phone
   follows the chosen digit style.

---

### User Story 5 - Data survives reinstall on Android (Priority: P3)

An owner on Android with phone backup enabled uninstalls the app by accident, then reinstalls it on
the same Google account. Their shop details and settings come back, and first run is skipped.

**Why this priority**: It protects against the most common accidental data loss, but depends on the
phone's own backup having run.

**Independent Test**: On an Android test phone with backup enabled, complete first run, trigger a
phone backup, uninstall, reinstall, open the app: Home appears with the same shop details.

**Acceptance Scenarios**:

1. **Given** Android backup is enabled and has run since setup, **When** the app is reinstalled on
   the same Google account, **Then** the shop details and settings are restored and first run is
   skipped.
2. **Given** no backup exists, **When** the app is reinstalled, **Then** first run starts normally.
3. **Given** the Android backup was made by an earlier release of the app, **When** a newer release
   is installed on the same Google account and opened, **Then** the restored data is upgraded
   automatically, all shop details and settings are present, first run is skipped, and the owner is
   asked to do nothing.

---

### Edge Cases

- Shop name made only of spaces is treated as empty; leading and trailing spaces are removed.
- Shop name longer than 60 characters cannot be entered.
- Phone accepts Arabic-Indic and Latin digits, with an optional leading "+"; spaces and dashes are
  ignored; other characters are rejected with a message. Stored digits are normalized so both input
  styles give the same value.
- Mixed text (Arabic shop name with Latin digits or English words) displays correctly in both
  directions.
- At 200% system text size, long labels wrap instead of being cut off, and every button stays
  reachable by scrolling.
- If saving fails (for example, the phone is out of storage), the owner sees a clear message, what
  they typed is kept on screen, and first run is not marked complete.
- If restored data comes from a newer app version than the one installed, the app refuses to open
  it, leaves it completely untouched (no read beyond the version check, no conversion, no write),
  and shows a clear message telling the owner to update the app. No other screen is reachable until
  the app is updated.
- If stored data comes from an older app version (for example, an Android backup made by an earlier
  release), the app upgrades it automatically on first launch, with no data lost and no action
  needed from the owner.
- The app works fully with no internet connection and never asks for one.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST open in Arabic, right-to-left, on first launch regardless of the phone's
  language, showing the app name
  "دفتر أفندي" and the logo.
- **FR-002**: The app MUST offer English (left-to-right, app name "Daftar Afandi") as a second
  language, switchable from a visible Arabic / English switch on the welcome screen and from
  settings, taking effect immediately. The language chosen on the welcome is kept for the rest of
  first run and after it, including if first run is interrupted.
- **FR-003**: Every user-visible text MUST exist in both Arabic and English; no screen may show text
  in the inactive language (the shop's own name excepted).
- **FR-004**: On first run only, the app MUST show, in order: a short welcome, a shop details step
  (name required, phone optional), and the data-and-backup explanation, then go to Home.
- **FR-005**: The app MUST remember that first run is complete and open on Home on every later launch.
- **FR-006**: The app MUST validate the shop name (required, trimmed, 1–60 characters) and phone
  (optional, digits with optional leading "+", 7–15 digits after normalization).
- **FR-007**: The data-and-backup screen MUST show the Android or iPhone message that matches the
  phone it runs on, and MUST be reachable again from settings.
- **FR-008**: The app MUST provide main navigation with exactly five sections in this order: Home,
  Sales, Customers & Suppliers, Purchases, Reports.
- **FR-009**: Each section MUST show a placeholder explaining what it will contain later, with no
  sample data.
- **FR-010**: Settings MUST let the owner edit shop name and phone, choose the language, choose the
  digit style (Arabic-Indic, Latin, or follow language), and open the data-and-backup screen.
  Settings MUST also show the installed app version, read-only. Nothing else is offered in settings
  in this feature.
- **FR-011**: The digit style MUST apply to numbers the app itself displays (counts, amounts, dates,
  the shop phone). Free text the owner typed, such as the shop name, MUST be shown exactly as
  entered. Exception: the app version is a technical identifier and MUST always be shown in Latin
  digits (for example "1.0.0 (1)"), regardless of the digit style. Number input MUST accept both
  digit styles regardless of the setting.
- **FR-012**: Shop details and all settings MUST persist across app restarts and phone restarts.
- **FR-013**: On Android, the app's data MUST be included in the phone's automatic backup to the
  user's Google account, so a reinstall on the same account restores it.
- **FR-014**: The app's on-phone data store MUST, from this feature onward, be able to hold every
  record type the planned features need (see Key Entities), so later features add screens without
  restructuring data already saved.
- **FR-015**: The app MUST work fully offline and MUST NOT send any data off the phone.
- **FR-016**: Every screen MUST be fully usable at 200% system text size in both languages, and the
  app MUST NOT override or cap the phone's text size setting.
- **FR-017**: The app MUST NOT describe any document or screen as a tax receipt or tax invoice.
- **FR-018**: On every launch, before using stored data, the app MUST check which app version's data
  format it holds. If it is newer than the installed app understands, the app MUST refuse to open
  it, MUST NOT read, convert, or change it, and MUST show only a clear "please update the app"
  message in the active language (Arabic if none is known). If it is older, the app MUST upgrade it
  automatically before use, with no data lost and no action needed from the owner.
- **FR-019**: The app MUST run in portrait orientation only and MUST NOT rotate to landscape. It
  targets phones; on tablets it shows the same phone layout in portrait.
- **FR-020**: Every interactive element (buttons, switches, fields, navigation items) and the logo
  MUST have a spoken label for screen readers, in the active language. A formal screen-reader test
  pass is not required in this feature.
- **FR-021**: The app MUST provide a light and a dark appearance and MUST follow the phone's
  light/dark setting automatically, switching while open if the phone setting changes. Settings
  MUST NOT offer an appearance choice in this feature.

### Key Entities *(include if feature involves data)*

Used by this feature:

- **Shop profile**: shop name, optional shop phone. One per installation. Shown later on shared
  invoices.
- **App preferences**: language (Arabic/English), digit style (follow language / Arabic-Indic /
  Latin), first-run-completed flag.

Prepared now for later features (stored, no screens yet):

- **Product category**: name; used to group products.
- **Product**: name, optional category, unit (piece, kg, liter, meter), selling price, current
  average cost, optional barcode (stored now; scanning comes in a later feature).
- **Customer** and **Supplier**: name, optional phone; each with a running balance derived from
  their history.
- **Sales invoice** with lines (product name, quantity, price, and cost as they were at the time of
  sale), payment method, and void information.
- **Sale return** with lines, linked to the original invoice.
- **Purchase invoice** with lines, payment method, and void information.
- **Expense category**: name.
- **Expense**: amount, expense category, note.
- **Payment received / payment made**: amount, payment method, linked customer or supplier.
- **Stock movement**: every change in quantity of a product (sale, return, purchase, adjustment for
  damage, count, or other); stock on hand is the sum of these.
- **Account history entries**: every change to a customer or supplier balance; balances are the sum
  of these.
- **Document number sequences**: one per document type, never reused, never with gaps.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In timed runs, 3 people who have never seen the app each complete first run in under
  60 seconds.
- **SC-002**: 100% of screens are fully usable in portrait on phones, in Arabic right-to-left and
  English left-to-right, in light and dark appearance, at normal and 200% system text size: no cut-off or overlapping text and every action reachable.
- **SC-003**: Shop details entered on first run are unchanged after 10 consecutive close-and-reopen
  cycles and after a phone restart.
- **SC-004**: Switching language or digit style updates every visible screen in under 1 second,
  without restarting the app.
- **SC-005**: On an Android test phone with backup enabled, uninstalling and reinstalling on the same
  Google account restores shop details and skips first run.
- **SC-006**: The app completes all flows in this feature with the phone in airplane mode and sends
  no data off the phone.
- **SC-007**: A review of every screen finds zero text in the inactive language.
- **SC-008**: A review of every screen finds zero interactive elements (and no logo) without a
  spoken label in both Arabic and English.

## Assumptions

- The app always starts in Arabic on first launch, whatever the phone's language; the owner can
  switch to English on the welcome screen or later in settings.
- The data-and-backup explanation is the last step of first run and is also reachable from settings.
- First run cannot be skipped; closing the app before finishing restarts it from the welcome.
- First run offers only the language switch on the welcome (no question is forced); digit style is
  not offered during first run, to keep it under one minute.
- Egyptian phone numbers (mobile and landline) fit 7–15 digits; no carrier-specific format check.
- Android automatic backup depends on the owner's phone settings and the phone's own backup
  schedule; the app cannot force a backup to run.
- iPhone has no automatic backup in this feature; manual export and restore arrive in a later feature.
- Shop name and phone are not yet printed anywhere in this feature; invoice sharing comes later.
- Units of measure are limited to piece, kg, liter, and meter for the first release.
- Project rules in the constitution (money and quantity precision, immutability, no network code,
  approved stack) apply and are not repeated here.
