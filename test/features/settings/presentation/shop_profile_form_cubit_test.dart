import 'package:bloc_test/bloc_test.dart';
import 'package:daftar_afandi/features/settings/domain/settings_repository.dart';
import 'package:daftar_afandi/features/settings/domain/shop_profile.dart';
import 'package:daftar_afandi/features/settings/presentation/cubits/shop_profile_form_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements SettingsRepository {}

const _idle = ShopProfileFormStatus.idle;

void main() {
  late _MockRepository repo;

  setUpAll(() => registerFallbackValue(const ShopProfile(name: 'x')));
  setUp(() => repo = _MockRepository());

  ShopProfileFormCubit onboarding() =>
      ShopProfileFormCubit(repo, mode: ShopProfileFormMode.onboarding);

  test('the settings mode is pre-filled from the stored profile', () {
    final cubit = ShopProfileFormCubit(
      repo,
      mode: ShopProfileFormMode.settings,
      initial: const ShopProfile(name: 'محل 23', phone: '01012345678'),
    );
    expect(cubit.state.nameInput, 'محل 23');
    expect(cubit.state.phoneInput, '01012345678');
  });

  blocTest<ShopProfileFormCubit, ShopProfileFormState>(
    'validate shows both errors and writes nothing',
    build: onboarding,
    act: (c) => c
      ..nameChanged('  ')
      ..phoneChanged('12')
      ..validate(),
    expect: () => const [
      ShopProfileFormState(nameInput: '  '),
      ShopProfileFormState(nameInput: '  ', phoneInput: '12'),
      ShopProfileFormState(
        nameInput: '  ',
        phoneInput: '12',
        nameError: ShopProfileError.nameRequired,
        phoneError: ShopProfileError.phoneTooShort,
      ),
    ],
    verify: (_) => verifyZeroInteractions(repo),
  );

  blocTest<ShopProfileFormCubit, ShopProfileFormState>(
    'editing a field clears its error only',
    build: onboarding,
    seed: () => const ShopProfileFormState(
      nameError: ShopProfileError.nameRequired,
      phoneError: ShopProfileError.phoneTooLong,
    ),
    act: (c) => c.nameChanged('Shop'),
    expect: () => const [
      ShopProfileFormState(
        nameInput: 'Shop',
        phoneError: ShopProfileError.phoneTooLong,
      ),
    ],
  );

  blocTest<ShopProfileFormCubit, ShopProfileFormState>(
    'submit with an invalid name does not save',
    build: onboarding,
    act: (c) => c.submit(),
    expect: () => const [
      ShopProfileFormState(nameError: ShopProfileError.nameRequired),
    ],
    verify: (_) => verifyZeroInteractions(repo),
  );

  blocTest<ShopProfileFormCubit, ShopProfileFormState>(
    'onboarding submit calls completeOnboarding with the normalized profile',
    setUp: () =>
        when(() => repo.completeOnboarding(any())).thenAnswer((_) async {}),
    build: onboarding,
    seed: () => const ShopProfileFormState(
      nameInput: ' محل 23 ',
      phoneInput: '٠١٠ ١٢٣٤-٥٦٧٨',
    ),
    act: (c) => c.submit(),
    expect: () => const [
      ShopProfileFormState(
        nameInput: ' محل 23 ',
        phoneInput: '٠١٠ ١٢٣٤-٥٦٧٨',
        status: ShopProfileFormStatus.saving,
      ),
      ShopProfileFormState(
        nameInput: ' محل 23 ',
        phoneInput: '٠١٠ ١٢٣٤-٥٦٧٨',
        status: ShopProfileFormStatus.saved,
      ),
    ],
    verify: (_) {
      verify(
        () => repo.completeOnboarding(
          const ShopProfile(name: 'محل 23', phone: '01012345678'),
        ),
      ).called(1);
      verifyNever(() => repo.saveShopProfile(any()));
    },
  );

  blocTest<ShopProfileFormCubit, ShopProfileFormState>(
    'settings submit calls saveShopProfile',
    setUp: () =>
        when(() => repo.saveShopProfile(any())).thenAnswer((_) async {}),
    build: () => ShopProfileFormCubit(
      repo,
      mode: ShopProfileFormMode.settings,
      initial: const ShopProfile(name: 'Old'),
    ),
    act: (c) => c
      ..nameChanged('New')
      ..submit(),
    skip: 1,
    expect: () => const [
      ShopProfileFormState(
        nameInput: 'New',
        status: ShopProfileFormStatus.saving,
      ),
      ShopProfileFormState(
        nameInput: 'New',
        status: ShopProfileFormStatus.saved,
      ),
    ],
    verify: (_) {
      verify(() => repo.saveShopProfile(const ShopProfile(name: 'New')))
          .called(1);
      verifyNever(() => repo.completeOnboarding(any()));
    },
  );

  blocTest<ShopProfileFormCubit, ShopProfileFormState>(
    'a failed save keeps the inputs and reports failed',
    setUp: () =>
        when(() => repo.completeOnboarding(any()))
            .thenThrow(const SettingsWriteFailure('disk full')),
    build: onboarding,
    seed: () =>
        const ShopProfileFormState(nameInput: 'Shop', phoneInput: '0101234567'),
    act: (c) => c.submit(),
    expect: () => const [
      ShopProfileFormState(
        nameInput: 'Shop',
        phoneInput: '0101234567',
        status: ShopProfileFormStatus.saving,
      ),
      ShopProfileFormState(
        nameInput: 'Shop',
        phoneInput: '0101234567',
        status: ShopProfileFormStatus.failed,
      ),
    ],
  );

  blocTest<ShopProfileFormCubit, ShopProfileFormState>(
    'typing after a failure returns to idle',
    build: onboarding,
    seed: () => const ShopProfileFormState(
      nameInput: 'Shop',
      status: ShopProfileFormStatus.failed,
    ),
    act: (c) => c.nameChanged('Shop 2'),
    expect: () => const [
      ShopProfileFormState(nameInput: 'Shop 2', status: _idle),
    ],
  );
}
