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
  String get welcomeTitle => 'Welcome to Daftar Afandi';

  @override
  String get welcomeBody =>
      'Your shop\'s books: sales, purchases, customers and suppliers, all on your phone and working without the internet.';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get continueAction => 'Continue';

  @override
  String get shopDetailsTitle => 'Shop details';

  @override
  String get shopNameLabel => 'Shop name';

  @override
  String get shopPhoneLabel => 'Shop phone';

  @override
  String get shopPhoneOptionalHint => 'Optional. Shown on invoices you share.';

  @override
  String get errorShopNameRequired => 'Enter the shop name.';

  @override
  String errorShopNameTooLong(String max) {
    return 'The shop name can be at most $max characters.';
  }

  @override
  String get errorPhoneInvalid =>
      'The phone number can only contain digits, with an optional + at the start.';

  @override
  String errorPhoneTooShort(String min) {
    return 'The phone number needs at least $min digits.';
  }

  @override
  String errorPhoneTooLong(String max) {
    return 'The phone number can have at most $max digits.';
  }

  @override
  String get errorSaveFailed =>
      'Couldn\'t save. What you typed is still here; try again.';

  @override
  String get dataSafetyTitle => 'About your data';

  @override
  String get dataSafetyLocalOnly =>
      'Your data is stored only on this phone and is never sent to any server.';

  @override
  String get dataSafetyAndroidBackup =>
      'If backup is turned on in your phone settings, Android automatically saves a copy of your data to your Google account, so it comes back if you reinstall the app with the same account.';

  @override
  String get dataSafetyIosManual =>
      'On iPhone there is no automatic backup. You\'ll be able to export a backup yourself in an upcoming update; do it regularly.';

  @override
  String get finishAction => 'Get started';

  @override
  String get navHome => 'Home';

  @override
  String get navSales => 'Sales';

  @override
  String get navParties => 'Customers & Suppliers';

  @override
  String get navPurchases => 'Purchases';

  @override
  String get navReports => 'Reports';

  @override
  String get placeholderHomeTitle => 'Home';

  @override
  String get placeholderHomeBody =>
      'Here you\'ll see a summary of your day: sales, expenses, cash, and important alerts.';

  @override
  String get placeholderSalesTitle => 'Sales';

  @override
  String get placeholderSalesBody =>
      'Here you\'ll record sales invoices and returns and share them with your customers.';

  @override
  String get placeholderPartiesTitle => 'Customers & Suppliers';

  @override
  String get placeholderPartiesBody =>
      'Here you\'ll follow your customers and suppliers, and what each one owes you or you owe them.';

  @override
  String get placeholderPurchasesTitle => 'Purchases';

  @override
  String get placeholderPurchasesBody =>
      'Here you\'ll record purchase invoices from suppliers, and stock and cost update automatically.';

  @override
  String get placeholderReportsTitle => 'Reports';

  @override
  String get placeholderReportsBody =>
      'Here you\'ll find reports on sales, profit, stock and expenses.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsShopDetails => 'Shop details';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDigitStyle => 'Digit style';

  @override
  String get digitStyleFollowLanguage => 'Follow the language';

  @override
  String get digitStyleArabic => 'Arabic-Indic (٠١٢٣)';

  @override
  String get digitStyleLatin => 'Latin (0123)';

  @override
  String get settingsAboutData => 'About your data';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get saveAction => 'Save';

  @override
  String get openSettingsSemantics => 'Open settings';

  @override
  String get logoSemantics => 'Daftar Afandi logo';

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
