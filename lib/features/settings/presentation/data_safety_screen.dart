import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/save_button.dart';
import '../../../core/widgets/status_banner.dart';
import 'cubits/shop_profile_form_cubit.dart';

enum DataSafetyMode { onboarding, settings }

/// Where the data lives and how it is backed up, per platform (US2).
/// In onboarding mode it is the last first-run step and saves the profile.
class DataSafetyScreen extends StatelessWidget {
  const DataSafetyScreen({required this.mode, super.key});

  final DataSafetyMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final platformText = switch (defaultTargetPlatform) {
      TargetPlatform.android => l10n.dataSafetyAndroidBackup,
      TargetPlatform.iOS => l10n.dataSafetyIosManual,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataSafetyTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: tokens.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.dataSafetyLocalOnly, style: textTheme.bodyLarge),
              if (platformText != null) ...[
                SizedBox(height: tokens.spaceMd),
                Text(platformText, style: textTheme.bodyLarge),
              ],
              if (mode == DataSafetyMode.onboarding) ...[
                SizedBox(height: tokens.spaceXl),
                const _FinishButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Saves the profile and completes onboarding. On success the router's
/// redirect moves to Home; on failure the typed values stay.
class _FinishButton extends StatelessWidget {
  const _FinishButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final status = context.select<ShopProfileFormCubit, ShopProfileFormStatus>(
      (c) => c.state.status,
    );
    final saving = status == ShopProfileFormStatus.saving;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (status == ShopProfileFormStatus.failed) ...[
          StatusBanner(tone: StatusTone.error, title: l10n.errorSaveFailed),
          SizedBox(height: tokens.spaceMd),
        ],
        SaveButton(
          label: l10n.finishAction,
          savingLabel: l10n.savingLabel,
          saving: saving,
          onPressed: () => context.read<ShopProfileFormCubit>().submit(),
        ),
      ],
    );
  }
}
