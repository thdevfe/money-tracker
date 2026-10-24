import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';

/// Rounded "‹ label ⌄  ↺ ›" bar used for month, day and year navigation.
class PeriodBar extends StatelessWidget {
  final String label;
  final String previousTooltip;
  final String nextTooltip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Opens a picker when the label is tapped; hides the chevron when null.
  final VoidCallback? onPick;

  /// Shown when the period is not the current one.
  final VoidCallback? onToday;

  const PeriodBar({
    super.key,
    required this.label,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.onPrevious,
    required this.onNext,
    this.onPick,
    this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: previousTooltip,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: onPrevious,
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.input),
              onTap: onPick,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onPick != null)
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                ],
              ),
            ),
          ),
          if (onToday != null)
            IconButton(
              tooltip: l10n.goToToday,
              icon: Icon(
                Icons.undo_rounded,
                size: 18,
                color: colors.textSecondary,
              ),
              onPressed: onToday,
            ),
          IconButton(
            tooltip: nextTooltip,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with a year switcher and a 4×3 month grid.
Future<DateTime?> showMonthPicker(BuildContext context, DateTime initial) {
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (context) => _MonthPicker(initial: initial),
  );
}

class _MonthPicker extends StatefulWidget {
  final DateTime initial;

  const _MonthPicker({required this.initial});

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late int _year = widget.initial.year;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.previousYear,
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => setState(() => _year--),
                ),
                Expanded(
                  child: Text(
                    '$_year',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.nextYear,
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => setState(() => _year++),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.8,
              children: [
                for (var m = 1; m <= 12; m++) _monthButton(fmt, scheme, m),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthButton(Formatters fmt, ColorScheme scheme, int month) {
    final selected =
        _year == widget.initial.year && month == widget.initial.month;
    final date = DateTime(_year, month);
    final label = fmt.monthShort(date);
    return selected
        ? FilledButton(
            onPressed: () => Navigator.of(context).pop(date),
            child: Text(label, maxLines: 1),
          )
        : OutlinedButton(
            onPressed: () => Navigator.of(context).pop(date),
            child: Text(label, maxLines: 1),
          );
  }
}
