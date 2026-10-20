import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/app_locale.dart';
import '../../domain/app_settings.dart';
import '../../domain/settings_repository.dart';

/// App-wide settings above the router. Writes go through the repository; the
/// state changes only when the stored row does (contracts/settings-and-state.md).
class AppPreferencesCubit extends Cubit<AppSettings> {
  AppPreferencesCubit(this._repository, AppSettings initial) : super(initial) {
    _subscription = _repository.watch().listen(emit, onError: addError);
  }

  final SettingsRepository _repository;
  late final StreamSubscription<AppSettings> _subscription;

  Future<void> changeLocale(AppLocale locale) =>
      _guard(() => _repository.setLocale(locale));

  Future<void> changeDigitStyle(DigitStylePreference style) =>
      _guard(() => _repository.setDigitStyle(style));

  /// A failed write leaves the state as it was and is reported to the
  /// BlocObserver.
  Future<void> _guard(Future<void> Function() write) async {
    try {
      await write();
    } on SettingsWriteFailure catch (e, s) {
      addError(e, s);
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
