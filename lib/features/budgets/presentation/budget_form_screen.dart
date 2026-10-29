import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../domain/budget.dart';
import '../providers/budgets_provider.dart';

/// Add or edit a budget: name, monthly limit and the categories it counts
/// (none selected = all spending). [template] prefills a new budget.
class BudgetFormScreen extends ConsumerStatefulWidget {
  final Budget? existing;
  final Budget? template;

  const BudgetFormScreen({super.key, this.existing, this.template});

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  static const _uuid = Uuid();

  late final Budget? _initial = widget.existing ?? widget.template;
  late final _name = TextEditingController(text: _initial?.name);
  final _limit = TextEditingController();
  late final Set<String> _categoryIds = {...?_initial?.categoryIds};
  bool _submitted = false;
  bool _busy = false;

  bool get _isEditing => widget.existing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final limit = _initial?.limitMinor ?? 0;
    if (_limit.text.isEmpty && limit > 0) {
      _limit.text = Formatters.of(context).groupDigits(limit);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    super.dispose();
  }

  int get _limitMinor =>
      int.tryParse(_limit.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (_name.text.trim().isEmpty || _limitMinor <= 0 || _busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(budgetsProvider.notifier)
          .save(
            Budget(
              id: widget.existing?.id ?? _uuid.v4(),
              name: _name.text.trim(),
              limitMinor: _limitMinor,
              categoryIds: _categoryIds.toList(),
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.savedMessage)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBudgetTitle),
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
    if (confirmed != true) return;
    try {
      await ref.read(budgetsProvider.notifier).delete(widget.existing!);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final fmt = Formatters.of(context);
    final categories = ref.watch(
      selectableCategoriesProvider(TransactionType.expense),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.cancel,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_isEditing ? l10n.editBudget : l10n.addBudget),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _busy ? null : _delete,
            ),
          TextButton(
            key: const ValueKey('budget_save'),
            onPressed: _busy ? null : _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            key: const ValueKey('budget_name'),
            controller: _name,
            autofocus: _initial == null,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.budgetName,
              counterText: '',
              errorText: _submitted && _name.text.trim().isEmpty
                  ? l10n.errorNameRequired
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            key: const ValueKey('budget_limit'),
            controller: _limit,
            autofocus: _initial != null && !_isEditing,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
              TextInputFormatter.withFunction((old, value) {
                if (value.text.isEmpty) return value;
                final text = fmt.groupDigits(int.parse(value.text));
                return TextEditingValue(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              }),
            ],
            decoration: InputDecoration(
              labelText: l10n.budgetLimit,
              hintText: '0',
              suffixText: '₫',
              errorText: _submitted && _limitMinor <= 0
                  ? l10n.errorAmountPositive
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.budgetCategories,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: Text(l10n.budgetAllSpending),
                selected: _categoryIds.isEmpty,
                onSelected: (_) => setState(_categoryIds.clear),
              ),
              for (final c in categories)
                FilterChip(
                  avatar: Icon(c.icon, size: 18, color: c.tint),
                  label: Text(c.label(l10n)),
                  selected: _categoryIds.contains(c.id),
                  onSelected: (on) => setState(
                    () =>
                        on ? _categoryIds.add(c.id) : _categoryIds.remove(c.id),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
