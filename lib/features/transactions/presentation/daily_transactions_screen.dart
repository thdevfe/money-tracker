import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/ledger.dart';
import '../domain/models.dart';
import '../providers/transactions_provider.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/transaction_list_item.dart';

class DailyTransactionsScreen extends ConsumerStatefulWidget {
  final DateTime date;

  const DailyTransactionsScreen({super.key, required this.date});

  @override
  ConsumerState<DailyTransactionsScreen> createState() =>
      _DailyTransactionsScreenState();
}

class _DailyTransactionsScreenState
    extends ConsumerState<DailyTransactionsScreen> {
  TransactionFilter _filter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final all = ref.watch(dayTransactionsProvider(widget.date));
    final visible = all.where(_filter.matches).toList();
    final totals = totalsOf(all);

    Widget totalTile(String label, String value, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fmt.fullDate(widget.date),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: all.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => openAddTransaction(context, date: widget.date),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addTransaction),
            ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    totalTile(
                      l10n.dayExpenseLabel,
                      fmt.signedMoney(
                        TransactionType.expense,
                        totals.expenseMinor,
                      ),
                      colors.expense,
                    ),
                    if (totals.incomeMinor > 0)
                      totalTile(
                        l10n.dayIncomeLabel,
                        fmt.signedMoney(
                          TransactionType.income,
                          totals.incomeMinor,
                        ),
                        colors.income,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (all.isEmpty)
            EmptyStateView(
              icon: Icons.photo_camera_back_outlined,
              title: l10n.dayEmptyTitle,
              message: l10n.dayEmptyMessage,
              actionLabel: l10n.addTransaction,
              onAction: () => openAddTransaction(context, date: widget.date),
            )
          else ...[
            TransactionFilterBar(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
            const SizedBox(height: AppSpacing.md),
            if (visible.isEmpty)
              EmptyStateView(
                compact: true,
                icon: Icons.filter_alt_off_outlined,
                title: l10n.filterEmptyTitle,
                message: l10n.filterEmptyMessage,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (final t in visible)
                        TransactionListItem(
                          transaction: t,
                          onTap: () => openEditTransaction(context, t),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
