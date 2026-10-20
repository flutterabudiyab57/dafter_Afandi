import 'package:equatable/equatable.dart';

import '../../domain/shop_profile.dart';

enum ShopProfileFormMode { onboarding, settings }

enum ShopProfileFormStatus { idle, saving, saved, failed }

final class ShopProfileFormState extends Equatable {
  const ShopProfileFormState({
    this.nameInput = '',
    this.phoneInput = '',
    this.nameError,
    this.phoneError,
    this.status = ShopProfileFormStatus.idle,
  });

  final String nameInput;
  final String phoneInput;
  final ShopProfileError? nameError;
  final ShopProfileError? phoneError;
  final ShopProfileFormStatus status;

  bool get hasErrors => nameError != null || phoneError != null;

  ShopProfileFormState copyWith({
    String? nameInput,
    String? phoneInput,
    ShopProfileError? Function()? nameError,
    ShopProfileError? Function()? phoneError,
    ShopProfileFormStatus? status,
  }) => ShopProfileFormState(
    nameInput: nameInput ?? this.nameInput,
    phoneInput: phoneInput ?? this.phoneInput,
    nameError: nameError == null ? this.nameError : nameError(),
    phoneError: phoneError == null ? this.phoneError : phoneError(),
    status: status ?? this.status,
  );

  @override
  List<Object?> get props => [
    nameInput,
    phoneInput,
    nameError,
    phoneError,
    status,
  ];
}
