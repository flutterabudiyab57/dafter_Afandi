import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name shown in the app and on the welcome screen.
  ///
  /// In ar, this message translates to:
  /// **'دفتر أفندي'**
  String get appName;

  /// Welcome screen title.
  ///
  /// In ar, this message translates to:
  /// **'أهلًا بك في دفتر أفندي'**
  String get welcomeTitle;

  /// Short introduction on the welcome screen.
  ///
  /// In ar, this message translates to:
  /// **'دفترك لحسابات المحل: المبيعات والمشتريات والعملاء والموردين، كلها على هاتفك وتعمل بدون إنترنت.'**
  String get welcomeBody;

  /// The Arabic language option. Always written in Arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// The English language option. Always written in English.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Button that moves to the next first-run step.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueAction;

  /// Title of the shop details step and the shop edit screen.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المحل'**
  String get shopDetailsTitle;

  /// Label of the required shop name field.
  ///
  /// In ar, this message translates to:
  /// **'اسم المحل'**
  String get shopNameLabel;

  /// Label of the optional shop phone field.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف المحل'**
  String get shopPhoneLabel;

  /// Helper text under the shop phone field.
  ///
  /// In ar, this message translates to:
  /// **'اختياري. يظهر على الفواتير التي تشاركها.'**
  String get shopPhoneOptionalHint;

  /// Error when the shop name is empty or only spaces.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المحل.'**
  String get errorShopNameRequired;

  /// Error when the shop name is too long. {max} is the limit, already in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'اسم المحل لا يزيد على {max} حرفًا.'**
  String errorShopNameTooLong(String max);

  /// Error when the phone has characters other than digits and a leading +.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف يقبل الأرقام فقط، مع علامة + في أوله إن لزم.'**
  String get errorPhoneInvalid;

  /// Error when the phone has too few digits. {min} is already in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف لا يقل عن {min} أرقام.'**
  String errorPhoneTooShort(String min);

  /// Error when the phone has too many digits. {max} is already in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف لا يزيد على {max} رقمًا.'**
  String errorPhoneTooLong(String max);

  /// Shown when writing settings fails. The typed values are kept.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحفظ. بياناتك المكتوبة ما زالت هنا، حاول مرة أخرى.'**
  String get errorSaveFailed;

  /// Title of the data and backup explanation screen.
  ///
  /// In ar, this message translates to:
  /// **'عن بياناتك'**
  String get dataSafetyTitle;

  /// Explains that data lives only on the device.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك محفوظة على هذا الهاتف فقط، ولا تُرسل إلى أي خادم.'**
  String get dataSafetyLocalOnly;

  /// Android-only backup explanation.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان النسخ الاحتياطي مفعّلًا في إعدادات الهاتف، يحفظ أندرويد نسخة من بياناتك في حساب Google الخاص بك تلقائيًا، فتعود إذا أعدت تثبيت التطبيق بنفس الحساب.'**
  String get dataSafetyAndroidBackup;

  /// iOS-only backup explanation.
  ///
  /// In ar, this message translates to:
  /// **'على آيفون لا يتم النسخ الاحتياطي تلقائيًا. ستتمكن من تصدير نسخة احتياطية بنفسك في تحديث قادم، فاحرص على ذلك بانتظام.'**
  String get dataSafetyIosManual;

  /// Button that finishes the first run.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get finishAction;

  /// Bottom navigation: Home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// Bottom navigation: Sales.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get navSales;

  /// Bottom navigation: Customers and suppliers.
  ///
  /// In ar, this message translates to:
  /// **'العملاء والموردين'**
  String get navParties;

  /// Bottom navigation: Purchases.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get navPurchases;

  /// Bottom navigation: Reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get navReports;

  /// Home placeholder title.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get placeholderHomeTitle;

  /// Home placeholder body.
  ///
  /// In ar, this message translates to:
  /// **'هنا سترى ملخص يومك: المبيعات والمصروفات والنقدية، والتنبيهات المهمة.'**
  String get placeholderHomeBody;

  /// Sales placeholder title.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات'**
  String get placeholderSalesTitle;

  /// Sales placeholder body.
  ///
  /// In ar, this message translates to:
  /// **'هنا ستسجّل فواتير البيع والمرتجعات وتشاركها مع عملائك.'**
  String get placeholderSalesBody;

  /// Customers and suppliers placeholder title.
  ///
  /// In ar, this message translates to:
  /// **'العملاء والموردين'**
  String get placeholderPartiesTitle;

  /// Customers and suppliers placeholder body.
  ///
  /// In ar, this message translates to:
  /// **'هنا ستتابع عملاءك ومورديك، وما لك وما عليك مع كل واحد منهم.'**
  String get placeholderPartiesBody;

  /// Purchases placeholder title.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get placeholderPurchasesTitle;

  /// Purchases placeholder body.
  ///
  /// In ar, this message translates to:
  /// **'هنا ستسجّل فواتير الشراء من الموردين، فيتحدّث المخزون والتكلفة تلقائيًا.'**
  String get placeholderPurchasesBody;

  /// Reports placeholder title.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get placeholderReportsTitle;

  /// Reports placeholder body.
  ///
  /// In ar, this message translates to:
  /// **'هنا ستجد تقارير المبيعات والأرباح والمخزون والمصروفات.'**
  String get placeholderReportsBody;

  /// Settings screen title.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// Settings row that opens the shop details editor.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المحل'**
  String get settingsShopDetails;

  /// Settings row for the app language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// Settings row for the digit style.
  ///
  /// In ar, this message translates to:
  /// **'شكل الأرقام'**
  String get settingsDigitStyle;

  /// Digit style option: follow the language.
  ///
  /// In ar, this message translates to:
  /// **'حسب اللغة'**
  String get digitStyleFollowLanguage;

  /// Digit style option: Arabic-Indic digits. The sample digits stay as written.
  ///
  /// In ar, this message translates to:
  /// **'أرقام عربية (٠١٢٣)'**
  String get digitStyleArabic;

  /// Digit style option: Latin digits. The sample digits stay as written.
  ///
  /// In ar, this message translates to:
  /// **'أرقام لاتينية (0123)'**
  String get digitStyleLatin;

  /// Settings row that opens the data and backup explanation.
  ///
  /// In ar, this message translates to:
  /// **'عن بياناتك'**
  String get settingsAboutData;

  /// Settings row showing the app version.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get settingsAppVersion;

  /// Save button.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveAction;

  /// Spoken label of the settings button in the app bar.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get openSettingsSemantics;

  /// Spoken label of the app logo.
  ///
  /// In ar, this message translates to:
  /// **'شعار دفتر أفندي'**
  String get logoSemantics;

  /// Title of the blocking screen shown when the stored data cannot be opened by this app version.
  ///
  /// In ar, this message translates to:
  /// **'يلزم تحديث التطبيق'**
  String get updateRequiredTitle;

  /// Body of the blocking screen when the data was made by a newer app version (FR-018).
  ///
  /// In ar, this message translates to:
  /// **'بياناتك محفوظة بإصدار أحدث من دفتر أفندي. حدّث التطبيق من المتجر لتفتحها. لم يتم تغيير أي شيء في بياناتك.'**
  String get updateRequiredBody;

  /// Body of the blocking screen when the data file is not a file this app made.
  ///
  /// In ar, this message translates to:
  /// **'ملف البيانات الموجود على هذا الهاتف غير معروف لهذا الإصدار من دفتر أفندي. حدّث التطبيق من المتجر. لم يتم تغيير أي شيء في الملف.'**
  String get dataUnrecognizedBody;

  /// Body of the screen shown when opening or upgrading the database fails.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح بياناتك. لم يتم تغيير أي شيء فيها. أغلق التطبيق وافتحه مرة أخرى، وإذا تكررت المشكلة حدّث التطبيق من المتجر.'**
  String get startupErrorBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
