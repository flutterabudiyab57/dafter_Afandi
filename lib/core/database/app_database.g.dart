// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _singletonMeta = const VerificationMeta(
    'singleton',
  );
  @override
  late final GeneratedColumn<int> singleton = GeneratedColumn<int>(
    'singleton',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _shopNameMeta = const VerificationMeta(
    'shopName',
  );
  @override
  late final GeneratedColumn<String> shopName = GeneratedColumn<String>(
    'shop_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shopPhoneMeta = const VerificationMeta(
    'shopPhone',
  );
  @override
  late final GeneratedColumn<String> shopPhone = GeneratedColumn<String>(
    'shop_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shopAddressMeta = const VerificationMeta(
    'shopAddress',
  );
  @override
  late final GeneratedColumn<String> shopAddress = GeneratedColumn<String>(
    'shop_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceFooterMeta = const VerificationMeta(
    'invoiceFooter',
  );
  @override
  late final GeneratedColumn<String> invoiceFooter = GeneratedColumn<String>(
    'invoice_footer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocaleCode, String> localeCode =
      GeneratedColumn<String>(
        'locale_code',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('ar'),
      ).withConverter<LocaleCode>($AppSettingsTable.$converterlocaleCode);
  @override
  late final GeneratedColumnWithTypeConverter<DigitStylePreference, String>
  digitStyle = GeneratedColumn<String>(
    'digit_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('follow'),
  ).withConverter<DigitStylePreference>($AppSettingsTable.$converterdigitStyle);
  @override
  late final GeneratedColumnWithTypeConverter<NegativeStockPolicy, String>
  negativeStockPolicy =
      GeneratedColumn<String>(
        'negative_stock_policy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('warn'),
      ).withConverter<NegativeStockPolicy>(
        $AppSettingsTable.$converternegativeStockPolicy,
      );
  static const VerificationMeta _appLockEnabledMeta = const VerificationMeta(
    'appLockEnabled',
  );
  @override
  late final GeneratedColumn<bool> appLockEnabled = GeneratedColumn<bool>(
    'app_lock_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("app_lock_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _biometricEnabledMeta = const VerificationMeta(
    'biometricEnabled',
  );
  @override
  late final GeneratedColumn<bool> biometricEnabled = GeneratedColumn<bool>(
    'biometric_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("biometric_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int>
  onboardingCompletedAt =
      GeneratedColumn<int>(
        'onboarding_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $AppSettingsTable.$converteronboardingCompletedAtn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AppSettingsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AppSettingsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    singleton,
    shopName,
    shopPhone,
    shopAddress,
    invoiceFooter,
    localeCode,
    digitStyle,
    negativeStockPolicy,
    appLockEnabled,
    biometricEnabled,
    deviceId,
    onboardingCompletedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('singleton')) {
      context.handle(
        _singletonMeta,
        singleton.isAcceptableOrUnknown(data['singleton']!, _singletonMeta),
      );
    }
    if (data.containsKey('shop_name')) {
      context.handle(
        _shopNameMeta,
        shopName.isAcceptableOrUnknown(data['shop_name']!, _shopNameMeta),
      );
    }
    if (data.containsKey('shop_phone')) {
      context.handle(
        _shopPhoneMeta,
        shopPhone.isAcceptableOrUnknown(data['shop_phone']!, _shopPhoneMeta),
      );
    }
    if (data.containsKey('shop_address')) {
      context.handle(
        _shopAddressMeta,
        shopAddress.isAcceptableOrUnknown(
          data['shop_address']!,
          _shopAddressMeta,
        ),
      );
    }
    if (data.containsKey('invoice_footer')) {
      context.handle(
        _invoiceFooterMeta,
        invoiceFooter.isAcceptableOrUnknown(
          data['invoice_footer']!,
          _invoiceFooterMeta,
        ),
      );
    }
    if (data.containsKey('app_lock_enabled')) {
      context.handle(
        _appLockEnabledMeta,
        appLockEnabled.isAcceptableOrUnknown(
          data['app_lock_enabled']!,
          _appLockEnabledMeta,
        ),
      );
    }
    if (data.containsKey('biometric_enabled')) {
      context.handle(
        _biometricEnabledMeta,
        biometricEnabled.isAcceptableOrUnknown(
          data['biometric_enabled']!,
          _biometricEnabledMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      singleton: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton'],
      )!,
      shopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_name'],
      ),
      shopPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_phone'],
      ),
      shopAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_address'],
      ),
      invoiceFooter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_footer'],
      ),
      localeCode: $AppSettingsTable.$converterlocaleCode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}locale_code'],
        )!,
      ),
      digitStyle: $AppSettingsTable.$converterdigitStyle.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}digit_style'],
        )!,
      ),
      negativeStockPolicy: $AppSettingsTable.$converternegativeStockPolicy
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}negative_stock_policy'],
            )!,
          ),
      appLockEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}app_lock_enabled'],
      )!,
      biometricEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}biometric_enabled'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      onboardingCompletedAt: $AppSettingsTable.$converteronboardingCompletedAtn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.int,
              data['${effectivePrefix}onboarding_completed_at'],
            ),
          ),
      createdAt: $AppSettingsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $AppSettingsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LocaleCode, String, String> $converterlocaleCode =
      const EnumNameConverter<LocaleCode>(LocaleCode.values);
  static JsonTypeConverter2<DigitStylePreference, String, String>
  $converterdigitStyle = const EnumNameConverter<DigitStylePreference>(
    DigitStylePreference.values,
  );
  static JsonTypeConverter2<NegativeStockPolicy, String, String>
  $converternegativeStockPolicy = const EnumNameConverter<NegativeStockPolicy>(
    NegativeStockPolicy.values,
  );
  static TypeConverter<DateTime, int> $converteronboardingCompletedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converteronboardingCompletedAtn =
      NullAwareTypeConverter.wrap($converteronboardingCompletedAt);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final String id;
  final int singleton;
  final String? shopName;
  final String? shopPhone;
  final String? shopAddress;
  final String? invoiceFooter;
  final LocaleCode localeCode;
  final DigitStylePreference digitStyle;
  final NegativeStockPolicy negativeStockPolicy;
  final bool appLockEnabled;
  final bool biometricEnabled;
  final String deviceId;
  final DateTime? onboardingCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AppSettingsRow({
    required this.id,
    required this.singleton,
    this.shopName,
    this.shopPhone,
    this.shopAddress,
    this.invoiceFooter,
    required this.localeCode,
    required this.digitStyle,
    required this.negativeStockPolicy,
    required this.appLockEnabled,
    required this.biometricEnabled,
    required this.deviceId,
    this.onboardingCompletedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['singleton'] = Variable<int>(singleton);
    if (!nullToAbsent || shopName != null) {
      map['shop_name'] = Variable<String>(shopName);
    }
    if (!nullToAbsent || shopPhone != null) {
      map['shop_phone'] = Variable<String>(shopPhone);
    }
    if (!nullToAbsent || shopAddress != null) {
      map['shop_address'] = Variable<String>(shopAddress);
    }
    if (!nullToAbsent || invoiceFooter != null) {
      map['invoice_footer'] = Variable<String>(invoiceFooter);
    }
    {
      map['locale_code'] = Variable<String>(
        $AppSettingsTable.$converterlocaleCode.toSql(localeCode),
      );
    }
    {
      map['digit_style'] = Variable<String>(
        $AppSettingsTable.$converterdigitStyle.toSql(digitStyle),
      );
    }
    {
      map['negative_stock_policy'] = Variable<String>(
        $AppSettingsTable.$converternegativeStockPolicy.toSql(
          negativeStockPolicy,
        ),
      );
    }
    map['app_lock_enabled'] = Variable<bool>(appLockEnabled);
    map['biometric_enabled'] = Variable<bool>(biometricEnabled);
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || onboardingCompletedAt != null) {
      map['onboarding_completed_at'] = Variable<int>(
        $AppSettingsTable.$converteronboardingCompletedAtn.toSql(
          onboardingCompletedAt,
        ),
      );
    }
    {
      map['created_at'] = Variable<int>(
        $AppSettingsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $AppSettingsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      singleton: Value(singleton),
      shopName: shopName == null && nullToAbsent
          ? const Value.absent()
          : Value(shopName),
      shopPhone: shopPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(shopPhone),
      shopAddress: shopAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(shopAddress),
      invoiceFooter: invoiceFooter == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceFooter),
      localeCode: Value(localeCode),
      digitStyle: Value(digitStyle),
      negativeStockPolicy: Value(negativeStockPolicy),
      appLockEnabled: Value(appLockEnabled),
      biometricEnabled: Value(biometricEnabled),
      deviceId: Value(deviceId),
      onboardingCompletedAt: onboardingCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardingCompletedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      singleton: serializer.fromJson<int>(json['singleton']),
      shopName: serializer.fromJson<String?>(json['shopName']),
      shopPhone: serializer.fromJson<String?>(json['shopPhone']),
      shopAddress: serializer.fromJson<String?>(json['shopAddress']),
      invoiceFooter: serializer.fromJson<String?>(json['invoiceFooter']),
      localeCode: $AppSettingsTable.$converterlocaleCode.fromJson(
        serializer.fromJson<String>(json['localeCode']),
      ),
      digitStyle: $AppSettingsTable.$converterdigitStyle.fromJson(
        serializer.fromJson<String>(json['digitStyle']),
      ),
      negativeStockPolicy: $AppSettingsTable.$converternegativeStockPolicy
          .fromJson(serializer.fromJson<String>(json['negativeStockPolicy'])),
      appLockEnabled: serializer.fromJson<bool>(json['appLockEnabled']),
      biometricEnabled: serializer.fromJson<bool>(json['biometricEnabled']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      onboardingCompletedAt: serializer.fromJson<DateTime?>(
        json['onboardingCompletedAt'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'singleton': serializer.toJson<int>(singleton),
      'shopName': serializer.toJson<String?>(shopName),
      'shopPhone': serializer.toJson<String?>(shopPhone),
      'shopAddress': serializer.toJson<String?>(shopAddress),
      'invoiceFooter': serializer.toJson<String?>(invoiceFooter),
      'localeCode': serializer.toJson<String>(
        $AppSettingsTable.$converterlocaleCode.toJson(localeCode),
      ),
      'digitStyle': serializer.toJson<String>(
        $AppSettingsTable.$converterdigitStyle.toJson(digitStyle),
      ),
      'negativeStockPolicy': serializer.toJson<String>(
        $AppSettingsTable.$converternegativeStockPolicy.toJson(
          negativeStockPolicy,
        ),
      ),
      'appLockEnabled': serializer.toJson<bool>(appLockEnabled),
      'biometricEnabled': serializer.toJson<bool>(biometricEnabled),
      'deviceId': serializer.toJson<String>(deviceId),
      'onboardingCompletedAt': serializer.toJson<DateTime?>(
        onboardingCompletedAt,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsRow copyWith({
    String? id,
    int? singleton,
    Value<String?> shopName = const Value.absent(),
    Value<String?> shopPhone = const Value.absent(),
    Value<String?> shopAddress = const Value.absent(),
    Value<String?> invoiceFooter = const Value.absent(),
    LocaleCode? localeCode,
    DigitStylePreference? digitStyle,
    NegativeStockPolicy? negativeStockPolicy,
    bool? appLockEnabled,
    bool? biometricEnabled,
    String? deviceId,
    Value<DateTime?> onboardingCompletedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AppSettingsRow(
    id: id ?? this.id,
    singleton: singleton ?? this.singleton,
    shopName: shopName.present ? shopName.value : this.shopName,
    shopPhone: shopPhone.present ? shopPhone.value : this.shopPhone,
    shopAddress: shopAddress.present ? shopAddress.value : this.shopAddress,
    invoiceFooter: invoiceFooter.present
        ? invoiceFooter.value
        : this.invoiceFooter,
    localeCode: localeCode ?? this.localeCode,
    digitStyle: digitStyle ?? this.digitStyle,
    negativeStockPolicy: negativeStockPolicy ?? this.negativeStockPolicy,
    appLockEnabled: appLockEnabled ?? this.appLockEnabled,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    deviceId: deviceId ?? this.deviceId,
    onboardingCompletedAt: onboardingCompletedAt.present
        ? onboardingCompletedAt.value
        : this.onboardingCompletedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      singleton: data.singleton.present ? data.singleton.value : this.singleton,
      shopName: data.shopName.present ? data.shopName.value : this.shopName,
      shopPhone: data.shopPhone.present ? data.shopPhone.value : this.shopPhone,
      shopAddress: data.shopAddress.present
          ? data.shopAddress.value
          : this.shopAddress,
      invoiceFooter: data.invoiceFooter.present
          ? data.invoiceFooter.value
          : this.invoiceFooter,
      localeCode: data.localeCode.present
          ? data.localeCode.value
          : this.localeCode,
      digitStyle: data.digitStyle.present
          ? data.digitStyle.value
          : this.digitStyle,
      negativeStockPolicy: data.negativeStockPolicy.present
          ? data.negativeStockPolicy.value
          : this.negativeStockPolicy,
      appLockEnabled: data.appLockEnabled.present
          ? data.appLockEnabled.value
          : this.appLockEnabled,
      biometricEnabled: data.biometricEnabled.present
          ? data.biometricEnabled.value
          : this.biometricEnabled,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      onboardingCompletedAt: data.onboardingCompletedAt.present
          ? data.onboardingCompletedAt.value
          : this.onboardingCompletedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('shopName: $shopName, ')
          ..write('shopPhone: $shopPhone, ')
          ..write('shopAddress: $shopAddress, ')
          ..write('invoiceFooter: $invoiceFooter, ')
          ..write('localeCode: $localeCode, ')
          ..write('digitStyle: $digitStyle, ')
          ..write('negativeStockPolicy: $negativeStockPolicy, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('deviceId: $deviceId, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    singleton,
    shopName,
    shopPhone,
    shopAddress,
    invoiceFooter,
    localeCode,
    digitStyle,
    negativeStockPolicy,
    appLockEnabled,
    biometricEnabled,
    deviceId,
    onboardingCompletedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.singleton == this.singleton &&
          other.shopName == this.shopName &&
          other.shopPhone == this.shopPhone &&
          other.shopAddress == this.shopAddress &&
          other.invoiceFooter == this.invoiceFooter &&
          other.localeCode == this.localeCode &&
          other.digitStyle == this.digitStyle &&
          other.negativeStockPolicy == this.negativeStockPolicy &&
          other.appLockEnabled == this.appLockEnabled &&
          other.biometricEnabled == this.biometricEnabled &&
          other.deviceId == this.deviceId &&
          other.onboardingCompletedAt == this.onboardingCompletedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<String> id;
  final Value<int> singleton;
  final Value<String?> shopName;
  final Value<String?> shopPhone;
  final Value<String?> shopAddress;
  final Value<String?> invoiceFooter;
  final Value<LocaleCode> localeCode;
  final Value<DigitStylePreference> digitStyle;
  final Value<NegativeStockPolicy> negativeStockPolicy;
  final Value<bool> appLockEnabled;
  final Value<bool> biometricEnabled;
  final Value<String> deviceId;
  final Value<DateTime?> onboardingCompletedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.singleton = const Value.absent(),
    this.shopName = const Value.absent(),
    this.shopPhone = const Value.absent(),
    this.shopAddress = const Value.absent(),
    this.invoiceFooter = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.digitStyle = const Value.absent(),
    this.negativeStockPolicy = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.onboardingCompletedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String id,
    this.singleton = const Value.absent(),
    this.shopName = const Value.absent(),
    this.shopPhone = const Value.absent(),
    this.shopAddress = const Value.absent(),
    this.invoiceFooter = const Value.absent(),
    this.localeCode = const Value.absent(),
    this.digitStyle = const Value.absent(),
    this.negativeStockPolicy = const Value.absent(),
    this.appLockEnabled = const Value.absent(),
    this.biometricEnabled = const Value.absent(),
    required String deviceId,
    this.onboardingCompletedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<String>? id,
    Expression<int>? singleton,
    Expression<String>? shopName,
    Expression<String>? shopPhone,
    Expression<String>? shopAddress,
    Expression<String>? invoiceFooter,
    Expression<String>? localeCode,
    Expression<String>? digitStyle,
    Expression<String>? negativeStockPolicy,
    Expression<bool>? appLockEnabled,
    Expression<bool>? biometricEnabled,
    Expression<String>? deviceId,
    Expression<int>? onboardingCompletedAt,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (singleton != null) 'singleton': singleton,
      if (shopName != null) 'shop_name': shopName,
      if (shopPhone != null) 'shop_phone': shopPhone,
      if (shopAddress != null) 'shop_address': shopAddress,
      if (invoiceFooter != null) 'invoice_footer': invoiceFooter,
      if (localeCode != null) 'locale_code': localeCode,
      if (digitStyle != null) 'digit_style': digitStyle,
      if (negativeStockPolicy != null)
        'negative_stock_policy': negativeStockPolicy,
      if (appLockEnabled != null) 'app_lock_enabled': appLockEnabled,
      if (biometricEnabled != null) 'biometric_enabled': biometricEnabled,
      if (deviceId != null) 'device_id': deviceId,
      if (onboardingCompletedAt != null)
        'onboarding_completed_at': onboardingCompletedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<int>? singleton,
    Value<String?>? shopName,
    Value<String?>? shopPhone,
    Value<String?>? shopAddress,
    Value<String?>? invoiceFooter,
    Value<LocaleCode>? localeCode,
    Value<DigitStylePreference>? digitStyle,
    Value<NegativeStockPolicy>? negativeStockPolicy,
    Value<bool>? appLockEnabled,
    Value<bool>? biometricEnabled,
    Value<String>? deviceId,
    Value<DateTime?>? onboardingCompletedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      singleton: singleton ?? this.singleton,
      shopName: shopName ?? this.shopName,
      shopPhone: shopPhone ?? this.shopPhone,
      shopAddress: shopAddress ?? this.shopAddress,
      invoiceFooter: invoiceFooter ?? this.invoiceFooter,
      localeCode: localeCode ?? this.localeCode,
      digitStyle: digitStyle ?? this.digitStyle,
      negativeStockPolicy: negativeStockPolicy ?? this.negativeStockPolicy,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      deviceId: deviceId ?? this.deviceId,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (singleton.present) {
      map['singleton'] = Variable<int>(singleton.value);
    }
    if (shopName.present) {
      map['shop_name'] = Variable<String>(shopName.value);
    }
    if (shopPhone.present) {
      map['shop_phone'] = Variable<String>(shopPhone.value);
    }
    if (shopAddress.present) {
      map['shop_address'] = Variable<String>(shopAddress.value);
    }
    if (invoiceFooter.present) {
      map['invoice_footer'] = Variable<String>(invoiceFooter.value);
    }
    if (localeCode.present) {
      map['locale_code'] = Variable<String>(
        $AppSettingsTable.$converterlocaleCode.toSql(localeCode.value),
      );
    }
    if (digitStyle.present) {
      map['digit_style'] = Variable<String>(
        $AppSettingsTable.$converterdigitStyle.toSql(digitStyle.value),
      );
    }
    if (negativeStockPolicy.present) {
      map['negative_stock_policy'] = Variable<String>(
        $AppSettingsTable.$converternegativeStockPolicy.toSql(
          negativeStockPolicy.value,
        ),
      );
    }
    if (appLockEnabled.present) {
      map['app_lock_enabled'] = Variable<bool>(appLockEnabled.value);
    }
    if (biometricEnabled.present) {
      map['biometric_enabled'] = Variable<bool>(biometricEnabled.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (onboardingCompletedAt.present) {
      map['onboarding_completed_at'] = Variable<int>(
        $AppSettingsTable.$converteronboardingCompletedAtn.toSql(
          onboardingCompletedAt.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $AppSettingsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $AppSettingsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('singleton: $singleton, ')
          ..write('shopName: $shopName, ')
          ..write('shopPhone: $shopPhone, ')
          ..write('shopAddress: $shopAddress, ')
          ..write('invoiceFooter: $invoiceFooter, ')
          ..write('localeCode: $localeCode, ')
          ..write('digitStyle: $digitStyle, ')
          ..write('negativeStockPolicy: $negativeStockPolicy, ')
          ..write('appLockEnabled: $appLockEnabled, ')
          ..write('biometricEnabled: $biometricEnabled, ')
          ..write('deviceId: $deviceId, ')
          ..write('onboardingCompletedAt: $onboardingCompletedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountersTable extends Counters
    with TableInfo<$CountersTable, CounterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DocType, String> docType =
      GeneratedColumn<String>(
        'doc_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      ).withConverter<DocType>($CountersTable.$converterdocType);
  static const VerificationMeta _nextValueMeta = const VerificationMeta(
    'nextValue',
  );
  @override
  late final GeneratedColumn<int> nextValue = GeneratedColumn<int>(
    'next_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CountersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CountersTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    docType,
    nextValue,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CounterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('next_value')) {
      context.handle(
        _nextValueMeta,
        nextValue.isAcceptableOrUnknown(data['next_value']!, _nextValueMeta),
      );
    } else if (isInserting) {
      context.missing(_nextValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CounterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CounterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      docType: $CountersTable.$converterdocType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}doc_type'],
        )!,
      ),
      nextValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_value'],
      )!,
      createdAt: $CountersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CountersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $CountersTable createAlias(String alias) {
    return $CountersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DocType, String, String> $converterdocType =
      const EnumNameConverter<DocType>(DocType.values);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
}

class CounterRow extends DataClass implements Insertable<CounterRow> {
  final String id;
  final DocType docType;
  final int nextValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CounterRow({
    required this.id,
    required this.docType,
    required this.nextValue,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['doc_type'] = Variable<String>(
        $CountersTable.$converterdocType.toSql(docType),
      );
    }
    map['next_value'] = Variable<int>(nextValue);
    {
      map['created_at'] = Variable<int>(
        $CountersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CountersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  CountersCompanion toCompanion(bool nullToAbsent) {
    return CountersCompanion(
      id: Value(id),
      docType: Value(docType),
      nextValue: Value(nextValue),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CounterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CounterRow(
      id: serializer.fromJson<String>(json['id']),
      docType: $CountersTable.$converterdocType.fromJson(
        serializer.fromJson<String>(json['docType']),
      ),
      nextValue: serializer.fromJson<int>(json['nextValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'docType': serializer.toJson<String>(
        $CountersTable.$converterdocType.toJson(docType),
      ),
      'nextValue': serializer.toJson<int>(nextValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CounterRow copyWith({
    String? id,
    DocType? docType,
    int? nextValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CounterRow(
    id: id ?? this.id,
    docType: docType ?? this.docType,
    nextValue: nextValue ?? this.nextValue,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CounterRow copyWithCompanion(CountersCompanion data) {
    return CounterRow(
      id: data.id.present ? data.id.value : this.id,
      docType: data.docType.present ? data.docType.value : this.docType,
      nextValue: data.nextValue.present ? data.nextValue.value : this.nextValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CounterRow(')
          ..write('id: $id, ')
          ..write('docType: $docType, ')
          ..write('nextValue: $nextValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, docType, nextValue, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CounterRow &&
          other.id == this.id &&
          other.docType == this.docType &&
          other.nextValue == this.nextValue &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CountersCompanion extends UpdateCompanion<CounterRow> {
  final Value<String> id;
  final Value<DocType> docType;
  final Value<int> nextValue;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CountersCompanion({
    this.id = const Value.absent(),
    this.docType = const Value.absent(),
    this.nextValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountersCompanion.insert({
    required String id,
    required DocType docType,
    required int nextValue,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       docType = Value(docType),
       nextValue = Value(nextValue),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CounterRow> custom({
    Expression<String>? id,
    Expression<String>? docType,
    Expression<int>? nextValue,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (docType != null) 'doc_type': docType,
      if (nextValue != null) 'next_value': nextValue,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountersCompanion copyWith({
    Value<String>? id,
    Value<DocType>? docType,
    Value<int>? nextValue,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CountersCompanion(
      id: id ?? this.id,
      docType: docType ?? this.docType,
      nextValue: nextValue ?? this.nextValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (docType.present) {
      map['doc_type'] = Variable<String>(
        $CountersTable.$converterdocType.toSql(docType.value),
      );
    }
    if (nextValue.present) {
      map['next_value'] = Variable<int>(nextValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $CountersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CountersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CountersCompanion(')
          ..write('id: $id, ')
          ..write('docType: $docType, ')
          ..write('nextValue: $nextValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CategoriesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CategoriesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CategoriesTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    searchKey,
    sortOrder,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: $CategoriesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CategoriesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      archivedAt: $CategoriesTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String searchKey;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.searchKey,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['search_key'] = Variable<String>(searchKey);
    map['sort_order'] = Variable<int>(sortOrder);
    {
      map['created_at'] = Variable<int>(
        $CategoriesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CategoriesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $CategoriesTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      searchKey: Value(searchKey),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'searchKey': serializer.toJson<String>(searchKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    String? searchKey,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    searchKey: searchKey ?? this.searchKey,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    searchKey,
    sortOrder,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.searchKey == this.searchKey &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> searchKey;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String searchKey,
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchKey = Value(searchKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? searchKey,
    Expression<int>? sortOrder,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (searchKey != null) 'search_key': searchKey,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? searchKey,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      searchKey: searchKey ?? this.searchKey,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $CategoriesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CategoriesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $CategoriesTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<UnitType, String> unitType =
      GeneratedColumn<String>(
        'unit_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<UnitType>($ProductsTable.$converterunitType);
  static const VerificationMeta _salePricePiastersMeta = const VerificationMeta(
    'salePricePiasters',
  );
  @override
  late final GeneratedColumn<int> salePricePiasters = GeneratedColumn<int>(
    'sale_price_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgCostPiastersMeta = const VerificationMeta(
    'avgCostPiasters',
  );
  @override
  late final GeneratedColumn<int> avgCostPiasters = GeneratedColumn<int>(
    'avg_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lowStockThresholdMilliMeta =
      const VerificationMeta('lowStockThresholdMilli');
  @override
  late final GeneratedColumn<int> lowStockThresholdMilli = GeneratedColumn<int>(
    'low_stock_threshold_milli',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProductsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ProductsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ProductsTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    searchKey,
    barcode,
    sku,
    unitType,
    salePricePiasters,
    avgCostPiasters,
    lowStockThresholdMilli,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('sale_price_piasters')) {
      context.handle(
        _salePricePiastersMeta,
        salePricePiasters.isAcceptableOrUnknown(
          data['sale_price_piasters']!,
          _salePricePiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salePricePiastersMeta);
    }
    if (data.containsKey('avg_cost_piasters')) {
      context.handle(
        _avgCostPiastersMeta,
        avgCostPiasters.isAcceptableOrUnknown(
          data['avg_cost_piasters']!,
          _avgCostPiastersMeta,
        ),
      );
    }
    if (data.containsKey('low_stock_threshold_milli')) {
      context.handle(
        _lowStockThresholdMilliMeta,
        lowStockThresholdMilli.isAcceptableOrUnknown(
          data['low_stock_threshold_milli']!,
          _lowStockThresholdMilliMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      unitType: $ProductsTable.$converterunitType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit_type'],
        )!,
      ),
      salePricePiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_price_piasters'],
      )!,
      avgCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cost_piasters'],
      )!,
      lowStockThresholdMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_stock_threshold_milli'],
      ),
      createdAt: $ProductsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ProductsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      archivedAt: $ProductsTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UnitType, String, String> $converterunitType =
      const EnumNameConverter<UnitType>(UnitType.values);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String? categoryId;
  final String name;
  final String searchKey;
  final String? barcode;
  final String? sku;
  final UnitType unitType;
  final int salePricePiasters;
  final int avgCostPiasters;
  final int? lowStockThresholdMilli;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const ProductRow({
    required this.id,
    this.categoryId,
    required this.name,
    required this.searchKey,
    this.barcode,
    this.sku,
    required this.unitType,
    required this.salePricePiasters,
    required this.avgCostPiasters,
    this.lowStockThresholdMilli,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['name'] = Variable<String>(name);
    map['search_key'] = Variable<String>(searchKey);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    {
      map['unit_type'] = Variable<String>(
        $ProductsTable.$converterunitType.toSql(unitType),
      );
    }
    map['sale_price_piasters'] = Variable<int>(salePricePiasters);
    map['avg_cost_piasters'] = Variable<int>(avgCostPiasters);
    if (!nullToAbsent || lowStockThresholdMilli != null) {
      map['low_stock_threshold_milli'] = Variable<int>(lowStockThresholdMilli);
    }
    {
      map['created_at'] = Variable<int>(
        $ProductsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $ProductsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $ProductsTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      name: Value(name),
      searchKey: Value(searchKey),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      unitType: Value(unitType),
      salePricePiasters: Value(salePricePiasters),
      avgCostPiasters: Value(avgCostPiasters),
      lowStockThresholdMilli: lowStockThresholdMilli == null && nullToAbsent
          ? const Value.absent()
          : Value(lowStockThresholdMilli),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      sku: serializer.fromJson<String?>(json['sku']),
      unitType: $ProductsTable.$converterunitType.fromJson(
        serializer.fromJson<String>(json['unitType']),
      ),
      salePricePiasters: serializer.fromJson<int>(json['salePricePiasters']),
      avgCostPiasters: serializer.fromJson<int>(json['avgCostPiasters']),
      lowStockThresholdMilli: serializer.fromJson<int?>(
        json['lowStockThresholdMilli'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String?>(categoryId),
      'name': serializer.toJson<String>(name),
      'searchKey': serializer.toJson<String>(searchKey),
      'barcode': serializer.toJson<String?>(barcode),
      'sku': serializer.toJson<String?>(sku),
      'unitType': serializer.toJson<String>(
        $ProductsTable.$converterunitType.toJson(unitType),
      ),
      'salePricePiasters': serializer.toJson<int>(salePricePiasters),
      'avgCostPiasters': serializer.toJson<int>(avgCostPiasters),
      'lowStockThresholdMilli': serializer.toJson<int?>(lowStockThresholdMilli),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ProductRow copyWith({
    String? id,
    Value<String?> categoryId = const Value.absent(),
    String? name,
    String? searchKey,
    Value<String?> barcode = const Value.absent(),
    Value<String?> sku = const Value.absent(),
    UnitType? unitType,
    int? salePricePiasters,
    int? avgCostPiasters,
    Value<int?> lowStockThresholdMilli = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ProductRow(
    id: id ?? this.id,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    name: name ?? this.name,
    searchKey: searchKey ?? this.searchKey,
    barcode: barcode.present ? barcode.value : this.barcode,
    sku: sku.present ? sku.value : this.sku,
    unitType: unitType ?? this.unitType,
    salePricePiasters: salePricePiasters ?? this.salePricePiasters,
    avgCostPiasters: avgCostPiasters ?? this.avgCostPiasters,
    lowStockThresholdMilli: lowStockThresholdMilli.present
        ? lowStockThresholdMilli.value
        : this.lowStockThresholdMilli,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      sku: data.sku.present ? data.sku.value : this.sku,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      salePricePiasters: data.salePricePiasters.present
          ? data.salePricePiasters.value
          : this.salePricePiasters,
      avgCostPiasters: data.avgCostPiasters.present
          ? data.avgCostPiasters.value
          : this.avgCostPiasters,
      lowStockThresholdMilli: data.lowStockThresholdMilli.present
          ? data.lowStockThresholdMilli.value
          : this.lowStockThresholdMilli,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku, ')
          ..write('unitType: $unitType, ')
          ..write('salePricePiasters: $salePricePiasters, ')
          ..write('avgCostPiasters: $avgCostPiasters, ')
          ..write('lowStockThresholdMilli: $lowStockThresholdMilli, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    searchKey,
    barcode,
    sku,
    unitType,
    salePricePiasters,
    avgCostPiasters,
    lowStockThresholdMilli,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.searchKey == this.searchKey &&
          other.barcode == this.barcode &&
          other.sku == this.sku &&
          other.unitType == this.unitType &&
          other.salePricePiasters == this.salePricePiasters &&
          other.avgCostPiasters == this.avgCostPiasters &&
          other.lowStockThresholdMilli == this.lowStockThresholdMilli &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String?> categoryId;
  final Value<String> name;
  final Value<String> searchKey;
  final Value<String?> barcode;
  final Value<String?> sku;
  final Value<UnitType> unitType;
  final Value<int> salePricePiasters;
  final Value<int> avgCostPiasters;
  final Value<int?> lowStockThresholdMilli;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.barcode = const Value.absent(),
    this.sku = const Value.absent(),
    this.unitType = const Value.absent(),
    this.salePricePiasters = const Value.absent(),
    this.avgCostPiasters = const Value.absent(),
    this.lowStockThresholdMilli = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    this.categoryId = const Value.absent(),
    required String name,
    required String searchKey,
    this.barcode = const Value.absent(),
    this.sku = const Value.absent(),
    required UnitType unitType,
    required int salePricePiasters,
    this.avgCostPiasters = const Value.absent(),
    this.lowStockThresholdMilli = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchKey = Value(searchKey),
       unitType = Value(unitType),
       salePricePiasters = Value(salePricePiasters),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? searchKey,
    Expression<String>? barcode,
    Expression<String>? sku,
    Expression<String>? unitType,
    Expression<int>? salePricePiasters,
    Expression<int>? avgCostPiasters,
    Expression<int>? lowStockThresholdMilli,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (searchKey != null) 'search_key': searchKey,
      if (barcode != null) 'barcode': barcode,
      if (sku != null) 'sku': sku,
      if (unitType != null) 'unit_type': unitType,
      if (salePricePiasters != null) 'sale_price_piasters': salePricePiasters,
      if (avgCostPiasters != null) 'avg_cost_piasters': avgCostPiasters,
      if (lowStockThresholdMilli != null)
        'low_stock_threshold_milli': lowStockThresholdMilli,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String?>? categoryId,
    Value<String>? name,
    Value<String>? searchKey,
    Value<String?>? barcode,
    Value<String?>? sku,
    Value<UnitType>? unitType,
    Value<int>? salePricePiasters,
    Value<int>? avgCostPiasters,
    Value<int?>? lowStockThresholdMilli,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      searchKey: searchKey ?? this.searchKey,
      barcode: barcode ?? this.barcode,
      sku: sku ?? this.sku,
      unitType: unitType ?? this.unitType,
      salePricePiasters: salePricePiasters ?? this.salePricePiasters,
      avgCostPiasters: avgCostPiasters ?? this.avgCostPiasters,
      lowStockThresholdMilli:
          lowStockThresholdMilli ?? this.lowStockThresholdMilli,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(
        $ProductsTable.$converterunitType.toSql(unitType.value),
      );
    }
    if (salePricePiasters.present) {
      map['sale_price_piasters'] = Variable<int>(salePricePiasters.value);
    }
    if (avgCostPiasters.present) {
      map['avg_cost_piasters'] = Variable<int>(avgCostPiasters.value);
    }
    if (lowStockThresholdMilli.present) {
      map['low_stock_threshold_milli'] = Variable<int>(
        lowStockThresholdMilli.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ProductsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ProductsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $ProductsTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('barcode: $barcode, ')
          ..write('sku: $sku, ')
          ..write('unitType: $unitType, ')
          ..write('salePricePiasters: $salePricePiasters, ')
          ..write('avgCostPiasters: $avgCostPiasters, ')
          ..write('lowStockThresholdMilli: $lowStockThresholdMilli, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CustomersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CustomersTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CustomersTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    searchKey,
    phone,
    address,
    note,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $CustomersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CustomersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      archivedAt: $CustomersTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String name;
  final String searchKey;
  final String? phone;
  final String? address;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const CustomerRow({
    required this.id,
    required this.name,
    required this.searchKey,
    this.phone,
    this.address,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['search_key'] = Variable<String>(searchKey);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $CustomersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CustomersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $CustomersTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      searchKey: Value(searchKey),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'searchKey': serializer.toJson<String>(searchKey),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  CustomerRow copyWith({
    String? id,
    String? name,
    String? searchKey,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => CustomerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    searchKey: searchKey ?? this.searchKey,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    searchKey,
    phone,
    address,
    note,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.searchKey == this.searchKey &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> searchKey;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    required String searchKey,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchKey = Value(searchKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? searchKey,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (searchKey != null) 'search_key': searchKey,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? searchKey,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      searchKey: searchKey ?? this.searchKey,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $CustomersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CustomersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $CustomersTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, SupplierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SuppliersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SuppliersTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SuppliersTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    searchKey,
    phone,
    address,
    note,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $SuppliersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $SuppliersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      archivedAt: $SuppliersTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class SupplierRow extends DataClass implements Insertable<SupplierRow> {
  final String id;
  final String name;
  final String searchKey;
  final String? phone;
  final String? address;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const SupplierRow({
    required this.id,
    required this.name,
    required this.searchKey,
    this.phone,
    this.address,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['search_key'] = Variable<String>(searchKey);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $SuppliersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $SuppliersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $SuppliersTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      searchKey: Value(searchKey),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory SupplierRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'searchKey': serializer.toJson<String>(searchKey),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  SupplierRow copyWith({
    String? id,
    String? name,
    String? searchKey,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => SupplierRow(
    id: id ?? this.id,
    name: name ?? this.name,
    searchKey: searchKey ?? this.searchKey,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  SupplierRow copyWithCompanion(SuppliersCompanion data) {
    return SupplierRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    searchKey,
    phone,
    address,
    note,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.searchKey == this.searchKey &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class SuppliersCompanion extends UpdateCompanion<SupplierRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> searchKey;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String name,
    required String searchKey,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchKey = Value(searchKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SupplierRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? searchKey,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (searchKey != null) 'search_key': searchKey,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? searchKey,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      searchKey: searchKey ?? this.searchKey,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SuppliersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $SuppliersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $SuppliersTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchKeyMeta = const VerificationMeta(
    'searchKey',
  );
  @override
  late final GeneratedColumn<String> searchKey = GeneratedColumn<String>(
    'search_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExpenseCategoriesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExpenseCategoriesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ExpenseCategoriesTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    searchKey,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_key')) {
      context.handle(
        _searchKeyMeta,
        searchKey.isAcceptableOrUnknown(data['search_key']!, _searchKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_searchKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      searchKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_key'],
      )!,
      createdAt: $ExpenseCategoriesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ExpenseCategoriesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      archivedAt: $ExpenseCategoriesTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class ExpenseCategoryRow extends DataClass
    implements Insertable<ExpenseCategoryRow> {
  final String id;
  final String name;
  final String searchKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  const ExpenseCategoryRow({
    required this.id,
    required this.name,
    required this.searchKey,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['search_key'] = Variable<String>(searchKey);
    {
      map['created_at'] = Variable<int>(
        $ExpenseCategoriesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $ExpenseCategoriesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $ExpenseCategoriesTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      searchKey: Value(searchKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory ExpenseCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      searchKey: serializer.fromJson<String>(json['searchKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'searchKey': serializer.toJson<String>(searchKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  ExpenseCategoryRow copyWith({
    String? id,
    String? name,
    String? searchKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => ExpenseCategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    searchKey: searchKey ?? this.searchKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  ExpenseCategoryRow copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      searchKey: data.searchKey.present ? data.searchKey.value : this.searchKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, searchKey, createdAt, updatedAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.searchKey == this.searchKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> searchKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.searchKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    required String id,
    required String name,
    required String searchKey,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       searchKey = Value(searchKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseCategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? searchKey,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (searchKey != null) 'search_key': searchKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? searchKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      searchKey: searchKey ?? this.searchKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchKey.present) {
      map['search_key'] = Variable<String>(searchKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ExpenseCategoriesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ExpenseCategoriesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $ExpenseCategoriesTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('searchKey: $searchKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesInvoicesTable extends SalesInvoices
    with TableInfo<$SalesInvoicesTable, SalesInvoiceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _subtotalPiastersMeta = const VerificationMeta(
    'subtotalPiasters',
  );
  @override
  late final GeneratedColumn<int> subtotalPiasters = GeneratedColumn<int>(
    'subtotal_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPiastersMeta = const VerificationMeta(
    'discountPiasters',
  );
  @override
  late final GeneratedColumn<int> discountPiasters = GeneratedColumn<int>(
    'discount_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPiastersMeta = const VerificationMeta(
    'totalPiasters',
  );
  @override
  late final GeneratedColumn<int> totalPiasters = GeneratedColumn<int>(
    'total_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAtSalePiastersMeta =
      const VerificationMeta('paidAtSalePiasters');
  @override
  late final GeneratedColumn<int> paidAtSalePiasters = GeneratedColumn<int>(
    'paid_at_sale_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  ).withConverter<PaymentMethod>($SalesInvoicesTable.$converterpaymentMethod);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SalesInvoicesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SalesInvoicesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> voidedAt =
      GeneratedColumn<int>(
        'voided_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SalesInvoicesTable.$convertervoidedAtn);
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    customerId,
    subtotalPiasters,
    discountPiasters,
    totalPiasters,
    paidAtSalePiasters,
    paymentMethod,
    note,
    createdAt,
    updatedAt,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalesInvoiceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('subtotal_piasters')) {
      context.handle(
        _subtotalPiastersMeta,
        subtotalPiasters.isAcceptableOrUnknown(
          data['subtotal_piasters']!,
          _subtotalPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalPiastersMeta);
    }
    if (data.containsKey('discount_piasters')) {
      context.handle(
        _discountPiastersMeta,
        discountPiasters.isAcceptableOrUnknown(
          data['discount_piasters']!,
          _discountPiastersMeta,
        ),
      );
    }
    if (data.containsKey('total_piasters')) {
      context.handle(
        _totalPiastersMeta,
        totalPiasters.isAcceptableOrUnknown(
          data['total_piasters']!,
          _totalPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPiastersMeta);
    }
    if (data.containsKey('paid_at_sale_piasters')) {
      context.handle(
        _paidAtSalePiastersMeta,
        paidAtSalePiasters.isAcceptableOrUnknown(
          data['paid_at_sale_piasters']!,
          _paidAtSalePiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paidAtSalePiastersMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesInvoiceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesInvoiceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      subtotalPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_piasters'],
      )!,
      discountPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_piasters'],
      )!,
      totalPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_piasters'],
      )!,
      paidAtSalePiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_at_sale_piasters'],
      )!,
      paymentMethod: $SalesInvoicesTable.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $SalesInvoicesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $SalesInvoicesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      voidedAt: $SalesInvoicesTable.$convertervoidedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}voided_at'],
        ),
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $SalesInvoicesTable createAlias(String alias) {
    return $SalesInvoicesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $convertervoidedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $convertervoidedAtn =
      NullAwareTypeConverter.wrap($convertervoidedAt);
}

class SalesInvoiceRow extends DataClass implements Insertable<SalesInvoiceRow> {
  final String id;
  final int number;
  final String? customerId;
  final int subtotalPiasters;
  final int discountPiasters;
  final int totalPiasters;
  final int paidAtSalePiasters;
  final PaymentMethod paymentMethod;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? voidedAt;
  final String? voidReason;
  const SalesInvoiceRow({
    required this.id,
    required this.number,
    this.customerId,
    required this.subtotalPiasters,
    required this.discountPiasters,
    required this.totalPiasters,
    required this.paidAtSalePiasters,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['number'] = Variable<int>(number);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['subtotal_piasters'] = Variable<int>(subtotalPiasters);
    map['discount_piasters'] = Variable<int>(discountPiasters);
    map['total_piasters'] = Variable<int>(totalPiasters);
    map['paid_at_sale_piasters'] = Variable<int>(paidAtSalePiasters);
    {
      map['payment_method'] = Variable<String>(
        $SalesInvoicesTable.$converterpaymentMethod.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $SalesInvoicesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $SalesInvoicesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<int>(
        $SalesInvoicesTable.$convertervoidedAtn.toSql(voidedAt),
      );
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  SalesInvoicesCompanion toCompanion(bool nullToAbsent) {
    return SalesInvoicesCompanion(
      id: Value(id),
      number: Value(number),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      subtotalPiasters: Value(subtotalPiasters),
      discountPiasters: Value(discountPiasters),
      totalPiasters: Value(totalPiasters),
      paidAtSalePiasters: Value(paidAtSalePiasters),
      paymentMethod: Value(paymentMethod),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory SalesInvoiceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesInvoiceRow(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      subtotalPiasters: serializer.fromJson<int>(json['subtotalPiasters']),
      discountPiasters: serializer.fromJson<int>(json['discountPiasters']),
      totalPiasters: serializer.fromJson<int>(json['totalPiasters']),
      paidAtSalePiasters: serializer.fromJson<int>(json['paidAtSalePiasters']),
      paymentMethod: $SalesInvoicesTable.$converterpaymentMethod.fromJson(
        serializer.fromJson<String>(json['paymentMethod']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<int>(number),
      'customerId': serializer.toJson<String?>(customerId),
      'subtotalPiasters': serializer.toJson<int>(subtotalPiasters),
      'discountPiasters': serializer.toJson<int>(discountPiasters),
      'totalPiasters': serializer.toJson<int>(totalPiasters),
      'paidAtSalePiasters': serializer.toJson<int>(paidAtSalePiasters),
      'paymentMethod': serializer.toJson<String>(
        $SalesInvoicesTable.$converterpaymentMethod.toJson(paymentMethod),
      ),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  SalesInvoiceRow copyWith({
    String? id,
    int? number,
    Value<String?> customerId = const Value.absent(),
    int? subtotalPiasters,
    int? discountPiasters,
    int? totalPiasters,
    int? paidAtSalePiasters,
    PaymentMethod? paymentMethod,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => SalesInvoiceRow(
    id: id ?? this.id,
    number: number ?? this.number,
    customerId: customerId.present ? customerId.value : this.customerId,
    subtotalPiasters: subtotalPiasters ?? this.subtotalPiasters,
    discountPiasters: discountPiasters ?? this.discountPiasters,
    totalPiasters: totalPiasters ?? this.totalPiasters,
    paidAtSalePiasters: paidAtSalePiasters ?? this.paidAtSalePiasters,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  SalesInvoiceRow copyWithCompanion(SalesInvoicesCompanion data) {
    return SalesInvoiceRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      subtotalPiasters: data.subtotalPiasters.present
          ? data.subtotalPiasters.value
          : this.subtotalPiasters,
      discountPiasters: data.discountPiasters.present
          ? data.discountPiasters.value
          : this.discountPiasters,
      totalPiasters: data.totalPiasters.present
          ? data.totalPiasters.value
          : this.totalPiasters,
      paidAtSalePiasters: data.paidAtSalePiasters.present
          ? data.paidAtSalePiasters.value
          : this.paidAtSalePiasters,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesInvoiceRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('customerId: $customerId, ')
          ..write('subtotalPiasters: $subtotalPiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('totalPiasters: $totalPiasters, ')
          ..write('paidAtSalePiasters: $paidAtSalePiasters, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    customerId,
    subtotalPiasters,
    discountPiasters,
    totalPiasters,
    paidAtSalePiasters,
    paymentMethod,
    note,
    createdAt,
    updatedAt,
    voidedAt,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesInvoiceRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.customerId == this.customerId &&
          other.subtotalPiasters == this.subtotalPiasters &&
          other.discountPiasters == this.discountPiasters &&
          other.totalPiasters == this.totalPiasters &&
          other.paidAtSalePiasters == this.paidAtSalePiasters &&
          other.paymentMethod == this.paymentMethod &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class SalesInvoicesCompanion extends UpdateCompanion<SalesInvoiceRow> {
  final Value<String> id;
  final Value<int> number;
  final Value<String?> customerId;
  final Value<int> subtotalPiasters;
  final Value<int> discountPiasters;
  final Value<int> totalPiasters;
  final Value<int> paidAtSalePiasters;
  final Value<PaymentMethod> paymentMethod;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const SalesInvoicesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.customerId = const Value.absent(),
    this.subtotalPiasters = const Value.absent(),
    this.discountPiasters = const Value.absent(),
    this.totalPiasters = const Value.absent(),
    this.paidAtSalePiasters = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesInvoicesCompanion.insert({
    required String id,
    required int number,
    this.customerId = const Value.absent(),
    required int subtotalPiasters,
    this.discountPiasters = const Value.absent(),
    required int totalPiasters,
    required int paidAtSalePiasters,
    this.paymentMethod = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       number = Value(number),
       subtotalPiasters = Value(subtotalPiasters),
       totalPiasters = Value(totalPiasters),
       paidAtSalePiasters = Value(paidAtSalePiasters),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SalesInvoiceRow> custom({
    Expression<String>? id,
    Expression<int>? number,
    Expression<String>? customerId,
    Expression<int>? subtotalPiasters,
    Expression<int>? discountPiasters,
    Expression<int>? totalPiasters,
    Expression<int>? paidAtSalePiasters,
    Expression<String>? paymentMethod,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (customerId != null) 'customer_id': customerId,
      if (subtotalPiasters != null) 'subtotal_piasters': subtotalPiasters,
      if (discountPiasters != null) 'discount_piasters': discountPiasters,
      if (totalPiasters != null) 'total_piasters': totalPiasters,
      if (paidAtSalePiasters != null)
        'paid_at_sale_piasters': paidAtSalePiasters,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesInvoicesCompanion copyWith({
    Value<String>? id,
    Value<int>? number,
    Value<String?>? customerId,
    Value<int>? subtotalPiasters,
    Value<int>? discountPiasters,
    Value<int>? totalPiasters,
    Value<int>? paidAtSalePiasters,
    Value<PaymentMethod>? paymentMethod,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return SalesInvoicesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      customerId: customerId ?? this.customerId,
      subtotalPiasters: subtotalPiasters ?? this.subtotalPiasters,
      discountPiasters: discountPiasters ?? this.discountPiasters,
      totalPiasters: totalPiasters ?? this.totalPiasters,
      paidAtSalePiasters: paidAtSalePiasters ?? this.paidAtSalePiasters,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (subtotalPiasters.present) {
      map['subtotal_piasters'] = Variable<int>(subtotalPiasters.value);
    }
    if (discountPiasters.present) {
      map['discount_piasters'] = Variable<int>(discountPiasters.value);
    }
    if (totalPiasters.present) {
      map['total_piasters'] = Variable<int>(totalPiasters.value);
    }
    if (paidAtSalePiasters.present) {
      map['paid_at_sale_piasters'] = Variable<int>(paidAtSalePiasters.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $SalesInvoicesTable.$converterpaymentMethod.toSql(paymentMethod.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SalesInvoicesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $SalesInvoicesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<int>(
        $SalesInvoicesTable.$convertervoidedAtn.toSql(voidedAt.value),
      );
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('customerId: $customerId, ')
          ..write('subtotalPiasters: $subtotalPiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('totalPiasters: $totalPiasters, ')
          ..write('paidAtSalePiasters: $paidAtSalePiasters, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salesInvoiceIdMeta = const VerificationMeta(
    'salesInvoiceId',
  );
  @override
  late final GeneratedColumn<String> salesInvoiceId = GeneratedColumn<String>(
    'sales_invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales_invoices (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
    'line_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<UnitType, String>
  unitTypeSnapshot = GeneratedColumn<String>(
    'unit_type_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<UnitType>($SaleItemsTable.$converterunitTypeSnapshot);
  static const VerificationMeta _qtyMilliMeta = const VerificationMeta(
    'qtyMilli',
  );
  @override
  late final GeneratedColumn<int> qtyMilli = GeneratedColumn<int>(
    'qty_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPricePiastersMeta = const VerificationMeta(
    'unitPricePiasters',
  );
  @override
  late final GeneratedColumn<int> unitPricePiasters = GeneratedColumn<int>(
    'unit_price_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPiastersMeta = const VerificationMeta(
    'discountPiasters',
  );
  @override
  late final GeneratedColumn<int> discountPiasters = GeneratedColumn<int>(
    'discount_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalPiastersMeta = const VerificationMeta(
    'lineTotalPiasters',
  );
  @override
  late final GeneratedColumn<int> lineTotalPiasters = GeneratedColumn<int>(
    'line_total_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceDiscountSharePiastersMeta =
      const VerificationMeta('invoiceDiscountSharePiasters');
  @override
  late final GeneratedColumn<int> invoiceDiscountSharePiasters =
      GeneratedColumn<int>(
        'invoice_discount_share_piasters',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _unitCostPiastersMeta = const VerificationMeta(
    'unitCostPiasters',
  );
  @override
  late final GeneratedColumn<int> unitCostPiasters = GeneratedColumn<int>(
    'unit_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineCostPiastersMeta = const VerificationMeta(
    'lineCostPiasters',
  );
  @override
  late final GeneratedColumn<int> lineCostPiasters = GeneratedColumn<int>(
    'line_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    salesInvoiceId,
    lineNo,
    productId,
    productNameSnapshot,
    unitTypeSnapshot,
    qtyMilli,
    unitPricePiasters,
    discountPiasters,
    lineTotalPiasters,
    invoiceDiscountSharePiasters,
    unitCostPiasters,
    lineCostPiasters,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sales_invoice_id')) {
      context.handle(
        _salesInvoiceIdMeta,
        salesInvoiceId.isAcceptableOrUnknown(
          data['sales_invoice_id']!,
          _salesInvoiceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salesInvoiceIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(
        _lineNoMeta,
        lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('qty_milli')) {
      context.handle(
        _qtyMilliMeta,
        qtyMilli.isAcceptableOrUnknown(data['qty_milli']!, _qtyMilliMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMilliMeta);
    }
    if (data.containsKey('unit_price_piasters')) {
      context.handle(
        _unitPricePiastersMeta,
        unitPricePiasters.isAcceptableOrUnknown(
          data['unit_price_piasters']!,
          _unitPricePiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPricePiastersMeta);
    }
    if (data.containsKey('discount_piasters')) {
      context.handle(
        _discountPiastersMeta,
        discountPiasters.isAcceptableOrUnknown(
          data['discount_piasters']!,
          _discountPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountPiastersMeta);
    }
    if (data.containsKey('line_total_piasters')) {
      context.handle(
        _lineTotalPiastersMeta,
        lineTotalPiasters.isAcceptableOrUnknown(
          data['line_total_piasters']!,
          _lineTotalPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalPiastersMeta);
    }
    if (data.containsKey('invoice_discount_share_piasters')) {
      context.handle(
        _invoiceDiscountSharePiastersMeta,
        invoiceDiscountSharePiasters.isAcceptableOrUnknown(
          data['invoice_discount_share_piasters']!,
          _invoiceDiscountSharePiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDiscountSharePiastersMeta);
    }
    if (data.containsKey('unit_cost_piasters')) {
      context.handle(
        _unitCostPiastersMeta,
        unitCostPiasters.isAcceptableOrUnknown(
          data['unit_cost_piasters']!,
          _unitCostPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostPiastersMeta);
    }
    if (data.containsKey('line_cost_piasters')) {
      context.handle(
        _lineCostPiastersMeta,
        lineCostPiasters.isAcceptableOrUnknown(
          data['line_cost_piasters']!,
          _lineCostPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineCostPiastersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {salesInvoiceId, lineNo},
  ];
  @override
  SaleItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      salesInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sales_invoice_id'],
      )!,
      lineNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_no'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      unitTypeSnapshot: $SaleItemsTable.$converterunitTypeSnapshot.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit_type_snapshot'],
        )!,
      ),
      qtyMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_milli'],
      )!,
      unitPricePiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_piasters'],
      )!,
      discountPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_piasters'],
      )!,
      lineTotalPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_piasters'],
      )!,
      invoiceDiscountSharePiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_discount_share_piasters'],
      )!,
      unitCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_piasters'],
      )!,
      lineCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_cost_piasters'],
      )!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UnitType, String, String>
  $converterunitTypeSnapshot = const EnumNameConverter<UnitType>(
    UnitType.values,
  );
}

class SaleItemRow extends DataClass implements Insertable<SaleItemRow> {
  final String id;
  final String salesInvoiceId;
  final int lineNo;
  final String productId;
  final String productNameSnapshot;
  final UnitType unitTypeSnapshot;
  final int qtyMilli;
  final int unitPricePiasters;
  final int discountPiasters;
  final int lineTotalPiasters;
  final int invoiceDiscountSharePiasters;
  final int unitCostPiasters;
  final int lineCostPiasters;
  const SaleItemRow({
    required this.id,
    required this.salesInvoiceId,
    required this.lineNo,
    required this.productId,
    required this.productNameSnapshot,
    required this.unitTypeSnapshot,
    required this.qtyMilli,
    required this.unitPricePiasters,
    required this.discountPiasters,
    required this.lineTotalPiasters,
    required this.invoiceDiscountSharePiasters,
    required this.unitCostPiasters,
    required this.lineCostPiasters,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sales_invoice_id'] = Variable<String>(salesInvoiceId);
    map['line_no'] = Variable<int>(lineNo);
    map['product_id'] = Variable<String>(productId);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    {
      map['unit_type_snapshot'] = Variable<String>(
        $SaleItemsTable.$converterunitTypeSnapshot.toSql(unitTypeSnapshot),
      );
    }
    map['qty_milli'] = Variable<int>(qtyMilli);
    map['unit_price_piasters'] = Variable<int>(unitPricePiasters);
    map['discount_piasters'] = Variable<int>(discountPiasters);
    map['line_total_piasters'] = Variable<int>(lineTotalPiasters);
    map['invoice_discount_share_piasters'] = Variable<int>(
      invoiceDiscountSharePiasters,
    );
    map['unit_cost_piasters'] = Variable<int>(unitCostPiasters);
    map['line_cost_piasters'] = Variable<int>(lineCostPiasters);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      salesInvoiceId: Value(salesInvoiceId),
      lineNo: Value(lineNo),
      productId: Value(productId),
      productNameSnapshot: Value(productNameSnapshot),
      unitTypeSnapshot: Value(unitTypeSnapshot),
      qtyMilli: Value(qtyMilli),
      unitPricePiasters: Value(unitPricePiasters),
      discountPiasters: Value(discountPiasters),
      lineTotalPiasters: Value(lineTotalPiasters),
      invoiceDiscountSharePiasters: Value(invoiceDiscountSharePiasters),
      unitCostPiasters: Value(unitCostPiasters),
      lineCostPiasters: Value(lineCostPiasters),
    );
  }

  factory SaleItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItemRow(
      id: serializer.fromJson<String>(json['id']),
      salesInvoiceId: serializer.fromJson<String>(json['salesInvoiceId']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
      productId: serializer.fromJson<String>(json['productId']),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      unitTypeSnapshot: $SaleItemsTable.$converterunitTypeSnapshot.fromJson(
        serializer.fromJson<String>(json['unitTypeSnapshot']),
      ),
      qtyMilli: serializer.fromJson<int>(json['qtyMilli']),
      unitPricePiasters: serializer.fromJson<int>(json['unitPricePiasters']),
      discountPiasters: serializer.fromJson<int>(json['discountPiasters']),
      lineTotalPiasters: serializer.fromJson<int>(json['lineTotalPiasters']),
      invoiceDiscountSharePiasters: serializer.fromJson<int>(
        json['invoiceDiscountSharePiasters'],
      ),
      unitCostPiasters: serializer.fromJson<int>(json['unitCostPiasters']),
      lineCostPiasters: serializer.fromJson<int>(json['lineCostPiasters']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'salesInvoiceId': serializer.toJson<String>(salesInvoiceId),
      'lineNo': serializer.toJson<int>(lineNo),
      'productId': serializer.toJson<String>(productId),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'unitTypeSnapshot': serializer.toJson<String>(
        $SaleItemsTable.$converterunitTypeSnapshot.toJson(unitTypeSnapshot),
      ),
      'qtyMilli': serializer.toJson<int>(qtyMilli),
      'unitPricePiasters': serializer.toJson<int>(unitPricePiasters),
      'discountPiasters': serializer.toJson<int>(discountPiasters),
      'lineTotalPiasters': serializer.toJson<int>(lineTotalPiasters),
      'invoiceDiscountSharePiasters': serializer.toJson<int>(
        invoiceDiscountSharePiasters,
      ),
      'unitCostPiasters': serializer.toJson<int>(unitCostPiasters),
      'lineCostPiasters': serializer.toJson<int>(lineCostPiasters),
    };
  }

  SaleItemRow copyWith({
    String? id,
    String? salesInvoiceId,
    int? lineNo,
    String? productId,
    String? productNameSnapshot,
    UnitType? unitTypeSnapshot,
    int? qtyMilli,
    int? unitPricePiasters,
    int? discountPiasters,
    int? lineTotalPiasters,
    int? invoiceDiscountSharePiasters,
    int? unitCostPiasters,
    int? lineCostPiasters,
  }) => SaleItemRow(
    id: id ?? this.id,
    salesInvoiceId: salesInvoiceId ?? this.salesInvoiceId,
    lineNo: lineNo ?? this.lineNo,
    productId: productId ?? this.productId,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    unitTypeSnapshot: unitTypeSnapshot ?? this.unitTypeSnapshot,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    unitPricePiasters: unitPricePiasters ?? this.unitPricePiasters,
    discountPiasters: discountPiasters ?? this.discountPiasters,
    lineTotalPiasters: lineTotalPiasters ?? this.lineTotalPiasters,
    invoiceDiscountSharePiasters:
        invoiceDiscountSharePiasters ?? this.invoiceDiscountSharePiasters,
    unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
    lineCostPiasters: lineCostPiasters ?? this.lineCostPiasters,
  );
  SaleItemRow copyWithCompanion(SaleItemsCompanion data) {
    return SaleItemRow(
      id: data.id.present ? data.id.value : this.id,
      salesInvoiceId: data.salesInvoiceId.present
          ? data.salesInvoiceId.value
          : this.salesInvoiceId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      productId: data.productId.present ? data.productId.value : this.productId,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      unitTypeSnapshot: data.unitTypeSnapshot.present
          ? data.unitTypeSnapshot.value
          : this.unitTypeSnapshot,
      qtyMilli: data.qtyMilli.present ? data.qtyMilli.value : this.qtyMilli,
      unitPricePiasters: data.unitPricePiasters.present
          ? data.unitPricePiasters.value
          : this.unitPricePiasters,
      discountPiasters: data.discountPiasters.present
          ? data.discountPiasters.value
          : this.discountPiasters,
      lineTotalPiasters: data.lineTotalPiasters.present
          ? data.lineTotalPiasters.value
          : this.lineTotalPiasters,
      invoiceDiscountSharePiasters: data.invoiceDiscountSharePiasters.present
          ? data.invoiceDiscountSharePiasters.value
          : this.invoiceDiscountSharePiasters,
      unitCostPiasters: data.unitCostPiasters.present
          ? data.unitCostPiasters.value
          : this.unitCostPiasters,
      lineCostPiasters: data.lineCostPiasters.present
          ? data.lineCostPiasters.value
          : this.lineCostPiasters,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemRow(')
          ..write('id: $id, ')
          ..write('salesInvoiceId: $salesInvoiceId, ')
          ..write('lineNo: $lineNo, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('unitTypeSnapshot: $unitTypeSnapshot, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unitPricePiasters: $unitPricePiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('lineTotalPiasters: $lineTotalPiasters, ')
          ..write(
            'invoiceDiscountSharePiasters: $invoiceDiscountSharePiasters, ',
          )
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('lineCostPiasters: $lineCostPiasters')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    salesInvoiceId,
    lineNo,
    productId,
    productNameSnapshot,
    unitTypeSnapshot,
    qtyMilli,
    unitPricePiasters,
    discountPiasters,
    lineTotalPiasters,
    invoiceDiscountSharePiasters,
    unitCostPiasters,
    lineCostPiasters,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItemRow &&
          other.id == this.id &&
          other.salesInvoiceId == this.salesInvoiceId &&
          other.lineNo == this.lineNo &&
          other.productId == this.productId &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.unitTypeSnapshot == this.unitTypeSnapshot &&
          other.qtyMilli == this.qtyMilli &&
          other.unitPricePiasters == this.unitPricePiasters &&
          other.discountPiasters == this.discountPiasters &&
          other.lineTotalPiasters == this.lineTotalPiasters &&
          other.invoiceDiscountSharePiasters ==
              this.invoiceDiscountSharePiasters &&
          other.unitCostPiasters == this.unitCostPiasters &&
          other.lineCostPiasters == this.lineCostPiasters);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItemRow> {
  final Value<String> id;
  final Value<String> salesInvoiceId;
  final Value<int> lineNo;
  final Value<String> productId;
  final Value<String> productNameSnapshot;
  final Value<UnitType> unitTypeSnapshot;
  final Value<int> qtyMilli;
  final Value<int> unitPricePiasters;
  final Value<int> discountPiasters;
  final Value<int> lineTotalPiasters;
  final Value<int> invoiceDiscountSharePiasters;
  final Value<int> unitCostPiasters;
  final Value<int> lineCostPiasters;
  final Value<int> rowid;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.salesInvoiceId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.productId = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.unitTypeSnapshot = const Value.absent(),
    this.qtyMilli = const Value.absent(),
    this.unitPricePiasters = const Value.absent(),
    this.discountPiasters = const Value.absent(),
    this.lineTotalPiasters = const Value.absent(),
    this.invoiceDiscountSharePiasters = const Value.absent(),
    this.unitCostPiasters = const Value.absent(),
    this.lineCostPiasters = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    required String id,
    required String salesInvoiceId,
    required int lineNo,
    required String productId,
    required String productNameSnapshot,
    required UnitType unitTypeSnapshot,
    required int qtyMilli,
    required int unitPricePiasters,
    required int discountPiasters,
    required int lineTotalPiasters,
    required int invoiceDiscountSharePiasters,
    required int unitCostPiasters,
    required int lineCostPiasters,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       salesInvoiceId = Value(salesInvoiceId),
       lineNo = Value(lineNo),
       productId = Value(productId),
       productNameSnapshot = Value(productNameSnapshot),
       unitTypeSnapshot = Value(unitTypeSnapshot),
       qtyMilli = Value(qtyMilli),
       unitPricePiasters = Value(unitPricePiasters),
       discountPiasters = Value(discountPiasters),
       lineTotalPiasters = Value(lineTotalPiasters),
       invoiceDiscountSharePiasters = Value(invoiceDiscountSharePiasters),
       unitCostPiasters = Value(unitCostPiasters),
       lineCostPiasters = Value(lineCostPiasters);
  static Insertable<SaleItemRow> custom({
    Expression<String>? id,
    Expression<String>? salesInvoiceId,
    Expression<int>? lineNo,
    Expression<String>? productId,
    Expression<String>? productNameSnapshot,
    Expression<String>? unitTypeSnapshot,
    Expression<int>? qtyMilli,
    Expression<int>? unitPricePiasters,
    Expression<int>? discountPiasters,
    Expression<int>? lineTotalPiasters,
    Expression<int>? invoiceDiscountSharePiasters,
    Expression<int>? unitCostPiasters,
    Expression<int>? lineCostPiasters,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (salesInvoiceId != null) 'sales_invoice_id': salesInvoiceId,
      if (lineNo != null) 'line_no': lineNo,
      if (productId != null) 'product_id': productId,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (unitTypeSnapshot != null) 'unit_type_snapshot': unitTypeSnapshot,
      if (qtyMilli != null) 'qty_milli': qtyMilli,
      if (unitPricePiasters != null) 'unit_price_piasters': unitPricePiasters,
      if (discountPiasters != null) 'discount_piasters': discountPiasters,
      if (lineTotalPiasters != null) 'line_total_piasters': lineTotalPiasters,
      if (invoiceDiscountSharePiasters != null)
        'invoice_discount_share_piasters': invoiceDiscountSharePiasters,
      if (unitCostPiasters != null) 'unit_cost_piasters': unitCostPiasters,
      if (lineCostPiasters != null) 'line_cost_piasters': lineCostPiasters,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? salesInvoiceId,
    Value<int>? lineNo,
    Value<String>? productId,
    Value<String>? productNameSnapshot,
    Value<UnitType>? unitTypeSnapshot,
    Value<int>? qtyMilli,
    Value<int>? unitPricePiasters,
    Value<int>? discountPiasters,
    Value<int>? lineTotalPiasters,
    Value<int>? invoiceDiscountSharePiasters,
    Value<int>? unitCostPiasters,
    Value<int>? lineCostPiasters,
    Value<int>? rowid,
  }) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      salesInvoiceId: salesInvoiceId ?? this.salesInvoiceId,
      lineNo: lineNo ?? this.lineNo,
      productId: productId ?? this.productId,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      unitTypeSnapshot: unitTypeSnapshot ?? this.unitTypeSnapshot,
      qtyMilli: qtyMilli ?? this.qtyMilli,
      unitPricePiasters: unitPricePiasters ?? this.unitPricePiasters,
      discountPiasters: discountPiasters ?? this.discountPiasters,
      lineTotalPiasters: lineTotalPiasters ?? this.lineTotalPiasters,
      invoiceDiscountSharePiasters:
          invoiceDiscountSharePiasters ?? this.invoiceDiscountSharePiasters,
      unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
      lineCostPiasters: lineCostPiasters ?? this.lineCostPiasters,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (salesInvoiceId.present) {
      map['sales_invoice_id'] = Variable<String>(salesInvoiceId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (unitTypeSnapshot.present) {
      map['unit_type_snapshot'] = Variable<String>(
        $SaleItemsTable.$converterunitTypeSnapshot.toSql(
          unitTypeSnapshot.value,
        ),
      );
    }
    if (qtyMilli.present) {
      map['qty_milli'] = Variable<int>(qtyMilli.value);
    }
    if (unitPricePiasters.present) {
      map['unit_price_piasters'] = Variable<int>(unitPricePiasters.value);
    }
    if (discountPiasters.present) {
      map['discount_piasters'] = Variable<int>(discountPiasters.value);
    }
    if (lineTotalPiasters.present) {
      map['line_total_piasters'] = Variable<int>(lineTotalPiasters.value);
    }
    if (invoiceDiscountSharePiasters.present) {
      map['invoice_discount_share_piasters'] = Variable<int>(
        invoiceDiscountSharePiasters.value,
      );
    }
    if (unitCostPiasters.present) {
      map['unit_cost_piasters'] = Variable<int>(unitCostPiasters.value);
    }
    if (lineCostPiasters.present) {
      map['line_cost_piasters'] = Variable<int>(lineCostPiasters.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('salesInvoiceId: $salesInvoiceId, ')
          ..write('lineNo: $lineNo, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('unitTypeSnapshot: $unitTypeSnapshot, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unitPricePiasters: $unitPricePiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('lineTotalPiasters: $lineTotalPiasters, ')
          ..write(
            'invoiceDiscountSharePiasters: $invoiceDiscountSharePiasters, ',
          )
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('lineCostPiasters: $lineCostPiasters, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleReturnsTable extends SaleReturns
    with TableInfo<$SaleReturnsTable, SaleReturnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleReturnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _salesInvoiceIdMeta = const VerificationMeta(
    'salesInvoiceId',
  );
  @override
  late final GeneratedColumn<String> salesInvoiceId = GeneratedColumn<String>(
    'sales_invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales_invoices (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _totalRefundPiastersMeta =
      const VerificationMeta('totalRefundPiasters');
  @override
  late final GeneratedColumn<int> totalRefundPiasters = GeneratedColumn<int>(
    'total_refund_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostPiastersMeta = const VerificationMeta(
    'totalCostPiasters',
  );
  @override
  late final GeneratedColumn<int> totalCostPiasters = GeneratedColumn<int>(
    'total_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundPaidPiastersMeta =
      const VerificationMeta('refundPaidPiasters');
  @override
  late final GeneratedColumn<int> refundPaidPiasters = GeneratedColumn<int>(
    'refund_paid_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  ).withConverter<PaymentMethod>($SaleReturnsTable.$converterpaymentMethod);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SaleReturnsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    salesInvoiceId,
    customerId,
    totalRefundPiasters,
    totalCostPiasters,
    refundPaidPiasters,
    paymentMethod,
    reason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_returns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleReturnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('sales_invoice_id')) {
      context.handle(
        _salesInvoiceIdMeta,
        salesInvoiceId.isAcceptableOrUnknown(
          data['sales_invoice_id']!,
          _salesInvoiceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salesInvoiceIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('total_refund_piasters')) {
      context.handle(
        _totalRefundPiastersMeta,
        totalRefundPiasters.isAcceptableOrUnknown(
          data['total_refund_piasters']!,
          _totalRefundPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalRefundPiastersMeta);
    }
    if (data.containsKey('total_cost_piasters')) {
      context.handle(
        _totalCostPiastersMeta,
        totalCostPiasters.isAcceptableOrUnknown(
          data['total_cost_piasters']!,
          _totalCostPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalCostPiastersMeta);
    }
    if (data.containsKey('refund_paid_piasters')) {
      context.handle(
        _refundPaidPiastersMeta,
        refundPaidPiasters.isAcceptableOrUnknown(
          data['refund_paid_piasters']!,
          _refundPaidPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundPaidPiastersMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleReturnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleReturnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      salesInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sales_invoice_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      totalRefundPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_refund_piasters'],
      )!,
      totalCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cost_piasters'],
      )!,
      refundPaidPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refund_paid_piasters'],
      )!,
      paymentMethod: $SaleReturnsTable.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        )!,
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      createdAt: $SaleReturnsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $SaleReturnsTable createAlias(String alias) {
    return $SaleReturnsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
}

class SaleReturnRow extends DataClass implements Insertable<SaleReturnRow> {
  final String id;
  final int number;
  final String salesInvoiceId;
  final String? customerId;
  final int totalRefundPiasters;
  final int totalCostPiasters;
  final int refundPaidPiasters;
  final PaymentMethod paymentMethod;
  final String? reason;
  final DateTime createdAt;
  const SaleReturnRow({
    required this.id,
    required this.number,
    required this.salesInvoiceId,
    this.customerId,
    required this.totalRefundPiasters,
    required this.totalCostPiasters,
    required this.refundPaidPiasters,
    required this.paymentMethod,
    this.reason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['number'] = Variable<int>(number);
    map['sales_invoice_id'] = Variable<String>(salesInvoiceId);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['total_refund_piasters'] = Variable<int>(totalRefundPiasters);
    map['total_cost_piasters'] = Variable<int>(totalCostPiasters);
    map['refund_paid_piasters'] = Variable<int>(refundPaidPiasters);
    {
      map['payment_method'] = Variable<String>(
        $SaleReturnsTable.$converterpaymentMethod.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    {
      map['created_at'] = Variable<int>(
        $SaleReturnsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  SaleReturnsCompanion toCompanion(bool nullToAbsent) {
    return SaleReturnsCompanion(
      id: Value(id),
      number: Value(number),
      salesInvoiceId: Value(salesInvoiceId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      totalRefundPiasters: Value(totalRefundPiasters),
      totalCostPiasters: Value(totalCostPiasters),
      refundPaidPiasters: Value(refundPaidPiasters),
      paymentMethod: Value(paymentMethod),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      createdAt: Value(createdAt),
    );
  }

  factory SaleReturnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleReturnRow(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      salesInvoiceId: serializer.fromJson<String>(json['salesInvoiceId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      totalRefundPiasters: serializer.fromJson<int>(
        json['totalRefundPiasters'],
      ),
      totalCostPiasters: serializer.fromJson<int>(json['totalCostPiasters']),
      refundPaidPiasters: serializer.fromJson<int>(json['refundPaidPiasters']),
      paymentMethod: $SaleReturnsTable.$converterpaymentMethod.fromJson(
        serializer.fromJson<String>(json['paymentMethod']),
      ),
      reason: serializer.fromJson<String?>(json['reason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<int>(number),
      'salesInvoiceId': serializer.toJson<String>(salesInvoiceId),
      'customerId': serializer.toJson<String?>(customerId),
      'totalRefundPiasters': serializer.toJson<int>(totalRefundPiasters),
      'totalCostPiasters': serializer.toJson<int>(totalCostPiasters),
      'refundPaidPiasters': serializer.toJson<int>(refundPaidPiasters),
      'paymentMethod': serializer.toJson<String>(
        $SaleReturnsTable.$converterpaymentMethod.toJson(paymentMethod),
      ),
      'reason': serializer.toJson<String?>(reason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SaleReturnRow copyWith({
    String? id,
    int? number,
    String? salesInvoiceId,
    Value<String?> customerId = const Value.absent(),
    int? totalRefundPiasters,
    int? totalCostPiasters,
    int? refundPaidPiasters,
    PaymentMethod? paymentMethod,
    Value<String?> reason = const Value.absent(),
    DateTime? createdAt,
  }) => SaleReturnRow(
    id: id ?? this.id,
    number: number ?? this.number,
    salesInvoiceId: salesInvoiceId ?? this.salesInvoiceId,
    customerId: customerId.present ? customerId.value : this.customerId,
    totalRefundPiasters: totalRefundPiasters ?? this.totalRefundPiasters,
    totalCostPiasters: totalCostPiasters ?? this.totalCostPiasters,
    refundPaidPiasters: refundPaidPiasters ?? this.refundPaidPiasters,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    reason: reason.present ? reason.value : this.reason,
    createdAt: createdAt ?? this.createdAt,
  );
  SaleReturnRow copyWithCompanion(SaleReturnsCompanion data) {
    return SaleReturnRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      salesInvoiceId: data.salesInvoiceId.present
          ? data.salesInvoiceId.value
          : this.salesInvoiceId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      totalRefundPiasters: data.totalRefundPiasters.present
          ? data.totalRefundPiasters.value
          : this.totalRefundPiasters,
      totalCostPiasters: data.totalCostPiasters.present
          ? data.totalCostPiasters.value
          : this.totalCostPiasters,
      refundPaidPiasters: data.refundPaidPiasters.present
          ? data.refundPaidPiasters.value
          : this.refundPaidPiasters,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('salesInvoiceId: $salesInvoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('totalRefundPiasters: $totalRefundPiasters, ')
          ..write('totalCostPiasters: $totalCostPiasters, ')
          ..write('refundPaidPiasters: $refundPaidPiasters, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    salesInvoiceId,
    customerId,
    totalRefundPiasters,
    totalCostPiasters,
    refundPaidPiasters,
    paymentMethod,
    reason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleReturnRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.salesInvoiceId == this.salesInvoiceId &&
          other.customerId == this.customerId &&
          other.totalRefundPiasters == this.totalRefundPiasters &&
          other.totalCostPiasters == this.totalCostPiasters &&
          other.refundPaidPiasters == this.refundPaidPiasters &&
          other.paymentMethod == this.paymentMethod &&
          other.reason == this.reason &&
          other.createdAt == this.createdAt);
}

class SaleReturnsCompanion extends UpdateCompanion<SaleReturnRow> {
  final Value<String> id;
  final Value<int> number;
  final Value<String> salesInvoiceId;
  final Value<String?> customerId;
  final Value<int> totalRefundPiasters;
  final Value<int> totalCostPiasters;
  final Value<int> refundPaidPiasters;
  final Value<PaymentMethod> paymentMethod;
  final Value<String?> reason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SaleReturnsCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.salesInvoiceId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.totalRefundPiasters = const Value.absent(),
    this.totalCostPiasters = const Value.absent(),
    this.refundPaidPiasters = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleReturnsCompanion.insert({
    required String id,
    required int number,
    required String salesInvoiceId,
    this.customerId = const Value.absent(),
    required int totalRefundPiasters,
    required int totalCostPiasters,
    required int refundPaidPiasters,
    this.paymentMethod = const Value.absent(),
    this.reason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       number = Value(number),
       salesInvoiceId = Value(salesInvoiceId),
       totalRefundPiasters = Value(totalRefundPiasters),
       totalCostPiasters = Value(totalCostPiasters),
       refundPaidPiasters = Value(refundPaidPiasters),
       createdAt = Value(createdAt);
  static Insertable<SaleReturnRow> custom({
    Expression<String>? id,
    Expression<int>? number,
    Expression<String>? salesInvoiceId,
    Expression<String>? customerId,
    Expression<int>? totalRefundPiasters,
    Expression<int>? totalCostPiasters,
    Expression<int>? refundPaidPiasters,
    Expression<String>? paymentMethod,
    Expression<String>? reason,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (salesInvoiceId != null) 'sales_invoice_id': salesInvoiceId,
      if (customerId != null) 'customer_id': customerId,
      if (totalRefundPiasters != null)
        'total_refund_piasters': totalRefundPiasters,
      if (totalCostPiasters != null) 'total_cost_piasters': totalCostPiasters,
      if (refundPaidPiasters != null)
        'refund_paid_piasters': refundPaidPiasters,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (reason != null) 'reason': reason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleReturnsCompanion copyWith({
    Value<String>? id,
    Value<int>? number,
    Value<String>? salesInvoiceId,
    Value<String?>? customerId,
    Value<int>? totalRefundPiasters,
    Value<int>? totalCostPiasters,
    Value<int>? refundPaidPiasters,
    Value<PaymentMethod>? paymentMethod,
    Value<String?>? reason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SaleReturnsCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      salesInvoiceId: salesInvoiceId ?? this.salesInvoiceId,
      customerId: customerId ?? this.customerId,
      totalRefundPiasters: totalRefundPiasters ?? this.totalRefundPiasters,
      totalCostPiasters: totalCostPiasters ?? this.totalCostPiasters,
      refundPaidPiasters: refundPaidPiasters ?? this.refundPaidPiasters,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (salesInvoiceId.present) {
      map['sales_invoice_id'] = Variable<String>(salesInvoiceId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (totalRefundPiasters.present) {
      map['total_refund_piasters'] = Variable<int>(totalRefundPiasters.value);
    }
    if (totalCostPiasters.present) {
      map['total_cost_piasters'] = Variable<int>(totalCostPiasters.value);
    }
    if (refundPaidPiasters.present) {
      map['refund_paid_piasters'] = Variable<int>(refundPaidPiasters.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $SaleReturnsTable.$converterpaymentMethod.toSql(paymentMethod.value),
      );
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SaleReturnsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnsCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('salesInvoiceId: $salesInvoiceId, ')
          ..write('customerId: $customerId, ')
          ..write('totalRefundPiasters: $totalRefundPiasters, ')
          ..write('totalCostPiasters: $totalCostPiasters, ')
          ..write('refundPaidPiasters: $refundPaidPiasters, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reason: $reason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleReturnItemsTable extends SaleReturnItems
    with TableInfo<$SaleReturnItemsTable, SaleReturnItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleReturnItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleReturnIdMeta = const VerificationMeta(
    'saleReturnId',
  );
  @override
  late final GeneratedColumn<String> saleReturnId = GeneratedColumn<String>(
    'sale_return_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_returns (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _saleItemIdMeta = const VerificationMeta(
    'saleItemId',
  );
  @override
  late final GeneratedColumn<String> saleItemId = GeneratedColumn<String>(
    'sale_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_items (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _qtyMilliMeta = const VerificationMeta(
    'qtyMilli',
  );
  @override
  late final GeneratedColumn<int> qtyMilli = GeneratedColumn<int>(
    'qty_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPricePiastersMeta = const VerificationMeta(
    'unitPricePiasters',
  );
  @override
  late final GeneratedColumn<int> unitPricePiasters = GeneratedColumn<int>(
    'unit_price_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostPiastersMeta = const VerificationMeta(
    'unitCostPiasters',
  );
  @override
  late final GeneratedColumn<int> unitCostPiasters = GeneratedColumn<int>(
    'unit_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refundPiastersMeta = const VerificationMeta(
    'refundPiasters',
  );
  @override
  late final GeneratedColumn<int> refundPiasters = GeneratedColumn<int>(
    'refund_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPiastersMeta = const VerificationMeta(
    'costPiasters',
  );
  @override
  late final GeneratedColumn<int> costPiasters = GeneratedColumn<int>(
    'cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SaleReturnItemsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleReturnId,
    saleItemId,
    productId,
    qtyMilli,
    unitPricePiasters,
    unitCostPiasters,
    refundPiasters,
    costPiasters,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_return_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleReturnItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sale_return_id')) {
      context.handle(
        _saleReturnIdMeta,
        saleReturnId.isAcceptableOrUnknown(
          data['sale_return_id']!,
          _saleReturnIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saleReturnIdMeta);
    }
    if (data.containsKey('sale_item_id')) {
      context.handle(
        _saleItemIdMeta,
        saleItemId.isAcceptableOrUnknown(
          data['sale_item_id']!,
          _saleItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_saleItemIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('qty_milli')) {
      context.handle(
        _qtyMilliMeta,
        qtyMilli.isAcceptableOrUnknown(data['qty_milli']!, _qtyMilliMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMilliMeta);
    }
    if (data.containsKey('unit_price_piasters')) {
      context.handle(
        _unitPricePiastersMeta,
        unitPricePiasters.isAcceptableOrUnknown(
          data['unit_price_piasters']!,
          _unitPricePiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPricePiastersMeta);
    }
    if (data.containsKey('unit_cost_piasters')) {
      context.handle(
        _unitCostPiastersMeta,
        unitCostPiasters.isAcceptableOrUnknown(
          data['unit_cost_piasters']!,
          _unitCostPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostPiastersMeta);
    }
    if (data.containsKey('refund_piasters')) {
      context.handle(
        _refundPiastersMeta,
        refundPiasters.isAcceptableOrUnknown(
          data['refund_piasters']!,
          _refundPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_refundPiastersMeta);
    }
    if (data.containsKey('cost_piasters')) {
      context.handle(
        _costPiastersMeta,
        costPiasters.isAcceptableOrUnknown(
          data['cost_piasters']!,
          _costPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costPiastersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleReturnItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleReturnItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      saleReturnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_return_id'],
      )!,
      saleItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_item_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      qtyMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_milli'],
      )!,
      unitPricePiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_piasters'],
      )!,
      unitCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_piasters'],
      )!,
      refundPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refund_piasters'],
      )!,
      costPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_piasters'],
      )!,
      createdAt: $SaleReturnItemsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $SaleReturnItemsTable createAlias(String alias) {
    return $SaleReturnItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
}

class SaleReturnItemRow extends DataClass
    implements Insertable<SaleReturnItemRow> {
  final String id;
  final String saleReturnId;
  final String saleItemId;
  final String productId;
  final int qtyMilli;
  final int unitPricePiasters;
  final int unitCostPiasters;
  final int refundPiasters;
  final int costPiasters;
  final DateTime createdAt;
  const SaleReturnItemRow({
    required this.id,
    required this.saleReturnId,
    required this.saleItemId,
    required this.productId,
    required this.qtyMilli,
    required this.unitPricePiasters,
    required this.unitCostPiasters,
    required this.refundPiasters,
    required this.costPiasters,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sale_return_id'] = Variable<String>(saleReturnId);
    map['sale_item_id'] = Variable<String>(saleItemId);
    map['product_id'] = Variable<String>(productId);
    map['qty_milli'] = Variable<int>(qtyMilli);
    map['unit_price_piasters'] = Variable<int>(unitPricePiasters);
    map['unit_cost_piasters'] = Variable<int>(unitCostPiasters);
    map['refund_piasters'] = Variable<int>(refundPiasters);
    map['cost_piasters'] = Variable<int>(costPiasters);
    {
      map['created_at'] = Variable<int>(
        $SaleReturnItemsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  SaleReturnItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleReturnItemsCompanion(
      id: Value(id),
      saleReturnId: Value(saleReturnId),
      saleItemId: Value(saleItemId),
      productId: Value(productId),
      qtyMilli: Value(qtyMilli),
      unitPricePiasters: Value(unitPricePiasters),
      unitCostPiasters: Value(unitCostPiasters),
      refundPiasters: Value(refundPiasters),
      costPiasters: Value(costPiasters),
      createdAt: Value(createdAt),
    );
  }

  factory SaleReturnItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleReturnItemRow(
      id: serializer.fromJson<String>(json['id']),
      saleReturnId: serializer.fromJson<String>(json['saleReturnId']),
      saleItemId: serializer.fromJson<String>(json['saleItemId']),
      productId: serializer.fromJson<String>(json['productId']),
      qtyMilli: serializer.fromJson<int>(json['qtyMilli']),
      unitPricePiasters: serializer.fromJson<int>(json['unitPricePiasters']),
      unitCostPiasters: serializer.fromJson<int>(json['unitCostPiasters']),
      refundPiasters: serializer.fromJson<int>(json['refundPiasters']),
      costPiasters: serializer.fromJson<int>(json['costPiasters']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'saleReturnId': serializer.toJson<String>(saleReturnId),
      'saleItemId': serializer.toJson<String>(saleItemId),
      'productId': serializer.toJson<String>(productId),
      'qtyMilli': serializer.toJson<int>(qtyMilli),
      'unitPricePiasters': serializer.toJson<int>(unitPricePiasters),
      'unitCostPiasters': serializer.toJson<int>(unitCostPiasters),
      'refundPiasters': serializer.toJson<int>(refundPiasters),
      'costPiasters': serializer.toJson<int>(costPiasters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SaleReturnItemRow copyWith({
    String? id,
    String? saleReturnId,
    String? saleItemId,
    String? productId,
    int? qtyMilli,
    int? unitPricePiasters,
    int? unitCostPiasters,
    int? refundPiasters,
    int? costPiasters,
    DateTime? createdAt,
  }) => SaleReturnItemRow(
    id: id ?? this.id,
    saleReturnId: saleReturnId ?? this.saleReturnId,
    saleItemId: saleItemId ?? this.saleItemId,
    productId: productId ?? this.productId,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    unitPricePiasters: unitPricePiasters ?? this.unitPricePiasters,
    unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
    refundPiasters: refundPiasters ?? this.refundPiasters,
    costPiasters: costPiasters ?? this.costPiasters,
    createdAt: createdAt ?? this.createdAt,
  );
  SaleReturnItemRow copyWithCompanion(SaleReturnItemsCompanion data) {
    return SaleReturnItemRow(
      id: data.id.present ? data.id.value : this.id,
      saleReturnId: data.saleReturnId.present
          ? data.saleReturnId.value
          : this.saleReturnId,
      saleItemId: data.saleItemId.present
          ? data.saleItemId.value
          : this.saleItemId,
      productId: data.productId.present ? data.productId.value : this.productId,
      qtyMilli: data.qtyMilli.present ? data.qtyMilli.value : this.qtyMilli,
      unitPricePiasters: data.unitPricePiasters.present
          ? data.unitPricePiasters.value
          : this.unitPricePiasters,
      unitCostPiasters: data.unitCostPiasters.present
          ? data.unitCostPiasters.value
          : this.unitCostPiasters,
      refundPiasters: data.refundPiasters.present
          ? data.refundPiasters.value
          : this.refundPiasters,
      costPiasters: data.costPiasters.present
          ? data.costPiasters.value
          : this.costPiasters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnItemRow(')
          ..write('id: $id, ')
          ..write('saleReturnId: $saleReturnId, ')
          ..write('saleItemId: $saleItemId, ')
          ..write('productId: $productId, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unitPricePiasters: $unitPricePiasters, ')
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('refundPiasters: $refundPiasters, ')
          ..write('costPiasters: $costPiasters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleReturnId,
    saleItemId,
    productId,
    qtyMilli,
    unitPricePiasters,
    unitCostPiasters,
    refundPiasters,
    costPiasters,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleReturnItemRow &&
          other.id == this.id &&
          other.saleReturnId == this.saleReturnId &&
          other.saleItemId == this.saleItemId &&
          other.productId == this.productId &&
          other.qtyMilli == this.qtyMilli &&
          other.unitPricePiasters == this.unitPricePiasters &&
          other.unitCostPiasters == this.unitCostPiasters &&
          other.refundPiasters == this.refundPiasters &&
          other.costPiasters == this.costPiasters &&
          other.createdAt == this.createdAt);
}

class SaleReturnItemsCompanion extends UpdateCompanion<SaleReturnItemRow> {
  final Value<String> id;
  final Value<String> saleReturnId;
  final Value<String> saleItemId;
  final Value<String> productId;
  final Value<int> qtyMilli;
  final Value<int> unitPricePiasters;
  final Value<int> unitCostPiasters;
  final Value<int> refundPiasters;
  final Value<int> costPiasters;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SaleReturnItemsCompanion({
    this.id = const Value.absent(),
    this.saleReturnId = const Value.absent(),
    this.saleItemId = const Value.absent(),
    this.productId = const Value.absent(),
    this.qtyMilli = const Value.absent(),
    this.unitPricePiasters = const Value.absent(),
    this.unitCostPiasters = const Value.absent(),
    this.refundPiasters = const Value.absent(),
    this.costPiasters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleReturnItemsCompanion.insert({
    required String id,
    required String saleReturnId,
    required String saleItemId,
    required String productId,
    required int qtyMilli,
    required int unitPricePiasters,
    required int unitCostPiasters,
    required int refundPiasters,
    required int costPiasters,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       saleReturnId = Value(saleReturnId),
       saleItemId = Value(saleItemId),
       productId = Value(productId),
       qtyMilli = Value(qtyMilli),
       unitPricePiasters = Value(unitPricePiasters),
       unitCostPiasters = Value(unitCostPiasters),
       refundPiasters = Value(refundPiasters),
       costPiasters = Value(costPiasters),
       createdAt = Value(createdAt);
  static Insertable<SaleReturnItemRow> custom({
    Expression<String>? id,
    Expression<String>? saleReturnId,
    Expression<String>? saleItemId,
    Expression<String>? productId,
    Expression<int>? qtyMilli,
    Expression<int>? unitPricePiasters,
    Expression<int>? unitCostPiasters,
    Expression<int>? refundPiasters,
    Expression<int>? costPiasters,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleReturnId != null) 'sale_return_id': saleReturnId,
      if (saleItemId != null) 'sale_item_id': saleItemId,
      if (productId != null) 'product_id': productId,
      if (qtyMilli != null) 'qty_milli': qtyMilli,
      if (unitPricePiasters != null) 'unit_price_piasters': unitPricePiasters,
      if (unitCostPiasters != null) 'unit_cost_piasters': unitCostPiasters,
      if (refundPiasters != null) 'refund_piasters': refundPiasters,
      if (costPiasters != null) 'cost_piasters': costPiasters,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleReturnItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? saleReturnId,
    Value<String>? saleItemId,
    Value<String>? productId,
    Value<int>? qtyMilli,
    Value<int>? unitPricePiasters,
    Value<int>? unitCostPiasters,
    Value<int>? refundPiasters,
    Value<int>? costPiasters,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SaleReturnItemsCompanion(
      id: id ?? this.id,
      saleReturnId: saleReturnId ?? this.saleReturnId,
      saleItemId: saleItemId ?? this.saleItemId,
      productId: productId ?? this.productId,
      qtyMilli: qtyMilli ?? this.qtyMilli,
      unitPricePiasters: unitPricePiasters ?? this.unitPricePiasters,
      unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
      refundPiasters: refundPiasters ?? this.refundPiasters,
      costPiasters: costPiasters ?? this.costPiasters,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (saleReturnId.present) {
      map['sale_return_id'] = Variable<String>(saleReturnId.value);
    }
    if (saleItemId.present) {
      map['sale_item_id'] = Variable<String>(saleItemId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (qtyMilli.present) {
      map['qty_milli'] = Variable<int>(qtyMilli.value);
    }
    if (unitPricePiasters.present) {
      map['unit_price_piasters'] = Variable<int>(unitPricePiasters.value);
    }
    if (unitCostPiasters.present) {
      map['unit_cost_piasters'] = Variable<int>(unitCostPiasters.value);
    }
    if (refundPiasters.present) {
      map['refund_piasters'] = Variable<int>(refundPiasters.value);
    }
    if (costPiasters.present) {
      map['cost_piasters'] = Variable<int>(costPiasters.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SaleReturnItemsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleReturnItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleReturnId: $saleReturnId, ')
          ..write('saleItemId: $saleItemId, ')
          ..write('productId: $productId, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unitPricePiasters: $unitPricePiasters, ')
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('refundPiasters: $refundPiasters, ')
          ..write('costPiasters: $costPiasters, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseInvoicesTable extends PurchaseInvoices
    with TableInfo<$PurchaseInvoicesTable, PurchaseInvoiceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _supplierRefMeta = const VerificationMeta(
    'supplierRef',
  );
  @override
  late final GeneratedColumn<String> supplierRef = GeneratedColumn<String>(
    'supplier_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> invoiceDate =
      GeneratedColumn<int>(
        'invoice_date',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PurchaseInvoicesTable.$converterinvoiceDate);
  static const VerificationMeta _subtotalPiastersMeta = const VerificationMeta(
    'subtotalPiasters',
  );
  @override
  late final GeneratedColumn<int> subtotalPiasters = GeneratedColumn<int>(
    'subtotal_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPiastersMeta = const VerificationMeta(
    'discountPiasters',
  );
  @override
  late final GeneratedColumn<int> discountPiasters = GeneratedColumn<int>(
    'discount_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPiastersMeta = const VerificationMeta(
    'totalPiasters',
  );
  @override
  late final GeneratedColumn<int> totalPiasters = GeneratedColumn<int>(
    'total_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidPiastersMeta = const VerificationMeta(
    'paidPiasters',
  );
  @override
  late final GeneratedColumn<int> paidPiasters = GeneratedColumn<int>(
    'paid_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod, String>
  paymentMethod =
      GeneratedColumn<String>(
        'payment_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('cash'),
      ).withConverter<PaymentMethod>(
        $PurchaseInvoicesTable.$converterpaymentMethod,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PurchaseInvoicesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PurchaseInvoicesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> voidedAt =
      GeneratedColumn<int>(
        'voided_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($PurchaseInvoicesTable.$convertervoidedAtn);
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    supplierId,
    supplierRef,
    invoiceDate,
    subtotalPiasters,
    discountPiasters,
    totalPiasters,
    paidPiasters,
    paymentMethod,
    note,
    createdAt,
    updatedAt,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseInvoiceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('supplier_ref')) {
      context.handle(
        _supplierRefMeta,
        supplierRef.isAcceptableOrUnknown(
          data['supplier_ref']!,
          _supplierRefMeta,
        ),
      );
    }
    if (data.containsKey('subtotal_piasters')) {
      context.handle(
        _subtotalPiastersMeta,
        subtotalPiasters.isAcceptableOrUnknown(
          data['subtotal_piasters']!,
          _subtotalPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subtotalPiastersMeta);
    }
    if (data.containsKey('discount_piasters')) {
      context.handle(
        _discountPiastersMeta,
        discountPiasters.isAcceptableOrUnknown(
          data['discount_piasters']!,
          _discountPiastersMeta,
        ),
      );
    }
    if (data.containsKey('total_piasters')) {
      context.handle(
        _totalPiastersMeta,
        totalPiasters.isAcceptableOrUnknown(
          data['total_piasters']!,
          _totalPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPiastersMeta);
    }
    if (data.containsKey('paid_piasters')) {
      context.handle(
        _paidPiastersMeta,
        paidPiasters.isAcceptableOrUnknown(
          data['paid_piasters']!,
          _paidPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paidPiastersMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseInvoiceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseInvoiceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      supplierRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_ref'],
      ),
      invoiceDate: $PurchaseInvoicesTable.$converterinvoiceDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}invoice_date'],
        )!,
      ),
      subtotalPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subtotal_piasters'],
      )!,
      discountPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_piasters'],
      )!,
      totalPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_piasters'],
      )!,
      paidPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_piasters'],
      )!,
      paymentMethod: $PurchaseInvoicesTable.$converterpaymentMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $PurchaseInvoicesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $PurchaseInvoicesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      voidedAt: $PurchaseInvoicesTable.$convertervoidedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}voided_at'],
        ),
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $PurchaseInvoicesTable createAlias(String alias) {
    return $PurchaseInvoicesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterinvoiceDate =
      const UtcMillisConverter();
  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $convertervoidedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $convertervoidedAtn =
      NullAwareTypeConverter.wrap($convertervoidedAt);
}

class PurchaseInvoiceRow extends DataClass
    implements Insertable<PurchaseInvoiceRow> {
  final String id;
  final int number;
  final String? supplierId;
  final String? supplierRef;
  final DateTime invoiceDate;
  final int subtotalPiasters;
  final int discountPiasters;
  final int totalPiasters;
  final int paidPiasters;
  final PaymentMethod paymentMethod;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? voidedAt;
  final String? voidReason;
  const PurchaseInvoiceRow({
    required this.id,
    required this.number,
    this.supplierId,
    this.supplierRef,
    required this.invoiceDate,
    required this.subtotalPiasters,
    required this.discountPiasters,
    required this.totalPiasters,
    required this.paidPiasters,
    required this.paymentMethod,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['number'] = Variable<int>(number);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    if (!nullToAbsent || supplierRef != null) {
      map['supplier_ref'] = Variable<String>(supplierRef);
    }
    {
      map['invoice_date'] = Variable<int>(
        $PurchaseInvoicesTable.$converterinvoiceDate.toSql(invoiceDate),
      );
    }
    map['subtotal_piasters'] = Variable<int>(subtotalPiasters);
    map['discount_piasters'] = Variable<int>(discountPiasters);
    map['total_piasters'] = Variable<int>(totalPiasters);
    map['paid_piasters'] = Variable<int>(paidPiasters);
    {
      map['payment_method'] = Variable<String>(
        $PurchaseInvoicesTable.$converterpaymentMethod.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $PurchaseInvoicesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $PurchaseInvoicesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<int>(
        $PurchaseInvoicesTable.$convertervoidedAtn.toSql(voidedAt),
      );
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  PurchaseInvoicesCompanion toCompanion(bool nullToAbsent) {
    return PurchaseInvoicesCompanion(
      id: Value(id),
      number: Value(number),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      supplierRef: supplierRef == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierRef),
      invoiceDate: Value(invoiceDate),
      subtotalPiasters: Value(subtotalPiasters),
      discountPiasters: Value(discountPiasters),
      totalPiasters: Value(totalPiasters),
      paidPiasters: Value(paidPiasters),
      paymentMethod: Value(paymentMethod),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory PurchaseInvoiceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseInvoiceRow(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      supplierRef: serializer.fromJson<String?>(json['supplierRef']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      subtotalPiasters: serializer.fromJson<int>(json['subtotalPiasters']),
      discountPiasters: serializer.fromJson<int>(json['discountPiasters']),
      totalPiasters: serializer.fromJson<int>(json['totalPiasters']),
      paidPiasters: serializer.fromJson<int>(json['paidPiasters']),
      paymentMethod: $PurchaseInvoicesTable.$converterpaymentMethod.fromJson(
        serializer.fromJson<String>(json['paymentMethod']),
      ),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<int>(number),
      'supplierId': serializer.toJson<String?>(supplierId),
      'supplierRef': serializer.toJson<String?>(supplierRef),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'subtotalPiasters': serializer.toJson<int>(subtotalPiasters),
      'discountPiasters': serializer.toJson<int>(discountPiasters),
      'totalPiasters': serializer.toJson<int>(totalPiasters),
      'paidPiasters': serializer.toJson<int>(paidPiasters),
      'paymentMethod': serializer.toJson<String>(
        $PurchaseInvoicesTable.$converterpaymentMethod.toJson(paymentMethod),
      ),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  PurchaseInvoiceRow copyWith({
    String? id,
    int? number,
    Value<String?> supplierId = const Value.absent(),
    Value<String?> supplierRef = const Value.absent(),
    DateTime? invoiceDate,
    int? subtotalPiasters,
    int? discountPiasters,
    int? totalPiasters,
    int? paidPiasters,
    PaymentMethod? paymentMethod,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => PurchaseInvoiceRow(
    id: id ?? this.id,
    number: number ?? this.number,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    supplierRef: supplierRef.present ? supplierRef.value : this.supplierRef,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    subtotalPiasters: subtotalPiasters ?? this.subtotalPiasters,
    discountPiasters: discountPiasters ?? this.discountPiasters,
    totalPiasters: totalPiasters ?? this.totalPiasters,
    paidPiasters: paidPiasters ?? this.paidPiasters,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  PurchaseInvoiceRow copyWithCompanion(PurchaseInvoicesCompanion data) {
    return PurchaseInvoiceRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      supplierRef: data.supplierRef.present
          ? data.supplierRef.value
          : this.supplierRef,
      invoiceDate: data.invoiceDate.present
          ? data.invoiceDate.value
          : this.invoiceDate,
      subtotalPiasters: data.subtotalPiasters.present
          ? data.subtotalPiasters.value
          : this.subtotalPiasters,
      discountPiasters: data.discountPiasters.present
          ? data.discountPiasters.value
          : this.discountPiasters,
      totalPiasters: data.totalPiasters.present
          ? data.totalPiasters.value
          : this.totalPiasters,
      paidPiasters: data.paidPiasters.present
          ? data.paidPiasters.value
          : this.paidPiasters,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseInvoiceRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierRef: $supplierRef, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('subtotalPiasters: $subtotalPiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('totalPiasters: $totalPiasters, ')
          ..write('paidPiasters: $paidPiasters, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    supplierId,
    supplierRef,
    invoiceDate,
    subtotalPiasters,
    discountPiasters,
    totalPiasters,
    paidPiasters,
    paymentMethod,
    note,
    createdAt,
    updatedAt,
    voidedAt,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseInvoiceRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.supplierId == this.supplierId &&
          other.supplierRef == this.supplierRef &&
          other.invoiceDate == this.invoiceDate &&
          other.subtotalPiasters == this.subtotalPiasters &&
          other.discountPiasters == this.discountPiasters &&
          other.totalPiasters == this.totalPiasters &&
          other.paidPiasters == this.paidPiasters &&
          other.paymentMethod == this.paymentMethod &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class PurchaseInvoicesCompanion extends UpdateCompanion<PurchaseInvoiceRow> {
  final Value<String> id;
  final Value<int> number;
  final Value<String?> supplierId;
  final Value<String?> supplierRef;
  final Value<DateTime> invoiceDate;
  final Value<int> subtotalPiasters;
  final Value<int> discountPiasters;
  final Value<int> totalPiasters;
  final Value<int> paidPiasters;
  final Value<PaymentMethod> paymentMethod;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const PurchaseInvoicesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.supplierRef = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.subtotalPiasters = const Value.absent(),
    this.discountPiasters = const Value.absent(),
    this.totalPiasters = const Value.absent(),
    this.paidPiasters = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseInvoicesCompanion.insert({
    required String id,
    required int number,
    this.supplierId = const Value.absent(),
    this.supplierRef = const Value.absent(),
    required DateTime invoiceDate,
    required int subtotalPiasters,
    this.discountPiasters = const Value.absent(),
    required int totalPiasters,
    required int paidPiasters,
    this.paymentMethod = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       number = Value(number),
       invoiceDate = Value(invoiceDate),
       subtotalPiasters = Value(subtotalPiasters),
       totalPiasters = Value(totalPiasters),
       paidPiasters = Value(paidPiasters),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PurchaseInvoiceRow> custom({
    Expression<String>? id,
    Expression<int>? number,
    Expression<String>? supplierId,
    Expression<String>? supplierRef,
    Expression<int>? invoiceDate,
    Expression<int>? subtotalPiasters,
    Expression<int>? discountPiasters,
    Expression<int>? totalPiasters,
    Expression<int>? paidPiasters,
    Expression<String>? paymentMethod,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (supplierId != null) 'supplier_id': supplierId,
      if (supplierRef != null) 'supplier_ref': supplierRef,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (subtotalPiasters != null) 'subtotal_piasters': subtotalPiasters,
      if (discountPiasters != null) 'discount_piasters': discountPiasters,
      if (totalPiasters != null) 'total_piasters': totalPiasters,
      if (paidPiasters != null) 'paid_piasters': paidPiasters,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseInvoicesCompanion copyWith({
    Value<String>? id,
    Value<int>? number,
    Value<String?>? supplierId,
    Value<String?>? supplierRef,
    Value<DateTime>? invoiceDate,
    Value<int>? subtotalPiasters,
    Value<int>? discountPiasters,
    Value<int>? totalPiasters,
    Value<int>? paidPiasters,
    Value<PaymentMethod>? paymentMethod,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return PurchaseInvoicesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      supplierId: supplierId ?? this.supplierId,
      supplierRef: supplierRef ?? this.supplierRef,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      subtotalPiasters: subtotalPiasters ?? this.subtotalPiasters,
      discountPiasters: discountPiasters ?? this.discountPiasters,
      totalPiasters: totalPiasters ?? this.totalPiasters,
      paidPiasters: paidPiasters ?? this.paidPiasters,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (supplierRef.present) {
      map['supplier_ref'] = Variable<String>(supplierRef.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<int>(
        $PurchaseInvoicesTable.$converterinvoiceDate.toSql(invoiceDate.value),
      );
    }
    if (subtotalPiasters.present) {
      map['subtotal_piasters'] = Variable<int>(subtotalPiasters.value);
    }
    if (discountPiasters.present) {
      map['discount_piasters'] = Variable<int>(discountPiasters.value);
    }
    if (totalPiasters.present) {
      map['total_piasters'] = Variable<int>(totalPiasters.value);
    }
    if (paidPiasters.present) {
      map['paid_piasters'] = Variable<int>(paidPiasters.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $PurchaseInvoicesTable.$converterpaymentMethod.toSql(
          paymentMethod.value,
        ),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $PurchaseInvoicesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $PurchaseInvoicesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<int>(
        $PurchaseInvoicesTable.$convertervoidedAtn.toSql(voidedAt.value),
      );
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('supplierId: $supplierId, ')
          ..write('supplierRef: $supplierRef, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('subtotalPiasters: $subtotalPiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('totalPiasters: $totalPiasters, ')
          ..write('paidPiasters: $paidPiasters, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseItemsTable extends PurchaseItems
    with TableInfo<$PurchaseItemsTable, PurchaseItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseInvoiceIdMeta = const VerificationMeta(
    'purchaseInvoiceId',
  );
  @override
  late final GeneratedColumn<String> purchaseInvoiceId =
      GeneratedColumn<String>(
        'purchase_invoice_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES purchase_invoices (id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
    'line_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _qtyMilliMeta = const VerificationMeta(
    'qtyMilli',
  );
  @override
  late final GeneratedColumn<int> qtyMilli = GeneratedColumn<int>(
    'qty_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostPiastersMeta = const VerificationMeta(
    'unitCostPiasters',
  );
  @override
  late final GeneratedColumn<int> unitCostPiasters = GeneratedColumn<int>(
    'unit_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPiastersMeta = const VerificationMeta(
    'discountPiasters',
  );
  @override
  late final GeneratedColumn<int> discountPiasters = GeneratedColumn<int>(
    'discount_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lineTotalPiastersMeta = const VerificationMeta(
    'lineTotalPiasters',
  );
  @override
  late final GeneratedColumn<int> lineTotalPiasters = GeneratedColumn<int>(
    'line_total_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invoiceDiscountSharePiastersMeta =
      const VerificationMeta('invoiceDiscountSharePiasters');
  @override
  late final GeneratedColumn<int> invoiceDiscountSharePiasters =
      GeneratedColumn<int>(
        'invoice_discount_share_piasters',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _netLineCostPiastersMeta =
      const VerificationMeta('netLineCostPiasters');
  @override
  late final GeneratedColumn<int> netLineCostPiasters = GeneratedColumn<int>(
    'net_line_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgCostBeforePiastersMeta =
      const VerificationMeta('avgCostBeforePiasters');
  @override
  late final GeneratedColumn<int> avgCostBeforePiasters = GeneratedColumn<int>(
    'avg_cost_before_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avgCostAfterPiastersMeta =
      const VerificationMeta('avgCostAfterPiasters');
  @override
  late final GeneratedColumn<int> avgCostAfterPiasters = GeneratedColumn<int>(
    'avg_cost_after_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($PurchaseItemsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseInvoiceId,
    lineNo,
    productId,
    productNameSnapshot,
    qtyMilli,
    unitCostPiasters,
    discountPiasters,
    lineTotalPiasters,
    invoiceDiscountSharePiasters,
    netLineCostPiasters,
    avgCostBeforePiasters,
    avgCostAfterPiasters,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_invoice_id')) {
      context.handle(
        _purchaseInvoiceIdMeta,
        purchaseInvoiceId.isAcceptableOrUnknown(
          data['purchase_invoice_id']!,
          _purchaseInvoiceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseInvoiceIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(
        _lineNoMeta,
        lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta),
      );
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('qty_milli')) {
      context.handle(
        _qtyMilliMeta,
        qtyMilli.isAcceptableOrUnknown(data['qty_milli']!, _qtyMilliMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMilliMeta);
    }
    if (data.containsKey('unit_cost_piasters')) {
      context.handle(
        _unitCostPiastersMeta,
        unitCostPiasters.isAcceptableOrUnknown(
          data['unit_cost_piasters']!,
          _unitCostPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostPiastersMeta);
    }
    if (data.containsKey('discount_piasters')) {
      context.handle(
        _discountPiastersMeta,
        discountPiasters.isAcceptableOrUnknown(
          data['discount_piasters']!,
          _discountPiastersMeta,
        ),
      );
    }
    if (data.containsKey('line_total_piasters')) {
      context.handle(
        _lineTotalPiastersMeta,
        lineTotalPiasters.isAcceptableOrUnknown(
          data['line_total_piasters']!,
          _lineTotalPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalPiastersMeta);
    }
    if (data.containsKey('invoice_discount_share_piasters')) {
      context.handle(
        _invoiceDiscountSharePiastersMeta,
        invoiceDiscountSharePiasters.isAcceptableOrUnknown(
          data['invoice_discount_share_piasters']!,
          _invoiceDiscountSharePiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDiscountSharePiastersMeta);
    }
    if (data.containsKey('net_line_cost_piasters')) {
      context.handle(
        _netLineCostPiastersMeta,
        netLineCostPiasters.isAcceptableOrUnknown(
          data['net_line_cost_piasters']!,
          _netLineCostPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_netLineCostPiastersMeta);
    }
    if (data.containsKey('avg_cost_before_piasters')) {
      context.handle(
        _avgCostBeforePiastersMeta,
        avgCostBeforePiasters.isAcceptableOrUnknown(
          data['avg_cost_before_piasters']!,
          _avgCostBeforePiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgCostBeforePiastersMeta);
    }
    if (data.containsKey('avg_cost_after_piasters')) {
      context.handle(
        _avgCostAfterPiastersMeta,
        avgCostAfterPiasters.isAcceptableOrUnknown(
          data['avg_cost_after_piasters']!,
          _avgCostAfterPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgCostAfterPiastersMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {purchaseInvoiceId, lineNo},
  ];
  @override
  PurchaseItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_invoice_id'],
      )!,
      lineNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_no'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      qtyMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_milli'],
      )!,
      unitCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_piasters'],
      )!,
      discountPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_piasters'],
      )!,
      lineTotalPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_piasters'],
      )!,
      invoiceDiscountSharePiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_discount_share_piasters'],
      )!,
      netLineCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_line_cost_piasters'],
      )!,
      avgCostBeforePiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cost_before_piasters'],
      )!,
      avgCostAfterPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avg_cost_after_piasters'],
      )!,
      createdAt: $PurchaseItemsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $PurchaseItemsTable createAlias(String alias) {
    return $PurchaseItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
}

class PurchaseItemRow extends DataClass implements Insertable<PurchaseItemRow> {
  final String id;
  final String purchaseInvoiceId;
  final int lineNo;
  final String productId;
  final String productNameSnapshot;
  final int qtyMilli;
  final int unitCostPiasters;
  final int discountPiasters;
  final int lineTotalPiasters;
  final int invoiceDiscountSharePiasters;
  final int netLineCostPiasters;
  final int avgCostBeforePiasters;
  final int avgCostAfterPiasters;
  final DateTime createdAt;
  const PurchaseItemRow({
    required this.id,
    required this.purchaseInvoiceId,
    required this.lineNo,
    required this.productId,
    required this.productNameSnapshot,
    required this.qtyMilli,
    required this.unitCostPiasters,
    required this.discountPiasters,
    required this.lineTotalPiasters,
    required this.invoiceDiscountSharePiasters,
    required this.netLineCostPiasters,
    required this.avgCostBeforePiasters,
    required this.avgCostAfterPiasters,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_invoice_id'] = Variable<String>(purchaseInvoiceId);
    map['line_no'] = Variable<int>(lineNo);
    map['product_id'] = Variable<String>(productId);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    map['qty_milli'] = Variable<int>(qtyMilli);
    map['unit_cost_piasters'] = Variable<int>(unitCostPiasters);
    map['discount_piasters'] = Variable<int>(discountPiasters);
    map['line_total_piasters'] = Variable<int>(lineTotalPiasters);
    map['invoice_discount_share_piasters'] = Variable<int>(
      invoiceDiscountSharePiasters,
    );
    map['net_line_cost_piasters'] = Variable<int>(netLineCostPiasters);
    map['avg_cost_before_piasters'] = Variable<int>(avgCostBeforePiasters);
    map['avg_cost_after_piasters'] = Variable<int>(avgCostAfterPiasters);
    {
      map['created_at'] = Variable<int>(
        $PurchaseItemsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  PurchaseItemsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseItemsCompanion(
      id: Value(id),
      purchaseInvoiceId: Value(purchaseInvoiceId),
      lineNo: Value(lineNo),
      productId: Value(productId),
      productNameSnapshot: Value(productNameSnapshot),
      qtyMilli: Value(qtyMilli),
      unitCostPiasters: Value(unitCostPiasters),
      discountPiasters: Value(discountPiasters),
      lineTotalPiasters: Value(lineTotalPiasters),
      invoiceDiscountSharePiasters: Value(invoiceDiscountSharePiasters),
      netLineCostPiasters: Value(netLineCostPiasters),
      avgCostBeforePiasters: Value(avgCostBeforePiasters),
      avgCostAfterPiasters: Value(avgCostAfterPiasters),
      createdAt: Value(createdAt),
    );
  }

  factory PurchaseItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseItemRow(
      id: serializer.fromJson<String>(json['id']),
      purchaseInvoiceId: serializer.fromJson<String>(json['purchaseInvoiceId']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
      productId: serializer.fromJson<String>(json['productId']),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      qtyMilli: serializer.fromJson<int>(json['qtyMilli']),
      unitCostPiasters: serializer.fromJson<int>(json['unitCostPiasters']),
      discountPiasters: serializer.fromJson<int>(json['discountPiasters']),
      lineTotalPiasters: serializer.fromJson<int>(json['lineTotalPiasters']),
      invoiceDiscountSharePiasters: serializer.fromJson<int>(
        json['invoiceDiscountSharePiasters'],
      ),
      netLineCostPiasters: serializer.fromJson<int>(
        json['netLineCostPiasters'],
      ),
      avgCostBeforePiasters: serializer.fromJson<int>(
        json['avgCostBeforePiasters'],
      ),
      avgCostAfterPiasters: serializer.fromJson<int>(
        json['avgCostAfterPiasters'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseInvoiceId': serializer.toJson<String>(purchaseInvoiceId),
      'lineNo': serializer.toJson<int>(lineNo),
      'productId': serializer.toJson<String>(productId),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'qtyMilli': serializer.toJson<int>(qtyMilli),
      'unitCostPiasters': serializer.toJson<int>(unitCostPiasters),
      'discountPiasters': serializer.toJson<int>(discountPiasters),
      'lineTotalPiasters': serializer.toJson<int>(lineTotalPiasters),
      'invoiceDiscountSharePiasters': serializer.toJson<int>(
        invoiceDiscountSharePiasters,
      ),
      'netLineCostPiasters': serializer.toJson<int>(netLineCostPiasters),
      'avgCostBeforePiasters': serializer.toJson<int>(avgCostBeforePiasters),
      'avgCostAfterPiasters': serializer.toJson<int>(avgCostAfterPiasters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PurchaseItemRow copyWith({
    String? id,
    String? purchaseInvoiceId,
    int? lineNo,
    String? productId,
    String? productNameSnapshot,
    int? qtyMilli,
    int? unitCostPiasters,
    int? discountPiasters,
    int? lineTotalPiasters,
    int? invoiceDiscountSharePiasters,
    int? netLineCostPiasters,
    int? avgCostBeforePiasters,
    int? avgCostAfterPiasters,
    DateTime? createdAt,
  }) => PurchaseItemRow(
    id: id ?? this.id,
    purchaseInvoiceId: purchaseInvoiceId ?? this.purchaseInvoiceId,
    lineNo: lineNo ?? this.lineNo,
    productId: productId ?? this.productId,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    qtyMilli: qtyMilli ?? this.qtyMilli,
    unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
    discountPiasters: discountPiasters ?? this.discountPiasters,
    lineTotalPiasters: lineTotalPiasters ?? this.lineTotalPiasters,
    invoiceDiscountSharePiasters:
        invoiceDiscountSharePiasters ?? this.invoiceDiscountSharePiasters,
    netLineCostPiasters: netLineCostPiasters ?? this.netLineCostPiasters,
    avgCostBeforePiasters: avgCostBeforePiasters ?? this.avgCostBeforePiasters,
    avgCostAfterPiasters: avgCostAfterPiasters ?? this.avgCostAfterPiasters,
    createdAt: createdAt ?? this.createdAt,
  );
  PurchaseItemRow copyWithCompanion(PurchaseItemsCompanion data) {
    return PurchaseItemRow(
      id: data.id.present ? data.id.value : this.id,
      purchaseInvoiceId: data.purchaseInvoiceId.present
          ? data.purchaseInvoiceId.value
          : this.purchaseInvoiceId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      productId: data.productId.present ? data.productId.value : this.productId,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      qtyMilli: data.qtyMilli.present ? data.qtyMilli.value : this.qtyMilli,
      unitCostPiasters: data.unitCostPiasters.present
          ? data.unitCostPiasters.value
          : this.unitCostPiasters,
      discountPiasters: data.discountPiasters.present
          ? data.discountPiasters.value
          : this.discountPiasters,
      lineTotalPiasters: data.lineTotalPiasters.present
          ? data.lineTotalPiasters.value
          : this.lineTotalPiasters,
      invoiceDiscountSharePiasters: data.invoiceDiscountSharePiasters.present
          ? data.invoiceDiscountSharePiasters.value
          : this.invoiceDiscountSharePiasters,
      netLineCostPiasters: data.netLineCostPiasters.present
          ? data.netLineCostPiasters.value
          : this.netLineCostPiasters,
      avgCostBeforePiasters: data.avgCostBeforePiasters.present
          ? data.avgCostBeforePiasters.value
          : this.avgCostBeforePiasters,
      avgCostAfterPiasters: data.avgCostAfterPiasters.present
          ? data.avgCostAfterPiasters.value
          : this.avgCostAfterPiasters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemRow(')
          ..write('id: $id, ')
          ..write('purchaseInvoiceId: $purchaseInvoiceId, ')
          ..write('lineNo: $lineNo, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('lineTotalPiasters: $lineTotalPiasters, ')
          ..write(
            'invoiceDiscountSharePiasters: $invoiceDiscountSharePiasters, ',
          )
          ..write('netLineCostPiasters: $netLineCostPiasters, ')
          ..write('avgCostBeforePiasters: $avgCostBeforePiasters, ')
          ..write('avgCostAfterPiasters: $avgCostAfterPiasters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseInvoiceId,
    lineNo,
    productId,
    productNameSnapshot,
    qtyMilli,
    unitCostPiasters,
    discountPiasters,
    lineTotalPiasters,
    invoiceDiscountSharePiasters,
    netLineCostPiasters,
    avgCostBeforePiasters,
    avgCostAfterPiasters,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseItemRow &&
          other.id == this.id &&
          other.purchaseInvoiceId == this.purchaseInvoiceId &&
          other.lineNo == this.lineNo &&
          other.productId == this.productId &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.qtyMilli == this.qtyMilli &&
          other.unitCostPiasters == this.unitCostPiasters &&
          other.discountPiasters == this.discountPiasters &&
          other.lineTotalPiasters == this.lineTotalPiasters &&
          other.invoiceDiscountSharePiasters ==
              this.invoiceDiscountSharePiasters &&
          other.netLineCostPiasters == this.netLineCostPiasters &&
          other.avgCostBeforePiasters == this.avgCostBeforePiasters &&
          other.avgCostAfterPiasters == this.avgCostAfterPiasters &&
          other.createdAt == this.createdAt);
}

class PurchaseItemsCompanion extends UpdateCompanion<PurchaseItemRow> {
  final Value<String> id;
  final Value<String> purchaseInvoiceId;
  final Value<int> lineNo;
  final Value<String> productId;
  final Value<String> productNameSnapshot;
  final Value<int> qtyMilli;
  final Value<int> unitCostPiasters;
  final Value<int> discountPiasters;
  final Value<int> lineTotalPiasters;
  final Value<int> invoiceDiscountSharePiasters;
  final Value<int> netLineCostPiasters;
  final Value<int> avgCostBeforePiasters;
  final Value<int> avgCostAfterPiasters;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PurchaseItemsCompanion({
    this.id = const Value.absent(),
    this.purchaseInvoiceId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.productId = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.qtyMilli = const Value.absent(),
    this.unitCostPiasters = const Value.absent(),
    this.discountPiasters = const Value.absent(),
    this.lineTotalPiasters = const Value.absent(),
    this.invoiceDiscountSharePiasters = const Value.absent(),
    this.netLineCostPiasters = const Value.absent(),
    this.avgCostBeforePiasters = const Value.absent(),
    this.avgCostAfterPiasters = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseItemsCompanion.insert({
    required String id,
    required String purchaseInvoiceId,
    required int lineNo,
    required String productId,
    required String productNameSnapshot,
    required int qtyMilli,
    required int unitCostPiasters,
    this.discountPiasters = const Value.absent(),
    required int lineTotalPiasters,
    required int invoiceDiscountSharePiasters,
    required int netLineCostPiasters,
    required int avgCostBeforePiasters,
    required int avgCostAfterPiasters,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchaseInvoiceId = Value(purchaseInvoiceId),
       lineNo = Value(lineNo),
       productId = Value(productId),
       productNameSnapshot = Value(productNameSnapshot),
       qtyMilli = Value(qtyMilli),
       unitCostPiasters = Value(unitCostPiasters),
       lineTotalPiasters = Value(lineTotalPiasters),
       invoiceDiscountSharePiasters = Value(invoiceDiscountSharePiasters),
       netLineCostPiasters = Value(netLineCostPiasters),
       avgCostBeforePiasters = Value(avgCostBeforePiasters),
       avgCostAfterPiasters = Value(avgCostAfterPiasters),
       createdAt = Value(createdAt);
  static Insertable<PurchaseItemRow> custom({
    Expression<String>? id,
    Expression<String>? purchaseInvoiceId,
    Expression<int>? lineNo,
    Expression<String>? productId,
    Expression<String>? productNameSnapshot,
    Expression<int>? qtyMilli,
    Expression<int>? unitCostPiasters,
    Expression<int>? discountPiasters,
    Expression<int>? lineTotalPiasters,
    Expression<int>? invoiceDiscountSharePiasters,
    Expression<int>? netLineCostPiasters,
    Expression<int>? avgCostBeforePiasters,
    Expression<int>? avgCostAfterPiasters,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseInvoiceId != null) 'purchase_invoice_id': purchaseInvoiceId,
      if (lineNo != null) 'line_no': lineNo,
      if (productId != null) 'product_id': productId,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (qtyMilli != null) 'qty_milli': qtyMilli,
      if (unitCostPiasters != null) 'unit_cost_piasters': unitCostPiasters,
      if (discountPiasters != null) 'discount_piasters': discountPiasters,
      if (lineTotalPiasters != null) 'line_total_piasters': lineTotalPiasters,
      if (invoiceDiscountSharePiasters != null)
        'invoice_discount_share_piasters': invoiceDiscountSharePiasters,
      if (netLineCostPiasters != null)
        'net_line_cost_piasters': netLineCostPiasters,
      if (avgCostBeforePiasters != null)
        'avg_cost_before_piasters': avgCostBeforePiasters,
      if (avgCostAfterPiasters != null)
        'avg_cost_after_piasters': avgCostAfterPiasters,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? purchaseInvoiceId,
    Value<int>? lineNo,
    Value<String>? productId,
    Value<String>? productNameSnapshot,
    Value<int>? qtyMilli,
    Value<int>? unitCostPiasters,
    Value<int>? discountPiasters,
    Value<int>? lineTotalPiasters,
    Value<int>? invoiceDiscountSharePiasters,
    Value<int>? netLineCostPiasters,
    Value<int>? avgCostBeforePiasters,
    Value<int>? avgCostAfterPiasters,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PurchaseItemsCompanion(
      id: id ?? this.id,
      purchaseInvoiceId: purchaseInvoiceId ?? this.purchaseInvoiceId,
      lineNo: lineNo ?? this.lineNo,
      productId: productId ?? this.productId,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      qtyMilli: qtyMilli ?? this.qtyMilli,
      unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
      discountPiasters: discountPiasters ?? this.discountPiasters,
      lineTotalPiasters: lineTotalPiasters ?? this.lineTotalPiasters,
      invoiceDiscountSharePiasters:
          invoiceDiscountSharePiasters ?? this.invoiceDiscountSharePiasters,
      netLineCostPiasters: netLineCostPiasters ?? this.netLineCostPiasters,
      avgCostBeforePiasters:
          avgCostBeforePiasters ?? this.avgCostBeforePiasters,
      avgCostAfterPiasters: avgCostAfterPiasters ?? this.avgCostAfterPiasters,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseInvoiceId.present) {
      map['purchase_invoice_id'] = Variable<String>(purchaseInvoiceId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (qtyMilli.present) {
      map['qty_milli'] = Variable<int>(qtyMilli.value);
    }
    if (unitCostPiasters.present) {
      map['unit_cost_piasters'] = Variable<int>(unitCostPiasters.value);
    }
    if (discountPiasters.present) {
      map['discount_piasters'] = Variable<int>(discountPiasters.value);
    }
    if (lineTotalPiasters.present) {
      map['line_total_piasters'] = Variable<int>(lineTotalPiasters.value);
    }
    if (invoiceDiscountSharePiasters.present) {
      map['invoice_discount_share_piasters'] = Variable<int>(
        invoiceDiscountSharePiasters.value,
      );
    }
    if (netLineCostPiasters.present) {
      map['net_line_cost_piasters'] = Variable<int>(netLineCostPiasters.value);
    }
    if (avgCostBeforePiasters.present) {
      map['avg_cost_before_piasters'] = Variable<int>(
        avgCostBeforePiasters.value,
      );
    }
    if (avgCostAfterPiasters.present) {
      map['avg_cost_after_piasters'] = Variable<int>(
        avgCostAfterPiasters.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $PurchaseItemsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseInvoiceId: $purchaseInvoiceId, ')
          ..write('lineNo: $lineNo, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('qtyMilli: $qtyMilli, ')
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('discountPiasters: $discountPiasters, ')
          ..write('lineTotalPiasters: $lineTotalPiasters, ')
          ..write(
            'invoiceDiscountSharePiasters: $invoiceDiscountSharePiasters, ',
          )
          ..write('netLineCostPiasters: $netLineCostPiasters, ')
          ..write('avgCostBeforePiasters: $avgCostBeforePiasters, ')
          ..write('avgCostAfterPiasters: $avgCostAfterPiasters, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MovementType, String>
  movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MovementType>($StockMovementsTable.$convertermovementType);
  static const VerificationMeta _qtyDeltaMilliMeta = const VerificationMeta(
    'qtyDeltaMilli',
  );
  @override
  late final GeneratedColumn<int> qtyDeltaMilli = GeneratedColumn<int>(
    'qty_delta_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostPiastersMeta = const VerificationMeta(
    'unitCostPiasters',
  );
  @override
  late final GeneratedColumn<int> unitCostPiasters = GeneratedColumn<int>(
    'unit_cost_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleItemIdMeta = const VerificationMeta(
    'saleItemId',
  );
  @override
  late final GeneratedColumn<String> saleItemId = GeneratedColumn<String>(
    'sale_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_items (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _saleReturnItemIdMeta = const VerificationMeta(
    'saleReturnItemId',
  );
  @override
  late final GeneratedColumn<String> saleReturnItemId = GeneratedColumn<String>(
    'sale_return_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_return_items (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _purchaseItemIdMeta = const VerificationMeta(
    'purchaseItemId',
  );
  @override
  late final GeneratedColumn<String> purchaseItemId = GeneratedColumn<String>(
    'purchase_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchase_items (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _reversesMovementIdMeta =
      const VerificationMeta('reversesMovementId');
  @override
  late final GeneratedColumn<String> reversesMovementId =
      GeneratedColumn<String>(
        'reverses_movement_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES stock_movements (id) ON DELETE RESTRICT',
        ),
      );
  @override
  late final GeneratedColumnWithTypeConverter<AdjustmentReason?, String>
  adjustmentReason =
      GeneratedColumn<String>(
        'adjustment_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<AdjustmentReason?>(
        $StockMovementsTable.$converteradjustmentReasonn,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($StockMovementsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    movementType,
    qtyDeltaMilli,
    unitCostPiasters,
    saleItemId,
    saleReturnItemId,
    purchaseItemId,
    reversesMovementId,
    adjustmentReason,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('qty_delta_milli')) {
      context.handle(
        _qtyDeltaMilliMeta,
        qtyDeltaMilli.isAcceptableOrUnknown(
          data['qty_delta_milli']!,
          _qtyDeltaMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_qtyDeltaMilliMeta);
    }
    if (data.containsKey('unit_cost_piasters')) {
      context.handle(
        _unitCostPiastersMeta,
        unitCostPiasters.isAcceptableOrUnknown(
          data['unit_cost_piasters']!,
          _unitCostPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitCostPiastersMeta);
    }
    if (data.containsKey('sale_item_id')) {
      context.handle(
        _saleItemIdMeta,
        saleItemId.isAcceptableOrUnknown(
          data['sale_item_id']!,
          _saleItemIdMeta,
        ),
      );
    }
    if (data.containsKey('sale_return_item_id')) {
      context.handle(
        _saleReturnItemIdMeta,
        saleReturnItemId.isAcceptableOrUnknown(
          data['sale_return_item_id']!,
          _saleReturnItemIdMeta,
        ),
      );
    }
    if (data.containsKey('purchase_item_id')) {
      context.handle(
        _purchaseItemIdMeta,
        purchaseItemId.isAcceptableOrUnknown(
          data['purchase_item_id']!,
          _purchaseItemIdMeta,
        ),
      );
    }
    if (data.containsKey('reverses_movement_id')) {
      context.handle(
        _reversesMovementIdMeta,
        reversesMovementId.isAcceptableOrUnknown(
          data['reverses_movement_id']!,
          _reversesMovementIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      movementType: $StockMovementsTable.$convertermovementType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}movement_type'],
        )!,
      ),
      qtyDeltaMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty_delta_milli'],
      )!,
      unitCostPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost_piasters'],
      )!,
      saleItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_item_id'],
      ),
      saleReturnItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_return_item_id'],
      ),
      purchaseItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_item_id'],
      ),
      reversesMovementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_movement_id'],
      ),
      adjustmentReason: $StockMovementsTable.$converteradjustmentReasonn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}adjustment_reason'],
            ),
          ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $StockMovementsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MovementType, String, String>
  $convertermovementType = const EnumNameConverter<MovementType>(
    MovementType.values,
  );
  static JsonTypeConverter2<AdjustmentReason, String, String>
  $converteradjustmentReason = const EnumNameConverter<AdjustmentReason>(
    AdjustmentReason.values,
  );
  static JsonTypeConverter2<AdjustmentReason?, String?, String?>
  $converteradjustmentReasonn = JsonTypeConverter2.asNullable(
    $converteradjustmentReason,
  );
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
}

class StockMovementRow extends DataClass
    implements Insertable<StockMovementRow> {
  final String id;
  final String productId;
  final MovementType movementType;
  final int qtyDeltaMilli;
  final int unitCostPiasters;
  final String? saleItemId;
  final String? saleReturnItemId;
  final String? purchaseItemId;
  final String? reversesMovementId;
  final AdjustmentReason? adjustmentReason;
  final String? note;
  final DateTime createdAt;
  const StockMovementRow({
    required this.id,
    required this.productId,
    required this.movementType,
    required this.qtyDeltaMilli,
    required this.unitCostPiasters,
    this.saleItemId,
    this.saleReturnItemId,
    this.purchaseItemId,
    this.reversesMovementId,
    this.adjustmentReason,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    {
      map['movement_type'] = Variable<String>(
        $StockMovementsTable.$convertermovementType.toSql(movementType),
      );
    }
    map['qty_delta_milli'] = Variable<int>(qtyDeltaMilli);
    map['unit_cost_piasters'] = Variable<int>(unitCostPiasters);
    if (!nullToAbsent || saleItemId != null) {
      map['sale_item_id'] = Variable<String>(saleItemId);
    }
    if (!nullToAbsent || saleReturnItemId != null) {
      map['sale_return_item_id'] = Variable<String>(saleReturnItemId);
    }
    if (!nullToAbsent || purchaseItemId != null) {
      map['purchase_item_id'] = Variable<String>(purchaseItemId);
    }
    if (!nullToAbsent || reversesMovementId != null) {
      map['reverses_movement_id'] = Variable<String>(reversesMovementId);
    }
    if (!nullToAbsent || adjustmentReason != null) {
      map['adjustment_reason'] = Variable<String>(
        $StockMovementsTable.$converteradjustmentReasonn.toSql(
          adjustmentReason,
        ),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $StockMovementsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      movementType: Value(movementType),
      qtyDeltaMilli: Value(qtyDeltaMilli),
      unitCostPiasters: Value(unitCostPiasters),
      saleItemId: saleItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleItemId),
      saleReturnItemId: saleReturnItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleReturnItemId),
      purchaseItemId: purchaseItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseItemId),
      reversesMovementId: reversesMovementId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesMovementId),
      adjustmentReason: adjustmentReason == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustmentReason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      movementType: $StockMovementsTable.$convertermovementType.fromJson(
        serializer.fromJson<String>(json['movementType']),
      ),
      qtyDeltaMilli: serializer.fromJson<int>(json['qtyDeltaMilli']),
      unitCostPiasters: serializer.fromJson<int>(json['unitCostPiasters']),
      saleItemId: serializer.fromJson<String?>(json['saleItemId']),
      saleReturnItemId: serializer.fromJson<String?>(json['saleReturnItemId']),
      purchaseItemId: serializer.fromJson<String?>(json['purchaseItemId']),
      reversesMovementId: serializer.fromJson<String?>(
        json['reversesMovementId'],
      ),
      adjustmentReason: $StockMovementsTable.$converteradjustmentReasonn
          .fromJson(serializer.fromJson<String?>(json['adjustmentReason'])),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'movementType': serializer.toJson<String>(
        $StockMovementsTable.$convertermovementType.toJson(movementType),
      ),
      'qtyDeltaMilli': serializer.toJson<int>(qtyDeltaMilli),
      'unitCostPiasters': serializer.toJson<int>(unitCostPiasters),
      'saleItemId': serializer.toJson<String?>(saleItemId),
      'saleReturnItemId': serializer.toJson<String?>(saleReturnItemId),
      'purchaseItemId': serializer.toJson<String?>(purchaseItemId),
      'reversesMovementId': serializer.toJson<String?>(reversesMovementId),
      'adjustmentReason': serializer.toJson<String?>(
        $StockMovementsTable.$converteradjustmentReasonn.toJson(
          adjustmentReason,
        ),
      ),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockMovementRow copyWith({
    String? id,
    String? productId,
    MovementType? movementType,
    int? qtyDeltaMilli,
    int? unitCostPiasters,
    Value<String?> saleItemId = const Value.absent(),
    Value<String?> saleReturnItemId = const Value.absent(),
    Value<String?> purchaseItemId = const Value.absent(),
    Value<String?> reversesMovementId = const Value.absent(),
    Value<AdjustmentReason?> adjustmentReason = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => StockMovementRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    movementType: movementType ?? this.movementType,
    qtyDeltaMilli: qtyDeltaMilli ?? this.qtyDeltaMilli,
    unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
    saleItemId: saleItemId.present ? saleItemId.value : this.saleItemId,
    saleReturnItemId: saleReturnItemId.present
        ? saleReturnItemId.value
        : this.saleReturnItemId,
    purchaseItemId: purchaseItemId.present
        ? purchaseItemId.value
        : this.purchaseItemId,
    reversesMovementId: reversesMovementId.present
        ? reversesMovementId.value
        : this.reversesMovementId,
    adjustmentReason: adjustmentReason.present
        ? adjustmentReason.value
        : this.adjustmentReason,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovementRow copyWithCompanion(StockMovementsCompanion data) {
    return StockMovementRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      qtyDeltaMilli: data.qtyDeltaMilli.present
          ? data.qtyDeltaMilli.value
          : this.qtyDeltaMilli,
      unitCostPiasters: data.unitCostPiasters.present
          ? data.unitCostPiasters.value
          : this.unitCostPiasters,
      saleItemId: data.saleItemId.present
          ? data.saleItemId.value
          : this.saleItemId,
      saleReturnItemId: data.saleReturnItemId.present
          ? data.saleReturnItemId.value
          : this.saleReturnItemId,
      purchaseItemId: data.purchaseItemId.present
          ? data.purchaseItemId.value
          : this.purchaseItemId,
      reversesMovementId: data.reversesMovementId.present
          ? data.reversesMovementId.value
          : this.reversesMovementId,
      adjustmentReason: data.adjustmentReason.present
          ? data.adjustmentReason.value
          : this.adjustmentReason,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('qtyDeltaMilli: $qtyDeltaMilli, ')
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('saleItemId: $saleItemId, ')
          ..write('saleReturnItemId: $saleReturnItemId, ')
          ..write('purchaseItemId: $purchaseItemId, ')
          ..write('reversesMovementId: $reversesMovementId, ')
          ..write('adjustmentReason: $adjustmentReason, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    movementType,
    qtyDeltaMilli,
    unitCostPiasters,
    saleItemId,
    saleReturnItemId,
    purchaseItemId,
    reversesMovementId,
    adjustmentReason,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.movementType == this.movementType &&
          other.qtyDeltaMilli == this.qtyDeltaMilli &&
          other.unitCostPiasters == this.unitCostPiasters &&
          other.saleItemId == this.saleItemId &&
          other.saleReturnItemId == this.saleReturnItemId &&
          other.purchaseItemId == this.purchaseItemId &&
          other.reversesMovementId == this.reversesMovementId &&
          other.adjustmentReason == this.adjustmentReason &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovementRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<MovementType> movementType;
  final Value<int> qtyDeltaMilli;
  final Value<int> unitCostPiasters;
  final Value<String?> saleItemId;
  final Value<String?> saleReturnItemId;
  final Value<String?> purchaseItemId;
  final Value<String?> reversesMovementId;
  final Value<AdjustmentReason?> adjustmentReason;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.qtyDeltaMilli = const Value.absent(),
    this.unitCostPiasters = const Value.absent(),
    this.saleItemId = const Value.absent(),
    this.saleReturnItemId = const Value.absent(),
    this.purchaseItemId = const Value.absent(),
    this.reversesMovementId = const Value.absent(),
    this.adjustmentReason = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    required String productId,
    required MovementType movementType,
    required int qtyDeltaMilli,
    required int unitCostPiasters,
    this.saleItemId = const Value.absent(),
    this.saleReturnItemId = const Value.absent(),
    this.purchaseItemId = const Value.absent(),
    this.reversesMovementId = const Value.absent(),
    this.adjustmentReason = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       movementType = Value(movementType),
       qtyDeltaMilli = Value(qtyDeltaMilli),
       unitCostPiasters = Value(unitCostPiasters),
       createdAt = Value(createdAt);
  static Insertable<StockMovementRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? movementType,
    Expression<int>? qtyDeltaMilli,
    Expression<int>? unitCostPiasters,
    Expression<String>? saleItemId,
    Expression<String>? saleReturnItemId,
    Expression<String>? purchaseItemId,
    Expression<String>? reversesMovementId,
    Expression<String>? adjustmentReason,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (movementType != null) 'movement_type': movementType,
      if (qtyDeltaMilli != null) 'qty_delta_milli': qtyDeltaMilli,
      if (unitCostPiasters != null) 'unit_cost_piasters': unitCostPiasters,
      if (saleItemId != null) 'sale_item_id': saleItemId,
      if (saleReturnItemId != null) 'sale_return_item_id': saleReturnItemId,
      if (purchaseItemId != null) 'purchase_item_id': purchaseItemId,
      if (reversesMovementId != null)
        'reverses_movement_id': reversesMovementId,
      if (adjustmentReason != null) 'adjustment_reason': adjustmentReason,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<MovementType>? movementType,
    Value<int>? qtyDeltaMilli,
    Value<int>? unitCostPiasters,
    Value<String?>? saleItemId,
    Value<String?>? saleReturnItemId,
    Value<String?>? purchaseItemId,
    Value<String?>? reversesMovementId,
    Value<AdjustmentReason?>? adjustmentReason,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      movementType: movementType ?? this.movementType,
      qtyDeltaMilli: qtyDeltaMilli ?? this.qtyDeltaMilli,
      unitCostPiasters: unitCostPiasters ?? this.unitCostPiasters,
      saleItemId: saleItemId ?? this.saleItemId,
      saleReturnItemId: saleReturnItemId ?? this.saleReturnItemId,
      purchaseItemId: purchaseItemId ?? this.purchaseItemId,
      reversesMovementId: reversesMovementId ?? this.reversesMovementId,
      adjustmentReason: adjustmentReason ?? this.adjustmentReason,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(
        $StockMovementsTable.$convertermovementType.toSql(movementType.value),
      );
    }
    if (qtyDeltaMilli.present) {
      map['qty_delta_milli'] = Variable<int>(qtyDeltaMilli.value);
    }
    if (unitCostPiasters.present) {
      map['unit_cost_piasters'] = Variable<int>(unitCostPiasters.value);
    }
    if (saleItemId.present) {
      map['sale_item_id'] = Variable<String>(saleItemId.value);
    }
    if (saleReturnItemId.present) {
      map['sale_return_item_id'] = Variable<String>(saleReturnItemId.value);
    }
    if (purchaseItemId.present) {
      map['purchase_item_id'] = Variable<String>(purchaseItemId.value);
    }
    if (reversesMovementId.present) {
      map['reverses_movement_id'] = Variable<String>(reversesMovementId.value);
    }
    if (adjustmentReason.present) {
      map['adjustment_reason'] = Variable<String>(
        $StockMovementsTable.$converteradjustmentReasonn.toSql(
          adjustmentReason.value,
        ),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $StockMovementsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('movementType: $movementType, ')
          ..write('qtyDeltaMilli: $qtyDeltaMilli, ')
          ..write('unitCostPiasters: $unitCostPiasters, ')
          ..write('saleItemId: $saleItemId, ')
          ..write('saleReturnItemId: $saleReturnItemId, ')
          ..write('purchaseItemId: $purchaseItemId, ')
          ..write('reversesMovementId: $reversesMovementId, ')
          ..write('adjustmentReason: $adjustmentReason, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerLedgerTable extends CustomerLedger
    with TableInfo<$CustomerLedgerTable, CustomerLedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CustomerEntryType, String>
  entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<CustomerEntryType>($CustomerLedgerTable.$converterentryType);
  static const VerificationMeta _amountPiastersMeta = const VerificationMeta(
    'amountPiasters',
  );
  @override
  late final GeneratedColumn<int> amountPiasters = GeneratedColumn<int>(
    'amount_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salesInvoiceIdMeta = const VerificationMeta(
    'salesInvoiceId',
  );
  @override
  late final GeneratedColumn<String> salesInvoiceId = GeneratedColumn<String>(
    'sales_invoice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales_invoices (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _saleReturnIdMeta = const VerificationMeta(
    'saleReturnId',
  );
  @override
  late final GeneratedColumn<String> saleReturnId = GeneratedColumn<String>(
    'sale_return_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sale_returns (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _receiptNumberMeta = const VerificationMeta(
    'receiptNumber',
  );
  @override
  late final GeneratedColumn<int> receiptNumber = GeneratedColumn<int>(
    'receipt_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod?, String>
  paymentMethod =
      GeneratedColumn<String>(
        'payment_method',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PaymentMethod?>(
        $CustomerLedgerTable.$converterpaymentMethodn,
      );
  static const VerificationMeta _reversesEntryIdMeta = const VerificationMeta(
    'reversesEntryId',
  );
  @override
  late final GeneratedColumn<String> reversesEntryId = GeneratedColumn<String>(
    'reverses_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customer_ledger (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CustomerLedgerTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    entryType,
    amountPiasters,
    salesInvoiceId,
    saleReturnId,
    receiptNumber,
    paymentMethod,
    reversesEntryId,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerLedgerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('amount_piasters')) {
      context.handle(
        _amountPiastersMeta,
        amountPiasters.isAcceptableOrUnknown(
          data['amount_piasters']!,
          _amountPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPiastersMeta);
    }
    if (data.containsKey('sales_invoice_id')) {
      context.handle(
        _salesInvoiceIdMeta,
        salesInvoiceId.isAcceptableOrUnknown(
          data['sales_invoice_id']!,
          _salesInvoiceIdMeta,
        ),
      );
    }
    if (data.containsKey('sale_return_id')) {
      context.handle(
        _saleReturnIdMeta,
        saleReturnId.isAcceptableOrUnknown(
          data['sale_return_id']!,
          _saleReturnIdMeta,
        ),
      );
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
        _receiptNumberMeta,
        receiptNumber.isAcceptableOrUnknown(
          data['receipt_number']!,
          _receiptNumberMeta,
        ),
      );
    }
    if (data.containsKey('reverses_entry_id')) {
      context.handle(
        _reversesEntryIdMeta,
        reversesEntryId.isAcceptableOrUnknown(
          data['reverses_entry_id']!,
          _reversesEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerLedgerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerLedgerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      entryType: $CustomerLedgerTable.$converterentryType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entry_type'],
        )!,
      ),
      amountPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_piasters'],
      )!,
      salesInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sales_invoice_id'],
      ),
      saleReturnId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_return_id'],
      ),
      receiptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receipt_number'],
      ),
      paymentMethod: $CustomerLedgerTable.$converterpaymentMethodn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        ),
      ),
      reversesEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_entry_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $CustomerLedgerTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $CustomerLedgerTable createAlias(String alias) {
    return $CustomerLedgerTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CustomerEntryType, String, String>
  $converterentryType = const EnumNameConverter<CustomerEntryType>(
    CustomerEntryType.values,
  );
  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static JsonTypeConverter2<PaymentMethod?, String?, String?>
  $converterpaymentMethodn = JsonTypeConverter2.asNullable(
    $converterpaymentMethod,
  );
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
}

class CustomerLedgerRow extends DataClass
    implements Insertable<CustomerLedgerRow> {
  final String id;
  final String customerId;
  final CustomerEntryType entryType;
  final int amountPiasters;
  final String? salesInvoiceId;
  final String? saleReturnId;
  final int? receiptNumber;
  final PaymentMethod? paymentMethod;
  final String? reversesEntryId;
  final String? note;
  final DateTime createdAt;
  const CustomerLedgerRow({
    required this.id,
    required this.customerId,
    required this.entryType,
    required this.amountPiasters,
    this.salesInvoiceId,
    this.saleReturnId,
    this.receiptNumber,
    this.paymentMethod,
    this.reversesEntryId,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    {
      map['entry_type'] = Variable<String>(
        $CustomerLedgerTable.$converterentryType.toSql(entryType),
      );
    }
    map['amount_piasters'] = Variable<int>(amountPiasters);
    if (!nullToAbsent || salesInvoiceId != null) {
      map['sales_invoice_id'] = Variable<String>(salesInvoiceId);
    }
    if (!nullToAbsent || saleReturnId != null) {
      map['sale_return_id'] = Variable<String>(saleReturnId);
    }
    if (!nullToAbsent || receiptNumber != null) {
      map['receipt_number'] = Variable<int>(receiptNumber);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(
        $CustomerLedgerTable.$converterpaymentMethodn.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || reversesEntryId != null) {
      map['reverses_entry_id'] = Variable<String>(reversesEntryId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $CustomerLedgerTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  CustomerLedgerCompanion toCompanion(bool nullToAbsent) {
    return CustomerLedgerCompanion(
      id: Value(id),
      customerId: Value(customerId),
      entryType: Value(entryType),
      amountPiasters: Value(amountPiasters),
      salesInvoiceId: salesInvoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(salesInvoiceId),
      saleReturnId: saleReturnId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleReturnId),
      receiptNumber: receiptNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptNumber),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      reversesEntryId: reversesEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesEntryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory CustomerLedgerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerLedgerRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      entryType: $CustomerLedgerTable.$converterentryType.fromJson(
        serializer.fromJson<String>(json['entryType']),
      ),
      amountPiasters: serializer.fromJson<int>(json['amountPiasters']),
      salesInvoiceId: serializer.fromJson<String?>(json['salesInvoiceId']),
      saleReturnId: serializer.fromJson<String?>(json['saleReturnId']),
      receiptNumber: serializer.fromJson<int?>(json['receiptNumber']),
      paymentMethod: $CustomerLedgerTable.$converterpaymentMethodn.fromJson(
        serializer.fromJson<String?>(json['paymentMethod']),
      ),
      reversesEntryId: serializer.fromJson<String?>(json['reversesEntryId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'entryType': serializer.toJson<String>(
        $CustomerLedgerTable.$converterentryType.toJson(entryType),
      ),
      'amountPiasters': serializer.toJson<int>(amountPiasters),
      'salesInvoiceId': serializer.toJson<String?>(salesInvoiceId),
      'saleReturnId': serializer.toJson<String?>(saleReturnId),
      'receiptNumber': serializer.toJson<int?>(receiptNumber),
      'paymentMethod': serializer.toJson<String?>(
        $CustomerLedgerTable.$converterpaymentMethodn.toJson(paymentMethod),
      ),
      'reversesEntryId': serializer.toJson<String?>(reversesEntryId),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomerLedgerRow copyWith({
    String? id,
    String? customerId,
    CustomerEntryType? entryType,
    int? amountPiasters,
    Value<String?> salesInvoiceId = const Value.absent(),
    Value<String?> saleReturnId = const Value.absent(),
    Value<int?> receiptNumber = const Value.absent(),
    Value<PaymentMethod?> paymentMethod = const Value.absent(),
    Value<String?> reversesEntryId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => CustomerLedgerRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    entryType: entryType ?? this.entryType,
    amountPiasters: amountPiasters ?? this.amountPiasters,
    salesInvoiceId: salesInvoiceId.present
        ? salesInvoiceId.value
        : this.salesInvoiceId,
    saleReturnId: saleReturnId.present ? saleReturnId.value : this.saleReturnId,
    receiptNumber: receiptNumber.present
        ? receiptNumber.value
        : this.receiptNumber,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    reversesEntryId: reversesEntryId.present
        ? reversesEntryId.value
        : this.reversesEntryId,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomerLedgerRow copyWithCompanion(CustomerLedgerCompanion data) {
    return CustomerLedgerRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      amountPiasters: data.amountPiasters.present
          ? data.amountPiasters.value
          : this.amountPiasters,
      salesInvoiceId: data.salesInvoiceId.present
          ? data.salesInvoiceId.value
          : this.salesInvoiceId,
      saleReturnId: data.saleReturnId.present
          ? data.saleReturnId.value
          : this.saleReturnId,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      reversesEntryId: data.reversesEntryId.present
          ? data.reversesEntryId.value
          : this.reversesEntryId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerLedgerRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('entryType: $entryType, ')
          ..write('amountPiasters: $amountPiasters, ')
          ..write('salesInvoiceId: $salesInvoiceId, ')
          ..write('saleReturnId: $saleReturnId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reversesEntryId: $reversesEntryId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    entryType,
    amountPiasters,
    salesInvoiceId,
    saleReturnId,
    receiptNumber,
    paymentMethod,
    reversesEntryId,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerLedgerRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.entryType == this.entryType &&
          other.amountPiasters == this.amountPiasters &&
          other.salesInvoiceId == this.salesInvoiceId &&
          other.saleReturnId == this.saleReturnId &&
          other.receiptNumber == this.receiptNumber &&
          other.paymentMethod == this.paymentMethod &&
          other.reversesEntryId == this.reversesEntryId &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class CustomerLedgerCompanion extends UpdateCompanion<CustomerLedgerRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<CustomerEntryType> entryType;
  final Value<int> amountPiasters;
  final Value<String?> salesInvoiceId;
  final Value<String?> saleReturnId;
  final Value<int?> receiptNumber;
  final Value<PaymentMethod?> paymentMethod;
  final Value<String?> reversesEntryId;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomerLedgerCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.amountPiasters = const Value.absent(),
    this.salesInvoiceId = const Value.absent(),
    this.saleReturnId = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerLedgerCompanion.insert({
    required String id,
    required String customerId,
    required CustomerEntryType entryType,
    required int amountPiasters,
    this.salesInvoiceId = const Value.absent(),
    this.saleReturnId = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       entryType = Value(entryType),
       amountPiasters = Value(amountPiasters),
       createdAt = Value(createdAt);
  static Insertable<CustomerLedgerRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? entryType,
    Expression<int>? amountPiasters,
    Expression<String>? salesInvoiceId,
    Expression<String>? saleReturnId,
    Expression<int>? receiptNumber,
    Expression<String>? paymentMethod,
    Expression<String>? reversesEntryId,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (entryType != null) 'entry_type': entryType,
      if (amountPiasters != null) 'amount_piasters': amountPiasters,
      if (salesInvoiceId != null) 'sales_invoice_id': salesInvoiceId,
      if (saleReturnId != null) 'sale_return_id': saleReturnId,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (reversesEntryId != null) 'reverses_entry_id': reversesEntryId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<CustomerEntryType>? entryType,
    Value<int>? amountPiasters,
    Value<String?>? salesInvoiceId,
    Value<String?>? saleReturnId,
    Value<int?>? receiptNumber,
    Value<PaymentMethod?>? paymentMethod,
    Value<String?>? reversesEntryId,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomerLedgerCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      entryType: entryType ?? this.entryType,
      amountPiasters: amountPiasters ?? this.amountPiasters,
      salesInvoiceId: salesInvoiceId ?? this.salesInvoiceId,
      saleReturnId: saleReturnId ?? this.saleReturnId,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reversesEntryId: reversesEntryId ?? this.reversesEntryId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(
        $CustomerLedgerTable.$converterentryType.toSql(entryType.value),
      );
    }
    if (amountPiasters.present) {
      map['amount_piasters'] = Variable<int>(amountPiasters.value);
    }
    if (salesInvoiceId.present) {
      map['sales_invoice_id'] = Variable<String>(salesInvoiceId.value);
    }
    if (saleReturnId.present) {
      map['sale_return_id'] = Variable<String>(saleReturnId.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<int>(receiptNumber.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $CustomerLedgerTable.$converterpaymentMethodn.toSql(
          paymentMethod.value,
        ),
      );
    }
    if (reversesEntryId.present) {
      map['reverses_entry_id'] = Variable<String>(reversesEntryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $CustomerLedgerTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerLedgerCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('entryType: $entryType, ')
          ..write('amountPiasters: $amountPiasters, ')
          ..write('salesInvoiceId: $salesInvoiceId, ')
          ..write('saleReturnId: $saleReturnId, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reversesEntryId: $reversesEntryId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierLedgerTable extends SupplierLedger
    with TableInfo<$SupplierLedgerTable, SupplierLedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id) ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SupplierEntryType, String>
  entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SupplierEntryType>($SupplierLedgerTable.$converterentryType);
  static const VerificationMeta _amountPiastersMeta = const VerificationMeta(
    'amountPiasters',
  );
  @override
  late final GeneratedColumn<int> amountPiasters = GeneratedColumn<int>(
    'amount_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseInvoiceIdMeta = const VerificationMeta(
    'purchaseInvoiceId',
  );
  @override
  late final GeneratedColumn<String> purchaseInvoiceId =
      GeneratedColumn<String>(
        'purchase_invoice_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES purchase_invoices (id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _paymentNumberMeta = const VerificationMeta(
    'paymentNumber',
  );
  @override
  late final GeneratedColumn<int> paymentNumber = GeneratedColumn<int>(
    'payment_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentMethod?, String>
  paymentMethod =
      GeneratedColumn<String>(
        'payment_method',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PaymentMethod?>(
        $SupplierLedgerTable.$converterpaymentMethodn,
      );
  static const VerificationMeta _reversesEntryIdMeta = const VerificationMeta(
    'reversesEntryId',
  );
  @override
  late final GeneratedColumn<String> reversesEntryId = GeneratedColumn<String>(
    'reverses_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_ledger (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SupplierLedgerTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    entryType,
    amountPiasters,
    purchaseInvoiceId,
    paymentNumber,
    paymentMethod,
    reversesEntryId,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierLedgerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('amount_piasters')) {
      context.handle(
        _amountPiastersMeta,
        amountPiasters.isAcceptableOrUnknown(
          data['amount_piasters']!,
          _amountPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPiastersMeta);
    }
    if (data.containsKey('purchase_invoice_id')) {
      context.handle(
        _purchaseInvoiceIdMeta,
        purchaseInvoiceId.isAcceptableOrUnknown(
          data['purchase_invoice_id']!,
          _purchaseInvoiceIdMeta,
        ),
      );
    }
    if (data.containsKey('payment_number')) {
      context.handle(
        _paymentNumberMeta,
        paymentNumber.isAcceptableOrUnknown(
          data['payment_number']!,
          _paymentNumberMeta,
        ),
      );
    }
    if (data.containsKey('reverses_entry_id')) {
      context.handle(
        _reversesEntryIdMeta,
        reversesEntryId.isAcceptableOrUnknown(
          data['reverses_entry_id']!,
          _reversesEntryIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierLedgerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierLedgerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      )!,
      entryType: $SupplierLedgerTable.$converterentryType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entry_type'],
        )!,
      ),
      amountPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_piasters'],
      )!,
      purchaseInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_invoice_id'],
      ),
      paymentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_number'],
      ),
      paymentMethod: $SupplierLedgerTable.$converterpaymentMethodn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_method'],
        ),
      ),
      reversesEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_entry_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $SupplierLedgerTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $SupplierLedgerTable createAlias(String alias) {
    return $SupplierLedgerTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SupplierEntryType, String, String>
  $converterentryType = const EnumNameConverter<SupplierEntryType>(
    SupplierEntryType.values,
  );
  static JsonTypeConverter2<PaymentMethod, String, String>
  $converterpaymentMethod = const EnumNameConverter<PaymentMethod>(
    PaymentMethod.values,
  );
  static JsonTypeConverter2<PaymentMethod?, String?, String?>
  $converterpaymentMethodn = JsonTypeConverter2.asNullable(
    $converterpaymentMethod,
  );
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
}

class SupplierLedgerRow extends DataClass
    implements Insertable<SupplierLedgerRow> {
  final String id;
  final String supplierId;
  final SupplierEntryType entryType;
  final int amountPiasters;
  final String? purchaseInvoiceId;
  final int? paymentNumber;
  final PaymentMethod? paymentMethod;
  final String? reversesEntryId;
  final String? note;
  final DateTime createdAt;
  const SupplierLedgerRow({
    required this.id,
    required this.supplierId,
    required this.entryType,
    required this.amountPiasters,
    this.purchaseInvoiceId,
    this.paymentNumber,
    this.paymentMethod,
    this.reversesEntryId,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['supplier_id'] = Variable<String>(supplierId);
    {
      map['entry_type'] = Variable<String>(
        $SupplierLedgerTable.$converterentryType.toSql(entryType),
      );
    }
    map['amount_piasters'] = Variable<int>(amountPiasters);
    if (!nullToAbsent || purchaseInvoiceId != null) {
      map['purchase_invoice_id'] = Variable<String>(purchaseInvoiceId);
    }
    if (!nullToAbsent || paymentNumber != null) {
      map['payment_number'] = Variable<int>(paymentNumber);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(
        $SupplierLedgerTable.$converterpaymentMethodn.toSql(paymentMethod),
      );
    }
    if (!nullToAbsent || reversesEntryId != null) {
      map['reverses_entry_id'] = Variable<String>(reversesEntryId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $SupplierLedgerTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  SupplierLedgerCompanion toCompanion(bool nullToAbsent) {
    return SupplierLedgerCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      entryType: Value(entryType),
      amountPiasters: Value(amountPiasters),
      purchaseInvoiceId: purchaseInvoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseInvoiceId),
      paymentNumber: paymentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentNumber),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      reversesEntryId: reversesEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesEntryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory SupplierLedgerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierLedgerRow(
      id: serializer.fromJson<String>(json['id']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      entryType: $SupplierLedgerTable.$converterentryType.fromJson(
        serializer.fromJson<String>(json['entryType']),
      ),
      amountPiasters: serializer.fromJson<int>(json['amountPiasters']),
      purchaseInvoiceId: serializer.fromJson<String?>(
        json['purchaseInvoiceId'],
      ),
      paymentNumber: serializer.fromJson<int?>(json['paymentNumber']),
      paymentMethod: $SupplierLedgerTable.$converterpaymentMethodn.fromJson(
        serializer.fromJson<String?>(json['paymentMethod']),
      ),
      reversesEntryId: serializer.fromJson<String?>(json['reversesEntryId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'supplierId': serializer.toJson<String>(supplierId),
      'entryType': serializer.toJson<String>(
        $SupplierLedgerTable.$converterentryType.toJson(entryType),
      ),
      'amountPiasters': serializer.toJson<int>(amountPiasters),
      'purchaseInvoiceId': serializer.toJson<String?>(purchaseInvoiceId),
      'paymentNumber': serializer.toJson<int?>(paymentNumber),
      'paymentMethod': serializer.toJson<String?>(
        $SupplierLedgerTable.$converterpaymentMethodn.toJson(paymentMethod),
      ),
      'reversesEntryId': serializer.toJson<String?>(reversesEntryId),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SupplierLedgerRow copyWith({
    String? id,
    String? supplierId,
    SupplierEntryType? entryType,
    int? amountPiasters,
    Value<String?> purchaseInvoiceId = const Value.absent(),
    Value<int?> paymentNumber = const Value.absent(),
    Value<PaymentMethod?> paymentMethod = const Value.absent(),
    Value<String?> reversesEntryId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => SupplierLedgerRow(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    entryType: entryType ?? this.entryType,
    amountPiasters: amountPiasters ?? this.amountPiasters,
    purchaseInvoiceId: purchaseInvoiceId.present
        ? purchaseInvoiceId.value
        : this.purchaseInvoiceId,
    paymentNumber: paymentNumber.present
        ? paymentNumber.value
        : this.paymentNumber,
    paymentMethod: paymentMethod.present
        ? paymentMethod.value
        : this.paymentMethod,
    reversesEntryId: reversesEntryId.present
        ? reversesEntryId.value
        : this.reversesEntryId,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  SupplierLedgerRow copyWithCompanion(SupplierLedgerCompanion data) {
    return SupplierLedgerRow(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      amountPiasters: data.amountPiasters.present
          ? data.amountPiasters.value
          : this.amountPiasters,
      purchaseInvoiceId: data.purchaseInvoiceId.present
          ? data.purchaseInvoiceId.value
          : this.purchaseInvoiceId,
      paymentNumber: data.paymentNumber.present
          ? data.paymentNumber.value
          : this.paymentNumber,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      reversesEntryId: data.reversesEntryId.present
          ? data.reversesEntryId.value
          : this.reversesEntryId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierLedgerRow(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('entryType: $entryType, ')
          ..write('amountPiasters: $amountPiasters, ')
          ..write('purchaseInvoiceId: $purchaseInvoiceId, ')
          ..write('paymentNumber: $paymentNumber, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reversesEntryId: $reversesEntryId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    entryType,
    amountPiasters,
    purchaseInvoiceId,
    paymentNumber,
    paymentMethod,
    reversesEntryId,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierLedgerRow &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.entryType == this.entryType &&
          other.amountPiasters == this.amountPiasters &&
          other.purchaseInvoiceId == this.purchaseInvoiceId &&
          other.paymentNumber == this.paymentNumber &&
          other.paymentMethod == this.paymentMethod &&
          other.reversesEntryId == this.reversesEntryId &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class SupplierLedgerCompanion extends UpdateCompanion<SupplierLedgerRow> {
  final Value<String> id;
  final Value<String> supplierId;
  final Value<SupplierEntryType> entryType;
  final Value<int> amountPiasters;
  final Value<String?> purchaseInvoiceId;
  final Value<int?> paymentNumber;
  final Value<PaymentMethod?> paymentMethod;
  final Value<String?> reversesEntryId;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SupplierLedgerCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.entryType = const Value.absent(),
    this.amountPiasters = const Value.absent(),
    this.purchaseInvoiceId = const Value.absent(),
    this.paymentNumber = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierLedgerCompanion.insert({
    required String id,
    required String supplierId,
    required SupplierEntryType entryType,
    required int amountPiasters,
    this.purchaseInvoiceId = const Value.absent(),
    this.paymentNumber = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reversesEntryId = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierId = Value(supplierId),
       entryType = Value(entryType),
       amountPiasters = Value(amountPiasters),
       createdAt = Value(createdAt);
  static Insertable<SupplierLedgerRow> custom({
    Expression<String>? id,
    Expression<String>? supplierId,
    Expression<String>? entryType,
    Expression<int>? amountPiasters,
    Expression<String>? purchaseInvoiceId,
    Expression<int>? paymentNumber,
    Expression<String>? paymentMethod,
    Expression<String>? reversesEntryId,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (entryType != null) 'entry_type': entryType,
      if (amountPiasters != null) 'amount_piasters': amountPiasters,
      if (purchaseInvoiceId != null) 'purchase_invoice_id': purchaseInvoiceId,
      if (paymentNumber != null) 'payment_number': paymentNumber,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (reversesEntryId != null) 'reverses_entry_id': reversesEntryId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? supplierId,
    Value<SupplierEntryType>? entryType,
    Value<int>? amountPiasters,
    Value<String?>? purchaseInvoiceId,
    Value<int?>? paymentNumber,
    Value<PaymentMethod?>? paymentMethod,
    Value<String?>? reversesEntryId,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SupplierLedgerCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      entryType: entryType ?? this.entryType,
      amountPiasters: amountPiasters ?? this.amountPiasters,
      purchaseInvoiceId: purchaseInvoiceId ?? this.purchaseInvoiceId,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reversesEntryId: reversesEntryId ?? this.reversesEntryId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(
        $SupplierLedgerTable.$converterentryType.toSql(entryType.value),
      );
    }
    if (amountPiasters.present) {
      map['amount_piasters'] = Variable<int>(amountPiasters.value);
    }
    if (purchaseInvoiceId.present) {
      map['purchase_invoice_id'] = Variable<String>(purchaseInvoiceId.value);
    }
    if (paymentNumber.present) {
      map['payment_number'] = Variable<int>(paymentNumber.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(
        $SupplierLedgerTable.$converterpaymentMethodn.toSql(
          paymentMethod.value,
        ),
      );
    }
    if (reversesEntryId.present) {
      map['reverses_entry_id'] = Variable<String>(reversesEntryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $SupplierLedgerTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierLedgerCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('entryType: $entryType, ')
          ..write('amountPiasters: $amountPiasters, ')
          ..write('purchaseInvoiceId: $purchaseInvoiceId, ')
          ..write('paymentNumber: $paymentNumber, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reversesEntryId: $reversesEntryId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _expenseCategoryIdMeta = const VerificationMeta(
    'expenseCategoryId',
  );
  @override
  late final GeneratedColumn<String> expenseCategoryId =
      GeneratedColumn<String>(
        'expense_category_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES expense_categories (id) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _amountPiastersMeta = const VerificationMeta(
    'amountPiasters',
  );
  @override
  late final GeneratedColumn<int> amountPiasters = GeneratedColumn<int>(
    'amount_piasters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> spentAt =
      GeneratedColumn<int>(
        'spent_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExpensesTable.$converterspentAt);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExpensesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExpensesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> voidedAt =
      GeneratedColumn<int>(
        'voided_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ExpensesTable.$convertervoidedAtn);
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    expenseCategoryId,
    amountPiasters,
    spentAt,
    note,
    createdAt,
    updatedAt,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('expense_category_id')) {
      context.handle(
        _expenseCategoryIdMeta,
        expenseCategoryId.isAcceptableOrUnknown(
          data['expense_category_id']!,
          _expenseCategoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expenseCategoryIdMeta);
    }
    if (data.containsKey('amount_piasters')) {
      context.handle(
        _amountPiastersMeta,
        amountPiasters.isAcceptableOrUnknown(
          data['amount_piasters']!,
          _amountPiastersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPiastersMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      expenseCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_category_id'],
      )!,
      amountPiasters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_piasters'],
      )!,
      spentAt: $ExpensesTable.$converterspentAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}spent_at'],
        )!,
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: $ExpensesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $ExpensesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      voidedAt: $ExpensesTable.$convertervoidedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}voided_at'],
        ),
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterspentAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime, int> $convertervoidedAt =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $convertervoidedAtn =
      NullAwareTypeConverter.wrap($convertervoidedAt);
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final int number;
  final String expenseCategoryId;
  final int amountPiasters;
  final DateTime spentAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? voidedAt;
  final String? voidReason;
  const ExpenseRow({
    required this.id,
    required this.number,
    required this.expenseCategoryId,
    required this.amountPiasters,
    required this.spentAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['number'] = Variable<int>(number);
    map['expense_category_id'] = Variable<String>(expenseCategoryId);
    map['amount_piasters'] = Variable<int>(amountPiasters);
    {
      map['spent_at'] = Variable<int>(
        $ExpensesTable.$converterspentAt.toSql(spentAt),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['created_at'] = Variable<int>(
        $ExpensesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $ExpensesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<int>(
        $ExpensesTable.$convertervoidedAtn.toSql(voidedAt),
      );
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      number: Value(number),
      expenseCategoryId: Value(expenseCategoryId),
      amountPiasters: Value(amountPiasters),
      spentAt: Value(spentAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      expenseCategoryId: serializer.fromJson<String>(json['expenseCategoryId']),
      amountPiasters: serializer.fromJson<int>(json['amountPiasters']),
      spentAt: serializer.fromJson<DateTime>(json['spentAt']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<int>(number),
      'expenseCategoryId': serializer.toJson<String>(expenseCategoryId),
      'amountPiasters': serializer.toJson<int>(amountPiasters),
      'spentAt': serializer.toJson<DateTime>(spentAt),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  ExpenseRow copyWith({
    String? id,
    int? number,
    String? expenseCategoryId,
    int? amountPiasters,
    DateTime? spentAt,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => ExpenseRow(
    id: id ?? this.id,
    number: number ?? this.number,
    expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
    amountPiasters: amountPiasters ?? this.amountPiasters,
    spentAt: spentAt ?? this.spentAt,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      expenseCategoryId: data.expenseCategoryId.present
          ? data.expenseCategoryId.value
          : this.expenseCategoryId,
      amountPiasters: data.amountPiasters.present
          ? data.amountPiasters.value
          : this.amountPiasters,
      spentAt: data.spentAt.present ? data.spentAt.value : this.spentAt,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('amountPiasters: $amountPiasters, ')
          ..write('spentAt: $spentAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    expenseCategoryId,
    amountPiasters,
    spentAt,
    note,
    createdAt,
    updatedAt,
    voidedAt,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.expenseCategoryId == this.expenseCategoryId &&
          other.amountPiasters == this.amountPiasters &&
          other.spentAt == this.spentAt &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<int> number;
  final Value<String> expenseCategoryId;
  final Value<int> amountPiasters;
  final Value<DateTime> spentAt;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.expenseCategoryId = const Value.absent(),
    this.amountPiasters = const Value.absent(),
    this.spentAt = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required int number,
    required String expenseCategoryId,
    required int amountPiasters,
    required DateTime spentAt,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       number = Value(number),
       expenseCategoryId = Value(expenseCategoryId),
       amountPiasters = Value(amountPiasters),
       spentAt = Value(spentAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<int>? number,
    Expression<String>? expenseCategoryId,
    Expression<int>? amountPiasters,
    Expression<int>? spentAt,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (expenseCategoryId != null) 'expense_category_id': expenseCategoryId,
      if (amountPiasters != null) 'amount_piasters': amountPiasters,
      if (spentAt != null) 'spent_at': spentAt,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<int>? number,
    Value<String>? expenseCategoryId,
    Value<int>? amountPiasters,
    Value<DateTime>? spentAt,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
      amountPiasters: amountPiasters ?? this.amountPiasters,
      spentAt: spentAt ?? this.spentAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (expenseCategoryId.present) {
      map['expense_category_id'] = Variable<String>(expenseCategoryId.value);
    }
    if (amountPiasters.present) {
      map['amount_piasters'] = Variable<int>(amountPiasters.value);
    }
    if (spentAt.present) {
      map['spent_at'] = Variable<int>(
        $ExpensesTable.$converterspentAt.toSql(spentAt.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ExpensesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ExpensesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<int>(
        $ExpensesTable.$convertervoidedAtn.toSql(voidedAt.value),
      );
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('expenseCategoryId: $expenseCategoryId, ')
          ..write('amountPiasters: $amountPiasters, ')
          ..write('spentAt: $spentAt, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CountersTable counters = $CountersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $SalesInvoicesTable salesInvoices = $SalesInvoicesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $SaleReturnsTable saleReturns = $SaleReturnsTable(this);
  late final $SaleReturnItemsTable saleReturnItems = $SaleReturnItemsTable(
    this,
  );
  late final $PurchaseInvoicesTable purchaseInvoices = $PurchaseInvoicesTable(
    this,
  );
  late final $PurchaseItemsTable purchaseItems = $PurchaseItemsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $CustomerLedgerTable customerLedger = $CustomerLedgerTable(this);
  late final $SupplierLedgerTable supplierLedger = $SupplierLedgerTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    counters,
    categories,
    products,
    customers,
    suppliers,
    expenseCategories,
    salesInvoices,
    saleItems,
    saleReturns,
    saleReturnItems,
    purchaseInvoices,
    purchaseItems,
    stockMovements,
    customerLedger,
    supplierLedger,
    expenses,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String id,
      Value<int> singleton,
      Value<String?> shopName,
      Value<String?> shopPhone,
      Value<String?> shopAddress,
      Value<String?> invoiceFooter,
      Value<LocaleCode> localeCode,
      Value<DigitStylePreference> digitStyle,
      Value<NegativeStockPolicy> negativeStockPolicy,
      Value<bool> appLockEnabled,
      Value<bool> biometricEnabled,
      required String deviceId,
      Value<DateTime?> onboardingCompletedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<int> singleton,
      Value<String?> shopName,
      Value<String?> shopPhone,
      Value<String?> shopAddress,
      Value<String?> invoiceFooter,
      Value<LocaleCode> localeCode,
      Value<DigitStylePreference> digitStyle,
      Value<NegativeStockPolicy> negativeStockPolicy,
      Value<bool> appLockEnabled,
      Value<bool> biometricEnabled,
      Value<String> deviceId,
      Value<DateTime?> onboardingCompletedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopPhone => $composableBuilder(
    column: $table.shopPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopAddress => $composableBuilder(
    column: $table.shopAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceFooter => $composableBuilder(
    column: $table.invoiceFooter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocaleCode, LocaleCode, String>
  get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    DigitStylePreference,
    DigitStylePreference,
    String
  >
  get digitStyle => $composableBuilder(
    column: $table.digitStyle,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    NegativeStockPolicy,
    NegativeStockPolicy,
    String
  >
  get negativeStockPolicy => $composableBuilder(
    column: $table.negativeStockPolicy,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get biometricEnabled => $composableBuilder(
    column: $table.biometricEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int>
  get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get singleton => $composableBuilder(
    column: $table.singleton,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopPhone => $composableBuilder(
    column: $table.shopPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopAddress => $composableBuilder(
    column: $table.shopAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceFooter => $composableBuilder(
    column: $table.invoiceFooter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeCode => $composableBuilder(
    column: $table.localeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get digitStyle => $composableBuilder(
    column: $table.digitStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get negativeStockPolicy => $composableBuilder(
    column: $table.negativeStockPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get biometricEnabled => $composableBuilder(
    column: $table.biometricEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardingCompletedAt => $composableBuilder(
    column: $table.onboardingCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get singleton =>
      $composableBuilder(column: $table.singleton, builder: (column) => column);

  GeneratedColumn<String> get shopName =>
      $composableBuilder(column: $table.shopName, builder: (column) => column);

  GeneratedColumn<String> get shopPhone =>
      $composableBuilder(column: $table.shopPhone, builder: (column) => column);

  GeneratedColumn<String> get shopAddress => $composableBuilder(
    column: $table.shopAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceFooter => $composableBuilder(
    column: $table.invoiceFooter,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocaleCode, String> get localeCode =>
      $composableBuilder(
        column: $table.localeCode,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DigitStylePreference, String>
  get digitStyle => $composableBuilder(
    column: $table.digitStyle,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<NegativeStockPolicy, String>
  get negativeStockPolicy => $composableBuilder(
    column: $table.negativeStockPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get appLockEnabled => $composableBuilder(
    column: $table.appLockEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get biometricEnabled => $composableBuilder(
    column: $table.biometricEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get onboardingCompletedAt =>
      $composableBuilder(
        column: $table.onboardingCompletedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingsRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> singleton = const Value.absent(),
                Value<String?> shopName = const Value.absent(),
                Value<String?> shopPhone = const Value.absent(),
                Value<String?> shopAddress = const Value.absent(),
                Value<String?> invoiceFooter = const Value.absent(),
                Value<LocaleCode> localeCode = const Value.absent(),
                Value<DigitStylePreference> digitStyle = const Value.absent(),
                Value<NegativeStockPolicy> negativeStockPolicy =
                    const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> biometricEnabled = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                singleton: singleton,
                shopName: shopName,
                shopPhone: shopPhone,
                shopAddress: shopAddress,
                invoiceFooter: invoiceFooter,
                localeCode: localeCode,
                digitStyle: digitStyle,
                negativeStockPolicy: negativeStockPolicy,
                appLockEnabled: appLockEnabled,
                biometricEnabled: biometricEnabled,
                deviceId: deviceId,
                onboardingCompletedAt: onboardingCompletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> singleton = const Value.absent(),
                Value<String?> shopName = const Value.absent(),
                Value<String?> shopPhone = const Value.absent(),
                Value<String?> shopAddress = const Value.absent(),
                Value<String?> invoiceFooter = const Value.absent(),
                Value<LocaleCode> localeCode = const Value.absent(),
                Value<DigitStylePreference> digitStyle = const Value.absent(),
                Value<NegativeStockPolicy> negativeStockPolicy =
                    const Value.absent(),
                Value<bool> appLockEnabled = const Value.absent(),
                Value<bool> biometricEnabled = const Value.absent(),
                required String deviceId,
                Value<DateTime?> onboardingCompletedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                singleton: singleton,
                shopName: shopName,
                shopPhone: shopPhone,
                shopAddress: shopAddress,
                invoiceFooter: invoiceFooter,
                localeCode: localeCode,
                digitStyle: digitStyle,
                negativeStockPolicy: negativeStockPolicy,
                appLockEnabled: appLockEnabled,
                biometricEnabled: biometricEnabled,
                deviceId: deviceId,
                onboardingCompletedAt: onboardingCompletedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingsRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$CountersTableCreateCompanionBuilder = CountersCompanion Function({
  required String id,
  required DocType docType,
  required int nextValue,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CountersTableUpdateCompanionBuilder = CountersCompanion Function({
  Value<String> id,
  Value<DocType> docType,
  Value<int> nextValue,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CountersTableFilterComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DocType, DocType, String> get docType =>
      $composableBuilder(
        column: $table.docType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get nextValue => $composableBuilder(
    column: $table.nextValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$CountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextValue => $composableBuilder(
    column: $table.nextValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountersTable> {
  $$CountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DocType, String> get docType =>
      $composableBuilder(column: $table.docType, builder: (column) => column);

  GeneratedColumn<int> get nextValue =>
      $composableBuilder(column: $table.nextValue, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountersTable,
          CounterRow,
          $$CountersTableFilterComposer,
          $$CountersTableOrderingComposer,
          $$CountersTableAnnotationComposer,
          $$CountersTableCreateCompanionBuilder,
          $$CountersTableUpdateCompanionBuilder,
          (
            CounterRow,
            BaseReferences<_$AppDatabase, $CountersTable, CounterRow>,
          ),
          CounterRow,
          PrefetchHooks Function()
        > {
  $$CountersTableTableManager(_$AppDatabase db, $CountersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DocType> docType = const Value.absent(),
                Value<int> nextValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountersCompanion(
                id: id,
                docType: docType,
                nextValue: nextValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DocType docType,
                required int nextValue,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CountersCompanion.insert(
                id: id,
                docType: docType,
                nextValue: nextValue,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CountersTable, CounterRow>(table),
                  BaseReferences<_$AppDatabase, $CountersTable, CounterRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountersTable,
      CounterRow,
      $$CountersTableFilterComposer,
      $$CountersTableOrderingComposer,
      $$CountersTableAnnotationComposer,
      $$CountersTableCreateCompanionBuilder,
      $$CountersTableUpdateCompanionBuilder,
      (CounterRow, BaseReferences<_$AppDatabase, $CountersTable, CounterRow>),
      CounterRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  required String searchKey,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> searchKey,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: 'categories__id__products__category_id',
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                searchKey: searchKey,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String searchKey,
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                searchKey: searchKey,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      ProductRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  Value<String?> categoryId,
  required String name,
  required String searchKey,
  Value<String?> barcode,
  Value<String?> sku,
  required UnitType unitType,
  required int salePricePiasters,
  Value<int> avgCostPiasters,
  Value<int?> lowStockThresholdMilli,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String?> categoryId,
  Value<String> name,
  Value<String> searchKey,
  Value<String?> barcode,
  Value<String?> sku,
  Value<UnitType> unitType,
  Value<int> salePricePiasters,
  Value<int> avgCostPiasters,
  Value<int?> lowStockThresholdMilli,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('products__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItemRow>>
  _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItems,
    aliasName: 'products__id__sale_items__product_id',
  );

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleReturnItemsTable, List<SaleReturnItemRow>>
  _saleReturnItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleReturnItems,
    aliasName: 'products__id__sale_return_items__product_id',
  );

  $$SaleReturnItemsTableProcessedTableManager get saleReturnItemsRefs {
    final manager = $$SaleReturnItemsTableTableManager(
      $_db,
      $_db.saleReturnItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleReturnItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PurchaseItemsTable, List<PurchaseItemRow>>
  _purchaseItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseItems,
    aliasName: 'products__id__purchase_items__product_id',
  );

  $$PurchaseItemsTableProcessedTableManager get purchaseItemsRefs {
    final manager = $$PurchaseItemsTableTableManager(
      $_db,
      $_db.purchaseItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovementRow>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'products__id__stock_movements__product_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UnitType, UnitType, String> get unitType =>
      $composableBuilder(
        column: $table.unitType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get salePricePiasters => $composableBuilder(
    column: $table.salePricePiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCostPiasters => $composableBuilder(
    column: $table.avgCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowStockThresholdMilli => $composableBuilder(
    column: $table.lowStockThresholdMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleItemsRefs(
    Expression<bool> Function($$SaleItemsTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleReturnItemsRefs(
    Expression<bool> Function($$SaleReturnItemsTableFilterComposer f) f,
  ) {
    final $$SaleReturnItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> purchaseItemsRefs(
    Expression<bool> Function($$PurchaseItemsTableFilterComposer f) f,
  ) {
    final $$PurchaseItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salePricePiasters => $composableBuilder(
    column: $table.salePricePiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCostPiasters => $composableBuilder(
    column: $table.avgCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowStockThresholdMilli => $composableBuilder(
    column: $table.lowStockThresholdMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UnitType, String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<int> get salePricePiasters => $composableBuilder(
    column: $table.salePricePiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgCostPiasters => $composableBuilder(
    column: $table.avgCostPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lowStockThresholdMilli => $composableBuilder(
    column: $table.lowStockThresholdMilli,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleItemsRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleReturnItemsRefs<T extends Object>(
    Expression<T> Function($$SaleReturnItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleReturnItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> purchaseItemsRefs<T extends Object>(
    Expression<T> Function($$PurchaseItemsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductsTableReferences),
          ProductRow,
          PrefetchHooks Function({
            bool categoryId,
            bool saleItemsRefs,
            bool saleReturnItemsRefs,
            bool purchaseItemsRefs,
            bool stockMovementsRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<UnitType> unitType = const Value.absent(),
                Value<int> salePricePiasters = const Value.absent(),
                Value<int> avgCostPiasters = const Value.absent(),
                Value<int?> lowStockThresholdMilli = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                searchKey: searchKey,
                barcode: barcode,
                sku: sku,
                unitType: unitType,
                salePricePiasters: salePricePiasters,
                avgCostPiasters: avgCostPiasters,
                lowStockThresholdMilli: lowStockThresholdMilli,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> categoryId = const Value.absent(),
                required String name,
                required String searchKey,
                Value<String?> barcode = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                required UnitType unitType,
                required int salePricePiasters,
                Value<int> avgCostPiasters = const Value.absent(),
                Value<int?> lowStockThresholdMilli = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                searchKey: searchKey,
                barcode: barcode,
                sku: sku,
                unitType: unitType,
                salePricePiasters: salePricePiasters,
                avgCostPiasters: avgCostPiasters,
                lowStockThresholdMilli: lowStockThresholdMilli,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRow>(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                saleItemsRefs = false,
                saleReturnItemsRefs = false,
                purchaseItemsRefs = false,
                stockMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemsRefs) db.saleItems,
                    if (saleReturnItemsRefs) db.saleReturnItems,
                    if (purchaseItemsRefs) db.purchaseItems,
                    if (stockMovementsRefs) db.stockMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$ProductsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$ProductsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleItemsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          SaleItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._saleItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (saleReturnItemsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          SaleReturnItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._saleReturnItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleReturnItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (purchaseItemsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          PurchaseItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._purchaseItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          StockMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductsTableReferences),
      ProductRow,
      PrefetchHooks Function({
        bool categoryId,
        bool saleItemsRefs,
        bool saleReturnItemsRefs,
        bool purchaseItemsRefs,
        bool stockMovementsRefs,
      })
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  required String searchKey,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> searchKey,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesInvoicesTable, List<SalesInvoiceRow>>
  _salesInvoicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.salesInvoices,
    aliasName: 'customers__id__sales_invoices__customer_id',
  );

  $$SalesInvoicesTableProcessedTableManager get salesInvoicesRefs {
    final manager = $$SalesInvoicesTableTableManager(
      $_db,
      $_db.salesInvoices,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesInvoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleReturnsTable, List<SaleReturnRow>>
  _saleReturnsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleReturns,
    aliasName: 'customers__id__sale_returns__customer_id',
  );

  $$SaleReturnsTableProcessedTableManager get saleReturnsRefs {
    final manager = $$SaleReturnsTableTableManager(
      $_db,
      $_db.saleReturns,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleReturnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerLedgerTable, List<CustomerLedgerRow>>
  _customerLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerLedger,
    aliasName: 'customers__id__customer_ledger__customer_id',
  );

  $$CustomerLedgerTableProcessedTableManager get customerLedgerRefs {
    final manager = $$CustomerLedgerTableTableManager(
      $_db,
      $_db.customerLedger,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_customerLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> salesInvoicesRefs(
    Expression<bool> Function($$SalesInvoicesTableFilterComposer f) f,
  ) {
    final $$SalesInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleReturnsRefs(
    Expression<bool> Function($$SaleReturnsTableFilterComposer f) f,
  ) {
    final $$SaleReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerLedgerRefs(
    Expression<bool> Function($$CustomerLedgerTableFilterComposer f) f,
  ) {
    final $$CustomerLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableFilterComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  Expression<T> salesInvoicesRefs<T extends Object>(
    Expression<T> Function($$SalesInvoicesTableAnnotationComposer a) f,
  ) {
    final $$SalesInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleReturnsRefs<T extends Object>(
    Expression<T> Function($$SaleReturnsTableAnnotationComposer a) f,
  ) {
    final $$SaleReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerLedgerRefs<T extends Object>(
    Expression<T> Function($$CustomerLedgerTableAnnotationComposer a) f,
  ) {
    final $$CustomerLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomersTableReferences),
          CustomerRow,
          PrefetchHooks Function({
            bool salesInvoicesRefs,
            bool saleReturnsRefs,
            bool customerLedgerRefs,
          })
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                searchKey: searchKey,
                phone: phone,
                address: address,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String searchKey,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                searchKey: searchKey,
                phone: phone,
                address: address,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, CustomerRow>(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                salesInvoicesRefs = false,
                saleReturnsRefs = false,
                customerLedgerRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (salesInvoicesRefs) db.salesInvoices,
                    if (saleReturnsRefs) db.saleReturns,
                    if (customerLedgerRefs) db.customerLedger,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (salesInvoicesRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          SalesInvoiceRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._salesInvoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).salesInvoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (saleReturnsRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          SaleReturnRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._saleReturnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).saleReturnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerLedgerRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          CustomerLedgerRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomersTableReferences),
      CustomerRow,
      PrefetchHooks Function({
        bool salesInvoicesRefs,
        bool saleReturnsRefs,
        bool customerLedgerRefs,
      })
    >;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String name,
  required String searchKey,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> searchKey,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> archivedAt,
  Value<int> rowid,
});

final class $$SuppliersTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PurchaseInvoicesTable, List<PurchaseInvoiceRow>>
  _purchaseInvoicesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseInvoices,
    aliasName: 'suppliers__id__purchase_invoices__supplier_id',
  );

  $$PurchaseInvoicesTableProcessedTableManager get purchaseInvoicesRefs {
    final manager = $$PurchaseInvoicesTableTableManager(
      $_db,
      $_db.purchaseInvoices,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _purchaseInvoicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierLedgerTable, List<SupplierLedgerRow>>
  _supplierLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierLedger,
    aliasName: 'suppliers__id__supplier_ledger__supplier_id',
  );

  $$SupplierLedgerTableProcessedTableManager get supplierLedgerRefs {
    final manager = $$SupplierLedgerTableTableManager(
      $_db,
      $_db.supplierLedger,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_supplierLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> purchaseInvoicesRefs(
    Expression<bool> Function($$PurchaseInvoicesTableFilterComposer f) f,
  ) {
    final $$PurchaseInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierLedgerRefs(
    Expression<bool> Function($$SupplierLedgerTableFilterComposer f) f,
  ) {
    final $$SupplierLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierLedger,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgerTableFilterComposer(
            $db: $db,
            $table: $db.supplierLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  Expression<T> purchaseInvoicesRefs<T extends Object>(
    Expression<T> Function($$PurchaseInvoicesTableAnnotationComposer a) f,
  ) {
    final $$PurchaseInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierLedgerRefs<T extends Object>(
    Expression<T> Function($$SupplierLedgerTableAnnotationComposer a) f,
  ) {
    final $$SupplierLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierLedger,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          SupplierRow,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (SupplierRow, $$SuppliersTableReferences),
          SupplierRow,
          PrefetchHooks Function({
            bool purchaseInvoicesRefs,
            bool supplierLedgerRefs,
          })
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                searchKey: searchKey,
                phone: phone,
                address: address,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String searchKey,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                searchKey: searchKey,
                phone: phone,
                address: address,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppliersTable, SupplierRow>(table),
                  $$SuppliersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({purchaseInvoicesRefs = false, supplierLedgerRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseInvoicesRefs) db.purchaseInvoices,
                    if (supplierLedgerRefs) db.supplierLedger,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseInvoicesRefs)
                        await $_getPrefetchedData<
                          SupplierRow,
                          $SuppliersTable,
                          PurchaseInvoiceRow
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._purchaseInvoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseInvoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierLedgerRefs)
                        await $_getPrefetchedData<
                          SupplierRow,
                          $SuppliersTable,
                          SupplierLedgerRow
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      SupplierRow,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (SupplierRow, $$SuppliersTableReferences),
      SupplierRow,
      PrefetchHooks Function({
        bool purchaseInvoicesRefs,
        bool supplierLedgerRefs,
      })
    >;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      required String id,
      required String name,
      required String searchKey,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> searchKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$ExpenseCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategoryRow
        > {
  $$ExpenseCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'expense_categories__id__expenses__expense_category_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.expenseCategoryId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.expenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchKey => $composableBuilder(
    column: $table.searchKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchKey =>
      $composableBuilder(column: $table.searchKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.expenseCategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategoryRow,
          $$ExpenseCategoriesTableFilterComposer,
          $$ExpenseCategoriesTableOrderingComposer,
          $$ExpenseCategoriesTableAnnotationComposer,
          $$ExpenseCategoriesTableCreateCompanionBuilder,
          $$ExpenseCategoriesTableUpdateCompanionBuilder,
          (ExpenseCategoryRow, $$ExpenseCategoriesTableReferences),
          ExpenseCategoryRow,
          PrefetchHooks Function({bool expensesRefs})
        > {
  $$ExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                name: name,
                searchKey: searchKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String searchKey,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                name: name,
                searchKey: searchKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpenseCategoriesTable, ExpenseCategoryRow>(
                    table,
                  ),
                  $$ExpenseCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<
                      ExpenseCategoryRow,
                      $ExpenseCategoriesTable,
                      ExpenseRow
                    >(
                      currentTable: table,
                      referencedTable: $$ExpenseCategoriesTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExpenseCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.expenseCategoryId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoriesTable,
      ExpenseCategoryRow,
      $$ExpenseCategoriesTableFilterComposer,
      $$ExpenseCategoriesTableOrderingComposer,
      $$ExpenseCategoriesTableAnnotationComposer,
      $$ExpenseCategoriesTableCreateCompanionBuilder,
      $$ExpenseCategoriesTableUpdateCompanionBuilder,
      (ExpenseCategoryRow, $$ExpenseCategoriesTableReferences),
      ExpenseCategoryRow,
      PrefetchHooks Function({bool expensesRefs})
    >;
typedef $$SalesInvoicesTableCreateCompanionBuilder =
    SalesInvoicesCompanion Function({
      required String id,
      required int number,
      Value<String?> customerId,
      required int subtotalPiasters,
      Value<int> discountPiasters,
      required int totalPiasters,
      required int paidAtSalePiasters,
      Value<PaymentMethod> paymentMethod,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$SalesInvoicesTableUpdateCompanionBuilder =
    SalesInvoicesCompanion Function({
      Value<String> id,
      Value<int> number,
      Value<String?> customerId,
      Value<int> subtotalPiasters,
      Value<int> discountPiasters,
      Value<int> totalPiasters,
      Value<int> paidAtSalePiasters,
      Value<PaymentMethod> paymentMethod,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });

final class $$SalesInvoicesTableReferences
    extends
        BaseReferences<_$AppDatabase, $SalesInvoicesTable, SalesInvoiceRow> {
  $$SalesInvoicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('sales_invoices__customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<String>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItemRow>>
  _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItems,
    aliasName: 'sales_invoices__id__sale_items__sales_invoice_id',
  );

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.salesInvoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleReturnsTable, List<SaleReturnRow>>
  _saleReturnsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleReturns,
    aliasName: 'sales_invoices__id__sale_returns__sales_invoice_id',
  );

  $$SaleReturnsTableProcessedTableManager get saleReturnsRefs {
    final manager = $$SaleReturnsTableTableManager(
      $_db,
      $_db.saleReturns,
    ).filter((f) => f.salesInvoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleReturnsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerLedgerTable, List<CustomerLedgerRow>>
  _customerLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerLedger,
    aliasName: 'sales_invoices__id__customer_ledger__sales_invoice_id',
  );

  $$CustomerLedgerTableProcessedTableManager get customerLedgerRefs {
    final manager = $$CustomerLedgerTableTableManager(
      $_db,
      $_db.customerLedger,
    ).filter((f) => f.salesInvoiceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_customerLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesInvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $SalesInvoicesTable> {
  $$SalesInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subtotalPiasters => $composableBuilder(
    column: $table.subtotalPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPiasters => $composableBuilder(
    column: $table.totalPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidAtSalePiasters => $composableBuilder(
    column: $table.paidAtSalePiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get voidedAt =>
      $composableBuilder(
        column: $table.voidedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleItemsRefs(
    Expression<bool> Function($$SaleItemsTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.salesInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleReturnsRefs(
    Expression<bool> Function($$SaleReturnsTableFilterComposer f) f,
  ) {
    final $$SaleReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.salesInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerLedgerRefs(
    Expression<bool> Function($$CustomerLedgerTableFilterComposer f) f,
  ) {
    final $$CustomerLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.salesInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableFilterComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesInvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesInvoicesTable> {
  $$SalesInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalPiasters => $composableBuilder(
    column: $table.subtotalPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPiasters => $composableBuilder(
    column: $table.totalPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidAtSalePiasters => $composableBuilder(
    column: $table.paidAtSalePiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesInvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesInvoicesTable> {
  $$SalesInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get subtotalPiasters => $composableBuilder(
    column: $table.subtotalPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPiasters => $composableBuilder(
    column: $table.totalPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidAtSalePiasters => $composableBuilder(
    column: $table.paidAtSalePiasters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleItemsRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.salesInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleReturnsRefs<T extends Object>(
    Expression<T> Function($$SaleReturnsTableAnnotationComposer a) f,
  ) {
    final $$SaleReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.salesInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerLedgerRefs<T extends Object>(
    Expression<T> Function($$CustomerLedgerTableAnnotationComposer a) f,
  ) {
    final $$CustomerLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.salesInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesInvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesInvoicesTable,
          SalesInvoiceRow,
          $$SalesInvoicesTableFilterComposer,
          $$SalesInvoicesTableOrderingComposer,
          $$SalesInvoicesTableAnnotationComposer,
          $$SalesInvoicesTableCreateCompanionBuilder,
          $$SalesInvoicesTableUpdateCompanionBuilder,
          (SalesInvoiceRow, $$SalesInvoicesTableReferences),
          SalesInvoiceRow,
          PrefetchHooks Function({
            bool customerId,
            bool saleItemsRefs,
            bool saleReturnsRefs,
            bool customerLedgerRefs,
          })
        > {
  $$SalesInvoicesTableTableManager(_$AppDatabase db, $SalesInvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesInvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<int> subtotalPiasters = const Value.absent(),
                Value<int> discountPiasters = const Value.absent(),
                Value<int> totalPiasters = const Value.absent(),
                Value<int> paidAtSalePiasters = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesInvoicesCompanion(
                id: id,
                number: number,
                customerId: customerId,
                subtotalPiasters: subtotalPiasters,
                discountPiasters: discountPiasters,
                totalPiasters: totalPiasters,
                paidAtSalePiasters: paidAtSalePiasters,
                paymentMethod: paymentMethod,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int number,
                Value<String?> customerId = const Value.absent(),
                required int subtotalPiasters,
                Value<int> discountPiasters = const Value.absent(),
                required int totalPiasters,
                required int paidAtSalePiasters,
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesInvoicesCompanion.insert(
                id: id,
                number: number,
                customerId: customerId,
                subtotalPiasters: subtotalPiasters,
                discountPiasters: discountPiasters,
                totalPiasters: totalPiasters,
                paidAtSalePiasters: paidAtSalePiasters,
                paymentMethod: paymentMethod,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesInvoicesTable, SalesInvoiceRow>(table),
                  $$SalesInvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                saleItemsRefs = false,
                saleReturnsRefs = false,
                customerLedgerRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemsRefs) db.saleItems,
                    if (saleReturnsRefs) db.saleReturns,
                    if (customerLedgerRefs) db.customerLedger,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable: $$SalesInvoicesTableReferences
                                ._customerIdTable(db),
                            referencedColumn: $$SalesInvoicesTableReferences
                                ._customerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleItemsRefs)
                        await $_getPrefetchedData<
                          SalesInvoiceRow,
                          $SalesInvoicesTable,
                          SaleItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$SalesInvoicesTableReferences
                              ._saleItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.salesInvoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (saleReturnsRefs)
                        await $_getPrefetchedData<
                          SalesInvoiceRow,
                          $SalesInvoicesTable,
                          SaleReturnRow
                        >(
                          currentTable: table,
                          referencedTable: $$SalesInvoicesTableReferences
                              ._saleReturnsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleReturnsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.salesInvoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerLedgerRefs)
                        await $_getPrefetchedData<
                          SalesInvoiceRow,
                          $SalesInvoicesTable,
                          CustomerLedgerRow
                        >(
                          currentTable: table,
                          referencedTable: $$SalesInvoicesTableReferences
                              ._customerLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).customerLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.salesInvoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SalesInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesInvoicesTable,
      SalesInvoiceRow,
      $$SalesInvoicesTableFilterComposer,
      $$SalesInvoicesTableOrderingComposer,
      $$SalesInvoicesTableAnnotationComposer,
      $$SalesInvoicesTableCreateCompanionBuilder,
      $$SalesInvoicesTableUpdateCompanionBuilder,
      (SalesInvoiceRow, $$SalesInvoicesTableReferences),
      SalesInvoiceRow,
      PrefetchHooks Function({
        bool customerId,
        bool saleItemsRefs,
        bool saleReturnsRefs,
        bool customerLedgerRefs,
      })
    >;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  required String id,
  required String salesInvoiceId,
  required int lineNo,
  required String productId,
  required String productNameSnapshot,
  required UnitType unitTypeSnapshot,
  required int qtyMilli,
  required int unitPricePiasters,
  required int discountPiasters,
  required int lineTotalPiasters,
  required int invoiceDiscountSharePiasters,
  required int unitCostPiasters,
  required int lineCostPiasters,
  Value<int> rowid,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<String> id,
  Value<String> salesInvoiceId,
  Value<int> lineNo,
  Value<String> productId,
  Value<String> productNameSnapshot,
  Value<UnitType> unitTypeSnapshot,
  Value<int> qtyMilli,
  Value<int> unitPricePiasters,
  Value<int> discountPiasters,
  Value<int> lineTotalPiasters,
  Value<int> invoiceDiscountSharePiasters,
  Value<int> unitCostPiasters,
  Value<int> lineCostPiasters,
  Value<int> rowid,
});

final class $$SaleItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItemRow> {
  $$SaleItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesInvoicesTable _salesInvoiceIdTable(_$AppDatabase db) => db
      .salesInvoices
      .createAlias('sale_items__sales_invoice_id__sales_invoices__id');

  $$SalesInvoicesTableProcessedTableManager get salesInvoiceId {
    final $_column = $_itemColumn<String>('sales_invoice_id')!;

    final manager = $$SalesInvoicesTableTableManager(
      $_db,
      $_db.salesInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_salesInvoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('sale_items__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleReturnItemsTable, List<SaleReturnItemRow>>
  _saleReturnItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleReturnItems,
    aliasName: 'sale_items__id__sale_return_items__sale_item_id',
  );

  $$SaleReturnItemsTableProcessedTableManager get saleReturnItemsRefs {
    final manager = $$SaleReturnItemsTableTableManager(
      $_db,
      $_db.saleReturnItems,
    ).filter((f) => f.saleItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleReturnItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovementRow>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'sale_items__id__stock_movements__sale_item_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.saleItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UnitType, UnitType, String>
  get unitTypeSnapshot => $composableBuilder(
    column: $table.unitTypeSnapshot,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPricePiasters => $composableBuilder(
    column: $table.unitPricePiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalPiasters => $composableBuilder(
    column: $table.lineTotalPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invoiceDiscountSharePiasters => $composableBuilder(
    column: $table.invoiceDiscountSharePiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineCostPiasters => $composableBuilder(
    column: $table.lineCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesInvoicesTableFilterComposer get salesInvoiceId {
    final $$SalesInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleReturnItemsRefs(
    Expression<bool> Function($$SaleReturnItemsTableFilterComposer f) f,
  ) {
    final $$SaleReturnItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.saleItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.saleItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitTypeSnapshot => $composableBuilder(
    column: $table.unitTypeSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPricePiasters => $composableBuilder(
    column: $table.unitPricePiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalPiasters => $composableBuilder(
    column: $table.lineTotalPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invoiceDiscountSharePiasters => $composableBuilder(
    column: $table.invoiceDiscountSharePiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineCostPiasters => $composableBuilder(
    column: $table.lineCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesInvoicesTableOrderingComposer get salesInvoiceId {
    final $$SalesInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UnitType, String> get unitTypeSnapshot =>
      $composableBuilder(
        column: $table.unitTypeSnapshot,
        builder: (column) => column,
      );

  GeneratedColumn<int> get qtyMilli =>
      $composableBuilder(column: $table.qtyMilli, builder: (column) => column);

  GeneratedColumn<int> get unitPricePiasters => $composableBuilder(
    column: $table.unitPricePiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalPiasters => $composableBuilder(
    column: $table.lineTotalPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get invoiceDiscountSharePiasters => $composableBuilder(
    column: $table.invoiceDiscountSharePiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineCostPiasters => $composableBuilder(
    column: $table.lineCostPiasters,
    builder: (column) => column,
  );

  $$SalesInvoicesTableAnnotationComposer get salesInvoiceId {
    final $$SalesInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleReturnItemsRefs<T extends Object>(
    Expression<T> Function($$SaleReturnItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleReturnItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.saleItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.saleItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemsTable,
          SaleItemRow,
          $$SaleItemsTableFilterComposer,
          $$SaleItemsTableOrderingComposer,
          $$SaleItemsTableAnnotationComposer,
          $$SaleItemsTableCreateCompanionBuilder,
          $$SaleItemsTableUpdateCompanionBuilder,
          (SaleItemRow, $$SaleItemsTableReferences),
          SaleItemRow,
          PrefetchHooks Function({
            bool salesInvoiceId,
            bool productId,
            bool saleReturnItemsRefs,
            bool stockMovementsRefs,
          })
        > {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> salesInvoiceId = const Value.absent(),
                Value<int> lineNo = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<UnitType> unitTypeSnapshot = const Value.absent(),
                Value<int> qtyMilli = const Value.absent(),
                Value<int> unitPricePiasters = const Value.absent(),
                Value<int> discountPiasters = const Value.absent(),
                Value<int> lineTotalPiasters = const Value.absent(),
                Value<int> invoiceDiscountSharePiasters = const Value.absent(),
                Value<int> unitCostPiasters = const Value.absent(),
                Value<int> lineCostPiasters = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion(
                id: id,
                salesInvoiceId: salesInvoiceId,
                lineNo: lineNo,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                unitTypeSnapshot: unitTypeSnapshot,
                qtyMilli: qtyMilli,
                unitPricePiasters: unitPricePiasters,
                discountPiasters: discountPiasters,
                lineTotalPiasters: lineTotalPiasters,
                invoiceDiscountSharePiasters: invoiceDiscountSharePiasters,
                unitCostPiasters: unitCostPiasters,
                lineCostPiasters: lineCostPiasters,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String salesInvoiceId,
                required int lineNo,
                required String productId,
                required String productNameSnapshot,
                required UnitType unitTypeSnapshot,
                required int qtyMilli,
                required int unitPricePiasters,
                required int discountPiasters,
                required int lineTotalPiasters,
                required int invoiceDiscountSharePiasters,
                required int unitCostPiasters,
                required int lineCostPiasters,
                Value<int> rowid = const Value.absent(),
              }) => SaleItemsCompanion.insert(
                id: id,
                salesInvoiceId: salesInvoiceId,
                lineNo: lineNo,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                unitTypeSnapshot: unitTypeSnapshot,
                qtyMilli: qtyMilli,
                unitPricePiasters: unitPricePiasters,
                discountPiasters: discountPiasters,
                lineTotalPiasters: lineTotalPiasters,
                invoiceDiscountSharePiasters: invoiceDiscountSharePiasters,
                unitCostPiasters: unitCostPiasters,
                lineCostPiasters: lineCostPiasters,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleItemsTable, SaleItemRow>(table),
                  $$SaleItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                salesInvoiceId = false,
                productId = false,
                saleReturnItemsRefs = false,
                stockMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleReturnItemsRefs) db.saleReturnItems,
                    if (stockMovementsRefs) db.stockMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (salesInvoiceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.salesInvoiceId,
                            referencedTable: $$SaleItemsTableReferences
                                ._salesInvoiceIdTable(db),
                            referencedColumn: $$SaleItemsTableReferences
                                ._salesInvoiceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable: $$SaleItemsTableReferences
                                ._productIdTable(db),
                            referencedColumn: $$SaleItemsTableReferences
                                ._productIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleReturnItemsRefs)
                        await $_getPrefetchedData<
                          SaleItemRow,
                          $SaleItemsTable,
                          SaleReturnItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$SaleItemsTableReferences
                              ._saleReturnItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SaleItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleReturnItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          SaleItemRow,
                          $SaleItemsTable,
                          StockMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$SaleItemsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SaleItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SaleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemsTable,
      SaleItemRow,
      $$SaleItemsTableFilterComposer,
      $$SaleItemsTableOrderingComposer,
      $$SaleItemsTableAnnotationComposer,
      $$SaleItemsTableCreateCompanionBuilder,
      $$SaleItemsTableUpdateCompanionBuilder,
      (SaleItemRow, $$SaleItemsTableReferences),
      SaleItemRow,
      PrefetchHooks Function({
        bool salesInvoiceId,
        bool productId,
        bool saleReturnItemsRefs,
        bool stockMovementsRefs,
      })
    >;
typedef $$SaleReturnsTableCreateCompanionBuilder =
    SaleReturnsCompanion Function({
      required String id,
      required int number,
      required String salesInvoiceId,
      Value<String?> customerId,
      required int totalRefundPiasters,
      required int totalCostPiasters,
      required int refundPaidPiasters,
      Value<PaymentMethod> paymentMethod,
      Value<String?> reason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SaleReturnsTableUpdateCompanionBuilder =
    SaleReturnsCompanion Function({
      Value<String> id,
      Value<int> number,
      Value<String> salesInvoiceId,
      Value<String?> customerId,
      Value<int> totalRefundPiasters,
      Value<int> totalCostPiasters,
      Value<int> refundPaidPiasters,
      Value<PaymentMethod> paymentMethod,
      Value<String?> reason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SaleReturnsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleReturnsTable, SaleReturnRow> {
  $$SaleReturnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesInvoicesTable _salesInvoiceIdTable(_$AppDatabase db) => db
      .salesInvoices
      .createAlias('sale_returns__sales_invoice_id__sales_invoices__id');

  $$SalesInvoicesTableProcessedTableManager get salesInvoiceId {
    final $_column = $_itemColumn<String>('sales_invoice_id')!;

    final manager = $$SalesInvoicesTableTableManager(
      $_db,
      $_db.salesInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_salesInvoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('sale_returns__customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<String>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleReturnItemsTable, List<SaleReturnItemRow>>
  _saleReturnItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleReturnItems,
    aliasName: 'sale_returns__id__sale_return_items__sale_return_id',
  );

  $$SaleReturnItemsTableProcessedTableManager get saleReturnItemsRefs {
    final manager = $$SaleReturnItemsTableTableManager(
      $_db,
      $_db.saleReturnItems,
    ).filter((f) => f.saleReturnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _saleReturnItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerLedgerTable, List<CustomerLedgerRow>>
  _customerLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerLedger,
    aliasName: 'sale_returns__id__customer_ledger__sale_return_id',
  );

  $$CustomerLedgerTableProcessedTableManager get customerLedgerRefs {
    final manager = $$CustomerLedgerTableTableManager(
      $_db,
      $_db.customerLedger,
    ).filter((f) => f.saleReturnId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_customerLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SaleReturnsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalRefundPiasters => $composableBuilder(
    column: $table.totalRefundPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCostPiasters => $composableBuilder(
    column: $table.totalCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundPaidPiasters => $composableBuilder(
    column: $table.refundPaidPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$SalesInvoicesTableFilterComposer get salesInvoiceId {
    final $$SalesInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleReturnItemsRefs(
    Expression<bool> Function($$SaleReturnItemsTableFilterComposer f) f,
  ) {
    final $$SaleReturnItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.saleReturnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerLedgerRefs(
    Expression<bool> Function($$CustomerLedgerTableFilterComposer f) f,
  ) {
    final $$CustomerLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.saleReturnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableFilterComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleReturnsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalRefundPiasters => $composableBuilder(
    column: $table.totalRefundPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCostPiasters => $composableBuilder(
    column: $table.totalCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundPaidPiasters => $composableBuilder(
    column: $table.refundPaidPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesInvoicesTableOrderingComposer get salesInvoiceId {
    final $$SalesInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleReturnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleReturnsTable> {
  $$SaleReturnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get totalRefundPiasters => $composableBuilder(
    column: $table.totalRefundPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalCostPiasters => $composableBuilder(
    column: $table.totalCostPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refundPaidPiasters => $composableBuilder(
    column: $table.refundPaidPiasters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SalesInvoicesTableAnnotationComposer get salesInvoiceId {
    final $$SalesInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleReturnItemsRefs<T extends Object>(
    Expression<T> Function($$SaleReturnItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleReturnItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.saleReturnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerLedgerRefs<T extends Object>(
    Expression<T> Function($$CustomerLedgerTableAnnotationComposer a) f,
  ) {
    final $$CustomerLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.saleReturnId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleReturnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleReturnsTable,
          SaleReturnRow,
          $$SaleReturnsTableFilterComposer,
          $$SaleReturnsTableOrderingComposer,
          $$SaleReturnsTableAnnotationComposer,
          $$SaleReturnsTableCreateCompanionBuilder,
          $$SaleReturnsTableUpdateCompanionBuilder,
          (SaleReturnRow, $$SaleReturnsTableReferences),
          SaleReturnRow,
          PrefetchHooks Function({
            bool salesInvoiceId,
            bool customerId,
            bool saleReturnItemsRefs,
            bool customerLedgerRefs,
          })
        > {
  $$SaleReturnsTableTableManager(_$AppDatabase db, $SaleReturnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleReturnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleReturnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleReturnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> salesInvoiceId = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<int> totalRefundPiasters = const Value.absent(),
                Value<int> totalCostPiasters = const Value.absent(),
                Value<int> refundPaidPiasters = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnsCompanion(
                id: id,
                number: number,
                salesInvoiceId: salesInvoiceId,
                customerId: customerId,
                totalRefundPiasters: totalRefundPiasters,
                totalCostPiasters: totalCostPiasters,
                refundPaidPiasters: refundPaidPiasters,
                paymentMethod: paymentMethod,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int number,
                required String salesInvoiceId,
                Value<String?> customerId = const Value.absent(),
                required int totalRefundPiasters,
                required int totalCostPiasters,
                required int refundPaidPiasters,
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnsCompanion.insert(
                id: id,
                number: number,
                salesInvoiceId: salesInvoiceId,
                customerId: customerId,
                totalRefundPiasters: totalRefundPiasters,
                totalCostPiasters: totalCostPiasters,
                refundPaidPiasters: refundPaidPiasters,
                paymentMethod: paymentMethod,
                reason: reason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleReturnsTable, SaleReturnRow>(table),
                  $$SaleReturnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                salesInvoiceId = false,
                customerId = false,
                saleReturnItemsRefs = false,
                customerLedgerRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleReturnItemsRefs) db.saleReturnItems,
                    if (customerLedgerRefs) db.customerLedger,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (salesInvoiceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.salesInvoiceId,
                            referencedTable: $$SaleReturnsTableReferences
                                ._salesInvoiceIdTable(db),
                            referencedColumn: $$SaleReturnsTableReferences
                                ._salesInvoiceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable: $$SaleReturnsTableReferences
                                ._customerIdTable(db),
                            referencedColumn: $$SaleReturnsTableReferences
                                ._customerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleReturnItemsRefs)
                        await $_getPrefetchedData<
                          SaleReturnRow,
                          $SaleReturnsTable,
                          SaleReturnItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$SaleReturnsTableReferences
                              ._saleReturnItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SaleReturnsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleReturnItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleReturnId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerLedgerRefs)
                        await $_getPrefetchedData<
                          SaleReturnRow,
                          $SaleReturnsTable,
                          CustomerLedgerRow
                        >(
                          currentTable: table,
                          referencedTable: $$SaleReturnsTableReferences
                              ._customerLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SaleReturnsTableReferences(
                                db,
                                table,
                                p0,
                              ).customerLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleReturnId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SaleReturnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleReturnsTable,
      SaleReturnRow,
      $$SaleReturnsTableFilterComposer,
      $$SaleReturnsTableOrderingComposer,
      $$SaleReturnsTableAnnotationComposer,
      $$SaleReturnsTableCreateCompanionBuilder,
      $$SaleReturnsTableUpdateCompanionBuilder,
      (SaleReturnRow, $$SaleReturnsTableReferences),
      SaleReturnRow,
      PrefetchHooks Function({
        bool salesInvoiceId,
        bool customerId,
        bool saleReturnItemsRefs,
        bool customerLedgerRefs,
      })
    >;
typedef $$SaleReturnItemsTableCreateCompanionBuilder =
    SaleReturnItemsCompanion Function({
      required String id,
      required String saleReturnId,
      required String saleItemId,
      required String productId,
      required int qtyMilli,
      required int unitPricePiasters,
      required int unitCostPiasters,
      required int refundPiasters,
      required int costPiasters,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SaleReturnItemsTableUpdateCompanionBuilder =
    SaleReturnItemsCompanion Function({
      Value<String> id,
      Value<String> saleReturnId,
      Value<String> saleItemId,
      Value<String> productId,
      Value<int> qtyMilli,
      Value<int> unitPricePiasters,
      Value<int> unitCostPiasters,
      Value<int> refundPiasters,
      Value<int> costPiasters,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SaleReturnItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SaleReturnItemsTable,
          SaleReturnItemRow
        > {
  $$SaleReturnItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SaleReturnsTable _saleReturnIdTable(_$AppDatabase db) => db
      .saleReturns
      .createAlias('sale_return_items__sale_return_id__sale_returns__id');

  $$SaleReturnsTableProcessedTableManager get saleReturnId {
    final $_column = $_itemColumn<String>('sale_return_id')!;

    final manager = $$SaleReturnsTableTableManager(
      $_db,
      $_db.saleReturns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleReturnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SaleItemsTable _saleItemIdTable(_$AppDatabase db) => db.saleItems
      .createAlias('sale_return_items__sale_item_id__sale_items__id');

  $$SaleItemsTableProcessedTableManager get saleItemId {
    final $_column = $_itemColumn<String>('sale_item_id')!;

    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('sale_return_items__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovementRow>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'sale_return_items__id__stock_movements__sale_return_item_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager($_db, $_db.stockMovements)
        .filter(
          (f) => f.saleReturnItemId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SaleReturnItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleReturnItemsTable> {
  $$SaleReturnItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPricePiasters => $composableBuilder(
    column: $table.unitPricePiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundPiasters => $composableBuilder(
    column: $table.refundPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costPiasters => $composableBuilder(
    column: $table.costPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$SaleReturnsTableFilterComposer get saleReturnId {
    final $$SaleReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnId,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleItemsTableFilterComposer get saleItemId {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleItemId,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.saleReturnItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleReturnItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleReturnItemsTable> {
  $$SaleReturnItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPricePiasters => $composableBuilder(
    column: $table.unitPricePiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundPiasters => $composableBuilder(
    column: $table.refundPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costPiasters => $composableBuilder(
    column: $table.costPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SaleReturnsTableOrderingComposer get saleReturnId {
    final $$SaleReturnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnId,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableOrderingComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleItemsTableOrderingComposer get saleItemId {
    final $$SaleItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleItemId,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableOrderingComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleReturnItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleReturnItemsTable> {
  $$SaleReturnItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get qtyMilli =>
      $composableBuilder(column: $table.qtyMilli, builder: (column) => column);

  GeneratedColumn<int> get unitPricePiasters => $composableBuilder(
    column: $table.unitPricePiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refundPiasters => $composableBuilder(
    column: $table.refundPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costPiasters => $composableBuilder(
    column: $table.costPiasters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SaleReturnsTableAnnotationComposer get saleReturnId {
    final $$SaleReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnId,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleItemsTableAnnotationComposer get saleItemId {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleItemId,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.saleReturnItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SaleReturnItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleReturnItemsTable,
          SaleReturnItemRow,
          $$SaleReturnItemsTableFilterComposer,
          $$SaleReturnItemsTableOrderingComposer,
          $$SaleReturnItemsTableAnnotationComposer,
          $$SaleReturnItemsTableCreateCompanionBuilder,
          $$SaleReturnItemsTableUpdateCompanionBuilder,
          (SaleReturnItemRow, $$SaleReturnItemsTableReferences),
          SaleReturnItemRow,
          PrefetchHooks Function({
            bool saleReturnId,
            bool saleItemId,
            bool productId,
            bool stockMovementsRefs,
          })
        > {
  $$SaleReturnItemsTableTableManager(
    _$AppDatabase db,
    $SaleReturnItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleReturnItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleReturnItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleReturnItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> saleReturnId = const Value.absent(),
                Value<String> saleItemId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<int> qtyMilli = const Value.absent(),
                Value<int> unitPricePiasters = const Value.absent(),
                Value<int> unitCostPiasters = const Value.absent(),
                Value<int> refundPiasters = const Value.absent(),
                Value<int> costPiasters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnItemsCompanion(
                id: id,
                saleReturnId: saleReturnId,
                saleItemId: saleItemId,
                productId: productId,
                qtyMilli: qtyMilli,
                unitPricePiasters: unitPricePiasters,
                unitCostPiasters: unitCostPiasters,
                refundPiasters: refundPiasters,
                costPiasters: costPiasters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String saleReturnId,
                required String saleItemId,
                required String productId,
                required int qtyMilli,
                required int unitPricePiasters,
                required int unitCostPiasters,
                required int refundPiasters,
                required int costPiasters,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SaleReturnItemsCompanion.insert(
                id: id,
                saleReturnId: saleReturnId,
                saleItemId: saleItemId,
                productId: productId,
                qtyMilli: qtyMilli,
                unitPricePiasters: unitPricePiasters,
                unitCostPiasters: unitCostPiasters,
                refundPiasters: refundPiasters,
                costPiasters: costPiasters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleReturnItemsTable, SaleReturnItemRow>(table),
                  $$SaleReturnItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                saleReturnId = false,
                saleItemId = false,
                productId = false,
                stockMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockMovementsRefs) db.stockMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (saleReturnId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.saleReturnId,
                            referencedTable: $$SaleReturnItemsTableReferences
                                ._saleReturnIdTable(db),
                            referencedColumn: $$SaleReturnItemsTableReferences
                                ._saleReturnIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (saleItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.saleItemId,
                            referencedTable: $$SaleReturnItemsTableReferences
                                ._saleItemIdTable(db),
                            referencedColumn: $$SaleReturnItemsTableReferences
                                ._saleItemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable: $$SaleReturnItemsTableReferences
                                ._productIdTable(db),
                            referencedColumn: $$SaleReturnItemsTableReferences
                                ._productIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          SaleReturnItemRow,
                          $SaleReturnItemsTable,
                          StockMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$SaleReturnItemsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SaleReturnItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleReturnItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SaleReturnItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleReturnItemsTable,
      SaleReturnItemRow,
      $$SaleReturnItemsTableFilterComposer,
      $$SaleReturnItemsTableOrderingComposer,
      $$SaleReturnItemsTableAnnotationComposer,
      $$SaleReturnItemsTableCreateCompanionBuilder,
      $$SaleReturnItemsTableUpdateCompanionBuilder,
      (SaleReturnItemRow, $$SaleReturnItemsTableReferences),
      SaleReturnItemRow,
      PrefetchHooks Function({
        bool saleReturnId,
        bool saleItemId,
        bool productId,
        bool stockMovementsRefs,
      })
    >;
typedef $$PurchaseInvoicesTableCreateCompanionBuilder =
    PurchaseInvoicesCompanion Function({
      required String id,
      required int number,
      Value<String?> supplierId,
      Value<String?> supplierRef,
      required DateTime invoiceDate,
      required int subtotalPiasters,
      Value<int> discountPiasters,
      required int totalPiasters,
      required int paidPiasters,
      Value<PaymentMethod> paymentMethod,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$PurchaseInvoicesTableUpdateCompanionBuilder =
    PurchaseInvoicesCompanion Function({
      Value<String> id,
      Value<int> number,
      Value<String?> supplierId,
      Value<String?> supplierRef,
      Value<DateTime> invoiceDate,
      Value<int> subtotalPiasters,
      Value<int> discountPiasters,
      Value<int> totalPiasters,
      Value<int> paidPiasters,
      Value<PaymentMethod> paymentMethod,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> voidedAt,
      Value<String?> voidReason,
      Value<int> rowid,
    });

final class $$PurchaseInvoicesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PurchaseInvoicesTable,
          PurchaseInvoiceRow
        > {
  $$PurchaseInvoicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('purchase_invoices__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager? get supplierId {
    final $_column = $_itemColumn<String>('supplier_id');
    if ($_column == null) return null;
    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PurchaseItemsTable, List<PurchaseItemRow>>
  _purchaseItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseItems,
    aliasName: 'purchase_invoices__id__purchase_items__purchase_invoice_id',
  );

  $$PurchaseItemsTableProcessedTableManager get purchaseItemsRefs {
    final manager = $$PurchaseItemsTableTableManager($_db, $_db.purchaseItems)
        .filter(
          (f) => f.purchaseInvoiceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_purchaseItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierLedgerTable, List<SupplierLedgerRow>>
  _supplierLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierLedger,
    aliasName: 'purchase_invoices__id__supplier_ledger__purchase_invoice_id',
  );

  $$SupplierLedgerTableProcessedTableManager get supplierLedgerRefs {
    final manager = $$SupplierLedgerTableTableManager($_db, $_db.supplierLedger)
        .filter(
          (f) => f.purchaseInvoiceId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_supplierLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchaseInvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseInvoicesTable> {
  $$PurchaseInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierRef => $composableBuilder(
    column: $table.supplierRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get invoiceDate =>
      $composableBuilder(
        column: $table.invoiceDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get subtotalPiasters => $composableBuilder(
    column: $table.subtotalPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPiasters => $composableBuilder(
    column: $table.totalPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidPiasters => $composableBuilder(
    column: $table.paidPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get voidedAt =>
      $composableBuilder(
        column: $table.voidedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseItemsRefs(
    Expression<bool> Function($$PurchaseItemsTableFilterComposer f) f,
  ) {
    final $$PurchaseItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.purchaseInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierLedgerRefs(
    Expression<bool> Function($$SupplierLedgerTableFilterComposer f) f,
  ) {
    final $$SupplierLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierLedger,
      getReferencedColumn: (t) => t.purchaseInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgerTableFilterComposer(
            $db: $db,
            $table: $db.supplierLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseInvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseInvoicesTable> {
  $$PurchaseInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierRef => $composableBuilder(
    column: $table.supplierRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subtotalPiasters => $composableBuilder(
    column: $table.subtotalPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPiasters => $composableBuilder(
    column: $table.totalPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidPiasters => $composableBuilder(
    column: $table.paidPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseInvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseInvoicesTable> {
  $$PurchaseInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get supplierRef => $composableBuilder(
    column: $table.supplierRef,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get invoiceDate =>
      $composableBuilder(
        column: $table.invoiceDate,
        builder: (column) => column,
      );

  GeneratedColumn<int> get subtotalPiasters => $composableBuilder(
    column: $table.subtotalPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPiasters => $composableBuilder(
    column: $table.totalPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidPiasters => $composableBuilder(
    column: $table.paidPiasters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMethod, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseItemsRefs<T extends Object>(
    Expression<T> Function($$PurchaseItemsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.purchaseInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierLedgerRefs<T extends Object>(
    Expression<T> Function($$SupplierLedgerTableAnnotationComposer a) f,
  ) {
    final $$SupplierLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierLedger,
      getReferencedColumn: (t) => t.purchaseInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseInvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseInvoicesTable,
          PurchaseInvoiceRow,
          $$PurchaseInvoicesTableFilterComposer,
          $$PurchaseInvoicesTableOrderingComposer,
          $$PurchaseInvoicesTableAnnotationComposer,
          $$PurchaseInvoicesTableCreateCompanionBuilder,
          $$PurchaseInvoicesTableUpdateCompanionBuilder,
          (PurchaseInvoiceRow, $$PurchaseInvoicesTableReferences),
          PurchaseInvoiceRow,
          PrefetchHooks Function({
            bool supplierId,
            bool purchaseItemsRefs,
            bool supplierLedgerRefs,
          })
        > {
  $$PurchaseInvoicesTableTableManager(
    _$AppDatabase db,
    $PurchaseInvoicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseInvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplierRef = const Value.absent(),
                Value<DateTime> invoiceDate = const Value.absent(),
                Value<int> subtotalPiasters = const Value.absent(),
                Value<int> discountPiasters = const Value.absent(),
                Value<int> totalPiasters = const Value.absent(),
                Value<int> paidPiasters = const Value.absent(),
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseInvoicesCompanion(
                id: id,
                number: number,
                supplierId: supplierId,
                supplierRef: supplierRef,
                invoiceDate: invoiceDate,
                subtotalPiasters: subtotalPiasters,
                discountPiasters: discountPiasters,
                totalPiasters: totalPiasters,
                paidPiasters: paidPiasters,
                paymentMethod: paymentMethod,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int number,
                Value<String?> supplierId = const Value.absent(),
                Value<String?> supplierRef = const Value.absent(),
                required DateTime invoiceDate,
                required int subtotalPiasters,
                Value<int> discountPiasters = const Value.absent(),
                required int totalPiasters,
                required int paidPiasters,
                Value<PaymentMethod> paymentMethod = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseInvoicesCompanion.insert(
                id: id,
                number: number,
                supplierId: supplierId,
                supplierRef: supplierRef,
                invoiceDate: invoiceDate,
                subtotalPiasters: subtotalPiasters,
                discountPiasters: discountPiasters,
                totalPiasters: totalPiasters,
                paidPiasters: paidPiasters,
                paymentMethod: paymentMethod,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseInvoicesTable, PurchaseInvoiceRow>(
                    table,
                  ),
                  $$PurchaseInvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                purchaseItemsRefs = false,
                supplierLedgerRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseItemsRefs) db.purchaseItems,
                    if (supplierLedgerRefs) db.supplierLedger,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$PurchaseInvoicesTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$PurchaseInvoicesTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseItemsRefs)
                        await $_getPrefetchedData<
                          PurchaseInvoiceRow,
                          $PurchaseInvoicesTable,
                          PurchaseItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseInvoicesTableReferences
                              ._purchaseItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseInvoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierLedgerRefs)
                        await $_getPrefetchedData<
                          PurchaseInvoiceRow,
                          $PurchaseInvoicesTable,
                          SupplierLedgerRow
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseInvoicesTableReferences
                              ._supplierLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseInvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseInvoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PurchaseInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseInvoicesTable,
      PurchaseInvoiceRow,
      $$PurchaseInvoicesTableFilterComposer,
      $$PurchaseInvoicesTableOrderingComposer,
      $$PurchaseInvoicesTableAnnotationComposer,
      $$PurchaseInvoicesTableCreateCompanionBuilder,
      $$PurchaseInvoicesTableUpdateCompanionBuilder,
      (PurchaseInvoiceRow, $$PurchaseInvoicesTableReferences),
      PurchaseInvoiceRow,
      PrefetchHooks Function({
        bool supplierId,
        bool purchaseItemsRefs,
        bool supplierLedgerRefs,
      })
    >;
typedef $$PurchaseItemsTableCreateCompanionBuilder =
    PurchaseItemsCompanion Function({
      required String id,
      required String purchaseInvoiceId,
      required int lineNo,
      required String productId,
      required String productNameSnapshot,
      required int qtyMilli,
      required int unitCostPiasters,
      Value<int> discountPiasters,
      required int lineTotalPiasters,
      required int invoiceDiscountSharePiasters,
      required int netLineCostPiasters,
      required int avgCostBeforePiasters,
      required int avgCostAfterPiasters,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PurchaseItemsTableUpdateCompanionBuilder =
    PurchaseItemsCompanion Function({
      Value<String> id,
      Value<String> purchaseInvoiceId,
      Value<int> lineNo,
      Value<String> productId,
      Value<String> productNameSnapshot,
      Value<int> qtyMilli,
      Value<int> unitCostPiasters,
      Value<int> discountPiasters,
      Value<int> lineTotalPiasters,
      Value<int> invoiceDiscountSharePiasters,
      Value<int> netLineCostPiasters,
      Value<int> avgCostBeforePiasters,
      Value<int> avgCostAfterPiasters,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PurchaseItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItemRow> {
  $$PurchaseItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchaseInvoicesTable _purchaseInvoiceIdTable(_$AppDatabase db) =>
      db.purchaseInvoices.createAlias(
        'purchase_items__purchase_invoice_id__purchase_invoices__id',
      );

  $$PurchaseInvoicesTableProcessedTableManager get purchaseInvoiceId {
    final $_column = $_itemColumn<String>('purchase_invoice_id')!;

    final manager = $$PurchaseInvoicesTableTableManager(
      $_db,
      $_db.purchaseInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseInvoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('purchase_items__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovementRow>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'purchase_items__id__stock_movements__purchase_item_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.purchaseItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchaseItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalPiasters => $composableBuilder(
    column: $table.lineTotalPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invoiceDiscountSharePiasters => $composableBuilder(
    column: $table.invoiceDiscountSharePiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netLineCostPiasters => $composableBuilder(
    column: $table.netLineCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCostBeforePiasters => $composableBuilder(
    column: $table.avgCostBeforePiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avgCostAfterPiasters => $composableBuilder(
    column: $table.avgCostAfterPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$PurchaseInvoicesTableFilterComposer get purchaseInvoiceId {
    final $$PurchaseInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseInvoiceId,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.purchaseItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineNo => $composableBuilder(
    column: $table.lineNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyMilli => $composableBuilder(
    column: $table.qtyMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalPiasters => $composableBuilder(
    column: $table.lineTotalPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invoiceDiscountSharePiasters => $composableBuilder(
    column: $table.invoiceDiscountSharePiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netLineCostPiasters => $composableBuilder(
    column: $table.netLineCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCostBeforePiasters => $composableBuilder(
    column: $table.avgCostBeforePiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avgCostAfterPiasters => $composableBuilder(
    column: $table.avgCostAfterPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchaseInvoicesTableOrderingComposer get purchaseInvoiceId {
    final $$PurchaseInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseInvoiceId,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get qtyMilli =>
      $composableBuilder(column: $table.qtyMilli, builder: (column) => column);

  GeneratedColumn<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountPiasters => $composableBuilder(
    column: $table.discountPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalPiasters => $composableBuilder(
    column: $table.lineTotalPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get invoiceDiscountSharePiasters => $composableBuilder(
    column: $table.invoiceDiscountSharePiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netLineCostPiasters => $composableBuilder(
    column: $table.netLineCostPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgCostBeforePiasters => $composableBuilder(
    column: $table.avgCostBeforePiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get avgCostAfterPiasters => $composableBuilder(
    column: $table.avgCostAfterPiasters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PurchaseInvoicesTableAnnotationComposer get purchaseInvoiceId {
    final $$PurchaseInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseInvoiceId,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.purchaseItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchaseItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseItemsTable,
          PurchaseItemRow,
          $$PurchaseItemsTableFilterComposer,
          $$PurchaseItemsTableOrderingComposer,
          $$PurchaseItemsTableAnnotationComposer,
          $$PurchaseItemsTableCreateCompanionBuilder,
          $$PurchaseItemsTableUpdateCompanionBuilder,
          (PurchaseItemRow, $$PurchaseItemsTableReferences),
          PurchaseItemRow,
          PrefetchHooks Function({
            bool purchaseInvoiceId,
            bool productId,
            bool stockMovementsRefs,
          })
        > {
  $$PurchaseItemsTableTableManager(_$AppDatabase db, $PurchaseItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> purchaseInvoiceId = const Value.absent(),
                Value<int> lineNo = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<int> qtyMilli = const Value.absent(),
                Value<int> unitCostPiasters = const Value.absent(),
                Value<int> discountPiasters = const Value.absent(),
                Value<int> lineTotalPiasters = const Value.absent(),
                Value<int> invoiceDiscountSharePiasters = const Value.absent(),
                Value<int> netLineCostPiasters = const Value.absent(),
                Value<int> avgCostBeforePiasters = const Value.absent(),
                Value<int> avgCostAfterPiasters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseItemsCompanion(
                id: id,
                purchaseInvoiceId: purchaseInvoiceId,
                lineNo: lineNo,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                qtyMilli: qtyMilli,
                unitCostPiasters: unitCostPiasters,
                discountPiasters: discountPiasters,
                lineTotalPiasters: lineTotalPiasters,
                invoiceDiscountSharePiasters: invoiceDiscountSharePiasters,
                netLineCostPiasters: netLineCostPiasters,
                avgCostBeforePiasters: avgCostBeforePiasters,
                avgCostAfterPiasters: avgCostAfterPiasters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String purchaseInvoiceId,
                required int lineNo,
                required String productId,
                required String productNameSnapshot,
                required int qtyMilli,
                required int unitCostPiasters,
                Value<int> discountPiasters = const Value.absent(),
                required int lineTotalPiasters,
                required int invoiceDiscountSharePiasters,
                required int netLineCostPiasters,
                required int avgCostBeforePiasters,
                required int avgCostAfterPiasters,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseItemsCompanion.insert(
                id: id,
                purchaseInvoiceId: purchaseInvoiceId,
                lineNo: lineNo,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                qtyMilli: qtyMilli,
                unitCostPiasters: unitCostPiasters,
                discountPiasters: discountPiasters,
                lineTotalPiasters: lineTotalPiasters,
                invoiceDiscountSharePiasters: invoiceDiscountSharePiasters,
                netLineCostPiasters: netLineCostPiasters,
                avgCostBeforePiasters: avgCostBeforePiasters,
                avgCostAfterPiasters: avgCostAfterPiasters,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchaseItemsTable, PurchaseItemRow>(table),
                  $$PurchaseItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                purchaseInvoiceId = false,
                productId = false,
                stockMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockMovementsRefs) db.stockMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (purchaseInvoiceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseInvoiceId,
                            referencedTable: $$PurchaseItemsTableReferences
                                ._purchaseInvoiceIdTable(db),
                            referencedColumn: $$PurchaseItemsTableReferences
                                ._purchaseInvoiceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable: $$PurchaseItemsTableReferences
                                ._productIdTable(db),
                            referencedColumn: $$PurchaseItemsTableReferences
                                ._productIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          PurchaseItemRow,
                          $PurchaseItemsTable,
                          StockMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$PurchaseItemsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchaseItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PurchaseItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseItemsTable,
      PurchaseItemRow,
      $$PurchaseItemsTableFilterComposer,
      $$PurchaseItemsTableOrderingComposer,
      $$PurchaseItemsTableAnnotationComposer,
      $$PurchaseItemsTableCreateCompanionBuilder,
      $$PurchaseItemsTableUpdateCompanionBuilder,
      (PurchaseItemRow, $$PurchaseItemsTableReferences),
      PurchaseItemRow,
      PrefetchHooks Function({
        bool purchaseInvoiceId,
        bool productId,
        bool stockMovementsRefs,
      })
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      required String id,
      required String productId,
      required MovementType movementType,
      required int qtyDeltaMilli,
      required int unitCostPiasters,
      Value<String?> saleItemId,
      Value<String?> saleReturnItemId,
      Value<String?> purchaseItemId,
      Value<String?> reversesMovementId,
      Value<AdjustmentReason?> adjustmentReason,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<MovementType> movementType,
      Value<int> qtyDeltaMilli,
      Value<int> unitCostPiasters,
      Value<String?> saleItemId,
      Value<String?> saleReturnItemId,
      Value<String?> purchaseItemId,
      Value<String?> reversesMovementId,
      Value<AdjustmentReason?> adjustmentReason,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StockMovementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow> {
  $$StockMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('stock_movements__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SaleItemsTable _saleItemIdTable(_$AppDatabase db) =>
      db.saleItems.createAlias('stock_movements__sale_item_id__sale_items__id');

  $$SaleItemsTableProcessedTableManager? get saleItemId {
    final $_column = $_itemColumn<String>('sale_item_id');
    if ($_column == null) return null;
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SaleReturnItemsTable _saleReturnItemIdTable(_$AppDatabase db) =>
      db.saleReturnItems.createAlias(
        'stock_movements__sale_return_item_id__sale_return_items__id',
      );

  $$SaleReturnItemsTableProcessedTableManager? get saleReturnItemId {
    final $_column = $_itemColumn<String>('sale_return_item_id');
    if ($_column == null) return null;
    final manager = $$SaleReturnItemsTableTableManager(
      $_db,
      $_db.saleReturnItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleReturnItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PurchaseItemsTable _purchaseItemIdTable(_$AppDatabase db) => db
      .purchaseItems
      .createAlias('stock_movements__purchase_item_id__purchase_items__id');

  $$PurchaseItemsTableProcessedTableManager? get purchaseItemId {
    final $_column = $_itemColumn<String>('purchase_item_id');
    if ($_column == null) return null;
    final manager = $$PurchaseItemsTableTableManager(
      $_db,
      $_db.purchaseItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StockMovementsTable _reversesMovementIdTable(_$AppDatabase db) =>
      db.stockMovements.createAlias(
        'stock_movements__reverses_movement_id__stock_movements__id',
      );

  $$StockMovementsTableProcessedTableManager? get reversesMovementId {
    final $_column = $_itemColumn<String>('reverses_movement_id');
    if ($_column == null) return null;
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reversesMovementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MovementType, MovementType, String>
  get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get qtyDeltaMilli => $composableBuilder(
    column: $table.qtyDeltaMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AdjustmentReason?, AdjustmentReason, String>
  get adjustmentReason => $composableBuilder(
    column: $table.adjustmentReason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleItemsTableFilterComposer get saleItemId {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleItemId,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleReturnItemsTableFilterComposer get saleReturnItemId {
    final $$SaleReturnItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnItemId,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseItemsTableFilterComposer get purchaseItemId {
    final $$PurchaseItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseItemId,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StockMovementsTableFilterComposer get reversesMovementId {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesMovementId,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qtyDeltaMilli => $composableBuilder(
    column: $table.qtyDeltaMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustmentReason => $composableBuilder(
    column: $table.adjustmentReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleItemsTableOrderingComposer get saleItemId {
    final $$SaleItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleItemId,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableOrderingComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleReturnItemsTableOrderingComposer get saleReturnItemId {
    final $$SaleReturnItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnItemId,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableOrderingComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseItemsTableOrderingComposer get purchaseItemId {
    final $$PurchaseItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseItemId,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StockMovementsTableOrderingComposer get reversesMovementId {
    final $$StockMovementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesMovementId,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableOrderingComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MovementType, String> get movementType =>
      $composableBuilder(
        column: $table.movementType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get qtyDeltaMilli => $composableBuilder(
    column: $table.qtyDeltaMilli,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitCostPiasters => $composableBuilder(
    column: $table.unitCostPiasters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AdjustmentReason?, String>
  get adjustmentReason => $composableBuilder(
    column: $table.adjustmentReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleItemsTableAnnotationComposer get saleItemId {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleItemId,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleReturnItemsTableAnnotationComposer get saleReturnItemId {
    final $$SaleReturnItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnItemId,
      referencedTable: $db.saleReturnItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturnItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseItemsTableAnnotationComposer get purchaseItemId {
    final $$PurchaseItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseItemId,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StockMovementsTableAnnotationComposer get reversesMovementId {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesMovementId,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovementRow,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (StockMovementRow, $$StockMovementsTableReferences),
          StockMovementRow,
          PrefetchHooks Function({
            bool productId,
            bool saleItemId,
            bool saleReturnItemId,
            bool purchaseItemId,
            bool reversesMovementId,
          })
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<MovementType> movementType = const Value.absent(),
                Value<int> qtyDeltaMilli = const Value.absent(),
                Value<int> unitCostPiasters = const Value.absent(),
                Value<String?> saleItemId = const Value.absent(),
                Value<String?> saleReturnItemId = const Value.absent(),
                Value<String?> purchaseItemId = const Value.absent(),
                Value<String?> reversesMovementId = const Value.absent(),
                Value<AdjustmentReason?> adjustmentReason =
                    const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                movementType: movementType,
                qtyDeltaMilli: qtyDeltaMilli,
                unitCostPiasters: unitCostPiasters,
                saleItemId: saleItemId,
                saleReturnItemId: saleReturnItemId,
                purchaseItemId: purchaseItemId,
                reversesMovementId: reversesMovementId,
                adjustmentReason: adjustmentReason,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required MovementType movementType,
                required int qtyDeltaMilli,
                required int unitCostPiasters,
                Value<String?> saleItemId = const Value.absent(),
                Value<String?> saleReturnItemId = const Value.absent(),
                Value<String?> purchaseItemId = const Value.absent(),
                Value<String?> reversesMovementId = const Value.absent(),
                Value<AdjustmentReason?> adjustmentReason =
                    const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                movementType: movementType,
                qtyDeltaMilli: qtyDeltaMilli,
                unitCostPiasters: unitCostPiasters,
                saleItemId: saleItemId,
                saleReturnItemId: saleReturnItemId,
                purchaseItemId: purchaseItemId,
                reversesMovementId: reversesMovementId,
                adjustmentReason: adjustmentReason,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockMovementsTable, StockMovementRow>(table),
                  $$StockMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productId = false,
                saleItemId = false,
                saleReturnItemId = false,
                purchaseItemId = false,
                reversesMovementId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (productId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.productId,
                            referencedTable: $$StockMovementsTableReferences
                                ._productIdTable(db),
                            referencedColumn: $$StockMovementsTableReferences
                                ._productIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (saleItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.saleItemId,
                            referencedTable: $$StockMovementsTableReferences
                                ._saleItemIdTable(db),
                            referencedColumn: $$StockMovementsTableReferences
                                ._saleItemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (saleReturnItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.saleReturnItemId,
                            referencedTable: $$StockMovementsTableReferences
                                ._saleReturnItemIdTable(db),
                            referencedColumn: $$StockMovementsTableReferences
                                ._saleReturnItemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (purchaseItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseItemId,
                            referencedTable: $$StockMovementsTableReferences
                                ._purchaseItemIdTable(db),
                            referencedColumn: $$StockMovementsTableReferences
                                ._purchaseItemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (reversesMovementId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.reversesMovementId,
                            referencedTable: $$StockMovementsTableReferences
                                ._reversesMovementIdTable(db),
                            referencedColumn: $$StockMovementsTableReferences
                                ._reversesMovementIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovementRow,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (StockMovementRow, $$StockMovementsTableReferences),
      StockMovementRow,
      PrefetchHooks Function({
        bool productId,
        bool saleItemId,
        bool saleReturnItemId,
        bool purchaseItemId,
        bool reversesMovementId,
      })
    >;
typedef $$CustomerLedgerTableCreateCompanionBuilder =
    CustomerLedgerCompanion Function({
      required String id,
      required String customerId,
      required CustomerEntryType entryType,
      required int amountPiasters,
      Value<String?> salesInvoiceId,
      Value<String?> saleReturnId,
      Value<int?> receiptNumber,
      Value<PaymentMethod?> paymentMethod,
      Value<String?> reversesEntryId,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CustomerLedgerTableUpdateCompanionBuilder =
    CustomerLedgerCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<CustomerEntryType> entryType,
      Value<int> amountPiasters,
      Value<String?> salesInvoiceId,
      Value<String?> saleReturnId,
      Value<int?> receiptNumber,
      Value<PaymentMethod?> paymentMethod,
      Value<String?> reversesEntryId,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CustomerLedgerTableReferences
    extends
        BaseReferences<_$AppDatabase, $CustomerLedgerTable, CustomerLedgerRow> {
  $$CustomerLedgerTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('customer_ledger__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SalesInvoicesTable _salesInvoiceIdTable(_$AppDatabase db) => db
      .salesInvoices
      .createAlias('customer_ledger__sales_invoice_id__sales_invoices__id');

  $$SalesInvoicesTableProcessedTableManager? get salesInvoiceId {
    final $_column = $_itemColumn<String>('sales_invoice_id');
    if ($_column == null) return null;
    final manager = $$SalesInvoicesTableTableManager(
      $_db,
      $_db.salesInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_salesInvoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SaleReturnsTable _saleReturnIdTable(_$AppDatabase db) => db
      .saleReturns
      .createAlias('customer_ledger__sale_return_id__sale_returns__id');

  $$SaleReturnsTableProcessedTableManager? get saleReturnId {
    final $_column = $_itemColumn<String>('sale_return_id');
    if ($_column == null) return null;
    final manager = $$SaleReturnsTableTableManager(
      $_db,
      $_db.saleReturns,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleReturnIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomerLedgerTable _reversesEntryIdTable(_$AppDatabase db) => db
      .customerLedger
      .createAlias('customer_ledger__reverses_entry_id__customer_ledger__id');

  $$CustomerLedgerTableProcessedTableManager? get reversesEntryId {
    final $_column = $_itemColumn<String>('reverses_entry_id');
    if ($_column == null) return null;
    final manager = $$CustomerLedgerTableTableManager(
      $_db,
      $_db.customerLedger,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reversesEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerLedgerTable> {
  $$CustomerLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CustomerEntryType, CustomerEntryType, String>
  get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod?, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SalesInvoicesTableFilterComposer get salesInvoiceId {
    final $$SalesInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleReturnsTableFilterComposer get saleReturnId {
    final $$SaleReturnsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnId,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableFilterComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomerLedgerTableFilterComposer get reversesEntryId {
    final $$CustomerLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableFilterComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerLedgerTable> {
  $$CustomerLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SalesInvoicesTableOrderingComposer get salesInvoiceId {
    final $$SalesInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleReturnsTableOrderingComposer get saleReturnId {
    final $$SaleReturnsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnId,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableOrderingComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomerLedgerTableOrderingComposer get reversesEntryId {
    final $$CustomerLedgerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableOrderingComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerLedgerTable> {
  $$CustomerLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CustomerEntryType, String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMethod?, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SalesInvoicesTableAnnotationComposer get salesInvoiceId {
    final $$SalesInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.salesInvoiceId,
      referencedTable: $db.salesInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.salesInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SaleReturnsTableAnnotationComposer get saleReturnId {
    final $$SaleReturnsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleReturnId,
      referencedTable: $db.saleReturns,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleReturnsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleReturns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomerLedgerTableAnnotationComposer get reversesEntryId {
    final $$CustomerLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.customerLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.customerLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerLedgerTable,
          CustomerLedgerRow,
          $$CustomerLedgerTableFilterComposer,
          $$CustomerLedgerTableOrderingComposer,
          $$CustomerLedgerTableAnnotationComposer,
          $$CustomerLedgerTableCreateCompanionBuilder,
          $$CustomerLedgerTableUpdateCompanionBuilder,
          (CustomerLedgerRow, $$CustomerLedgerTableReferences),
          CustomerLedgerRow,
          PrefetchHooks Function({
            bool customerId,
            bool salesInvoiceId,
            bool saleReturnId,
            bool reversesEntryId,
          })
        > {
  $$CustomerLedgerTableTableManager(
    _$AppDatabase db,
    $CustomerLedgerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<CustomerEntryType> entryType = const Value.absent(),
                Value<int> amountPiasters = const Value.absent(),
                Value<String?> salesInvoiceId = const Value.absent(),
                Value<String?> saleReturnId = const Value.absent(),
                Value<int?> receiptNumber = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<String?> reversesEntryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerLedgerCompanion(
                id: id,
                customerId: customerId,
                entryType: entryType,
                amountPiasters: amountPiasters,
                salesInvoiceId: salesInvoiceId,
                saleReturnId: saleReturnId,
                receiptNumber: receiptNumber,
                paymentMethod: paymentMethod,
                reversesEntryId: reversesEntryId,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required CustomerEntryType entryType,
                required int amountPiasters,
                Value<String?> salesInvoiceId = const Value.absent(),
                Value<String?> saleReturnId = const Value.absent(),
                Value<int?> receiptNumber = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<String?> reversesEntryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomerLedgerCompanion.insert(
                id: id,
                customerId: customerId,
                entryType: entryType,
                amountPiasters: amountPiasters,
                salesInvoiceId: salesInvoiceId,
                saleReturnId: saleReturnId,
                receiptNumber: receiptNumber,
                paymentMethod: paymentMethod,
                reversesEntryId: reversesEntryId,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomerLedgerTable, CustomerLedgerRow>(table),
                  $$CustomerLedgerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                salesInvoiceId = false,
                saleReturnId = false,
                reversesEntryId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable: $$CustomerLedgerTableReferences
                                ._customerIdTable(db),
                            referencedColumn: $$CustomerLedgerTableReferences
                                ._customerIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (salesInvoiceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.salesInvoiceId,
                            referencedTable: $$CustomerLedgerTableReferences
                                ._salesInvoiceIdTable(db),
                            referencedColumn: $$CustomerLedgerTableReferences
                                ._salesInvoiceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (saleReturnId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.saleReturnId,
                            referencedTable: $$CustomerLedgerTableReferences
                                ._saleReturnIdTable(db),
                            referencedColumn: $$CustomerLedgerTableReferences
                                ._saleReturnIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (reversesEntryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.reversesEntryId,
                            referencedTable: $$CustomerLedgerTableReferences
                                ._reversesEntryIdTable(db),
                            referencedColumn: $$CustomerLedgerTableReferences
                                ._reversesEntryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$CustomerLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerLedgerTable,
      CustomerLedgerRow,
      $$CustomerLedgerTableFilterComposer,
      $$CustomerLedgerTableOrderingComposer,
      $$CustomerLedgerTableAnnotationComposer,
      $$CustomerLedgerTableCreateCompanionBuilder,
      $$CustomerLedgerTableUpdateCompanionBuilder,
      (CustomerLedgerRow, $$CustomerLedgerTableReferences),
      CustomerLedgerRow,
      PrefetchHooks Function({
        bool customerId,
        bool salesInvoiceId,
        bool saleReturnId,
        bool reversesEntryId,
      })
    >;
typedef $$SupplierLedgerTableCreateCompanionBuilder =
    SupplierLedgerCompanion Function({
      required String id,
      required String supplierId,
      required SupplierEntryType entryType,
      required int amountPiasters,
      Value<String?> purchaseInvoiceId,
      Value<int?> paymentNumber,
      Value<PaymentMethod?> paymentMethod,
      Value<String?> reversesEntryId,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SupplierLedgerTableUpdateCompanionBuilder =
    SupplierLedgerCompanion Function({
      Value<String> id,
      Value<String> supplierId,
      Value<SupplierEntryType> entryType,
      Value<int> amountPiasters,
      Value<String?> purchaseInvoiceId,
      Value<int?> paymentNumber,
      Value<PaymentMethod?> paymentMethod,
      Value<String?> reversesEntryId,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SupplierLedgerTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierLedgerTable, SupplierLedgerRow> {
  $$SupplierLedgerTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('supplier_ledger__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<String>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PurchaseInvoicesTable _purchaseInvoiceIdTable(_$AppDatabase db) =>
      db.purchaseInvoices.createAlias(
        'supplier_ledger__purchase_invoice_id__purchase_invoices__id',
      );

  $$PurchaseInvoicesTableProcessedTableManager? get purchaseInvoiceId {
    final $_column = $_itemColumn<String>('purchase_invoice_id');
    if ($_column == null) return null;
    final manager = $$PurchaseInvoicesTableTableManager(
      $_db,
      $_db.purchaseInvoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseInvoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierLedgerTable _reversesEntryIdTable(_$AppDatabase db) => db
      .supplierLedger
      .createAlias('supplier_ledger__reverses_entry_id__supplier_ledger__id');

  $$SupplierLedgerTableProcessedTableManager? get reversesEntryId {
    final $_column = $_itemColumn<String>('reverses_entry_id');
    if ($_column == null) return null;
    final manager = $$SupplierLedgerTableTableManager(
      $_db,
      $_db.supplierLedger,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reversesEntryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierLedgerTable> {
  $$SupplierLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SupplierEntryType, SupplierEntryType, String>
  get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentNumber => $composableBuilder(
    column: $table.paymentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentMethod?, PaymentMethod, String>
  get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseInvoicesTableFilterComposer get purchaseInvoiceId {
    final $$PurchaseInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseInvoiceId,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierLedgerTableFilterComposer get reversesEntryId {
    final $$SupplierLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.supplierLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgerTableFilterComposer(
            $db: $db,
            $table: $db.supplierLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierLedgerTable> {
  $$SupplierLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentNumber => $composableBuilder(
    column: $table.paymentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseInvoicesTableOrderingComposer get purchaseInvoiceId {
    final $$PurchaseInvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseInvoiceId,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierLedgerTableOrderingComposer get reversesEntryId {
    final $$SupplierLedgerTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.supplierLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgerTableOrderingComposer(
            $db: $db,
            $table: $db.supplierLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierLedgerTable> {
  $$SupplierLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SupplierEntryType, String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentNumber => $composableBuilder(
    column: $table.paymentNumber,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentMethod?, String> get paymentMethod =>
      $composableBuilder(
        column: $table.paymentMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PurchaseInvoicesTableAnnotationComposer get purchaseInvoiceId {
    final $$PurchaseInvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseInvoiceId,
      referencedTable: $db.purchaseInvoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseInvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierLedgerTableAnnotationComposer get reversesEntryId {
    final $$SupplierLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reversesEntryId,
      referencedTable: $db.supplierLedger,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierLedgerTable,
          SupplierLedgerRow,
          $$SupplierLedgerTableFilterComposer,
          $$SupplierLedgerTableOrderingComposer,
          $$SupplierLedgerTableAnnotationComposer,
          $$SupplierLedgerTableCreateCompanionBuilder,
          $$SupplierLedgerTableUpdateCompanionBuilder,
          (SupplierLedgerRow, $$SupplierLedgerTableReferences),
          SupplierLedgerRow,
          PrefetchHooks Function({
            bool supplierId,
            bool purchaseInvoiceId,
            bool reversesEntryId,
          })
        > {
  $$SupplierLedgerTableTableManager(
    _$AppDatabase db,
    $SupplierLedgerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> supplierId = const Value.absent(),
                Value<SupplierEntryType> entryType = const Value.absent(),
                Value<int> amountPiasters = const Value.absent(),
                Value<String?> purchaseInvoiceId = const Value.absent(),
                Value<int?> paymentNumber = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<String?> reversesEntryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplierLedgerCompanion(
                id: id,
                supplierId: supplierId,
                entryType: entryType,
                amountPiasters: amountPiasters,
                purchaseInvoiceId: purchaseInvoiceId,
                paymentNumber: paymentNumber,
                paymentMethod: paymentMethod,
                reversesEntryId: reversesEntryId,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String supplierId,
                required SupplierEntryType entryType,
                required int amountPiasters,
                Value<String?> purchaseInvoiceId = const Value.absent(),
                Value<int?> paymentNumber = const Value.absent(),
                Value<PaymentMethod?> paymentMethod = const Value.absent(),
                Value<String?> reversesEntryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SupplierLedgerCompanion.insert(
                id: id,
                supplierId: supplierId,
                entryType: entryType,
                amountPiasters: amountPiasters,
                purchaseInvoiceId: purchaseInvoiceId,
                paymentNumber: paymentNumber,
                paymentMethod: paymentMethod,
                reversesEntryId: reversesEntryId,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SupplierLedgerTable, SupplierLedgerRow>(table),
                  $$SupplierLedgerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                purchaseInvoiceId = false,
                reversesEntryId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$SupplierLedgerTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$SupplierLedgerTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (purchaseInvoiceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.purchaseInvoiceId,
                            referencedTable: $$SupplierLedgerTableReferences
                                ._purchaseInvoiceIdTable(db),
                            referencedColumn: $$SupplierLedgerTableReferences
                                ._purchaseInvoiceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (reversesEntryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.reversesEntryId,
                            referencedTable: $$SupplierLedgerTableReferences
                                ._reversesEntryIdTable(db),
                            referencedColumn: $$SupplierLedgerTableReferences
                                ._reversesEntryIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$SupplierLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierLedgerTable,
      SupplierLedgerRow,
      $$SupplierLedgerTableFilterComposer,
      $$SupplierLedgerTableOrderingComposer,
      $$SupplierLedgerTableAnnotationComposer,
      $$SupplierLedgerTableCreateCompanionBuilder,
      $$SupplierLedgerTableUpdateCompanionBuilder,
      (SupplierLedgerRow, $$SupplierLedgerTableReferences),
      SupplierLedgerRow,
      PrefetchHooks Function({
        bool supplierId,
        bool purchaseInvoiceId,
        bool reversesEntryId,
      })
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required int number,
  required String expenseCategoryId,
  required int amountPiasters,
  required DateTime spentAt,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<int> number,
  Value<String> expenseCategoryId,
  Value<int> amountPiasters,
  Value<DateTime> spentAt,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExpenseCategoriesTable _expenseCategoryIdTable(_$AppDatabase db) => db
      .expenseCategories
      .createAlias('expenses__expense_category_id__expense_categories__id');

  $$ExpenseCategoriesTableProcessedTableManager get expenseCategoryId {
    final $_column = $_itemColumn<String>('expense_category_id')!;

    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseCategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get spentAt =>
      $composableBuilder(
        column: $table.spentAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get voidedAt =>
      $composableBuilder(
        column: $table.voidedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$ExpenseCategoriesTableFilterComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseCategoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get spentAt => $composableBuilder(
    column: $table.spentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExpenseCategoriesTableOrderingComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseCategoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get amountPiasters => $composableBuilder(
    column: $table.amountPiasters,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get spentAt =>
      $composableBuilder(column: $table.spentAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$ExpenseCategoriesTableAnnotationComposer get expenseCategoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.expenseCategoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseRow,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (ExpenseRow, $$ExpensesTableReferences),
          ExpenseRow,
          PrefetchHooks Function({bool expenseCategoryId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> expenseCategoryId = const Value.absent(),
                Value<int> amountPiasters = const Value.absent(),
                Value<DateTime> spentAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                number: number,
                expenseCategoryId: expenseCategoryId,
                amountPiasters: amountPiasters,
                spentAt: spentAt,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int number,
                required String expenseCategoryId,
                required int amountPiasters,
                required DateTime spentAt,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                number: number,
                expenseCategoryId: expenseCategoryId,
                amountPiasters: amountPiasters,
                spentAt: spentAt,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseRow>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expenseCategoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (expenseCategoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.expenseCategoryId,
                        referencedTable: $$ExpensesTableReferences
                            ._expenseCategoryIdTable(db),
                        referencedColumn: $$ExpensesTableReferences
                            ._expenseCategoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseRow,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseRow, $$ExpensesTableReferences),
      ExpenseRow,
      PrefetchHooks Function({bool expenseCategoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db, _db.counters);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$SalesInvoicesTableTableManager get salesInvoices =>
      $$SalesInvoicesTableTableManager(_db, _db.salesInvoices);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$SaleReturnsTableTableManager get saleReturns =>
      $$SaleReturnsTableTableManager(_db, _db.saleReturns);
  $$SaleReturnItemsTableTableManager get saleReturnItems =>
      $$SaleReturnItemsTableTableManager(_db, _db.saleReturnItems);
  $$PurchaseInvoicesTableTableManager get purchaseInvoices =>
      $$PurchaseInvoicesTableTableManager(_db, _db.purchaseInvoices);
  $$PurchaseItemsTableTableManager get purchaseItems =>
      $$PurchaseItemsTableTableManager(_db, _db.purchaseItems);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$CustomerLedgerTableTableManager get customerLedger =>
      $$CustomerLedgerTableTableManager(_db, _db.customerLedger);
  $$SupplierLedgerTableTableManager get supplierLedger =>
      $$SupplierLedgerTableTableManager(_db, _db.supplierLedger);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
}
