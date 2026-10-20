import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/digit_style_scope.dart';
import '../domain/shop_profile.dart';

/// The message for [error] in the active language and digit style.
String shopProfileErrorText(BuildContext context, ShopProfileError error) {
  final l10n = AppLocalizations.of(context);
  return switch (error) {
    ShopProfileError.nameRequired => l10n.errorShopNameRequired,
    ShopProfileError.nameTooLong => l10n.errorShopNameTooLong(
      context.digits('$maxShopNameLength'),
    ),
    ShopProfileError.phoneInvalidCharacters => l10n.errorPhoneInvalid,
    ShopProfileError.phoneTooShort => l10n.errorPhoneTooShort(
      context.digits('$minPhoneDigits'),
    ),
    ShopProfileError.phoneTooLong => l10n.errorPhoneTooLong(
      context.digits('$maxPhoneDigits'),
    ),
  };
}
