import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/empty_state_view.dart';
import '../features/accounts/presentation/accounts_screen.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/transactions/presentation/home/home_screen.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../features/transactions/providers/transactions_provider.dart';
import '../l10n/app_localizations.dart';
import 'navigation.dart';

/// Tabs: Home, Reports, Transactions, Accounts, Profile. A floating pill nav
/// bar with the + button beside it sits over the content.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _homeTab = 0;
  static const _profileTab = 4;

  int _index = _homeTab;

  void _add() {
    // From Home, default the new transaction to the selected calendar day;
    // elsewhere use now.
    final date = _index == _homeTab ? ref.read(selectedDateProvider) : null;
    openAddTransaction(context, date: date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: switch (ref.watch(ledgerProvider.select((s) => s.status))) {
        LedgerStatus.loading when ref.read(transactionsProvider).isEmpty =>
          const Center(child: CircularProgressIndicator()),
        LedgerStatus.error => _LoadError(
          onRetry: () => ref.read(ledgerProvider.notifier).load(),
        ),
        _ => IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              onOpenProfile: () => setState(() => _index = _profileTab),
            ),
            const ReportsScreen(),
            const TransactionsScreen(),
            const AccountsScreen(),
            const SettingsScreen(),
          ],
        ),
      },
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        onAdd: _add,
      ),
    );
  }
}

/// Floating, icon-only pill navigation bar with the + button on its right,
/// so the button never covers screen content.
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

    final items = [
      (Icons.home_outlined, Icons.home_rounded, l10n.navHome),
      (
        Icons.pie_chart_outline_rounded,
        Icons.pie_chart_rounded,
        l10n.navReports,
      ),
      (
        Icons.receipt_long_outlined,
        Icons.receipt_long_rounded,
        l10n.navTransactions,
      ),
      (
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded,
        l10n.navAccounts,
      ),
      (Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];

    // Floats clear of the screen edges. Home-screen web apps get no safe-area
    // inset from Flutter, so the minimum keeps a visible gap there too.
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: _pill(items, scheme, colors)),
            const SizedBox(width: AppSpacing.sm),
            // Same tile height and tab-button shape as the pill's items.
            Tooltip(
              message: l10n.navAdd,
              child: Semantics(
                button: true,
                label: l10n.navAdd,
                excludeSemantics: true,
                child: Container(
                  width: _barHeight,
                  height: _barHeight,
                  alignment: Alignment.center,
                  decoration: _barDecoration(colors),
                  child: Material(
                    color: scheme.primary,
                    shape: const StadiumBorder(),
                    child: InkWell(
                      customBorder: const StadiumBorder(),
                      onTap: onAdd,
                      child: SizedBox(
                        width: _tabWidth,
                        height: _tabHeight,
                        child: Icon(Icons.add_rounded, color: scheme.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _barHeight = 60.0;
  static const _tabWidth = 48.0;
  static const _tabHeight = 40.0;

  static BoxDecoration _barDecoration(AppColors colors) => BoxDecoration(
    color: colors.elevatedSurface,
    borderRadius: BorderRadius.circular(_barHeight / 2),
    border: Border.all(color: colors.border),
    boxShadow: const [
      BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
  );

  Widget _pill(
    List<(IconData, IconData, String)> items,
    ColorScheme scheme,
    AppColors colors,
  ) {
    return Container(
      height: _barHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: _barDecoration(colors),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Tooltip(
                message: items[i].$3,
                child: Semantics(
                  button: true,
                  selected: i == currentIndex,
                  label: items[i].$3,
                  excludeSemantics: true,
                  child: InkResponse(
                    onTap: () => onSelected(i),
                    radius: 28,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _tabWidth,
                        height: _tabHeight,
                        decoration: BoxDecoration(
                          color: i == currentIndex
                              ? scheme.primary.withValues(alpha: 0.16)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          i == currentIndex ? items[i].$2 : items[i].$1,
                          color: i == currentIndex
                              ? scheme.primary
                              : colors.textSecondary,
                        ),
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

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: EmptyStateView(
        icon: Icons.cloud_off_rounded,
        title: l10n.loadErrorTitle,
        message: l10n.loadErrorMessage,
        actionLabel: l10n.retry,
        onAction: onRetry,
      ),
    );
  }
}
