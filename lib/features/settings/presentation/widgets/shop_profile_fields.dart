import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../domain/shop_profile.dart';
import '../cubits/shop_profile_form_cubit.dart';
import '../shop_profile_error_text.dart';

/// The shop name and phone fields, bound to the [ShopProfileFormCubit]
/// above. Used by the first-run step and the settings editor.
class ShopProfileFields extends StatefulWidget {
  const ShopProfileFields({required this.onDone, super.key});

  /// Called when the owner presses the keyboard's done action on the phone.
  final VoidCallback onDone;

  @override
  State<ShopProfileFields> createState() => _ShopProfileFieldsState();
}

class _ShopProfileFieldsState extends State<ShopProfileFields> {
  late final ShopProfileFormCubit _cubit = context.read<ShopProfileFormCubit>();
  late final TextEditingController _name = TextEditingController(
    text: _cubit.state.nameInput,
  );
  late final TextEditingController _phone = TextEditingController(
    text: _cubit.state.phoneInput,
  );

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return BlocBuilder<ShopProfileFormCubit, ShopProfileFormState>(
      buildWhen: (a, b) =>
          a.nameError != b.nameError || a.phoneError != b.phoneError,
      builder: (context, state) {
        String? error(ShopProfileError? e) =>
            e == null ? null : shopProfileErrorText(context, e);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              onChanged: _cubit.nameChanged,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              inputFormatters: const [
                CodePointLengthFormatter(maxShopNameLength),
              ],
              decoration: InputDecoration(
                labelText: l10n.shopNameLabel,
                errorText: error(state.nameError),
                errorMaxLines: 3,
              ),
            ),
            SizedBox(height: tokens.spaceMd),
            TextField(
              controller: _phone,
              onChanged: _cubit.phoneChanged,
              onSubmitted: (_) => widget.onDone(),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: l10n.shopPhoneLabel,
                helperText: l10n.shopPhoneOptionalHint,
                helperMaxLines: 3,
                errorText: error(state.phoneError),
                errorMaxLines: 3,
              ),
            ),
          ],
        );
      },
    );
  }
}
