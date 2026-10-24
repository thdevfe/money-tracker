import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/transaction_thumbnail.dart';

/// Layout constants shared by [PhotoCalendarDayCell] and the calendar.
class DayCellMetrics {
  static const int maxStacked = 2;
  static const double padding = 3;
  static const double border = 1.5;
  static const double dayLabelHeight = 22;

  static double thumbnailSize(double cellWidth) =>
      (cellWidth * 0.62).clamp(22, 36);

  static double stackHeight(double cellWidth) => thumbnailSize(cellWidth) + 10;

  static double cellHeight(double cellWidth) =>
      (padding + border) * 2 + stackHeight(cellWidth) + dayLabelHeight;
}

/// One calendar day: up to two of the day's transactions as a tilted stack
/// (photos first, then category tiles), a "+N" badge for the rest, and the
/// day number underneath. Days outside the month render empty.
class PhotoCalendarDayCell extends StatelessWidget {
  final DateTime date;

  /// Transactions on [date], newest first.
  final List<MoneyTransaction> transactions;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  const PhotoCalendarDayCell({
    super.key,
    required this.date,
    required this.transactions,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.width,
    required this.onTap,
  });

  /// The transactions drawn in the stack: photos first, newest first.
  static List<MoneyTransaction> stacked(List<MoneyTransaction> items) => [
    ...items.where((t) => t.hasPhoto),
    ...items.where((t) => !t.hasPhoto),
  ].take(DayCellMetrics.maxStacked).toList();

  @override
  Widget build(BuildContext context) {
    final height = DayCellMetrics.cellHeight(width);
    if (!inMonth) return SizedBox(width: width, height: height);

    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final shown = stacked(transactions);
    final extra = transactions.length - shown.length;
    final totals = totalsOf(transactions);

    final semantics = StringBuffer(
      l10n.calendarDaySemantics(fmt.fullDate(date), transactions.length),
    );
    if (totals.expenseMinor > 0) {
      semantics.write(
        '. ${l10n.expenseAmountSemantics(fmt.money(totals.expenseMinor))}',
      );
    }
    if (totals.incomeMinor > 0) {
      semantics.write(
        '. ${l10n.incomeAmountSemantics(fmt.money(totals.incomeMinor))}',
      );
    }

    return Semantics(
      button: true,
      selected: isSelected,
      label: semantics.toString(),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          height: height,
          padding: const EdgeInsets.all(DayCellMetrics.padding),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? scheme.primary : Colors.transparent,
              width: DayCellMetrics.border,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: DayCellMetrics.stackHeight(width),
                child: shown.isEmpty
                    ? null
                    : _PhotoStack(
                        items: shown,
                        extra: extra,
                        size: DayCellMetrics.thumbnailSize(width),
                      ),
              ),
              SizedBox(
                height: DayCellMetrics.dayLabelHeight,
                child: Center(
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: isToday
                        ? BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Text(
                      '${date.day}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isToday || isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isToday ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoStack extends StatelessWidget {
  final List<MoneyTransaction> items;
  final int extra;
  final double size;

  const _PhotoStack({
    required this.items,
    required this.extra,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Colors.white;

    Widget card(MoneyTransaction t) {
      final inner = size - DayCellMetrics.border * 2;
      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(DayCellMetrics.border),
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.5),
          child: t.photo == null
              ? CategoryTile(transaction: t, size: inner, radius: 0)
              : PhotoImage(
                  photo: t.photo!,
                  size: inner,
                  fallback: CategoryTile(
                    transaction: t,
                    size: inner,
                    radius: 0,
                  ),
                ),
        ),
      );
    }

    final front = items.first;
    final back = items.length > 1 ? items[1] : null;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (back != null)
          Transform.translate(
            offset: const Offset(-4, -2),
            child: Transform.rotate(angle: -0.16, child: card(back)),
          ),
        Transform.translate(
          offset: back == null ? Offset.zero : const Offset(3, 3),
          child: Transform.rotate(
            angle: back == null ? 0 : 0.06,
            child: card(front),
          ),
        ),
        if (extra > 0)
          Positioned(top: -2, right: -2, child: _ExtraBadge(count: extra)),
      ],
    );
  }
}

class _ExtraBadge extends StatelessWidget {
  final int count;

  const _ExtraBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFF17211D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}
