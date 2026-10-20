import 'package:drift/drift.dart';

import '../converters/utc_millis_converter.dart';
import 'enums.dart';

/// The single settings row (data-model.md, app_settings). Seeded in
/// `onCreate`; never inserted or deleted afterwards. No PIN columns: the PIN
/// lives in flutter_secure_storage (constitution).
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  TextColumn get id => text()();
  IntColumn get singleton =>
      integer().withDefault(const Constant(1)).unique()();
  TextColumn get shopName => text().nullable()();
  TextColumn get shopPhone => text().nullable()();
  TextColumn get shopAddress => text().nullable()();
  TextColumn get invoiceFooter => text().nullable()();
  TextColumn get localeCode =>
      textEnum<LocaleCode>().withDefault(const Constant('ar'))();
  TextColumn get digitStyle =>
      textEnum<DigitStylePreference>().withDefault(const Constant('follow'))();
  TextColumn get negativeStockPolicy =>
      textEnum<NegativeStockPolicy>().withDefault(const Constant('warn'))();
  BoolColumn get appLockEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get biometricEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get deviceId => text()();
  IntColumn get onboardingCompletedAt =>
      integer().map(const UtcMillisConverter()).nullable()();
  IntColumn get createdAt => integer().map(const UtcMillisConverter())();
  IntColumn get updatedAt => integer().map(const UtcMillisConverter())();

  @override
  Set<Column> get primaryKey => {id};

  // The phone CHECK is the full stored form: an optional leading `+`, then
  // 7–15 Latin digits (data-model.md lists only its first clause).
  @override
  List<String> get customConstraints => [
    'CHECK (singleton = 1)',
    "CHECK (shop_phone IS NULL OR (shop_phone GLOB '[+0-9]*' AND NOT (substr(shop_phone, 2) GLOB '*[^0-9]*') AND length(ltrim(shop_phone, '+')) BETWEEN 7 AND 15))",
    "CHECK (locale_code IN ('ar', 'en'))",
    "CHECK (digit_style IN ('follow', 'arabic', 'latin'))",
    "CHECK (negative_stock_policy IN ('warn', 'block'))",
    'CHECK (onboarding_completed_at IS NULL OR (shop_name IS NOT NULL AND length(trim(shop_name)) BETWEEN 1 AND 60))',
  ];
}
