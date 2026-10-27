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
  String get categoryNameLabel => 'اسم القسم';

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

  @override
  String get productNotFound => 'هذا المنتج غير موجود.';

  @override
  String get productsArchivedEmpty => 'لا توجد منتجات مؤرشفة.';

  @override
  String get demoSeedMenu => 'أدوات المطور';

  @override
  String get demoSeedAction => 'إضافة منتجات تجريبية';

  @override
  String demoSeedDone(String count) {
    return 'تمت إضافة المنتجات التجريبية: $count.';
  }

  @override
  String get salesNewAction => 'بيع جديد';

  @override
  String get salesListEmpty => 'لا توجد فواتير بعد.';

  @override
  String get salesNoMatch => 'لا توجد فواتير مطابقة.';

  @override
  String get salesSearchHint => 'ابحث برقم الفاتورة أو اسم العميل';

  @override
  String get salesFilterUnpaid => 'غير مدفوعة بالكامل';

  @override
  String get listShowMore => 'عرض المزيد';

  @override
  String get walkInCustomer => 'عميل نقدي';

  @override
  String get saleKindCredit => 'آجل';

  @override
  String get saleKindPartial => 'مدفوعة جزئيًا';

  @override
  String get saleVoidedBadge => 'ملغاة';

  @override
  String get saleNewTitle => 'فاتورة بيع جديدة';

  @override
  String get saleAddProductAction => 'إضافة منتج';

  @override
  String get saleBarcodeLabel => 'امسح أو اكتب الباركود';

  @override
  String get saleBarcodeNotFound => 'لا يوجد منتج نشط بهذا الباركود.';

  @override
  String get saleEmpty => 'أضف منتجًا للبدء.';

  @override
  String get saleQtyLabel => 'الكمية';

  @override
  String get salePriceLabel => 'سعر الوحدة';

  @override
  String get saleLineDiscountLabel => 'خصم السطر';

  @override
  String saleRemoveLine(String name) {
    return 'إزالة $name من الفاتورة';
  }

  @override
  String saleLineTotal(String amount) {
    return 'إجمالي السطر: $amount';
  }

  @override
  String get saleSubtotal => 'المجموع';

  @override
  String get saleInvoiceDiscountLabel => 'خصم على الفاتورة';

  @override
  String get saleTotal => 'الإجمالي';

  @override
  String get salePaidLabel => 'المدفوع الآن';

  @override
  String get salePaidHint => 'اتركه فارغًا لدفع الإجمالي كاملًا';

  @override
  String get saleRemaining => 'المتبقي';

  @override
  String get saleMethodLabel => 'طريقة الدفع';

  @override
  String get methodCash => 'نقدي';

  @override
  String get methodWallet => 'محفظة إلكترونية';

  @override
  String get methodInstapay => 'إنستاباي';

  @override
  String get methodCard => 'بطاقة';

  @override
  String get saleCustomerLabel => 'العميل';

  @override
  String get saleCustomerPick => 'اختيار عميل';

  @override
  String get saleCustomerClear => 'بدون عميل';

  @override
  String get saleSaveAction => 'حفظ الفاتورة';

  @override
  String saleSaved(String number) {
    return 'تم حفظ الفاتورة $number.';
  }

  @override
  String get saleDiscardTitle => 'تجاهل الفاتورة؟';

  @override
  String get saleDiscardBody => 'المنتجات المضافة لن تُحفظ.';

  @override
  String get saleDiscardAction => 'تجاهل';

  @override
  String get saleKeepAction => 'متابعة البيع';

  @override
  String get shortageTitle => 'المخزون لا يكفي';

  @override
  String get shortageBody => 'سيصبح المخزون أقل من صفر لهذه المنتجات:';

  @override
  String shortageLine(String name, String stock, String need) {
    return '$name: المتاح $stock، المطلوب $need';
  }

  @override
  String get shortageConfirm => 'حفظ على أي حال';

  @override
  String get errorSaleNoLines => 'أضف منتجًا واحدًا على الأقل.';

  @override
  String get errorCreditNeedsCustomer =>
      'البيع الآجل أو الدفع الجزئي يحتاج إلى عميل مسمّى.';

  @override
  String get errorPaidTooLarge => 'المدفوع أكبر من الإجمالي.';

  @override
  String get errorLineDiscountTooLarge => 'الخصم أكبر من قيمة السطر.';

  @override
  String get errorInvoiceDiscountTooLarge => 'الخصم أكبر من المجموع.';

  @override
  String errorProductUnavailable(String name) {
    return 'المنتج «$name» لم يعد متاحًا؛ أزله من الفاتورة.';
  }

  @override
  String get errorCustomerUnavailable =>
      'العميل لم يعد متاحًا؛ اختر عميلًا آخر.';

  @override
  String invoiceTitle(String number) {
    return 'فاتورة بيع $number';
  }

  @override
  String get invoiceDateLabel => 'التاريخ';

  @override
  String invoiceLineDetail(String qty, String price) {
    return '$qty × $price';
  }

  @override
  String invoiceLineDiscount(String amount) {
    return 'خصم $amount';
  }

  @override
  String get invoiceVoidAction => 'إلغاء الفاتورة';

  @override
  String get invoiceVoidTitle => 'إلغاء الفاتورة؟';

  @override
  String get invoiceVoidBody =>
      'يرجع المخزون ورصيد العميل كما كانا قبل البيع، ولا يمكن التراجع.';

  @override
  String get reasonLabel => 'السبب';

  @override
  String invoiceVoidedOn(String date, String reason) {
    return 'ملغاة في $date: $reason';
  }

  @override
  String get invoiceVoided => 'تم إلغاء الفاتورة.';

  @override
  String get invoiceNotFound => 'هذه الفاتورة غير موجودة.';

  @override
  String get invoiceAlreadyVoided => 'هذه الفاتورة ملغاة بالفعل.';

  @override
  String get paymentAlreadyCancelled => 'هذه الدفعة ملغاة بالفعل.';

  @override
  String get paymentNotCancellable =>
      'دفعة الفاتورة لا تُلغى وحدها. ألغِ الفاتورة نفسها.';

  @override
  String get errorActionFailed =>
      'تعذّر إتمام العملية. لم يتغيّر شيء، حاول مرة أخرى.';

  @override
  String get errorReasonRequired => 'اكتب السبب.';

  @override
  String errorReasonTooLong(String max) {
    return 'يمكن أن يصل السبب إلى $max حرفًا كحد أقصى.';
  }

  @override
  String get customersTitle => 'العملاء';

  @override
  String get customersSearchHint => 'ابحث بالاسم أو رقم الهاتف';

  @override
  String get customersFilterOwes => 'المدينون';

  @override
  String get customersEmpty => 'لا يوجد عملاء بعد.';

  @override
  String get customersNoMatch => 'لا يوجد عملاء مطابقون.';

  @override
  String get customerAddTitle => 'إضافة عميل';

  @override
  String customerAddNamed(String name) {
    return 'إضافة «$name»';
  }

  @override
  String get customersArchivedTitle => 'العملاء المؤرشفون';

  @override
  String get customersArchivedEmpty => 'لا يوجد عملاء مؤرشفون.';

  @override
  String get customerEditTitle => 'تعديل العميل';

  @override
  String get customerNameLabel => 'اسم العميل';

  @override
  String get customerPhoneLabel => 'رقم الهاتف';

  @override
  String get customerAddressLabel => 'العنوان';

  @override
  String get customerNoteLabel => 'ملاحظة';

  @override
  String get customerOpeningSection => 'رصيد سابق';

  @override
  String get customerOpeningHint =>
      'إن كان للعميل حساب قبل استخدام التطبيق. لا يمكن تعديله بعد الحفظ.';

  @override
  String get customerOpeningAmount => 'المبلغ';

  @override
  String get customerOpeningOwes => 'العميل مدين للمحل';

  @override
  String get customerOpeningInFavour => 'المحل مدين للعميل';

  @override
  String get customerNameExistsNotice => 'تم الحفظ. يوجد عميل آخر بالاسم نفسه.';

  @override
  String get customerDetailsTitle => 'بيانات العميل';

  @override
  String get customerBalanceLabel => 'الرصيد';

  @override
  String balanceOwes(String amount) {
    return 'عليه $amount';
  }

  @override
  String balanceInFavour(String amount) {
    return 'له $amount';
  }

  @override
  String get balanceZero => 'لا رصيد';

  @override
  String get customerReceivePayment => 'استلام دفعة';

  @override
  String get customerArchiveAction => 'أرشفة العميل';

  @override
  String get customerArchiveConfirm =>
      'أرشفة العميل؟ فواتيره وكشف حسابه تبقى ويمكن استعادته.';

  @override
  String customerArchiveConfirmBalance(String balance) {
    return 'أرشفة العميل؟ رصيده $balance يبقى كما هو، وفواتيره وكشف حسابه تبقى ويمكن استعادته.';
  }

  @override
  String get customerArchivedBadge => 'مؤرشف';

  @override
  String get customerRestoreAction => 'استعادة';

  @override
  String get customerRestored => 'تمت استعادة العميل.';

  @override
  String get customerNotFound => 'هذا العميل غير موجود.';

  @override
  String get statementTitle => 'كشف الحساب';

  @override
  String get statementEmpty => 'لا توجد حركات بعد.';

  @override
  String get ledgerOpening => 'رصيد سابق';

  @override
  String ledgerSale(String number) {
    return 'فاتورة $number';
  }

  @override
  String get ledgerPayment => 'دفعة';

  @override
  String ledgerPaymentReceipt(String number) {
    return 'دفعة $number';
  }

  @override
  String ledgerSaleVoid(String number) {
    return 'إلغاء فاتورة $number';
  }

  @override
  String get ledgerReversal => 'قيد عكسي';

  @override
  String ledgerBalanceAfter(String amount) {
    return 'الرصيد: $amount';
  }

  @override
  String get ledgerCancelled => 'ملغاة';

  @override
  String get paymentCancelAction => 'إلغاء الدفعة';

  @override
  String get paymentCancelTitle => 'إلغاء الدفعة؟';

  @override
  String get paymentCancelBody =>
      'يُضاف قيد عكسي بالمبلغ نفسه ويرجع الرصيد كما كان.';

  @override
  String get paymentCancelled => 'تم إلغاء الدفعة.';

  @override
  String get customerInvoicesTitle => 'الفواتير';

  @override
  String get paymentTitle => 'استلام دفعة';

  @override
  String paymentBalanceNow(String amount) {
    return 'الرصيد الحالي: $amount';
  }

  @override
  String get paymentAmountLabel => 'المبلغ';

  @override
  String get paymentCreditTitle => 'الدفعة أكبر من الرصيد';

  @override
  String paymentCreditBody(String amount) {
    return 'سيصبح للعميل رصيد دائن قدره $amount.';
  }

  @override
  String paymentSaved(String number) {
    return 'تم حفظ الدفعة $number.';
  }

  @override
  String get errorAmountRequired => 'أدخل المبلغ.';

  @override
  String get errorCustomerNameRequired => 'أدخل اسم العميل.';

  @override
  String get errorCustomerArchived => 'العميل مؤرشف؛ استعده أولًا.';

  @override
  String get partiesCustomersTab => 'العملاء';

  @override
  String get partiesSuppliersTab => 'الموردون';

  @override
  String get suppliersTitle => 'الموردون';

  @override
  String get suppliersSearchHint => 'ابحث بالاسم أو رقم الهاتف';

  @override
  String get suppliersFilterOwed => 'مستحق لهم';

  @override
  String get suppliersEmpty => 'لا يوجد موردون بعد.';

  @override
  String get suppliersNoMatch => 'لا يوجد موردون مطابقون.';

  @override
  String get supplierAddTitle => 'إضافة مورد';

  @override
  String supplierAddNamed(String name) {
    return 'إضافة «$name»';
  }

  @override
  String get suppliersArchivedTitle => 'الموردون المؤرشفون';

  @override
  String get suppliersArchivedEmpty => 'لا يوجد موردون مؤرشفون.';

  @override
  String get supplierEditTitle => 'تعديل المورد';

  @override
  String get supplierNameLabel => 'اسم المورد';

  @override
  String get supplierOpeningHint =>
      'إذا كان للمورد حساب قبل استخدام التطبيق. لا يمكن تغييره بعد الحفظ.';

  @override
  String get supplierOpeningOwed => 'المحل مدين للمورد';

  @override
  String get supplierOpeningInShopFavour => 'المورد مدين للمحل';

  @override
  String get supplierNameExistsNotice => 'تم الحفظ. يوجد مورد آخر بالاسم نفسه.';

  @override
  String get supplierDetailsTitle => 'المورد';

  @override
  String supplierBalanceOwed(String amount) {
    return 'مستحق له $amount';
  }

  @override
  String supplierBalanceInShopFavour(String amount) {
    return 'عليه للمحل $amount';
  }

  @override
  String get supplierPayAction => 'دفع للمورد';

  @override
  String get supplierArchiveAction => 'أرشفة المورد';

  @override
  String get supplierArchiveConfirm =>
      'أرشفة المورد؟ تبقى مشترياته وكشف حسابه ويمكن استعادته.';

  @override
  String supplierArchiveConfirmBalance(String balance) {
    return 'أرشفة المورد؟ رصيده $balance يبقى كما هو، ومشترياته وكشف حسابه تبقى ويمكن استعادته.';
  }

  @override
  String get supplierRestored => 'تمت استعادة المورد.';

  @override
  String get supplierNotFound => 'هذا المورد غير موجود.';

  @override
  String get supplierPurchasesTitle => 'المشتريات';

  @override
  String get errorSupplierNameRequired => 'أدخل اسم المورد.';

  @override
  String get errorSupplierArchived => 'المورد مؤرشف؛ استعده أولًا.';

  @override
  String ledgerPurchase(String number) {
    return 'فاتورة شراء $number';
  }

  @override
  String ledgerPurchaseVoid(String number) {
    return 'فاتورة شراء ملغاة $number';
  }

  @override
  String get supplierPaymentNotCancellable =>
      'لا يمكن إلغاء دفعة تمت مع فاتورة شراء وحدها. ألغِ الفاتورة بدلًا من ذلك.';

  @override
  String get supplierPaymentTitle => 'دفع للمورد';

  @override
  String get supplierOverpayTitle => 'أكثر من المستحق';

  @override
  String supplierOverpayBody(String amount) {
    return 'سيصبح المورد مدينًا للمحل بمبلغ $amount.';
  }

  @override
  String get purchasesNewAction => 'فاتورة شراء جديدة';

  @override
  String get purchasesListEmpty => 'لا توجد فواتير شراء بعد.';

  @override
  String get purchasesNoMatch => 'لا توجد فواتير شراء مطابقة.';

  @override
  String get purchasesSearchHint =>
      'ابحث برقم الفاتورة أو المورد أو رقم فاتورة المورد';

  @override
  String get purchaseNoSupplier => 'بدون مورد';

  @override
  String get purchaseNewTitle => 'فاتورة شراء جديدة';

  @override
  String get purchaseCostLabel => 'تكلفة الوحدة';

  @override
  String get purchaseCostNotice => 'التكلفة تساوي سعر البيع أو تزيد عليه.';

  @override
  String purchaseRemoveLine(String name) {
    return 'إزالة $name من الفاتورة';
  }

  @override
  String get purchaseSupplierLabel => 'المورد';

  @override
  String get purchaseSupplierPick => 'اختر موردًا';

  @override
  String get purchaseSupplierRefLabel => 'رقم فاتورة المورد';

  @override
  String get purchaseDateLabel => 'تاريخ الفاتورة';

  @override
  String get purchaseSaveAction => 'حفظ فاتورة الشراء';

  @override
  String purchaseSaved(String number) {
    return 'تم حفظ فاتورة الشراء $number.';
  }

  @override
  String get purchaseDiscardTitle => 'تجاهل فاتورة الشراء؟';

  @override
  String get purchaseKeepAction => 'متابعة الفاتورة';

  @override
  String purchaseAddProductNamed(String name) {
    return 'إضافة «$name» كمنتج جديد';
  }

  @override
  String get purchaseQuickAddTitle => 'منتج جديد';

  @override
  String get errorCreditNeedsSupplier =>
      'الشراء الآجل أو الدفع الجزئي يحتاج إلى مورد.';

  @override
  String get errorPurchaseDateInFuture =>
      'لا يمكن أن يكون تاريخ الفاتورة بعد اليوم.';

  @override
  String errorPurchaseProductUnavailable(String name) {
    return '«$name» لم يعد متاحًا؛ أزله من الفاتورة.';
  }

  @override
  String get errorSupplierUnavailable => 'المورد لم يعد متاحًا؛ اختر غيره.';

  @override
  String purchaseTitle(String number) {
    return 'فاتورة شراء $number';
  }

  @override
  String get purchaseVoidAction => 'إلغاء الفاتورة';

  @override
  String get purchaseVoidTitle => 'إلغاء فاتورة الشراء؟';

  @override
  String get purchaseVoidBody =>
      'يعود المخزون ومتوسط التكلفة ورصيد المورد إلى ما كانت عليه قبل الشراء. لا يمكن التراجع عن ذلك.';

  @override
  String get purchaseVoided => 'تم إلغاء فاتورة الشراء.';

  @override
  String get purchaseNotFound => 'فاتورة الشراء هذه غير موجودة.';

  @override
  String get purchaseAlreadyVoided => 'فاتورة الشراء هذه ملغاة بالفعل.';

  @override
  String voidShortageLine(String name, String stock) {
    return '$name: $stock بعد الإلغاء';
  }

  @override
  String get voidShortageConfirm => 'إلغاء على أي حال';

  @override
  String get customersEmptyTitle => 'لا يوجد عملاء بعد';

  @override
  String get customersEmptyBody =>
      'أضف عميلًا لتسجّل البيع الآجل وتتابع ما عليه.';

  @override
  String get suppliersEmptyTitle => 'لا يوجد موردون بعد';

  @override
  String get suppliersEmptyBody => 'أضف موردًا لتسجّل مشترياتك وما عليك له.';

  @override
  String get purchasesEmptyTitle => 'لا توجد مشتريات بعد';

  @override
  String get purchasesEmptyBody =>
      'سجّل أول شراء ليزيد المخزون وتُحسب التكلفة.';

  @override
  String get searchEmptyTitle => 'لا توجد نتائج';

  @override
  String get searchClearAction => 'مسح البحث';

  @override
  String get retryAction => 'إعادة المحاولة';

  @override
  String get undoAction => 'تراجع';

  @override
  String get savingLabel => 'جارٍ الحفظ…';

  @override
  String get discardChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get discardChangesBody => 'لم تُحفظ التغييرات. إذا خرجت الآن فستضيع.';

  @override
  String get discardAction => 'تجاهل';

  @override
  String get keepEditingAction => 'متابعة التعديل';

  @override
  String get creditNeedsCustomerTitle => 'اختر عميلًا للبيع الآجل';

  @override
  String get chooseAction => 'اختيار';

  @override
  String get openingDataLabel => 'جارٍ فتح بياناتك…';

  @override
  String get productArchivedMessage => 'أُرشف المنتج.';

  @override
  String get customerArchivedMessage => 'أُرشف العميل.';

  @override
  String get supplierArchivedMessage => 'أُرشف المورد.';

  @override
  String get loadFailedTitle => 'تعذّر عرض البيانات';

  @override
  String get loadFailedBody => 'لم يتغيّر شيء في بياناتك. حاول مرة أخرى.';

  @override
  String get dashboardTodayTitle => 'اليوم';

  @override
  String get dashboardSalesTitle => 'مبيعات اليوم';

  @override
  String dashboardSalesCount(int count, String countText) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countText عملية بيع',
      few: '$countText عمليات بيع',
      two: 'عمليتا بيع',
      one: 'عملية بيع واحدة',
      zero: 'لا توجد مبيعات بعد',
    );
    return '$_temp0';
  }

  @override
  String get dashboardCollectedTitle => 'المحصَّل اليوم';

  @override
  String get dashboardRunningLowTitle => 'منتجات قاربت على النفاد';

  @override
  String get dashboardDebtorsTitle => 'الأكثر مديونية';

  @override
  String get dashboardDebtorsNone => 'لا يوجد عملاء عليهم مبالغ للمحل.';

  @override
  String get dashboardSeeAll => 'عرض الكل';

  @override
  String get reportPeriodToday => 'اليوم';

  @override
  String get reportPeriodYesterday => 'أمس';

  @override
  String get reportPeriodThisWeek => 'هذا الأسبوع';

  @override
  String get reportPeriodThisMonth => 'هذا الشهر';

  @override
  String get reportPeriodLastMonth => 'الشهر الماضي';

  @override
  String get reportPeriodCustom => 'فترة أخرى';

  @override
  String reportPeriodRange(String from, String to) {
    return 'من $from إلى $to';
  }

  @override
  String get reportPeriodEndBeforeStart => 'تاريخ النهاية قبل تاريخ البداية.';

  @override
  String get reportPeriodInFuture => 'لا يمكن اختيار يوم بعد اليوم.';

  @override
  String get profitTitle => 'الربح';

  @override
  String get profitNetSales => 'صافي المبيعات';

  @override
  String get profitCostOfGoods => 'تكلفة البضاعة المباعة';

  @override
  String get profitGross => 'مجمل الربح';

  @override
  String get profitInventoryLosses => 'خسائر المخزون';

  @override
  String get profitInventoryNetGain => 'صافي مكسب المخزون';

  @override
  String get profitExpenses => 'المصروفات';

  @override
  String get profitNet => 'صافي الربح';

  @override
  String get profitNetLoss => 'صافي الخسارة';

  @override
  String get profitEmpty => 'لا توجد عمليات في هذه الفترة.';

  @override
  String get profitNoCostNote =>
      'بيعت بعض المنتجات دون تكلفة مسجلة، فقد يبدو الربح أعلى من حقيقته.';

  @override
  String get expensesTitle => 'المصروفات';

  @override
  String get expenseNewAction => 'تسجيل مصروف';

  @override
  String get expenseNewTitle => 'مصروف جديد';

  @override
  String expenseTitle(String number) {
    return 'المصروف $number';
  }

  @override
  String get expenseCategoryLabel => 'البند';

  @override
  String get expenseDateLabel => 'التاريخ';

  @override
  String get expenseCategoryRent => 'إيجار';

  @override
  String get expenseCategoryElectricity => 'كهرباء';

  @override
  String get expenseCategorySalaries => 'رواتب';

  @override
  String get expenseCategoryOther => 'أخرى';

  @override
  String get expensesAllCategories => 'كل البنود';

  @override
  String expensesTotal(String amount) {
    return 'إجمالي غير الملغى: $amount';
  }

  @override
  String get expensesEmptyTitle => 'لا توجد مصروفات في هذه الفترة';

  @override
  String get expensesEmptyBody =>
      'سجّل الإيجار والكهرباء والرواتب وغيرها ليظهر صافي الربح صحيحًا.';

  @override
  String expenseSaved(String number) {
    return 'تم حفظ المصروف $number.';
  }

  @override
  String get expenseVoidAction => 'إلغاء المصروف';

  @override
  String get expenseVoidTitle => 'إلغاء هذا المصروف؟';

  @override
  String get expenseVoidBody =>
      'يبقى في القائمة مُعلَّمًا بأنه ملغى، ولا يُحسب في الإجماليات ولا في الربح. لا يمكن التراجع عن ذلك.';

  @override
  String get expenseVoided => 'تم إلغاء المصروف.';

  @override
  String get expenseAlreadyVoided => 'هذا المصروف ملغى بالفعل.';

  @override
  String get expenseNotFound => 'هذا المصروف غير موجود.';

  @override
  String get errorExpenseCategoryRequired => 'اختر البند.';

  @override
  String get errorExpenseCategoryArchived => 'أُرشف هذا البند. اختر بندًا آخر.';

  @override
  String get errorExpenseCategoryUnavailable =>
      'هذا البند لم يعد موجودًا. اختر بندًا آخر.';

  @override
  String get errorExpenseAmountInvalid =>
      'اكتب مبلغًا أكبر من صفر بخانتين عشريتين على الأكثر.';

  @override
  String get errorExpenseDateInFuture => 'لا يمكن أن يكون التاريخ بعد اليوم.';

  @override
  String get errorPaymentDetails => 'راجع بيانات الدفع.';

  @override
  String get expenseCategoriesTitle => 'بنود المصروفات';

  @override
  String get expenseCategoryArchiveConfirm =>
      'أرشفة هذا البند؟ تظل المصروفات السابقة تعرض اسمه.';

  @override
  String get expenseCategoryArchive => 'أرشفة البند';

  @override
  String get expenseCategoryRestore => 'استعادة';

  @override
  String get expenseCategoriesArchived => 'البنود المؤرشفة';

  @override
  String get expenseCategoriesEmpty =>
      'لا توجد بنود نشطة. أضف بندًا من الأعلى.';

  @override
  String get errorExpenseCategoryNameRequired => 'اكتب اسم البند.';

  @override
  String errorExpenseCategoryNameTooLong(String max) {
    return 'اسم البند لا يزيد على $max حرفًا.';
  }

  @override
  String errorExpenseCategoryNameTaken(String name) {
    return 'يوجد بند نشط بنفس الاسم: $name.';
  }

  @override
  String get errorExpenseCategoryNotFound => 'هذا البند لم يعد موجودًا.';
}
