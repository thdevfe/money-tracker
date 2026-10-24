import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/providers/transactions_provider.dart';
import 'category_form_screen.dart';

/// Built-in categories (read-only) and the user's own, with archived ones in
/// their own section.
class CategoriesScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;

  const CategoriesScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  late TransactionType _type = widget.initialType == TransactionType.income
      ? TransactionType.income
      : TransactionType.expense;

  void _open([Category? category]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryFormScreen(type: _type, existing: category),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final custom =
        ref
            .watch(ledgerProvider.select((s) => s.customCategories))
            .where((c) => c.type == _type)
            .toList()
          ..sort(
            (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()),
          );
    final active = custom.where((c) => !c.isArchived).toList();
    final archived = custom.where((c) => c.isArchived).toList();

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    Widget group(List<Widget> tiles) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(children: tiles),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoriesTitle),
        actions: [
          IconButton(
            tooltip: l10n.addCategory,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _open(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: SegmentedButton<TransactionType>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(l10n.typeExpense),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(l10n.typeIncome),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
          ),
          if (active.isNotEmpty) ...[
            header(l10n.categoriesTitle),
            group([
              for (final c in active)
                _CategoryTile(category: c, onTap: () => _open(c)),
            ]),
          ],
          header(l10n.builtInBadge),
          group([
            for (final c in Category.systemFor(_type))
              _CategoryTile(
                category: c,
                trailing: Text(
                  l10n.builtInBadge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                onTap: () => ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.builtInReadOnly))),
              ),
          ]),
          if (archived.isNotEmpty) ...[
            header(l10n.archivedSection),
            group([
              for (final c in archived)
                _CategoryTile(category: c, dimmed: true, onTap: () => _open(c)),
            ]),
          ],
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => _open(),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addCategory),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool dimmed;

  const _CategoryTile({
    required this.category,
    required this.onTap,
    this.trailing,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: ListTile(
        minTileHeight: 56,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: category.tint,
            borderRadius: BorderRadius.circular(AppRadii.listThumbnail),
          ),
          child: Icon(category.icon, color: Colors.white, size: 20),
        ),
        title: Text(
          category.label(l10n),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
