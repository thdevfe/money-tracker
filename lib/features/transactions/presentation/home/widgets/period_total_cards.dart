import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';

/// Expense and income cards for the visible day or month.
class PeriodTotalCards extends StatelessWidget {
  final int expenseMinor;
  final int incomeMinor;

  const PeriodTotalCards({
    super.key,
    required this.expenseMinor,
    required this.incomeMinor,
  });

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

  const _TotalCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.amountMinor,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card),
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
    );
  }
}
