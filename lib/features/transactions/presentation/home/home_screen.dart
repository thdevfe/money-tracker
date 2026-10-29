import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/navigation.dart';
import '../../../../core/formatting/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/presentation/customize_grid_sheet.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../domain/ledger.dart';
import '../../providers/transactions_provider.dart';
import '../widgets/account_filter_chips.dart';
import '../form/widgets/day_picker_sheet.dart';
import 'widgets/day_photo_grid.dart';
import 'widgets/day_preview_card.dart';
import 'widgets/month_bar_chart.dart';
import 'widgets/month_transaction_list.dart';
import 'widgets/period_total_cards.dart';
import 'widgets/period_bar.dart';
import 'widgets/photo_calendar.dart';

class HomeScreen extends ConsumerWidget {
  /// Opens the Profile tab (avatar tap).
  final VoidCallback onOpenProfile;

  const HomeScreen({super.key, required this.onOpenProfile});

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

  /// Selects [date] and keeps the visible month in sync.
  static void selectDate(WidgetRef ref, DateTime date) {
    final day = dateOnly(date);
    if (!isSameMonth(day, ref.read(selectedMonthProvider))) {
      ref.read(selectedMonthProvider.notifier).state = monthStart(day);
    }
    ref.read(selectedDateProvider.notifier).state = day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final mode = ref.watch(homeViewModeProvider);
    final dayLayout = ref.watch(dayLayoutProvider);
    final monthLayout = ref.watch(monthLayoutProvider);
    final month = ref.watch(selectedMonthProvider);
    final selected = ref.watch(selectedDateProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    final byDay = ref.watch(homeTransactionsByDayProvider);
    final dayItems = byDay[selected] ?? const [];
    final monthItems = [
      for (final e in byDay.entries)
        if (isSameMonth(e.key, month)) ...e.value,
    ];
    final monthCount = monthItems.length;

    void shiftMonth(int delta) =>
        changeMonth(ref, DateTime(month.year, month.month + delta));
    void shiftDay(int delta) => selectDate(
      ref,
      DateTime(selected.year, selected.month, selected.day + delta),
    );

    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: child,
    );

    /// Cross-fades [child] when [key] changes (month, day or layout).
    Widget switching(Object key, Widget child) => AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: KeyedSubtree(key: ValueKey(key), child: child),
    );

    final isMonth = mode == HomeViewMode.month;
    final periodTotals = totalsOf(isMonth ? monthItems : dayItems);
    // Grid settings only apply to the photo layouts.
    final showsPhotoGrid = isMonth
        ? monthLayout == MonthLayout.calendar
        : dayLayout == DayLayout.grid;

