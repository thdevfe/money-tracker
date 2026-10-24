import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/ledger.dart';
import '../../../domain/models.dart';
import '../../widgets/transaction_thumbnail.dart';

/// Layout constants shared by [PhotoCalendarDayCell] and the calendar, which
/// sizes each week row from them.
class DayCellMetrics {
  static const int maxThumbnails = 3;
  static const double padding = 3;
  static const double border = 1.5;
  static const double gap = 2;
  static const double dayLabelHeight = 20;
  static const double totalHeight = 14;

  static double thumbnailSize(double cellWidth) =>
      ((cellWidth - (padding + border) * 2 - gap) / 2).clamp(14, 30);

  /// Thumbnail slots (photos plus an optional "+N" tile) for a day.
  static int slotsFor(int photoCount) =>
      photoCount > maxThumbnails ? maxThumbnails + 1 : photoCount;

  static int rowsFor(int photoCount) => (slotsFor(photoCount) / 2).ceil();

  static double cellHeight(double cellWidth, int thumbnailRows) {
    final thumbs = thumbnailRows == 0
        ? 0
        : thumbnailRows * thumbnailSize(cellWidth) + (thumbnailRows - 1) * gap;
    return (padding + border) * 2 + dayLabelHeight + thumbs + gap + totalHeight;
  }
}

class PhotoCalendarDayCell extends StatelessWidget {
  final DateTime date;

  /// Transactions on [date], newest first.
  final List<MoneyTransaction> transactions;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final double width;
  final double height;
  final VoidCallback onTap;

  const PhotoCalendarDayCell({
    super.key,
    required this.date,
    required this.transactions,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);

    final visible = inMonth ? transactions : const <MoneyTransaction>[];
    final totals = totalsOf(visible);
    final photoCount = visible.where((t) => t.hasPhoto).length;
    final thumbnails = dayThumbnails(visible);
    final overflow = photoCount - thumbnails.length;
    final hasTransferOnly =
        visible.isNotEmpty &&
        visible.every((t) => t.type == TransactionType.transfer);

    final semantics = StringBuffer(
      l10n.calendarDaySemantics(fmt.fullDate(date), visible.length),
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

    final thumbSize = DayCellMetrics.thumbnailSize(width);
    final dayText = Text(
      '${date.day}',
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isToday ? scheme.onPrimary : scheme.onSurface,
      ),
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label: semantics.toString(),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: inMonth ? 1 : 0.35,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: width,
            height: height,
            padding: const EdgeInsets.all(DayCellMetrics.padding),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? scheme.primary : Colors.transparent,
                width: DayCellMetrics.border,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: DayCellMetrics.dayLabelHeight,
                  child: Center(
                    child: isToday
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: dayText,
                          )
                        : dayText,
                  ),
                ),
                if (thumbnails.isNotEmpty)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: DayCellMetrics.gap,
                    runSpacing: DayCellMetrics.gap,
                    children: [
                      for (final photo in thumbnails)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadii.thumbnail,
                          ),
                          child: PhotoImage(
                            photo: photo,
                            size: thumbSize,
                            fallback: Container(
                              width: thumbSize,
                              height: thumbSize,
                              color: colors.elevatedSurface,
                            ),
                          ),
                        ),
                      if (overflow > 0)
                        _OverflowTile(count: overflow, size: thumbSize),
                    ],
                  ),
                const Spacer(),
                SizedBox(
                  height: DayCellMetrics.totalHeight,
                  child: _DayTotal(
                    totals: totals,
                    hasTransferOnly: hasTransferOnly,
                    fmt: fmt,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverflowTile extends StatelessWidget {
  final int count;
  final double size;

  const _OverflowTile({required this.count, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.of(context).elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.thumbnail),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '+$count',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Daily expense total ("−165k"). Income-only days show "+8tr" in the income
/// color instead, so they are never mistaken for spending.
class _DayTotal extends StatelessWidget {
  final PeriodTotals totals;
  final bool hasTransferOnly;
  final Formatters fmt;

  const _DayTotal({
    required this.totals,
    required this.hasTransferOnly,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    if (totals.expenseMinor > 0) {
      return _fit(
        fmt.compactSigned(TransactionType.expense, totals.expenseMinor),
        style?.copyWith(color: colors.expense),
      );
    }
    if (totals.incomeMinor > 0) {
      return _fit(
        fmt.compactSigned(TransactionType.income, totals.incomeMinor),
        style?.copyWith(color: colors.income),
      );
    }
    if (hasTransferOnly) {
      return Icon(Icons.swap_horiz_rounded, size: 12, color: colors.transfer);
    }
    return const SizedBox.shrink();
  }

  Widget _fit(String text, TextStyle? style) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(text, maxLines: 1, style: style),
  );
}
