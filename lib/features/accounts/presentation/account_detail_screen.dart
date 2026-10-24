import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation.dart';
import '../../../core/formatting/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/ledger.dart';
import '../../transactions/domain/ledger_repository.dart';
import '../../transactions/domain/models.dart';
import '../../transactions/presentation/category_presentation.dart';
import '../../transactions/presentation/widgets/transaction_list_item.dart';
import '../../transactions/providers/transactions_provider.dart';
import 'account_form_screen.dart';

/// One account: balance, recent transactions, edit and delete.
class AccountDetailScreen extends ConsumerWidget {
  static const _recentLimit = 20;

  final String accountId;

  const AccountDetailScreen({super.key, required this.accountId});

  Future<void> _delete(BuildContext context, WidgetRef ref, Account a) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(ledgerProvider.notifier).deleteAccount(a);
      navigator.pop();
    } on LedgerException catch (e) {
      if (e.failure == LedgerFailure.inUse && context.mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteAccountTitle),
            content: Text(l10n.accountInUseMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.done),
              ),
            ],
          ),
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l10n.deleteFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final account = ref.watch(accountByIdProvider)[accountId];
    if (account == null) return const Scaffold();
    final transactions = ref.watch(transactionsProvider);
    final recent = transactions
        .where(
          (t) =>
              t.accountId == accountId ||
              t.sourceAccountId == accountId ||
              t.destinationAccountId == accountId,
        )
        .take(_recentLimit)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            tooltip: l10n.editAccount,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AccountFormScreen(existing: account),
                fullscreenDialog: true,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _delete(context, ref, account),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                      child: Icon(account.type.icon),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.currentBalanceLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              fmt.money(accountBalance(account, transactions)),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${account.type.label(l10n)} · '
                            '${l10n.openingBalanceLabel}: '
                            '${fmt.money(account.openingBalanceMinor)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Text(
              l10n.recentTransactions,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (recent.isEmpty)
            EmptyStateView(
              compact: true,
              icon: Icons.receipt_long_outlined,
              title: l10n.noTransactionsYet,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final MoneyTransaction t in recent)
                      TransactionListItem(
                        transaction: t,
                        onTap: () => openEditTransaction(context, t),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
