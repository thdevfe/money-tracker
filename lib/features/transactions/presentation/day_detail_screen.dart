import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/ledger.dart';
import '../providers/transactions_provider.dart';
import 'home/widgets/day_photo_grid.dart';

/// A calendar day opened from Home: the date, the day's spending and its
/// transactions as photo tiles. Tiles open the swipeable viewer.
class DayDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DayDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    // Same account filter as the calendar it was opened from.
    final items =
        ref.watch(homeTransactionsByDayProvider)[dateOnly(date)] ?? const [];
    final totals = totalsOf(items);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addTransaction,
        onPressed: () => openAddTransaction(context, date: date),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      fmt.fullDate(date),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Balances the close button so the title stays centered.
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (totals.expenseMinor > 0 || totals.incomeMinor > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (totals.expenseMinor > 0) ...[
                    Icon(
                      Icons.north_east_rounded,
                      size: 16,
                      color: colors.expense,
                    ),
                    Text(
                      fmt.money(totals.expenseMinor),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (totals.incomeMinor > 0) ...[
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.south_west_rounded,
                      size: 16,
                      color: colors.income,
                    ),
                    Text(
                      fmt.money(totals.incomeMinor),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colors.income,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: EmptyStateView(
                        icon: Icons.photo_camera_back_outlined,
                        title: l10n.dayEmptyTitle,
                        message: l10n.dayEmptyMessage,
                        actionLabel: l10n.addTransaction,
                        onAction: () => openAddTransaction(context, date: date),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm,
                        0,
                        AppSpacing.sm,
                        96,
                      ),
                      child: DayPhotoGrid(
                        transactions: items,
                        onTap: (t) => openTransactionViewer(
                          context,
                          items,
                          items.indexOf(t),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
