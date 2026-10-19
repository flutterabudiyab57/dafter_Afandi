# Contract: Routes, screens and strings

Router: go_router 18.0.2, `lib/core/router/app_router.dart`. Paths are constants in `route_names.dart`.

## Routes

| Path | Screen (feature/presentation) | Notes |
|---|---|---|
| `/welcome` | `WelcomeScreen` (onboarding) | logo, app name, short intro, **Arabic / English switch** (writes immediately), Continue |
| `/onboarding/shop` | `ShopDetailsStepScreen` (onboarding) | name (required), phone (optional), Continue blocked while invalid |
| `/onboarding/data` | `DataSafetyScreen(mode: onboarding)` (settings) | platform-specific text; Finish → `completeOnboarding` → `/home` |
| `/home` | `HomeScreen` (home) | shell branch 0, placeholder |
| `/sales` | `SalesScreen` (sales) | shell branch 1, placeholder |
| `/parties` | `PartiesScreen` (customers) | shell branch 2, "Customers & Suppliers" placeholder |
| `/purchases` | `PurchasesScreen` (purchases) | shell branch 3, placeholder |
| `/reports` | `ReportsScreen` (reports) | shell branch 4, placeholder |
| `/settings` | `SettingsScreen` (settings) | pushed above the shell |
| `/settings/shop` | `ShopProfileEditScreen` (settings) | edit name and phone, Save |
| `/settings/data` | `DataSafetyScreen(mode: settings)` (settings) | the same content, back button |

The shell is a `StatefulShellRoute.indexedStack` with a `NavigationBar` of 5 destinations in the
order above (FR-008). In RTL, Home sits at the start (right). Each branch's app bar has a settings
action (icon + spoken label) that pushes `/settings`.

## Redirect rules (single `redirect` function, `refreshListenable` = settings stream)

| State | Allowed | Otherwise go to |
|---|---|---|
| onboarding not completed | `/welcome`, `/onboarding/*` | `/welcome` |
| onboarding completed | everything except `/welcome`, `/onboarding/*` | `/home` |

The initial location is `/welcome`. After a restart, an interrupted first run starts at `/welcome`
again (typed values are not kept; the language is).

## Screen behavior contract

- **Placeholders**: a shared `SectionPlaceholder(icon, title, body)` in `core/widgets`, with no sample data (FR-009).
- **DataSafetyScreen**: chooses its body by `defaultTargetPlatform` (`android` → auto-backup text;
  `iOS` → manual-export-later text). Keys: `dataSafetyTitle`, `dataSafetyLocalOnly`,
  `dataSafetyAndroidBackup`, `dataSafetyIosManual`.
- **SettingsScreen** rows: Shop details (name and phone preview, opens `/settings/shop`); Language
  (ar/en); Digit style (Follow language / Arabic-Indic ٠١٢٣ / Latin 0123); About your data; App version
  (read-only, Latin digits, e.g. `1.0.0 (1)`). Nothing else (FR-010).
- **Shop name display**: always exactly as typed; the digit style is never applied (FR-011).
  The phone and version display inside LTR isolates.
- Every interactive element and the logo has a `Semantics` label from ARB (FR-020).
- At 200% text: no fixed heights on text containers, every screen scrolls, and buttons wrap their labels (FR-016).
- Content width is capped (token `maxContentWidth`) and centered for tablets and landscape fallback (FR-019, K1).

## ARB keys (both `app_ar.arb` and `app_en.arb`, ar is the template)

`appName`; `welcomeTitle`, `welcomeBody`, `languageArabic`, `languageEnglish`, `continueAction`;
`shopDetailsTitle`, `shopNameLabel`, `shopPhoneLabel`, `shopPhoneOptionalHint`,
`errorShopNameRequired`, `errorShopNameTooLong`, `errorPhoneInvalid`, `errorPhoneTooShort`,
`errorPhoneTooLong`, `errorSaveFailed`; `dataSafetyTitle`, `dataSafetyLocalOnly`,
`dataSafetyAndroidBackup`, `dataSafetyIosManual`, `finishAction`;
`navHome`, `navSales`, `navParties`, `navPurchases`, `navReports`;
`placeholderHomeTitle/Body`, `placeholderSalesTitle/Body`, `placeholderPartiesTitle/Body`,
`placeholderPurchasesTitle/Body`, `placeholderReportsTitle/Body`;
`settingsTitle`, `settingsShopDetails`, `settingsLanguage`, `settingsDigitStyle`,
`digitStyleFollowLanguage`, `digitStyleArabic`, `digitStyleLatin`, `settingsAboutData`,
`settingsAppVersion`, `saveAction`, `openSettingsSemantics`, `logoSemantics`;
`updateRequiredTitle`, `updateRequiredBody`, `dataUnrecognizedBody`, `startupErrorBody`.

Wording rule: no string may say "tax receipt", "tax invoice", "فاتورة ضريبية" or "إيصال ضريبي" (FR-017).
A test greps both ARB files for this.
