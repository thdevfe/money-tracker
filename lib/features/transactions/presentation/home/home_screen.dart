import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/settings_screen.dart';
import '../../domain/ledger.dart';
import '../../providers/transactions_provider.dart';
import 'widgets/day_preview_card.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/photo_calendar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  /// Moves the visible month and keeps a sensible day selected: today when it
  /// is in that month, otherwise the 1st.
  static void changeMonth(WidgetRef ref, DateTime month) {
    final target = monthStart(month);
    final today = dateOnly(ref.read(clockProvider)());
    ref.read(selectedMonthProvider.notifier).state = target;
    ref.read(selectedDateProvider.notifier).state = isSameMonth(today, target)
        ? today
        : target;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final month = ref.watch(selectedMonthProvider);
    final selected = ref.watch(selectedDateProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    final byDay = ref.watch(transactionsByDayProvider);
    final monthTotals = ref.watch(monthTotalsProvider);
    final monthIsEmpty = !byDay.keys.any((day) => isSameMonth(day, month));

    void shift(int delta) =>
        changeMonth(ref, DateTime(month.year, month.month + delta));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.xs,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.previousMonth,
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () => shift(-1),
            ),
            Flexible(
              child: Text(
                fmt.monthYear(month),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              tooltip: l10n.nextMonth,
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () => shift(1),
            ),
          ],
        ),
        actions: [
          if (!isSameMonth(month, today))
            TextButton(
              onPressed: () => changeMonth(ref, today),
              child: Text(l10n.goToToday),
            ),
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          MonthlySummaryCard(
            totalBalanceMinor: ref.watch(totalBalanceProvider),
            monthTotals: monthTotals,
          ),
          const SizedBox(height: AppSpacing.md),
          PhotoCalendar(
            month: month,
            selectedDate: selected,
            today: today,
            transactionsByDay: byDay,
            onMonthOffset: shift,
            onDateSelected: (date) {
              if (!isSameMonth(date, month)) {
                ref.read(selectedMonthProvider.notifier).state = monthStart(
                  date,
                );
              }
              ref.read(selectedDateProvider.notifier).state = date;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          if (monthIsEmpty)
            Card(
              child: EmptyStateView(
                compact: true,
                icon: Icons.calendar_month_outlined,
                title: l10n.monthEmptyTitle,
                message: l10n.monthEmptyMessage,
              ),
            )
          else
            DayPreviewCard(
              date: selected,
              today: today,
              transactions: byDay[selected] ?? const [],
            ),
        ],
      ),
    );
  }
}
