import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/save_button.dart';
import '../../../core/widgets/status_banner.dart';
import '../../../core/widgets/unsaved_changes_guard.dart';
import 'cubits/shop_profile_form_cubit.dart';
import 'widgets/shop_profile_fields.dart';

/// Edits the shop name and phone from settings. An invalid name blocks Save
/// and the stored name stays (US4).
class ShopProfileEditScreen extends StatelessWidget {
  const ShopProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<ShopProfileFormCubit>();

    return BlocListener<ShopProfileFormCubit, ShopProfileFormState>(
      listenWhen: (a, b) => b.status == ShopProfileFormStatus.saved,
      listener: (context, _) => context.pop(),
      child: BlocBuilder<ShopProfileFormCubit, ShopProfileFormState>(
        builder: (context, _) => UnsavedChangesGuard(
          dirty: context.read<ShopProfileFormCubit>().hasUnsavedChanges,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.shopDetailsTitle)),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: tokens.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ShopProfileFields(onDone: cubit.submit),
                    SizedBox(height: tokens.spaceXl),
                    BlocBuilder<ShopProfileFormCubit, ShopProfileFormState>(
                      buildWhen: (a, b) => a.status != b.status,
                      builder: (context, state) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (state.status == ShopProfileFormStatus.failed) ...[
                            StatusBanner(
                              tone: StatusTone.error,
                              title: l10n.errorSaveFailed,
                            ),
                            SizedBox(height: tokens.spaceMd),
                          ],
                          SaveButton(
                            label: l10n.saveAction,
                            savingLabel: l10n.savingLabel,
                            saving:
                                state.status == ShopProfileFormStatus.saving,
                            onPressed: cubit.submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
