import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';

/// Compact one-row summary: tracked balance, month income, month expenses.
/// Kept small so the calendar stays the focus of Home.
class MonthlySummaryCard extends StatelessWidget {
  final int totalBalanceMinor;
  final PeriodTotals monthTotals;

  const MonthlySummaryCard({
    super.key,
    required this.totalBalanceMinor,
    required this.monthTotals,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final colors = AppColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _SummaryItem(
                icon: Icons.account_balance_wallet_rounded,
                label: l10n.summaryBalance,
                value: fmt.money(totalBalanceMinor),
                color: scheme.onSurface,
              ),
              VerticalDivider(color: colors.border, width: AppSpacing.lg),
              _SummaryItem(
                icon: Icons.north_east_rounded,
                label: l10n.summaryIncome,
                value: fmt.signedMoney(
                  TransactionType.income,
                  monthTotals.incomeMinor,
                ),
                color: colors.income,
              ),
              VerticalDivider(color: colors.border, width: AppSpacing.lg),
              _SummaryItem(
                icon: Icons.south_east_rounded,
                label: l10n.summaryExpense,
                value: fmt.signedMoney(
                  TransactionType.expense,
                  monthTotals.expenseMinor,
                ),
                color: colors.expense,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Expanded(
      child: Semantics(
        container: true,
        label: '$label $value',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 2),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
