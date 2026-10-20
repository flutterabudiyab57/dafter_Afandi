import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/theme/app_tokens.dart';
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
    final theme = Theme.of(context);
    final cubit = context.read<ShopProfileFormCubit>();

    return BlocListener<ShopProfileFormCubit, ShopProfileFormState>(
      listenWhen: (a, b) => b.status == ShopProfileFormStatus.saved,
      listener: (context, _) => context.pop(),
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
                        Text(
                          l10n.errorSaveFailed,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        SizedBox(height: tokens.spaceMd),
                      ],
                      FilledButton(
                        onPressed: state.status == ShopProfileFormStatus.saving
                            ? null
                            : cubit.submit,
                        child: Text(l10n.saveAction),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
