// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'دفتر أفندي';

  @override
  String get welcomeTitle => 'أهلًا بك في دفتر أفندي';

  @override
  String get welcomeBody =>
      'دفترك لحسابات المحل: المبيعات والمشتريات والعملاء والموردين، كلها على هاتفك وتعمل بدون إنترنت.';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get continueAction => 'متابعة';

  @override
  String get shopDetailsTitle => 'بيانات المحل';

  @override
  String get shopNameLabel => 'اسم المحل';

  @override
  String get shopPhoneLabel => 'رقم هاتف المحل';

  @override
  String get shopPhoneOptionalHint =>
      'اختياري. يظهر على الفواتير التي تشاركها.';

  @override
  String get errorShopNameRequired => 'اكتب اسم المحل.';

  @override
  String errorShopNameTooLong(String max) {
    return 'اسم المحل لا يزيد على $max حرفًا.';
  }

  @override
  String get errorPhoneInvalid =>
      'رقم الهاتف يقبل الأرقام فقط، مع علامة + في أوله إن لزم.';

  @override
  String errorPhoneTooShort(String min) {
    return 'رقم الهاتف لا يقل عن $min أرقام.';
  }

  @override
  String errorPhoneTooLong(String max) {
    return 'رقم الهاتف لا يزيد على $max رقمًا.';
  }

  @override
  String get errorSaveFailed =>
      'تعذّر الحفظ. بياناتك المكتوبة ما زالت هنا، حاول مرة أخرى.';

  @override
  String get dataSafetyTitle => 'عن بياناتك';

  @override
  String get dataSafetyLocalOnly =>
      'بياناتك محفوظة على هذا الهاتف فقط، ولا تُرسل إلى أي خادم.';

  @override
  String get dataSafetyAndroidBackup =>
      'إذا كان النسخ الاحتياطي مفعّلًا في إعدادات الهاتف، يحفظ أندرويد نسخة من بياناتك في حساب Google الخاص بك تلقائيًا، فتعود إذا أعدت تثبيت التطبيق بنفس الحساب.';

  @override
  String get dataSafetyIosManual =>
      'على آيفون لا يتم النسخ الاحتياطي تلقائيًا. ستتمكن من تصدير نسخة احتياطية بنفسك في تحديث قادم، فاحرص على ذلك بانتظام.';

  @override
  String get finishAction => 'ابدأ';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSales => 'المبيعات';

  @override
  String get navParties => 'العملاء والموردين';

  @override
  String get navPurchases => 'المشتريات';

  @override
  String get navReports => 'التقارير';

  @override
  String get placeholderHomeTitle => 'الرئيسية';

  @override
  String get placeholderHomeBody =>
      'هنا سترى ملخص يومك: المبيعات والمصروفات والنقدية، والتنبيهات المهمة.';

  @override
  String get placeholderSalesTitle => 'المبيعات';

  @override
  String get placeholderSalesBody =>
      'هنا ستسجّل فواتير البيع والمرتجعات وتشاركها مع عملائك.';

  @override
  String get placeholderPartiesTitle => 'العملاء والموردين';

  @override
  String get placeholderPartiesBody =>
      'هنا ستتابع عملاءك ومورديك، وما لك وما عليك مع كل واحد منهم.';

  @override
  String get placeholderPurchasesTitle => 'المشتريات';

  @override
  String get placeholderPurchasesBody =>
      'هنا ستسجّل فواتير الشراء من الموردين، فيتحدّث المخزون والتكلفة تلقائيًا.';

  @override
  String get placeholderReportsTitle => 'التقارير';

  @override
  String get placeholderReportsBody =>
      'هنا ستجد تقارير المبيعات والأرباح والمخزون والمصروفات.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsShopDetails => 'بيانات المحل';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsDigitStyle => 'شكل الأرقام';

  @override
  String get digitStyleFollowLanguage => 'حسب اللغة';

  @override
  String get digitStyleArabic => 'أرقام عربية (٠١٢٣)';

  @override
  String get digitStyleLatin => 'أرقام لاتينية (0123)';

  @override
  String get settingsAboutData => 'عن بياناتك';

  @override
  String get settingsAppVersion => 'إصدار التطبيق';

  @override
  String get saveAction => 'حفظ';

  @override
  String get openSettingsSemantics => 'فتح الإعدادات';

  @override
  String get logoSemantics => 'شعار دفتر أفندي';

  @override
  String get updateRequiredTitle => 'يلزم تحديث التطبيق';

  @override
  String get updateRequiredBody =>
      'بياناتك محفوظة بإصدار أحدث من دفتر أفندي. حدّث التطبيق من المتجر لتفتحها. لم يتم تغيير أي شيء في بياناتك.';

  @override
  String get dataUnrecognizedBody =>
      'ملف البيانات الموجود على هذا الهاتف غير معروف لهذا الإصدار من دفتر أفندي. حدّث التطبيق من المتجر. لم يتم تغيير أي شيء في الملف.';

  @override
  String get startupErrorBody =>
      'تعذّر فتح بياناتك. لم يتم تغيير أي شيء فيها. أغلق التطبيق وافتحه مرة أخرى، وإذا تكررت المشكلة حدّث التطبيق من المتجر.';
}
