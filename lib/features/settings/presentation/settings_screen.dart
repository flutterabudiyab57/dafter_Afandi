import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/digits.dart';
import '../../../core/widgets/digit_style_scope.dart';
import '../domain/app_locale.dart';
import '../domain/app_settings.dart';
import '../domain/app_version.dart';
import 'cubits/app_preferences_cubit.dart';

/// Shop details, language, digit style, about your data and the version.
/// Nothing else (FR-010).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<AppPreferencesCubit>().state;
    final version = context.read<AppVersion>();
    final prefs = context.read<AppPreferencesCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _ShopDetailsTile(settings: settings),
          const Divider(),
          _SectionHeader(l10n.settingsLanguage),
          RadioGroup<AppLocale>(
            groupValue: settings.locale,
            onChanged: (locale) {
              if (locale != null) prefs.changeLocale(locale);
            },
            child: Column(
              children: [
                RadioListTile(
                  value: AppLocale.ar,
                  title: Text(l10n.languageArabic),
                ),
                RadioListTile(
                  value: AppLocale.en,
                  title: Text(l10n.languageEnglish),
                ),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(l10n.settingsDigitStyle),
          RadioGroup<DigitStylePreference>(
            groupValue: settings.digitStyle,
            onChanged: (style) {
              if (style != null) prefs.changeDigitStyle(style);
            },
            child: Column(
              children: [
                RadioListTile(
                  value: DigitStylePreference.followLanguage,
                  title: Text(l10n.digitStyleFollowLanguage),
                ),
                RadioListTile(
                  value: DigitStylePreference.arabicIndic,
                  title: Text(l10n.digitStyleArabic),
                ),
                RadioListTile(
                  value: DigitStylePreference.latin,
                  title: Text(l10n.digitStyleLatin),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(l10n.settingsAboutData),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(RoutePaths.settingsData),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.settingsAppVersion),
            // Always Latin, never through context.digits (FR-011).
            subtitle: Text(ltrIsolate(version.display)),
          ),
        ],
      ),
    );
  }
}

class _ShopDetailsTile extends StatelessWidget {
  const _ShopDetailsTile({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shop = settings.shop;
    final phone = shop?.phone;
    return ListTile(
      leading: const Icon(Icons.storefront_outlined),
      title: Text(l10n.settingsShopDetails),
      subtitle: shop == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exactly as typed: no digit style on the name (FR-011).
                Text(shop.name),
                if (phone != null) Text(ltrIsolate(context.digits(phone))),
              ],
            ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(RoutePaths.settingsShop),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: context.tokens.sectionHeaderPadding,
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
