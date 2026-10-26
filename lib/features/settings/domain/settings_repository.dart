import 'app_locale.dart';
import 'app_settings.dart';
import 'shop_profile.dart';

/// contracts/settings-and-state.md. Writes throw [SettingsWriteFailure].
abstract interface class SettingsRepository {
  Future<AppSettings> load();

  /// The current settings, then every change.
  Stream<AppSettings> watch();

  Future<void> setLocale(AppLocale locale);

  Future<void> setDigitStyle(DigitStylePreference style);

  /// Requires onboarding to be completed.
  Future<void> saveShopProfile(ShopProfile profile);

  /// Saves the profile and marks onboarding done, in one transaction.
  Future<void> completeOnboarding(ShopProfile profile);
}

/// A settings write failed; nothing was saved. The UI shows `errorSaveFailed`
/// and keeps what the owner typed.
final class SettingsWriteFailure implements Exception {
  const SettingsWriteFailure(this.cause);

  final Object cause;

  @override
  String toString() => 'SettingsWriteFailure($cause)';
}
