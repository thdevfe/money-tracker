import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';

/// One bar per day of [month] with that day's spending. Tap a bar to
/// select the day.
class MonthBarChart extends StatelessWidget {
  static const double _chartHeight = 160;

  final DateTime month;
  final DateTime selectedDate;
  final DateTime today;
  final Map<DateTime, List<MoneyTransaction>> transactionsByDay;
  final ValueChanged<DateTime> onDateSelected;

  const MonthBarChart({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.today,
    required this.transactionsByDay,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    final days = [
      for (var d = 1; d <= dayCount; d++) DateTime(month.year, month.month, d),
    ];
    final spent = [
      for (final d in days)
        totalsOf(transactionsByDay[d] ?? const []).expenseMinor,
    ];
    final peak = spent.fold<int>(0, (m, v) => v > m ? v : m);
    final selectedSpent = isSameMonth(selectedDate, month)
        ? spent[selectedDate.day - 1]
        : 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card + 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.dailySpending,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  '${fmt.dayMonth(selectedDate)} · ${fmt.money(selectedSpent)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: _chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: isSameDay(days[i], selectedDate),
                      label: '${fmt.dayMonth(days[i])}: ${fmt.money(spent[i])}',
                      excludeSemantics: true,
                      child: GestureDetector(
                        key: ValueKey('bar_${days[i].day}'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onDateSelected(days[i]),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            height: peak == 0
                                ? 3
                                : 3 + (_chartHeight - 3) * spent[i] / peak,
                            decoration: BoxDecoration(
                              color: isSameDay(days[i], selectedDate)
                                  ? colors.expense
                                  : spent[i] == 0
                                  ? colors.border
                                  : colors.expense.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Day numbers every 5 days keep the axis readable.
          Row(
            children: [
              for (final d in days)
                Expanded(
                  child: Text(
                    d.day == 1 || d.day % 5 == 0 ? '${d.day}' : '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSameDay(d, today)
                          ? theme.colorScheme.primary
                          : colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
