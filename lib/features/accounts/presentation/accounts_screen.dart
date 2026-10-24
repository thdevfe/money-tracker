import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/providers/transactions_provider.dart';

/// Cash wallets and bank accounts with derived balances, grouped by type.
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

    Widget group(AccountType type) {
      final items = accounts.where((a) => a.type == type).toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Text(
              type.label(l10n),
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final a in items)
                  ListTile(
                    minTileHeight: 64,
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      child: Icon(a.type.icon),
                    ),
                    title: Text(
                      a.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      fmt.money(balances[a.id] ?? 0),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => openAccountDetail(context, a.id),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navAccounts),
        actions: [
          IconButton(
            tooltip: l10n.addAccount,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => openAccountForm(context),
          ),
        ],
      ),
      body: accounts.isEmpty
          ? Center(
              child: EmptyStateView(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.noAccountsTitle,
                message: l10n.noAccountsMessage,
                actionLabel: l10n.addAccount,
                onAction: () => openAccountForm(context),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.navClearance,
              ),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.accountsTotalLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          fmt.money(ref.watch(totalBalanceProvider)),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                group(AccountType.cash),
                group(AccountType.bank),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: FilledButton.tonalIcon(
                    onPressed: () => openAccountForm(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.addAccount),
                  ),
                ),
              ],
            ),
    );
  }
}
