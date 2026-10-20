import 'package:daftar_afandi/core/database/app_database.dart';
import 'package:daftar_afandi/core/database/transaction_runner.dart';
import 'package:daftar_afandi/core/router/route_names.dart';
import 'package:daftar_afandi/core/utils/clock.dart';
import 'package:daftar_afandi/core/utils/id.dart';
import 'package:daftar_afandi/features/settings/data/settings_repository_impl.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    final clock = FixedClock(DateTime.utc(2026, 10, 20, 9));
    db = AppDatabase(NativeDatabase.memory(), const UuidV7Generator(), clock);
    repo = SettingsRepositoryImpl(
      db.settingsDao,
      DriftTransactionRunner(db),
      clock,
    );
  });

  /// Closes the DB inside runAsync so drift's stream timers finish.
  Future<void> closeDb(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(db.close);
  }

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.tap(find.widgetWithText(FilledButton, label));
    await tester.pumpAndSettle();
  }

  testWidgets('the full first run ends on Home and is stored', (tester) async {
    await pumpApp(tester, repo);
    expect(currentPath(tester), RoutePaths.welcome);

    await tapButton(tester, 'متابعة');
    await tester.enterText(
      find.widgetWithText(TextField, 'اسم المحل'),
      ' محل 23 ',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'رقم هاتف المحل'),
      '٠١٠ ١٢٣٤-٥٦٧٨',
    );
    await tapButton(tester, 'متابعة');
    expect(currentPath(tester), RoutePaths.onboardingData);
    await tapButton(tester, 'ابدأ');

    expect(currentPath(tester), RoutePaths.home);
    final row = (await tester.runAsync(db.settingsDao.getSingleton))!;
    expect(row.onboardingCompletedAt, isNotNull);
    expect(row.shopName, 'محل 23');
    expect(row.shopPhone, '01012345678');

    // Relaunch: Home again, no first run.
    await pumpApp(tester, repo);
    expect(currentPath(tester), RoutePaths.home);
    await closeDb(tester);
  });

  testWidgets(
    'an interrupted first run restarts at welcome in the chosen language',
    (tester) async {
      await pumpApp(tester, repo);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      await tapButton(tester, 'Continue');
      await tester.enterText(
        find.widgetWithText(TextField, 'Shop name'),
        'Nile shop',
      );

      // Relaunch before finishing.
      await pumpApp(tester, repo);
      expect(currentPath(tester), RoutePaths.welcome);
      expect(find.text('Welcome to Daftar Afandi'), findsOneWidget);
      final row = (await tester.runAsync(db.settingsDao.getSingleton))!;
      expect(row.shopName, isNull, reason: 'typed values are not kept');
      expect(row.onboardingCompletedAt, isNull);
      await closeDb(tester);
    },
  );

  for (final brightness in Brightness.values) {
    for (final english in [false, true]) {
      final label = '${brightness.name}, ${english ? 'en' : 'ar'}';
      testWidgets(
        'every first-run screen at 200% text has no overflow ($label)',
        (tester) async {
          if (english) {
            await tester.runAsync(() => repo.setLocale(AppLocale.en));
          }
          await pumpApp(
            tester,
            repo,
            size: const Size(375, 812),
            textScale: 2,
            brightness: brightness,
          );
          for (final path in [
            RoutePaths.welcome,
            RoutePaths.onboardingShop,
            RoutePaths.onboardingData,
          ]) {
            await goTo(tester, path);
            expect(currentPath(tester), path);
            expect(tester.takeException(), isNull, reason: path);
          }
          // Errors shown at 200% must wrap, not overflow.
          await goTo(tester, RoutePaths.onboardingShop);
          await tapButton(tester, english ? 'Continue' : 'متابعة');
          expect(tester.takeException(), isNull);
          await closeDb(tester);
        },
      );
    }
  }
}
