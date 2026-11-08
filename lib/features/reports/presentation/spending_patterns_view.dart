import 'package:flutter/material.dart';

import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../domain/spending_patterns.dart';

/// The report's "Cluster" tab: when spending happens (weekday × time of
/// day) and the expenses that repeat.
class SpendingPatternsView extends StatefulWidget {
  final List<MoneyTransaction> transactions;

  const SpendingPatternsView({super.key, required this.transactions});

  @override
  State<SpendingPatternsView> createState() => _SpendingPatternsViewState();
}

class _SpendingPatternsViewState extends State<SpendingPatternsView> {
  /// The tapped heatmap cell (weekday index, slot).
  (int, DaySlot)? _picked;

  static String slotLabel(AppLocalizations l10n, DaySlot slot) =>
      switch (slot) {
        DaySlot.night => l10n.slotNight,
        DaySlot.morning => l10n.slotMorning,
        DaySlot.noon => l10n.slotNoon,
        DaySlot.afternoon => l10n.slotAfternoon,
        DaySlot.evening => l10n.slotEvening,
        DaySlot.late => l10n.slotLate,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final heatmap = SpendingHeatmap.of(widget.transactions);
    final clusters = repeatedSpending(widget.transactions).take(8).toList();

    if (heatmap.isEmpty) {
      return EmptyStateView(
        icon: Icons.bubble_chart_outlined,
        title: l10n.noPatterns,
        message: l10n.noPatternsMessage,
      );
    }

    // Monday-based week, labelled in the user's language.
    final monday = DateTime(2024, 1, 1);
    String weekday(int row) =>
        fmt.weekdayShort(monday.add(Duration(days: row)));
    final focus = _picked ?? heatmap.peak!;
    final (row, slot) = focus;

    Widget card({required Widget child}) => Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: child,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.whenYouSpend,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _picked == null
                    ? l10n.peakSpending(slotLabel(l10n, slot), weekday(row))
                    : l10n.heatCell(
                        weekday(row),
                        slotLabel(l10n, slot),
                        fmt.money(heatmap.amounts[row][slot.index]),
                        heatmap.counts[row][slot.index],
                      ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const SizedBox(width: 36),
                  for (final s in DaySlot.values)
                    Expanded(
                      child: Text(
                        slotLabel(l10n, s),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              for (var r = 0; r < 7; r++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          weekday(r),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      for (final s in DaySlot.values)
                        Expanded(
                          child: _HeatCell(
                            key: ValueKey('heat_${r}_${s.name}'),
                            intensity:
                                heatmap.amounts[r][s.index] / heatmap.max,
                            selected: r == row && s == slot,
                            color: colors.expense,
                            empty: colors.border,
                            onTap: () => setState(() => _picked = (r, s)),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.repeatedSpending,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (clusters.isEmpty)
                Text(
                  l10n.noRepeats,
                  style: TextStyle(color: colors.textSecondary),
                )
              else
                for (final c in clusters)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c.category.tint,
                            borderRadius: BorderRadius.circular(
                              AppRadii.listThumbnail,
                            ),
                          ),
                          child: Icon(
                            c.category.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.note ?? c.category.label(l10n),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                l10n.repeatSummary(
                                  c.count,
                                  fmt.money(c.averageMinor),
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          fmt.money(c.totalMinor),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeatCell extends StatelessWidget {
  final double intensity;
  final bool selected;
  final Color color;
  final Color empty;
  final VoidCallback onTap;

  const _HeatCell({
    super.key,
    required this.intensity,
    required this.selected,
    required this.color,
    required this.empty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 26,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: intensity == 0
              ? empty.withValues(alpha: 0.6)
              : color.withValues(alpha: 0.18 + 0.82 * intensity),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
