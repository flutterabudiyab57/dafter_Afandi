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
