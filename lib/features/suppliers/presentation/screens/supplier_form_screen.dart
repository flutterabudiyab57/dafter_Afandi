import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../customers/domain/customer_errors.dart';
import '../../../customers/presentation/cubits/customers_list_cubit.dart';
import '../cubits/supplier_form_cubit.dart';
import '../widgets/supplier_text.dart';

/// Adds or edits a supplier (US4). The opening balance appears only when
/// adding.
class SupplierFormScreen extends StatelessWidget {
  const SupplierFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final create =
        context.read<SupplierFormCubit>().mode == SupplierFormMode.create;
    return BlocListener<SupplierFormCubit, SupplierFormState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == SupplierFormStatus.saved,
      listener: (context, state) {
        if (state.nameExistsElsewhere) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.supplierNameExistsNotice)),
          );
        }
        if (create) {
          context.pushReplacement(RoutePaths.supplierDetails(state.savedId!));
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(create ? l10n.supplierAddTitle : l10n.supplierEditTitle),
        ),
        body: BlocBuilder<SupplierFormCubit, SupplierFormState>(
          buildWhen: (a, b) =>
              (a.status == SupplierFormStatus.loading) !=
                  (b.status == SupplierFormStatus.loading) ||
              (a.status == SupplierFormStatus.notFound) !=
                  (b.status == SupplierFormStatus.notFound),
          builder: (context, state) => switch (state.status) {
            SupplierFormStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            SupplierFormStatus.notFound => Center(
              child: Text(l10n.supplierNotFound),
            ),
            _ => const _Form(),
          },
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final SupplierFormCubit _cubit = context.read<SupplierFormCubit>();
  late final _name = TextEditingController(text: _cubit.state.name);
  late final _phone = TextEditingController(text: _cubit.state.phone);
  late final _address = TextEditingController(text: _cubit.state.address);
  late final _note = TextEditingController(text: _cubit.state.note);
  late final _opening = TextEditingController(text: _cubit.state.opening);

  @override
  void dispose() {
    for (final c in [_name, _phone, _address, _note, _opening]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<SupplierFormCubit>().state;
    final create = _cubit.mode == SupplierFormMode.create;

    String? err(CustomerField f) {
      final e = errorFor(state.errors, f);
      return e == null ? null : context.supplierFieldError(e);
    }

    final gap = SizedBox(height: tokens.spaceMd);
    return SafeArea(
      child: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              onChanged: _cubit.nameChanged,
              textInputAction: TextInputAction.next,
              inputFormatters: const [
                CodePointLengthFormatter(maxCustomerNameLength),
              ],
              decoration: InputDecoration(
                labelText: l10n.supplierNameLabel,
                errorText: err(CustomerField.name),
                errorMaxLines: 3,
              ),
            ),
            gap,
            TextField(
              controller: _phone,
              onChanged: _cubit.phoneChanged,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.customerPhoneLabel,
                errorText: err(CustomerField.phone),
                errorMaxLines: 3,
              ),
            ),
            gap,
            TextField(
              controller: _address,
              onChanged: _cubit.addressChanged,
              maxLines: null,
              inputFormatters: const [
                CodePointLengthFormatter(maxCustomerTextLength),
              ],
              decoration: InputDecoration(
                labelText: l10n.customerAddressLabel,
                errorText: err(CustomerField.address),
                errorMaxLines: 3,
              ),
            ),
            gap,
            TextField(
              controller: _note,
              onChanged: _cubit.noteChanged,
              maxLines: null,
              inputFormatters: const [
                CodePointLengthFormatter(maxCustomerTextLength),
              ],
              decoration: InputDecoration(
                labelText: l10n.customerNoteLabel,
                errorText: err(CustomerField.note),
                errorMaxLines: 3,
              ),
            ),
            if (create) ...[
              SizedBox(height: tokens.spaceLg),
              Text(
                l10n.customerOpeningSection,
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(height: tokens.spaceXs),
              Text(l10n.supplierOpeningHint, style: theme.textTheme.bodySmall),
              gap,
              MoneyField(
                controller: _opening,
                label: l10n.customerOpeningAmount,
                onChanged: _cubit.openingChanged,
                errorText: err(CustomerField.opening),
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: tokens.spaceSm),
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                children: [
                  ChoiceChip(
                    label: Text(l10n.supplierOpeningOwed),
                    selected: !state.openingInShopFavour,
                    onSelected: (_) =>
                        _cubit.openingDirectionChanged(inShopFavour: false),
                  ),
                  ChoiceChip(
                    label: Text(l10n.supplierOpeningInShopFavour),
                    selected: state.openingInShopFavour,
                    onSelected: (_) =>
                        _cubit.openingDirectionChanged(inShopFavour: true),
                  ),
                ],
              ),
            ],
            SizedBox(height: tokens.spaceXl),
            if (state.status == SupplierFormStatus.failed) ...[
              Text(
                l10n.errorSaveFailed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              gap,
            ],
            FilledButton(
              onPressed: state.status == SupplierFormStatus.saving
                  ? null
                  : _cubit.submit,
              child: Text(l10n.saveAction),
            ),
          ],
        ),
      ),
    );
  }
}
