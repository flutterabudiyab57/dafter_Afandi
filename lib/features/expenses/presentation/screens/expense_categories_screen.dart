import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/list_load_state.dart';
import '../../../../core/widgets/status_banner.dart';
import '../../domain/expense.dart';
import '../../domain/expense_errors.dart';
import '../cubits/expense_categories_cubit.dart';
import '../widgets/expense_text.dart';

/// Add, rename, archive and restore expense categories (US3-6, US3-7).
class ExpenseCategoriesScreen extends StatefulWidget {
  const ExpenseCategoriesScreen({super.key});

  @override
  State<ExpenseCategoriesScreen> createState() =>
      _ExpenseCategoriesScreenState();
}

class _ExpenseCategoriesScreenState extends State<ExpenseCategoriesScreen> {
  bool _defaultsAsked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // In the shop's language at this moment (research R13).
    if (!_defaultsAsked) {
      _defaultsAsked = true;
      context.read<ExpenseCategoriesCubit>().ensureDefaults(
        context.defaultExpenseCategoryNames,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final cubit = context.read<ExpenseCategoriesCubit>();
    final state = context.watch<ExpenseCategoriesCubit>().state;
    final loadState = listLoadState(
      context,
      loadFailed: state.loadFailed,
      loading: !state.loaded,
      empty: state.active.isEmpty,
      onRetry: cubit.retry,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.expenseCategoriesTitle)),
      body:
          loadState ??
          SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(bottom: tokens.spaceXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AddField(),
                if (state.active.isEmpty)
                  Padding(
                    padding: tokens.pagePadding,
                    child: Text(l10n.expenseCategoriesEmpty),
                  ),
                for (final c in state.active) _ActiveRow(category: c),
                if (state.archived.isNotEmpty) ...[
                  Padding(
                    padding: tokens.pagePadding,
                    child: Text(
                      l10n.expenseCategoriesArchived,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  for (final c in state.archived) ...[
                    ListTile(title: Text(c.name)),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: tokens.spaceSm,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          icon: const Icon(Icons.unarchive_outlined),
                          label: Text(l10n.expenseCategoryRestore),
                          onPressed: () => _restore(context, c),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                ],
              ],
            ),
          ),
    );
  }

  Future<void> _restore(BuildContext context, ExpenseCategory c) async {
    final error = await context.read<ExpenseCategoriesCubit>().restore(c.id);
    if (error != null && context.mounted) {
      showAppSnackBar(
        context,
        context.expenseCategoryError(error),
        tone: StatusTone.error,
      );
    }
  }
}

class _AddField extends StatefulWidget {
  const _AddField();

  @override
  State<_AddField> createState() => _AddFieldState();
}

class _AddFieldState extends State<_AddField> {
  final _name = TextEditingController();
  ExpenseCategoryError? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final error = await context.read<ExpenseCategoriesCubit>().create(
      _name.text,
    );
    if (!mounted) return;
    setState(() => _error = error);
    if (error == null) _name.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return Padding(
      padding: tokens.pagePadding,
      child: Wrap(
        spacing: tokens.spaceSm,
        runSpacing: tokens.spaceSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextField(
            controller: _name,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _add(),
            textInputAction: TextInputAction.done,
            inputFormatters: const [
              CodePointLengthFormatter(maxExpenseCategoryNameLength),
            ],
            decoration: InputDecoration(
              labelText: l10n.categoryAddHint,
              errorText: _error == null
                  ? null
                  : context.expenseCategoryError(_error!),
              errorMaxLines: 3,
            ),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.categoryAddAction),
            onPressed: _add,
          ),
        ],
      ),
    );
  }
}

class _ActiveRow extends StatelessWidget {
  const _ActiveRow({required this.category});

  final ExpenseCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ExpenseCategoriesCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(title: Text(category.name)),
        // Below the name, not as its trailing, so they fit at any text size.
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: context.tokens.spaceSm,
          ),
          child: Wrap(
            spacing: context.tokens.spaceXs,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.categoryRename,
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      _RenameDialog(cubit: cubit, category: category),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                tooltip: l10n.expenseCategoryArchive,
                onPressed: () => _archive(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _archive(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ExpenseCategoriesCubit>();
    final ok = await showConfirmDialog(
      context,
      tone: StatusTone.warning,
      title: null,
      message: l10n.expenseCategoryArchiveConfirm,
      confirmLabel: l10n.expenseCategoryArchive,
      cancelLabel: l10n.cancelAction,
    );
    if (ok ?? false) await cubit.archive(category.id);
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.cubit, required this.category});

  final ExpenseCategoriesCubit cubit;
  final ExpenseCategory category;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.category.name);
  ExpenseCategoryError? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = await widget.cubit.rename(widget.category.id, _name.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.categoryRename),
      content: SingleChildScrollView(
        child: TextField(
          controller: _name,
          autofocus: true,
          onSubmitted: (_) => _save(),
          inputFormatters: const [
            CodePointLengthFormatter(maxExpenseCategoryNameLength),
          ],
          decoration: InputDecoration(
            labelText: l10n.categoryNameLabel,
            errorText: _error == null
                ? null
                : context.expenseCategoryError(_error!),
            errorMaxLines: 3,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelAction),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.saveAction)),
      ],
    );
  }
}
