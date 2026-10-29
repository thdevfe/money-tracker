import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../deposits/domain/term_deposit.dart';
import '../../deposits/providers/deposits_provider.dart';
import '../../transactions/domain/ledger.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/providers/transactions_provider.dart';

/// Overview (balance, income and expense by period), account cards and
/// term deposits.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final accounts = ref.watch(accountsProvider);
    final balances = ref.watch(accountBalancesProvider);

    if (accounts.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navAccounts)),
        body: Center(
          child: EmptyStateView(
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.noAccountsTitle,
            message: l10n.noAccountsMessage,
            actionLabel: l10n.addAccount,
            onAction: () => openAccountForm(context),
          ),
        ),
      );
    }

    // Cash first, then bank, keeping creation order within a type.
    final ordered = [
      ...accounts.where((a) => a.type == AccountType.cash),
      ...accounts.where((a) => a.type == AccountType.bank),
    ];
    final groupTotal = ordered.fold<int>(
      0,
      (sum, a) => sum + (balances[a.id] ?? 0),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.read(depositsProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.navClearance,
            ),
            children: [
              const _Overview(),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Text(
                    l10n.accountsSection,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _CountBadge(count: accounts.length),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: l10n.transferMoney,
                    icon: const Icon(Icons.swap_horiz_rounded),
                    onPressed: () => openTransfer(context),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    tooltip: l10n.addAccount,
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () => openAccountForm(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.cashAndBank,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        _CountBadge(count: ordered.length),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    fmt.money(groupTotal),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: groupTotal < 0 ? colors.expense : null,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final a in ordered) ...[
                _AccountCard(account: a, balanceMinor: balances[a.id] ?? 0),
                const SizedBox(height: AppSpacing.sm),
              ],
              _AddRow(
                label: l10n.addAccount,
                onTap: () => openAccountForm(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.termDeposits,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    key: const ValueKey('add_deposit'),
                    onPressed: () => openDepositForm(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(l10n.addDeposit),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const _Deposits(),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Period { month, year, all }

/// Total balance with income and expense for this month, year or all time.
class _Overview extends ConsumerStatefulWidget {
  const _Overview();

  @override
  ConsumerState<_Overview> createState() => _OverviewState();
}

class _OverviewState extends ConsumerState<_Overview> {
  _Period _period = _Period.month;
  late DateTime _anchor = monthStart(ref.read(clockProvider)());

  void _shift(int delta) => setState(() {
    _anchor = _period == _Period.month
        ? DateTime(_anchor.year, _anchor.month + delta)
        : DateTime(_anchor.year + delta, _anchor.month);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final total = ref.watch(totalBalanceProvider);
    final inPeriod = ref
        .watch(transactionsProvider)
        .where(
          (t) => switch (_period) {
            _Period.month => isSameMonth(t.occurredAt, _anchor),
            _Period.year => t.occurredAt.year == _anchor.year,
            _Period.all => true,
          },
        );
    final totals = totalsOf(inPeriod);

    Widget periodTab(_Period p, String label) {
      final selected = _period == p;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _period = p;
            _anchor = monthStart(ref.read(clockProvider)());
          }),
          child: Semantics(
            button: true,
            selected: selected,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? null : colors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget stat(String label, int minor, Color dot) => Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 3, backgroundColor: dot),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          fmt.money(minor),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(AppRadii.card + 4),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                periodTab(_Period.month, l10n.periodThisMonth),
                periodTab(_Period.year, l10n.periodThisYear),
                periodTab(_Period.all, l10n.periodAllTimeShort),
              ],
            ),
          ),
          if (_period != _Period.all)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: _period == _Period.month
                      ? l10n.previousMonth
                      : l10n.previousYear,
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => _shift(-1),
                ),
                Flexible(
                  child: Text(
                    _period == _Period.month
                        ? fmt.monthYear(_anchor)
                        : '${_anchor.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _period == _Period.month
                      ? l10n.nextMonth
                      : l10n.nextYear,
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => _shift(1),
                ),
              ],
            )
          else
            const SizedBox(height: AppSpacing.md),
          Text(
            l10n.totalBalance,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              fmt.money(total),
              key: const ValueKey('accounts_total'),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: total < 0 ? colors.expense : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: stat(
                  l10n.summaryIncome,
                  totals.incomeMinor,
                  colors.income,
                ),
              ),
              Expanded(
                child: stat(
                  l10n.summaryExpense,
                  totals.expenseMinor,
                  colors.expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final int balanceMinor;

  const _AccountCard({required this.account, required this.balanceMinor});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final tint = account.type == AccountType.cash
        ? const Color(0xFF3FBF6F)
        : const Color(0xFF3B82F6);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              tint.withValues(alpha: 0.28),
              tint.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: tint.withValues(alpha: 0.45)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: () => openAccountDetail(context, account.id),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(account.type.icon, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        account.type.label(l10n),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  fmt.money(balanceMinor),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: balanceMinor < 0 ? colors.expense : null,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Deposits extends ConsumerWidget {
  const _Deposits();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final today = dateOnly(ref.watch(clockProvider)());
    return ref
        .watch(depositsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              l10n.depositsLoadFailed,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          data: (deposits) => deposits.isEmpty
              ? Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    leading: Icon(
                      Icons.account_balance_rounded,
                      color: colors.textSecondary,
                    ),
                    title: Text(l10n.noDepositsTitle),
                    subtitle: Text(l10n.noDepositsMessage),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => openDepositForm(context),
                  ),
                )
              : Column(
                  children: [
                    for (final d in deposits) ...[
                      _DepositCard(deposit: d, today: today),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
        );
  }
}

class _DepositCard extends StatelessWidget {
  final TermDeposit deposit;
  final DateTime today;

  const _DepositCard({required this.deposit, required this.today});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final matured = deposit.isMatured(today);
    final rate = fmt.decimal(deposit.ratePercent);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openDepositForm(context, existing: deposit),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(
                      0xFFF5B83D,
                    ).withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.savings_rounded,
                      size: 20,
                      color: Color(0xFFF5B83D),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deposit.bankName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.depositRateTerm(rate, deposit.termMonths),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    fmt.money(deposit.principalMinor),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: deposit.progress(today),
                  minHeight: 6,
                  color: matured ? colors.income : const Color(0xFFF5B83D),
                  backgroundColor: colors.border,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      matured
                          ? l10n.depositMatured
                          : l10n.depositMaturity(
                              fmt.shortDate(deposit.maturityDate),
                            ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: matured ? colors.income : colors.textSecondary,
                        fontWeight: matured ? FontWeight.w700 : null,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${fmt.signedMoney(TransactionType.income, deposit.accruedInterestMinor(today))}'
                      ' / ${fmt.money(deposit.interestAtMaturityMinor)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.income,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: colors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Outlined "+ label" row at the end of a list.
class _AddRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddRow({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        foregroundColor: colors.textSecondary,
        side: BorderSide(color: colors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      onPressed: onTap,
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
    );
  }
}
