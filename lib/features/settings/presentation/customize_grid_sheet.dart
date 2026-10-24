import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/calendar_grid_settings.dart';
import '../providers/settings_provider.dart';
import 'grid_border_colors.dart';

/// Bottom sheet for the Home calendar's look and the monthly period start
/// day. Every change applies (and saves) immediately.
Future<void> showCustomizeGridSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
    ),
    builder: (_) => const CustomizeGridSheet(),
  );
}

class CustomizeGridSheet extends ConsumerWidget {
  const CustomizeGridSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(calendarGridSettingsProvider);
    void update(CalendarGridSettings next) =>
        ref.read(calendarGridSettingsProvider.notifier).update(next);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              const SizedBox(width: 64),
              Expanded(
                child: Text(
                  l10n.customizeGrid,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _Section(
                icon: Icons.interests_outlined,
                title: l10n.gridShape,
                child: _Options<GridShape>(
                  selected: s.shape,
                  onSelected: (v) => update(s.copyWith(shape: v)),
                  options: [
                    (GridShape.rounded, l10n.shapeRounded, _ShapeIcon.rounded),
                    (GridShape.circle, l10n.shapeCircle, _ShapeIcon.circle),
                    (GridShape.square, l10n.shapeSquare, _ShapeIcon.square),
                  ],
                ),
              ),
              _Section(
                icon: Icons.view_agenda_outlined,
                title: l10n.gridDisplay,
                child: _Options<GridDisplay>(
                  selected: s.display,
                  onSelected: (v) => update(s.copyWith(display: v)),
                  options: [
                    (
                      GridDisplay.single,
                      l10n.displaySingle,
                      const Icon(Icons.crop_square_rounded, size: 30),
                    ),
                    (
                      GridDisplay.stacked,
                      l10n.displayStacked,
                      const Icon(Icons.filter_none_rounded, size: 28),
                    ),
                    (
                      GridDisplay.fan,
                      l10n.displayFan,
                      const Icon(Icons.photo_library_outlined, size: 28),
                    ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.crop_free_rounded,
                title: l10n.gridBorder,
                child: _Options<GridBorder>(
                  selected: s.border,
                  onSelected: (v) => update(s.copyWith(border: v)),
                  options: [
                    (
                      GridBorder.accent,
                      l10n.borderAccent,
                      const _BorderIcon(width: 3),
                    ),
                    (
                      GridBorder.none,
                      l10n.borderNone,
                      const _BorderIcon(width: 0),
                    ),
                    (
                      GridBorder.thin,
                      l10n.borderThin,
                      const _BorderIcon(width: 1.2),
                    ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.palette_outlined,
                title: l10n.borderColor,
                child: Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    _ColorDot(
                      color: theme.colorScheme.primary,
                      label: l10n.colorAuto,
                      selected: s.borderColorKey == null,
                      onTap: () => update(s.copyWith(autoBorderColor: true)),
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    for (final entry in gridBorderColorChoices.entries)
                      _ColorDot(
                        color: entry.value,
                        label: entry.key,
                        selected: s.borderColorKey == entry.key,
                        onTap: () =>
                            update(s.copyWith(borderColorKey: entry.key)),
                      ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.tag_rounded,
                title: l10n.badgeSection,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.showCountBadge),
                  value: s.showBadge,
                  onChanged: (v) => update(s.copyWith(showBadge: v)),
                ),
              ),
              _Section(
                icon: Icons.event_repeat_rounded,
                title: l10n.monthStartDay,
                subtitle: l10n.monthStartDayHelp,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 7,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  children: [
                    for (
                      var day = 1;
                      day <= CalendarGridSettings.maxMonthStartDay;
                      day++
                    )
                      _DayChip(
                        day: day,
                        selected: s.monthStartDay == day,
                        onTap: () => update(s.copyWith(monthStartDay: day)),
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

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    // A Material (not a decorated box) so the switch's ink stays visible.
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card + 4),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Three big option tiles with a label under each.
class _Options<T> extends StatelessWidget {
  final T selected;
  final ValueChanged<T> onSelected;
  final List<(T, String, Widget)> options;

  const _Options({
    required this.selected,
    required this.onSelected,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (value, label, icon) in options)
          Expanded(
            child: Semantics(
              button: true,
              selected: value == selected,
              label: label,
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onSelected(value),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: value == selected
                            ? theme.colorScheme.primary
                            : theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        border: Border.all(color: colors.border),
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: value == selected
                              ? theme.colorScheme.onPrimary
                              : colors.textSecondary,
                        ),
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            color: value == selected
                                ? theme.colorScheme.onPrimary
                                : colors.textSecondary,
                          ),
                          child: Center(child: icon),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: value == selected
                            ? theme.colorScheme.primary
                            : colors.textSecondary,
                        fontWeight: value == selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A small filled shape showing a cell shape option.
class _ShapeIcon extends StatelessWidget {
  static const rounded = _ShapeIcon(radius: 7);
  static const circle = _ShapeIcon(radius: 14);
  static const square = _ShapeIcon(radius: 2);

  final double radius;

  const _ShapeIcon({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: IconTheme.of(context).color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// An outlined square showing a border thickness option.
class _BorderIcon extends StatelessWidget {
  final double width;

  const _BorderIcon({required this.width});

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color!;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: width == 0
            ? Border.all(color: color.withValues(alpha: 0.35))
            : Border.all(color: color, width: width),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  const _ColorDot({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? onSurface : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final int day;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary
          : theme.scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(AppRadii.listThumbnail),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.listThumbnail),
        onTap: onTap,
        child: Center(
          child: Text(
            '$day',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
