import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../domain/customer_errors.dart';
import '../cubits/customer_form_cubit.dart';
import '../cubits/customers_list_cubit.dart';
import '../widgets/customer_text.dart';

/// Adds or edits a customer (US4). The opening balance appears only when
/// adding.
class CustomerFormScreen extends StatelessWidget {
  const CustomerFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final create =
        context.read<CustomerFormCubit>().mode == CustomerFormMode.create;
    return BlocListener<CustomerFormCubit, CustomerFormState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == CustomerFormStatus.saved,
      listener: (context, state) {
        if (state.nameExistsElsewhere) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.customerNameExistsNotice)),
          );
        }
        if (create) {
          context.pushReplacement(RoutePaths.customerDetails(state.savedId!));
        } else {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(create ? l10n.customerAddTitle : l10n.customerEditTitle),
        ),
        body: BlocBuilder<CustomerFormCubit, CustomerFormState>(
          buildWhen: (a, b) =>
              (a.status == CustomerFormStatus.loading) !=
                  (b.status == CustomerFormStatus.loading) ||
              (a.status == CustomerFormStatus.notFound) !=
                  (b.status == CustomerFormStatus.notFound),
          builder: (context, state) => switch (state.status) {
            CustomerFormStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            CustomerFormStatus.notFound => Center(
              child: Text(l10n.customerNotFound),
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
  late final CustomerFormCubit _cubit = context.read<CustomerFormCubit>();
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
    final state = context.watch<CustomerFormCubit>().state;
    final create = _cubit.mode == CustomerFormMode.create;

    String? err(CustomerField f) {
      final e = errorFor(state.errors, f);
      return e == null ? null : context.customerFieldError(e);
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
                labelText: l10n.customerNameLabel,
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
              Text(l10n.customerOpeningHint, style: theme.textTheme.bodySmall),
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
                    label: Text(l10n.customerOpeningOwes),
                    selected: !state.openingInFavour,
                    onSelected: (_) =>
                        _cubit.openingDirectionChanged(inFavour: false),
                  ),
                  ChoiceChip(
                    label: Text(l10n.customerOpeningInFavour),
                    selected: state.openingInFavour,
                    onSelected: (_) =>
                        _cubit.openingDirectionChanged(inFavour: true),
                  ),
                ],
              ),
            ],
            SizedBox(height: tokens.spaceXl),
            if (state.status == CustomerFormStatus.failed) ...[
              Text(
                l10n.errorSaveFailed,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              gap,
            ],
            FilledButton(
              onPressed: state.status == CustomerFormStatus.saving
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
