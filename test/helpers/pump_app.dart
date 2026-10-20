import 'dart:async';

import 'package:daftar_afandi/app.dart';
import 'package:daftar_afandi/features/customers/presentation/customers_cubits.dart';
import 'package:daftar_afandi/features/products/presentation/products_cubits.dart';
import 'package:daftar_afandi/features/sales/presentation/sales_cubits.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/settings/domain/app_settings.dart';
import 'package:daftar_afandi/features/settings/domain/app_version.dart';
import 'package:daftar_afandi/features/settings/domain/settings_repository.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:daftar_afandi/features/settings/presentation/cubits/app_preferences_cubit.dart';
import 'package:daftar_afandi/features/settings/presentation/cubits/shop_profile_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'fake_products.dart';
import 'fake_sales.dart';

const AppVersion kTestVersion = AppVersion(name: '1.0.0', build: '1');

const AppSettings kFreshSettings = AppSettings(
  locale: AppLocale.ar,
  digitStyle: DigitStylePreference.followLanguage,
  onboardingCompleted: false,
);

const AppSettings kOnboardedSettings = AppSettings(
  locale: AppLocale.ar,
  digitStyle: DigitStylePreference.followLanguage,
  onboardingCompleted: true,
  shop: ShopProfile(name: 'محل 23', phone: '01012345678'),
);

/// An in-memory [SettingsRepository] that behaves like the real one and
/// records every write.
final class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([AppSettings initial = kFreshSettings])
    : _value = initial;

  AppSettings _value;
  final StreamController<AppSettings> _changes = StreamController.broadcast();

  /// Every write, e.g. `('setLocale', AppLocale.en)`.
  final List<(String, Object)> writes = [];

  /// When set, every write throws [SettingsWriteFailure] and changes nothing.
  Object? failWith;

  AppSettings get value => _value;

  void _set(String name, Object arg, AppSettings next) {
    if (failWith case final cause?) throw SettingsWriteFailure(cause);
    writes.add((name, arg));
    _value = next;
    _changes.add(next);
  }

  AppSettings _copy({
    AppLocale? locale,
    DigitStylePreference? digitStyle,
    ShopProfile? shop,
    bool? onboardingCompleted,
  }) => AppSettings(
    locale: locale ?? _value.locale,
    digitStyle: digitStyle ?? _value.digitStyle,
    shop: shop ?? _value.shop,
    onboardingCompleted: onboardingCompleted ?? _value.onboardingCompleted,
  );

  @override
  Future<AppSettings> load() async => _value;

  @override
  Stream<AppSettings> watch() async* {
    yield _value;
    yield* _changes.stream;
  }

  @override
  Future<void> setLocale(AppLocale locale) async =>
      _set('setLocale', locale, _copy(locale: locale));

  @override
  Future<void> setDigitStyle(DigitStylePreference style) async =>
      _set('setDigitStyle', style, _copy(digitStyle: style));

  @override
  Future<void> saveShopProfile(ShopProfile profile) async {
    if (!_value.onboardingCompleted) throw StateError('not onboarded');
    _set('saveShopProfile', profile, _copy(shop: profile));
  }

  @override
  Future<void> completeOnboarding(ShopProfile profile) async => _set(
    'completeOnboarding',
    profile,
    _copy(shop: profile, onboardingCompleted: true),
  );
}

/// Pumps [App] on [repository] at a phone size, then settles.
Future<void> pumpApp(
  WidgetTester tester,
  SettingsRepository repository, {
  Size size = const Size(420, 812),
  double textScale = 1,
  Brightness brightness = Brightness.light,
  ProductsCubits? products,
  CustomersCubits? customers,
  SalesCubits? sales,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  tester.platformDispatcher
    ..textScaleFactorTestValue = textScale
    ..platformBrightnessTestValue = brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final prefs = AppPreferencesCubit(repository, await repository.load());
  // Not awaited: closing the broadcast state stream waits for listeners
  // that the fake-async test zone never runs to completion.
  addTearDown(() => unawaited(prefs.close()));
  // Unmount any earlier App, as a restart would.
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    App(
      preferences: prefs,
      appVersion: kTestVersion,
      shopProfileForm: (mode, initial) =>
          ShopProfileFormCubit(repository, mode: mode, initial: initial),
      products: products ?? FakeProductsCubits(),
      customers: customers ?? FakeCustomersCubits(),
      sales: sales ?? FakeSalesCubits(),
    ),
  );
  await tester.pumpAndSettle();
}

/// The app's router, found from any widget below it.
GoRouter routerOf(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first));

/// The current path, e.g. `/welcome`.
String currentPath(WidgetTester tester) => routerOf(tester).state.uri.path;

/// Navigates with `go` and settles.
Future<void> goTo(WidgetTester tester, String path) async {
  routerOf(tester).go(path);
  await tester.pumpAndSettle();
}

/// Taps the app bar's back button. `tester.pageBack()` looks for
/// flutter/material's type, not material_ui's.
Future<void> tapBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}
