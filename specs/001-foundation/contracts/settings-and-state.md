# Contract: Settings repository, DAO and Cubits

Layer path (constitution IV): Screen → Cubit → `SettingsRepository` (domain) →
`SettingsRepositoryImpl` (data) → `SettingsDao` (core/database/daos) → Drift.

## Domain (`lib/features/settings/domain/`, pure Dart)

```dart
enum AppLocale { ar, en }
enum DigitStylePreference { followLanguage, arabicIndic, latin }
enum DigitStyle { arabicIndic, latin }   // effective; lives in core/utils/digits.dart

final class AppSettings extends Equatable {
  final AppLocale locale;
  final DigitStylePreference digitStyle;
  final ShopProfile? shop;
  final bool onboardingCompleted;
  DigitStyle get effectiveDigitStyle;  // follow: ar → arabicIndic, en → latin
}

abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Stream<AppSettings> watch();
  Future<void> setLocale(AppLocale locale);
  Future<void> setDigitStyle(DigitStylePreference style);
  Future<void> saveShopProfile(ShopProfile profile);        // requires onboarding completed
  Future<void> completeOnboarding(ShopProfile profile);     // ONE transaction: profile + onboardingCompletedAt
}
```

Errors are typed: `SettingsWriteFailure` (wraps the storage error; the UI shows `errorSaveFailed`
and keeps the typed values).

## Data (`lib/features/settings/data/`)

- `SettingsRepositoryImpl(SettingsDao, TransactionRunner, Clock)` maps the Drift row to `AppSettings`.
- `completeOnboarding` runs inside `TransactionRunner.run` and sets `shopName`, `shopPhone`,
  `onboardingCompletedAt = clock.nowUtc()`, `updatedAt` in one UPDATE of the singleton row.

## DAO (`lib/core/database/daos/settings_dao.dart`)

`Future<AppSettingsRow> getSingleton()`, `Stream<AppSettingsRow> watchSingleton()`,
`Future<void> updateSingleton(AppSettingsCompanion)` (asserts that exactly 1 row is affected).
No insert (the row is seeded in `onCreate`), no delete.

## Cubits

| Cubit | Scope | State | Methods |
|---|---|---|---|
| `AppPreferencesCubit` | app-wide (above the router) | `AppSettings` | `changeLocale`, `changeDigitStyle` (writes, then the stream updates the state) |
| `ShopProfileFormCubit` | onboarding shop step, settings shop edit | `{nameInput, phoneInput, nameError?, phoneError?, status: idle/saving/saved/failed}` | `nameChanged`, `phoneChanged`, `submit()` (validates via `ShopProfile.create`, calls `completeOnboarding` or `saveShopProfile` depending on mode) |

`App` builds `MaterialApp.router` from `AppPreferencesCubit` state: `locale`, `themeMode: system`,
and digit style provided through an inherited `DigitStyleScope` used by formatting widgets. A
locale or digit change rebuilds without a restart (SC-004).

## Tests

- bloc_test for both cubits with mocktail repositories: validation errors, a successful submit,
  a failure keeping inputs, and the locale change flow.
- Repository tests on `NativeDatabase.memory()`: seed row present, `completeOnboarding` atomic (a forced
  failure leaves `onboardingCompletedAt` NULL), the CHECK rejects onboarded-without-name, values
  persist after close/reopen on a temp file (SC-003).
