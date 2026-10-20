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
