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

  /// Home button that opens the product list.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get homeProductsAction;

  /// Home entry that opens the categories screen.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get homeCategoriesAction;

  /// Title of the Home card listing products low on stock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون قليل'**
  String get lowStockCardTitle;

  /// How many products are low on stock. {count} picks the plural form; {countText} is the same number in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منتج واحد مخزونه قليل} =2{منتجان مخزونهما قليل} few{{countText} منتجات مخزونها قليل} other{{countText} منتج مخزونه قليل}}'**
  String lowStockCount(int count, String countText);

  /// Home card text when no product is low on stock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون كله على ما يرام.'**
  String get lowStockNone;

  /// Home card text when the shop has no products yet.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجاتك لتتابع مخزونها.'**
  String get lowStockNoProducts;

  /// Home card action that opens the list filtered to low stock.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get lowStockSeeAll;

  /// Title of the product list.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get productsTitle;

  /// Hint in the product search field.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو الكود أو الباركود'**
  String get productsSearchHint;

  /// Filter chip: all categories.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get productsFilterAll;

  /// Filter chip: products with no category.
  ///
  /// In ar, this message translates to:
  /// **'بدون قسم'**
  String get productsFilterNoCategory;

  /// Filter chip: only products low on stock.
  ///
  /// In ar, this message translates to:
  /// **'مخزون قليل'**
  String get productsFilterLow;

  /// Title of the archived products screen and its menu item.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المؤرشفة'**
  String get productsArchivedTitle;

  /// Empty state of the product list.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات بعد. أضف أول منتج لتبدأ.'**
  String get productsEmpty;

  /// Button in the empty product list.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get productsEmptyAction;

  /// Empty search result. {query} is what the owner typed.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد منتج باسم «{query}».'**
  String productsNoMatch(String query);

  /// Button that opens the add form with the typed name.
  ///
  /// In ar, this message translates to:
  /// **'إضافة «{name}»'**
  String productsAddNamed(String name);

  /// Spoken label of the low-stock mark on a product row.
  ///
  /// In ar, this message translates to:
  /// **'مخزون قليل'**
  String get markLowStock;

  /// Spoken label of the below-zero mark on a product row.
  ///
  /// In ar, this message translates to:
  /// **'المخزون أقل من صفر'**
  String get markBelowZero;

  /// Badge on an archived product.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get productArchivedBadge;

  /// Unit option: sold by piece.
  ///
  /// In ar, this message translates to:
  /// **'بالقطعة'**
  String get unitPiece;

  /// Unit option: sold by kilogram.
  ///
  /// In ar, this message translates to:
  /// **'بالكيلو'**
  String get unitKg;

  /// Unit option: sold by liter.
  ///
  /// In ar, this message translates to:
  /// **'باللتر'**
  String get unitLiter;

  /// Unit option: sold by meter.
  ///
  /// In ar, this message translates to:
  /// **'بالمتر'**
  String get unitMeter;

  /// Short unit label after a quantity: piece. No plural.
  ///
  /// In ar, this message translates to:
  /// **'قطعة'**
  String get unitPieceShort;

  /// Short unit label after a quantity: kilogram.
  ///
  /// In ar, this message translates to:
  /// **'كجم'**
  String get unitKgShort;

  /// Short unit label after a quantity: liter.
  ///
  /// In ar, this message translates to:
  /// **'لتر'**
  String get unitLiterShort;

  /// Short unit label after a quantity: meter.
  ///
  /// In ar, this message translates to:
  /// **'م'**
  String get unitMeterShort;

  /// Title of the add product screen and its button.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get productAddTitle;

  /// Title of the edit product screen.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المنتج'**
  String get productEditTitle;

  /// Label of the product name field.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productNameLabel;

  /// Label above the unit options.
  ///
  /// In ar, this message translates to:
  /// **'يُباع'**
  String get productUnitLabel;

  /// Label of the sale price field.
  ///
  /// In ar, this message translates to:
  /// **'سعر البيع للوحدة'**
  String get productPriceLabel;

  /// Label of the category picker and the category row in details.
  ///
  /// In ar, this message translates to:
  /// **'القسم'**
  String get productCategoryLabel;

  /// Category option: none.
  ///
  /// In ar, this message translates to:
  /// **'بدون قسم'**
  String get productNoCategory;

  /// Label of the barcode field.
  ///
  /// In ar, this message translates to:
  /// **'الباركود'**
  String get productBarcodeLabel;

  /// Label of the product code (SKU) field.
  ///
  /// In ar, this message translates to:
  /// **'الكود'**
  String get productSkuLabel;

  /// Label of the low-stock level field.
  ///
  /// In ar, this message translates to:
  /// **'حد المخزون القليل'**
  String get productLowStockLabel;

  /// Helper text under the low-stock level field.
  ///
  /// In ar, this message translates to:
  /// **'تظهر علامة عندما يصل المخزون إلى هذه الكمية أو أقل.'**
  String get productLowStockHint;

  /// Header of the opening stock section.
  ///
  /// In ar, this message translates to:
  /// **'رصيد أول المدة'**
  String get productOpeningSection;

  /// Helper text of the opening stock section.
  ///
  /// In ar, this message translates to:
  /// **'الكمية الموجودة لديك الآن، وتكلفة الوحدة عليك.'**
  String get productOpeningHint;

  /// Label of the opening quantity field.
  ///
  /// In ar, this message translates to:
  /// **'الكمية الموجودة'**
  String get productOpeningQtyLabel;

  /// Label of the opening cost field.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة الوحدة'**
  String get productOpeningCostLabel;

  /// Note under the disabled unit options.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير الوحدة بعد تسجيل حركات مخزون للمنتج.'**
  String get productUnitLockedNote;

  /// Title of the opening stock confirmation.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رصيد أول المدة'**
  String get openingConfirmTitle;

  /// Opening stock confirmation. {qty} includes the unit; all values are already formatted.
  ///
  /// In ar, this message translates to:
  /// **'{qty} × {cost} = {total}\nلا يمكن تعديل رصيد أول المدة بعد الحفظ.'**
  String openingConfirmBody(String qty, String cost, String total);

  /// Confirm button.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirmAction;

  /// Back button in a dialog; nothing is saved.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get backAction;

  /// Cancel button in a dialog.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelAction;

  /// Notice after saving a product whose name another product has.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ. يوجد منتج آخر بنفس الاسم.'**
  String get productNameExistsNotice;

  /// Error when the product name is empty.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم المنتج.'**
  String get errorNameRequired;

  /// Error when a name is too long. {max} is already in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'الاسم لا يزيد على {max} حرفًا.'**
  String errorNameTooLong(String max);

  /// Error when the sale price is empty.
  ///
  /// In ar, this message translates to:
  /// **'اكتب سعر البيع.'**
  String get errorPriceRequired;

  /// Error when an amount is not a number or has too many decimals.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مبلغًا صحيحًا بحد أقصى رقمين بعد العلامة العشرية.'**
  String get errorPriceInvalid;

  /// Error when an amount is too large. {max} is already formatted with the currency.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ لا يزيد على {max}.'**
  String errorPriceTooLarge(String max);

  /// Error when a quantity is empty or zero.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الكمية.'**
  String get errorQuantityRequired;

  /// Error when a quantity is not a number, negative or has too many decimals.
  ///
  /// In ar, this message translates to:
  /// **'اكتب كمية صحيحة بحد أقصى ٣ أرقام بعد العلامة العشرية.'**
  String get errorQuantityInvalid;

  /// Error when a piece quantity has a fraction.
  ///
  /// In ar, this message translates to:
  /// **'القطع تُكتب أعدادًا صحيحة بدون كسور.'**
  String get errorQuantityNotWhole;

  /// Error when a quantity is too large. {max} is already formatted.
  ///
  /// In ar, this message translates to:
  /// **'الكمية لا تزيد على {max}.'**
  String errorQuantityTooLarge(String max);

  /// Error when an opening quantity has no cost.
  ///
  /// In ar, this message translates to:
  /// **'اكتب تكلفة الوحدة، نحتاجها لحساب الربح.'**
  String get errorOpeningCostRequired;

  /// Error when another active product has the barcode.
  ///
  /// In ar, this message translates to:
  /// **'هذا الباركود مستخدم للمنتج «{name}».'**
  String errorBarcodeTaken(String name);

  /// Error when a barcode or code is too long. {max} is already formatted.
  ///
  /// In ar, this message translates to:
  /// **'لا يزيد على {max} حرفًا.'**
  String errorCodeTooLong(String max);

  /// Error when restoring a product whose barcode another active product has.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن الاسترجاع: الباركود مستخدم الآن للمنتج «{name}».'**
  String errorRestoreBarcodeTaken(String name);

  /// Error when a note is too long. {max} is already formatted.
  ///
  /// In ar, this message translates to:
  /// **'الملاحظة لا تزيد على {max} حرفًا.'**
  String errorNoteTooLong(String max);

  /// Title of the product details screen.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنتج'**
  String get productDetailsTitle;

  /// Row label: average cost per unit.
  ///
  /// In ar, this message translates to:
  /// **'متوسط التكلفة'**
  String get productAvgCost;

  /// Row label: stock on hand.
  ///
  /// In ar, this message translates to:
  /// **'المخزون الحالي'**
  String get productStockOnHand;

  /// Action that opens the edit form.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get productEditAction;

  /// Action that opens the stock adjustment.
  ///
  /// In ar, this message translates to:
  /// **'تسوية المخزون'**
  String get productAdjustAction;

  /// Action that opens the opening stock screen.
  ///
  /// In ar, this message translates to:
  /// **'إدخال رصيد أول المدة'**
  String get productSetOpeningAction;

  /// Action that archives the product.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة'**
  String get productArchiveAction;

  /// Archive confirmation text.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المنتج؟ لن يظهر في القائمة والبحث، ويبقى سجله محفوظًا ويمكن استرجاعه.'**
  String get productArchiveConfirm;

  /// Action that restores an archived product.
  ///
  /// In ar, this message translates to:
  /// **'استرجاع'**
  String get productRestoreAction;

  /// Notice after restoring a product.
  ///
  /// In ar, this message translates to:
  /// **'تم استرجاع المنتج.'**
  String get productRestored;

  /// Header of the stock history list.
  ///
  /// In ar, this message translates to:
  /// **'حركة المخزون'**
  String get historyTitle;

  /// Empty stock history.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات مخزون بعد.'**
  String get historyEmpty;

  /// Loads more history rows.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get historyShowMore;

  /// History type: opening stock.
  ///
  /// In ar, this message translates to:
  /// **'رصيد أول المدة'**
  String get stockOpening;

  /// History type: purchase.
  ///
  /// In ar, this message translates to:
  /// **'شراء'**
  String get stockPurchase;

  /// History type: purchase voided.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء شراء'**
  String get stockPurchaseVoid;

  /// History type: sale.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get stockSale;

  /// History type: sale return.
  ///
  /// In ar, this message translates to:
  /// **'مرتجع بيع'**
  String get stockSaleReturn;

  /// History type: sale voided.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء بيع'**
  String get stockSaleVoid;

  /// History type: stock adjustment.
  ///
  /// In ar, this message translates to:
  /// **'تسوية'**
  String get stockAdjustment;

  /// Adjustment reason: damaged.
  ///
  /// In ar, this message translates to:
  /// **'تالف'**
  String get reasonDamage;

  /// Adjustment reason: stock count.
  ///
  /// In ar, this message translates to:
  /// **'جرد'**
  String get reasonCount;

  /// Adjustment reason: other.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get reasonOther;

  /// Title of the stock adjustment screen.
  ///
  /// In ar, this message translates to:
  /// **'تسوية المخزون'**
  String get adjustTitle;

  /// Label above the adjustment reasons.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get adjustReasonLabel;

  /// Current stock on the adjustment screen. {qty} includes the unit.
  ///
  /// In ar, this message translates to:
  /// **'الموجود حاليًا: {qty}'**
  String adjustOnHand(String qty);

  /// Field label for a stock count.
  ///
  /// In ar, this message translates to:
  /// **'الكمية التي تم عدّها'**
  String get adjustCountedLabel;

  /// Field label for damaged stock.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المطلوب خصمها'**
  String get adjustRemoveLabel;

  /// Direction option: add stock.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get adjustAdd;

  /// Direction option: remove stock.
  ///
  /// In ar, this message translates to:
  /// **'خصم'**
  String get adjustRemove;

  /// Field label for the other reason.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get adjustQtyLabel;

  /// Label of the note field.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get adjustNoteLabel;

  /// Error when the other reason has no note.
  ///
  /// In ar, this message translates to:
  /// **'اكتب ملاحظة توضح السبب.'**
  String get adjustNoteRequired;

  /// Error when removing more than is on hand. {qty} includes the unit.
  ///
  /// In ar, this message translates to:
  /// **'الموجود {qty} فقط.'**
  String adjustExceedsStock(String qty);

  /// Info when a count equals the stock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون مطابق بالفعل، لم يتم تسجيل شيء.'**
  String get adjustAlreadyMatches;

  /// Notice after an adjustment. {qty} includes the unit.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ. المخزون الآن {qty}.'**
  String adjustSaved(String qty);

  /// Title of the categories screen.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get categoriesTitle;

  /// Hint of the add category field.
  ///
  /// In ar, this message translates to:
  /// **'اسم قسم جديد'**
  String get categoryAddHint;

  /// Label of the category name field in the rename dialog.
  ///
  /// In ar, this message translates to:
  /// **'اسم القسم'**
  String get categoryNameLabel;

  /// Button that adds the typed category.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get categoryAddAction;

  /// Action that renames a category.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الاسم'**
  String get categoryRename;

  /// Action that moves a category up.
  ///
  /// In ar, this message translates to:
  /// **'تحريك لأعلى'**
  String get categoryMoveUp;

  /// Action that moves a category down.
  ///
  /// In ar, this message translates to:
  /// **'تحريك لأسفل'**
  String get categoryMoveDown;

  /// Action that archives a category.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة القسم'**
  String get categoryArchive;

  /// Category archive confirmation.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة القسم؟ منتجاته تبقى وتظهر «بدون قسم».'**
  String get categoryArchiveConfirm;

  /// Number of products in a category. {count} picks the plural form; {countText} is the same number in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا منتجات} =1{منتج واحد} =2{منتجان} few{{countText} منتجات} other{{countText} منتج}}'**
  String categoryProductCount(int count, String countText);

  /// Empty categories list.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أقسام بعد.'**
  String get categoriesEmpty;

  /// Error when a category name is empty.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم القسم.'**
  String get errorCategoryNameRequired;

  /// Error when an active category has the same name.
  ///
  /// In ar, this message translates to:
  /// **'يوجد قسم بنفس الاسم.'**
  String get errorCategoryDuplicate;

  /// Error when a category name is too long. {max} is already formatted.
  ///
  /// In ar, this message translates to:
  /// **'اسم القسم لا يزيد على {max} حرفًا.'**
  String errorCategoryNameTooLong(String max);

  /// Empty list when filters (no search text) match nothing.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات تطابق هذا الاختيار.'**
  String get productsFilterEmpty;

  /// Shown when a product page is opened for a product that does not exist.
  ///
  /// In ar, this message translates to:
  /// **'هذا المنتج غير موجود.'**
  String get productNotFound;

  /// Empty archived products list.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد منتجات مؤرشفة.'**
  String get productsArchivedEmpty;

  /// Menu of debug-only tools on the archived products screen.
  ///
  /// In ar, this message translates to:
  /// **'أدوات المطور'**
  String get demoSeedMenu;

  /// Debug-only action that adds demo products.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتجات تجريبية'**
  String get demoSeedAction;

  /// After seeding demo products. {count} is the number added, already formatted.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة المنتجات التجريبية: {count}.'**
  String demoSeedDone(String count);

  /// Button that starts a new sale.
  ///
  /// In ar, this message translates to:
  /// **'بيع جديد'**
  String get salesNewAction;

  /// Invoice list with no invoices.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير بعد.'**
  String get salesListEmpty;

  /// Invoice search or filter with no result.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير مطابقة.'**
  String get salesNoMatch;

  /// Hint of the invoice search field.
  ///
  /// In ar, this message translates to:
  /// **'ابحث برقم الفاتورة أو اسم العميل'**
  String get salesSearchHint;

  /// Filter chip: credit or partly paid invoices.
  ///
  /// In ar, this message translates to:
  /// **'غير مدفوعة بالكامل'**
  String get salesFilterUnpaid;

  /// Loads more rows of a list.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get listShowMore;

  /// Shown instead of a customer name on a sale without a customer.
  ///
  /// In ar, this message translates to:
  /// **'عميل نقدي'**
  String get walkInCustomer;

  /// Mark on an invoice nothing of which was paid.
  ///
  /// In ar, this message translates to:
  /// **'آجل'**
  String get saleKindCredit;

  /// Mark on an invoice partly paid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوعة جزئيًا'**
  String get saleKindPartial;

  /// Mark on a voided invoice.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get saleVoidedBadge;

  /// Title of the new sale screen.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة بيع جديدة'**
  String get saleNewTitle;

  /// Opens the product picker on the sale screen.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get saleAddProductAction;

  /// Barcode field on the sale screen; Enter adds the product.
  ///
  /// In ar, this message translates to:
  /// **'امسح أو اكتب الباركود'**
  String get saleBarcodeLabel;

  /// Barcode on the sale screen matched nothing.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد منتج نشط بهذا الباركود.'**
  String get saleBarcodeNotFound;

  /// Sale with no lines yet.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجًا للبدء.'**
  String get saleEmpty;

  /// Quantity field of a sale line.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get saleQtyLabel;

  /// Unit price field of a sale line.
  ///
  /// In ar, this message translates to:
  /// **'سعر الوحدة'**
  String get salePriceLabel;

  /// Discount field of a sale line.
  ///
  /// In ar, this message translates to:
  /// **'خصم السطر'**
  String get saleLineDiscountLabel;

  /// Spoken label of the button that removes a line. {name} is the product.
  ///
  /// In ar, this message translates to:
  /// **'إزالة {name} من الفاتورة'**
  String saleRemoveLine(String name);

  /// Total of one line. {amount} is formatted money.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السطر: {amount}'**
  String saleLineTotal(String amount);

  /// Sum of the line totals.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get saleSubtotal;

  /// Discount on the whole invoice.
  ///
  /// In ar, this message translates to:
  /// **'خصم على الفاتورة'**
  String get saleInvoiceDiscountLabel;

  /// Invoice total after discounts.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get saleTotal;

  /// Amount paid at the time of sale.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع الآن'**
  String get salePaidLabel;

  /// Helper of the paid-now field.
  ///
  /// In ar, this message translates to:
  /// **'اتركه فارغًا لدفع الإجمالي كاملًا'**
  String get salePaidHint;

  /// Amount not paid now.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get saleRemaining;

  /// Label above the payment method choices.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get saleMethodLabel;

  /// Payment method.
  ///
  /// In ar, this message translates to:
  /// **'نقدي'**
  String get methodCash;

  /// Payment method.
  ///
  /// In ar, this message translates to:
  /// **'محفظة إلكترونية'**
  String get methodWallet;

  /// Payment method.
  ///
  /// In ar, this message translates to:
  /// **'إنستاباي'**
  String get methodInstapay;

  /// Payment method (stored, not offered).
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get methodCard;

  /// Label of the customer on a sale or invoice.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get saleCustomerLabel;

  /// Opens the customer picker.
  ///
  /// In ar, this message translates to:
  /// **'اختيار عميل'**
  String get saleCustomerPick;

  /// Removes the customer from the sale.
  ///
  /// In ar, this message translates to:
  /// **'بدون عميل'**
  String get saleCustomerClear;

  /// Saves the sale.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الفاتورة'**
  String get saleSaveAction;

  /// After a sale is saved. {number} is like S-000012.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الفاتورة {number}.'**
  String saleSaved(String number);

  /// Leaving a sale with lines.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل الفاتورة؟'**
  String get saleDiscardTitle;

  /// Body of the leave dialog.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات المضافة لن تُحفظ.'**
  String get saleDiscardBody;

  /// Leaves and drops the sale.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get saleDiscardAction;

  /// Stays on the sale.
  ///
  /// In ar, this message translates to:
  /// **'متابعة البيع'**
  String get saleKeepAction;

  /// Title of the stock shortage warning.
  ///
  /// In ar, this message translates to:
  /// **'المخزون لا يكفي'**
  String get shortageTitle;

  /// Body of the stock shortage warning.
  ///
  /// In ar, this message translates to:
  /// **'سيصبح المخزون أقل من صفر لهذه المنتجات:'**
  String get shortageBody;

  /// One short product. Quantities are formatted with their unit.
  ///
  /// In ar, this message translates to:
  /// **'{name}: المتاح {stock}، المطلوب {need}'**
  String shortageLine(String name, String stock, String need);

  /// Saves despite the shortage.
  ///
  /// In ar, this message translates to:
  /// **'حفظ على أي حال'**
  String get shortageConfirm;

  /// Saving a sale with no lines.
  ///
  /// In ar, this message translates to:
  /// **'أضف منتجًا واحدًا على الأقل.'**
  String get errorSaleNoLines;

  /// Paid now below the total without a customer.
  ///
  /// In ar, this message translates to:
  /// **'البيع الآجل أو الدفع الجزئي يحتاج إلى عميل مسمّى.'**
  String get errorCreditNeedsCustomer;

  /// Paid now above the total.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع أكبر من الإجمالي.'**
  String get errorPaidTooLarge;

  /// Line discount above the line.
  ///
  /// In ar, this message translates to:
  /// **'الخصم أكبر من قيمة السطر.'**
  String get errorLineDiscountTooLarge;

  /// Invoice discount above the subtotal.
  ///
  /// In ar, this message translates to:
  /// **'الخصم أكبر من المجموع.'**
  String get errorInvoiceDiscountTooLarge;

  /// A product on the sale was archived.
  ///
  /// In ar, this message translates to:
  /// **'المنتج «{name}» لم يعد متاحًا؛ أزله من الفاتورة.'**
  String errorProductUnavailable(String name);

  /// The picked customer was archived.
  ///
  /// In ar, this message translates to:
  /// **'العميل لم يعد متاحًا؛ اختر عميلًا آخر.'**
  String get errorCustomerUnavailable;

  /// Title of an invoice. {number} is like S-000012. Never a tax invoice.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة بيع {number}'**
  String invoiceTitle(String number);

  /// Date and time of an invoice.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get invoiceDateLabel;

  /// Quantity times unit price on an invoice line.
  ///
  /// In ar, this message translates to:
  /// **'{qty} × {price}'**
  String invoiceLineDetail(String qty, String price);

  /// Line discount on an invoice line.
  ///
  /// In ar, this message translates to:
  /// **'خصم {amount}'**
  String invoiceLineDiscount(String amount);

  /// Starts voiding an invoice.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الفاتورة'**
  String get invoiceVoidAction;

  /// Title of the void dialog.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الفاتورة؟'**
  String get invoiceVoidTitle;

  /// Body of the void dialog.
  ///
  /// In ar, this message translates to:
  /// **'يرجع المخزون ورصيد العميل كما كانا قبل البيع، ولا يمكن التراجع.'**
  String get invoiceVoidBody;

  /// Reason field of a void or cancel.
  ///
  /// In ar, this message translates to:
  /// **'السبب'**
  String get reasonLabel;

  /// Shown on a voided invoice.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة في {date}: {reason}'**
  String invoiceVoidedOn(String date, String reason);

  /// After voiding.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الفاتورة.'**
  String get invoiceVoided;

  /// Invoice id not found.
  ///
  /// In ar, this message translates to:
  /// **'هذه الفاتورة غير موجودة.'**
  String get invoiceNotFound;

  /// Void refused: the invoice was already voided.
  ///
  /// In ar, this message translates to:
  /// **'هذه الفاتورة ملغاة بالفعل.'**
  String get invoiceAlreadyVoided;

  /// Cancel refused: the payment was already cancelled.
  ///
  /// In ar, this message translates to:
  /// **'هذه الدفعة ملغاة بالفعل.'**
  String get paymentAlreadyCancelled;

  /// Cancel refused: the payment was made with a sale.
  ///
  /// In ar, this message translates to:
  /// **'دفعة الفاتورة لا تُلغى وحدها. ألغِ الفاتورة نفسها.'**
  String get paymentNotCancellable;

  /// An unexpected failure while voiding or cancelling; nothing was saved.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إتمام العملية. لم يتغيّر شيء، حاول مرة أخرى.'**
  String get errorActionFailed;

  /// Void or cancel without a reason.
  ///
  /// In ar, this message translates to:
  /// **'اكتب السبب.'**
  String get errorReasonRequired;

  /// Reason over the limit.
  ///
  /// In ar, this message translates to:
  /// **'يمكن أن يصل السبب إلى {max} حرفًا كحد أقصى.'**
  String errorReasonTooLong(String max);

  /// Title of the customer list.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get customersTitle;

  /// Hint of the customer search.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو رقم الهاتف'**
  String get customersSearchHint;

  /// Filter chip: customers who owe the shop.
  ///
  /// In ar, this message translates to:
  /// **'المدينون'**
  String get customersFilterOwes;

  /// Customer list with no customers.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء بعد.'**
  String get customersEmpty;

  /// Customer search with no result.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء مطابقون.'**
  String get customersNoMatch;

  /// Title and button for adding a customer.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عميل'**
  String get customerAddTitle;

  /// Opens the full customer form from the sale's customer picker.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عميل جديد'**
  String get customerNewAction;

  /// Adds a customer with the searched name.
  ///
  /// In ar, this message translates to:
  /// **'إضافة «{name}»'**
  String customerAddNamed(String name);

  /// Title of the archived customers view.
  ///
  /// In ar, this message translates to:
  /// **'العملاء المؤرشفون'**
  String get customersArchivedTitle;

  /// Archived customers view is empty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء مؤرشفون.'**
  String get customersArchivedEmpty;

  /// Title of the customer edit form.
  ///
  /// In ar, this message translates to:
  /// **'تعديل العميل'**
  String get customerEditTitle;

  /// Name field.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get customerNameLabel;

  /// Phone field.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get customerPhoneLabel;

  /// Address field.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get customerAddressLabel;

  /// Note field.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة'**
  String get customerNoteLabel;

  /// Section of the add form.
  ///
  /// In ar, this message translates to:
  /// **'رصيد سابق'**
  String get customerOpeningSection;

  /// Help for the opening balance.
  ///
  /// In ar, this message translates to:
  /// **'إن كان للعميل حساب قبل استخدام التطبيق. لا يمكن تعديله بعد الحفظ.'**
  String get customerOpeningHint;

  /// Opening balance amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get customerOpeningAmount;

  /// Direction of the opening balance.
  ///
  /// In ar, this message translates to:
  /// **'العميل مدين للمحل'**
  String get customerOpeningOwes;

  /// Direction of the opening balance.
  ///
  /// In ar, this message translates to:
  /// **'المحل مدين للعميل'**
  String get customerOpeningInFavour;

  /// Same-name notice.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ. يوجد عميل آخر بالاسم نفسه.'**
  String get customerNameExistsNotice;

  /// Title of the customer page.
  ///
  /// In ar, this message translates to:
  /// **'بيانات العميل'**
  String get customerDetailsTitle;

  /// Label of the balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get customerBalanceLabel;

  /// Balance the customer owes.
  ///
  /// In ar, this message translates to:
  /// **'عليه {amount}'**
  String balanceOwes(String amount);

  /// Balance the shop owes the customer.
  ///
  /// In ar, this message translates to:
  /// **'له {amount}'**
  String balanceInFavour(String amount);

  /// Zero balance.
  ///
  /// In ar, this message translates to:
  /// **'لا رصيد'**
  String get balanceZero;

  /// Opens the payment screen.
  ///
  /// In ar, this message translates to:
  /// **'استلام دفعة'**
  String get customerReceivePayment;

  /// Archives a customer.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة العميل'**
  String get customerArchiveAction;

  /// Archive confirmation.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة العميل؟ فواتيره وكشف حسابه تبقى ويمكن استعادته.'**
  String get customerArchiveConfirm;

  /// Archive confirmation with a non-zero balance.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة العميل؟ رصيده {balance} يبقى كما هو، وفواتيره وكشف حسابه تبقى ويمكن استعادته.'**
  String customerArchiveConfirmBalance(String balance);

  /// Mark on an archived customer.
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get customerArchivedBadge;

  /// Restores a customer.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get customerRestoreAction;

  /// After restoring.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة العميل.'**
  String get customerRestored;

  /// Customer id not found.
  ///
  /// In ar, this message translates to:
  /// **'هذا العميل غير موجود.'**
  String get customerNotFound;

  /// Section with the customer's account rows.
  ///
  /// In ar, this message translates to:
  /// **'كشف الحساب'**
  String get statementTitle;

  /// Empty statement.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد حركات بعد.'**
  String get statementEmpty;

  /// Statement row type.
  ///
  /// In ar, this message translates to:
  /// **'رصيد سابق'**
  String get ledgerOpening;

  /// Statement row for a sale.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة {number}'**
  String ledgerSale(String number);

  /// Statement row for a payment made with a sale.
  ///
  /// In ar, this message translates to:
  /// **'دفعة'**
  String get ledgerPayment;

  /// Statement row for a payment. {number} is like RC-000001.
  ///
  /// In ar, this message translates to:
  /// **'دفعة {number}'**
  String ledgerPaymentReceipt(String number);

  /// Statement row reversing a sale.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء فاتورة {number}'**
  String ledgerSaleVoid(String number);

  /// Statement row reversing a payment.
  ///
  /// In ar, this message translates to:
  /// **'قيد عكسي'**
  String get ledgerReversal;

  /// Running balance after a row.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد: {amount}'**
  String ledgerBalanceAfter(String amount);

  /// Mark on a cancelled payment.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get ledgerCancelled;

  /// Starts cancelling a payment.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الدفعة'**
  String get paymentCancelAction;

  /// Title of the cancel dialog.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الدفعة؟'**
  String get paymentCancelTitle;

  /// Body of the cancel dialog.
  ///
  /// In ar, this message translates to:
  /// **'يُضاف قيد عكسي بالمبلغ نفسه ويرجع الرصيد كما كان.'**
  String get paymentCancelBody;

  /// After cancelling.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الدفعة.'**
  String get paymentCancelled;

  /// Section with the customer's invoices.
  ///
  /// In ar, this message translates to:
  /// **'الفواتير'**
  String get customerInvoicesTitle;

  /// Title of the payment screen.
  ///
  /// In ar, this message translates to:
  /// **'استلام دفعة'**
  String get paymentTitle;

  /// Shown on the payment screen.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الحالي: {amount}'**
  String paymentBalanceNow(String amount);

  /// Payment amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get paymentAmountLabel;

  /// Title of the credit notice.
  ///
  /// In ar, this message translates to:
  /// **'الدفعة أكبر من الرصيد'**
  String get paymentCreditTitle;

  /// Body of the credit notice.
  ///
  /// In ar, this message translates to:
  /// **'سيصبح للعميل رصيد دائن قدره {amount}.'**
  String paymentCreditBody(String amount);

  /// After saving. {number} is like RC-000001.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الدفعة {number}.'**
  String paymentSaved(String number);

  /// Amount empty or zero.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ.'**
  String get errorAmountRequired;

  /// Name empty.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم العميل.'**
  String get errorCustomerNameRequired;

  /// Payment for an archived customer.
  ///
  /// In ar, this message translates to:
  /// **'العميل مؤرشف؛ استعده أولًا.'**
  String get errorCustomerArchived;

  /// Parties switch: the customers list.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get partiesCustomersTab;

  /// Parties switch: the suppliers list.
  ///
  /// In ar, this message translates to:
  /// **'الموردون'**
  String get partiesSuppliersTab;

  /// Suppliers list title.
  ///
  /// In ar, this message translates to:
  /// **'الموردون'**
  String get suppliersTitle;

  /// Supplier search field.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالاسم أو رقم الهاتف'**
  String get suppliersSearchHint;

  /// Filter: suppliers the shop owes.
  ///
  /// In ar, this message translates to:
  /// **'مستحق لهم'**
  String get suppliersFilterOwed;

  /// Empty supplier list.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد موردون بعد.'**
  String get suppliersEmpty;

  /// Search or filter found nothing.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد موردون مطابقون.'**
  String get suppliersNoMatch;

  /// Add supplier button and form title.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مورد'**
  String get supplierAddTitle;

  /// Opens the full supplier form from the purchase's supplier picker.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مورد جديد'**
  String get supplierNewAction;

  /// Adds a supplier with the searched name.
  ///
  /// In ar, this message translates to:
  /// **'إضافة «{name}»'**
  String supplierAddNamed(String name);

  /// Archived suppliers screen.
  ///
  /// In ar, this message translates to:
  /// **'الموردون المؤرشفون'**
  String get suppliersArchivedTitle;

  /// Empty archived list.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد موردون مؤرشفون.'**
  String get suppliersArchivedEmpty;

  /// Edit form title.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المورد'**
  String get supplierEditTitle;

  /// Name field.
  ///
  /// In ar, this message translates to:
  /// **'اسم المورد'**
  String get supplierNameLabel;

  /// Opening balance help.
  ///
  /// In ar, this message translates to:
  /// **'إذا كان للمورد حساب قبل استخدام التطبيق. لا يمكن تغييره بعد الحفظ.'**
  String get supplierOpeningHint;

  /// Opening direction: positive.
  ///
  /// In ar, this message translates to:
  /// **'المحل مدين للمورد'**
  String get supplierOpeningOwed;

  /// Opening direction: negative.
  ///
  /// In ar, this message translates to:
  /// **'المورد مدين للمحل'**
  String get supplierOpeningInShopFavour;

  /// Same-name notice.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ. يوجد مورد آخر بالاسم نفسه.'**
  String get supplierNameExistsNotice;

  /// Supplier page title.
  ///
  /// In ar, this message translates to:
  /// **'المورد'**
  String get supplierDetailsTitle;

  /// Balance the shop owes the supplier.
  ///
  /// In ar, this message translates to:
  /// **'مستحق له {amount}'**
  String supplierBalanceOwed(String amount);

  /// Balance the supplier owes the shop.
  ///
  /// In ar, this message translates to:
  /// **'عليه للمحل {amount}'**
  String supplierBalanceInShopFavour(String amount);

  /// Opens the payment screen.
  ///
  /// In ar, this message translates to:
  /// **'دفع للمورد'**
  String get supplierPayAction;

  /// Archive button.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المورد'**
  String get supplierArchiveAction;

  /// Archive confirmation, zero balance.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المورد؟ تبقى مشترياته وكشف حسابه ويمكن استعادته.'**
  String get supplierArchiveConfirm;

  /// Archive confirmation with a non-zero balance.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المورد؟ رصيده {balance} يبقى كما هو، ومشترياته وكشف حسابه تبقى ويمكن استعادته.'**
  String supplierArchiveConfirmBalance(String balance);

  /// After restoring.
  ///
  /// In ar, this message translates to:
  /// **'تمت استعادة المورد.'**
  String get supplierRestored;

  /// Unknown supplier id.
  ///
  /// In ar, this message translates to:
  /// **'هذا المورد غير موجود.'**
  String get supplierNotFound;

  /// Supplier page: their purchases.
  ///
  /// In ar, this message translates to:
  /// **'المشتريات'**
  String get supplierPurchasesTitle;

  /// Name empty.
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المورد.'**
  String get errorSupplierNameRequired;

  /// Payment to an archived supplier.
  ///
  /// In ar, this message translates to:
  /// **'المورد مؤرشف؛ استعده أولًا.'**
  String get errorSupplierArchived;

  /// Statement row for a purchase.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء {number}'**
  String ledgerPurchase(String number);

  /// Statement row for a purchase void.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء ملغاة {number}'**
  String ledgerPurchaseVoid(String number);

  /// Cancel refused.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن إلغاء دفعة تمت مع فاتورة شراء وحدها. ألغِ الفاتورة بدلًا من ذلك.'**
  String get supplierPaymentNotCancellable;

  /// Payment screen title.
  ///
  /// In ar, this message translates to:
  /// **'دفع للمورد'**
  String get supplierPaymentTitle;

  /// Overpay confirmation title.
  ///
  /// In ar, this message translates to:
  /// **'أكثر من المستحق'**
  String get supplierOverpayTitle;

  /// Overpay confirmation body.
  ///
  /// In ar, this message translates to:
  /// **'سيصبح المورد مدينًا للمحل بمبلغ {amount}.'**
  String supplierOverpayBody(String amount);

  /// Opens a new purchase.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء جديدة'**
  String get purchasesNewAction;

  /// Empty purchase list.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير شراء بعد.'**
  String get purchasesListEmpty;

  /// Search found nothing.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فواتير شراء مطابقة.'**
  String get purchasesNoMatch;

  /// Purchase search field.
  ///
  /// In ar, this message translates to:
  /// **'ابحث برقم الفاتورة أو المورد أو رقم فاتورة المورد'**
  String get purchasesSearchHint;

  /// A purchase without a supplier.
  ///
  /// In ar, this message translates to:
  /// **'بدون مورد'**
  String get purchaseNoSupplier;

  /// New purchase screen.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء جديدة'**
  String get purchaseNewTitle;

  /// Cost field.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة الوحدة'**
  String get purchaseCostLabel;

  /// Notice under a line; does not block saving.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة تساوي سعر البيع أو تزيد عليه.'**
  String get purchaseCostNotice;

  /// Remove-line button label.
  ///
  /// In ar, this message translates to:
  /// **'إزالة {name} من الفاتورة'**
  String purchaseRemoveLine(String name);

  /// Supplier chip.
  ///
  /// In ar, this message translates to:
  /// **'المورد'**
  String get purchaseSupplierLabel;

  /// Supplier picker title.
  ///
  /// In ar, this message translates to:
  /// **'اختر موردًا'**
  String get purchaseSupplierPick;

  /// Supplier reference field.
  ///
  /// In ar, this message translates to:
  /// **'رقم فاتورة المورد'**
  String get purchaseSupplierRefLabel;

  /// Invoice date field.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الفاتورة'**
  String get purchaseDateLabel;

  /// Save button.
  ///
  /// In ar, this message translates to:
  /// **'حفظ فاتورة الشراء'**
  String get purchaseSaveAction;

  /// After saving. {number} is like P-000001.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ فاتورة الشراء {number}.'**
  String purchaseSaved(String number);

  /// Leave guard title.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل فاتورة الشراء؟'**
  String get purchaseDiscardTitle;

  /// Leave guard: stay.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الفاتورة'**
  String get purchaseKeepAction;

  /// Quick add from the product picker.
  ///
  /// In ar, this message translates to:
  /// **'إضافة «{name}» كمنتج جديد'**
  String purchaseAddProductNamed(String name);

  /// Quick add product form title.
  ///
  /// In ar, this message translates to:
  /// **'منتج جديد'**
  String get purchaseQuickAddTitle;

  /// Paid less than the total without a supplier.
  ///
  /// In ar, this message translates to:
  /// **'الشراء الآجل أو الدفع الجزئي يحتاج إلى مورد.'**
  String get errorCreditNeedsSupplier;

  /// Future date.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن يكون تاريخ الفاتورة بعد اليوم.'**
  String get errorPurchaseDateInFuture;

  /// Archived product on save.
  ///
  /// In ar, this message translates to:
  /// **'«{name}» لم يعد متاحًا؛ أزله من الفاتورة.'**
  String errorPurchaseProductUnavailable(String name);

  /// Archived supplier on save.
  ///
  /// In ar, this message translates to:
  /// **'المورد لم يعد متاحًا؛ اختر غيره.'**
  String get errorSupplierUnavailable;

  /// Purchase screen title.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة شراء {number}'**
  String purchaseTitle(String number);

  /// Void button.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الفاتورة'**
  String get purchaseVoidAction;

  /// Void dialog title.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء فاتورة الشراء؟'**
  String get purchaseVoidTitle;

  /// Void dialog body.
  ///
  /// In ar, this message translates to:
  /// **'يعود المخزون ومتوسط التكلفة ورصيد المورد إلى ما كانت عليه قبل الشراء. لا يمكن التراجع عن ذلك.'**
  String get purchaseVoidBody;

  /// After voiding.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء فاتورة الشراء.'**
  String get purchaseVoided;

  /// Unknown purchase id.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة الشراء هذه غير موجودة.'**
  String get purchaseNotFound;

  /// Void refused.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة الشراء هذه ملغاة بالفعل.'**
  String get purchaseAlreadyVoided;

  /// One product that would go below zero.
  ///
  /// In ar, this message translates to:
  /// **'{name}: {stock} بعد الإلغاء'**
  String voidShortageLine(String name, String stock);

  /// Confirms a void that takes stock below zero.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء على أي حال'**
  String get voidShortageConfirm;

  /// Title of the empty customers list.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء بعد'**
  String get customersEmptyTitle;

  /// Body of the empty customers list.
  ///
  /// In ar, this message translates to:
  /// **'أضف عميلًا لتسجّل البيع الآجل وتتابع ما عليه.'**
  String get customersEmptyBody;

  /// Title of the empty suppliers list.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد موردون بعد'**
  String get suppliersEmptyTitle;

  /// Body of the empty suppliers list.
  ///
  /// In ar, this message translates to:
  /// **'أضف موردًا لتسجّل مشترياتك وما عليك له.'**
  String get suppliersEmptyBody;

  /// Title of the empty purchases list.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشتريات بعد'**
  String get purchasesEmptyTitle;

  /// Body of the empty purchases list.
  ///
  /// In ar, this message translates to:
  /// **'سجّل أول شراء ليزيد المخزون وتُحسب التكلفة.'**
  String get purchasesEmptyBody;

  /// Title when a search or filter matches nothing.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get searchEmptyTitle;

  /// Clears the search text and filters.
  ///
  /// In ar, this message translates to:
  /// **'مسح البحث'**
  String get searchClearAction;

  /// Retries loading a list that failed.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retryAction;

  /// Undoes the last action from a bottom message.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undoAction;

  /// Save button label while saving.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحفظ…'**
  String get savingLabel;

  /// Asked when leaving a form with unsaved changes.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات؟'**
  String get discardChangesTitle;

  /// Body of the discard-changes question.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحفظ التغييرات. إذا خرجت الآن فستضيع.'**
  String get discardChangesBody;

  /// Leaves the form and drops the changes.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get discardAction;

  /// Stays on the form.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التعديل'**
  String get keepEditingAction;

  /// Warning banner title on a credit sale with no customer.
  ///
  /// In ar, this message translates to:
  /// **'اختر عميلًا للبيع الآجل'**
  String get creditNeedsCustomerTitle;

  /// Opens a picker from a banner.
  ///
  /// In ar, this message translates to:
  /// **'اختيار'**
  String get chooseAction;

  /// Shown while the app opens the database.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ فتح بياناتك…'**
  String get openingDataLabel;

  /// Bottom message after archiving a product; offers Undo.
  ///
  /// In ar, this message translates to:
  /// **'أُرشف المنتج.'**
  String get productArchivedMessage;

  /// Bottom message after archiving a customer; offers Undo.
  ///
  /// In ar, this message translates to:
  /// **'أُرشف العميل.'**
  String get customerArchivedMessage;

  /// Bottom message after archiving a supplier; offers Undo.
  ///
  /// In ar, this message translates to:
  /// **'أُرشف المورد.'**
  String get supplierArchivedMessage;

  /// Title when a list could not load.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر عرض البيانات'**
  String get loadFailedTitle;

  /// Body when a list could not load.
  ///
  /// In ar, this message translates to:
  /// **'لم يتغيّر شيء في بياناتك. حاول مرة أخرى.'**
  String get loadFailedBody;

  /// Home heading above today's numbers (006 US1).
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get dashboardTodayTitle;

  /// Home card: today's net sales total.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get dashboardSalesTitle;

  /// How many sales today, under the total. {count} picks the plural form; {countText} is the same number in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد مبيعات بعد} =1{عملية بيع واحدة} =2{عمليتا بيع} few{{countText} عمليات بيع} other{{countText} عملية بيع}}'**
  String dashboardSalesCount(int count, String countText);

  /// Home card: money that came in today, with a line per payment method.
  ///
  /// In ar, this message translates to:
  /// **'المحصَّل اليوم'**
  String get dashboardCollectedTitle;

  /// Home card: how many products are at or below their low-stock level or below zero; opens the filtered list.
  ///
  /// In ar, this message translates to:
  /// **'منتجات قاربت على النفاد'**
  String get dashboardRunningLowTitle;

  /// Home card: the three customers who owe the shop the most.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مديونية'**
  String get dashboardDebtorsTitle;

  /// Home card text when no customer owes the shop.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء عليهم مبالغ للمحل.'**
  String get dashboardDebtorsNone;

  /// Home card action that opens the full list.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get dashboardSeeAll;

  /// Report period chip (006 FR-001).
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get reportPeriodToday;

  /// Report period chip.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get reportPeriodYesterday;

  /// Report period chip; the week starts on Saturday.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get reportPeriodThisWeek;

  /// Report period chip.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get reportPeriodThisMonth;

  /// Report period chip.
  ///
  /// In ar, this message translates to:
  /// **'الشهر الماضي'**
  String get reportPeriodLastMonth;

  /// Report period chip that opens a date range picker.
  ///
  /// In ar, this message translates to:
  /// **'فترة أخرى'**
  String get reportPeriodCustom;

  /// The chosen period's first and last days.
  ///
  /// In ar, this message translates to:
  /// **'من {from} إلى {to}'**
  String reportPeriodRange(String from, String to);

  /// Why a custom range is refused.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النهاية قبل تاريخ البداية.'**
  String get reportPeriodEndBeforeStart;

  /// Why a custom range is refused.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن اختيار يوم بعد اليوم.'**
  String get reportPeriodInFuture;

  /// Profit report heading (006 US2).
  ///
  /// In ar, this message translates to:
  /// **'الربح'**
  String get profitTitle;

  /// Profit line: sales not voided minus returns.
  ///
  /// In ar, this message translates to:
  /// **'صافي المبيعات'**
  String get profitNetSales;

  /// Profit line: the cost recorded on each sale line.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة البضاعة المباعة'**
  String get profitCostOfGoods;

  /// Profit line: net sales minus cost of goods sold.
  ///
  /// In ar, this message translates to:
  /// **'مجمل الربح'**
  String get profitGross;

  /// Profit line: stock adjustments at cost, losses net of count gains.
  ///
  /// In ar, this message translates to:
  /// **'خسائر المخزون'**
  String get profitInventoryLosses;

  /// Shown instead of inventory losses when count gains are larger.
  ///
  /// In ar, this message translates to:
  /// **'صافي مكسب المخزون'**
  String get profitInventoryNetGain;

  /// Profit line: expenses not voided in the period.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get profitExpenses;

  /// Profit line: gross profit minus inventory losses minus expenses.
  ///
  /// In ar, this message translates to:
  /// **'صافي الربح'**
  String get profitNet;

  /// Shown instead of net profit when it is negative.
  ///
  /// In ar, this message translates to:
  /// **'صافي الخسارة'**
  String get profitNetLoss;

  /// Profit report text when nothing happened in the period.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عمليات في هذه الفترة.'**
  String get profitEmpty;

  /// Note when some sale lines had no cost when sold.
  ///
  /// In ar, this message translates to:
  /// **'بيعت بعض المنتجات دون تكلفة مسجلة، فقد يبدو الربح أعلى من حقيقته.'**
  String get profitNoCostNote;

  /// Expenses list title and the Reports link.
  ///
  /// In ar, this message translates to:
  /// **'المصروفات'**
  String get expensesTitle;

  /// Button that opens the new expense form.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل مصروف'**
  String get expenseNewAction;

  /// New expense form title.
  ///
  /// In ar, this message translates to:
  /// **'مصروف جديد'**
  String get expenseNewTitle;

  /// Expense details title.
  ///
  /// In ar, this message translates to:
  /// **'المصروف {number}'**
  String expenseTitle(String number);

  /// Expense form: the category.
  ///
  /// In ar, this message translates to:
  /// **'البند'**
  String get expenseCategoryLabel;

  /// Expense form and details: the day it was spent.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get expenseDateLabel;

  /// Default expense category.
  ///
  /// In ar, this message translates to:
  /// **'إيجار'**
  String get expenseCategoryRent;

  /// Default expense category.
  ///
  /// In ar, this message translates to:
  /// **'كهرباء'**
  String get expenseCategoryElectricity;

  /// Default expense category.
  ///
  /// In ar, this message translates to:
  /// **'رواتب'**
  String get expenseCategorySalaries;

  /// Default expense category.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get expenseCategoryOther;

  /// Expenses list filter: no category filter.
  ///
  /// In ar, this message translates to:
  /// **'كل البنود'**
  String get expensesAllCategories;

  /// Above the customer list: what all customers, active or archived, owe the shop.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستحق على العملاء: {amount}'**
  String customersTotalOwing(String amount);

  /// Above the supplier list: what the shop owes all suppliers, active or archived.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستحق للموردين: {amount}'**
  String suppliersTotalOwed(String amount);

  /// Stock summary screen title.
  ///
  /// In ar, this message translates to:
  /// **'ملخص المخزون'**
  String get stockSummaryTitle;

  /// The stock of active products at their average purchase cost.
  ///
  /// In ar, this message translates to:
  /// **'قيمة المخزون بسعر الشراء: {amount}'**
  String stockValueAtCost(String amount);

  /// The same stock at the sale prices.
  ///
  /// In ar, this message translates to:
  /// **'وبسعر البيع: {amount}'**
  String stockValueAtSale(String amount);

  /// Note under the stock value.
  ///
  /// In ar, this message translates to:
  /// **'{count} من الأصناف المتوفرة بلا سعر شراء، فلم تُحسب في القيمة بسعر الشراء.'**
  String stockWithoutCost(String count);

  /// Stock summary section header.
  ///
  /// In ar, this message translates to:
  /// **'حسب التصنيف'**
  String get stockByCategory;

  /// How many active products a category has.
  ///
  /// In ar, this message translates to:
  /// **'الأصناف: {count}'**
  String stockProductCount(String count);

  /// A category's stock at cost.
  ///
  /// In ar, this message translates to:
  /// **'القيمة: {amount}'**
  String stockGroupValue(String amount);

  /// A category whose products have no stock.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مخزون'**
  String get stockNone;

  /// Stock summary with no active products.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أصناف بعد.'**
  String get stockSummaryEmpty;

  /// Archive confirmation for a customer with no history (constitution 1.2.0).
  ///
  /// In ar, this message translates to:
  /// **'أرشفة العميل؟ ليس له أي حركة، لذلك سيُحذف نهائيًا بعد {days} أيام في الأرشيف إلا إذا استعدته قبلها. لا يمكن التراجع عن الحذف.'**
  String customerArchiveConfirmPurge(String days);

  /// Archive confirmation for a supplier with no history (constitution 1.2.0).
  ///
  /// In ar, this message translates to:
  /// **'أرشفة المورد؟ ليس له أي حركة، لذلك سيُحذف نهائيًا بعد {days} أيام في الأرشيف إلا إذا استعدته قبلها. لا يمكن التراجع عن الحذف.'**
  String supplierArchiveConfirmPurge(String days);

  /// Under an archived customer or supplier with no history.
  ///
  /// In ar, this message translates to:
  /// **'يُحذف نهائيًا في {date}'**
  String partyPurgeOn(String date);

  /// Expenses list total for the filters.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي غير الملغى: {amount}'**
  String expensesTotal(String amount);

  /// Expenses list empty state title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مصروفات في هذه الفترة'**
  String get expensesEmptyTitle;

  /// Expenses list empty state text.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الإيجار والكهرباء والرواتب وغيرها ليظهر صافي الربح صحيحًا.'**
  String get expensesEmptyBody;

  /// Shown after saving an expense.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المصروف {number}.'**
  String expenseSaved(String number);

  /// Expense details: void button.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء المصروف'**
  String get expenseVoidAction;

  /// Void dialog title.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء هذا المصروف؟'**
  String get expenseVoidTitle;

  /// Void dialog text.
  ///
  /// In ar, this message translates to:
  /// **'يبقى في القائمة مُعلَّمًا بأنه ملغى، ولا يُحسب في الإجماليات ولا في الربح. لا يمكن التراجع عن ذلك.'**
  String get expenseVoidBody;

  /// Shown after voiding an expense.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء المصروف.'**
  String get expenseVoided;

  /// Refusal: voided twice.
  ///
  /// In ar, this message translates to:
  /// **'هذا المصروف ملغى بالفعل.'**
  String get expenseAlreadyVoided;

  /// Expense details for a missing id.
  ///
  /// In ar, this message translates to:
  /// **'هذا المصروف غير موجود.'**
  String get expenseNotFound;

  /// Expense form error.
  ///
  /// In ar, this message translates to:
  /// **'اختر البند.'**
  String get errorExpenseCategoryRequired;

  /// Expense form error.
  ///
  /// In ar, this message translates to:
  /// **'أُرشف هذا البند. اختر بندًا آخر.'**
  String get errorExpenseCategoryArchived;

  /// Expense save refusal.
  ///
  /// In ar, this message translates to:
  /// **'هذا البند لم يعد موجودًا. اختر بندًا آخر.'**
  String get errorExpenseCategoryUnavailable;

  /// Expense form error.
  ///
  /// In ar, this message translates to:
  /// **'اكتب مبلغًا أكبر من صفر بخانتين عشريتين على الأكثر.'**
  String get errorExpenseAmountInvalid;

  /// Expense form error.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن أن يكون التاريخ بعد اليوم.'**
  String get errorExpenseDateInFuture;

  /// Expense form error when how it was paid is invalid.
  ///
  /// In ar, this message translates to:
  /// **'راجع بيانات الدفع.'**
  String get errorPaymentDetails;

  /// Expense categories screen title and link.
  ///
  /// In ar, this message translates to:
  /// **'بنود المصروفات'**
  String get expenseCategoriesTitle;

  /// Archive category confirmation.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة هذا البند؟ تظل المصروفات السابقة تعرض اسمه.'**
  String get expenseCategoryArchiveConfirm;

  /// Expense category archive button.
  ///
  /// In ar, this message translates to:
  /// **'أرشفة البند'**
  String get expenseCategoryArchive;

  /// Restore an archived expense category.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get expenseCategoryRestore;

  /// Expense categories: archived section title.
  ///
  /// In ar, this message translates to:
  /// **'البنود المؤرشفة'**
  String get expenseCategoriesArchived;

  /// Expense categories empty text.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بنود نشطة. أضف بندًا من الأعلى.'**
  String get expenseCategoriesEmpty;

  /// Expense category error.
  ///
  /// In ar, this message translates to:
  /// **'اكتب اسم البند.'**
  String get errorExpenseCategoryNameRequired;

  /// Expense category error.
  ///
  /// In ar, this message translates to:
  /// **'اسم البند لا يزيد على {max} حرفًا.'**
  String errorExpenseCategoryNameTooLong(String max);

  /// Expense category error.
  ///
  /// In ar, this message translates to:
  /// **'يوجد بند نشط بنفس الاسم: {name}.'**
  String errorExpenseCategoryNameTaken(String name);

  /// Expense category error.
  ///
  /// In ar, this message translates to:
  /// **'هذا البند لم يعد موجودًا.'**
  String get errorExpenseCategoryNotFound;

  /// After a sale is saved: one product on it is running low. {qty} is the quantity left with its unit.
  ///
  /// In ar, this message translates to:
  /// **'مخزون {name} قليل (المتبقي {qty}).'**
  String saleLowStockOne(String name, String qty);

  /// One running-low product inside saleLowStockTwo and saleLowStockTwoMore. {qty} is the quantity left with its unit.
  ///
  /// In ar, this message translates to:
  /// **'{name} (المتبقي {qty})'**
  String saleLowStockItem(String name, String qty);

  /// After a sale is saved: two products on it are running low. {first} and {second} are saleLowStockItem texts.
  ///
  /// In ar, this message translates to:
  /// **'المخزون قليل: {first}، {second}.'**
  String saleLowStockTwo(String first, String second);

  /// After a sale is saved: more than two products on it are running low. {first} and {second} are saleLowStockItem texts; {count} is how many more and picks the plural form; {countText} is the same number in the active digit style.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{المخزون قليل: {first}، {second}، ومنتج آخر.} =2{المخزون قليل: {first}، {second}، ومنتجان آخران.} few{المخزون قليل: {first}، {second}، و{countText} منتجات أخرى.} other{المخزون قليل: {first}، {second}، و{countText} منتجًا آخر.}}'**
  String saleLowStockTwoMore(
    String first,
    String second,
    int count,
    String countText,
  );

  /// Snack bar action after a sale that opens the running-low product list.
  ///
  /// In ar, this message translates to:
  /// **'عرض'**
  String get saleLowStockShow;

  /// Reports: title of the money-collected view and its link.
  ///
  /// In ar, this message translates to:
  /// **'المبالغ المحصَّلة'**
  String get reportCollectedTitle;

  /// Money collected: the grand total. {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي: {amount}'**
  String reportCollectedTotal(String amount);

  /// Money collected: nothing in the period.
  ///
  /// In ar, this message translates to:
  /// **'لم تُحصَّل أي مبالغ في هذه الفترة.'**
  String get reportCollectedEmpty;

  /// Reports: title of the top-sellers view and its link.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعًا'**
  String get reportTopSellersTitle;

  /// Top sellers: order by net sales value.
  ///
  /// In ar, this message translates to:
  /// **'حسب قيمة المبيعات'**
  String get reportTopByValue;

  /// Top sellers: order by quantity sold.
  ///
  /// In ar, this message translates to:
  /// **'حسب الكمية'**
  String get reportTopByQuantity;

  /// Top sellers: nothing sold in the period.
  ///
  /// In ar, this message translates to:
  /// **'لم يُبَع أي منتج في هذه الفترة.'**
  String get reportTopEmpty;

  /// Top sellers row: quantity sold, net of returns, with its unit.
  ///
  /// In ar, this message translates to:
  /// **'المباع: {qty}'**
  String reportTopSold(String qty);

  /// Reports: title of the balances view and its link.
  ///
  /// In ar, this message translates to:
  /// **'الأرصدة'**
  String get reportBalancesTitle;

  /// Balances tab: customers who owe the shop.
  ///
  /// In ar, this message translates to:
  /// **'على العملاء'**
  String get reportBalancesCustomersTab;

  /// Balances tab: suppliers the shop owes.
  ///
  /// In ar, this message translates to:
  /// **'للموردين'**
  String get reportBalancesSuppliersTab;

  /// Balances: total that customers owe. {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستحق للمحل: {amount}'**
  String reportBalancesCustomersTotal(String amount);

  /// Balances: total the shop owes suppliers. {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستحق على المحل: {amount}'**
  String reportBalancesSuppliersTotal(String amount);

  /// Balances: no customer owes.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عميل عليه مبالغ للمحل.'**
  String get reportBalancesCustomersNone;

  /// Balances: the shop owes no supplier.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مبالغ مستحقة على المحل لأي مورد.'**
  String get reportBalancesSuppliersNone;

  /// Payment field: adds another part paid by another method.
  ///
  /// In ar, this message translates to:
  /// **'تقسيم الدفع'**
  String get paymentSplitAction;

  /// Payment field: heading of one part of a split payment. {n} is 1, 2 or 3 in the digit style.
  ///
  /// In ar, this message translates to:
  /// **'الجزء {n}'**
  String paymentPartTitle(String n);

  /// Payment field: spoken label of the button that removes a part; its amount goes back to part 1.
  ///
  /// In ar, this message translates to:
  /// **'حذف الجزء {n}'**
  String paymentPartRemove(String n);

  /// Payment field: the amount of one part.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الجزء'**
  String get paymentPartAmountLabel;

  /// Payment field, wallet or InstaPay: the owner's own wallet number or InstaPay address the money arrived in or left from.
  ///
  /// In ar, this message translates to:
  /// **'رقم حسابك (اختياري)'**
  String get paymentAccountLabel;

  /// Helper under the account number field.
  ///
  /// In ar, this message translates to:
  /// **'مثل رقم محفظتك أو عنوان إنستاباي'**
  String get paymentAccountHint;

  /// Payment field: label above the chips of account numbers used before.
  ///
  /// In ar, this message translates to:
  /// **'حسابات استخدمتها من قبل'**
  String get paymentAccountSuggestions;

  /// Payment field, split: how much of the amount is not in any part yet. {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي توزيعه: {amount}'**
  String paymentRemaining(String amount);

  /// Payment field, split: the parts add up to more than the amount. {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'الأجزاء أكثر من المبلغ بـ {amount}'**
  String paymentOverBy(String amount);

  /// Payment field, split: the parts add up exactly.
  ///
  /// In ar, this message translates to:
  /// **'الأجزاء مساوية للمبلغ.'**
  String get paymentSplitBalanced;

  /// Payment part error.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مبلغًا صحيحًا بحد أقصى منزلتين عشريتين.'**
  String get errorPartAmountInvalid;

  /// Payment part error.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون الجزء أكبر من صفر.'**
  String get errorPartAmountZero;

  /// Payment part error: the same method is on two parts.
  ///
  /// In ar, this message translates to:
  /// **'كل طريقة دفع تُستخدم مرة واحدة فقط.'**
  String get errorPaymentMethodRepeated;

  /// Account number error.
  ///
  /// In ar, this message translates to:
  /// **'استخدم الأرقام والحروف اللاتينية و@ . _ - فقط.'**
  String get errorAccountInvalid;

  /// Account number error. {max} is 40 in the digit style.
  ///
  /// In ar, this message translates to:
  /// **'رقم الحساب {max} حرفًا على الأكثر.'**
  String errorAccountTooLong(String max);

  /// Account number error on a cash part.
  ///
  /// In ar, this message translates to:
  /// **'الدفع النقدي ليس له رقم حساب.'**
  String get errorAccountNotAllowed;

  /// Payment error.
  ///
  /// In ar, this message translates to:
  /// **'يمكن تقسيم الدفع إلى ثلاثة أجزاء على الأكثر.'**
  String get errorTooManyParts;

  /// Payment error: the parts add up to more. {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'مجموع الأجزاء أكثر من المبلغ المدفوع بـ {amount}. اجعلها مساوية له.'**
  String errorPartsOver(String amount);

  /// Payment error: the parts add up to less. {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'مجموع الأجزاء أقل من المبلغ المدفوع بـ {amount}. اجعلها مساوية له.'**
  String errorPartsShort(String amount);

  /// One part of a payment on a details screen or statement. {method} is the method name; {amount} is money.
  ///
  /// In ar, this message translates to:
  /// **'{method}: {amount}'**
  String paymentPartLine(String method, String amount);

  /// Under a payment part: the owner's account number. {account} is kept left-to-right.
  ///
  /// In ar, this message translates to:
  /// **'إلى/من حسابك {account}'**
  String paymentPartAccount(String account);

  /// Details screens: heading of the payment parts.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentPartsTitle;
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
