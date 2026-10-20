import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_tokens.dart';
import '../../settings/presentation/cubits/shop_profile_form_cubit.dart';
import '../../settings/presentation/widgets/shop_profile_fields.dart';

/// First-run step 2: shop name (required) and phone (optional). Nothing is
/// saved here; the last step saves both (US1).
class ShopDetailsStepScreen extends StatelessWidget {
  const ShopDetailsStepScreen({super.key});

  void _continue(BuildContext context) {
    if (context.read<ShopProfileFormCubit>().validate()) {
      context.push(RoutePaths.onboardingData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopDetailsTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: tokens.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShopProfileFields(onDone: () => _continue(context)),
              SizedBox(height: tokens.spaceXl),
              FilledButton(
                onPressed: () => _continue(context),
                child: Text(l10n.continueAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
