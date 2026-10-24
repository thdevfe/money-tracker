import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';
import 'photo_calendar_day_cell.dart';

/// Seven-column month grid with photo thumbnails and daily totals.
///
/// Each week row is only as tall as its busiest day needs, so quiet weeks stay
/// compact. Swipe horizontally to change month.
class PhotoCalendar extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final DateTime today;
  final Map<DateTime, List<MoneyTransaction>> transactionsByDay;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<int> onMonthOffset;

  const PhotoCalendar({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.today,
    required this.transactionsByDay,
    required this.onDateSelected,
    required this.onMonthOffset,
  });

  /// Monday-first for Vietnamese; otherwise follow the locale.
  static int firstWeekdayFor(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'vi') {
      return DateTime.monday;
    }
    final index = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    return index == 0 ? DateTime.sunday : index;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final days = monthGridDays(month, firstWeekday: firstWeekdayFor(context));

    return Card(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() < 250) return;
          onMonthOffset(velocity < 0 ? 1 : -1);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellWidth = constraints.maxWidth / 7;
              return Column(
                children: [
                  ExcludeSemantics(
                    child: Row(
                      children: [
                        for (final d in days.take(7))
                          SizedBox(
                            width: cellWidth,
                            height: 24,
                            child: Center(
                              child: Text(
                                fmt.weekdayShort(d),
                                maxLines: 1,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (var w = 0; w < days.length ~/ 7; w++)
                    _buildWeek(days.sublist(w * 7, w * 7 + 7), cellWidth),
                  const SizedBox(height: AppSpacing.xs),
                  ExcludeSemantics(
                    child: _Legend(
                      expenseLabel: l10n.calendarLegendExpense,
                      incomeLabel: l10n.calendarLegendIncome,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeek(List<DateTime> week, double cellWidth) {
    List<MoneyTransaction> dayItems(DateTime d) =>
        isSameMonth(d, month) ? transactionsByDay[d] ?? const [] : const [];

    final rows = week.fold<int>(
      0,
      (acc, d) => max(
        acc,
        DayCellMetrics.rowsFor(dayItems(d).where((t) => t.hasPhoto).length),
      ),
    );
    final height = DayCellMetrics.cellHeight(cellWidth, rows);
    return Row(
      children: [
        for (final d in week)
          PhotoCalendarDayCell(
            key: ValueKey(d),
            date: d,
            transactions: dayItems(d),
            inMonth: isSameMonth(d, month),
            isToday: isSameDay(d, today),
            isSelected: isSameDay(d, selectedDate),
            width: cellWidth,
            height: height,
            onTap: () => onDateSelected(d),
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final String expenseLabel;
  final String incomeLabel;

  const _Legend({required this.expenseLabel, required this.incomeLabel});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: colors.textSecondary);
    Widget item(String sign, Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          sign,
          style: style?.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: style),
      ],
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.lg,
      children: [
        item('−', colors.expense, expenseLabel),
        item('+', colors.income, incomeLabel),
      ],
    );
  }
}
