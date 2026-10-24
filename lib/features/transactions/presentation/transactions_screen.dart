import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/ledger.dart';
import '../domain/models.dart';
import '../providers/transactions_provider.dart';
import 'category_presentation.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/transaction_list_item.dart';

/// All transactions grouped by day, newest first, with type filters and a
/// simple text search.
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

  bool _matchesQuery(
    MoneyTransaction t,
    String query,
    AppLocalizations l10n,
    Map<String, Account> accounts,
  ) {
    if (query.isEmpty) return true;
    final haystack = [
      t.note ?? '',
      t.category?.label(l10n) ?? t.type.label(l10n),
      for (final id in [t.accountId, t.sourceAccountId, t.destinationAccountId])
        if (id != null) accounts[id]?.name ?? '',
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }

  void _resetFilters() {
    ref.read(transactionsFilterProvider.notifier).state = TransactionFilter.all;
    _searchController.clear();
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final all = ref.watch(transactionsProvider);
    final accounts = ref.watch(accountByIdProvider);
    final filter = ref.watch(transactionsFilterProvider);
    final today = dateOnly(ref.watch(clockProvider)());
    final query = _searchController.text.trim().toLowerCase();

    final visible = all
        .where(filter.matches)
        .where((t) => _matchesQuery(t, query, l10n, accounts))
        .toList();
    final groups = <DateTime, List<MoneyTransaction>>{};
    for (final t in visible) {
      groups.putIfAbsent(dateOnly(t.occurredAt), () => []).add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
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
              if (!_searching) _searchController.clear();
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
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      bottom: AppSpacing.sm,
                    ),
                    child: TransactionFilterBar(
                      selected: filter,
                      onChanged: (f) =>
                          ref.read(transactionsFilterProvider.notifier).state =
                              f,
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
                      onAction: _resetFilters,
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
