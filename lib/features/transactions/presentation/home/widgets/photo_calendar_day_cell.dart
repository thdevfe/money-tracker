import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../settings/domain/calendar_grid_settings.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/transaction_thumbnail.dart';

/// Layout constants shared by [PhotoCalendarDayCell] and the calendar.
class DayCellMetrics {
  static const double padding = 3;
  static const double border = 1.5;
  static const double dayLabelHeight = 22;

  static double thumbnailSize(double cellWidth) =>
      (cellWidth * 0.62).clamp(22, 36);

  static double stackHeight(double cellWidth) => thumbnailSize(cellWidth) + 10;

  static double cellHeight(double cellWidth) =>
      (padding + border) * 2 + stackHeight(cellWidth) + dayLabelHeight;
}

/// One calendar day: the day's transactions as a single tile, a tilted stack
/// or a fan (photos first, then category tiles), styled by
/// [CalendarGridSettings], an optional "+N" badge for the rest, and the day
/// number underneath. Days outside the month render empty.
class PhotoCalendarDayCell extends StatelessWidget {
  final DateTime date;

  /// Transactions on [date], newest first.
  final List<MoneyTransaction> transactions;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final double width;
  final CalendarGridSettings settings;

  /// Resolved tile border color ([CalendarGridSettings.borderColorKey]).
  final Color borderColor;
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
    this.settings = const CalendarGridSettings(),
    this.borderColor = Colors.white,
  });

  static int visibleCount(GridDisplay display) => switch (display) {
    GridDisplay.single => 1,
    GridDisplay.stacked => 2,
    GridDisplay.fan => 3,
  };

  /// The transactions drawn in the cell: photos first, newest first.
  static List<MoneyTransaction> stacked(
    List<MoneyTransaction> items, {
    GridDisplay display = GridDisplay.stacked,
  }) => [
    ...items.where((t) => t.hasPhoto),
    ...items.where((t) => !t.hasPhoto),
  ].take(visibleCount(display)).toList();

  @override
  Widget build(BuildContext context) {
    final height = DayCellMetrics.cellHeight(width);
    if (!inMonth) return SizedBox(width: width, height: height);

    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final shown = stacked(transactions, display: settings.display);
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
                        extra: settings.showBadge ? extra : 0,
                        size: DayCellMetrics.thumbnailSize(width),
                        settings: settings,
                        borderColor: borderColor,
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
  final CalendarGridSettings settings;
  final Color borderColor;

  const _PhotoStack({
    required this.items,
    required this.extra,
    required this.size,
    required this.settings,
    required this.borderColor,
  });

  double get _borderWidth => switch (settings.border) {
    GridBorder.accent => 1.5,
    GridBorder.thin => 0.75,
    GridBorder.none => 0,
  };

  Widget _card(MoneyTransaction t) {
    final border = _borderWidth;
    final inner = size - border * 2;
    final isCircle = settings.shape == GridShape.circle;
    final radius = settings.shape == GridShape.square ? 2.0 : 8.0;
    final tile = CategoryTile(transaction: t, size: inner, radius: 0);
    final content = t.photo == null
        ? tile
        : PhotoImage(photo: t.photo!, size: inner, fallback: tile);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(border),
      decoration: BoxDecoration(
        color: border == 0 ? Colors.transparent : borderColor,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: isCircle
          ? ClipOval(child: content)
          : ClipRRect(
              borderRadius: BorderRadius.circular(
                (radius - border).clamp(0, radius),
              ),
              child: content,
            ),
    );
  }

  Widget _placed(MoneyTransaction t, Offset offset, double angle) =>
      Transform.translate(
        offset: offset,
        child: Transform.rotate(angle: angle, child: _card(t)),
      );

  @override
  Widget build(BuildContext context) {
    final layers = switch ((settings.display, items.length)) {
      (_, 1) ||
      (GridDisplay.single, _) => [_placed(items.first, Offset.zero, 0)],
      (GridDisplay.fan, 3) => [
        _placed(items[1], const Offset(-6, 1), -0.24),
        _placed(items[2], const Offset(6, 1), 0.24),
        _placed(items.first, const Offset(0, -1), 0),
      ],
      // Stacked, or a fan with only two items.
      _ => [
        _placed(items[1], const Offset(-4, -2), -0.16),
        _placed(items.first, const Offset(3, 3), 0.06),
      ],
    };
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        ...layers,
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
