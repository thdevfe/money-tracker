import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/accounts/presentation/accounts_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/transactions/presentation/home/home_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/transactions/providers/transactions_provider.dart';
import '../l10n/app_localizations.dart';
import 'navigation.dart';

/// Tabs: Home, Transactions, (Add), Reports, Accounts.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static const _tabs = [
    HomeScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    AccountsScreen(),
  ];

  void _add() {
    // From Home, default the new transaction to the day selected on the
    // calendar; elsewhere use now.
    final date = _index == 0 ? ref.read(selectedDateProvider) : null;
    openAddTransaction(context, date: date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        onAdd: _add,
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = AppColors.of(context);

    Widget item(int index, IconData icon, IconData selectedIcon, String label) {
      final selected = index == currentIndex;
      final color = selected ? scheme.primary : colors.textSecondary;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          label: label,
          excludeSemantics: true,
          child: InkResponse(
            onTap: () => onSelected(index),
            child: SizedBox(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(selected ? selectedIcon : icon, color: color),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              item(
                0,
                Icons.calendar_month_outlined,
                Icons.calendar_month,
                l10n.navHome,
              ),
              item(
                1,
                Icons.receipt_long_outlined,
                Icons.receipt_long,
                l10n.navTransactions,
              ),
              Expanded(
                child: Center(
                  child: Tooltip(
                    message: l10n.navAdd,
                    child: Semantics(
                      button: true,
                      label: l10n.navAdd,
                      excludeSemantics: true,
                      child: Material(
                        color: scheme.primary,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onAdd,
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.add_rounded,
                              size: 30,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              item(
                2,
                Icons.pie_chart_outline_rounded,
                Icons.pie_chart_rounded,
                l10n.navReports,
              ),
              item(
                3,
                Icons.account_balance_wallet_outlined,
                Icons.account_balance_wallet,
                l10n.navAccounts,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
