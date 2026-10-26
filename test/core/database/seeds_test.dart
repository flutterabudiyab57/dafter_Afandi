import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/tables/enums.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

final RegExp _uuidV7 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

void main() {
  late TempDatabase t;

  setUp(() async => t = await TempDatabase.open());
  tearDown(() => t.dispose());

  test('6 counters rows, one per DocType, each at 1', () async {
    final rows = await t.db.select(t.db.counters).get();
    expect(rows, hasLength(6));
    expect(rows.map((r) => r.docType).toSet(), DocType.values.toSet());
    expect(rows.every((r) => r.nextValue == 1), isTrue);
    expect(rows.every((r) => _uuidV7.hasMatch(r.id)), isTrue);
  });

  test('exactly one app_settings row with defaults', () async {
    final rows = await t.db.select(t.db.appSettings).get();
    expect(rows, hasLength(1));
    final s = rows.single;
    expect(s.singleton, 1);
    expect(s.localeCode, LocaleCode.ar);
    expect(s.digitStyle, DigitStylePreference.follow);
    expect(s.negativeStockPolicy, NegativeStockPolicy.warn);
    expect(s.shopName, isNull);
    expect(s.shopPhone, isNull);
    expect(s.onboardingCompletedAt, isNull);
    expect(s.appLockEnabled, isFalse);
    expect(s.biometricEnabled, isFalse);
    expect(_uuidV7.hasMatch(s.id), isTrue);
    expect(_uuidV7.hasMatch(s.deviceId), isTrue);
    expect(s.deviceId, isNot(s.id));
    expect(s.createdAt, testNow);
    expect(s.createdAt.isUtc, isTrue);
  });

  test('a second app_settings row is rejected', () async {
    await expectLater(
      t.db
          .into(t.db.appSettings)
          .insert(
            AppSettingsCompanion.insert(
              id: 'second',
              deviceId: 'second',
              createdAt: testNow,
              updatedAt: testNow,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
    await expectLater(
      t.db.exec(
        'INSERT INTO app_settings (id, singleton, device_id, created_at, updated_at) '
        "VALUES ('third', 2, 'd', 1, 1)",
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(await t.db.scalar('SELECT COUNT(*) FROM app_settings'), 1);
  });

  group('SettingsDao', () {
    test('getSingleton and updateSingleton', () async {
      final dao = t.db.settingsDao;
      await dao.updateSingleton(
        const AppSettingsCompanion(
          localeCode: Value(LocaleCode.en),
          digitStyle: Value(DigitStylePreference.latin),
        ),
      );
      final s = await dao.getSingleton();
      expect(s.localeCode, LocaleCode.en);
      expect(s.digitStyle, DigitStylePreference.latin);
    });

    test('watchSingleton emits the change', () async {
      final dao = t.db.settingsDao;
      final seen = dao.watchSingleton().map((s) => s.localeCode);
      final expectation = expectLater(
        seen,
        emitsInOrder([LocaleCode.ar, LocaleCode.en]),
      );
      await pumpEventQueue();
      await dao.updateSingleton(
        const AppSettingsCompanion(localeCode: Value(LocaleCode.en)),
      );
      await expectation;
    });

    test('updateSingleton fails unless exactly one row changed', () async {
      // A temp trigger that skips the row makes the UPDATE change 0 rows.
      final dao = t.db.settingsDao;
      await t.db.exec(
        'CREATE TEMP TRIGGER skip BEFORE UPDATE ON app_settings '
        'BEGIN SELECT RAISE(IGNORE); END',
      );
      await expectLater(
        dao.updateSingleton(
          const AppSettingsCompanion(localeCode: Value(LocaleCode.en)),
        ),
        throwsStateError,
      );
    });
  });
}
