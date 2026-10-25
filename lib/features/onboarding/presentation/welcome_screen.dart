import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_illustration.dart';
import '../../settings/domain/app_locale.dart';
import '../../settings/presentation/cubits/app_preferences_cubit.dart';

/// First-run step 1: logo, name, intro and the language switch (US1).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final locale = context.select<AppPreferencesCubit, AppLocale>(
      (c) => c.state.locale,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: tokens.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                label: l10n.logoSemantics,
                image: true,
                child: ExcludeSemantics(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: tokens.logoHeight,
                  ),
                ),
              ),
              SizedBox(height: tokens.spaceMd),
              Text(
                l10n.appName,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spaceLg),
              const Center(child: Illustration(AppIllustration.welcome)),
              SizedBox(height: tokens.spaceLg),
              Text(
                l10n.welcomeTitle,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spaceSm),
              Text(
                l10n.welcomeBody,
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: tokens.spaceXl),
              Center(
                child: SegmentedButton<AppLocale>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: AppLocale.ar,
                      label: Text(l10n.languageArabic),
                    ),
                    ButtonSegment(
                      value: AppLocale.en,
                      label: Text(l10n.languageEnglish),
                    ),
                  ],
                  selected: {locale},
                  onSelectionChanged: (selection) => context
                      .read<AppPreferencesCubit>()
                      .changeLocale(selection.single),
                ),
              ),
              SizedBox(height: tokens.spaceXl),
              FilledButton(
                onPressed: () => context.push(RoutePaths.onboardingShop),
                child: Text(l10n.continueAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
