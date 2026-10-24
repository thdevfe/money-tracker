import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models.dart';
import '../../providers/transactions_provider.dart';
import '../category_presentation.dart';
import 'transaction_thumbnail.dart';

Color amountColor(BuildContext context, TransactionType type) {
  final colors = AppColors.of(context);
  return switch (type) {
    TransactionType.expense => colors.expense,
    TransactionType.income => colors.income,
    TransactionType.transfer => colors.transfer,
  };
}

/// One transaction row: thumbnail or category icon, name, category, time and
/// signed amount. Shared by Home, Daily Transactions and Transactions.
class TransactionListItem extends ConsumerWidget {
  final MoneyTransaction transaction;
  final VoidCallback onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    final accounts = ref.watch(accountByIdProvider);
    final t = transaction;

    final String detail;
    if (t.type == TransactionType.transfer) {
      detail = l10n.transferRoute(
        accounts[t.sourceAccountId]?.name ?? '',
        accounts[t.destinationAccountId]?.name ?? '',
      );
    } else {
      detail = [
        t.category?.label(l10n),
        accounts[t.accountId]?.name,
      ].whereType<String>().join(' · ');
    }

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              TransactionThumbnail(transaction: t),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$detail · ${fmt.time(t.occurredAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (t.type == TransactionType.transfer)
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 16,
                        color: colors.transfer,
                      ),
                    ),
                  Text(
                    fmt.signedMoney(t.type, t.amountMinor),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: amountColor(context, t.type),
                      fontFeatures: const [FontFeature.tabularFigures()],
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
