import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models.dart';

/// Expense and income cards for the visible day or month.
/// Tapping a card filters Home to that type; tapping it again clears it.
class PeriodTotalCards extends StatelessWidget {
  final int expenseMinor;
  final int incomeMinor;

  /// The active filter, if any.
  final TransactionType? selected;
  final ValueChanged<TransactionType?> onSelected;

  const PeriodTotalCards({
    super.key,
    required this.expenseMinor,
    required this.incomeMinor,
    required this.selected,
    required this.onSelected,
  });

  void _toggle(TransactionType type) =>
      onSelected(selected == type ? null : type);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: _TotalCard(
            key: const ValueKey('total_expense'),
            icon: Icons.north_east_rounded,
            color: colors.expense,
            label: l10n.expenseShort,
            amountMinor: expenseMinor,
            selected: selected == TransactionType.expense,
            dimmed: selected == TransactionType.income,
            onTap: () => _toggle(TransactionType.expense),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _TotalCard(
            key: const ValueKey('total_income'),
            icon: Icons.south_west_rounded,
            color: colors.income,
            label: l10n.incomeShort,
            amountMinor: incomeMinor,
            selected: selected == TransactionType.income,
            dimmed: selected == TransactionType.expense,
            onTap: () => _toggle(TransactionType.income),
          ),
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int amountMinor;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  const _TotalCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.amountMinor,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: dimmed ? 0.5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.16)
                  : colors.elevatedSurface,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(
                color: selected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: color,
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          fmt.money(amountMinor),
                          maxLines: 1,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
