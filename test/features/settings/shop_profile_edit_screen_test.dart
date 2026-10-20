import 'dart:io';

import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/features/settings/data/settings_repository_impl.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

Finder _name() => find.widgetWithText(TextField, 'اسم المحل');

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pumpAndSettle();
  }

  testWidgets('the form is pre-filled; clearing the name blocks Save', (
    tester,
  ) async {
    final repo = FakeSettingsRepository(kOnboardedSettings);
    await pumpApp(tester, repo);
    await goTo(tester, RoutePaths.settings);
    await tester.tap(find.text('بيانات المحل'));
    await tester.pumpAndSettle();

    expect(find.text('محل 23'), findsOneWidget);
    expect(find.text('01012345678'), findsOneWidget);

    await tester.enterText(_name(), '');
    await save(tester);
    expect(find.text('اكتب اسم المحل.'), findsOneWidget);
    expect(currentPath(tester), RoutePaths.settingsShop);
    expect(repo.writes, isEmpty);
    expect(repo.value.shop!.name, 'محل 23');
  });

  testWidgets('a failed save shows the error and keeps the inputs', (
    tester,
  ) async {
    final repo = FakeSettingsRepository(kOnboardedSettings);
    await pumpApp(tester, repo);
    await goTo(tester, RoutePaths.settingsShop);
    repo.failWith = 'disk full';
    await tester.enterText(_name(), 'محل جديد');
    await save(tester);
    expect(find.textContaining('تعذّر الحفظ'), findsOneWidget);
    expect(find.text('محل جديد'), findsOneWidget);
    expect(currentPath(tester), RoutePaths.settingsShop);
  });

  testWidgets('a valid edit pops and survives a database reopen', (
    tester,
  ) async {
    final dir = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('daftar_edit_test_'),
    ))!;
    final file = File('${dir.path}${Platform.pathSeparator}e.sqlite');
    final clock = FixedClock(DateTime.utc(2026, 10, 20, 9));
    AppDatabase open() =>
        AppDatabase(NativeDatabase(file), const UuidV7Generator(), clock);

    final db = open();
    final repo = SettingsRepositoryImpl(
      db.settingsDao,
      DriftTransactionRunner(db),
      clock,
    );
    await tester.runAsync(
      () => repo.completeOnboarding(const ShopProfile(name: 'Old name')),
    );

    await pumpApp(tester, repo);
    // /settings/shop is nested under /settings, so Save pops back to it.
    await goTo(tester, RoutePaths.settingsShop);

    await tester.enterText(_name(), 'New name');
    await tester.enterText(
      find.widgetWithText(TextField, 'رقم هاتف المحل'),
      '+٢٠ ١٠١ ٢٣٤ ٥٦٧٨',
    );
    await save(tester);
    expect(currentPath(tester), RoutePaths.settings);
    expect(find.text('New name'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() async {
      await db.close();
      final reopened = open();
      final row = await reopened.settingsDao.getSingleton();
      expect(row.shopName, 'New name');
      expect(row.shopPhone, '+201012345678');
      await reopened.close();
      await dir.delete(recursive: true);
    });
  });
}
