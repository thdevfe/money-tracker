import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/ledger.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/presentation/home/widgets/period_bar.dart';
import '../../transactions/presentation/widgets/account_filter_chips.dart';
import '../../transactions/providers/transactions_provider.dart';

enum ReportPeriod { month, year, allTime }

enum ReportTab { category, cluster, map }

/// Income/expense overview for a month, a year or all time, with the expense
/// breakdown by category. Cluster and Map are placeholders.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.month;
  ReportTab _tab = ReportTab.category;
  String? _accountId;
  late DateTime _anchor = monthStart(ref.read(clockProvider)());

  bool _inPeriod(DateTime d) => switch (_period) {
    ReportPeriod.month => isSameMonth(d, _anchor),
    ReportPeriod.year => d.year == _anchor.year,
    ReportPeriod.allTime => true,
  };

  void _shift(int delta) => setState(() {
    _anchor = _period == ReportPeriod.year
        ? DateTime(_anchor.year + delta, _anchor.month)
        : DateTime(_anchor.year, _anchor.month + delta);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final colors = AppColors.of(context);
    final today = ref.watch(clockProvider)();
    final accountId = _accountId;
    final items = ref
        .watch(transactionsProvider)
        .where((t) => _inPeriod(t.occurredAt))
        .where((t) => accountId == null || involvesAccount(t, accountId))
        .toList();
    final totals = totalsOf(items);
    final breakdown = expenseByCategory(items);
    final rate = savingsRate(totals);
    final percent = NumberFormat.percentPattern(fmt.locale);

    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: child,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.navClearance,
          ),
          children: [
            padded(
              _PillTabs<ReportPeriod>(
                values: ReportPeriod.values,
                selected: _period,
                label: (p) => switch (p) {
                  ReportPeriod.month => l10n.periodMonth,
                  ReportPeriod.year => l10n.periodYear,
                  ReportPeriod.allTime => l10n.periodAllTime,
                },
                onChanged: (p) => setState(() => _period = p),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            padded(
              _period == ReportPeriod.allTime
                  ? SizedBox(
                      height: 44,
                      child: Center(
                        child: Text(
                          l10n.allTimeTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  : PeriodBar(
                      label: _period == ReportPeriod.year
                          ? '${_anchor.year}'
                          : fmt.monthYear(_anchor),
                      previousTooltip: _period == ReportPeriod.year
                          ? l10n.previousYear
                          : l10n.previousMonth,
                      nextTooltip: _period == ReportPeriod.year
                          ? l10n.nextYear
                          : l10n.nextMonth,
                      onPrevious: () => _shift(-1),
                      onNext: () => _shift(1),
                      onToday: _inPeriod(today)
                          ? null
                          : () => setState(() => _anchor = monthStart(today)),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            AccountFilterChips(
              selectedId: _accountId,
              onChanged: (id) => setState(() => _accountId = id),
            ),
            const SizedBox(height: AppSpacing.md),
            padded(
              Row(
                children: [
                  Expanded(
                    child: _TotalCard(
                      icon: Icons.south_west_rounded,
                      label: l10n.summaryIncome,
                      value: fmt.money(totals.incomeMinor),
                      color: colors.income,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TotalCard(
                      icon: Icons.north_east_rounded,
                      label: l10n.summaryExpense,
                      value: fmt.money(totals.expenseMinor),
                      color: colors.expense,
                      highlighted: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            padded(
              _BalanceCard(
                balance: fmt.signedMoney(
                  totals.netMinor < 0
                      ? TransactionType.expense
                      : TransactionType.income,
                  totals.netMinor.abs(),
                ),
                positive: totals.netMinor >= 0,
                rate: rate == null ? '—' : percent.format(rate),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            padded(
              _PillTabs<ReportTab>(
                values: ReportTab.values,
                selected: _tab,
                label: (t) => switch (t) {
                  ReportTab.category => l10n.categoryLabel,
                  ReportTab.cluster => l10n.tabCluster,
                  ReportTab.map => l10n.tabMap,
                },
                onChanged: (t) => setState(() => _tab = t),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_tab != ReportTab.category)
              EmptyStateView(
                icon: _tab == ReportTab.map
                    ? Icons.map_outlined
                    : Icons.bubble_chart_outlined,
                title: l10n.laterVersionTitle,
                message: l10n.laterVersionMessage,
              )
            else if (breakdown.isEmpty)
              EmptyStateView(
                icon: Icons.pie_chart_outline_rounded,
                title: l10n.reportsNoExpenses,
              )
            else
              padded(
                Container(
                  decoration: BoxDecoration(
                    color: colors.elevatedSurface,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    children: [
                      for (final c in breakdown)
                        _CategoryRow(
                          total: c,
                          share: c.amountMinor / totals.expenseMinor,
                          percent: percent,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Full-width rounded segmented tabs.
class _PillTabs<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  const _PillTabs({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: Semantics(
                button: true,
                selected: v == selected,
                child: GestureDetector(
                  onTap: () => onChanged(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: v == selected
                          ? theme.colorScheme.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Text(
                      label(v),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: v == selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: v == selected
                            ? theme.colorScheme.onSurface
                            : colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool highlighted;

  const _TotalCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlighted
            ? color.withValues(alpha: 0.10)
            : colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: highlighted
              ? color.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: highlighted ? color : colors.textSecondary,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: highlighted ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String balance;
  final bool positive;
  final String rate;

  const _BalanceCard({
    required this.balance,
    required this.positive,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(
      color: colors.textSecondary,
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.reportsBalance, style: labelStyle),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    balance,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: positive ? colors.income : colors.expense,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(l10n.savingsRate, style: labelStyle),
              const SizedBox(height: 2),
              Text(
                rate,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final CategoryTotal total;
  final double share;
  final NumberFormat percent;

  const _CategoryRow({
    required this.total,
    required this.share,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final c = total.category;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.tint,
              borderRadius: BorderRadius.circular(AppRadii.listThumbnail),
            ),
            child: Icon(c.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.label(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      fmt.money(total.amountMinor),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.categoryShareDetail(total.count, percent.format(share)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: 5,
                    color: c.tint,
                    backgroundColor: colors.border,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
