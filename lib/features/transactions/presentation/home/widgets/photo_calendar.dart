import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';
import 'photo_calendar_day_cell.dart';

/// Seven-column month grid of photo stacks. Swipe horizontally to change
/// month.
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
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final days = monthGridDays(month, firstWeekday: firstWeekdayFor(context));

    return Container(
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card + 4),
      ),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity.abs() < 250) return;
          onMonthOffset(velocity < 0 ? 1 : -1);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
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
                  const SizedBox(height: AppSpacing.xs),
                  for (var w = 0; w < days.length ~/ 7; w++)
                    Row(
                      children: [
                        for (final d in days.sublist(w * 7, w * 7 + 7))
                          PhotoCalendarDayCell(
                            key: ValueKey(d),
                            date: d,
                            transactions: isSameMonth(d, month)
                                ? transactionsByDay[d] ?? const []
                                : const [],
                            inMonth: isSameMonth(d, month),
                            isToday: isSameDay(d, today),
                            isSelected: isSameDay(d, selectedDate),
                            width: cellWidth,
                            onTap: () => onDateSelected(d),
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
