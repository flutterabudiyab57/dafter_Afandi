// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Daftar Afandi';

  @override
  String get updateRequiredTitle => 'Please update the app';

  @override
  String get updateRequiredBody =>
      'Your data was saved by a newer version of Daftar Afandi. Update the app from the store to open it. Nothing in your data was changed.';

  @override
  String get dataUnrecognizedBody =>
      'The data file on this phone isn\'t recognized by this version of Daftar Afandi. Update the app from the store. Nothing in the file was changed.';

  @override
  String get startupErrorBody =>
      'Your data couldn\'t be opened. Nothing in it was changed. Close the app and open it again; if the problem continues, update the app from the store.';
}
