import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/navigation.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models.dart';
import '../../../providers/transactions_provider.dart';
import '../../category_presentation.dart';

/// "Choose category" sheet. With [allowTypeSwitch], expense / income tabs
/// let the user pick from the other type too (the caller switches type).
Future<Category?> showCategoryPicker(
  BuildContext context, {
  required TransactionType type,
  required Category? selected,
  bool allowTypeSwitch = false,
}) {
  final l10n = AppLocalizations.of(context);
  final parentContext = context;
  var sheetType = type;
  return showModalBottomSheet<Category>(
    context: context,
    showDragHandle: true,
    // Scrolls when custom categories make the grid taller than the sheet.
    isScrollControlled: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.75,
    ),
    builder: (context) => StatefulBuilder(
      builder: (context, setSheetState) {
        final options = ProviderScope.containerOf(
          context,
        ).read(selectableCategoriesProvider(sheetType));
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.chooseCategory,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (allowTypeSwitch) ...[
                  const SizedBox(height: AppSpacing.md),
                  SegmentedButton<TransactionType>(
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
                    selected: {sheetType},
                    onSelectionChanged: (s) =>
                        setSheetState(() => sheetType = s.first),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.82,
                  children: [
                    for (final c in options)
                      CategoryOption(
                        category: c,
                        selected: c == selected,
                        onTap: () => Navigator.of(context).pop(c),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    openCategories(parentContext, type: sheetType);
                  },
                  icon: const Icon(Icons.tune_rounded),
                  label: Text(l10n.manageCategories),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Round category icon with its label; highlighted when selected.
class CategoryOption extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryOption({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.card),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: category.tint,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: selected
                  ? Border.all(color: theme.colorScheme.onSurface, width: 2.5)
                  : null,
            ),
            child: Icon(category.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            category.label(l10n),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
