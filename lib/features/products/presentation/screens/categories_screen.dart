import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/code_point_length_formatter.dart';
import '../../domain/category.dart';
import '../../domain/product_errors.dart';
import '../cubits/categories_cubit.dart';
import '../widgets/product_error_text.dart';
import '../widgets/unit_label.dart';

/// Add, rename, reorder and archive categories (FR-017, US5).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          if (!state.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = state.categories;
          return SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(bottom: context.tokens.spaceXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AddField(),
                if (list.isEmpty)
                  Padding(
                    padding: context.tokens.pagePadding,
                    child: Text(l10n.categoriesEmpty),
                  ),
                for (final (i, c) in list.indexed)
                  _CategoryRow(
                    category: c,
                    first: i == 0,
                    last: i == list.length - 1,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddField extends StatefulWidget {
  const _AddField();

  @override
  State<_AddField> createState() => _AddFieldState();
}

class _AddFieldState extends State<_AddField> {
  final _name = TextEditingController();
  CategoryError? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final error = await context.read<CategoriesCubit>().create(_name.text);
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
              CodePointLengthFormatter(maxCategoryNameLength),
            ],
            decoration: InputDecoration(
              labelText: l10n.categoryAddHint,
              errorText: _error == null ? null : context.categoryError(_error!),
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.first,
    required this.last,
  });

  final Category category;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cubit = context.read<CategoriesCubit>();
    final c = category;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text(c.name),
          subtitle: Text(
            l10n.categoryProductCount(
              c.productCount,
              context.count(c.productCount),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.spaceSm),
          child: Wrap(
            spacing: tokens.spaceXs,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                tooltip: l10n.categoryMoveUp,
                onPressed: first ? null : () => cubit.moveUp(c.id),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                tooltip: l10n.categoryMoveDown,
                onPressed: last ? null : () => cubit.moveDown(c.id),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n.categoryRename,
                onPressed: () => _rename(context),
              ),
              IconButton(
                icon: const Icon(Icons.archive_outlined),
                tooltip: l10n.categoryArchive,
                onPressed: () => _archive(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Future<void> _rename(BuildContext context) async {
    final cubit = context.read<CategoriesCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => _RenameDialog(cubit: cubit, category: category),
    );
  }

  Future<void> _archive(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CategoriesCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Text(l10n.categoryArchiveConfirm),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.categoryArchive),
          ),
        ],
      ),
    );
    if (ok ?? false) await cubit.archive(category.id);
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.cubit, required this.category});

  final CategoriesCubit cubit;
  final Category category;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.category.name);
  CategoryError? _error;

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
            CodePointLengthFormatter(maxCategoryNameLength),
          ],
          decoration: InputDecoration(
            labelText: l10n.categoryNameLabel,
            errorText: _error == null ? null : context.categoryError(_error!),
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
