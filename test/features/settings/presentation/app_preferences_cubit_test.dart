import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/features/settings/domain/app_locale.dart';
import 'package:daftar_afandi/features/settings/domain/app_settings.dart';
import 'package:daftar_afandi/features/settings/domain/settings_repository.dart';
import 'package:daftar_afandi/features/settings/presentation/cubits/app_preferences_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements SettingsRepository {}

const AppSettings _ar = AppSettings(
  locale: AppLocale.ar,
  digitStyle: DigitStylePreference.followLanguage,
  onboardingCompleted: false,
);
const AppSettings _en = AppSettings(
  locale: AppLocale.en,
  digitStyle: DigitStylePreference.followLanguage,
  onboardingCompleted: false,
);

void main() {
  late _MockRepository repo;
  late StreamController<AppSettings> changes;

  setUpAll(() {
    registerFallbackValue(AppLocale.ar);
    registerFallbackValue(DigitStylePreference.followLanguage);
  });

  setUp(() {
    repo = _MockRepository();
    changes = StreamController<AppSettings>();
    when(() => repo.watch()).thenAnswer((_) => changes.stream);
  });
  tearDown(() => changes.close());

  blocTest<AppPreferencesCubit, AppSettings>(
    'starts from the initial settings and follows the stream',
    build: () => AppPreferencesCubit(repo, _ar),
    act: (_) => changes.add(_en),
    expect: () => [_en],
  );

  blocTest<AppPreferencesCubit, AppSettings>(
    'changeLocale writes through the repository and waits for the stream',
    setUp: () => when(() => repo.setLocale(any())).thenAnswer((_) async {}),
    build: () => AppPreferencesCubit(repo, _ar),
    act: (cubit) => cubit.changeLocale(AppLocale.en),
    expect: () => <AppSettings>[],
    verify: (_) => verify(() => repo.setLocale(AppLocale.en)).called(1),
  );

  blocTest<AppPreferencesCubit, AppSettings>(
    'changeDigitStyle writes through the repository',
    setUp: () => when(() => repo.setDigitStyle(any())).thenAnswer((_) async {}),
    build: () => AppPreferencesCubit(repo, _ar),
    act: (cubit) => cubit.changeDigitStyle(DigitStylePreference.latin),
    verify: (_) =>
        verify(() => repo.setDigitStyle(DigitStylePreference.latin)).called(1),
  );

  blocTest<AppPreferencesCubit, AppSettings>(
    'a failed write keeps the state and reports the error',
    setUp: () =>
        when(() => repo.setLocale(any()))
            .thenThrow(const SettingsWriteFailure('disk full')),
    build: () => AppPreferencesCubit(repo, _ar),
    act: (cubit) => cubit.changeLocale(AppLocale.en),
    expect: () => <AppSettings>[],
    errors: () => [isA<SettingsWriteFailure>()],
  );

  test('close cancels the subscription', () async {
    final cubit = AppPreferencesCubit(repo, _ar);
    expect(changes.hasListener, isTrue);
    await cubit.close();
    expect(changes.hasListener, isFalse);
  });
}
