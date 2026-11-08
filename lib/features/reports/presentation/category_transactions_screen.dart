import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/ledger.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/presentation/home/widgets/month_transaction_list.dart';
import '../../transactions/providers/transactions_provider.dart';

/// One category's transactions in the report's period and account, grouped
/// by day. Follows edits made from here.
class CategoryTransactionsScreen extends ConsumerWidget {
  final Category category;
  final TransactionType type;

  /// The report's period label, e.g. "Tháng 10 năm 2026".
  final String periodLabel;

  /// The report's period and account filter.
  final bool Function(MoneyTransaction) inReport;

  const CategoryTransactionsScreen({
    super.key,
    required this.category,
    required this.type,
    required this.periodLabel,
    required this.inReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final today = dateOnly(ref.watch(clockProvider)());
    final items = ref
        .watch(transactionsProvider)
        .where((t) => t.type == type && t.category == category && inReport(t))
        .toList();
    final total = items.fold<int>(0, (sum, t) => sum + t.amountMinor);
    final byDay = <DateTime, List<MoneyTransaction>>{};
    for (final t in items) {
      byDay.putIfAbsent(dateOnly(t.occurredAt), () => []).add(t);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: category.tint,
                borderRadius: BorderRadius.circular(AppRadii.listThumbnail),
              ),
              child: Icon(category.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    periodLabel,
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
      body: items.isEmpty
          ? Center(
              child: EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: type == TransactionType.expense
                    ? l10n.reportsNoExpenses
                    : l10n.reportsNoIncome,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: category.tint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.resultCount(items.length),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        fmt.signedMoney(type, total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: type == TransactionType.expense
                              ? colors.expense
                              : colors.income,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final day in days) ...[
                  DayTransactionsCard(
                    date: day,
                    today: today,
                    transactions: byDay[day]!,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
    );
  }
}
