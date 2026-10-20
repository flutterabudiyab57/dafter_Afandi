import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../domain/settings_repository.dart';
import '../../domain/shop_profile.dart';
import 'shop_profile_form_state.dart';

export 'shop_profile_form_state.dart';

/// The shop name and phone form, for the first-run step and the settings
/// editor. A failed save keeps what was typed.
class ShopProfileFormCubit extends Cubit<ShopProfileFormState> {
  ShopProfileFormCubit(
    this._repository, {
    required this.mode,
    ShopProfile? initial,
  }) : super(
         ShopProfileFormState(
           nameInput: initial?.name ?? '',
           phoneInput: initial?.phone ?? '',
         ),
       );

  final SettingsRepository _repository;
  final ShopProfileFormMode mode;

  void nameChanged(String value) => emit(
    state.copyWith(
      nameInput: value,
      nameError: () => null,
      status: ShopProfileFormStatus.idle,
    ),
  );

  void phoneChanged(String value) => emit(
    state.copyWith(
      phoneInput: value,
      phoneError: () => null,
      status: ShopProfileFormStatus.idle,
    ),
  );

  /// Shows the errors for the current inputs. Writes nothing.
  bool validate() {
    final nameError = ShopProfile.validateName(state.nameInput);
    final phoneError = ShopProfile.validatePhone(state.phoneInput);
    emit(
      state.copyWith(nameError: () => nameError, phoneError: () => phoneError),
    );
    return nameError == null && phoneError == null;
  }

  Future<void> submit() async {
    if (state.status == ShopProfileFormStatus.saving || !validate()) return;
    final profile = switch (ShopProfile.create(
      state.nameInput,
      state.phoneInput,
    )) {
      Ok(:final value) => value,
      // validate() passed, so create() cannot fail.
      Err(:final error) => throw StateError('invalid profile: $error'),
    };

    emit(state.copyWith(status: ShopProfileFormStatus.saving));
    try {
      switch (mode) {
        case ShopProfileFormMode.onboarding:
          await _repository.completeOnboarding(profile);
        case ShopProfileFormMode.settings:
          await _repository.saveShopProfile(profile);
      }
      emit(state.copyWith(status: ShopProfileFormStatus.saved));
    } on SettingsWriteFailure {
      emit(state.copyWith(status: ShopProfileFormStatus.failed));
    }
  }
}
