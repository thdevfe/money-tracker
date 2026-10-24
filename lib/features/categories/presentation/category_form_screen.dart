import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/ledger_repository.dart';
import '../../transactions/domain/ledger_rules.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/providers/transactions_provider.dart';

/// Create or edit a custom category: name, icon and color. Existing ones can
/// be archived/restored, or deleted when no transaction uses them.
class CategoryFormScreen extends ConsumerStatefulWidget {
  final TransactionType type;
  final Category? existing;

  const CategoryFormScreen({super.key, required this.type, this.existing});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  static const _uuid = Uuid();

  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late String _iconKey = widget.existing?.iconKey ?? 'other';
  late String _colorKey = widget.existing?.colorKey ?? 'slate';
  bool _submitted = false;
  bool _busy = false;
  bool _duplicate = false;

  bool get _isEditing => widget.existing != null;

  TransactionType get _type => widget.existing?.type ?? widget.type;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  NameError? get _nameError {
    if (_duplicate) return NameError.duplicate;
    return validateCategoryName(
      _name.text,
      type: _type,
      existing: ref.read(ledgerProvider).customCategories,
      editingId: widget.existing?.id,
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) Navigator.of(context).pop();
    } on LedgerException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _duplicate = e.failure == LedgerFailure.duplicate;
      });
      if (e.failure == LedgerFailure.inUse) {
        await _explainInUse();
      } else if (e.failure == LedgerFailure.unavailable) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    }
  }

  Future<void> _save() async {
    setState(() {
      _submitted = true;
      _duplicate = false;
    });
    if (_nameError != null || _busy) return;
    final notifier = ref.read(ledgerProvider.notifier);
    final existing = widget.existing;
    final category = existing == null
        ? Category.custom(
            id: _uuid.v4(),
            type: _type,
            name: _name.text.trim(),
            iconKey: _iconKey,
            colorKey: _colorKey,
          )
        : existing.copyWith(
            name: _name.text.trim(),
            iconKey: _iconKey,
            colorKey: _colorKey,
          );
    await _run(() => notifier.saveCategory(category));
  }

  Future<void> _toggleArchive() async {
    final existing = widget.existing!;
    await _run(
      () => ref
          .read(ledgerProvider.notifier)
          .saveCategory(existing.copyWith(isArchived: !existing.isArchived)),
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => ref.read(ledgerProvider.notifier).deleteCategory(widget.existing!),
    );
  }

  /// Used categories can't be deleted; offer archiving instead.
  Future<void> _explainInUse() async {
    final l10n = AppLocalizations.of(context);
    final archive = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.categoryInUseMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          if (!widget.existing!.isArchived)
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.archiveAction),
            ),
        ],
      ),
    );
    if (archive == true && mounted) await _toggleArchive();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final nameError = _submitted
        ? switch (_nameError) {
            NameError.empty => l10n.errorNameRequired,
            NameError.tooLong => l10n.errorNameTooLong,
            NameError.duplicate => l10n.errorNameDuplicate,
            null => null,
          }
        : null;
    final tint = categoryColorChoices[_colorKey]!;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.cancel,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? l10n.editCategory : l10n.addCategory),
        actions: [
          TextButton(onPressed: _busy ? null : _save, child: Text(l10n.save)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(AppRadii.card + 4),
              ),
              child: Icon(
                categoryIconChoices[_iconKey],
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _name,
            autofocus: !_isEditing,
            maxLength: maxCategoryNameLength,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() => _duplicate = false),
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              labelText: l10n.categoryNameLabel,
              errorText: nameError,
              counterText: '',
            ),
          ),
          label(l10n.colorLabel),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final entry in categoryColorChoices.entries)
                Semantics(
                  button: true,
                  selected: entry.key == _colorKey,
                  label: entry.key,
                  child: GestureDetector(
                    onTap: () => setState(() => _colorKey = entry.key),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: entry.key == _colorKey
                              ? theme.colorScheme.onSurface
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          label(l10n.iconLabel),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final entry in categoryIconChoices.entries)
                Semantics(
                  button: true,
                  selected: entry.key == _iconKey,
                  label: entry.key,
                  child: GestureDetector(
                    onTap: () => setState(() => _iconKey = entry.key),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: entry.key == _iconKey
                            ? tint
                            : colors.elevatedSurface,
                        borderRadius: BorderRadius.circular(
                          AppRadii.listThumbnail,
                        ),
                      ),
                      child: Icon(
                        entry.value,
                        color: entry.key == _iconKey
                            ? Colors.white
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (_isEditing) ...[
            const SizedBox(height: AppSpacing.xxl),
            OutlinedButton.icon(
              onPressed: _busy ? null : _toggleArchive,
              icon: Icon(
                widget.existing!.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              label: Text(
                widget.existing!.isArchived
                    ? l10n.restoreAction
                    : l10n.archiveAction,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.delete),
            ),
          ],
        ],
      ),
    );
  }
}
