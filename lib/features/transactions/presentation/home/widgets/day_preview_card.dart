import 'package:flutter/material.dart';

import '../../../../../app/navigation.dart';
import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/empty_state_view.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';
import '../../widgets/transaction_list_item.dart';

/// Selected-day summary under the calendar with the first few transactions.
class DayPreviewCard extends StatelessWidget {
  static const maxRows = 3;

  final DateTime date;
  final DateTime today;

  /// Transactions on [date], newest first.
  final List<MoneyTransaction> transactions;

  const DayPreviewCard({
    super.key,
    required this.date,
    required this.today,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final totals = totalsOf(transactions);
    final hidden = transactions.length - maxRows;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fmt.dayHeading(date, today),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${l10n.dayExpenseLabel} '),
                            TextSpan(
                              text: fmt.money(totals.expenseMinor),
                              style: TextStyle(
                                color: totals.expenseMinor > 0
                                    ? colors.expense
                                    : null,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (totals.incomeMinor > 0) ...[
                              TextSpan(text: '  ·  ${l10n.dayIncomeLabel} '),
                              TextSpan(
                                text: fmt.money(totals.incomeMinor),
                                style: TextStyle(
                                  color: colors.income,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (transactions.isNotEmpty)
                  TextButton(
                    onPressed: () => openDailyTransactions(context, date),
                    child: Text(l10n.viewAll),
                  ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            EmptyStateView(
              compact: true,
              icon: Icons.photo_camera_back_outlined,
              title: l10n.dayEmptyTitle,
              message: l10n.dayEmptyMessage,
              actionLabel: l10n.addTransaction,
              onAction: () => openAddTransaction(context, date: date),
            )
          else ...[
            for (final t in transactions.take(maxRows))
              TransactionListItem(
                transaction: t,
                onTap: () => openEditTransaction(context, t),
              ),
            if (hidden > 0)
              InkWell(
                onTap: () => openDailyTransactions(context, date),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    l10n.moreTransactions(hidden),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
