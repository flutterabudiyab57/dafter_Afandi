import 'package:drift/drift.dart' show Value;

import '../../../core/database/app_database.dart';
import '../../../core/database/daos/settings_dao.dart';
import '../../../core/database/tables/enums.dart' as db;
import '../../../core/database/transaction_runner.dart';
import '../../../core/utils/clock.dart';
import '../domain/app_locale.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';
import '../domain/shop_profile.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._dao, this._tx, this._clock);

  final SettingsDao _dao;
  final TransactionRunner _tx;
  final Clock _clock;

  @override
  Future<AppSettings> load() async => _toEntity(await _dao.getSingleton());

  @override
  Stream<AppSettings> watch() => _dao.watchSingleton().map(_toEntity);

  @override
  Future<void> setLocale(AppLocale locale) => _write(
    AppSettingsCompanion(
      localeCode: Value(_localeToDb(locale)),
      updatedAt: Value(_clock.nowUtc()),
    ),
  );

  @override
  Future<void> setDigitStyle(DigitStylePreference style) => _write(
    AppSettingsCompanion(
      digitStyle: Value(_digitStyleToDb(style)),
      updatedAt: Value(_clock.nowUtc()),
    ),
  );

  @override
  Future<void> saveShopProfile(ShopProfile profile) async {
    final AppSettingsRow current;
    try {
      current = await _dao.getSingleton();
    } on Object catch (e) {
      throw SettingsWriteFailure(e);
    }
    if (current.onboardingCompletedAt == null) {
      throw StateError('saveShopProfile before onboarding is completed');
    }
    await _write(
      AppSettingsCompanion(
        shopName: Value(profile.name),
        shopPhone: Value(profile.phone),
        updatedAt: Value(_clock.nowUtc()),
      ),
    );
  }

  @override
  Future<void> completeOnboarding(ShopProfile profile) {
    final now = _clock.nowUtc();
    return _write(
      AppSettingsCompanion(
        shopName: Value(profile.name),
        shopPhone: Value(profile.phone),
        onboardingCompletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// One UPDATE of the singleton row, in one transaction.
  Future<void> _write(AppSettingsCompanion changes) async {
    try {
      await _tx.run(() => _dao.updateSingleton(changes));
    } on Object catch (e) {
      throw SettingsWriteFailure(e);
    }
  }

  static AppSettings _toEntity(AppSettingsRow row) => AppSettings(
    locale: switch (row.localeCode) {
      db.LocaleCode.ar => AppLocale.ar,
      db.LocaleCode.en => AppLocale.en,
    },
    digitStyle: switch (row.digitStyle) {
      db.DigitStylePreference.follow => DigitStylePreference.followLanguage,
      db.DigitStylePreference.arabic => DigitStylePreference.arabicIndic,
      db.DigitStylePreference.latin => DigitStylePreference.latin,
    },
    shop: row.shopName == null
        ? null
        : ShopProfile(name: row.shopName!, phone: row.shopPhone),
    onboardingCompleted: row.onboardingCompletedAt != null,
  );

  static db.LocaleCode _localeToDb(AppLocale locale) => switch (locale) {
    AppLocale.ar => db.LocaleCode.ar,
    AppLocale.en => db.LocaleCode.en,
  };

  static db.DigitStylePreference _digitStyleToDb(DigitStylePreference s) =>
      switch (s) {
        DigitStylePreference.followLanguage => db.DigitStylePreference.follow,
        DigitStylePreference.arabicIndic => db.DigitStylePreference.arabic,
        DigitStylePreference.latin => db.DigitStylePreference.latin,
      };
}
