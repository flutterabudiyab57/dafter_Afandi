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

  @override
  String get homeProductsAction => 'المنتجات';

  @override
  String get homeCategoriesAction => 'الأقسام';

  @override
  String get lowStockCardTitle => 'مخزون قليل';

  @override
  String lowStockCount(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText منتج مخزونه قليل',
      few: '$countText منتجات مخزونها قليل',
      two: 'منتجان مخزونهما قليل',
      one: 'منتج واحد مخزونه قليل',
    );
    return '$_temp0';
  }

  @override
  String get lowStockNone => 'المخزون كله على ما يرام.';

  @override
  String get lowStockNoProducts => 'أضف منتجاتك لتتابع مخزونها.';

  @override
  String get lowStockSeeAll => 'عرض الكل';

  @override
  String get productsTitle => 'المنتجات';

  @override
  String get productsSearchHint => 'ابحث بالاسم أو الكود أو الباركود';

  @override
  String get productsFilterAll => 'الكل';

  @override
  String get productsFilterNoCategory => 'بدون قسم';

  @override
  String get productsFilterLow => 'مخزون قليل';

  @override
  String get productsArchivedTitle => 'المنتجات المؤرشفة';

  @override
  String get productsEmpty => 'لا توجد منتجات بعد. أضف أول منتج لتبدأ.';

  @override
  String get productsEmptyAction => 'إضافة منتج';

  @override
  String productsNoMatch(String query) {
    return 'لا يوجد منتج باسم «$query».';
  }

  @override
  String productsAddNamed(String name) {
    return 'إضافة «$name»';
  }

  @override
  String get markLowStock => 'مخزون قليل';

  @override
  String get markBelowZero => 'المخزون أقل من صفر';

  @override
  String get productArchivedBadge => 'مؤرشف';

  @override
  String get unitPiece => 'بالقطعة';

  @override
  String get unitKg => 'بالكيلو';

  @override
  String get unitLiter => 'باللتر';

  @override
  String get unitMeter => 'بالمتر';

  @override
  String get unitPieceShort => 'قطعة';

  @override
  String get unitKgShort => 'كجم';

  @override
  String get unitLiterShort => 'لتر';

  @override
  String get unitMeterShort => 'م';

  @override
  String get productAddTitle => 'إضافة منتج';

  @override
  String get productEditTitle => 'تعديل المنتج';

  @override
  String get productNameLabel => 'اسم المنتج';

  @override
  String get productUnitLabel => 'يُباع';

  @override
  String get productPriceLabel => 'سعر البيع للوحدة';

  @override
  String get productCategoryLabel => 'القسم';

  @override
  String get productNoCategory => 'بدون قسم';

  @override
  String get productBarcodeLabel => 'الباركود';

  @override
  String get productSkuLabel => 'الكود';

  @override
  String get productLowStockLabel => 'حد المخزون القليل';

  @override
  String get productLowStockHint =>
      'تظهر علامة عندما يصل المخزون إلى هذه الكمية أو أقل.';

  @override
  String get productOpeningSection => 'رصيد أول المدة';

  @override
  String get productOpeningHint =>
      'الكمية الموجودة لديك الآن، وتكلفة الوحدة عليك.';

  @override
  String get productOpeningQtyLabel => 'الكمية الموجودة';

  @override
  String get productOpeningCostLabel => 'تكلفة الوحدة';

  @override
  String get productUnitLockedNote =>
      'لا يمكن تغيير الوحدة بعد تسجيل حركات مخزون للمنتج.';

  @override
  String get openingConfirmTitle => 'تأكيد رصيد أول المدة';

  @override
  String openingConfirmBody(String qty, String cost, String total) {
    return '$qty × $cost = $total\nلا يمكن تعديل رصيد أول المدة بعد الحفظ.';
  }

  @override
  String get confirmAction => 'تأكيد';

  @override
  String get backAction => 'رجوع';

  @override
  String get cancelAction => 'إلغاء';

  @override
  String get productNameExistsNotice => 'تم الحفظ. يوجد منتج آخر بنفس الاسم.';

  @override
  String get errorNameRequired => 'اكتب اسم المنتج.';

  @override
  String errorNameTooLong(String max) {
    return 'الاسم لا يزيد على $max حرفًا.';
  }

  @override
  String get errorPriceRequired => 'اكتب سعر البيع.';

  @override
  String get errorPriceInvalid =>
      'اكتب مبلغًا صحيحًا بحد أقصى رقمين بعد العلامة العشرية.';

  @override
  String errorPriceTooLarge(String max) {
    return 'المبلغ لا يزيد على $max.';
  }

  @override
  String get errorQuantityRequired => 'اكتب الكمية.';

  @override
  String get errorQuantityInvalid =>
      'اكتب كمية صحيحة بحد أقصى ٣ أرقام بعد العلامة العشرية.';

  @override
  String get errorQuantityNotWhole => 'القطع تُكتب أعدادًا صحيحة بدون كسور.';

  @override
  String errorQuantityTooLarge(String max) {
    return 'الكمية لا تزيد على $max.';
  }

  @override
  String get errorOpeningCostRequired =>
      'اكتب تكلفة الوحدة، نحتاجها لحساب الربح.';

  @override
  String errorBarcodeTaken(String name) {
    return 'هذا الباركود مستخدم للمنتج «$name».';
  }

  @override
  String errorCodeTooLong(String max) {
    return 'لا يزيد على $max حرفًا.';
  }

  @override
  String errorRestoreBarcodeTaken(String name) {
    return 'لا يمكن الاسترجاع: الباركود مستخدم الآن للمنتج «$name».';
  }

  @override
  String errorNoteTooLong(String max) {
    return 'الملاحظة لا تزيد على $max حرفًا.';
  }

  @override
  String get productDetailsTitle => 'تفاصيل المنتج';

  @override
  String get productAvgCost => 'متوسط التكلفة';

  @override
  String get productStockOnHand => 'المخزون الحالي';

  @override
  String get productEditAction => 'تعديل';

  @override
  String get productAdjustAction => 'تسوية المخزون';

  @override
  String get productSetOpeningAction => 'إدخال رصيد أول المدة';

  @override
  String get productArchiveAction => 'أرشفة';

  @override
  String get productArchiveConfirm =>
      'أرشفة المنتج؟ لن يظهر في القائمة والبحث، ويبقى سجله محفوظًا ويمكن استرجاعه.';

  @override
  String get productRestoreAction => 'استرجاع';

  @override
  String get productRestored => 'تم استرجاع المنتج.';

  @override
  String get historyTitle => 'حركة المخزون';

  @override
  String get historyEmpty => 'لا توجد حركات مخزون بعد.';

  @override
  String get historyShowMore => 'عرض المزيد';

  @override
  String get stockOpening => 'رصيد أول المدة';

  @override
  String get stockPurchase => 'شراء';

  @override
  String get stockPurchaseVoid => 'إلغاء شراء';

  @override
  String get stockSale => 'بيع';

  @override
  String get stockSaleReturn => 'مرتجع بيع';

  @override
  String get stockSaleVoid => 'إلغاء بيع';

  @override
  String get stockAdjustment => 'تسوية';

  @override
  String get reasonDamage => 'تالف';

  @override
  String get reasonCount => 'جرد';

  @override
  String get reasonOther => 'أخرى';

  @override
  String get adjustTitle => 'تسوية المخزون';

  @override
  String get adjustReasonLabel => 'السبب';

  @override
  String adjustOnHand(String qty) {
    return 'الموجود حاليًا: $qty';
  }

  @override
  String get adjustCountedLabel => 'الكمية التي تم عدّها';

  @override
  String get adjustRemoveLabel => 'الكمية المطلوب خصمها';

  @override
  String get adjustAdd => 'إضافة';

  @override
  String get adjustRemove => 'خصم';

  @override
  String get adjustQtyLabel => 'الكمية';

  @override
  String get adjustNoteLabel => 'ملاحظة';

  @override
  String get adjustNoteRequired => 'اكتب ملاحظة توضح السبب.';

  @override
  String adjustExceedsStock(String qty) {
    return 'الموجود $qty فقط.';
  }

  @override
  String get adjustAlreadyMatches => 'المخزون مطابق بالفعل، لم يتم تسجيل شيء.';

  @override
  String adjustSaved(String qty) {
    return 'تم الحفظ. المخزون الآن $qty.';
  }

  @override
  String get categoriesTitle => 'الأقسام';

  @override
  String get categoryAddHint => 'اسم قسم جديد';

  @override
  String get categoryAddAction => 'إضافة';

  @override
  String get categoryRename => 'تغيير الاسم';

  @override
  String get categoryMoveUp => 'تحريك لأعلى';

  @override
  String get categoryMoveDown => 'تحريك لأسفل';

  @override
  String get categoryArchive => 'أرشفة القسم';

  @override
  String get categoryArchiveConfirm =>
      'أرشفة القسم؟ منتجاته تبقى وتظهر «بدون قسم».';

  @override
  String categoryProductCount(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText منتج',
      few: '$countText منتجات',
      two: 'منتجان',
      one: 'منتج واحد',
      zero: 'لا منتجات',
    );
    return '$_temp0';
  }

  @override
  String get categoriesEmpty => 'لا توجد أقسام بعد.';

  @override
  String get errorCategoryNameRequired => 'اكتب اسم القسم.';

  @override
  String get errorCategoryDuplicate => 'يوجد قسم بنفس الاسم.';

  @override
  String errorCategoryNameTooLong(String max) {
    return 'اسم القسم لا يزيد على $max حرفًا.';
  }

  @override
  String get productsFilterEmpty => 'لا توجد منتجات تطابق هذا الاختيار.';
}
