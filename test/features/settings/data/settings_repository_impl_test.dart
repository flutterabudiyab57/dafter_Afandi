import 'dart:io';

import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/features/settings/data/settings_repository_impl.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/settings/domain/settings_repository.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final DateTime _now = DateTime.utc(2026, 10, 20, 12);

AppDatabase _open(QueryExecutorFactory executor) =>
    AppDatabase(executor(), const UuidV7Generator(), FixedClock(_now));

typedef QueryExecutorFactory = NativeDatabase Function();

SettingsRepositoryImpl _repo(AppDatabase db) => SettingsRepositoryImpl(
  db.settingsDao,
  DriftTransactionRunner(db),
  FixedClock(_now),
);

void main() {
  group('in memory', () {
    late AppDatabase db;
    late SettingsRepositoryImpl repo;

    setUp(() {
      db = _open(NativeDatabase.memory);
      repo = _repo(db);
    });
    tearDown(() => db.close());

    test('load returns the seeded defaults', () async {
      final s = await repo.load();
      expect(s.locale, AppLocale.ar);
      expect(s.digitStyle, DigitStylePreference.followLanguage);
      expect(s.shop, isNull);
      expect(s.onboardingCompleted, isFalse);
    });

    test('setLocale and setDigitStyle are stored', () async {
      await repo.setLocale(AppLocale.en);
      await repo.setDigitStyle(DigitStylePreference.arabicIndic);
      final s = await repo.load();
      expect(s.locale, AppLocale.en);
      expect(s.digitStyle, DigitStylePreference.arabicIndic);

      await repo.setDigitStyle(DigitStylePreference.latin);
      expect((await repo.load()).digitStyle, DigitStylePreference.latin);
      await repo.setDigitStyle(DigitStylePreference.followLanguage);
      expect(
        (await repo.load()).digitStyle,
        DigitStylePreference.followLanguage,
      );
    });

    test('completeOnboarding stores the profile and the time', () async {
      await repo.completeOnboarding(
        const ShopProfile(name: 'محل 23', phone: '01012345678'),
      );
      final s = await repo.load();
      expect(s.onboardingCompleted, isTrue);
      expect(s.shop, const ShopProfile(name: 'محل 23', phone: '01012345678'));
      final row = await db.settingsDao.getSingleton();
      expect(row.onboardingCompletedAt, _now);
      expect(row.updatedAt, _now);
    });

    test(
      'completeOnboarding is atomic: a failed write leaves it NULL',
      () async {
        await db.customStatement(
          'CREATE TEMP TRIGGER fail BEFORE UPDATE ON app_settings '
          "BEGIN SELECT RAISE(ABORT, 'disk full'); END",
        );
        await expectLater(
          repo.completeOnboarding(const ShopProfile(name: 'Shop')),
          throwsA(isA<SettingsWriteFailure>()),
        );
        final row = await db.settingsDao.getSingleton();
        expect(row.onboardingCompletedAt, isNull);
        expect(row.shopName, isNull);
      },
    );

    test('the CHECK rejects onboarded-without-name', () async {
      await expectLater(
        db.settingsDao.updateSingleton(
          AppSettingsCompanion(onboardingCompletedAt: Value(_now)),
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
      'saveShopProfile requires onboarding, then updates the shop',
      () async {
        await expectLater(
          repo.saveShopProfile(const ShopProfile(name: 'Shop')),
          throwsStateError,
        );
        await repo.completeOnboarding(
          const ShopProfile(name: 'Shop', phone: '01012345678'),
        );
        await repo.saveShopProfile(const ShopProfile(name: 'New name'));
        expect((await repo.load()).shop, const ShopProfile(name: 'New name'));
      },
    );

    test('watch emits the current value, then each change', () async {
      final expectation = expectLater(
        repo.watch().map((s) => s.locale),
        emitsInOrder([AppLocale.ar, AppLocale.en]),
      );
      await pumpEventQueue();
      await repo.setLocale(AppLocale.en);
      await expectation;
    });
  });

  test('values persist after close and reopen (SC-003)', () async {
    final dir = await Directory.systemTemp.createTemp('daftar_settings_test_');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}${Platform.pathSeparator}s.sqlite');

    final first = _open(() => NativeDatabase(file));
    final repo = _repo(first);
    await repo.completeOnboarding(
      const ShopProfile(name: 'محل الأمل', phone: '+201012345678'),
    );
    await repo.setLocale(AppLocale.en);
    await repo.setDigitStyle(DigitStylePreference.latin);
    await first.close();

    final second = _open(() => NativeDatabase(file));
    addTearDown(second.close);
    final s = await _repo(second).load();
    expect(s.onboardingCompleted, isTrue);
    expect(
      s.shop,
      const ShopProfile(name: 'محل الأمل', phone: '+201012345678'),
    );
    expect(s.locale, AppLocale.en);
    expect(s.digitStyle, DigitStylePreference.latin);
  });
}
