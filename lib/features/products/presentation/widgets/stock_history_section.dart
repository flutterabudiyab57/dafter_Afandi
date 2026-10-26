import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/quantity.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../domain/stock_entry.dart';
import '../cubits/product_details_cubit.dart';
import '../cubits/stock_history_cubit.dart';
import 'history_labels.dart';
import 'unit_label.dart';

/// A product's permanent stock history, newest first (FR-016). Rows have no
/// edit or delete. The list reloads whenever the product changes, so a new
/// adjustment shows on return.
class StockHistorySection extends StatelessWidget {
  const StockHistorySection({required this.unit, super.key});

  final UnitType unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return BlocListener<ProductDetailsCubit, ProductDetailsState>(
      listenWhen: (a, b) => a.summary != b.summary,
      listener: (context, _) => context.read<StockHistoryCubit>().load(),
      child: BlocBuilder<StockHistoryCubit, StockHistoryState>(
        builder: (context, state) {
          final loadState = listLoadState(
            context,
            loadFailed: state.loadFailed,
            loading: state.loading,
            empty: state.entries.isEmpty,
            onRetry: context.read<StockHistoryCubit>().load,
          );
          if (loadState != null) return loadState;
          if (state.entries.isEmpty) {
            return Padding(
              padding: EdgeInsetsDirectional.all(tokens.spaceMd),
              child: Text(l10n.historyEmpty),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final e in state.entries) _EntryRow(entry: e, unit: unit),
              if (state.hasMore)
                Padding(
                  padding: EdgeInsetsDirectional.all(tokens.spaceSm),
                  child: OutlinedButton(
                    onPressed: state.loading
                        ? null
                        : context.read<StockHistoryCubit>().loadMore,
                    child: Text(l10n.historyShowMore),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.unit});

  final StockEntry entry;
  final UnitType unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final reason = entry.reason;
    final title = reason == null
        ? stockEntryLabel(l10n, entry.type)
        : '${stockEntryLabel(l10n, entry.type)} · '
              '${adjustmentKindLabel(l10n, reason)}';
    final delta = entry.qtyDeltaMilli;
    final note = entry.note;

    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.dateTime(entry.at)),
          if (note != null && note.isNotEmpty) Text(note),
        ],
      ),
      trailing: Text(
        context.signedQuantity(delta, unit),
        style: theme.textTheme.titleSmall?.copyWith(
          color: delta < 0 ? theme.colorScheme.error : null,
        ),
      ),
    );
  }
}
