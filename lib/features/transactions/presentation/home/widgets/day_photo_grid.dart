import 'package:flutter/material.dart';

import '../../../../../core/formatting/formatters.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models.dart';
import '../../category_presentation.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/transaction_thumbnail.dart';

/// Shared by a grid tile and its card in the transaction viewer.
String transactionHeroTag(MoneyTransaction t) => 'transaction-${t.id}';

/// Three-column grid of a day's transactions: the photo (or a category tile)
/// with the amount overlaid. Used by the Day view on Home.
class DayPhotoGrid extends StatelessWidget {
  final List<MoneyTransaction> transactions;
  final ValueChanged<MoneyTransaction> onTap;

  const DayPhotoGrid({
    super.key,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sm;
        final size = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final t in transactions)
              _GridTile(transaction: t, size: size, onTap: () => onTap(t)),
          ],
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  final MoneyTransaction transaction;
  final double size;
  final VoidCallback onTap;

  const _GridTile({
    required this.transaction,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = Formatters.of(context);
    final t = transaction;
    final amount = t.type == TransactionType.income
        ? fmt.signedMoney(t.type, t.amountMinor)
        : fmt.money(t.amountMinor);
    final tile = CategoryTile(transaction: t, size: size, radius: 0);

    return Semantics(
      button: true,
      label: '${t.title(l10n)}, $amount',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Grows into the viewer card when opened.
                Hero(
                  tag: transactionHeroTag(t),
                  child: t.photo != null
                      ? PhotoImage(photo: t.photo!, size: size, fallback: tile)
                      : tile,
                ),
                if (t.photo == null)
                  Positioned(
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: Text(
                      t.title(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Positioned(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        amount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
