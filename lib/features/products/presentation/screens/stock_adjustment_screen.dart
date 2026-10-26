import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/form_error_banner.dart';
import '../../../../core/widgets/number_fields.dart';
import '../../../../core/widgets/save_button.dart';
import '../../../../core/widgets/unsaved_changes_guard.dart';
import '../../domain/product_errors.dart';
import '../../domain/stock_entry.dart';
import '../cubits/stock_adjustment_cubit.dart';
import '../widgets/history_labels.dart';
import '../widgets/product_error_text.dart';
import '../widgets/unit_label.dart';

/// Records one stock adjustment: damaged, a stock count, or other with a
/// note (FR-013–FR-015, US4).
class StockAdjustmentScreen extends StatelessWidget {
  const StockAdjustmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<StockAdjustmentCubit, StockAdjustmentState>(
      listenWhen: (a, b) =>
          a.status != b.status && b.status == StockAdjustmentStatus.saved,
      listener: (context, state) {
        showAppSnackBar(
          context,
          l10n.adjustSaved(context.quantity(state.newStockMilli!, state.unit)),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(
            RoutePaths.productDetails(
              context.read<StockAdjustmentCubit>().productId,
            ),
          );
        }
      },
      child: BlocSelector<StockAdjustmentCubit, StockAdjustmentState, bool>(
        // Rebuilt only when the answer to "leave?" changes.
        selector: (_) => context.read<StockAdjustmentCubit>().hasUnsavedChanges,
        builder: (context, dirty) => UnsavedChangesGuard(
          dirty: dirty,
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.adjustTitle)),
            body: BlocBuilder<StockAdjustmentCubit, StockAdjustmentState>(
              buildWhen: (a, b) =>
                  (a.status == StockAdjustmentStatus.loading) !=
                      (b.status == StockAdjustmentStatus.loading) ||
                  (a.status == StockAdjustmentStatus.notFound) !=
                      (b.status == StockAdjustmentStatus.notFound),
              builder: (context, state) => switch (state.status) {
                StockAdjustmentStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                StockAdjustmentStatus.notFound => Center(
                  child: Text(l10n.productNotFound),
                ),
                _ => const _Form(),
              },
            ),
          ),
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
  late final StockAdjustmentCubit _cubit = context.read<StockAdjustmentCubit>();
  late final _qty = TextEditingController(text: _cubit.state.qty);
  late final _note = TextEditingController(text: _cubit.state.note);

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final state = context.watch<StockAdjustmentCubit>().state;
    final gap = SizedBox(height: tokens.spaceMd);

    String? err(AdjustmentError? e) =>
        e == null ? null : context.adjustmentError(e, state.unit);

    final qtyLabel = switch (state.kind) {
      AdjustmentKind.count => l10n.adjustCountedLabel,
      AdjustmentKind.damage => l10n.adjustRemoveLabel,
      AdjustmentKind.other => l10n.adjustQtyLabel,
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: tokens.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.status == StockAdjustmentStatus.failed) ...[
              FormErrorBanner(title: l10n.errorSaveFailed),
              gap,
            ],
            Text(
              l10n.adjustOnHand(
                context.quantity(state.onHandMilli, state.unit),
              ),
              style: theme.textTheme.titleMedium,
            ),
            gap,
            Text(l10n.adjustReasonLabel, style: theme.textTheme.labelLarge),
            SizedBox(height: tokens.spaceXs),
            Wrap(
              spacing: tokens.spaceSm,
              runSpacing: tokens.spaceSm,
              children: [
                for (final kind in AdjustmentKind.values)
                  ChoiceChip(
                    label: Text(adjustmentKindLabel(l10n, kind)),
                    selected: state.kind == kind,
                    onSelected: (_) => _cubit.kindChanged(kind),
                  ),
              ],
            ),
            if (state.kind == AdjustmentKind.other) ...[
              gap,
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                children: [
                  ChoiceChip(
                    label: Text(l10n.adjustAdd),
                    selected: state.add,
                    onSelected: (_) => _cubit.directionChanged(add: true),
                  ),
                  ChoiceChip(
                    label: Text(l10n.adjustRemove),
                    selected: !state.add,
                    onSelected: (_) => _cubit.directionChanged(add: false),
                  ),
                ],
              ),
            ],
            gap,
            QuantityField(
              controller: _qty,
              label: qtyLabel,
              onChanged: _cubit.qtyChanged,
              errorText: err(state.qtyError),
            ),
            gap,
            TextField(
              controller: _note,
              onChanged: _cubit.noteChanged,
              maxLines: null,
              textInputAction: TextInputAction.done,
              inputFormatters: const [CodePointLengthFormatter(maxNoteLength)],
              decoration: InputDecoration(
                labelText: l10n.adjustNoteLabel,
                helperText: state.kind == AdjustmentKind.other
                    ? l10n.adjustNoteRequired
                    : null,
                helperMaxLines: 3,
                errorText: err(state.noteError),
                errorMaxLines: 3,
              ),
            ),
            SizedBox(height: tokens.spaceXl),
            if (state.status == StockAdjustmentStatus.alreadyMatches) ...[
              Text(
                l10n.adjustAlreadyMatches,
                style: theme.textTheme.bodyMedium,
              ),
              gap,
            ],
            SaveButton(
              label: l10n.saveAction,
              savingLabel: l10n.savingLabel,
              saving: state.status == StockAdjustmentStatus.saving,
              onPressed: _cubit.submit,
            ),
          ],
        ),
      ),
    );
  }
}
