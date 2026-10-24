import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/ledger.dart';
import '../domain/models.dart';
import '../domain/transaction_query.dart';
import '../providers/transactions_provider.dart';
import 'category_presentation.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/transaction_list_item.dart';

/// All transactions grouped by day, newest first, with combinable filters
/// (time, account, category, type) and text search.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  TransactionQuery get _query => ref.read(transactionsQueryProvider);

  void _setQuery(TransactionQuery query) =>
      ref.read(transactionsQueryProvider.notifier).state = query;

  void _reset() {
    _setQuery(const TransactionQuery());
    _searchController.clear();
    setState(() => _searching = false);
  }

  /// Words a search can match: note, category, type and account names.
  String _searchText(
    MoneyTransaction t,
    AppLocalizations l10n,
    Map<String, Account> accounts,
  ) => [
    t.note ?? '',
    t.category?.label(l10n) ?? t.type.label(l10n),
    for (final id in [t.accountId, t.sourceAccountId, t.destinationAccountId])
      if (id != null) accounts[id]?.name ?? '',
  ].join(' ');

  Future<void> _pickPeriod() async {
    final l10n = AppLocalizations.of(context);
    final picked = await _showOptions<PeriodPreset>(
      title: l10n.filterTime,
      selected: _query.period,
      options: [
        (PeriodPreset.anyTime, l10n.periodAnyTime, Icons.all_inclusive_rounded),
        (PeriodPreset.thisMonth, l10n.periodThisMonth, Icons.today_rounded),
        (PeriodPreset.lastMonth, l10n.periodLastMonth, Icons.history_rounded),
        (PeriodPreset.custom, l10n.periodCustom, Icons.date_range_rounded),
      ],
    );
    if (picked == null || !mounted) return;
    if (picked != PeriodPreset.custom) {
      _setQuery(_query.copyWith(period: picked));
      return;
    }
    final now = ref.read(clockProvider)();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _query.customStart == null
          ? DateTimeRange(start: monthStart(now), end: dateOnly(now))
          : DateTimeRange(start: _query.customStart!, end: _query.customEnd!),
    );
    if (range == null) return;
    _setQuery(
      _query.copyWith(
        period: PeriodPreset.custom,
        customStart: range.start,
        customEnd: range.end,
      ),
    );
  }

  Future<void> _pickAccount() async {
    final l10n = AppLocalizations.of(context);
    final picked = await _showOptions<String>(
      title: l10n.accountLabel,
      selected: _query.accountId ?? '',
      options: [
        ('', l10n.allAccounts, Icons.layers_rounded),
        for (final a in ref.read(accountsProvider)) (a.id, a.name, a.type.icon),
      ],
    );
    if (picked == null) return;
    _setQuery(
      picked.isEmpty
          ? _query.copyWith(clearAccount: true)
          : _query.copyWith(accountId: picked),
    );
  }

  Future<void> _pickCategory() async {
    final l10n = AppLocalizations.of(context);
    final custom = ref.read(ledgerProvider).customCategories;
    // Archived categories stay listed: their transactions are still history.
    List<Category> forType(TransactionType type) => [
      ...Category.systemFor(type),
      ...custom.where((c) => c.type == type),
    ];
    final categories = switch (_query.type) {
      TypeFilter.expense => forType(TransactionType.expense),
      TypeFilter.income => forType(TransactionType.income),
      _ => [
        ...forType(TransactionType.expense),
        ...forType(TransactionType.income),
      ],
    };
    final picked = await _showOptions<String>(
      title: l10n.categoryLabel,
      selected: _query.categoryId ?? '',
      options: [
        ('', l10n.allCategories, Icons.category_outlined),
        for (final c in categories) (c.id, c.label(l10n), c.icon),
      ],
      colors: {for (final c in categories) c.id: c.tint},
    );
    if (picked == null) return;
    _setQuery(
      picked.isEmpty
          ? _query.copyWith(clearCategory: true)
          : _query.copyWith(categoryId: picked),
    );
  }

  Future<T?> _showOptions<T>({
    required String title,
    required T selected,
    required List<(T, String, IconData)> options,
    Map<T, Color> colors = const {},
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final (value, label, icon) in options)
                      ListTile(
                        leading: Icon(icon, color: colors[value]),
                        title: Text(label),
                        trailing: value == selected
                            ? Icon(Icons.check_rounded, color: scheme.primary)
                            : null,
                        onTap: () => Navigator.of(context).pop(value),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final all = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountByIdProvider);
    final query = ref.watch(transactionsQueryProvider);
    final now = ref.watch(clockProvider)();
    final today = dateOnly(now);

    final visible = all
        .where(
          (t) => query.matches(
            t,
            now: now,
            searchText: (t) => _searchText(t, l10n, accounts),
          ),
        )
        .toList();
    final groups = <DateTime, List<MoneyTransaction>>{};
    for (final t in visible) {
      groups.putIfAbsent(dateOnly(t.occurredAt), () => []).add(t);
    }

    final periodLabel = switch (query.period) {
      PeriodPreset.anyTime => l10n.filterTime,
      PeriodPreset.thisMonth => l10n.periodThisMonth,
      PeriodPreset.lastMonth => l10n.periodLastMonth,
      PeriodPreset.custom => l10n.dateRange(
        fmt.dayMonth(query.customStart!),
        fmt.dayMonth(query.customEnd!),
      ),
    };
    Category? category;
    if (query.categoryId case final id?) {
      category = [
        ...Category.systemFor(TransactionType.expense),
        ...Category.systemFor(TransactionType.income),
        ...ref.watch(ledgerProvider).customCategories,
      ].where((c) => c.id == id).firstOrNull;
    }

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (v) => _setQuery(_query.copyWith(search: v)),
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                ),
              )
            : Text(l10n.navTransactions),
        actions: [
          IconButton(
            tooltip: _searching ? l10n.closeSearch : l10n.search,
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _searchController.clear();
                _setQuery(_query.copyWith(search: ''));
              }
            }),
          ),
        ],
      ),
      body: all.isEmpty
          ? Center(
              child: EmptyStateView(
                icon: Icons.receipt_long_outlined,
                title: l10n.transactionsEmptyTitle,
                message: l10n.transactionsEmptyMessage,
                actionLabel: l10n.addTransaction,
                onAction: () => openAddTransaction(context),
              ),
            )
          : CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        // First, so it stays visible on narrow screens.
                        if (query.isFiltered)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.sm,
                            ),
                            child: IconButton.filledTonal(
                              tooltip: l10n.resetFilters,
                              onPressed: _reset,
                              icon: const Icon(Icons.filter_alt_off_rounded),
                            ),
                          ),
                        _FilterButton(
                          key: const ValueKey('filter_time'),
                          icon: Icons.calendar_month_rounded,
                          label: periodLabel,
                          active: query.period != PeriodPreset.anyTime,
                          onTap: _pickPeriod,
                        ),
                        _FilterButton(
                          key: const ValueKey('filter_account'),
                          icon: Icons.account_balance_wallet_outlined,
                          label:
                              accounts[query.accountId]?.name ??
                              l10n.accountLabel,
                          active: query.accountId != null,
                          onTap: _pickAccount,
                        ),
                        _FilterButton(
                          key: const ValueKey('filter_category'),
                          icon: category?.icon ?? Icons.category_outlined,
                          label: category?.label(l10n) ?? l10n.categoryLabel,
                          active: query.categoryId != null,
                          onTap: _pickCategory,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TransactionFilterBar(
                      selected: query.type,
                      onChanged: (f) => _setQuery(query.copyWith(type: f)),
                    ),
                  ),
                ),
                if (query.isFiltered && visible.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        l10n.resultCount(visible.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                if (visible.isEmpty)
                  SliverToBoxAdapter(
                    child: EmptyStateView(
                      icon: Icons.filter_alt_off_outlined,
                      title: l10n.filterEmptyTitle,
                      message: l10n.filterEmptyMessage,
                      actionLabel: l10n.showAll,
                      onAction: _reset,
                    ),
                  ),
                for (final entry in groups.entries) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.md,
                        AppSpacing.xl,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        fmt.dayHeading(entry.key, today),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (final t in entry.value)
                              TransactionListItem(
                                transaction: t,
                                onTap: () => openEditTransaction(context, t),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.navClearance),
                ),
              ],
            ),
    );
  }
}

/// Rounded "icon label ⌄" button that opens a filter picker; highlighted
/// while the filter is set.
class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterButton({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);
    final foreground = active ? scheme.onPrimaryContainer : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Semantics(
        button: true,
        selected: active,
        child: Material(
          color: active ? scheme.primaryContainer : scheme.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: active
                  ? scheme.primary.withValues(alpha: 0.5)
                  : colors.border,
            ),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: AppSpacing.xs),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: foreground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