    void cycleLayout(HomeViewMode m) {
      if (m == HomeViewMode.day) {
        final next =
            DayLayout.values[(dayLayout.index + 1) % DayLayout.values.length];
        ref.read(dayLayoutProvider.notifier).state = next;
      } else {
        final next = MonthLayout
            .values[(monthLayout.index + 1) % MonthLayout.values.length];
        ref.read(monthLayoutProvider.notifier).state = next;
      }
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.navClearance,
          ),
          children: [
            padded(
              _Header(
                today: today,
                todayExpenseMinor: totalsOf(
                  byDay[today] ?? const [],
                ).expenseMinor,
                onOpenProfile: onOpenProfile,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            padded(
              Row(
                children: [
                  // Shrinks rather than overflowing with long labels.
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: _ViewToggle(
                        mode: mode,
                        dayLayout: dayLayout,
                        monthLayout: monthLayout,
                        dayCount: dayItems.length,
                        monthCount: monthCount,
                        onChanged: (m) => m == mode
                            ? cycleLayout(m)
                            : ref.read(homeViewModeProvider.notifier).state = m,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _HeaderIconButton(
                    tooltip: l10n.search,
                    icon: Icons.search_rounded,
                    onPressed: () => openSearch(context),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _HideAmountsButton(),
                  if (showsPhotoGrid) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _HeaderIconButton(
                      tooltip: l10n.customizeGrid,
                      icon: Icons.auto_fix_high_rounded,
                      onPressed: () => showCustomizeGridSheet(context),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            padded(
              PeriodTotalCards(
                expenseMinor: periodTotals.expenseMinor,
                incomeMinor: periodTotals.incomeMinor,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AccountFilterChips(
              selectedId: ref.watch(homeAccountFilterProvider),
              onChanged: (id) =>
                  ref.read(homeAccountFilterProvider.notifier).state = id,
            ),
            const SizedBox(height: AppSpacing.md),
            padded(
              isMonth
                  ? PeriodBar(
                      label: fmt.monthYear(month),
                      previousTooltip: l10n.previousMonth,
                      nextTooltip: l10n.nextMonth,
                      onPrevious: () => shiftMonth(-1),
                      onNext: () => shiftMonth(1),
                      onPick: () async {
                        final picked = await showMonthPicker(context, month);
                        if (picked != null) changeMonth(ref, picked);
                      },
                      onToday: isSameMonth(month, today)
                          ? null
                          : () => changeMonth(ref, today),
                    )
                  : PeriodBar(
                      label: fmt.dayMonth(selected),
                      badge: periodTotals.expenseMinor > 0
                          ? fmt.compact(periodTotals.expenseMinor)
                          : null,
                      previousTooltip: l10n.previousDay,
                      nextTooltip: l10n.nextDay,
                      onPrevious: () => shiftDay(-1),
                      onNext: () => shiftDay(1),
                      onPick: () async {
                        final picked = await showDayPicker(
                          context,
                          initial: selected,
                          today: today,
                        );
                        if (picked != null) selectDate(ref, picked);
                      },
                      onToday: isSameDay(selected, today)
                          ? null
                          : () => selectDate(ref, today),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isMonth) ...[
              if (monthLayout == MonthLayout.list)
                padded(
                  switching(
                    'list $month',
                    monthCount == 0
                        ? Card(
                            child: EmptyStateView(
                              compact: true,
                              icon: Icons.calendar_month_outlined,
                              title: l10n.monthEmptyTitle,
                              message: l10n.monthEmptyMessage,
                            ),
                          )
                        : MonthTransactionList(
                            month: month,
                            today: today,
                            transactionsByDay: byDay,
                          ),
                  ),
                )
              else ...[
                padded(
                  switching(
                    '$monthLayout $month',
                    monthLayout == MonthLayout.chart
                        ? MonthBarChart(
                            month: month,
                            selectedDate: selected,
                            today: today,
                            transactionsByDay: byDay,
                            onDateSelected: (date) => selectDate(ref, date),
                          )
                        : PhotoCalendar(
                            month: month,
                            selectedDate: selected,
                            today: today,
                            transactionsByDay: byDay,
                            onMonthOffset: shiftMonth,
                            // Days with entries open their page; empty days
                            // start an entry for that day.
                            onDateSelected: (date) {
                              selectDate(ref, date);
                              if ((byDay[date] ?? const []).isEmpty) {
                                openAddTransaction(context, date: date);
                              } else {
                                openDayDetail(context, date);
                              }
                            },
                            settings: ref.watch(calendarGridSettingsProvider),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                padded(
                  monthCount == 0
                      ? Card(
                          child: EmptyStateView(
                            compact: true,
                            icon: Icons.calendar_month_outlined,
                            title: l10n.monthEmptyTitle,
                            message: l10n.monthEmptyMessage,
                          ),
                        )
                      : DayPreviewCard(
                          date: selected,
                          today: today,
                          transactions: dayItems,
                        ),
                ),
              ],
            ] else
              padded(
                switching(
                  '$dayLayout $selected',
                  dayItems.isEmpty
                      ? EmptyStateView(
                          icon: Icons.photo_camera_back_outlined,
                          title: l10n.dayEmptyTitle,
                          message: l10n.dayEmptyMessage,
                          actionLabel: l10n.addTransaction,
                          onAction: () =>
                              openAddTransaction(context, date: selected),
                        )
                      : dayLayout == DayLayout.list
                      ? DayTransactionsCard(
                          date: selected,
                          today: today,
                          transactions: dayItems,
                        )
                      : DayPhotoGrid(
                          transactions: dayItems,
                          onTap: (t) => openTransactionViewer(
                            context,
                            dayItems,
                            dayItems.indexOf(t),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Greeting, name, "spent today" pill and avatar.
class _Header extends ConsumerWidget {
  final DateTime today;
  final int todayExpenseMinor;
  final VoidCallback onOpenProfile;

  const _Header({
    required this.today,
    required this.todayExpenseMinor,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final hour = ref.watch(clockProvider)().hour;
    // Before 5am still counts as evening.
    final isEvening = hour < 5 || hour >= 18;
    final greeting = isEvening
        ? l10n.greetingEvening
        : hour < 12
        ? l10n.greetingMorning
        : l10n.greetingAfternoon;
    final greetingIcon = isEvening
        ? Icons.nightlight_round
        : Icons.wb_sunny_rounded;
    final savedName = ref.watch(profileNameProvider).trim();
    final name = savedName.isEmpty ? l10n.defaultUserName : savedName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    greeting,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(greetingIcon, size: 16, color: const Color(0xFFF5B83D)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.expense.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_rounded,
                      size: 13,
                      color: colors.expense,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        l10n.spentToday(fmt.money(todayExpenseMinor)),
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
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Semantics(
          button: true,
          label: l10n.openProfile,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onOpenProfile,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Text(
                name.characters.first.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Day ⓝ | Month ⓝ" pill toggle with transaction counts.
class _ViewToggle extends StatelessWidget {
  final HomeViewMode mode;
  final DayLayout dayLayout;
  final MonthLayout monthLayout;
  final int dayCount;
  final int monthCount;

  /// Called with the tapped mode; the selected one cycles its layout.
  final ValueChanged<HomeViewMode> onChanged;

  const _ViewToggle({
    required this.mode,
    required this.dayLayout,
    required this.monthLayout,
    required this.dayCount,
    required this.monthCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);

    Widget segment(
      HomeViewMode value,
      String label,
      IconData icon,
      String layoutName,
      int count,
    ) {
      final selected = mode == value;
      return Semantics(
        button: true,
        selected: selected,
        hint: selected ? l10n.switchLayout(layoutName) : null,
        child: GestureDetector(
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: selected ? theme.colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? theme.colorScheme.onSurface
                        : colors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  icon,
                  size: 14,
                  color: selected
                      ? theme.colorScheme.primary
                      : colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: selected ? theme.colorScheme.primary : colors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(21),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment(
            HomeViewMode.day,
            l10n.viewDay,
            switch (dayLayout) {
              DayLayout.grid => Icons.grid_view_rounded,
              DayLayout.list => Icons.view_list_rounded,
            },
            switch (dayLayout) {
              DayLayout.grid => l10n.layoutGrid,
              DayLayout.list => l10n.layoutList,
            },
            dayCount,
          ),
          segment(
            HomeViewMode.month,
            l10n.viewMonth,
            switch (monthLayout) {
              MonthLayout.calendar => Icons.calendar_view_month_rounded,
              MonthLayout.list => Icons.view_list_rounded,
              MonthLayout.chart => Icons.bar_chart_rounded,
            },
            switch (monthLayout) {
              MonthLayout.calendar => l10n.layoutCalendar,
              MonthLayout.list => l10n.layoutList,
              MonthLayout.chart => l10n.layoutChart,
            },
            monthCount,
          ),
        ],
      ),
    );
  }
}

class _HideAmountsButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hidden = ref.watch(hideAmountsProvider);
    return _HeaderIconButton(
      tooltip: hidden ? l10n.showAmounts : l10n.hideAmounts,
      icon: hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      onPressed: () => ref.read(hideAmountsProvider.notifier).state = !hidden,
    );
  }
}

/// Round tonal icon button used in the Home header.
class _HeaderIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: colors.elevatedSurface,
        foregroundColor: colors.textSecondary,
        fixedSize: const Size(44, 44),
        minimumSize: const Size(44, 44),
      ),
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }
}
