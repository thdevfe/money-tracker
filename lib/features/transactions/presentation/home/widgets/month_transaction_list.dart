import 'package:flutter/material.dart';

import '../../../../../app/navigation.dart';
import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';
import '../../widgets/transaction_list_item.dart';

/// The month's transactions grouped by day, newest day first.
class MonthTransactionList extends StatelessWidget {
  final DateTime month;
  final DateTime today;
  final Map<DateTime, List<MoneyTransaction>> transactionsByDay;

  const MonthTransactionList({
    super.key,
    required this.month,
    required this.today,
    required this.transactionsByDay,
  });

  @override
  Widget build(BuildContext context) {
    final days =
        transactionsByDay.keys
            .where(
              (d) => isSameMonth(d, month) && transactionsByDay[d]!.isNotEmpty,
            )
            .toList()
          ..sort((a, b) => b.compareTo(a));
    return Column(
      children: [
        for (final day in days) ...[
          DayTransactionsCard(
            date: day,
            today: today,
            transactions: transactionsByDay[day]!,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

/// A day heading with its net total and every transaction of the day.
class DayTransactionsCard extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final List<MoneyTransaction> transactions;

  const DayTransactionsCard({
    super.key,
    required this.date,
    required this.today,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final totals = totalsOf(transactions);
    final net = totals.incomeMinor - totals.expenseMinor;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fmt.dayHeading(date, today),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  fmt.signedMoney(
                    net < 0 ? TransactionType.expense : TransactionType.income,
                    net.abs(),
                  ),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: net < 0 ? colors.expense : colors.income,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          for (final t in transactions)
            TransactionListItem(
              transaction: t,
              onTap: () => openEditTransaction(context, t),
            ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
